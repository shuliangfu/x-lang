#!/usr/bin/env bash
# STD-110：std.codec compress/base64 流式适配门禁
#
# 用法：./tests/run-std-codec-stream-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD110_DOC:-analysis/std-codec-stream-v1.md}"
MANIFEST="${SHUX_STD110_TSV:-tests/baseline/std-codec-stream.tsv}"
VECTORS="${SHUX_STD110_VECTORS:-tests/baseline/std-codec-stream-vectors.tsv}"
MOD_SU="std/codec/mod.sx"
LIB="tests/lib/std-codec-stream.sh"
SMOKE_SU="tests/std-codec/stream_roundtrip.sx"
MIN_APIS=8

# shellcheck source=tests/lib/std-codec-stream.sh
. "$LIB"

echo "=== STD-110: std.codec stream manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$SMOKE_SU"; do
  if [ ! -f "$f" ]; then
    echo "std-codec-stream gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-110 adapter_compress_stream_init stream_codec_init_base64 aGVsbG8; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-codec-stream gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'aGVsbG8=' "$VECTORS" 2>/dev/null; then
  echo "std-codec-stream gate FAIL: vectors missing hello_enc gold" >&2
  exit 1
fi

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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-codec-stream FAIL: doc missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-codec-stream gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_codec_stream_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_codec_stream_emit_report "fail" 0 0
  exit 1
fi
echo "std-codec-stream manifest OK"

SU_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-110: .sx smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-codec-stream gate FAIL: typeck $SMOKE_SU" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_codec_stream_emit_report "fail" 0 0
    exit 1
  fi
  if std_codec_stream_run_smoke "$SHUX_BIN" "$SMOKE_SU" "stream"; then
    SU_OK=1
  else
    std_codec_stream_emit_report "fail" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_codec_stream_emit_report "ok" "$SU_OK" "$SKIP"
echo "std-codec-stream gate OK"
