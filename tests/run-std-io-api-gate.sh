#!/usr/bin/env bash
# STD-001：std.io 稳定 API manifest 门禁 + 基础 smoke。
# 1) tests/baseline/std-io-api.tsv 中每个符号须在 std/io/mod.sx 存在
# 2) tests/run-io.sh 烟测
#
# 用法：./tests/run-std-io-api-gate.sh
set -e
cd "$(dirname "$0")/.."

BASELINE="tests/baseline/std-io-api.tsv"
MOD="std/io/mod.sx"
MISS=0
N=0

if [ ! -f "$BASELINE" ]; then
  echo "std-io-api gate FAIL: missing $BASELINE" >&2
  exit 1
fi
if [ ! -f "$MOD" ]; then
  echo "std-io-api gate FAIL: missing $MOD" >&2
  exit 1
fi

echo "=== STD-001: std.io stable API manifest ==="
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    ''|'#'*) continue ;;
  esac
  sym="$line"
  N=$((N + 1))
  if ! grep -qE "function ${sym}[[:space:](]" "$MOD"; then
    echo "std-io-api gate FAIL: missing stable symbol function ${sym} in $MOD" >&2
    MISS=$((MISS + 1))
  fi
done < "$BASELINE"

if [ "$MISS" -gt 0 ]; then
  echo "std-io-api gate FAIL: ${MISS}/${N} symbols missing" >&2
  exit 1
fi
echo "std-io-api manifest OK (${N} symbols)"

# 烟测：需本机可 exec 的 shux/shux-c
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
  echo "std-io-api gate SKIP smoke (no native shux; manifest OK only)"
  echo "std-io-api gate OK (manifest)"
  exit 0
fi

echo "=== STD-001: std.io smoke (run-io.sh) ==="
chmod +x tests/run-io.sh
SHUX="$SHUX_BIN" ./tests/run-io.sh
echo "std-io-api gate OK"
