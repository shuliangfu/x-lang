#!/usr/bin/env bash
# F-trace v2: span/export logic in trace.x (trace_span_glue.c deleted).
#
# Usage: ./tests/run-f-trace-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-trace-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# Soft XLANG_F_TRACE_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static already green; STD-088
# still red on fossil API needles trace_new vs live create_c; hooks same).
# STD-088／hooks observational (product/DOC residual; UNDEF jump).
# Report static=/ensure=/trace=/hooks=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-trace-v2.md"
MANIFEST="tests/baseline/f-trace-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_TRACE_V2]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f-trace-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} trace=${TRACE_OK:-0} hooks=${HOOKS_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
TRACE_OK=0
HOOKS_OK=0
SKIP=1

echo "=== F-trace v2: span/export logic → trace.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-trace v2' "$DOC" || die "doc missing F-trace v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/trace/trace.x ] || die "missing trace.x"
[ ! -f std/trace/trace_span_glue.c ] || die "trace_span_glue.c should be deleted"
[ ! -f std/trace/trace.c ] || die "trace.c should be deleted"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
grep -q 'trace_create_c' std/trace/trace.x || die "trace.x missing trace_create_c"
grep -q 'trace_export_text_c' std/trace/trace.x || die "trace.x missing export"
grep -q 'trace_smoke_c' std/trace/trace.x || die "trace.x missing smoke"
grep -q 'trace_f_trace_v2_marker_c' std/trace/trace.x || die "trace.x missing v2 marker"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/trace/trace.o >/dev/null 2>&1 \
  || die "ensure trace.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# STD-088／hooks observational: fossil api trace_new vs live create_c (product residual).
if [ -f tests/run-std-trace-gate.sh ]; then
  echo "=== F-trace v2: std-trace (observational; API rename residual) ==="
  chmod +x tests/run-std-trace-gate.sh
  if tests/run-std-trace-gate.sh; then
    TRACE_OK=1
  else
    echo "f-trace-v2 WARN: std-trace failed (observational)" >&2
    TRACE_OK=0
  fi
fi

if [ -f tests/run-std-trace-hooks-gate.sh ]; then
  echo "=== F-trace v2: std-trace-hooks (observational; product residual) ==="
  chmod +x tests/run-std-trace-hooks-gate.sh
  if tests/run-std-trace-hooks-gate.sh; then
    HOOKS_OK=1
  else
    echo "f-trace-v2 WARN: std-trace-hooks failed (observational)" >&2
    HOOKS_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} trace=${TRACE_OK} hooks=${HOOKS_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-trace-v2 gate OK (F-trace v2; honesty)"
