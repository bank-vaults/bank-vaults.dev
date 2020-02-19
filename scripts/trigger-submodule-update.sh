#!/bin/bash

set -euf

PROJECT_SLUG='gh/banzaicloud/banzaicloud.github.io'

function main()
{
    curl \
        -u "${CIRCLE_TOKEN}:" \
        -X POST \
        --header "Content-Type: application/json" \
        -d "{
            \"branch\": \"gh-pages\",
            \"parameters\": {
                \"module\": \"bank-vaults\"
            }
        }" "https://circleci.com/api/v2/project/${PROJECT_SLUG}/pipeline"
}

main "$@"
