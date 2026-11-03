#!/bin/bash
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS design_practice" >/dev/null 2>&1
psql -X -q -d postgres -c "CREATE DATABASE design_practice"
{
  echo '$ psql -d design_practice -a -f lab09_database_design.sql'
  PAGER=cat psql -X -a -d design_practice -f lab09_database_design.sql
} > output.txt 2>&1
echo "Done: lab-09/output.txt"
