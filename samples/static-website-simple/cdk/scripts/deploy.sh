#!/usr/bin/env bash
# Deploys the static website stack with CDK (public bucket + content upload
# via BucketDeployment) and prints the resulting website URL.
# Usage: ./scripts/deploy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

if [ ! -d .venv ]; then
  python3 -m venv .venv
fi
.venv/bin/pip install -q -r requirements.txt
# cdk.json runs "python3 app.py"; put the venv first on PATH so it is used.
export PATH="${PWD}/.venv/bin:${PATH}"

npx cdk bootstrap
npx cdk deploy --require-approval never --outputs-file cdk-outputs.json

WEBSITE_URL="$(node -p "Object.values(require('./cdk-outputs.json').CdkBucketStack)[0]")"
echo "Website deployed: ${WEBSITE_URL}"
