#!/usr/bin/env bash
# Deploys the entire ICDb app:
#   1. icdb-comms-sam — comments API (SAM: VPC + Aurora Serverless v2 + Lambda)
#   2. icdb-static-sv — static site build, with the comments API URL baked in
#   3. icdb-static-cdk — S3 static website hosting the build (CDK)
#   4. icdb-cdn-cdk — CloudFront in front of both; the default entry point
# Usage: ./scripts/deploy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICDB_DIR="${SCRIPT_DIR}/.."

"${ICDB_DIR}/icdb-comms-sam/scripts/deploy.sh"

API_URL="$(aws cloudformation describe-stacks \
  --stack-name icdb-comms-sam \
  --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" \
  --output text)"
echo "Building static site with comments API: ${API_URL}"

VITE_COMMENTS_API="${API_URL}" "${ICDB_DIR}/icdb-static-sv/scripts/build.sh"

"${ICDB_DIR}/icdb-static-cdk/scripts/deploy.sh"

ICDB_API_URL="${API_URL}" "${ICDB_DIR}/icdb-cdn-cdk/scripts/deploy.sh"

CDN_URL="$(node -p "Object.values(require('${ICDB_DIR}/icdb-cdn-cdk/cdk-outputs.json').IcdbCdnCdkStack)[0]")"
echo "ICDb is live (CloudFront): ${CDN_URL}"
