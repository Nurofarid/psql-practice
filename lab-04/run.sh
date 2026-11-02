#!/bin/bash
# Lab 04: creates the database, runs every query and saves the result to output.txt
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS lab04_sql" >/dev/null 2>&1
psql -X -q -d postgres -c "CREATE DATABASE lab04_sql"
{
  echo '$ psql -d lab04_sql -a -f lab04_first_sql_query.sql'
  PAGER=cat psql -X -a -d lab04_sql -f lab04_first_sql_query.sql
} > output.txt 2>&1
echo "Done: lab-04/output.txt"
