#!/usr/bin/env bash

set -euo pipefail

echo "${GCP_CREDENTIALS_JSON}" >tas-srt-gcp-pipeline-repo/vars/gcp_creds.json
echo "${GCP_CREDENTIALS_JSON}" | jq -er '.client_email' >tas-srt-gcp-pipeline-repo/vars/gcp_service_account
