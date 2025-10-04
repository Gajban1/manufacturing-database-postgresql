CREATE DATABASE company;

\c company

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    position VARCHAR(50),
    hire_date DATE
);



CREATE TABLE external_employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    company_name VARCHAR(100)
);



CREATE TABLE employee_register (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    register_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(30)

);



CREATE TABLE work_hours (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    work_date DATE,
    hours_worked NUMERIC(4,2),
    hourly_rate NUMERIC(6,2)
);


CREATE TABLE salary (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    payment_date DATE,
    total_pay NUMERIC(10,2)
);

CREATE TABLE bonus_points (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    bonus_type VARCHAR(50),
    bonus_value NUMERIC(8,2),
    date_awarded DATE DEFAULT CURRENT_DATE,
    description TEXT
);


CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    task_description TEXT,
    deadline DATE,
    status VARCHAR(20)
);


CREATE TABLE bhp_records (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    training_date DATE,
    valid_until DATE,
    comments TEXT
);



CREATE TABLE misconduct (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    incident_date DATE,
    description TEXT,
    action_taken VARCHAR(100)
);




