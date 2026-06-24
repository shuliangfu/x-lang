#!/usr/bin/env bash
# F-04 v7：std.compress zstd 去 C + compress.o 退役门禁。
#
# 用法：./tests/run-f04-std-compress-zstd-gate.sh
# 环境：SHUX_F04_COMPRESS_ZSTD_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_COMPRESS_ZSTD_FAIL:-0}
DOC="analysis/phase-f-f04-v7.md"
ZSTD_LIB="std/compress/zstd/zstd_lib.sx"
ZSTD_MOD="std/compress/zstd/mod.sx"

die() {
  echo "f04-compress-zstd gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v7: std.compress zstd remove zstd.c + retire compress.o ==="
# 清理旧构建残留（F-04 v7 不再产出 compress.o）
rm -f std/compress/compress.o std/compress/zstd/zstd.o std/compress/gzip/gzip.o std/compress/brotli/brotli.o 2>/dev/null || true
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v7' "$DOC" || die "doc missing F-04 v7 marker"
[ -f "$ZSTD_LIB" ] || die "missing zstd_lib.sx"
[ ! -f std/compress/zstd/zstd.c ] || die "zstd.c should be deleted"
grep -q 'compress_zstd_compress_c' "$ZSTD_LIB" || die "zstd_lib missing compress_zstd_compress_c"
grep -q 'compress_zstd_stream_compress_c' "$ZSTD_LIB" || die "zstd_lib missing stream compress"
grep -q 'shu_compress_zstd_marker' "$ZSTD_LIB" || die "zstd_lib missing marker"
grep -q 'import("std.compress.zstd.zstd_lib")' "$ZSTD_MOD" || die "mod.sx missing zstd_lib import"
if grep -q 'extern function compress_zstd_compress_c' "$ZSTD_MOD" 2>/dev/null; then
  die "mod.sx still extern compress_zstd_compress_c"
fi
if grep -q 'compress/zstd/zstd.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references zstd.c"
fi
if grep -q 'compress/zstd/zstd.o' compiler/Makefile 2>/dev/null; then
  die "Makefile still references zstd.o"
fi
if grep -q 'compress/compress.o:' compiler/Makefile 2>/dev/null; then
  die "Makefile still builds compress.o rule"
fi
if grep 'STD_AND_PANIC_O' compiler/Makefile | grep -q 'compress/compress.o'; then
  die "STD_AND_PANIC_O still lists compress.o"
fi
grep -q 'link_abi_user_o_needs_compress_libs' compiler/src/runtime_link_abi.c || die "missing compress user_o link helper"

MANIFEST="tests/baseline/f04-std-compress-zstd.tsv"
if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$kind" in
      symbol)
        target="$ZSTD_LIB"
        case "$mod_path" in
          std/compress/zstd/mod.sx) target="$ZSTD_MOD" ;;
        esac
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
      target)
        grep -qF "$anchor" "${mod_path:-compiler/Makefile}" || die "manifest missing target $anchor"
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
    esac
  done < "$MANIFEST"
fi

for sub in run-std-compress-gate.sh run-std-compress-brotli-zstd-stream-gate.sh; do
  if [ -f "tests/$sub" ]; then
    echo "=== F-04 v7: delegate tests/$sub ==="
    chmod +x "tests/$sub"
    if ! "tests/$sub"; then
      die "$sub failed"
    fi
  fi
done

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-04 v7: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f04 std.compress zstd gate OK (F-04 v7)"
