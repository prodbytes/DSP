#!/usr/bin/env bash
# Empties the website bucket so the stack (and bucket) can be deleted.
# Usage: ./static-website-simple.before-destroy.sh [stack-name]
set -euo pipefail

STACK_NAME="${1:-${STACK_NAME:-static-website-simple}}"

BUCKET_NAME="$(aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" \
  --output text)"

if [[ -z "${BUCKET_NAME}" || "${BUCKET_NAME}" == "None" ]]; then
  echo "Could not resolve BucketName output from stack '${STACK_NAME}'" >&2
  exit 1
fi

if ! aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  echo "Bucket '${BUCKET_NAME}' not found; nothing to empty."
  exit 0
fi

echo "Emptying s3://${BUCKET_NAME}"
aws s3 rm "s3://${BUCKET_NAME}" --recursive
