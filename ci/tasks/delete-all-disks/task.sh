#!/usr/bin/env bash

set -euo pipefail

service_account="$(awk '/client_email/{print $2}' "tas-srt-gcp-pipeline-repo/vars/gcp_creds.json" | sed 's/[",]//g')"
gcloud auth activate-service-account "${service_account}" --key-file "tas-srt-gcp-pipeline-repo/vars/gcp_creds.json"
gcloud config set project "$PROJECT_NAME"

apt-get update && apt-get install -y jq

disks=$(gcloud compute disks list --format='json' | jq --raw-output --compact-output '.[]')

for disk in $(echo $disks); do
  disk_name=$(echo $disk | jq --raw-output '.name')
  zone=$(echo $disk | jq --raw-output '.zone')

  echo "Deleting disk $disk_name in zone $zone"
  gcloud compute disks delete "$disk_name" --zone $zone
done
