#!/bin/bash

set -euo pipefail

# Get the base branch for the PR, so we can determine which files are changed.
base_branch=$(jq -r '.pull_request.base.ref' "${GITHUB_EVENT_PATH}")

# Determine which dashboards are affected by this change.
files=($(git log --format='' --name-status "origin/${base_branch}".. -- '**/*.jsonnet' | awk '/^[^D]/ {print $2}'))
libfiles=($(git log --format='' --name-status "origin/${base_branch}".. -- '**/*.libsonnet' | awk '{print $2}'))
dependencyFiles=()
for l in "${libfiles[@]}"; do
    dependencies=($(grep -R --include='*.jsonnet' -l -F "import '${l}'" . || true))
    dependencyFiles+=("${dependencies[@]}")
done
for d in "${dependencyFiles[@]}"; do
    found='false'
    for f in "${files[@]}"; do
        if [[ "${d}" == "./${f}" ]]; then
            found='true'
            break
        fi
    done

    if [[ "${found}" == 'false' ]]; then
        dd=$(echo "${d}" | sed -e 's/^..//')
        files+=("${dd}")
    fi
done

function generate_previews() {
    export GRAFANA="${1}"
    export NO_DOCKER='true'
    export EXPIRY='259200' # 3 days
    for f in "${files[@]}"; do
        folder=$(dirname "$f" | sed 's/^dashboards\///')
        dbname=$(basename "$f" | sed 's/\.jsonnet$//')

        url=$(scripts/preview.sh "${f}")
        echo "${folder}/${dbname}::${url}"
    done
}

urls=''
links=''
for preview in $(generate_previews "${1}"); do
    dbname=$(echo "${preview}" | awk -F:: '{print $1}')
    url=$(echo "${preview}" | awk -F:: '{print $2}')
    urls="${url},${urls}"
    links="[Preview for dashboard ${dbname}](${url})<br>${links}"
done

echo "::set-output name=links::${links}"
echo "::set-output name=urls::${urls}"
