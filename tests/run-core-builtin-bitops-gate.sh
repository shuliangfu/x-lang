#!/usr/bin/env bash
# CORE-009：core.builtin clz/ctz/popcount 内建门禁（G-01：纯 .sx，无 builtin.c）
#
# 用法：./tests/run-core-builtin-bitops-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_CORE_BUILTIN_DOC:-analysis/core-builtin-bitops-v1.md}"
MANIFEST="${SHUX_CORE_BUILTIN_TSV:-tests/baseline/core-builtin-bitops.tsv}"
CODEGEN="compiler/src/codegen/codegen.c"
BUILTIN_SX="core/builtin/mod.sx"
LIB="tests/lib/core-builtin-bitops.sh"
EMIT_SX="tests/builtin/main.sx"
MIN_MAP=3
PREFIX="shux: [SHUX_CORE_BUILTIN_BITOPS]"

# shellcheck source=tests/lib/core-builtin-bitops.sh
. tests/lib/core-builtin-bitops.sh

echo "=== CORE-009: core.builtin bitops manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$CODEGEN" "$BUILTIN_SX" "$EMIT_SX"; do
  if [ ! -f "$f" ]; then
    echo "core-builtin-bitops gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in __builtin_clz clz_u32 popcount_u32; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-builtin-bitops gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_mappings) MIN_MAP="$c2" ;;
  esac
done < "$MANIFEST"

map_miss="$(core_builtin_mappings_ok "$CODEGEN" "$MANIFEST" || true)"
sx_miss="$(core_builtin_sx_impl_ok "$BUILTIN_SX" || true)"
if [ "${map_miss:-0}" -gt 0 ] || [ "${sx_miss:-0}" -gt 0 ]; then
  core_builtin_emit_report "fail" 0 "$MIN_MAP"
  echo "core-builtin-bitops gate FAIL: mapping_miss=${map_miss:-0} sx_miss=${sx_miss:-0}" >&2
  exit 1
fi
echo "core-builtin-bitops manifest OK"

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
  for cand in ./compiler/shux-c ./compiler/shux; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

EMIT_TOTAL=3
if SHUX_BIN="$(resolve_emit_shu 2>/dev/null)"; then
  echo "=== CORE-009: SHUX_DEBUG_C emit (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  found="$(core_builtin_emit_ok "$SHUX_BIN" "$EMIT_SX" "$MANIFEST" || true)"
  if [ "${found:-0}" -lt "$EMIT_TOTAL" ]; then
    core_builtin_emit_report "fail" "${found:-0}" "$EMIT_TOTAL"
    echo "core-builtin-bitops gate FAIL: emit ${found:-0}/${EMIT_TOTAL}" >&2
    exit 1
  fi
  core_builtin_emit_report "ok" "$found" "$EMIT_TOTAL"
  echo "=== CORE-009: runnable builtin smoke ==="
  chmod +x tests/run-builtin.sh
  ./tests/run-builtin.sh
else
  echo "core-builtin-bitops gate SKIP runnable (no shux)" >&2
fi

echo "core-builtin-bitops gate OK"
