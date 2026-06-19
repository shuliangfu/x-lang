#!/usr/bin/env bash
# STD-073：std.codec 门禁
#
# 用法：./tests/run-std-codec-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_CODEC_DOC:-analysis/std-codec-v1.md}"
MANIFEST="${SHUX_STD_CODEC_MANIFEST:-tests/baseline/std-codec-manifest.tsv}"
VECTORS="${SHUX_STD_CODEC_VECTORS:-tests/baseline/std-codec-vectors.tsv}"
MOD_SU="std/codec/mod.sx"
LIB="tests/lib/std-codec.sh"
SMOKE_SU="tests/std-codec/roundtrip.sx"
MIN_APIS=10

# shellcheck source=tests/lib/std-codec.sh
. "$LIB"

echo "=== STD-073: std.codec manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$SMOKE_SU" std/codec/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-codec gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-073 Encoder Decoder encode_into_bytes StreamCodec adapter_hex; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-codec gate FAIL: doc missing '$kw'" >&2
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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
    echo "std-codec gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-codec gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_codec_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_codec_emit_report "fail" 0 0
  exit 1
fi
echo "std-codec manifest OK"

if [ "${SHUX_STD_CODEC_MANIFEST_ONLY:-0}" = "1" ]; then
  std_codec_emit_report "ok" 0 1
  echo "std-codec gate OK (manifest only)"
  exit 0
fi

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/compress/compress.o
COMPRESS_O="$(cd compiler && pwd)/../std/compress/compress.o"

SU_OK=0
SKIP=0

SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-073: .sx smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-codec gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_codec_emit_report "fail" 0 0
    exit 1
  fi
  if std_codec_run_smoke "$SHUX_BIN" "$SMOKE_SU" "roundtrip" "$COMPRESS_O"; then
    SU_OK=1
  else
    std_codec_emit_report "fail" 0 0
    exit 1
  fi
else
  echo "std-codec gate SKIP .sx smoke (no shux)" >&2
  SKIP=1
fi

std_codec_emit_report "ok" "$SU_OK" "$SKIP"
echo "std-codec gate OK"
