import os
import json
from confluent_kafka import Consumer
# from transformers import pipeline

# KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
# KAFKA_TOPIC = os.getenv("KAFKA_TOPIC", "testdb_cdc.public.employees")

print("Starting Kafka consumer...")
# print("Starting Model Download...")

# Initialize Hugging Face zero-shot classifier (replace with your fine-tuned model if available)
# classifier = pipeline("zero-shot-classification", model="typeform/distilbert-base-uncased-mnli")

# print("Model is downloaded...")


departments = ["Engineering", "Sales", "Marketing", "Human Resources", "Finance", "Operations"]
functions = ["Software Development", "Customer Support", "Product Management", "Recruitment", "Accounting"]
seniorities = ["Intern", "Junior", "Mid-level", "Senior", "Lead", "Manager", "Director", "VP", "C-level"]

conf = {
    'bootstrap.servers': "kafka:9092",
    'group.id': 'job-title-standardizer-test',
    'auto.offset.reset': 'earliest'
}

consumer = Consumer(conf)
consumer.subscribe(["testdb_cdc.public.employees"])

# def classify_title(title):
#     dept = classifier(title, departments)['labels'][0]
#     func = classifier(title, functions)['labels'][0]
#     senior = classifier(title, seniorities)['labels'][0]
#     return dept, func, senior


try:
    while True:
        msg = consumer.poll(5.0)
        if msg is None:
            print("No message received.")
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
        print("Payload.after:", after)
        if after is None:
            continue  # skip deletes or tombstones

        job_title = after.get('job_title')
        print("Title from kafka:", job_title)
        # if not job_title:
        #     continue

        # department, function, seniority = classify_title(job_title)

        # enriched_record = {
        #     "id": after.get("id"),
        #     "job_title": job_title,
        #     "department": department,
        #     "function": function,
        #     "seniority": seniority
        # }

        # print("Enriched record:", enriched_record)
        # TODO: Save to DB or produce to another Kafka topic

finally:
    consumer.close()