#!/usr/bin/env bash
# STD-122：std.compress 统一流式 API 门禁
#
# 用法：./tests/run-std-compress-unified-stream-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD122_COMPRESS_UNIFIED_DOC:-analysis/std-compress-unified-stream-v1.md}"
MANIFEST="${SHUX_STD122_COMPRESS_UNIFIED_TSV:-tests/baseline/std-compress-unified-stream-manifest.tsv}"
MOD_SX="std/compress/mod.sx"
COMPRESS_C="std/compress/gzip/gzip_libz.sx"
LIB="tests/lib/std-compress-unified-stream.sh"
STREAM_SX="tests/std-compress/unified_stream_roundtrip.sx"
MIN_APIS=7

# shellcheck source=tests/lib/std-compress-unified-stream.sh
. "$LIB"
# shellcheck source=tests/lib/std-compress.sh
. tests/lib/std-compress.sh

echo "=== STD-122: compress unified stream manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$COMPRESS_C" "$STREAM_SX"; do
  if [ ! -f "$f" ]; then
    echo "std-compress-unified-stream gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-122 StreamCompress stream_compress_init compress_format_gzip; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-compress-unified-stream gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_SX" 2>/dev/null; then
        echo "std-compress-unified-stream gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-compress-unified-stream gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-compress-unified-stream gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_compress_unified_symbols_ok "$MOD_SX" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_compress_unified_emit_report "fail" 0 0
  echo "std-compress-unified-stream gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-compress-unified-stream manifest OK"

STREAM_OK=0
SKIP=1
if SHUX_BIN="$(std_compress_resolve_shu)"; then
  echo "=== STD-122: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  std_compress_try_libs
  # F-04 v7+：compress 纯 .sx，不再 ensure compress.o
  if ! "$SHUX_BIN" check -L . "$STREAM_SX" >/dev/null 2>&1; then
    echo "std-compress-unified-stream gate FAIL: typeck $STREAM_SX" >&2
    "$SHUX_BIN" check -L . "$STREAM_SX" 2>&1 | tail -10 >&2 || true
    std_compress_unified_emit_report "fail" 0 0
    exit 1
  fi
  if std_compress_unified_run_smoke "$SHUX_BIN" "$STREAM_SX" "unified_stream"; then
    STREAM_OK=1
    SKIP=0
  else
    std_compress_unified_emit_report "fail" 0 0
    exit 1
  fi
else
  echo "std-compress-unified-stream gate SKIP smoke (no native shux)" >&2
fi

std_compress_unified_emit_report "ok" "$STREAM_OK" "$SKIP"
echo "std-compress-unified-stream gate OK"
