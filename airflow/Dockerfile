FROM apache/airflow:2.8.1-python3.10

# Copy the requirements file
COPY requirements.txt /requirements.txt

# Install dependencies and clean up
RUN --mount=type=cache,target=/root/.cache/pip pip install -r /requirements.txt

