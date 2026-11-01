#!/usr/bin/env bash
# Usage: ./shot.sh <out.png> [width] [height] [ui-state]
# Headless Firefox screenshot of the local site, e.g. ./shot.sh start.png 1280 900 nointro,startmenu
set -e
out=$1; w=${2:-1280}; h=${3:-900}; ui=${4:-nointro}
prof=$(mktemp -d)
timeout 90 firefox --headless --no-remote --profile "$prof" --screenshot "$out" --window-size="$w,$h" "http://127.0.0.1:8080/?ui=$ui" >/dev/null 2>&1 || true
rm -rf "$prof"
ls -la "$out"