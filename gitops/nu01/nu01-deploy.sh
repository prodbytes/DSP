#!/usr/bin/env bash
# Deploys all of nu01's domain stacks in order: Route 53 zone, ACM certificate,
# then the HTTPS redirect and the Gmail mail records. Each step is also
# runnable on its own from gitops/scripts with the same environment.
set -euo pipefail

export TENANT_ID="nu01"
export DOMAIN_NAME="nu01.com"
export TARGET_HOST_NAME="prodbytes.substack.com"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)"
source "${SCRIPT_DIR}/tenant-common.sh"

echo "Tenant ${TENANT_ID}: ${DOMAIN_NAME} -> ${TARGET_HOST_NAME} (${REGION})"
"${SCRIPT_DIR}/tenant-deploy-zone.sh"

# nu01.com is registered with Route 53 Domains in this account, so point the
# registration at the zone's name servers; the cert can't validate until then.
IFS=',' read -r -a zone_ns <<<"$(output "${TENANT_ID}-route53-zone" NameServers)"
registered_ns="$(aws route53domains get-domain-detail \
  --region "${REGION}" \
  --domain-name "${DOMAIN_NAME}" \
  --query 'Nameservers[].Name' \
  --output text | tr '\t' '\n' | sed 's/\.$//' | sort)"
if [[ "${registered_ns}" != "$(printf '%s\n' "${zone_ns[@]}" | sort)" ]]; then
  echo "==> Delegating ${DOMAIN_NAME} to ${zone_ns[*]}"
  aws route53domains update-domain-nameservers \
    --region "${REGION}" \
    --domain-name "${DOMAIN_NAME}" \
    --nameservers "${zone_ns[@]/#/Name=}" \
    --output text
fi

"${SCRIPT_DIR}/tenant-deploy-cert.sh"
"${SCRIPT_DIR}/tenant-deploy-redirect.sh"
"${SCRIPT_DIR}/tenant-deploy-gmail.sh"
