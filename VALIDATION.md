# Validation

Portfolio edition checked locally on PostgreSQL 18.

- Loaded `files/schema.sql` into an empty disposable database with `ON_ERROR_STOP=1`.
- Loaded `files/functions.sql` successfully.
- Passed transaction-based checks in `tests/validation.sql`: employee validation, valid recent payroll update, rejection of historical payroll update and deletion.
- Python source syntax parsed successfully.
- PHP runtime and viewer were not executed (PHP unavailable).
- Legacy role grants, sample data generator and all business procedures were not exhaustively tested. Roles are excluded from the minimal setup.

The original database was not modified. The validation database was temporary and its server was stopped after use.
