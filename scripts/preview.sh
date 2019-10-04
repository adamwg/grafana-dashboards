#!/bin/bash

set -euo pipefail
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function make_preview() {
    # Read local configuration from config.env in the repository root. It's handy to
    # set GRAFANA and TOKEN here so you don't have to provide them on every
    # invocation.
    source "${SCRIPTDIR}/../config.env"
    # EXPIRY is how many seconds a preview will be available for. Default it to 5
    # minutes; this can be overridden in config.env.
    : "${EXPIRY:=300}"

    # Make sure we have the necessary parameters. DASHBOARD can be provided as an
    # envvar or an argument to the script.
    : "${DASHBOARD:=${1:-}}"
    if [[ -z "${DASHBOARD}" ]]; then
        echo 'Must provide DASHBOARD'
        exit 1
    fi
    if [[ -z "${GRAFANA:-}" ]]; then
        echo 'Must provide GRAFANA'
        exit 1
    fi

    # Use token authentication if we have a token.
    CURL=(curl)
    if [[ ! -z "${TOKEN:-}" ]]; then
        CURL+=(-H "Authorization: Bearer ${TOKEN}")
    fi

    # Generate the snapshot JSON in to a temporary file.
    json=$(mktemp)
    jsonnet -J /grafonnet-lib -J . "${DASHBOARD}" | \
        jq "{ \"dashboard\": ., \"expires\": ${EXPIRY} }" > "${json}"

    # Create the snapshot and fix up the URL we get back - when running grafana
    # under Kubernetes it thinks its URL is localhost:3000.
    url=$("${CURL[@]}" -s -X POST -H 'Content-type: application/json' -H 'Accept: application/json' \
                       "${GRAFANA}/api/snapshots" --data-binary "@${json}" | \
              jq -r ".url | sub(\"http://localhost:3000\"; \"${GRAFANA}\")")

    echo "${url}"
}

# Set NO_DOCKER to run directly on the host - otherwise we'll run under docker.
: "${NO_DOCKER:=}"
# Set OPEN_CMD to specify what command to use to open the preview - otherwise
# we'll guess.
: "${OPEN_CMD:=}"

if [[ ! -z "${OPEN_CMD}" ]]; then
    # Use caller-provided OPEN_CMD.
    true
elif command -v open &> /dev/null; then
    OPEN_CMD='open'
elif command -v xdg-open &> /dev/null; then
    OPEN_CMD='xdg-open'
else
    OPEN_CMD='echo'
fi

url=""
if [[ "${NO_DOCKER}" ]]; then
    url=$(make_preview "${@}")
else
    url=$(docker run -it --rm \
                 -v "${SCRIPTDIR}/..:/dashboards" \
                 -w /dashboards \
                 -e NO_DOCKER=true \
                 grafonnet:latest \
                 scripts/preview.sh "${@}")
fi

"${OPEN_CMD}" "${url}"
