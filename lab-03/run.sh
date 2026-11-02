#!/bin/bash
# Lab 03: creates the database, runs every step and saves the result to output.txt
cd "$(dirname "$0")" || exit 1
psql -X -q -d postgres -c "DROP DATABASE IF EXISTS lab03_psql" >/dev/null 2>&1
psql -X -q -d postgres -c "CREATE DATABASE lab03_psql"
{
  echo '$ psql --version'
  psql --version
  echo
  echo '$ psql -h localhost -p 5432 -U '"$USER"' -d lab03_psql -c "SELECT current_user, current_database(), inet_server_port();"'
  psql -X -h localhost -p 5432 -U "$USER" -d lab03_psql -c "SELECT current_user, current_database(), inet_server_port();"
  echo '$ psql -d lab03_psql -a -f lab03_basic_psql.sql'
  PAGER=cat psql -X -a -d lab03_psql -f lab03_basic_psql.sql
} > output.txt 2>&1
echo "Done: lab-03/output.txt"
