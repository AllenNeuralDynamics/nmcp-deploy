#!/usr/bin/env bash

if [[ -a "options.sh" ]]; then
    source "options.sh"
fi

haveRemote=(test -d "${NMCP_RESTORE_LOCATION}")

if [[ haveRemote ]]; then
    echo "attempting restore from ${NMCP_RESTORE_LOCATION}"
    docker run -it --rm --network ${NMCP_COMPOSE_PROJECT}_back_tier -e NODE_ENV=production -e DATABASE_PW=${DATABASE_PW} -e RESTORE_PATH=${NMCP_RESTORE_PATH} -v "${NMCP_RESTORE_LOCATION}":/opt/data mouselightdatabrowser/data-services:1.4 ./restore.sh
else
    echo "local restore location ${NMCP_RESTORE_LOCATION} is not accessible - skipping"
fi
