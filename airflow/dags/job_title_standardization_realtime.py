from airflow import DAG
from airflow.providers.postgres.hooks.postgres import PostgresHook
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from airflow.operators.python import PythonOperator
from datetime import datetime

MODEL_NAME = "typeform/distilbert-base-uncased-mnli"
CLASSIFIER = None
BATCH_SIZE = 1000

DEPARTMENTS = ["Engineering", "Sales", "Marketing", "Human Resources", "Finance", "Operations"]
FUNCTIONS = ["Software Development", "Customer Support", "Product Management", "Recruitment", "Accounting"]
SENIORITIES = ["Intern", "Junior", "Mid-level", "Senior", "Lead", "Manager", "Director", "VP", "C-level"]


def init_classifier():
    from transformers import pipeline, AutoModelForSequenceClassification, AutoTokenizer
    global CLASSIFIER
    if CLASSIFIER is None:
        model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME)
        tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

        # Save to a local folder
        model.save_pretrained("./local-models/typeform-mnli")
        tokenizer.save_pretrained("./local-models/typeform-mnli")

        CLASSIFIER = pipeline("zero-shot-classification", model="./local-models/typeform-mnli", tokenizer="./local-models/typeform-mnli")
    return CLASSIFIER

def classify_title(title):
    CLASSIFIER = init_classifier()
    dept = CLASSIFIER(title, DEPARTMENTS)['labels'][0]
    func = CLASSIFIER(title, FUNCTIONS)['labels'][0]
    senior = CLASSIFIER(title, SENIORITIES)['labels'][0]
    return dept, func, senior

def process_title(title):
    department, function, seniority = classify_title(title)

    enriched_record = {
        "job_title": title,
        "job_department": department,
        "job_function": function,
        "job_seniority": seniority
    }
    print("Enriched record:", enriched_record)
    return enriched_record
    
# Function to insert a record into the standardized_title table
def insert_standardized_title(session, record):
    try:
        title_update_query = f"""
            INSERT INTO standardized_title (job_title, job_department, job_function, job_seniority)
            VALUES ({record["job_title"]}, {record["job_department"]}, {record["job_function"]}, {record["job_seniority"]});
        """
        session.execute(title_update_query)
        session.commit()
        print(f"Record inserted successfully: {record}")
    except Exception as e:
        print(f"Error inserting record: {e}")

# Main function to standardize_title
def standardize_title(**kwargs):
    dag_run = kwargs.get('dag_run')
    if dag_run:
        conf = dag_run.conf or {}
        title = conf.get("title")
    else:
        print(f"No title found for enrichment")

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
        enriched_record = process_title(title)
        insert_standardized_title(session, enriched_record)

    finally:
        session.close()

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
}

with DAG(
    dag_id="job_standardization_online_strategy",
    default_args=default_args,
    start_date=datetime(2025, 4, 15),
    schedule_interval=None,
    tags=['online_strategy'],
) as dag:

    process_task = PythonOperator(
        task_id="process_job_title",
        python_callable=standardize_title,
        provide_context=True,
    )