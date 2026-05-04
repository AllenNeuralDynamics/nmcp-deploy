#!/usr/bin/env bash

# Start service(s) that are not typically under local development (e.g., databases), but are required to run and test services that may be under development.

if [ -a ".env" ]; then
    source ".env"
fi

required_vars=("NMCP_DATABASE_PW" "NMCP_INFLUX_DB_PASSWORD")

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "${var} is not set" >&2
        exit 1
    fi
done

if [ -z "NMCP_COMPOSE_PROJECT" ]; then
    export NMCP_COMPOSE_PROJECT="nmcp"
fi

docker compose -p ${NMCP_COMPOSE_PROJECT} up -d "$@"
