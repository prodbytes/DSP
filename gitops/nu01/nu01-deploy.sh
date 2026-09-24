#!/usr/bin/env bash
# Deploys all of nu01's domain stacks in order: Route 53 zone, ACM certificate,
# then the HTTPS redirect. Each step is also runnable on its own from
# gitops/scripts with the same environment.
set -euo pipefail

export TENANT_ID="nu01"
export DOMAIN_NAME="nu01.com"
export TARGET_HOST_NAME="prodbytes.substack.com"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)"
source "${SCRIPT_DIR}/tenant-common.sh"

echo "Tenant ${TENANT_ID}: ${DOMAIN_NAME} -> ${TARGET_HOST_NAME} (${REGION})"
"${SCRIPT_DIR}/tenant-deploy-zone.sh"
"${SCRIPT_DIR}/tenant-deploy-cert.sh"
"${SCRIPT_DIR}/tenant-deploy-redirect.sh"
