#!/usr/bin/env bash

set -euo pipefail

echo "${GCP_CREDENTIALS_JSON}" >tas-srt-gcp-pipeline-repo/vars/gcp_creds.json

gcp_service_account="$(echo "${GCP_CREDENTIALS_JSON}" | jq -er '.client_email')"

# manually set tas-srt-gcp-pipeline-repo/config/director.yml to correct service account
sed -i "s/associated_service_account:.\*/associated_service_account: ${gcp_service_account}/g" "tas-srt-gcp-pipeline-repo/config/director.yml"
