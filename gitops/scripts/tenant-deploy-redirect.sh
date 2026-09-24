#!/usr/bin/env bash
# Deploys a tenant's HTTPS redirect. Requires the zone and certificate stacks
# (tenant-deploy-zone.sh, tenant-deploy-cert.sh), whose exports it imports.
# Usage: TENANT_ID=... DOMAIN_NAME=... TARGET_HOST_NAME=... ./tenant-deploy-redirect.sh
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/tenant-common.sh"

deploy "${TENANT_ID}-s3-redirect-https" \
  "${SAMPLES_DIR}/s3-redirect-https/s3-redirect-https.cform.yaml" \
  "TenantId=${TENANT_ID}" "TargetHostName=${TARGET_HOST_NAME}"

echo "Redirect: $(output "${TENANT_ID}-s3-redirect-https" RedirectFrom)" \
  "-> $(output "${TENANT_ID}-s3-redirect-https" RedirectTo)"
