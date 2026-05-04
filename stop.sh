#!/usr/bin/env bash

# Wrapper to stop containers that are part of default production project with the required env var properties.

# Allowed location of NMCP_COMPOSE_PROJECT variable.
if [ -a ".env" ]; then
    source ".env"
fi

docker compose -p ${NMCP_COMPOSE_PROJECT} stop "$@"
