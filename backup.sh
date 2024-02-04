#!/usr/bin/env bash

if [[ -a "options.sh" ]]; then
    source "options.sh"
fi

haveLocal=(test -d "${NMCP_LOCAL_BACKUP_LOCATION}")

if [[ haveLocal ]]; then
    echo "attempting backup to ${NMCP_LOCAL_BACKUP_LOCATION}"
    docker run -it --rm --network ${NMCP_COMPOSE_PROJECT}_back_tier -e NODE_ENV=production -e DATABASE_PW=${DATABASE_PW} -v "${NMCP_LOCAL_BACKUP_LOCATION}":/opt/data/ mouselightdatabrowser/data-services:1.4 ./backup.sh
else
    echo "local backup location ${NMCP_LOCAL_BACKUP_LOCATION} is not accessible - skipping"
fi

haveRemote=(test -d "${NMCP_REMOTE_BACKUP_LOCATION}")

if [[ haveRemote ]]; then
    echo "attempting backup to ${NMCP_REMOTE_BACKUP_LOCATION}"
    docker run -it --rm --network ${NMCP_COMPOSE_PROJECT}_back_tier -e NODE_ENV=production -e DATABASE_PW=${DATABASE_PW} -e BACKUP_PATH=${NMCP_REMOTE_BACKUP_PATH} -v "${NMCP_REMOTE_BACKUP_LOCATION}":/opt/data mouselightdatabrowser/data-services:1.4 ./backup.sh
else
    echo "remote backup location ${NMCP_REMOTE_BACKUP_LOCATION} is not accessible - skipping"
fi
