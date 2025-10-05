
-- nie wiem czy tak to wlasnie mialo dzialac, ale jak mozesz to dodaj jakies nowe funkcje bo nie wiem co mam dalej robic

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

    IF emp_status IS NULL OR LOWER(emp_status) <> 'aktywny' THEN
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
