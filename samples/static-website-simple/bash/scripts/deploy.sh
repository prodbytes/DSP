#!/usr/bin/env bash
# Creates the website bucket, uploads the site content, enables static
# website hosting, and prints the resulting URL.
# Usage: ./deploy.sh
set -euo pipefail

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET_NAME="static-website-simple-${ACCOUNT_ID}"

REGION="$(aws configure get region)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_DIR="${SCRIPT_DIR}/../../hello-website"

if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  echo "Bucket '${BUCKET_NAME}' already exists; skipping creation."
else
  echo "Creating bucket '${BUCKET_NAME}' in ${REGION}"
  aws s3api create-bucket --bucket "${BUCKET_NAME}"
fi

echo "Allowing public read access"
aws s3api put-public-access-block --bucket "${BUCKET_NAME}" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=false,RestrictPublicBuckets=false"

aws s3api put-bucket-policy --bucket "${BUCKET_NAME}" --policy "{
  \"Version\": \"2012-10-17\",
  \"Statement\": [{
    \"Sid\": \"PublicReadGetObject\",
    \"Effect\": \"Allow\",
    \"Principal\": \"*\",
    \"Action\": \"s3:GetObject\",
    \"Resource\": \"arn:aws:s3:::${BUCKET_NAME}/*\"
  }]
}"

echo "Uploading content from ${CONTENT_DIR}"
aws s3 sync "${CONTENT_DIR}" "s3://${BUCKET_NAME}" --delete

echo "Enabling static website hosting"
aws s3api put-bucket-website --bucket "${BUCKET_NAME}" \
  --website-configuration \
  '{"IndexDocument": {"Suffix": "index.html"}, "ErrorDocument": {"Key": "index.html"}}'

echo "Website deployed: http://${BUCKET_NAME}.s3-website.${REGION}.amazonaws.com"
