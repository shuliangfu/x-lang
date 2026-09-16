#!/usr/bin/env bash
# F-schema v2: JSON/CSV typed decode in schema.x (schema_glue deleted).
#
# Usage: ./tests/run-f-schema-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-schema-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# Soft XLANG_F_SCHEMA_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green. STD-090 schema product residual
# (fossil schema_new / smoke) observational (listed skip).
# Report static=/ensure=/schema=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested std-schema; refuse leftover ignore of
# explicit-bad). leftover auto-make of schema.o (`xlang_compiler_make`
# even when the leaf is present — try-heat/g05 raced L2) retired.
# leftover unused compiler-make.sh sourced unused after leftover
# auto-make retired. Missing leaf .o = hard die. leftover nested
# std-schema stay.
# G.7: complete existing resolve_shu; converge dod_native_exe; do not
# fork a third resolver.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-schema-v2.md"
MANIFEST="tests/baseline/f-schema-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_SCHEMA_V2]"

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
  echo "f-schema-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} schema=${SCHEMA_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
SCHEMA_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested std-schema (refuse leftover SKIP→OK / leftover ignore
# of explicit-bad / leftover XLANG fallthrough). leftover auto-make of
# schema.o retired; leftover nested std-schema stay.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-schema v2: JSON/CSV decode → schema.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-schema v2' "$DOC" || die "doc missing F-schema v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/schema/schema.x ] || die "missing schema.x"
[ ! -f std/schema/schema_glue.c ] || die "schema_glue.c should be deleted"
[ ! -f std/schema/schema.c ] || die "schema.c should be deleted"

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
grep -q 'schema_create_c' std/schema/schema.x || die "schema.x missing create"
grep -q 'schema_decode_json_c' std/schema/schema.x || die "schema.x missing decode_json"
grep -q 'schema_smoke_c' std/schema/schema.x || die "schema.x missing smoke"
grep -q 'schema_f_schema_v2_marker_c' std/schema/schema.x || die "schema.x missing v2 marker"
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
if [ ! -f std/schema/schema.o ]; then
  die "missing std/schema/schema.o (refuse leftover auto-make)"
fi
ENSURE_OK=1

# Do NOT export retired XLANG_F_SCHEMA_V2_FAIL.
# STD-090: fossil schema_new / product smoke residual — observational.
# leftover nested std-schema stay (already Honesty; for cand without
# "${XLANG:-}"). PLATFORM: SHARED archaeology.
if [ -f tests/run-std-schema-gate.sh ]; then
  echo "=== F-schema v2: std-schema (observational; product residual) ==="
  chmod +x tests/run-std-schema-gate.sh
  if tests/run-std-schema-gate.sh; then
    SCHEMA_OK=1
  else
    echo "f-schema-v2 WARN: std-schema failed (observational)" >&2
    SCHEMA_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} schema=${SCHEMA_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-schema-v2 gate OK (F-schema v2; honesty)"
