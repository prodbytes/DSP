#!/usr/bin/env bash
# Deploys a tenant's ACM certificate. Requires the zone stack
# (tenant-deploy-zone.sh), whose exports it imports.
# Usage: ./tenant-deploy-cert.sh <tenant-vars-file>
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/tenant-common.sh"

# The certificate stack blocks until DNS validation succeeds, which needs the
# registrar to delegate the domain to this zone's name servers.
name_servers="$(output "${TENANT_ID}-route53-zone" NameServers)"
if command -v dig >/dev/null 2>&1; then
  delegated="$(dig +short NS "${DOMAIN_NAME}" | sed 's/\.$//' | sort)"
  expected="$(tr ',' '\n' <<<"${name_servers}" | sed 's/\.$//' | sort)"
  if [[ "${delegated}" != "${expected}" ]]; then
    echo "WARNING: ${DOMAIN_NAME} is not yet delegated to ${name_servers};" \
      "certificate validation will wait until it is." >&2
  fi
fi

deploy "${TENANT_ID}-acm-cert" \
  "${SAMPLES_DIR}/acm-cert/acm-cert.cform.yaml" \
  "TenantId=${TENANT_ID}"
