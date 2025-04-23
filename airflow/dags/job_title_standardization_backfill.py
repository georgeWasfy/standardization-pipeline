from airflow import DAG
from airflow.providers.postgres.hooks.postgres import PostgresHook
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from airflow.operators.python import PythonOperator
from datetime import datetime
import re

MODEL_NAME = "typeform/distilbert-base-uncased-mnli"
MODEL_DIR = "/opt/airflow/models/typeform-mnli"
CLASSIFIER = None
BATCH_SIZE = 1000

DEPARTMENTS = [
  "C-Suite",
  "Engineering & Technical",
  "Design",
  "Education",
  "Finance",
  "Human Resources",
  "Information Technology",
  "Legal",
  "Marketing",
  "Medical & Health",
  "Operations",
  "Sales",
  "Consulting"
];
FUNCTIONS = [
  "Executive",
  "Finance Executive",
  "Founder",
  "Human Resources Executive",
  "Information Technology Executive",
  "Legal Executive",
  "Marketing Executive",
  "Medical & Health Executive",
  "Operations Executive",
  "Sales Leader",
  "Artificial Intelligence / Machine Learning",
  "Bioengineering",
  "Biometrics",
  "Business Intelligence",
  "Chemical Engineering",
  "Cloud / Mobility",
  "Data Science",
  "DevOps",
  "Digital Transformation",
  "Emerging Technology / Innovation",
  "Engineering & Technical",
  "Industrial Engineering",
  "Mechanic",
  "Mobile Development",
  "Product Development",
  "Product Management",
  "Project Management",
  "Research & Development",
  "Scrum Master / Agile Coach",
  "Software Development",
  "Support / Technical Services",
  "Technician",
  "Technology Operations",
  "Test / Quality Assurance",
  "UI / UX",
  "Web Development",
  "All Design",
  "Product or UI/UX Design",
  "Graphic / Visual / Brand Design",
  "Teacher",
  "Principal",
  "Superintendent",
  "Professor",
  "Accounting",
  "Finance",
  "Financial Planning & Analysis",
  "Financial Reporting",
  "Financial Strategy",
  "Financial Systems",
  "Internal Audit & Control",
  "Investor Relations",
  "Mergers & Acquisitions",
  "Real Estate Finance",
  "Financial Risk",
  "Shared Services",
  "Sourcing / Procurement",
  "Tax",
  "Treasury",
  "Compensation & Benefits",
  "Culture, Diversity & Inclusion",
  "Employee & Labor Relations",
  "Health & Safety",
  "Human Resource Information System",
  "Human Resources",
  "HR Business Partner",
  "Learning & Development",
  "Organizational Development",
  "Recruiting & Talent Acquisition",
  "Talent Management",
  "Workforce Management",
  "People Operations",
  "Application Development",
  "Business Service Management / ITSM",
  "Collaboration & Web App",
  "Data Center",
  "Data Warehouse",
  "Database Administration",
  "eCommerce Development",
  "Enterprise Architecture",
  "Help Desk / Desktop Services",
  "HR / Financial / ERP Systems",
  "Information Security",
  "Information Technology",
  "Infrastructure",
  "IT Asset Management",
  "IT Audit / IT Compliance",
  "IT Operations",
  "IT Procurement",
  "IT Strategy",
  "IT Training",
  "Networking",
  "Project & Program Management",
  "Quality Assurance",
  "Retail / Store Systems",
  "Servers",
  "Storage & Disaster Recovery",
  "Telecommunications",
  "Virtualization",
  "Acquisitions",
  "Compliance",
  "Contracts",
  "Corporate Secretary",
  "eDiscovery",
  "Ethics",
  "Governance",
  "Governmental Affairs & Regulatory Law",
  "Intellectual Property & Patent",
  "Labor & Employment",
  "Lawyer / Attorney",
  "Legal",
  "Legal Counsel",
  "Legal Operations",
  "Litigation",
  "Privacy",
  "Advertising",
  "Brand Management",
  "Content Marketing",
  "Customer Experience",
  "Customer Marketing",
  "Demand Generation",
  "Digital Marketing",
  "eCommerce Marketing",
  "Event Marketing",
  "Field Marketing",
  "Lead Generation",
  "Marketing",
  "Marketing Analytics / Insights",
  "Marketing Communications",
  "Marketing Operations",
  "Product Marketing",
  "Public Relations",
  "Search Engine Optimization / Pay Per Click",
  "Social Media Marketing",
  "Strategic Communications",
  "Technical Marketing",
  "Anesthesiology",
  "Chiropractics",
  "Clinical Systems",
  "Dentistry",
  "Dermatology",
  "Doctors / Physicians",
  "Epidemiology",
  "First Responder",
  "Infectious Disease",
  "Medical Administration",
  "Medical Education & Training",
  "Medical Research",
  "Medicine",
  "Neurology",
  "Nursing",
  "Nutrition & Dietetics",
  "Obstetrics / Gynecology",
  "Oncology",
  "Ophthalmology",
  "Optometry",
  "Orthopedics",
  "Pathology",
  "Pediatrics",
  "Pharmacy",
  "Physical Therapy",
  "Psychiatry",
  "Psychology",
  "Public Health",
  "Radiology",
  "Social Work",
  "Call Center",
  "Construction",
  "Corporate Strategy",
  "Customer Service / Support",
  "Enterprise Resource Planning",
  "Facilities Management",
  "Leasing",
  "Logistics",
  "Office Operations",
  "Operations",
  "Physical Security",
  "Project Development",
  "Quality Management",
  "Real Estate",
  "Safety",
  "Store Operations",
  "Supply Chain",
  "Account Management",
  "Business Development",
  "Channel Sales",
  "Customer Retention & Development",
  "Customer Success",
  "Field / Outside Sales",
  "Inside Sales",
  "Partnerships",
  "Revenue Operations",
  "Sales",
  "Sales Enablement",
  "Sales Engineering",
  "Sales Operations",
  "Sales Training",
  "Business Strategy Consulting",
  "Change Management Consulting",
  "Customer Experience Consulting",
  "Data Analytics Consulting",
  "Digital Transformation Consulting",
  "Environmental Consulting",
  "Financial Advisory Consulting",
  "Healthcare Consulting",
  "Human Resources Consulting",
  "Information Technology Consulting",
  "Management Consulting",
  "Marketing Consulting",
  "Mergers & Acquisitions Consulting",
  "Organizational Development Consulting",
  "Process Improvement Consulting",
  "Risk Management Consulting",
  "Sales Strategy Consulting",
  "Supply Chain Consulting",
  "Sustainability Consulting",
  "Tax Consulting",
  "Technology Implementation Consulting",
  "Training & Development Consulting"
];
SENIORITIES = [
  "Owner",
  "Founder",
  "C-suite",
  "Partner",
  "VP",
  "Head",
  "Director",
  "Manager",
  "Senior",
  "Entry",
  "Intern"
]

