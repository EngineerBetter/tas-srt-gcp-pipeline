#!/usr/bin/env bash

set -euo pipefail

me="$(cd "$(dirname "$0")" && pwd)"

jq '.stable_config_opsmanager |= fromjson | .stable_config_opsmanager' paving-terraform/metadata >opsman_config.json
jq '.stable_config_pas |= fromjson | .stable_config_pas' paving-terraform/metadata >tas_config.json

bosh interpolate "${me}/creds.yml" \
  -l opsman_config.json \
  -l tas_config.json \
  -l project-account-and-bucket-terraform/metadata \
  -l "tas-srt-gcp-pipeline-repo/vars/${ENV}.yml" >interpolated_creds.yml

credhub import -f interpolated_creds.yml
