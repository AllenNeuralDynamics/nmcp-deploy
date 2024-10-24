#!/usr/bin/env bash

# Wrapper to follow logs that are part of default production project with the required env var properties.

if [ -a "options.sh" ]; then
    source "options.sh"
fi

docker run -it --rm --volume ./datastore/data:/mnt/data --network=nmcp_back_tier --env NMCP_DATABASE_PW=${NMCP_DATABASE_PW} leapscientific/nmcp-api:2.0.19 /bin/bash
