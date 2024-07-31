#!/usr/bin/env bash

# Wrapper to stop and remove containers that are part of default production project with the required env var properties.  The volume with database storage is
# not removed.

# Allowed location of NMCP_COMPOSE_PROJECT variable.
if [ -a "options.sh" ]; then
    source "options.sh"
fi

if [ -z "${NMCP_COMPOSE_PROJECT}" ]; then
    export NMCP_COMPOSE_PROJECT="nmcp"
fi

docker compose -p ${NMCP_COMPOSE_PROJECT} down
