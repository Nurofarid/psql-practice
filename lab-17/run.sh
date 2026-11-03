#!/bin/bash
# Lab 17: COPY, pg_dump / pg_restore, backups, WAL and migration.
cd "$(dirname "$0")" || exit 1
rm -rf files backups; mkdir -p files backups
for db in shop_db shop_restored shop_tables test_restore; do
  dropdb --if-exists "$db" 2>/dev/null
done
createdb shop_db

step() { echo "\$ $*"; eval "$@"; echo; }   # print a command, then run it

{
echo '$ psql -d shop_db -a -f lab17_copy.sql'
PAGER=cat psql -X -a -d shop_db -f lab17_copy.sql
echo

echo '-- 6. pg_dump: plain SQL, custom format, single tables, schema/data only'
step 'pg_dump -h localhost -U $USER -d shop_db > backups/backup.sql'
step 'pg_dump -h localhost -U $USER -d shop_db -Fc > backups/backup.dump'
step 'pg_dump -h localhost -U $USER -d shop_db -t employees -t products > backups/tables_backup.sql'
step 'pg_dump -h localhost -U $USER -d shop_db -s > backups/schema_only.sql'
step 'pg_dump -h localhost -U $USER -d shop_db -a > backups/data_only.sql'
step 'pg_dump -h localhost -U $USER -d shop_db -T log_table > backups/backup_without_logs.sql'
step 'wc -c backups/*'
step 'grep -c "CREATE TABLE" backups/backup.sql backups/schema_only.sql backups/data_only.sql backups/tables_backup.sql backups/backup_without_logs.sql'
step 'grep -A3 "COPY public.products " backups/backup.sql'

echo '-- 7. pg_restore: check the backup, restore everything, restore one table'
step 'pg_restore --list backups/backup.dump | grep "TABLE DATA"'
step 'createdb shop_restored'
step 'pg_restore -h localhost -U $USER -d shop_restored -j 2 backups/backup.dump'
step 'psql -X -d shop_restored -c "SELECT count(*) AS employees FROM employees" -c "SELECT count(*) AS products FROM products"'
step 'createdb shop_tables'
step 'pg_restore -d shop_tables -t products backups/backup.dump'
step 'psql -X -d shop_tables -c "\dt"'

echo '-- 8. Full backups: whole cluster (roles only here) and a verbose full dump'
step 'pg_dumpall -h localhost -U $USER --globals-only > backups/globals.sql && grep -c "ROLE" backups/globals.sql'
step 'pg_dump -h localhost -U $USER -d shop_db -Fc --verbose -O > backups/full_backup.dump 2> backups/verbose.log; tail -3 backups/verbose.log'

echo '-- 9. Automated backup script and validation'
step 'cat backup_script.sh'
step 'bash backup_script.sh'
step 'ls backups | grep shop_db_'
step 'createdb test_restore && pg_restore -d test_restore backups/full_backup.dump && psql -X -d test_restore -Atc "SELECT '"'"'restored tables: '"'"' || count(*) FROM pg_tables WHERE schemaname = '"'"'public'"'"'"'

echo '$ psql -d shop_db -a -f lab17_wal_migration.sql'
PAGER=cat psql -X -a -d shop_db -f lab17_wal_migration.sql
echo
echo '-- 14. Migration best practice: copy one table straight into another database with a pipe'
step 'pg_dump -d shop_db -t target_customers | psql -X -q -d test_restore > /dev/null'
step 'psql -X -d test_restore -c "SELECT count(*) AS migrated_rows FROM target_customers"'
} > output.txt 2>&1

echo "Done: lab-17/output.txt"
