#!/usr/bin/env bash
# STD-004：std.async 调度器稳定 API manifest + smoke + 1M 压测
#
# 1) tests/baseline/std-async-api.tsv 符号须在 std/async/mod.sx
# 2) tests/run-async.sh 烟测
# 3) tests/run-std-async-1m-gate.sh 1M task 无崩溃
#
# 用法：./tests/run-std-async-api-gate.sh
set -e
cd "$(dirname "$0")/.."

BASELINE="tests/baseline/std-async-api.tsv"
MOD="std/async/mod.sx"
MISS=0
N=0

if [ ! -f "$BASELINE" ]; then
  echo "std-async-api gate FAIL: missing $BASELINE" >&2
  exit 1
fi
if [ ! -f "$MOD" ]; then
  echo "std-async-api gate FAIL: missing $MOD" >&2
  exit 1
fi
if [ ! -f analysis/std-async-api-v1.md ]; then
  echo "std-async-api gate FAIL: missing analysis/std-async-api-v1.md" >&2
  exit 1
fi

echo "=== STD-004: std.async stable API manifest ==="
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    ''|'#'*) continue ;;
  esac
  sym="$line"
  N=$((N + 1))
  if ! grep -qE "(function|extern function) ${sym}[[:space:](]" "$MOD"; then
    echo "std-async-api gate FAIL: missing symbol ${sym} in $MOD" >&2
    MISS=$((MISS + 1))
  fi
done < "$BASELINE"

if [ "$MISS" -gt 0 ]; then
  echo "std-async-api gate FAIL: ${MISS}/${N} symbols missing" >&2
  exit 1
fi
echo "std-async-api manifest OK (${N} symbols)"

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ]; then
  echo "std-async-api gate SKIP bench (no native shux; manifest OK only)"
  echo "std-async-api gate OK (manifest)"
  exit 0
fi

echo "=== STD-004: std.async smoke (run-async.sh) ==="
chmod +x tests/run-async.sh
SHUX="$SHUX_BIN" ./tests/run-async.sh

echo "=== STD-004: async 1M task stress ==="
chmod +x tests/run-std-async-1m-gate.sh
SHUX="$SHUX_BIN" ./tests/run-std-async-1m-gate.sh

echo "std-async-api gate OK"
