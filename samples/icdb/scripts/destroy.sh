#!/usr/bin/env bash
# Destroys the entire ICDb app: the CloudFront distribution first, then the
# static site stack, then the comments API stack (including its database).
# Usage: ./scripts/destroy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICDB_DIR="${SCRIPT_DIR}/.."

"${ICDB_DIR}/icdb-cdn-cdk/scripts/destroy.sh"
"${ICDB_DIR}/icdb-static-cdk/scripts/destroy.sh"
"${ICDB_DIR}/icdb-comms-sam/scripts/destroy.sh"
