#!/usr/bin/env bash
# F-04 v6：std.compress brotli 去 C 门禁（lib.x + 无 brotli.c）。
#
# 用法：./tests/run-f04-std-compress-brotli-gate.sh
# 环境：SHUX_F04_COMPRESS_BROTLI_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_COMPRESS_BROTLI_FAIL:-0}
DOC="analysis/phase-f-f04-v6.md"
BROTLI_LIB="std/compress/brotli/lib.x"
BROTLI_MOD="std/compress/brotli/mod.x"

die() {
  echo "f04-compress-brotli gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v6: std.compress brotli remove brotli.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v6' "$DOC" || die "doc missing F-04 v6 marker"
[ -f "$BROTLI_LIB" ] || die "missing lib.x"
[ ! -f std/compress/brotli/brotli.c ] || die "brotli.c should be deleted"
grep -q 'compress_brotli_compress_c' "$BROTLI_LIB" || die "lib missing compress_brotli_compress_c"
grep -q 'compress_brotli_stream_compress_c' "$BROTLI_LIB" || die "lib missing stream compress"
grep -q 'shu_compress_brotli_marker' "$BROTLI_LIB" || die "lib missing marker"
grep -q 'import("std.compress.brotli.lib")' "$BROTLI_MOD" || die "mod.x missing lib import"
if grep -q 'extern function compress_brotli_compress_c' "$BROTLI_MOD" 2>/dev/null; then
  die "mod.x still extern compress_brotli_compress_c"
fi
if grep -q 'compress/brotli/brotli.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references brotli.c"
fi
if grep -q 'compress/brotli/brotli.o' compiler/Makefile 2>/dev/null; then
  die "Makefile still references brotli.o"
fi

MANIFEST="tests/baseline/f04-std-compress-brotli.tsv"
if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$kind" in
      symbol)
        target="$BROTLI_LIB"
        case "$mod_path" in
          std/compress/brotli/mod.x) target="$BROTLI_MOD" ;;
        esac
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
      absent)
        [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
        ;;
    esac
  done < "$MANIFEST"
fi

for sub in run-std-compress-gate.sh run-std-compress-brotli-gate.sh; do
  if [ -f "tests/$sub" ]; then
    echo "=== F-04 v6: delegate tests/$sub ==="
    chmod +x "tests/$sub"
    if ! "tests/$sub"; then
      die "$sub failed"
    fi
  fi
done

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-04 v6: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f04 std.compress brotli gate OK (F-04 v6)"
