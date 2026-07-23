#!/usr/bin/env bash
# Destroys the static website stack (the bucket auto-deletes its objects).
# Usage: ./destroy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

npx cdk destroy --force
rm -f cdk-outputs.json
