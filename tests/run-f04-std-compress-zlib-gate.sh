#!/usr/bin/env bash
# F-04 v4: std.compress zlib remove zlib.c (libz.x + no zlib.c).
#
# Usage: ./tests/run-f04-std-compress-zlib-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-compress-zlib-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory + STD-007 compress
# (no soft die→exit0). Soft XLANG_F04_COMPRESS_ZLIB_FAIL retired. Prefer asm;
# pin XLANG_LINK_XLANG. Report static=/inventory=/compress=/skip=. Gate was
# portable-false-green (DOC still pointed at top-level analysis/phase-f-f04-v4.md
# after archive move; soft FAIL printed then exit0 while static checks already
# green). PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F04_ZLIB_DOC:-analysis/archive/phase/phase-f-f04-v4.md}"
MANIFEST="tests/baseline/f04-std-compress-zlib.tsv"
ZLIB_LIBZ="std/compress/zlib/libz.x"
ZLIB_MOD="std/compress/zlib/mod.x"
PREFIX="xlang: [XLANG_F04_ZLIB]"

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
  echo "f04-compress-zlib gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} compress=${COMPRESS_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
COMPRESS_OK=0
SKIP=1

echo "=== F-04 v4: std.compress zlib remove zlib.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v4' "$DOC" || die "doc missing F-04 v4 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$ZLIB_LIBZ" ] || die "missing libz.x"
[ -f "$ZLIB_MOD" ] || die "missing mod.x"
[ ! -f std/compress/zlib/zlib.c ] || die "zlib.c should be deleted"
grep -q 'compress_deflate_c' "$ZLIB_LIBZ" || die "libz missing compress_deflate_c"
grep -q 'compress_inflate_c' "$ZLIB_LIBZ" || die "libz missing compress_inflate_c"
grep -q 'xlang_compress_zlib_marker' "$ZLIB_LIBZ" || die "libz missing marker"
grep -q 'import("std.compress.zlib.libz")' "$ZLIB_MOD" || die "mod.x missing libz import"
if grep -q 'extern function compress_deflate_c' "$ZLIB_MOD" 2>/dev/null; then
  die "mod.x still extern compress_deflate_c"
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
      target="$ZLIB_LIBZ"
      case "$mod_path" in
        std/compress/zlib/mod.x) target="$ZLIB_MOD" ;;
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
echo "f04-zlib manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v4: delegate run-std-c-inventory-gate (F-01; hard) ==="
chmod +x tests/run-std-c-inventory-gate.sh
if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory sub-gate failed"
fi
INVENTORY_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
echo "=== F-04 v4: STD-007 compress (XLANG=$XLANG_BIN; hard) ==="
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
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} compress=${COMPRESS_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.compress zlib gate OK (F-04 v4; honesty)"
