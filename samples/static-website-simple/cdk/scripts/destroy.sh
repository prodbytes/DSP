#!/usr/bin/env bash
# Destroys the static website stack (the bucket auto-deletes its objects).
# Usage: ./scripts/destroy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

if [ ! -d .venv ]; then
  python3 -m venv .venv
fi
.venv/bin/pip install -q -r requirements.txt
# cdk.json runs "python3 app.py"; put the venv first on PATH so it is used.
export PATH="${PWD}/.venv/bin:${PATH}"

npx cdk destroy --force
rm -f cdk-outputs.json
