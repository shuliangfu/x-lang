#!/usr/bin/env bash
# F-regex v2: engine fully in regex.x (regex_engine_glue + regex_min.inc deleted).
#
# Usage: ./tests/run-f-regex-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-regex-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# Soft XLANG_F_REGEX_V2_FAIL retired. Root: soft die→exit0 = portable false-green
# (static already green; STD-051 regex / atomic product residual listed skip —
# `_main` / typeck / prefer-c). STD regex＋atomic observational only.
# Report static=/ensure=/regex=/atomic=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested std-regex / leftover nested
# std-regex-atomic; refuse leftover ignore of explicit-bad). leftover
# auto-make of regex.o (`xlang_compiler_make` even when the leaf is
# present — try-heat/g05 raced L2) retired. leftover unused
# compiler-make.sh sourced unused after leftover auto-make retired.
# Missing leaf .o = hard die. leftover nested std-regex /
# std-regex-atomic stay.
# G.7: complete existing resolve_shu; converge dod_native_exe; do not
# fork a third resolver.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-regex-v2.md"
MANIFEST="tests/baseline/f-regex-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_REGEX_V2]"

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
  echo "f-regex-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} regex=${REGEX_OK:-0} atomic=${ATOMIC_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
REGEX_OK=0
ATOMIC_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested std-regex / leftover nested std-regex-atomic (refuse
# leftover SKIP→OK / leftover ignore of explicit-bad / leftover XLANG
# fallthrough). leftover auto-make of regex.o retired; leftover nested
# std-regex / std-regex-atomic stay.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-regex v2: engine → regex.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-regex v2' "$DOC" || die "doc missing F-regex v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/regex/regex.x ] || die "missing regex.x"
[ ! -f std/regex/regex_engine_glue.c ] || die "regex_engine_glue.c should be deleted"
[ ! -f std/regex/regex_min.inc.c ] || die "regex_min.inc.c should be deleted"

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
grep -q 'regex_compile_c' std/regex/regex.x || die "regex.x missing compile"
grep -q 'regex_min_smoke_c' std/regex/regex.x || die "regex.x missing smoke"
grep -q 'regex_f_regex_v2_marker_c' std/regex/regex.x || die "regex.x missing v2 marker"
grep -q 'atomic_nest' std/regex/regex.x || die "regex.x missing atomic_nest"
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

# leftover auto-make retired: require the leaf already present (refuse try-heat/g05).
# PLATFORM: SHARED — missing leaf = hard die; Ubuntu gold still required.
if [ ! -f std/regex/regex.o ]; then
  die "missing std/regex/regex.o (refuse leftover auto-make)"
fi
ENSURE_OK=1

# Do NOT export retired XLANG_F_REGEX_V2_FAIL.
# Product residual (listed skip encoding-extra／regex／net-tls): observational.
# leftover nested std-regex / std-regex-atomic stay (already Honesty;
# for cand without "${XLANG:-}"). PLATFORM: SHARED archaeology.
if [ -f tests/run-std-regex-gate.sh ]; then
  echo "=== F-regex v2: std-regex (observational; product residual) ==="
  chmod +x tests/run-std-regex-gate.sh
  if tests/run-std-regex-gate.sh; then
    REGEX_OK=1
  else
    echo "f-regex-v2 WARN: std-regex failed (observational)" >&2
    REGEX_OK=0
  fi
fi

if [ -f tests/run-std-regex-atomic-gate.sh ]; then
  echo "=== F-regex v2: std-regex-atomic (observational; product residual) ==="
  chmod +x tests/run-std-regex-atomic-gate.sh
  if tests/run-std-regex-atomic-gate.sh; then
    ATOMIC_OK=1
  else
    echo "f-regex-v2 WARN: std-regex-atomic failed (observational)" >&2
    ATOMIC_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} regex=${REGEX_OK} atomic=${ATOMIC_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-regex-v2 gate OK (F-regex v2; honesty)"
