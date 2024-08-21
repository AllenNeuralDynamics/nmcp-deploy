#!/usr/bin/env bash

# Environment variables that used both in the Docker Compose files and various scripts.  Env var that just used in the
# Docker Compose files are in the Compose specific .env file.

# Will override all database passwords (optional).
export NMCP_DATABASE_PW=

# Customize Compose project/container prefix.
export NMCP_COMPOSE_PROJECT=

# Will be mapped to /var/log/nmcp in most service containers for log files.  Could be a host location or a docker volume.
export NMCP_LOG_VOLUME=

export NMCP_SERVICES_FILE=
