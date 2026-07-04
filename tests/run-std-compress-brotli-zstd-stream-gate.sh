#!/usr/bin/env bash
# STD-136：std.compress brotli/zstd 流式 API 门禁
set -e
cd "$(dirname "$0")/.."
MANIFEST="tests/baseline/std-compress-brotli-zstd-stream.tsv"
MOD_X="std/compress/mod.x"
SMOKE_X="tests/std-compress/brotli_zstd_stream_smoke.x"

echo "=== STD-136: compress brotli/zstd stream manifest ==="
for f in "$MANIFEST" "$MOD_X" "$SMOKE_X" std/compress/brotli/lib.x std/compress/zstd/lib.x; do
  [ -f "$f" ] || { echo "std-compress-brotli-zstd-stream gate FAIL: missing $f" >&2; exit 1; }
done

MISS=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      grep -qE "function ${anchor}" "$MOD_X" || { echo "FAIL: missing $anchor" >&2; MISS=$((MISS + 1)); }
      ;;
    symbol)
      grep -qF "$anchor" "$mod_path" || { echo "FAIL: missing $anchor in $mod_path" >&2; MISS=$((MISS + 1)); }
      ;;
    smoke)
      [ -f "$anchor" ] || { echo "FAIL: missing $anchor" >&2; MISS=$((MISS + 1)); }
      ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || exit 1
echo "std-compress-brotli-zstd-stream manifest OK"

# F-04 v7：不再依赖 compress.o；烟测经 .x + runtime 按需链库
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null
  # shellcheck source=tests/lib/bootstrap-link-shux.sh
  . tests/lib/bootstrap-link-shux.sh
  EXE="/tmp/shux_compress_br_zs_stream_$$"
  $RUN_SHUX -L . "$SMOKE_X" -o "$EXE" >/dev/null
  "$EXE" || { echo "std-compress-brotli-zstd-stream FAIL: smoke exit=$?" >&2; rm -f "$EXE"; exit 1; }
  rm -f "$EXE"
fi

echo "std-compress-brotli-zstd-stream gate OK"
