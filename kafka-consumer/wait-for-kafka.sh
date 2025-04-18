#!/bin/bash

echo "Waiting for Kafka to be ready..."

python - <<EOF
import time
from confluent_kafka.admin import AdminClient, KafkaException

bootstrap_servers = "kafka:9092"

for _ in range(30):  # Try for up to 30 seconds
    try:
        client = AdminClient({'bootstrap.servers': bootstrap_servers})
        # This will raise an exception if it fails
        metadata = client.list_topics(timeout=5)
        print("Kafka is ready!")
        exit(0)
    except KafkaException as e:
        print(f"Kafka not ready yet: {e}")
        time.sleep(1)

print("Kafka failed to become ready in time.")
exit(1)
EOF

exec "$@"
