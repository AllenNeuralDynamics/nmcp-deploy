#!/usr/bin/env bash

# Wrapper to follow logs that are part of default production project with the required env var properties.

if [ -a "options.sh" ]; then
    source "options.sh"
fi

if [ -z "NMCP_COMPOSE_PROJECT" ]; then
    export NMCP_COMPOSE_PROJECT="nmcp"
fi

docker compose -p ${NMCP_COMPOSE_PROJECT} logs --follow
