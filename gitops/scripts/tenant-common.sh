# Shared setup for the tenant-deploy*.sh scripts. Source it; don't run it
# directly. Sources the tenant vars file named by the calling script's first
# argument, which must set TENANT_ID, DOMAIN_NAME and TARGET_HOST_NAME.

TENANT_VARS="${1:?usage: $0 <tenant-vars-file>}"
source "${TENANT_VARS}"
: "${TENANT_ID:?not set in ${TENANT_VARS}}" \
  "${DOMAIN_NAME:?not set in ${TENANT_VARS}}" \
  "${TARGET_HOST_NAME:?not set in ${TENANT_VARS}}"

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
