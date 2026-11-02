#!/bin/bash
# Lab 06: runs every step in the "university" database and saves the result to output.txt
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "CREATE DATABASE university" >/dev/null 2>&1   # in case it does not exist yet
psql -X -q -d university -c "DROP TABLE IF EXISTS enrollments, university_students, students CASCADE" >/dev/null 2>&1
{
  echo '$ psql -d university -a -f lab06_tables.sql'
  PAGER=cat psql -X -a -d university -f lab06_tables.sql
} > output.txt 2>&1
echo "Done: lab-06/output.txt"
