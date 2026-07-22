#!/usr/bin/env bash
# Empties the website bucket, then deletes the stack.
# Usage: ./destroy.sh [stack-name]
set -euo pipefail

STACK_NAME="${1:-${STACK_NAME:-static-website-simple}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/static-website-simple.before-destroy.sh" "${STACK_NAME}"

aws cloudformation delete-stack --stack-name "${STACK_NAME}"

echo "Waiting for stack '${STACK_NAME}' to be deleted..."
aws cloudformation wait stack-delete-complete --stack-name "${STACK_NAME}"
echo "Stack '${STACK_NAME}' deleted."
