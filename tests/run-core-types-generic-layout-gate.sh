#!/usr/bin/env bash
# CORE-001: core.types generic size_of<T> / align_of<T> gate.
#
# Honesty: soft prefer-c (xlang-c before asm) + soft auto-make of xlang-c +
# soft SKIP→OK when no native (false authority) retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make / prefer-c). Check path
# = obs= (check gate paused 2026-08-05). Product `-o` generic_layout must
# exit 0. Report: run=/obs=/skip=
# Usage: ./tests/run-core-types-generic-layout-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_CORE_TYPES_GL_DOC:-analysis/archive/core/core-types-generic-layout-v1.md}"
MANIFEST="${XLANG_CORE_TYPES_GL_TSV:-tests/baseline/core-types-generic-layout.tsv}"
TYPES_X="core/types/mod.x"
LIB="tests/lib/core-types-generic-layout.sh"
GENERIC_X="tests/core-types-size/generic_layout.x"
SCALAR_X="tests/core-types-size/main.x"

# shellcheck source=tests/lib/core-types-generic-layout.sh
. "$LIB"

PREFIX="${XLANG_CORE_TYPES_GL_PREFIX:-xlang: [XLANG_CORE_TYPES_GL]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "core-types-generic-layout FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== CORE-001: generic layout (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="

if [ -f compiler/src/typeck/typeck.c ]; then
  die "typeck.c resurrected (live = typeck.x)"
fi
if [ -f compiler/src/codegen/codegen.c ]; then
  die "codegen.c resurrected (live = codegen.x)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$TYPES_X" "$GENERIC_X" "$SCALAR_X" \
  compiler/src/typeck/typeck.x compiler/src/codegen/codegen.x; do
  [ -f "$f" ] || die "missing $f"
done

for kw in size_of align_of compile-time Pair generic_layout; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

if ! grep -q 'CORE-001' compiler/src/typeck/typeck.x && ! grep -q 'CORE-001' compiler/src/codegen/codegen.x; then
  die "compiler hooks missing (CORE-001)"
fi

sym_miss="$(core_types_gl_symbols_ok "$TYPES_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_types_gl_emit_report "fail" 0 0 0
  die "symbol_miss=${sym_miss}"
fi
echo "core-types-generic-layout manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Observational check (paused) — never soft SKIP→OK / never soft auto-make.
if "$XLANG_BIN" check -L . "$GENERIC_X" >/dev/null 2>&1 \
  && "$XLANG_BIN" check -L . "$SCALAR_X" >/dev/null 2>&1; then
  :
else
  echo "core-types-generic-layout OBS: check residual (paused; refuse soft silence)" >&2
  OBS=$((OBS + 1))
fi

tmp="/tmp/xlang_core_types_gl_$$"
trap 'rm -f "$tmp"' EXIT
# CORE-001 hard-green: asm fold size_of/align_of → imm; -o must run 0.
if ! "$XLANG_BIN" -L . "$GENERIC_X" -o "$tmp" 2>/tmp/xlang_core_types_gl_o.err; then
  cat /tmp/xlang_core_types_gl_o.err >&2 || true
  core_types_gl_emit_report "fail" 0 0 0
  die "-o smoke link failed (CORE-001 asm fold residual)"
fi
if ! "$tmp"; then
  core_types_gl_emit_report "fail" 0 0 0
  die "-o smoke run failed (CORE-001)"
fi

RUN_OK=$((RUN_OK + 1))
core_types_gl_emit_report "ok" 1 1 0
echo "core-types-generic-layout gate OK"
ok_report
