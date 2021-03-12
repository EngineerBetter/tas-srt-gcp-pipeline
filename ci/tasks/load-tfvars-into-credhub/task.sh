#!/usr/bin/env bash

set -euo pipefail

me="$(cd "$(dirname "$0")" && pwd)"

jq '.stable_config_opsmanager |= fromjson | .stable_config_opsmanager' paving-terraform/metadata >opsman_config.json
jq '.stable_config_pas |= fromjson | .stable_config_pas' paving-terraform/metadata >tas_config.json

bosh interpolate "${me}/creds.yml" \
  --vars-file opsman_config.json \
  --vars-file tas_config.json \
  --vars-file project-account-and-bucket-terraform/metadata \
  --vars-file "tas-srt-gcp-pipeline-repo/vars/${ENV}.yml" >interpolated_creds.yml

credhub import --file interpolated_creds.yml
