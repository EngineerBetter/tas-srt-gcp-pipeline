#!/usr/bin/env bash

set -euo pipefail

gcloud version

# Authenticate with Google before creating VM
service_account="$(awk '/client_email/{print $2}' "vars/vars/gcp_creds.json" | sed 's/[",]//g')"

gcloud auth activate-service-account "${service_account}" --key-file "vars/vars/gcp_creds.json"

scope_set=$(gcloud compute instances list --filter="serviceAccounts.scopes=https://www.googleapis.com/auth/cloud-platform AND name=ops-manager-vm")

if [[ $scope_set == "true" ]]; then
  echo "Scope 'cloud-platform' already set for Opsman VM instance, skipping..."
  exit 0
fi

# This is necessary because this scope is not added to the Opsman VM by platform automation's 'create-vm' task, and without it Opsman will error when trying to validate tile configuration with GCP
echo "Stopping Opsman VM..."
gcloud compute instances stop ops-manager-vm
echo "Adding scope 'cloud-platform' to Opsman VM..."
gcloud beta compute instances set-scopes --scopes=https://www.googleapis.com/auth/cloud-platform ops-manager-vm
echo "Starting Opsman VM..."
gcloud compute instances start ops-manager-vm

# run an arbitrary om command, with OM_DECRYPTION_PASSPHRASE exported in order to decrypt opsman after a reboot
echo "Decrypting Opsman..."
om products
