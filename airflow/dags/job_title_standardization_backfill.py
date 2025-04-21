from airflow import DAG
from airflow.providers.postgres.hooks.postgres import PostgresHook
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from airflow.operators.python import PythonOperator
from datetime import datetime

MODEL_NAME = "typeform/distilbert-base-uncased-mnli"
MODEL_DIR = "/opt/airflow/models/typeform-mnli"
CLASSIFIER = None
BATCH_SIZE = 1000

DEPARTMENTS = ["Engineering", "Sales", "Marketing", "Human Resources", "Finance", "Operations"]
FUNCTIONS = ["Software Development", "Customer Support", "Product Management", "Recruitment", "Accounting"]
SENIORITIES = ["Intern", "Junior", "Mid-level", "Senior", "Lead", "Manager", "Director", "VP", "C-level"]


def init_classifier():
    from transformers import pipeline
    global CLASSIFIER
    if CLASSIFIER is None:
        CLASSIFIER = pipeline("zero-shot-classification",  model=MODEL_DIR, tokenizer=MODEL_DIR)
    return CLASSIFIER



def classify_title(title):
    CLASSIFIER = init_classifier()
    dept = CLASSIFIER(title, DEPARTMENTS)['labels'][0]
    func = CLASSIFIER(title, FUNCTIONS)['labels'][0]
    senior = CLASSIFIER(title, SENIORITIES)['labels'][0]
    return dept, func, senior

# Function to insert a record into the standardized_title table
def insert_standardized_title(session, record):
    try:
        title_update_query = """
            INSERT INTO standardized_title (job_title, job_department, job_function, job_seniority)
            VALUES (:job_title, :job_department, :job_function, :job_seniority)
        """
        session.execute(title_update_query, {
            "job_title": record["job_title"],
            "job_department": record["job_department"],
            "job_function": record["job_function"],
            "job_seniority": record["job_seniority"],
        })
        session.commit()
        print(f"Record inserted successfully: {record}")

    except Exception as e:
        print(f"Error inserting record: {e}")


# Function to get the current offset from the checkpoint table
def get_current_offset(session):
    checkpoint_check_query = "SELECT backfill_offset FROM backfill_checkpoint ORDER BY backfill_offset DESC LIMIT 1;"
    checkpoint_record = session.execute(checkpoint_check_query).fetchone()
    if checkpoint_record:
        return checkpoint_record[0]
    else:
        return 0

# Function to fetch a batch of titles from the database
def fetch_batch_of_titles(session, batch_size, offset):
    sql_query = f"""
        SELECT DISTINCT ON (title) id, title
        FROM member
        ORDER BY title, id
        LIMIT {batch_size} OFFSET {offset};
    """
    return session.execute(sql_query).fetchall()

# Function to insert or update the offset in the checkpoint table
def insert_or_update_checkpoint(session, offset, batch_size):
    checkpoint_exists_query = f"""
        SELECT * FROM backfill_checkpoint WHERE backfill_offset = {offset};
    """
    checkpoint_exists = session.execute(checkpoint_exists_query).fetchone()

    if not checkpoint_exists:
        checkpoint_insert_query = f"""
            INSERT INTO backfill_checkpoint (backfill_offset)
            VALUES ({offset});
        """
        session.execute(checkpoint_insert_query)
        session.commit() 
    else:
        new_offset = offset + batch_size
        checkpoint_update_query = f"""
            UPDATE backfill_checkpoint
            SET backfill_offset = {new_offset}
            WHERE backfill_offset = {offset};
        """
        session.execute(checkpoint_update_query)
        session.commit()

# Function to process the titles fetched from the batch
def process_titles(titles):
    for row in titles:
        department, function, seniority = classify_title(row['title'])

        enriched_record = {
            "job_title": row['title'],
            "job_department": department,
            "job_function": function,
            "job_seniority": seniority
        }
        print("Enriched record:", enriched_record)
        return enriched_record

# Main function to fetch titles in batches and update checkpoint
def fetch_and_process_batches(**kwargs):
    batch_size = kwargs.get('batch_size', BATCH_SIZE)
    offset = kwargs.get('offset', 0)

    hook = PostgresHook(postgres_conn_id='testdb')
    engine = create_engine(
        hook.get_uri(),
        pool_size=10,
        max_overflow=20,
        pool_timeout=30,
        pool_recycle=3600,
        echo=False
    )

    Session = sessionmaker(bind=engine)
    session = Session()

    try:
        while True:
            offset = get_current_offset(session)
            titles = fetch_batch_of_titles(session, batch_size, offset)

            if titles:
                enriched_record = process_titles(titles)
                insert_standardized_title(session, enriched_record)
                insert_or_update_checkpoint(session, offset, batch_size)
                offset += batch_size
            else:
                print("✅ No more records to process.")
                break

    finally:
        session.close()


default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 4, 19),
    'retries': 1,
}


with DAG(
    'job_standardization_manual_backfill',
    default_args=default_args,
    description='DAG to fetch member titles in batches and standardize titles using AI',
    schedule_interval=None,
    catchup=False,
    dagrun_timeout=None,
    tags=['manual_backfill'],
) as dag:

    fetch_titles_task = PythonOperator(
        task_id='fetch_titles_task',
        python_callable=fetch_and_process_batches,
        op_kwargs={'batch_size': BATCH_SIZE},
        provide_context=True,
    )