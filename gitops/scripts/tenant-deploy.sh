#!/usr/bin/env bash
# Deploys all of a tenant's domain stacks in order: Route 53 zone, ACM
# certificate, then the HTTPS redirect. Each step is also runnable on its own.
# Usage: ./tenant-deploy.sh <tenant-vars-file>   (e.g. ../nu01/nu01-vars.sh)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/tenant-common.sh"

echo "Tenant ${TENANT_ID}: ${DOMAIN_NAME} -> ${TARGET_HOST_NAME} (${REGION})"
"${SCRIPT_DIR}/tenant-deploy-zone.sh" "${TENANT_VARS}"
"${SCRIPT_DIR}/tenant-deploy-cert.sh" "${TENANT_VARS}"
"${SCRIPT_DIR}/tenant-deploy-redirect.sh" "${TENANT_VARS}"
