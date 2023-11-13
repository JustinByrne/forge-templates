#!/bin/bash
cd /home/forge/site_dir

BRANCH=$(git rev-parse --abbrev-ref HEAD)
REMOTE="origin/$BRANCH"
SERVER="server_id"
SITE="site_id"
TOKEN="bearer_token"

git fetch

if git merge-base --is-ancestor $REMOTE $BRANCH; then
    # echo "no update needed"
    exit 1
fi

# curl request to do update
curl --request POST \
    "https://forge.laravel.com/api/v1/servers/${SERVER}/sites/${SITE}/deployment/deploy" \
    --header "Authorization: Bearer ${TOKEN}" \
    --header "Content-Type: application/json" \
    --header "Accept: application/json"
