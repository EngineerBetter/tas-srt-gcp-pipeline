#!/usr/bin/env bash

set -euo pipefail

echo "${GCP_CREDENTIALS_JSON}" | jq -rc '{"gcp_credentials_json": . | tostring}' >tas-srt-gcp-pipeline-repo/vars/g_creds.yml
