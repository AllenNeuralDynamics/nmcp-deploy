#!/usr/bin/env bash

if [[ -a "options.sh" ]]; then
    source "options.sh"
fi

haveLocal=(test -d "${MNB_LOCAL_BACKUP_LOCATION}")

if [[ haveLocal ]]; then
    echo "attempting backup to ${MNB_LOCAL_BACKUP_LOCATION}"
    docker run -it --rm --network ${NMCP_COMPOSE_PROJECT}_back_tier -e NODE_ENV=production -e DATABASE_PW=${DATABASE_PW} -v "${MNB_LOCAL_BACKUP_LOCATION}":/opt/data/ mouselightdatabrowser/data-services:1.4 ./backup.sh
else
    echo "local backup location ${MNB_LOCAL_BACKUP_LOCATION} is not accessible - skipping"
fi

haveRemote=(test -d "${MNB_REMOTE_BACKUP_LOCATION}")

if [[ haveRemote ]]; then
    echo "attempting backup to ${MNB_REMOTE_BACKUP_LOCATION}"
    docker run -it --rm --network ${NMCP_COMPOSE_PROJECT}_back_tier -e NODE_ENV=production -e DATABASE_PW=${DATABASE_PW} -e BACKUP_PATH=${MNB_REMOTE_BACKUP_PATH} -v "${MNB_REMOTE_BACKUP_LOCATION}":/opt/data mouselightdatabrowser/data-services:1.4 ./backup.sh
else
    echo "remote backup location ${MNB_REMOTE_BACKUP_LOCATION} is not accessible - skipping"
fi
