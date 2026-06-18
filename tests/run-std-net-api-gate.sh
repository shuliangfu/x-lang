#!/usr/bin/env bash
# STD-002：std.net 稳定 API manifest 门禁 + 基础 smoke。
# 1) tests/baseline/std-net-api.tsv 中每个符号须在 std/net/mod.su 存在
# 2) tests/run-net.sh 烟测
#
# 用法：./tests/run-std-net-api-gate.sh
set -e
cd "$(dirname "$0")/.."

BASELINE="tests/baseline/std-net-api.tsv"
MOD="std/net/mod.su"
MISS=0
N=0

if [ ! -f "$BASELINE" ]; then
  echo "std-net-api gate FAIL: missing $BASELINE" >&2
  exit 1
fi
if [ ! -f "$MOD" ]; then
  echo "std-net-api gate FAIL: missing $MOD" >&2
  exit 1
fi

echo "=== STD-002: std.net stable API manifest ==="
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    ''|'#'*) continue ;;
  esac
  sym="$line"
  N=$((N + 1))
  if ! grep -qE "function ${sym}[[:space:](]" "$MOD"; then
    echo "std-net-api gate FAIL: missing stable symbol function ${sym} in $MOD" >&2
    MISS=$((MISS + 1))
  fi
done < "$BASELINE"

if [ "$MISS" -gt 0 ]; then
  echo "std-net-api gate FAIL: ${MISS}/${N} symbols missing" >&2
  exit 1
fi
echo "std-net-api manifest OK (${N} symbols)"

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

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHU_BIN" ]; then
  echo "std-net-api gate SKIP smoke (no native shu; manifest OK only)"
  echo "std-net-api gate OK (manifest)"
  exit 0
fi

echo "=== STD-002: std.net smoke (run-net.sh) ==="
chmod +x tests/run-net.sh
SHU="$SHU_BIN" ./tests/run-net.sh
echo "std-net-api gate OK"