def is_probable_job_title(title):
    if not title or len(title) < 3:
        return False
    if re.fullmatch(r'[\W\d_]+', title):  # Only punctuation or digits
        return False
    if sum(c.isalpha() for c in title) < 3:
        return False
    return True

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

# Function to check if a title already processed
def title_already_exists(session, title):
    query = """
        SELECT 1 FROM standardized_title WHERE job_title = :job_title LIMIT 1
    """
    result = session.execute(query, {"job_title": title}).fetchone()
    return bool(result)

# Function to insert a record into the standardized_title table
def insert_standardized_title(session, record):
    try:
        title_update_query = """
            INSERT INTO standardized_title (job_title, job_department, job_function, job_seniority)
            VALUES (:job_title, :job_department, :job_function, :job_seniority)
            ON CONFLICT (job_title) DO NOTHING
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
def process_title(row):
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

            if not titles:
                print("✅ No more records to process.")
                break

            for row in titles:
                title = row["title"]
                if not is_probable_job_title(title):
                    print(f"⏭️ Skipping non-job title: '{title}'")
                    continue
                
                if not title_already_exists(session, title):
                    enriched_record = process_title(row)
                    insert_standardized_title(session, enriched_record)

            insert_or_update_checkpoint(session, offset, batch_size)
            offset += batch_size


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