
-- nie wiem czy tak to wlasnie mialo dzialac, ale zrobilem ta funkcje po to zeby zobaczyc czy to dziala wgl

CREATE OR REPLACE FUNCTION show_salary(emp_id INT)
RETURNS NUMERIC AS $$
DECLARE
    total_pay NUMERIC := 0;
BEGIN

    SELECT SUM(hours_worked * hourly_rate) 
    INTO total_pay
    FROM work_hours
    WHERE employee_id = emp_id;

    SELECT COALESCE(SUM(bonus_value),0)
    INTO total_pay
    FROM bonus_points
    WHERE employee_id = emp_id;

    RETURN total_pay;
END;
$$ LANGUAGE plpgsql;