#!/usr/bin/env bash
# Serve the built ICDB static site with Python's http.server.
set -euo pipefail
cd "$(dirname "$0")"

PORT="${1:-8000}"

if [ ! -f build/index.html ]; then
	echo "No build output found — running ./build.sh first"
	./build.sh
fi

echo "Serving ICDb at: http://localhost:${PORT}/"
python3 -m http.server "$PORT" --directory build
