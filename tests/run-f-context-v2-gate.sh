#!/usr/bin/env bash
# F-context v2: node storage fully in context.x (context_node_glue.c deleted).
#
# Usage: ./tests/run-f-context-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-context-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-071 context hard delegate. Soft XLANG_F_CONTEXT_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/ctx=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-context-v2.md"
MANIFEST="tests/baseline/f-context-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_CONTEXT_V2]"

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
  echo "f-context-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} ctx=${CTX_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
CTX_OK=0
SKIP=1

echo "=== F-context v2: node storage → context.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-context v2' "$DOC" || die "doc missing F-context v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/context/context.x ] || die "missing context.x"
[ ! -f std/context/context_node_glue.c ] || die "context_node_glue.c should be deleted"
[ ! -f std/context/context.c ] || die "context.c should be deleted"

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
grep -q 'ctx_glue_background_c' std/context/context.x || die "context.x missing glue background"
grep -q 'ctx_glue_alloc_c' std/context/context.x || die "context.x missing glue alloc"
grep -q 'ctx_smoke_c' std/context/context.x || die "context.x missing smoke"
grep -q 'ctx_f_context_v2_marker_c' std/context/context.x || die "context.x missing v2 marker"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/context/context.o >/dev/null 2>&1 \
  || die "ensure context.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD-071.
# Do NOT export retired XLANG_F_CONTEXT_V2_FAIL.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-context-gate.sh ]; then
  echo "=== F-context v2: delegate run-std-context-gate (hard) ==="
  chmod +x tests/run-std-context-gate.sh
  if ! tests/run-std-context-gate.sh; then
    die "std-context sub-gate failed"
  fi
  CTX_OK=1
else
  die "missing tests/run-std-context-gate.sh"
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} ctx=${CTX_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-context-v2 gate OK (F-context v2; honesty)"
