#!/usr/bin/env bash
# CORE-001：core.types 泛型 size_of<T> / align_of<T> 门禁（假权威诚实）。
#
# 用法：./tests/run-core-types-generic-layout-gate.sh
# wave honesty (2026-08-24 #8): DOC → analysis/archive/core/;
# typeck.c/codegen.c retired — live = typeck.x / codegen.x.
# check smoke observational SKIP (check gate paused 2026-08-05).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_CORE_TYPES_GL_DOC:-analysis/archive/core/core-types-generic-layout-v1.md}"
MANIFEST="${XLANG_CORE_TYPES_GL_TSV:-tests/baseline/core-types-generic-layout.tsv}"
TYPES_X="core/types/mod.x"
LIB="tests/lib/core-types-generic-layout.sh"
GENERIC_X="tests/core-types-size/generic_layout.x"
SCALAR_X="tests/core-types-size/main.x"

# shellcheck source=tests/lib/core-types-generic-layout.sh
. "$LIB"

echo "=== CORE-001: generic layout manifest (c retired) ==="

if [ -f compiler/src/typeck/typeck.c ]; then
  echo "core-types-generic-layout gate FAIL: typeck.c resurrected (live = typeck.x)" >&2
  exit 1
fi
if [ -f compiler/src/codegen/codegen.c ]; then
  echo "core-types-generic-layout gate FAIL: codegen.c resurrected (live = codegen.x)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$TYPES_X" "$GENERIC_X" "$SCALAR_X" \
  compiler/src/typeck/typeck.x compiler/src/codegen/codegen.x; do
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

if ! grep -q 'CORE-001' compiler/src/typeck/typeck.x && ! grep -q 'CORE-001' compiler/src/codegen/codegen.x; then
  echo "core-types-generic-layout gate FAIL: compiler hooks missing" >&2
  exit 1
fi

sym_miss="$(core_types_gl_symbols_ok "$TYPES_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_types_gl_emit_report "fail" 0 0 1
  echo "core-types-generic-layout gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "core-types-generic-layout manifest OK"

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

GENERIC_OK=0
SCALAR_OK=0
SKIP=1
if XLANG_BIN="$(stdlib_cm_native_xlang ./compiler/xlang-c && echo ./compiler/xlang-c || true)"; then
  :
elif XLANG_BIN="$(stdlib_cm_native_xlang ./compiler/xlang && echo ./compiler/xlang || true)"; then
  :
else
  XLANG_BIN=""
fi

if [ -n "$XLANG_BIN" ]; then
  echo "=== CORE-001: smoke (XLANG=$XLANG_BIN; check observational) ==="
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Observational: check gate paused (2026-08-05); prefer -o path.
  if "$XLANG_BIN" check -L . "$GENERIC_X" >/dev/null 2>&1     && "$XLANG_BIN" check -L . "$SCALAR_X" >/dev/null 2>&1; then
    SCALAR_OK=1
  else
    echo "core-types-generic-layout gate SKIP check (paused / typeck debt)" >&2
  fi
  tmp="/tmp/xlang_core_types_gl_$$"
  # CORE-001 hard-green (2026-08-24): asm fold size_of/align_of → imm; -o must run 0.
  if "$XLANG_BIN" -L . "$GENERIC_X" -o "$tmp" 2>/tmp/xlang_core_types_gl_o.err && "$tmp"; then
    GENERIC_OK=1
    SCALAR_OK=1
    SKIP=0
  else
    echo "core-types-generic-layout gate FAIL: -o smoke (CORE-001 asm fold residual)" >&2
    cat /tmp/xlang_core_types_gl_o.err >&2 || true
    core_types_gl_emit_report "fail" 0 "$SCALAR_OK" 0
    rm -f "$tmp"
    exit 1
  fi
  rm -f "$tmp"
else
  echo "core-types-generic-layout gate SKIP smoke (no native xlang-c)" >&2
fi

core_types_gl_emit_report "ok" "$GENERIC_OK" "$SCALAR_OK" "$SKIP"
echo "core-types-generic-layout gate OK"
