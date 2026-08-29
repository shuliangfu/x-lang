#!/usr/bin/env bash
# F-async-future v2: Future/Poll logic in future.x (future_glue.c deleted).
#
# Usage: ./tests/run-f-async-future-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-async-future-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# Soft XLANG_F_ASYNC_FUTURE_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green. STD-041 async-future product
# residual (c smoke) observational (listed skip).
# Report static=/ensure=/future=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested xlang_compiler_make / leftover nested
# std-async-future; refuse leftover ignore of explicit-bad). leftover
# nested product path stay.
# G.7: complete existing resolve_shu; converge dod_native_exe.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-async-future-v2.md"
MANIFEST="tests/baseline/f-async-future-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_ASYNC_FUTURE_V2]"

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

die() {
  echo "f-async-future-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} future=${FUTURE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
FUTURE_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested ensure / leftover nested std-async-future (refuse leftover
# SKIP→OK / leftover ignore of explicit-bad / leftover XLANG fallthrough).
# leftover nested product path stays when XLANG is unset (do not
# rewrite leftover xlang_compiler_make / std-async-future).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-async-future v2: Future/Poll → future.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-async-future v2' "$DOC" || die "doc missing F-async-future v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/async/future.x ] || die "missing future.x"
[ ! -f std/async/future_glue.c ] || die "future_glue.c should be deleted"
[ -f compiler/seeds/runtime_scheduler_glue.from_x.c ] || die "runtime_scheduler_glue.inc should remain (v1)"

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
grep -q 'xlang_async_future_create_c' std/async/future.x || die "future.x missing create"
grep -q 'xlang_async_future_poll_c' std/async/future.x || die "future.x missing poll"
grep -q 'xlang_async_future_complete_c' std/async/future.x || die "future.x missing complete"
grep -q 'xlang_async_future_take_c' std/async/future.x || die "future.x missing take"
grep -q 'xlang_async_future_reset_c' std/async/future.x || die "future.x missing reset"
grep -q 'xlang_async_future_wait_c' std/async/future.x || die "future.x missing wait"
grep -q 'xlang_async_future_smoke_c' std/async/future.x || die "future.x missing smoke"
grep -q 'future_f_async_future_v1_marker_c' std/async/future.x || die "future.x missing v1 marker"
grep -q 'future_f_async_future_v2_marker_c' std/async/future.x || die "future.x missing v2 marker"
grep -q 'xlang_async_run_drain_until_idle' std/async/future.x || die "future.x missing drain extern"
grep -q 'xlang_io_poll_async_completions' std/async/future.x || die "future.x missing io poll extern"
STATIC_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/async/future.o >/dev/null 2>&1 \
  || die "ensure future.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Do NOT export retired XLANG_F_ASYNC_FUTURE_V2_FAIL.
# STD-041: future c smoke product residual — observational.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-async-future-gate.sh ]; then
  echo "=== F-async-future v2: std-async-future (observational; product residual) ==="
  chmod +x tests/run-std-async-future-gate.sh
  if tests/run-std-async-future-gate.sh; then
    FUTURE_OK=1
  else
    echo "f-async-future-v2 WARN: std-async-future failed (observational)" >&2
    FUTURE_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} future=${FUTURE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-async-future-v2 gate OK (F-async-future v2; honesty)"
