#!/usr/bin/env bash
# CORE-001：core.types 泛型 size_of<T> / align_of<T> 门禁
#
# 用法：./tests/run-core-types-generic-layout-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_CORE_TYPES_GL_DOC:-analysis/core-types-generic-layout-v1.md}"
MANIFEST="${SHUX_CORE_TYPES_GL_TSV:-tests/baseline/core-types-generic-layout.tsv}"
TYPES_SU="core/types/mod.sx"
LIB="tests/lib/core-types-generic-layout.sh"
GENERIC_SU="tests/core-types-size/generic_layout.sx"
SCALAR_SU="tests/core-types-size/main.sx"

# shellcheck source=tests/lib/core-types-generic-layout.sh
. "$LIB"

echo "=== CORE-001: generic layout manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$TYPES_SU" "$GENERIC_SU" "$SCALAR_SU" \
  compiler/src/typeck/typeck.c compiler/src/codegen/codegen.c; do
  if [ ! -f "$f" ]; then
    echo "core-types-generic-layout gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in size_of align_of compile-time Pair generic_layout; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-types-generic-layout gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -q 'CORE-001' compiler/src/typeck/typeck.c && ! grep -q 'CORE-001' compiler/src/codegen/codegen.c; then
  echo "core-types-generic-layout gate FAIL: compiler hooks missing" >&2
  exit 1
fi

sym_miss="$(core_types_gl_symbols_ok "$TYPES_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_types_gl_emit_report "fail" 0 0 1
  echo "core-types-generic-layout gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "core-types-generic-layout manifest OK"

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

GENERIC_OK=0
SCALAR_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== CORE-001: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$GENERIC_SU" >/dev/null 2>&1; then
    echo "core-types-generic-layout gate FAIL: typeck $GENERIC_SU" >&2
    "$SHUX_BIN" check -L . "$GENERIC_SU" 2>&1 | tail -10 >&2 || true
    core_types_gl_emit_report "fail" 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SCALAR_SU" >/dev/null 2>&1; then
    echo "core-types-generic-layout gate FAIL: typeck $SCALAR_SU" >&2
    core_types_gl_emit_report "fail" 0 0 0
    exit 1
  fi
  SCALAR_OK=1
  tmp="/tmp/shux_core_types_gl_$$"
  if "$SHUX_BIN" -L . "$GENERIC_SU" -o "$tmp" && "$tmp"; then
    GENERIC_OK=1
  else
    echo "core-types-generic-layout gate FAIL: generic_layout smoke" >&2
    core_types_gl_emit_report "fail" 0 "$SCALAR_OK" 0
    exit 1
  fi
  rm -f "$tmp"
  SKIP=0
else
  echo "core-types-generic-layout gate SKIP smoke (no native shux-c)" >&2
fi

core_types_gl_emit_report "ok" "$GENERIC_OK" "$SCALAR_OK" "$SKIP"
echo "core-types-generic-layout gate OK"
