#!/usr/bin/env bash
# Destroys the sam-calc stack.
# Usage: ./scripts/destroy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

sam delete --no-prompts
