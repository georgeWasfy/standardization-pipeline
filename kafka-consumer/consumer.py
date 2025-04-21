import os
import json
from confluent_kafka import Consumer
import requests

hostname = "postgres"
port = "5432"
username = "postgres"
password = "secretpassword"
database = "testdb"

KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
KAFKA_TOPIC = os.getenv("KAFKA_TOPIC", "testdb_cdc.public.member")
AIRFLOW_DAG_TRIGGER_URL = os.getenv("AIRFLOW_DAG_TRIGGER_URL", "http://airflow-webserver:8080/api/v1/dags/job_standardization_online_strategy/trigger")

conf = {
    'bootstrap.servers': KAFKA_BOOTSTRAP_SERVERS,
    'group.id': 'job-title-standardizer-test',
    'auto.offset.reset': 'earliest'
}

consumer = Consumer(conf)
consumer.subscribe([KAFKA_TOPIC])

"""Trigger Airflow DAG with received Kafka message."""
def trigger_airflow_dag(data):
    payload = {
        "conf": data
    }
    response = requests.post(AIRFLOW_DAG_TRIGGER_URL, json=payload, auth=("airflow", "airflow"))
    if response.status_code == 200:
        print(f"DAG triggered successfully: {response.json()}")
    else:
        print(f"Failed to trigger DAG: {response.text}")

try:
    while True:
        msg = consumer.poll(5.0)
        if msg is None:
            continue
        if msg.error():
            print(f"Consumer error: {msg.error()}")
            continue

        record = json.loads(msg.value())
        after = record.get('payload', {}).get('after')
        if after is None:
            continue  # Skip deletes or tombstones

        job_title = after.get('title')
        if not job_title:
            continue

        print(f"Received job title: {job_title}")
        
        # Trigger Airflow DAG with the message payload
        trigger_airflow_dag(after)

finally:
    consumer.close()