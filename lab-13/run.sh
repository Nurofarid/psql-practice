#!/bin/bash
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS agg_practice" >/dev/null 2>&1
psql -X -q -d postgres -c "CREATE DATABASE agg_practice"
{
  echo '$ psql -d agg_practice -a -f lab13_aggregate_functions.sql'
  PAGER=cat psql -X -a -d agg_practice -f lab13_aggregate_functions.sql
} > output.txt 2>&1
echo "Done: lab-13/output.txt"
