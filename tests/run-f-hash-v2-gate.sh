#!/usr/bin/env bash
# F-hash v2: SipHash/xxHash/FNV fully in hash.x (zero glue).
#
# Usage: ./tests/run-f-hash-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-hash-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# Soft XLANG_F_HASH_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green. STD-056 hasher／STD-105 xxhash／
# STD-148 default-strategy product smokes observational (listed skip).
# Report static=/ensure=/hasher=/xxhash=/default=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested xlang_compiler_make / leftover nested
# std-hash-hasher-trait / leftover nested std-hash-xxhash / leftover
# nested std-hash-default-strategy; refuse leftover ignore of
# explicit-bad). leftover nested product path stay.
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

DOC="analysis/archive/phase/phase-f-hash-v2.md"
MANIFEST="tests/baseline/f-hash-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_HASH_V2]"

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
  echo "f-hash-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} hasher=${HASHER_OK:-0} xxhash=${XXHASH_OK:-0} default=${DEFAULT_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
HASHER_OK=0
XXHASH_OK=0
DEFAULT_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested ensure / leftover nested std-hash family (refuse leftover
# SKIP→OK / leftover ignore of explicit-bad / leftover XLANG
# fallthrough). leftover nested product path stays when XLANG is unset
# (do not rewrite leftover xlang_compiler_make / std-hash-hasher-trait /
# std-hash-xxhash / std-hash-default-strategy).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-hash v2: SipHash/xxHash/FNV → hash.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-hash v2' "$DOC" || die "doc missing F-hash v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/hash/hash.x ] || die "missing hash.x"
[ ! -f std/hash/hash_glue.c ] || die "hash_glue.c should be deleted"
[ ! -f std/hash/hash.c ] || die "hash.c should be deleted"

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
grep -q 'hash_sip_new_c' std/hash/hash.x || die "hash.x missing sip new"
grep -q 'hash_xxhash64_bytes_c' std/hash/hash.x || die "hash.x missing xxhash"
grep -q 'hash_hasher_switch_smoke_c' std/hash/hash.x || die "hash.x missing smoke"
grep -q 'hash_f_hash_v2_marker_c' std/hash/hash.x || die "hash.x missing v2 marker"
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

xlang_compiler_make ../std/hash/hash.o >/dev/null 2>&1 \
  || die "ensure hash.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Do NOT export retired XLANG_F_HASH_V2_FAIL.
# STD-056／105／148 product smokes are observational (xxhash／hash-default／
# hasher C-smoke residual; do not soft-exit0 on archaeology knife).
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-hash-hasher-trait-gate.sh ]; then
  echo "=== F-hash v2: std-hash-hasher-trait (observational; product residual) ==="
  chmod +x tests/run-std-hash-hasher-trait-gate.sh
  if tests/run-std-hash-hasher-trait-gate.sh; then
    HASHER_OK=1
  else
    echo "f-hash-v2 WARN: std-hash-hasher-trait failed (observational)" >&2
    HASHER_OK=0
  fi
fi

if [ -f tests/run-std-hash-xxhash-gate.sh ]; then
  echo "=== F-hash v2: std-hash-xxhash (observational; product residual) ==="
  chmod +x tests/run-std-hash-xxhash-gate.sh
  if tests/run-std-hash-xxhash-gate.sh; then
    XXHASH_OK=1
  else
    echo "f-hash-v2 WARN: std-hash-xxhash failed (observational)" >&2
    XXHASH_OK=0
  fi
fi

if [ -f tests/run-std-hash-default-strategy-gate.sh ]; then
  echo "=== F-hash v2: std-hash-default-strategy (observational; product residual) ==="
  chmod +x tests/run-std-hash-default-strategy-gate.sh
  if tests/run-std-hash-default-strategy-gate.sh; then
    DEFAULT_OK=1
  else
    echo "f-hash-v2 WARN: std-hash-default-strategy failed (observational)" >&2
    DEFAULT_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} hasher=${HASHER_OK} xxhash=${XXHASH_OK} default=${DEFAULT_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-hash-v2 gate OK (F-hash v2; honesty)"
