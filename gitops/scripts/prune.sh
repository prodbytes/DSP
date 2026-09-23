#!/usr/bin/env bash
# Wipes the current AWS account: deletes every object, object version and
# delete marker in every S3 bucket and every Route 53 record except each
# zone's apex NS and SOA, then deletes every CloudFormation stack. Buckets and
# hosted zones themselves are left in place; stacks remove the ones they own
# once they are empty. Stacks are retried until those that import another stack's
# exports are gone and the exporting stack can be deleted too.
# Usage: [REGIONS="us-east-1 ..."] ./prune.sh
set -euo pipefail

REGIONS="${REGIONS:-us-east-1}"

bucket_region() {
  local location
  location="$(aws s3api get-bucket-location --bucket "$1" \
    --query LocationConstraint --output text)"
  case "${location}" in
    None | null | "") echo us-east-1 ;;
    EU) echo eu-west-1 ;;
    *) echo "${location}" ;;
  esac
}

# Deletes objects in pages of up to 1000 (the delete-objects limit), listing
# from the start each time so deletions never invalidate a pagination token.
# Unversioned buckets list their objects with VersionId "null", which
# delete-objects accepts, so one loop covers both kinds of bucket.
empty_bucket() {
  local bucket="$1" region page count
  region="$(bucket_region "${bucket}")"
  echo "==> Emptying s3://${bucket} (${region})"
  while :; do
    page="$(aws s3api list-object-versions --region "${region}" \
      --bucket "${bucket}" --max-items 1000 --output json \
      | jq -c '{Objects: ([.Versions[]?, .DeleteMarkers[]?]
                          | map({Key, VersionId})), Quiet: true}')"
    count="$(jq '.Objects | length' <<<"${page}")"
    [[ "${count}" -eq 0 ]] && break
    echo "    deleting ${count} versions"
    aws s3api delete-objects --region "${region}" --bucket "${bucket}" \
      --delete "${page}" --output json \
      | jq -r '.Errors[]? | "    ERROR \(.Key) \(.VersionId): \(.Message)"' >&2
  done
}

# Clears every record except the apex NS and SOA that Route 53 creates with
# the zone. A hosted zone can only be deleted in that state, and ACM leaves its
# DNS-validation CNAMEs behind, which would block the stack owning the zone.
# Changes go in batches of 500, under the 1000-change limit per request.
empty_zone() {
  local zone="$1" apex changes count
  apex="$(aws route53 get-hosted-zone --id "${zone}" \
    --query HostedZone.Name --output text)"
  echo "==> Emptying hosted zone ${apex} (${zone})"
  changes="$(aws route53 list-resource-record-sets --hosted-zone-id "${zone}" \
    --output json | jq -c --arg apex "${apex}" '
    [.ResourceRecordSets[]
     | select((.Name == $apex and (.Type == "NS" or .Type == "SOA")) | not)
     | {Action: "DELETE", ResourceRecordSet: .}]')"
  count="$(jq length <<<"${changes}")"
  echo "    deleting ${count} records"
  for ((i = 0; i < count; i += 500)); do
    aws route53 change-resource-record-sets --hosted-zone-id "${zone}" \
      --change-batch "$(jq -c --argjson i "${i}" '{Changes: .[$i:$i+500]}' \
        <<<"${changes}")" >/dev/null
  done
}

# Top-level stacks only: nested stacks are deleted with their parent.
list_stacks() {
  aws cloudformation describe-stacks --region "$1" \
    --query 'Stacks[?ParentId==null && StackStatus!=`DELETE_COMPLETE`].StackName' \
    --output text | tr '\t' '\n' | sed '/^$/d'
}

delete_stacks() {
  local region="$1" stacks remaining previous=""
  while :; do
    stacks="$(list_stacks "${region}")"
    [[ -z "${stacks}" ]] && { echo "    no stacks left in ${region}"; return 0; }
    if [[ "${stacks}" == "${previous}" ]]; then
      echo "ERROR: these stacks in ${region} could not be deleted:" >&2
      aws cloudformation describe-stacks --region "${region}" \
        --query 'Stacks[?ParentId==null].[StackName,StackStatus,StackStatusReason]' \
        --output text >&2
      return 1
    fi
    previous="${stacks}"
    while IFS= read -r stack; do
      echo "==> Deleting stack ${stack} (${region})"
      aws cloudformation delete-stack --region "${region}" --stack-name "${stack}" || true
    done <<<"${stacks}"
    while IFS= read -r stack; do
      aws cloudformation wait stack-delete-complete --region "${region}" \
        --stack-name "${stack}" 2>/dev/null || true
    done <<<"${stacks}"
    remaining="$(list_stacks "${region}" | wc -l | tr -d ' ')"
    echo "    ${remaining} stacks remaining in ${region}"
  done
}

account="$(aws sts get-caller-identity --query Account --output text)"
zones="$(aws route53 list-hosted-zones --query 'HostedZones[].Id' \
  --output text | tr '\t' '\n' | sed '/^$/d')"
buckets="$(aws s3api list-buckets --query 'Buckets[].Name' --output text \
  | tr '\t' '\n' | sed '/^$/d')"

echo "Account: ${account}"
echo "Hosted zones to empty:"
sed 's/^/  /' <<<"${zones:-(none)}"
echo "Buckets to empty:"
sed 's/^/  /' <<<"${buckets:-(none)}"
for region in ${REGIONS}; do
  echo "Stacks to delete in ${region}:"
  stacks="$(list_stacks "${region}")"
  sed 's/^/  /' <<<"${stacks:-(none)}"
done

if [[ -n "${buckets}" ]]; then
  while IFS= read -r bucket; do
    empty_bucket "${bucket}"
  done <<<"${buckets}"
fi

if [[ -n "${zones}" ]]; then
  while IFS= read -r zone; do
    empty_zone "${zone}"
  done <<<"${zones}"
fi

status=0
for region in ${REGIONS}; do
  delete_stacks "${region}" || status=1
done
exit "${status}"
