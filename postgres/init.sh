#!/bin/sh
# Runs once, on an empty data volume: one database and user for the app, one for the Rivet engine.
set -eu
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<SQL
CREATE USER app WITH PASSWORD '$APP_DB_PASSWORD';
CREATE DATABASE app OWNER app;
CREATE USER rivet WITH PASSWORD '$RIVET_DB_PASSWORD';
CREATE DATABASE rivet OWNER rivet;
SQL
