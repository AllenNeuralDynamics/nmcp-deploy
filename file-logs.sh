#!/usr/bin/env bash

source ./.env
source ./options.sh

docker run -it --rm --network ${NMCP_COMPOSE_PROJECT}_back_tier -v ${NMCP_COMPOSE_PROJECT}_log_output:/var/log/nmcp busybox
