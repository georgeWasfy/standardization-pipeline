#!/bin/bash

# Temporarily switch to root if possible
if [ "$(id -u)" -eq 0 ]; then
  apk add --no-cache gettext curl
else
  echo "Did not get curl and gettext envsubst"
  exit 1
fi

# Wait for Kafka Connect to be ready
until curl -s http://connect:8083/; do
  echo "Waiting for Kafka Connect..."
  sleep 5
done


# Create a temp config file by replacing env vars in the template
envsubst < /config/register-postgres.template.json > /config/register-postgres.json

# Register the connector
curl -X POST -H "Content-Type: application/json" --data @/config/register-postgres.json http://connect:8083/connectors
