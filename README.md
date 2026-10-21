# Manufacturing Management Database — PostgreSQL

Academic team project modelling employee records, working hours, simplified payroll and production orders for a fictional manufacturing company inspired by Wielton.

**This is a university exercise, not a system commissioned, approved or deployed by Wielton S.A.** Sample records are academic/generated data.

## My contribution

**Piotr Straszak:** database triggers, test data population and testing of database behaviour.
**Paweł Lorenc:** database structure. This portfolio copy preserves the original Git history and credits the team; the entire application is not claimed as individual work.

Original repository: [pawelorenc/Bazy_Cyber](https://github.com/pawelorenc/Bazy_Cyber).

## Technical highlights

- PostgreSQL tables, foreign keys and integrity constraints.
- PL/pgSQL employee validation, including PESEL checksum and telephone format.
- Payroll history guard for records older than 30 days.
- Stored procedures, reporting functions, sample role grants and a PHP/PDO viewer.

## Local setup

Use a dedicated disposable database with PostgreSQL and `psql` installed. From the repository root:

```bash
createdb company_portfolio
psql -v ON_ERROR_STOP=1 -d company_portfolio -f files/schema.sql
psql -v ON_ERROR_STOP=1 -d company_portfolio -f files/functions.sql
psql -v ON_ERROR_STOP=1 -d company_portfolio -f tests/validation.sql
```

The schema script uses the database you select and no longer drops an existing `company` database. `massive_data.sql` and `generator.py` are original sample-data materials and are not required for this minimal validation run.

Optional PHP viewer (PHP with PDO PostgreSQL extension):

```bash
export DB_HOST=localhost
export DB_NAME=company_portfolio
export DB_USER=your_local_database_user
export DB_PASSWORD=''
php -S 127.0.0.1:8080 -t visual
```

## Limitations

This is an academic prototype, not a production ERP, payroll or compliance solution. Net pay and forecasting use simplified assumptions. The PHP viewer has no authentication and is intended for local demonstration. TLS, password policy, backups and firewall configuration are not implemented by the SQL files. `files/roles.sql` is a legacy example requiring review against the current schema (including sequence names) before use; it is not part of the setup above.

Original Polish documentation is retained under `docs/` for context and may contain historical or aspirational claims. The portfolio edition fixes the history guard to allow valid updates of recent rows, and replaces machine-specific connection settings with environment variables.

## Attribution and license

Original authors: Piotr Straszak and Paweł Lorenc. Original history and source links are preserved. The upstream repository does not include a license; this copy does not grant a new license over the team's work.
