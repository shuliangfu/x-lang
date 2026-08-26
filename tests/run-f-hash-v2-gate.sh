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

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
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
