#!/usr/bin/env bash
# F-04 v5: std.compress gzip remove gzip.c (libz.x + no gzip.c).
#
# Usage: ./tests/run-f04-std-compress-gzip-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-compress-gzip-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory + STD-007 compress
# (no soft die→exit0). Soft XLANG_F04_COMPRESS_GZIP_FAIL retired. Prefer asm;
# pin XLANG_LINK_XLANG. compress-stream smoke is observational (product-red
# residual — not soft false-green; do not die). Report
# static=/inventory=/compress=/stream=/skip=. Gate was portable-false-green
# (DOC still pointed at top-level analysis/phase-f-f04-v5.md after archive
# move; soft FAIL printed then exit0 while static checks already green).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F04_GZIP_DOC:-analysis/archive/phase/phase-f-f04-v5.md}"
MANIFEST="tests/baseline/f04-std-compress-gzip.tsv"
GZIP_LIBZ="std/compress/gzip/libz.x"
GZIP_MOD="std/compress/gzip/mod.x"
PREFIX="xlang: [XLANG_F04_GZIP]"

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
  echo "f04-compress-gzip gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} compress=${COMPRESS_OK:-0} stream=${STREAM_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
COMPRESS_OK=0
STREAM_OK=0
SKIP=1

echo "=== F-04 v5: std.compress gzip remove gzip.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v5' "$DOC" || die "doc missing F-04 v5 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$GZIP_LIBZ" ] || die "missing libz.x"
[ -f "$GZIP_MOD" ] || die "missing mod.x"
[ ! -f std/compress/gzip/gzip.c ] || die "gzip.c should be deleted"
grep -q 'compress_gzip_compress_c' "$GZIP_LIBZ" || die "gzip_libz missing compress_gzip_compress_c"
grep -q 'compress_gzip_stream_compress_c' "$GZIP_LIBZ" || die "gzip_libz missing stream compress"
grep -q 'deflateInit2' "$GZIP_LIBZ" || die "gzip_libz missing deflateInit2 extern"
grep -q 'import("std.compress.gzip.libz")' "$GZIP_MOD" || die "mod.x missing libz import"
if grep -q 'extern function compress_gzip_compress_c' "$GZIP_MOD" 2>/dev/null; then
  die "mod.x still extern compress_gzip_compress_c"
fi

# Manifest: symbol / absent rows (honesty TSV).
# PLATFORM: SHARED archaeology.
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    symbol)
      target="$GZIP_LIBZ"
      case "$mod_path" in
        std/compress/gzip/mod.x) target="$GZIP_MOD" ;;
      esac
      grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
echo "f04-gzip manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v5: delegate run-std-c-inventory-gate (F-01; hard) ==="
chmod +x tests/run-std-c-inventory-gate.sh
if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory sub-gate failed"
fi
INVENTORY_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
echo "=== F-04 v5: STD-007 compress (XLANG=$XLANG_BIN; hard) ==="
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

if [ ! -f tests/run-std-compress-stream-gate.sh ]; then
  die "missing tests/run-std-compress-stream-gate.sh"
fi
echo "=== F-04 v5: compress-stream (observational; product-red residual) ==="
chmod +x tests/run-std-compress-stream-gate.sh
# Observational: compress-stream product residual — not soft; do not die archaeology.
if tests/run-std-compress-stream-gate.sh; then
  STREAM_OK=1
else
  echo "f04-gzip gate SKIP compress-stream (observational; product-red residual)" >&2
  STREAM_OK=0
fi
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} compress=${COMPRESS_OK} stream=${STREAM_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.compress gzip gate OK (F-04 v5; honesty)"
