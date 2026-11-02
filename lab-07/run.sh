#!/bin/bash
# Lab 07: creates a fresh pk_practice database, runs the lab and saves the result to output.txt
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS pk_practice" >/dev/null 2>&1
psql -X -q -d postgres -c "CREATE DATABASE pk_practice"
{
  echo '$ psql -d pk_practice -a -f lab07_primary_keys.sql'
  PAGER=cat psql -X -a -d pk_practice -f lab07_primary_keys.sql
} > output.txt 2>&1
echo "Done: lab-07/output.txt"
