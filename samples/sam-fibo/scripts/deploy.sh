#!/usr/bin/env bash
# Builds and deploys the sam-fibo stack (SAM), then prints the API URL.
# Usage: ./scripts/deploy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

# Build in a Lambda-like container so the host Python version doesn't matter.
sam build --use-container
sam deploy --no-confirm-changeset --no-fail-on-empty-changeset

API_URL="$(aws cloudformation describe-stacks \
  --stack-name sam-fibo \
  --query "Stacks[0].Outputs[?OutputKey=='SAMFiboApi'].OutputValue" \
  --output text)"

echo "SAMFibo API deployed: ${API_URL}"
echo "Try it now: ${API_URL}?x=10"
