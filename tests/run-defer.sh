#!/usr/bin/env bash
# defer block: parse + codegen; block-tail expression is the return value.
#
# Honesty: body lives in run-defer-gate.sh (prefer-asm / hard die /
# run=/obs=/skip=). This wrapper only delegates — no soft SKIP→OK.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
chmod +x tests/run-defer-gate.sh
./tests/run-defer-gate.sh
echo "defer test OK"
