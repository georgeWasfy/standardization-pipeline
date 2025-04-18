#!/bin/bash
# Wait for Kafka Connect to be ready
until curl -s http://connect:8083/; do
  echo "Waiting for Kafka Connect..."
  sleep 5
done

# Register the connector
curl -X POST -H "Content-Type: application/json" \
  --data @/config/register-postgres.json \
  http://connect:8083/connectors
