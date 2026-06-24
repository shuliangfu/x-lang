#!/usr/bin/env bash
# F-04 v4：std.compress zlib 去 C 门禁（zlib_libz.sx + 无 zlib.c）。
#
# 用法：./tests/run-f04-std-compress-zlib-gate.sh
# 环境：SHUX_F04_COMPRESS_ZLIB_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_COMPRESS_ZLIB_FAIL:-0}
DOC="analysis/phase-f-f04-v4.md"
ZLIB_LIBZ="std/compress/zlib/zlib_libz.sx"
ZLIB_MOD="std/compress/zlib/mod.sx"

die() {
  echo "f04-compress-zlib gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v4: std.compress zlib remove zlib.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v4' "$DOC" || die "doc missing F-04 v4 marker"
[ -f "$ZLIB_LIBZ" ] || die "missing zlib_libz.sx"
[ ! -f std/compress/zlib/zlib.c ] || die "zlib.c should be deleted"
grep -q 'compress_deflate_c' "$ZLIB_LIBZ" || die "zlib_libz missing compress_deflate_c"
grep -q 'compress_inflate_c' "$ZLIB_LIBZ" || die "zlib_libz missing compress_inflate_c"
grep -q 'shu_compress_zlib_marker' "$ZLIB_LIBZ" || die "zlib_libz missing marker"
grep -q 'import("std.compress.zlib.zlib_libz")' "$ZLIB_MOD" || die "mod.sx missing zlib_libz import"
if grep -q 'extern function compress_deflate_c' "$ZLIB_MOD" 2>/dev/null; then
  die "mod.sx still extern compress_deflate_c"
fi
if grep -q 'compress/zlib/zlib.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references zlib.c"
fi
if grep -q 'compress/zlib/zlib.o' compiler/Makefile 2>/dev/null; then
  die "Makefile still references zlib.o"
fi

MANIFEST="tests/baseline/f04-std-compress-zlib.tsv"
if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$kind" in
      symbol)
        target="$ZLIB_LIBZ"
        case "$mod_path" in
          std/compress/zlib/mod.sx) target="$ZLIB_MOD" ;;
        esac
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
      absent)
        [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
        ;;
    esac
  done < "$MANIFEST"
fi

if [ -f tests/run-std-compress-gate.sh ]; then
  echo "=== F-04 v4: delegate run-std-compress-gate.sh ==="
  chmod +x tests/run-std-compress-gate.sh
  if ! tests/run-std-compress-gate.sh; then
    die "std-compress sub-gate failed"
  fi
fi

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-04 v4: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f04 std.compress zlib gate OK (F-04 v4)"
