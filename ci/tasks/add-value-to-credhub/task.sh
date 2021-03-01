#!/usr/bin/env bash

set -euo pipefail

credhub set \
  --name "${NAME}" \
  --type "${TYPE}" \
  --value "${VALUE}"
