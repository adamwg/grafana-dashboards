#!/bin/bash

set -euo pipefail

GRAFANA="${1}"

function get_folder_id() {
    fname="\"${1}\""
    existing=$(curl -sf -X GET \
                    -H "Authorization: Bearer ${TOKEN}" \
                    -H 'Content-type: application/json' \
                    -H 'Accept: application/json' \
                    "${GRAFANA}/api/folders" | \
                   jq ".[] | select(.title == ${fname}) | .id")
    if [[ -n "${existing}" ]]; then
        echo "${existing}"
        return 0
    fi

    new=$(curl -sf -X POST \
               -H "Authorization: Bearer ${TOKEN}" \
               -H 'Content-type: application/json' \
               -H 'Accept: application/json' \
               "${GRAFANA}/api/folders" \
               --data-binary "{ \"title\": ${fname} }" | \
              jq '.id')
    echo "${new}"
    return 0
}

bad=0
for f in dashboards/**/*.jsonnet ; do
    folder=$(dirname "$f" | sed 's/^dashboards\///')
    folder_id=$(get_folder_id "${folder}")
    dbname=$(basename "$f" | sed 's/\.jsonnet$//')

    echo "Updating dashboard ${folder}/${dbname}"

    if ! jsonnet -J /grafonnet-lib -J . "${f}" | \
            jq "{ \"dashboard\": ., \"folderId\": ${folder_id}, \"overwrite\": true }" > \
               "/tmp/${dbname}.json" ; then

        echo "Failed to build ${folder}/${dbname}"
        bad=$((bad+1))
        continue
    fi

    if ! curl -sf -X POST \
         -H "Authorization: Bearer ${TOKEN}" \
         -H 'Content-type: application/json' \
         -H 'Accept: application/json' \
         "${GRAFANA}/api/dashboards/db" \
         --data-binary "@/tmp/${dbname}.json" ; then

         echo "Failed to update ${folder}/${dbname}"
         bad=$((bad+1))
    fi
done

exit ${bad}
