#!/usr/bin/env bash
# B-SIZE 门禁：shu_asm stripped 体积追踪（ENG-002 advisory；默认不 block CI）。
#
# 用法：
#   ./tests/run-size-shu-asm-gate.sh
#   SHU_ASM=./compiler/shu_asm ./tests/run-size-shu-asm-gate.sh
# 环境变量：
#   SHU_SIZE_SHU_ASM_MAX_BYTES — 上限字节（默认 8388608 = 8MiB）
#   SHU_SIZE_FAIL=1 — 超 cap 时 exit 1（仅显式 opt-in；CI 默认 0）
set -e
cd "$(dirname "$0")/.."

SHU_ASM="${SHU_ASM:-./compiler/shu_asm}"
MAX_BYTES="${SHU_SIZE_SHU_ASM_MAX_BYTES:-$((8 * 1024 * 1024))}"
BASELINE="tests/baseline/shu-asm-size.tsv"

if [ ! -x "$SHU_ASM" ]; then
  echo "size gate SKIP (no shu_asm at $SHU_ASM)"
  exit 0
fi

file_bytes() {
  local f="$1"
  if [ "$(uname -s)" = "Darwin" ]; then
    stat -f%z "$f" 2>/dev/null || wc -c <"$f"
  else
    stat -c%s "$f" 2>/dev/null || wc -c <"$f"
  fi
}

STRIPPED="$(mktemp /tmp/shu_asm_stripped.XXXXXX)"
cp "$SHU_ASM" "$STRIPPED"
if command -v strip >/dev/null 2>&1; then
  strip "$STRIPPED" 2>/dev/null || true
fi

SZ=$(file_bytes "$STRIPPED")
rm -f "$STRIPPED"

echo "size gate: shu_asm stripped=${SZ}B cap=${MAX_BYTES}B ($(awk -v s="$SZ" 'BEGIN { printf "%.2f", s/1048576 }')MiB)"

FAIL=0
if [ "${SHU_SIZE_FAIL:-0}" = "1" ]; then
  FAIL=1
fi

if [ "$SZ" -gt "$MAX_BYTES" ]; then
  echo "size gate FAIL: shu_asm stripped ${SZ}B > cap ${MAX_BYTES}B (B-SIZE stretch ≤8MiB)" >&2
  [ "$FAIL" -eq 1 ] && exit 1
  echo "size gate WARN (SHU_SIZE_FAIL=0)"
else
  echo "size gate OK (≤8MiB)"
fi

if [ "${SHU_PERF_UPDATE_SIZE_BASELINE:-0}" = "1" ]; then
  mkdir -p "$(dirname "$BASELINE")"
  {
    echo -e "# shu_asm stripped bytes (B-SIZE)"
    echo -e "max_stripped_bytes\t${MAX_BYTES}"
    echo -e "stripped_bytes\t${SZ}"
  } >"$BASELINE"
  echo "size gate: updated $BASELINE"
fi

exit 0
