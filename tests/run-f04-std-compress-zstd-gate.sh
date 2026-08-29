#!/usr/bin/env bash
# F-04 v7: std.compress zstd remove zstd.c + compress.o retire.
#
# Usage: ./tests/run-f04-std-compress-zstd-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-compress-zstd-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory + STD-007 compress
# (no soft die→exit0). Soft XLANG_F04_COMPRESS_ZSTD_FAIL retired. Prefer asm;
# pin XLANG_LINK_XLANG. brotli/zstd stream smoke is observational (product-red
# residual — not soft false-green; do not die). Report
# static=/inventory=/compress=/bz_stream=/skip=. Gate was portable-false-green
# (DOC still pointed at top-level analysis/phase-f-f04-v7.md after archive
# move; soft FAIL printed then exit0 while static checks already green).
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# inventory / nested run-std-compress / brotli-zstd-stream observational;
# refuse leftover ignore of explicit-bad). leftover nested product path
# (inventory / STD-007 compress / brotli-zstd-stream observational) stay.
# G.7: complete existing resolve_shu; converge dod_native_exe.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F04_ZSTD_DOC:-analysis/archive/phase/phase-f-f04-v7.md}"
MANIFEST="tests/baseline/f04-std-compress-zstd.tsv"
ZSTD_LIB="std/compress/zstd/lib.x"
ZSTD_MOD="std/compress/zstd/mod.x"
PREFIX="xlang: [XLANG_F04_ZSTD]"

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
  echo "f04-compress-zstd gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} compress=${COMPRESS_OK:-0} bz_stream=${BZ_STREAM_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
COMPRESS_OK=0
BZ_STREAM_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE inventory /
# nested run-std-compress / brotli-zstd-stream observational (refuse leftover
# SKIP→OK / leftover ignore of explicit-bad / leftover XLANG fallthrough).
# leftover nested product path stays when XLANG is unset (do not rewrite
# leftover inventory / STD-007 compress / brotli-zstd-stream observational).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-04 v7: std.compress zstd remove zstd.c + retire compress.o (honesty) ==="
# Drop stale build residue (F-04 v7 no longer produces compress.o by default).
# PLATFORM: SHARED archaeology — file may reappear via formal_mod fossil ensure.
rm -f std/compress/compress.o std/compress/zstd/zstd.o std/compress/gzip/gzip.o std/compress/brotli/brotli.o 2>/dev/null || true

[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v7' "$DOC" || die "doc missing F-04 v7 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$ZSTD_LIB" ] || die "missing lib.x"
[ -f "$ZSTD_MOD" ] || die "missing mod.x"
[ ! -f std/compress/zstd/zstd.c ] || die "zstd.c should be deleted"
grep -q 'compress_zstd_compress_c' "$ZSTD_LIB" || die "zstd_lib missing compress_zstd_compress_c"
grep -q 'compress_zstd_stream_compress_c' "$ZSTD_LIB" || die "zstd_lib missing stream compress"
grep -q 'xlang_compress_zstd_marker' "$ZSTD_LIB" || die "zstd_lib missing marker"
grep -q 'import("std.compress.zstd.lib")' "$ZSTD_MOD" || die "mod.x missing lib import"
if grep -q 'extern function compress_zstd_compress_c' "$ZSTD_MOD" 2>/dev/null; then
  die "mod.x still extern compress_zstd_compress_c"
fi
grep -q 'link_abi_user_o_needs_compress_libs' compiler/seeds/runtime_link_abi.from_x.c \
  || die "missing compress user_o link helper"

# Manifest: symbol / target / absent rows (honesty TSV).
# PLATFORM: SHARED archaeology.
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    symbol)
      target="$ZSTD_LIB"
      case "$mod_path" in
        std/compress/zstd/mod.x) target="$ZSTD_MOD" ;;
      esac
      grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
      ;;
    target)
      # Post-MF phys-del: compress-o-* hub no-ops in compiler-make.sh (G.7).
      grep -qF "$anchor" "${mod_path:-tests/lib/compiler-make.sh}" \
        || die "manifest missing hub phony $anchor"
      ;;
    absent)
      case "$anchor" in
        std/compress/compress.o)
          [ ! -f "$anchor" ] || die "compress.o should not be built by default: $anchor"
          ;;
        *)
          [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
          ;;
      esac
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
echo "f04-zstd manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v7: delegate run-std-c-inventory-gate (F-01; hard) ==="
chmod +x tests/run-std-c-inventory-gate.sh
if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory sub-gate failed"
fi
INVENTORY_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
echo "=== F-04 v7: STD-007 compress (XLANG=$XLANG_BIN; hard) ==="
# Pin product link to resolved compiler (prefer asm).
# PLATFORM: SHARED — product path honesty.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
if [ ! -f tests/run-std-compress-gate.sh ]; then
  die "missing tests/run-std-compress-gate.sh"
fi
chmod +x tests/run-std-compress-gate.sh
if ! tests/run-std-compress-gate.sh; then
  die "std-compress sub-gate failed"
fi
COMPRESS_OK=1

if [ ! -f tests/run-std-compress-brotli-zstd-stream-gate.sh ]; then
  die "missing tests/run-std-compress-brotli-zstd-stream-gate.sh"
fi
echo "=== F-04 v7: brotli/zstd stream (observational; product-red residual) ==="
chmod +x tests/run-std-compress-brotli-zstd-stream-gate.sh
# Observational: brotli/zstd stream product residual — not soft; do not die archaeology.
if tests/run-std-compress-brotli-zstd-stream-gate.sh; then
  BZ_STREAM_OK=1
else
  echo "f04-zstd gate SKIP brotli-zstd-stream (observational; product-red residual)" >&2
  BZ_STREAM_OK=0
fi
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} compress=${COMPRESS_OK} bz_stream=${BZ_STREAM_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.compress zstd gate OK (F-04 v7; honesty)"
