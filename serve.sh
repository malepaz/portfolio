#!/usr/bin/env bash
# Serves the site at http://localhost:8080 (and on your LAN IP, so you can open it on a phone).
cd "$(dirname "$0")" && exec python3 -m http.server 8080 --bind 0.0.0.0