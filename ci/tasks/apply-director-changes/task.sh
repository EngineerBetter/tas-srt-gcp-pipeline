#!/usr/bin/env bash

set -euo pipefail

# Disable network verifier since OM seems unable to use the correct service account
# when checking GCP networks
om --env env/config/env.yml disable-director-verifiers --type NetworksExistenceVerifier

./platform-automation-tasks/tasks/apply-director-changes.sh
