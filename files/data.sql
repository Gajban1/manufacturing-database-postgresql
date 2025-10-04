INSERT INTO employees (name, department, position, hire_date)
VALUES
('Jan Kowalski', 'Produkcja', 'Operator', '2022-03-01'),
('Anna Nowak', 'Logistyka', 'Magazynier', '2023-01-15'),
('Piotr Wiśniewski', 'Administracja', 'Księgowy', '2021-07-10');


INSERT INTO work_hours (employee_id, work_date, hours_worked, hourly_rate)
VALUES
(1, '2025-09-01', 8, 25.00),
(1, '2025-09-02', 7.5, 25.00),
(2, '2025-09-01', 8, 22.00),
(3, '2025-09-01', 6, 30.00);


INSERT INTO bonus_points (employee_id, bonus_type, bonus_value, description)
VALUES
(1, 'Premia miesięczna', 200.00, 'Premia za nadgodziny'),
(2, 'Premia wydajnościowa', 150.00, 'Premia za efektywność'),
(3, 'Premia świąteczna', 300.00, 'Premia grudniowa');


INSERT INTO employee_register (employee_id, status)
VALUES
(1, 'aktywny'),
(2, 'aktywny'),
(3, 'aktywny');
