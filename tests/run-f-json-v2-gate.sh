#!/usr/bin/env bash
# F-json v2: parse/cursor/serialize in json.x (json_parse_glue deleted).
#
# Usage: ./tests/run-f-json-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-json-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-008 json + object-array + serialize hard delegate. Soft XLANG_F_JSON_V2_FAIL
# retired. Root: soft die→exit0 = portable false-green (static+STD-008 already
# green). typed-decode product residual observational (listed skip).
# Report static=/ensure=/json=/oa=/ser=/typed=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested xlang_compiler_make / leftover nested
# std-json / leftover nested std-json-object-array / leftover nested
# std-json-serialize / leftover nested std-json-typed-decode; refuse
# leftover ignore of explicit-bad). leftover nested product path stay.
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

DOC="analysis/archive/phase/phase-f-json-v2.md"
MANIFEST="tests/baseline/f-json-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_JSON_V2]"

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
  echo "f-json-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} json=${JSON_OK:-0} oa=${OA_OK:-0} ser=${SER_OK:-0} typed=${TYPED_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
JSON_OK=0
OA_OK=0
SER_OK=0
TYPED_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested ensure / leftover nested std-json family (refuse leftover
# SKIP→OK / leftover ignore of explicit-bad / leftover XLANG
# fallthrough). leftover nested product path stays when XLANG is unset
# (do not rewrite leftover xlang_compiler_make / std-json /
# std-json-object-array / std-json-serialize / std-json-typed-decode).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-json v2: json logic → json.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-json v2' "$DOC" || die "doc missing F-json v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/json/json.x ] || die "missing json.x"
[ ! -f std/json/json_parse_glue.c ] || die "json_parse_glue.c should be deleted"

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
grep -q 'json_parse_number_c' std/json/json.x || die "json.x missing parse_number"
grep -q 'json_typed_decode_smoke_c' std/json/json.x || die "json.x missing typed smoke"
grep -q 'json_parse_string_view_c' std/json/json.x || die "json.x missing string view"
grep -q 'json_f_json_v2_marker_c' std/json/json.x || die "json.x missing v2 marker"
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

xlang_compiler_make ../std/json/json.o >/dev/null 2>&1 \
  || die "ensure json.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Do NOT export retired XLANG_F_JSON_V2_FAIL.
# STD-008 json already soft→硬绿; hard-delegate as product signal.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-json-gate.sh ]; then
  echo "=== F-json v2: delegate run-std-json-gate (hard) ==="
  chmod +x tests/run-std-json-gate.sh
  if ! tests/run-std-json-gate.sh; then
    die "std-json sub-gate failed"
  fi
  JSON_OK=1
else
  die "missing tests/run-std-json-gate.sh"
fi

if [ -f tests/run-std-json-object-array-gate.sh ]; then
  echo "=== F-json v2: delegate run-std-json-object-array-gate (hard) ==="
  chmod +x tests/run-std-json-object-array-gate.sh
  if ! tests/run-std-json-object-array-gate.sh; then
    die "std-json-object-array sub-gate failed"
  fi
  OA_OK=1
else
  die "missing tests/run-std-json-object-array-gate.sh"
fi

if [ -f tests/run-std-json-serialize-gate.sh ]; then
  echo "=== F-json v2: delegate run-std-json-serialize-gate (hard) ==="
  chmod +x tests/run-std-json-serialize-gate.sh
  if ! tests/run-std-json-serialize-gate.sh; then
    die "std-json-serialize sub-gate failed"
  fi
  SER_OK=1
else
  die "missing tests/run-std-json-serialize-gate.sh"
fi

# Product residual (listed skip): typed-decode — observational only.
if [ -f tests/run-std-json-typed-decode-gate.sh ]; then
  echo "=== F-json v2: std-json-typed-decode (observational; product residual) ==="
  chmod +x tests/run-std-json-typed-decode-gate.sh
  if tests/run-std-json-typed-decode-gate.sh; then
    TYPED_OK=1
  else
    echo "f-json-v2 WARN: std-json-typed-decode failed (observational)" >&2
    TYPED_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} json=${JSON_OK} oa=${OA_OK} ser=${SER_OK} typed=${TYPED_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-json-v2 gate OK (F-json v2; honesty)"
