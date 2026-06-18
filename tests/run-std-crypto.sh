#!/usr/bin/env bash
# STD-006：std.crypto 金样 hook
#
# 用法：./tests/run-std-crypto.sh
set -e
cd "$(dirname "$0")/.."
chmod +x tests/run-std-crypto-gate.sh
if ./tests/run-std-crypto-gate.sh; then
  echo "std-crypto hook OK"
else
  echo "std-crypto hook FAIL" >&2
  exit 1
fi
