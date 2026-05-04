#!/usr/bin/env bash

# Wrapper to start containers that are part of default production project with the required env var properties.

# Allowed location of NMCP_COMPOSE_PROJECT variable.
if [ -a ".env" ]; then
    source ".env"
fi

required_vars=("NMCP_DATABASE_PW" "NMCP_INFLUX_DB_PASSWORD" "NMCP_LOG_VOLUME")

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "${var} is not set" >&2
        exit 1
    fi
done

if [ -z "${NMCP_COMPOSE_PROJECT}" ]; then
    export NMCP_COMPOSE_PROJECT="nmcp"
fi

if [ -z "${NMCP_SERVICES_FILE}" ]; then
    export NMCP_SERVICES_FILE="docker-compose.services.yml"
fi

echo Using services defined in ${NMCP_SERVICES_FILE}

docker compose -f docker-compose.yml -f ${NMCP_SERVICES_FILE} -p ${NMCP_COMPOSE_PROJECT} up -d "$@"
