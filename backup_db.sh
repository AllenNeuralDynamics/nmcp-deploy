#!/usr/bin/env bash

# Dump the entire PostgreSQL instance (all databases plus roles) from the Compose `db` service to a gzipped SQL file.
#
# Usage: ./backup_db.sh <output>
#   <output> is either an existing directory, in which case a timestamped file name is generated in it, or a file path.
#
# Restore (stop the application services first so nothing holds a connection to nmcp_production):
#   ./stop.sh api client export precomputed-worker quality-api
#   gunzip -c <backup>.sql.gz | docker compose -f docker-compose.yml -p <project> exec -T db psql -U postgres -d postgres
#   ./up.sh
# Two errors about the postgres role ("current user cannot be dropped", "already exists") are expected and harmless.

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <output directory or file>" >&2
    exit 1
fi

# Resolve the output location against the caller's working directory before changing to the script directory.
output="$1"
if [ -d "${output}" ]; then
    output_dir="$(cd "${output}" && pwd)"
    output_file=""
else
    output_dir="$(cd "$(dirname "${output}")" 2>/dev/null && pwd)" || {
        echo "Output directory $(dirname "${output}") does not exist" >&2
        exit 1
    }
    output_file="$(basename "${output}")"
fi

cd "$(dirname "$0")"

if [ -a ".env" ]; then
    source ".env"
fi

if [ -z "${NMCP_DATABASE_PW:-}" ]; then
    echo "NMCP_DATABASE_PW is not set" >&2
    exit 1
fi

if [ -z "${NMCP_COMPOSE_PROJECT:-}" ]; then
    export NMCP_COMPOSE_PROJECT="nmcp"
fi

if [ -z "${output_file}" ]; then
    output_file="${NMCP_COMPOSE_PROJECT}-db-$(date +%Y%m%d-%H%M%S).sql.gz"
fi

destination="${output_dir}/${output_file}"
partial="${destination}.partial"

if [ -e "${destination}" ]; then
    echo "${destination} already exists" >&2
    exit 1
fi

compose=(docker compose -f docker-compose.yml -p "${NMCP_COMPOSE_PROJECT}")

if [ -z "$("${compose[@]}" ps -q --status running db)" ]; then
    echo "The db service is not running in Compose project ${NMCP_COMPOSE_PROJECT}" >&2
    exit 1
fi

trap 'rm -f "${partial}"' EXIT

echo "Dumping database instance from project ${NMCP_COMPOSE_PROJECT} to ${destination}"

# pg_dumpall runs inside the container so its version always matches the server's. PGPASSWORD is passed by name only
# so its value is inherited from this environment rather than appearing on the docker command line.
export PGPASSWORD="${NMCP_DATABASE_PW}"
"${compose[@]}" exec -T -e PGPASSWORD db \
    pg_dumpall -h localhost -U postgres --clean --if-exists \
    | gzip -9 > "${partial}"

gzip -t "${partial}"
mv "${partial}" "${destination}"
trap - EXIT

echo "Backup complete: ${destination} ($(du -h "${destination}" | cut -f1))"
