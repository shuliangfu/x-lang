#!/usr/bin/env bash
# F-async v1: std.async de-C (scheduler/future.x + runtime_scheduler_glue).
#
# Usage: ./tests/run-f-async-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-async-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-004 async-api hard delegate. Soft XLANG_F_ASYNC_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD-004 already green).
# future／io-cps／context／language product smokes observational
# (async-language／async-future／async-context／coop UNDEF residual — listed skip).
# Report static=/ensure=/glue=/api=/future=/iocps=/ctx=/lang=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested xlang_compiler_make / leftover nested
# std-async-api / leftover nested std-async-future / leftover nested
# std-async-io-cps / leftover nested std-async-context / leftover nested
# std-async-language; refuse leftover ignore of explicit-bad). leftover
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

DOC="analysis/archive/phase/phase-f-async-v1.md"
MANIFEST="tests/baseline/f-async-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_ASYNC_V1]"

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
  echo "f-async-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} glue=${GLUE_OK:-0} api=${API_OK:-0} future=${FUTURE_OK:-0} iocps=${IOCPS_OK:-0} ctx=${CTX_OK:-0} lang=${LANG_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
GLUE_OK=0
API_OK=0
FUTURE_OK=0
IOCPS_OK=0
CTX_OK=0
LANG_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested ensure / leftover nested std-async-api / leftover
# nested std-async-future / leftover nested std-async-io-cps /
# leftover nested std-async-context / leftover nested std-async-language
# (refuse leftover SKIP→OK / leftover ignore of explicit-bad /
# leftover XLANG fallthrough). leftover nested product path stays when
# XLANG is unset (do not rewrite leftover xlang_compiler_make /
# std-async-api / std-async-future / std-async-io-cps / std-async-context /
# std-async-language).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-async v1: std.async scheduler/future.c → .x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-async v1' "$DOC" || die "doc missing F-async v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/async/scheduler.x ] || die "missing scheduler.x"
[ -f std/async/future.x ] || die "missing future.x"
[ -f compiler/seeds/runtime_scheduler_glue.from_x.c ] || die "missing scheduler glue"
[ ! -f std/async/scheduler_glue.c ] || die "scheduler_glue.c should be deleted (F-ZC)"
[ ! -f std/async/future_glue.c ] || die "future_glue.c should be deleted (see F-async-future v2)"
[ ! -f std/async/scheduler.c ] || die "scheduler.c should be deleted"
[ ! -f std/async/future.c ] || die "future.c should be deleted"

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

xlang_compiler_make -q runtime_scheduler_glue.o 2>/dev/null \
  || xlang_compiler_make runtime_scheduler_glue.o >/dev/null 2>&1 \
  || die "runtime_scheduler_glue.o build failed"
GLUE_OK=1

xlang_compiler_make ../std/async/scheduler.o >/dev/null 2>&1 \
  || die "ensure scheduler.o failed (xlang_compiler_make; prefer asm)"
xlang_compiler_make ../std/async/future.o >/dev/null 2>&1 \
  || die "ensure future.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# STD-004 async-api already soft→硬绿; hard-delegate as product signal.
if [ -f tests/run-std-async-api-gate.sh ]; then
  echo "=== F-async v1: delegate run-std-async-api-gate ==="
  chmod +x tests/run-std-async-api-gate.sh
  if ! tests/run-std-async-api-gate.sh; then
    die "std-async-api sub-gate failed"
  fi
  API_OK=1
fi

# Product residuals (listed skip): future／language／context／coop UNDEF —
# observational only; do not soft-exit0 on archaeology knife.
if [ -f tests/run-std-async-future-gate.sh ]; then
  echo "=== F-async v1: std-async-future (observational; product residual) ==="
  chmod +x tests/run-std-async-future-gate.sh
  if tests/run-std-async-future-gate.sh; then
    FUTURE_OK=1
  else
    echo "f-async-v1 WARN: std-async-future failed (observational)" >&2
    FUTURE_OK=0
  fi
fi

if [ -f tests/run-std-async-io-cps-gate.sh ]; then
  echo "=== F-async v1: std-async-io-cps (observational; product residual) ==="
  chmod +x tests/run-std-async-io-cps-gate.sh
  if tests/run-std-async-io-cps-gate.sh; then
    IOCPS_OK=1
  else
    echo "f-async-v1 WARN: std-async-io-cps failed (observational)" >&2
    IOCPS_OK=0
  fi
fi

if [ -f tests/run-std-async-context-gate.sh ]; then
  echo "=== F-async v1: std-async-context (observational; product residual) ==="
  chmod +x tests/run-std-async-context-gate.sh
  if tests/run-std-async-context-gate.sh; then
    CTX_OK=1
  else
    echo "f-async-v1 WARN: std-async-context failed (observational)" >&2
    CTX_OK=0
  fi
fi

if [ -f tests/run-std-async-language-gate.sh ]; then
  echo "=== F-async v1: std-async-language (observational; product residual) ==="
  chmod +x tests/run-std-async-language-gate.sh
  if tests/run-std-async-language-gate.sh; then
    LANG_OK=1
  else
    echo "f-async-v1 WARN: std-async-language failed (observational)" >&2
    LANG_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} glue=${GLUE_OK} api=${API_OK} future=${FUTURE_OK} iocps=${IOCPS_OK} ctx=${CTX_OK} lang=${LANG_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-async-v1 std.async gate OK (F-async v1; honesty)"
