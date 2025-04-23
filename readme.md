# Job Standardization Pipeline

## Overview

The Job Standardization Pipeline is designed to classify and standardize job titles from member data stored in a PostgreSQL database. Each member's job title is categorized into three key dimensions: **Department**, **Function**, and **Seniority**. This pipeline supports two main classification strategies:

- **Backfill Strategy:** Batch processing of existing data.
- **Online Strategy:** Real-time classification of new records.

Both strategies leverage a machine learning model powered by Hugging Face for accurate and scalable job title classification.

---

## Architecture

### Data Source

- **PostgreSQL Database:** Contains member data, including job titles.

### Classification Dimensions

- **Department**
- **Function**
- **Seniority**

---

## Strategies

### 1. Backfill Strategy

- **Purpose:** Classify all existing job titles in the database.
- **Implementation:**
  - An Airflow DAG is scheduled and triggered via the Airflow webserver.
  - The DAG queries all member titles from the PostgreSQL database.
  - Titles are classified into Department, Function, and Seniority using a Hugging Face ML model.
  - Classification results are stored back in the database to be used later for members search and filtering.

### 2. Online Strategy

- **Purpose:** Real-time classification of new or updated job titles.
- **Implementation:**
  - **Change Data Capture (CDC):** Debezium monitors inserts or updates in the PostgreSQL database.
  - **Event Streaming:** Debezium publishes change events to Kafka topics.
  - **Kafka Consumer:** Listens to relevant Kafka topics for new member records.
  - **Trigger DAG:** Upon receiving a new record event, the Kafka consumer triggers an Airflow DAG run.
  - **Classification:** The DAG classifies the new job title using the Hugging Face ML model.
  - **Result Storage:** Classification output is saved back to the database to be used later for members search and filtering.

---

## Search Service

The Search Service provides APIs to interact with the member data, enabling insertion of new member records and retrieval of members with filtering capabilities based on classification dimensions.

### APIs

#### 1. Insert New Member Record

- **Endpoint:** `POST api/v1/members`
- **Description:** Inserts a new member record into the system.
- **Request Body:** JSON object containing member details wich are name, first_name, last_name and title.
- **Behavior:** Upon insertion, the record will be processed by the online strategy pipeline to classify its title into Department, Function, and Seniority.
- **Example CURL:** 
```
curl -X POST http://localhost:3000/api/v1/member \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"John Doe\", \"first_name\": \"John\", \"last_name\": \"Doe\", \"title\": \"Software Engineer\"}"
```


#### 2. Get Members with Filters

- **Endpoint:** `GET /members`
- **Description:** Retrieves a list of members filtered by classification dimensions.
- **Query Parameters (optional):**
  - `department` — Filter members by Department.
  - `function` — Filter members by Function.
  - `seniority` — Filter members by Seniority.
  - `page` — Page number.
  - `per_page` — Amount of records per single page.
- **Response:** JSON array of member records matching the specified filters.
- **Note:** Parameters must follow this structure
  - `filters[department]`
  - `filters[function]`
  - `filters[seniority]`
  - `paging[page]`
  - `paging[per_page]`
- **Example CURL:** 
```
curl "http://localhost:3000/api/v1/members?filters[department]=software%20development&\
filters[function]=Engineering&\
filters[seniority]=vp&\
paging[page]=1&\
paging[per_page]=10"
```
## Technologies Used

| Component             | Technology/Tool          |
|-----------------------|-------------------------|
| Database              | PostgreSQL              |
| Workflow Orchestration| Apache Airflow           |
| Machine Learning      | Hugging Face Transformers|
| Change Data Capture   | Debezium                |
| Messaging             | Apache Kafka            |
| Search service        | Exress                  |

---

## Getting Started Locally

Follow these steps to set up and run the Job Standardization Pipeline project locally.

### 1. Install Dependencies and Download ML Model
```sh
cd airflow
pip install -r requirements.txt
python download_model.py
```

This step installs all necessary Python dependencies for Airflow and downloads the Hugging Face ML model required for job title classification.

### 2. Configure Environment Variables

Create a `.env` file in the root directory of the project. Use the `.env.example` file as a reference to define all required environment variables with appropriate values.


### 3. Build and Run the Project with Docker Compose

From the root directory, run the following command to build and start all services (Airflow, Kafka, Postgres, Debezium, etc.):

```sh
docker compose up --build
```
### 4. Create a Postgres Connection in Airflow UI

Once all services are running, follow these steps to create a new Postgres connection in Airflow with the connection ID `testdb`:

1. Open your browser and navigate to the Airflow web UI (usually at [http://localhost:8080](http://localhost:8080)).
2. In the top navigation bar, click on **Admin**.
3. From the dropdown, select **Connections**.
4. Click the **+ (plus)** button to add a new connection.
5. In the **Connection Type** dropdown, select **Postgres**.
6. Fill in the connection details:
    - **Connection Id:** must be `testdb`
    - **Host:** (your Postgres host, e.g., `postgres`)
    - **Schema:** (your database name, e.g., `maindb`)
    - **Login:** (your Postgres username, e.g., `postgres`)
    - **Password:** (your Postgres password)
    - **Port:** (your Postgres port, usually `5432`)
7. (Optional) Click the **Test Connection** button to verify the settings.
8. Click **Save** to create the connection.

---

This command will build the Docker images and start the entire pipeline stack, including the orchestration, messaging, database, and classification components.

---

Once all services are running, you can access the Airflow webserver UI, monitor DAGs, and start using the pipeline for job title classification and member search.


---

## Usage

- **Backfill:** Trigger the backfill DAG via Airflow UI to classify all existing titles.
- **Online:** Insert or update member records in PostgreSQL to automatically trigger classification through Kafka events.

---

## Monitoring & Maintenance

- Use Airflow UI to monitor DAG runs and logs.
- Monitor Kafka consumer lag and Debezium connector status.
- Periodically retrain or update the ML model as needed for accuracy improvements.

---

