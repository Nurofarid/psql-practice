#!/bin/bash
# Lab 08: creates a fresh fk_practice database, runs the lab and saves the result to output.txt
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS fk_practice" >/dev/null 2>&1
psql -X -q -d postgres -c "CREATE DATABASE fk_practice"
{
  echo '$ psql -d fk_practice -a -f lab08_foreign_keys.sql'
  PAGER=cat psql -X -a -d fk_practice -f lab08_foreign_keys.sql
} > output.txt 2>&1
echo "Done: lab-08/output.txt"
