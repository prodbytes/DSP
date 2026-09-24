#!/usr/bin/env bash
# Deploys a tenant's Google Workspace (Gmail) mail records. Requires the zone
# stack (tenant-deploy-zone.sh), whose exports it imports.
# Usage: TENANT_ID=... DOMAIN_NAME=... TARGET_HOST_NAME=... ./tenant-deploy-gmail.sh
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/tenant-common.sh"

deploy "${TENANT_ID}-route53-gmail" \
  "${SAMPLES_DIR}/route53-gmail/route53-gmail.cform.yaml" \
  "TenantId=${TENANT_ID}"
