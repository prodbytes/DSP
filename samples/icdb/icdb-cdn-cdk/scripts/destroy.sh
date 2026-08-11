#!/usr/bin/env bash
# Destroys the CloudFront distribution stack.
# Usage: ./destroy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

# Synth needs the env vars even to destroy; placeholders are fine.
export ICDB_API_URL="${ICDB_API_URL:-https://placeholder.execute-api.invalid}"
export ICDB_SITE_URL="${ICDB_SITE_URL:-http://placeholder.s3-website.invalid}"

npx cdk destroy --force
rm -f cdk-outputs.json
