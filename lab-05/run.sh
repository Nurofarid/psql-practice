#!/bin/bash
# Lab 05: runs every step and saves the result to output.txt
cd "$(dirname "$0")" || exit 1
for db in university student_records studentdb '"StudentDB"'; do
  psql -X -q -d postgres -c "DROP DATABASE IF EXISTS $db" >/dev/null 2>&1
done
{
  echo '$ psql -d postgres -a -f lab05_databases.sql'
  PAGER=cat psql -X -a -d postgres -f lab05_databases.sql
  echo
  echo '$ psql -d postgres -c "CREATE DATABASE university;"'
  psql -X -d postgres -c "CREATE DATABASE university;"
  echo '$ psql -d university -c "SELECT current_database();"     # connect directly from the terminal'
  psql -X -d university -c "SELECT current_database();"
} > output.txt 2>&1
echo "Done: lab-05/output.txt"
