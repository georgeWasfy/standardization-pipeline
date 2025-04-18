FROM python:3.10-slim

WORKDIR /app

# Only copy requirements to leverage cache
COPY requirements.txt .
# Install dependencies and clean up
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt
# Copy application code last
COPY consumer.py .
COPY wait-for-kafka.sh /wait-for-kafka.sh

RUN chmod +x /wait-for-kafka.sh

# CMD ["python", "consumer.py"]
ENTRYPOINT ["/wait-for-kafka.sh", "python", "consumer.py"]
