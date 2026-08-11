#!/usr/bin/env bash
# Deploys the CloudFront distribution in front of the ICDb app: /app is
# served from the static site bucket, everything else from the comments API.
# Requires icdb-comms-sam and IcdbStaticCdkStack to be deployed already;
# their outputs provide the two origins.
# Usage: ./deploy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

ICDB_API_URL="${ICDB_API_URL:-$(aws cloudformation describe-stacks \
  --stack-name icdb-comms-sam \
  --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" \
  --output text)}"
ICDB_SITE_URL="${ICDB_SITE_URL:-$(aws cloudformation describe-stacks \
  --stack-name IcdbStaticCdkStack \
  --query "Stacks[0].Outputs[?OutputKey=='WebsiteUrl'].OutputValue" \
  --output text)}"
export ICDB_API_URL ICDB_SITE_URL

echo "CDN origins: api=${ICDB_API_URL} site=${ICDB_SITE_URL}"

npx cdk bootstrap
npx cdk deploy --require-approval never --outputs-file cdk-outputs.json

CDN_URL="$(node -p "Object.values(require('./cdk-outputs.json').IcdbCdnCdkStack)[0]")"
echo "CDN deployed: ${CDN_URL}"
