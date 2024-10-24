#!/usr/bin/env bash

# Wrapper to open a container to view file logs that are part of default production project with the required env var properties.

if [ -a ".env" ]; then
    source ".env"
fi

if [ -a "options.sh" ]; then
    source "options.sh"
fi

if [ -z "NMCP_COMPOSE_PROJECT" ]; then
    export NMCP_COMPOSE_PROJECT="nmcp"
fi

docker run -it --rm --network ${NMCP_COMPOSE_PROJECT}_back_tier -v ${NMCP_COMPOSE_PROJECT}_log_output:/var/log/nmcp busybox
