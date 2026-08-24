#!/usr/bin/env bash
# CORE-008：core.mem 热路径 intrinsic / 纯 .x 门禁（假权威诚实）。
#
# 用法：./tests/run-core-mem-intrinsic-gate.sh
# wave honesty (2026-08-24 #11): DOC → analysis/archive/core/;
# codegen.c retired — live = codegen.x + core/mem/mod.x pure .x loops;
# XLANG_DEBUG_C __builtin_* emit observational SKIP.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_CORE_MEM_INTRINSIC_DOC:-analysis/archive/core/core-mem-intrinsic-v1.md}"
MANIFEST="${XLANG_CORE_MEM_INTRINSIC_TSV:-tests/baseline/core-mem-intrinsic.tsv}"
CODEGEN="compiler/src/codegen/codegen.x"
MEM_X="core/mem/mod.x"
LIB="tests/lib/core-mem-intrinsic.sh"
EMIT_X="tests/mem/main.x"
MIN_MAP=4
PREFIX="xlang: [XLANG_CORE_MEM_INTRINSIC]"

# shellcheck source=tests/lib/core-mem-intrinsic.sh
. tests/lib/core-mem-intrinsic.sh

echo "=== CORE-008: core.mem intrinsic manifest (archive DOC; c retired) ==="
if [ -f analysis/core-mem-intrinsic-v1.md ]; then
  echo "core-mem-intrinsic gate FAIL: top-level DOC resurrected (live = archive/core/)" >&2
  exit 1
fi
if [ -f compiler/src/codegen/codegen.c ]; then
  echo "core-mem-intrinsic gate FAIL: codegen.c resurrected (live = codegen.x / pure .x)" >&2
  exit 1
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$CODEGEN" "$MEM_X" "$EMIT_X"; do
  if [ ! -f "$f" ]; then
    echo "core-mem-intrinsic gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in runnable XLANG_CORE_MEM_INTRINSIC mem_compare __builtin_memcmp; do
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

map_miss="$(core_mem_intrinsic_mappings_ok "$CODEGEN" "$MANIFEST" "$MEM_X" || true)"
if [ "${map_miss:-0}" -gt 0 ]; then
  core_mem_intrinsic_emit_report "fail" 0 "$MIN_MAP"
  echo "core-mem-intrinsic gate FAIL: mapping_miss=${map_miss}" >&2
  exit 1
fi
echo "core-mem-intrinsic manifest OK (mappings=${MIN_MAP} via pure .x)"

stdlib_cm_native_xlang() {
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
  for cand in ./compiler/xlang-c ./compiler/xlang; do
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  if [ -n "${XLANG:-}" ] && stdlib_cm_native_xlang "$XLANG"; then
    echo "$XLANG"
    return 0
  fi
  return 1
}

EMIT_TOTAL=4
if XLANG_BIN="$(resolve_emit_shu 2>/dev/null)"; then
  echo "=== CORE-008: XLANG_DEBUG_C emit observational + runnable (XLANG=$XLANG_BIN) ==="
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  found="$(core_mem_intrinsic_emit_ok "$XLANG_BIN" "$EMIT_X" "$MANIFEST" || true)"
  if [ "${found:-0}" -lt "$EMIT_TOTAL" ]; then
    echo "core-mem-intrinsic gate SKIP emit ${found:-0}/${EMIT_TOTAL} (__builtin_* table retired with codegen.c; pure .x)" >&2
  else
    echo "core-mem-intrinsic emit OK ${found}/${EMIT_TOTAL}"
  fi
  # Hard: -o runnable of mem smoke (pure .x path).
  if "$XLANG_BIN" -L . "$EMIT_X" -o /tmp/xlang_core_mem_intrinsic 2>/tmp/xlang_core_mem_intrinsic_build.log; then
    if /tmp/xlang_core_mem_intrinsic >/dev/null 2>&1; then
      core_mem_intrinsic_emit_report "ok" "${found:-0}" "$EMIT_TOTAL"
    else
      echo "core-mem-intrinsic gate FAIL: runnable non-zero exit" >&2
      exit 1
    fi
  else
    echo "core-mem-intrinsic gate FAIL: runnable -o" >&2
    tail -5 /tmp/xlang_core_mem_intrinsic_build.log 2>/dev/null >&2 || true
    exit 1
  fi
else
  echo "core-mem-intrinsic gate SKIP runnable (no xlang)" >&2
  core_mem_intrinsic_emit_report "ok" 0 "$EMIT_TOTAL"
fi

echo "core-mem-intrinsic gate OK"
