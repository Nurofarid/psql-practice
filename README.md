# PostgreSQL Practice — Databases Labs

**AUCA · Databases · Nurofarid Kukanbekova**

My lab work for the Databases course at the American University of Central Asia. Each lab has its own folder with:
- the SQL I wrote
- a script that runs it
- the real terminal output
- screenshots from my Terminal
- a README report that explains the results

## Environment

| | |
|-|-|
| Database | PostgreSQL 18 (Homebrew) |
| Client | `psql` in the macOS Terminal (zsh) |
| OS | macOS |
| Version control | git + GitHub |

## Labs

| Lab | Topic | What it covers | Screenshots | Expected errors |
|-----|-------|----------------|:-----------:|:---------------:|
| [03](lab-03/README.md) | Basic psql Commands | Connecting, `\l` `\c` `\dt` `\d` `\conninfo` `\h`, first SQL | 3 | 0 |
| [04](lab-04/README.md) | First SQL Query | `CREATE TABLE`, `INSERT`, `SELECT`, `WHERE`, `ORDER BY`, `LIMIT` | 3 | 0 |
| [05](lab-05/README.md) | Databases | Create / switch / drop databases, naming rules | 3 | 3 |
| [06](lab-06/README.md) | Tables, Data Types and Constraints | Data types, PK, NOT NULL, UNIQUE, CHECK, FK, DEFAULT, `ALTER TABLE`, temp tables | 4 | 6 |
| [07](lab-07/README.md) | Primary Keys | Column/table/named/composite keys, `SERIAL`, `IDENTITY`, the automatic index | 6 | 5 |
| [08](lab-08/README.md) | Foreign Keys and Relationships | 4 ways to create an FK, CASCADE / SET NULL / SET DEFAULT / RESTRICT, 1:1, 1:N, M:N | 9 | 7 |
| [09](lab-09/README.md) | Database Design Basics | ER modelling, 1NF / 2NF / 3NF (bad vs fixed), a library system | 10 | 2 |
| [10](lab-10/README.md) | Viewing Database and Table Structure | `\dt+` `\d+` `\di` `\ds`, `information_schema`, `pg_constraint`, ER diagram | 6 | 0 |
| [11](lab-11/README.md) | Basic Data Operations | `INSERT`, `UPDATE`, `DELETE`, bulk operations, `\copy` CSV import/export | 4 | 1 |
| [12](lab-12/README.md) | Querying Data | `WHERE`, `LIKE`/`ILIKE`, regex, `IN`/`EXISTS`, `CASE`, CTE | 8 | 1 |
| [13](lab-13/README.md) | Aggregate Functions | `COUNT` `SUM` `AVG` …, `STRING_AGG`, `GROUP BY`, `HAVING`, NULLs, window vs aggregate | 9 | 2 |
| [14](lab-14/README.md) | Joining Tables | INNER / LEFT / RIGHT / FULL / CROSS, self join, multi-table joins, pitfalls | 10 | 1 |
| [15](lab-15/README.md) | Advanced Querying | Subqueries, recursive CTE, set operations, `RANK`/`LAG`, pivot, `EXPLAIN` | 11 | 2 |
| [16](lab-16/README.md) | Transactions and ACID | `BEGIN`/`COMMIT`/`ROLLBACK`, savepoints, isolation levels with two live sessions | 12 | 5 |
| [17](lab-17/README.md) | Data Import/Export and Backup | `COPY`, CSV options, `pg_dump` / `pg_restore`, backup script, WAL, migration | 10 | 1 |

The lab numbers match the course handout numbers.

## Layout of every lab folder

```
lab-XX/
├── README.md        report: what was done, results, the expected errors, notes on the handout
├── labXX_*.sql      the SQL file, split into numbered sections (-- 1. … -- 2. …)
├── run.sh           recreates a fresh database and runs the SQL file
├── output.txt       the real output (psql -a echoes every command before its result)
└── screenshots/     Terminal screenshots, one for each section
```

Some labs have extra files: CSV input/output in Lab 11 and Lab 17, the two-session demo in Lab 16, and backups in Lab 17.

## Expected errors

Some commands are **meant to fail**: breaking a constraint, using a reserved word as a name, an aggregate in `WHERE`, and so on. They show that the database protects its data. In the SQL files they are marked with

```sql
-- EXPECTED ERROR: why this fails
```

Each lab README lists its expected errors in a table. Any other error would be a real problem.

## How to run

```bash
git clone https://github.com/Nurofarid/psql-practice.git
cd psql-practice
brew services start postgresql@18     # if the server is not running yet

bash lab-12/run.sh                    # run one lab; it writes lab-12/output.txt
bash run_all.sh                       # run every lab in order and check the error counts
```

- Every `run.sh` creates its own database from scratch, so a lab can be run again at any time.
- Lab 10 reads the database from Lab 09 (and builds it if it is missing).
- Lab 06 uses the `university` database created in Lab 05.

## Notes on the handouts

While doing the labs I tested every handout example. A few did not work as written; the details are in each lab's README:

- **Lab 16:** `LASTVAL()` attaches the order to the wrong customer, and `ROLLBACK` inside a `DO` block fails.
- **Lab 17:** `FORCE_QUOTE (col)` with the old CSV syntax is a syntax error. `recovery.signal` must be an empty file.
- **Lab 11:** server-side `COPY` with a relative path fails; `\copy` works.
- **Lab 14:** the example data has no unmatched rows, so I added some to make LEFT, RIGHT and FULL joins differ from INNER.

## Older practice files

`archive/` holds my first versions of the exercises from before I reorganised the repository into lab folders. They are kept for history; the lab folders are the current, complete versions.
