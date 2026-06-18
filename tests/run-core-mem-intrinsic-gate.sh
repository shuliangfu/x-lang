#!/usr/bin/env bash
# CORE-008：core.mem 热路径 intrinsic 映射门禁
#
# 用法：./tests/run-core-mem-intrinsic-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_CORE_MEM_INTRINSIC_DOC:-analysis/core-mem-intrinsic-v1.md}"
MANIFEST="${SHU_CORE_MEM_INTRINSIC_TSV:-tests/baseline/core-mem-intrinsic.tsv}"
CODEGEN="compiler/src/codegen/codegen.c"
LIB="tests/lib/core-mem-intrinsic.sh"
EMIT_SU="tests/mem/main.su"
MIN_MAP=4
PREFIX="shu: [SHU_CORE_MEM_INTRINSIC]"

# shellcheck source=tests/lib/core-mem-intrinsic.sh
. tests/lib/core-mem-intrinsic.sh

echo "=== CORE-008: core.mem intrinsic manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$CODEGEN" "$EMIT_SU"; do
  if [ ! -f "$f" ]; then
    echo "core-mem-intrinsic gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in runnable SHU_CORE_MEM_INTRINSIC mem_compare __builtin_memcmp; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-mem-intrinsic gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_mappings) MIN_MAP="$c2" ;;
  esac
done < "$MANIFEST"

map_miss="$(core_mem_intrinsic_mappings_ok "$CODEGEN" "$MANIFEST" || true)"
if [ "${map_miss:-0}" -gt 0 ]; then
  core_mem_intrinsic_emit_report "fail" 0 "$MIN_MAP"
  echo "core-mem-intrinsic gate FAIL: mapping_miss=${map_miss}" >&2
  exit 1
fi
echo "core-mem-intrinsic manifest OK (mappings=${MIN_MAP})"

# 解析本机可执行 shu-c（与 BOOT-013 一致，避免 Darwin 误判 Linux ELF）。
stdlib_cm_native_shu() {
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
resolve_emit_shu() {
  local cand
  for cand in ./compiler/shu-c ./compiler/shu; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  if [ -n "${SHU:-}" ] && stdlib_cm_native_shu "$SHU"; then
    echo "$SHU"
    return 0
  fi
  return 1
}

EMIT_TOTAL=4
if SHU_BIN="$(resolve_emit_shu 2>/dev/null)"; then
  echo "=== CORE-008: runnable SHU_DEBUG_C emit (SHU=$SHU_BIN) ==="
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  if ! stdlib_cm_native_shu "$SHU_BIN"; then
    SHU_BIN="$(resolve_emit_shu 2>/dev/null || true)"
  fi
  if [ -n "${SHU_BIN:-}" ] && stdlib_cm_native_shu "$SHU_BIN"; then
  found="$(core_mem_intrinsic_emit_ok "$SHU_BIN" "$EMIT_SU" "$MANIFEST" || true)"
  if [ "${found:-0}" -lt "$EMIT_TOTAL" ]; then
    core_mem_intrinsic_emit_report "fail" "${found:-0}" "$EMIT_TOTAL"
    echo "core-mem-intrinsic gate FAIL: emit ${found:-0}/${EMIT_TOTAL}" >&2
    exit 1
  fi
  core_mem_intrinsic_emit_report "ok" "$found" "$EMIT_TOTAL"
  grep -qF "$PREFIX" <(core_mem_intrinsic_emit_report "ok" "$found" "$EMIT_TOTAL")
  else
    echo "core-mem-intrinsic gate SKIP runnable (shu not native after make)" >&2
  fi
else
  echo "core-mem-intrinsic gate SKIP runnable (no shu)" >&2
fi

echo "core-mem-intrinsic gate OK"
