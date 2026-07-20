#!/usr/bin/env bash
# Runs two scenarios on the lbnet docker network:
#   direct  -> k6 hits app1:3000 (no proxy)
#   nginx   -> k6 hits nginx:80  (proxy overhead included)
set -euo pipefail
cd "$(dirname "$0")"
OUT_DIR="${OUT_DIR:-$PWD/../benchmark-raw}" # stays inside the repo
mkdir -p "$OUT_DIR"

for scenario in direct nginx; do
  [ "$scenario" = direct ] && target=http://app1:3000 || target=http://nginx:80
  echo ">>> $scenario ($target)"
  docker run --rm --network lbnet \
    -v "$PWD:/scripts" -v "$OUT_DIR:/out" \
    -e TARGET=$target \
    grafana/k6 run --summary-export "/out/${scenario}.json" /scripts/script.js
done
