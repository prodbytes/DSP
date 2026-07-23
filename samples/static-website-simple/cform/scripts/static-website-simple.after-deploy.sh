#!/usr/bin/env bash
# Uploads the site content to the website bucket created by the stack.
# Usage: ./static-website-simple.after-deploy.sh [stack-name]
set -euo pipefail

STACK_NAME="${1:-${STACK_NAME:-static-website-simple}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_DIR="${SCRIPT_DIR}/../../hello-website"

BUCKET_NAME="$(aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" \
  --output text)"

if [[ -z "${BUCKET_NAME}" || "${BUCKET_NAME}" == "None" ]]; then
  echo "Could not resolve BucketName output from stack '${STACK_NAME}'" >&2
  exit 1
fi

echo "Uploading ${SITE_DIR} to s3://${BUCKET_NAME}"
aws s3 sync "${SITE_DIR}" "s3://${BUCKET_NAME}" --delete

WEBSITE_URL="$(aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs[?OutputKey=='WebsiteURL'].OutputValue" \
  --output text)"

echo "Site available at: ${WEBSITE_URL}"
