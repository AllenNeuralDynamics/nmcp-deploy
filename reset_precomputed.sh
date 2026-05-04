#!/bin/bash

. ./.env

set -e

if [ -z "${NMCP_PRECOMPUTED_OUTPUT}" ]; then
    echo "NMCP_PRECOMPUTED_OUTPUT is not set" >&2
    exit 1
fi

top_level=("axon" "dendrite" "full" "specimen")

recursive=("segment_properties" "skeleton")

non_recursive=("info")

for top in "${top_level[@]}"; do
    for sub in "${recursive[@]}"; do
        location="${NMCP_PRECOMPUTED_OUTPUT}/${top}/${sub}"
        echo "clearing location ${location} (recursive)"
        aws s3 rm "$location" --recursive
    done
    for sub in "${non_recursive[@]}"; do
        location="${NMCP_PRECOMPUTED_OUTPUT}/${top}/${sub}"
        echo "clearing location ${location} (non-recursive)"
        aws s3 rm "$location"
    done
done
