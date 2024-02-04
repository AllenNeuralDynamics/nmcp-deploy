#!/usr/bin/env bash

if [ -a "options.sh" ]; then
    source "options.sh"
fi

if [ -z "NMCP_COMPOSE_PROJECT" ]; then
    export NMCP_COMPOSE_PROJECT="nmcp"
fi

docker compose -f docker-compose.yml -f docker-compose.services.yml -p ${NMCP_COMPOSE_PROJECT} up -d
