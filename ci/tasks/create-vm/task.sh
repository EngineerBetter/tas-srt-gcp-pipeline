#!/usr/bin/env bash

set -euo pipefail

service_account="$(awk '/client_email/{print $2}' "vars/vars/gcp_creds.json" | sed 's/[",]//g')"

gcloud auth activate-service-account "${service_account}" --key-file "vars/vars/gcp_creds.json"

./platform-automation-tasks/tasks/create-vm.sh
