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


--NIE WIEM CZY CHCEMY ZROBIC OSOBY PLIK Z FUNKCJAMI CZY NIE ALE NARAZIE DALEM TO W OBU PLIKACH

CREATE OR REPLACE FUNCTION show_salary(emp_id INT)
RETURNS NUMERIC AS $$
DECLARE
    total_pay NUMERIC := 0;
    bonus_total NUMERIC := 0;
    emp_status VARCHAR(30);
BEGIN
    SELECT status 
    INTO emp_status
    FROM employee_register
    WHERE employee_id = emp_id
    ORDER BY register_date DESC
    LIMIT 1;

    IF emp_status IS NULL OR emp_status <> 'aktywny' THEN
        RAISE NOTICE 'Pracownik % nie jest aktywny lub nie istnieje.', emp_id;
        RETURN 0;
    END IF;


    SELECT COALESCE(SUM(hours_worked * hourly_rate), 0)
    INTO total_pay
    FROM work_hours
    WHERE employee_id = emp_id;


    SELECT COALESCE(SUM(bonus_value), 0)
    INTO bonus_total
    FROM bonus_points
    WHERE employee_id = emp_id;

    RETURN total_pay + bonus_total;
END;
$$ LANGUAGE plpgsql;