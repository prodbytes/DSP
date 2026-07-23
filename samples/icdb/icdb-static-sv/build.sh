#!/usr/bin/env bash
# Build the ICDB static site and verify the output.
set -euo pipefail
cd "$(dirname "$0")"

echo "==> Installing dependencies"
if [ -f package-lock.json ]; then
	npm ci
else
	npm install
fi

echo "==> Building static site"
npm run build

echo "==> Verifying output"
fail=0
for page in \
	build/index.html \
	build/videos/index.html \
	build/cats/index.html \
	build/about/index.html \
	build/cats/maru/index.html \
	build/videos/henri-2-paw-de-deux/index.html \
	build/images/cats/grumpy-cat.jpg; do
	if [ ! -s "$page" ]; then
		echo "MISSING: $page"
		fail=1
	fi
done

if ! grep -q "Internet Cat Database" build/index.html; then
	echo "MISSING: expected title in build/index.html"
	fail=1
fi

pages=$(find build -name 'index.html' | wc -l)
echo "Prerendered pages: $pages"

if [ "$fail" -ne 0 ]; then
	echo "Build verification FAILED"
	exit 1
fi
echo "Build verified OK — static site in ./build"
