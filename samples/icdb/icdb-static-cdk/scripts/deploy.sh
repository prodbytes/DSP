#!/usr/bin/env bash
# Deploys the static website stack with CDK (bucket + content upload via
# BucketDeployment) and prints the resulting website URL.
# Usage: ./deploy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

npx cdk bootstrap
npx cdk deploy --require-approval never --outputs-file cdk-outputs.json

WEBSITE_URL="$(node -p "Object.values(require('./cdk-outputs.json').IcdbStaticCdkStack)[0]")"
echo "Website deployed: ${WEBSITE_URL}"
