import os
import json
from confluent_kafka import Consumer
from transformers import pipeline
import psycopg2
from psycopg2 import sql

# Database connection details
hostname = "postgres"
port = "5432"
username = "postgres"
password = "secretpassword"
database = "testdb"

KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
KAFKA_TOPIC = os.getenv("KAFKA_TOPIC", "testdb_cdc.public.member")


# Initialize Hugging Face zero-shot classifier (replace with your fine-tuned model if available)
classifier = pipeline("zero-shot-classification", model="typeform/distilbert-base-uncased-mnli")


departments = ["Engineering", "Sales", "Marketing", "Human Resources", "Finance", "Operations"]
functions = ["Software Development", "Customer Support", "Product Management", "Recruitment", "Accounting"]
seniorities = ["Intern", "Junior", "Mid-level", "Senior", "Lead", "Manager", "Director", "VP", "C-level"]

conf = {
    'bootstrap.servers': "kafka:9092",
    'group.id': 'job-title-standardizer-test',
    'auto.offset.reset': 'earliest'
}

consumer = Consumer(conf)
consumer.subscribe([KAFKA_TOPIC])

# Function to insert a record into the standardized_title table
def insert_standardized_title(record):
    try:
        # Establish the connection to the database
        connection = psycopg2.connect(
            host=hostname,
            port=port,
            user=username,
            password=password,
            database=database
        )
        cursor = connection.cursor()

        # Create the insert query using SQL placeholders
        insert_query = sql.SQL("""
            INSERT INTO standardized_title (job_title, job_department, job_function, job_seniority)
            VALUES (%s, %s, %s, %s);
        """)

        # Extract the values from the record dictionary
        values = (
            record["job_title"],
            record["job_department"],
            record["job_function"],
            record["job_seniority"]
        )

        # Execute the insert query
        cursor.execute(insert_query, values)
        
        # Commit the transaction
        connection.commit()

        # Print a success message
        print(f"Record inserted successfully: {record}")

    except Exception as e:
        print(f"Error inserting record: {e}")
    
    finally:
        # Close the cursor and the connection
        if cursor:
            cursor.close()
        if connection:
            connection.close()

def classify_title(title):
    dept = classifier(title, departments)['labels'][0]
    func = classifier(title, functions)['labels'][0]
    senior = classifier(title, seniorities)['labels'][0]
    return dept, func, senior


try:
    while True:
        msg = consumer.poll(5.0)
        if msg is None:
            continue
        if msg.error():
            print(f"Consumer error: {msg.error()}")
            continue

        try:
            raw_value = msg.value().decode('utf-8')
            print("Raw Kafka message:", raw_value)
            record = json.loads(raw_value)
        except Exception as e:
            print(f"Failed to decode/parse message: {e}")
            continue
        # Debezium message format: payload.after contains the new row data
        after = record.get('payload', {}).get('after')
        if after is None:
            continue  # skip deletes or tombstones

        job_title = after.get('title')
        print("Title from kafka:", job_title)
        if not job_title:
            continue

        department, function, seniority = classify_title(job_title)

        enriched_record = {
            "job_title": job_title,
            "job_department": department,
            "job_function": function,
            "job_seniority": seniority
        }

        print("Enriched record:", enriched_record)
        insert_standardized_title(enriched_record)

finally:
    consumer.close()