#!/usr/bin/env bash
# F-04 v5：std.compress gzip 去 C 门禁（gzip_libz.sx + 无 gzip.c）。
#
# 用法：./tests/run-f04-std-compress-gzip-gate.sh
# 环境：SHUX_F04_COMPRESS_GZIP_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_COMPRESS_GZIP_FAIL:-0}
DOC="analysis/phase-f-f04-v5.md"
GZIP_LIBZ="std/compress/gzip/gzip_libz.sx"
GZIP_MOD="std/compress/gzip/mod.sx"

die() {
  echo "f04-compress-gzip gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v5: std.compress gzip remove gzip.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v5' "$DOC" || die "doc missing F-04 v5 marker"
[ -f "$GZIP_LIBZ" ] || die "missing gzip_libz.sx"
[ ! -f std/compress/gzip/gzip.c ] || die "gzip.c should be deleted"
grep -q 'compress_gzip_compress_c' "$GZIP_LIBZ" || die "gzip_libz missing compress_gzip_compress_c"
grep -q 'compress_gzip_stream_compress_c' "$GZIP_LIBZ" || die "gzip_libz missing stream compress"
grep -q 'deflateInit2' "$GZIP_LIBZ" || die "gzip_libz missing deflateInit2 extern"
grep -q 'import("std.compress.gzip.gzip_libz")' "$GZIP_MOD" || die "mod.sx missing gzip_libz import"
if grep -q 'extern function compress_gzip_compress_c' "$GZIP_MOD" 2>/dev/null; then
  die "mod.sx still extern compress_gzip_compress_c"
fi
if grep -q 'compress/gzip/gzip.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references gzip.c"
fi
if grep -q 'compress/gzip/gzip.o' compiler/Makefile 2>/dev/null; then
  die "Makefile still references gzip.o"
fi

MANIFEST="tests/baseline/f04-std-compress-gzip.tsv"
if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$kind" in
      symbol)
        target="$GZIP_LIBZ"
        case "$mod_path" in
          std/compress/gzip/mod.sx) target="$GZIP_MOD" ;;
        esac
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
      absent)
        [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
        ;;
    esac
  done < "$MANIFEST"
fi

for sub in run-std-compress-gate.sh run-std-compress-stream-gate.sh; do
  if [ -f "tests/$sub" ]; then
    echo "=== F-04 v5: delegate tests/$sub ==="
    chmod +x "tests/$sub"
    if ! "tests/$sub"; then
      die "$sub failed"
    fi
  fi
done

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-04 v5: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f04 std.compress gzip gate OK (F-04 v5)"
