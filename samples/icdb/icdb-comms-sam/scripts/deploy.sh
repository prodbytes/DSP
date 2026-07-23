#!/usr/bin/env bash
# Builds and deploys the comments API stack (SAM), then prints the API URL.
# Usage: ./scripts/deploy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

if [ ! -d node_modules ]; then
  npm install
fi

# sam build bundles with esbuild, which it expects to find on the PATH.
PATH="$(pwd)/node_modules/.bin:${PATH}"

sam build
sam deploy --no-confirm-changeset --no-fail-on-empty-changeset

API_URL="$(aws cloudformation describe-stacks \
  --stack-name icdb-comms-sam \
  --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" \
  --output text)"

echo "Seeding initial comments (errors harmlessly if comments already exist)"
curl -sS "${API_URL}/init"
echo

echo "Comments API deployed: ${API_URL}"
