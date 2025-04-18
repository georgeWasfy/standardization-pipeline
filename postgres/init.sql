-- Enable logical replication and create publication
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    job_title VARCHAR(255),
    updated_at TIMESTAMP DEFAULT now()
);

-- Insert sample data
INSERT INTO employees (job_title) VALUES
('Software Engineer'),
('Marketing Manager'),
('Senior Sales Associate');

-- Create publication for Debezium
CREATE PUBLICATION employee_publication FOR TABLE employees;