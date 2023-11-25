#!/usr/bin/env bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE samples_production;
    GRANT ALL PRIVILEGES ON DATABASE samples_production TO "$POSTGRES_USER";
EOSQL
