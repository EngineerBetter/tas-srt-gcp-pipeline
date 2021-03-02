#!/usr/bin/env bash

set -euo pipefail

me="$(cd "$(dirname "$0")" && pwd)"

envsubst <"${me}/template.yml" >"${me}/../../../vars/g_creds.yml"
