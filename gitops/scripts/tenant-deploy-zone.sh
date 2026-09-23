#!/usr/bin/env bash
# Deploys a tenant's Route 53 hosted zone and prints its name servers, which
# the registrar must delegate to before the certificate can validate.
# Usage: ./tenant-deploy-zone.sh <tenant-vars-file>
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/tenant-common.sh"

deploy "${TENANT_ID}-route53-zone" \
  "${SAMPLES_DIR}/route53-zone/route53-zone.cform.yaml" \
  "TenantId=${TENANT_ID}" "DomainName=${DOMAIN_NAME}"

echo "Zone name servers: $(output "${TENANT_ID}-route53-zone" NameServers)"
