#!/usr/bin/env bash

gcp_service_account="$(cat vars/vars/gcp_service_account)"

# manually set tas-srt-gcp-pipeline-repo/config/director.yml to correct service account
# om does not seem to be able to detect this correctly
sed -i "s/associated_service_account:.*/associated_service_account: ${gcp_service_account}/g" "config/config/director.yml"

./platform-automation-tasks/tasks/configure-director.sh
