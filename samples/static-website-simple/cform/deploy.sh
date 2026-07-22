#!/usr/bin/env bash
# Deploys the static website stack, then uploads the site content.
# Usage: ./deploy.sh [stack-name]
set -euo pipefail

STACK_NAME="${1:-${STACK_NAME:-static-website-simple}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

aws cloudformation deploy \
  --stack-name "${STACK_NAME}" \
  --template-file "${SCRIPT_DIR}/static-website-simple.cform.yaml"

"${SCRIPT_DIR}/static-website-simple.after-deploy.sh" "${STACK_NAME}"

website_address="$(aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --query 'Stacks[0].Outputs[?OutputKey==`WebsiteAddress` || OutputKey==`WebsiteURL`].OutputValue | [0]' \
  --output text 2>/dev/null || true)"

if [[ -n "${website_address}" && "${website_address}" != "None" ]]; then
  echo "Website address: ${website_address}"
else
  echo "Website address: unavailable"
fi
