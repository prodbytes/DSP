#!/usr/bin/env bash
# Empties the website bucket, then deletes the bucket.
# Usage: ./destroy.sh
set -euo pipefail

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET_NAME="static-website-simple-${ACCOUNT_ID}"

if ! aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  echo "Bucket '${BUCKET_NAME}' not found; nothing to delete."
  exit 0
fi

echo "Emptying s3://${BUCKET_NAME}"
aws s3 rm "s3://${BUCKET_NAME}" --recursive

echo "Deleting bucket '${BUCKET_NAME}'"
aws s3api delete-bucket --bucket "${BUCKET_NAME}"
echo "Bucket '${BUCKET_NAME}' deleted."
