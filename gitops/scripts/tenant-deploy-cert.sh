#!/usr/bin/env bash
# Deploys a tenant's ACM certificate. Requires the zone stack
# (tenant-deploy-zone.sh), whose exports it imports.
# Usage: TENANT_ID=... DOMAIN_NAME=... TARGET_HOST_NAME=... ./tenant-deploy-cert.sh
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/tenant-common.sh"

# The certificate stack blocks until DNS validation succeeds, which needs the
# registrar to delegate the domain to this zone's name servers. Wait for that
# to propagate first (up to DELEGATION_TIMEOUT seconds, default 30 minutes).
name_servers="$(output "${TENANT_ID}-route53-zone" NameServers)"
if command -v dig >/dev/null 2>&1; then
  expected="$(tr ',' '\n' <<<"${name_servers}" | sed 's/\.$//' | sort)"
  deadline=$((SECONDS + ${DELEGATION_TIMEOUT:-1800}))
  until [[ "$(dig +short NS "${DOMAIN_NAME}" | sed 's/\.$//' | sort)" == "${expected}" ]]; do
    if ((SECONDS >= deadline)); then
      echo "ERROR: ${DOMAIN_NAME} is still not delegated to ${name_servers}" >&2
      exit 1
    fi
    echo "Waiting for ${DOMAIN_NAME} to delegate to ${name_servers}..."
    sleep 30
  done
  echo "${DOMAIN_NAME} is delegated to ${name_servers}"
else
  echo "WARNING: dig not found; not checking that ${DOMAIN_NAME} is delegated." >&2
fi

deploy "${TENANT_ID}-acm-cert" \
  "${SAMPLES_DIR}/acm-cert/acm-cert.cform.yaml" \
  "TenantId=${TENANT_ID}"
