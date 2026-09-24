# Shared setup for the tenant-deploy*.sh scripts. Source it; don't run it
# directly. Tenant settings come from the environment: TENANT_ID, DOMAIN_NAME
# and TARGET_HOST_NAME must be exported by the caller (e.g. nu01/nu01-deploy.sh).

: "${TENANT_ID:?must be set in the environment}" \
  "${DOMAIN_NAME:?must be set in the environment}" \
  "${TARGET_HOST_NAME:?must be set in the environment}"

# us-east-1 is required: CloudFront only accepts ACM certificates from there,
# and CloudFormation imports only resolve within one region.
REGION="us-east-1"

SAMPLES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../samples" && pwd)"

deploy() {
  local stack="$1" template="$2"
  shift 2
  echo "==> Deploying ${stack}"
  aws cloudformation deploy \
    --region "${REGION}" \
    --stack-name "${stack}" \
    --template-file "${template}" \
    --no-fail-on-empty-changeset \
    --parameter-overrides "$@"
}

output() {
  aws cloudformation describe-stacks \
    --region "${REGION}" \
    --stack-name "$1" \
    --query "Stacks[0].Outputs[?OutputKey=='$2'].OutputValue | [0]" \
    --output text
}
