#!/usr/bin/env bash
# STD-139：std.codec 缓冲复用与零拷贝策略门禁
#
# 用法：./tests/run-std-codec-buffer-reuse-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-codec-buffer-reuse-v1.md"
MANIFEST="tests/baseline/std-codec-buffer-reuse-manifest.tsv"
CODEC_SU="std/codec/mod.sx"
BYTES_SU="std/bytes/mod.sx"
LIB="tests/lib/std-codec-buffer-reuse.sh"
SMOKE_SU="tests/std-codec/buffer_reuse.sx"

# shellcheck source=tests/lib/std-codec-buffer-reuse.sh
. "$LIB"

echo "=== STD-139: std.codec buffer reuse manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$CODEC_SU" "$BYTES_SU" "$SMOKE_SU" \
  analysis/std-codec-v1.md analysis/std-bytes-v1.md std/codec/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-codec-buffer-reuse gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-139 encode_into_bytes bytes_clear bytes_grow encode_upper_bound; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-codec-buffer-reuse gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "std-codec-buffer-reuse-v1.md" analysis/std-codec-v1.md 2>/dev/null; then
  echo "std-codec-buffer-reuse gate FAIL: std-codec-v1 cross-link" >&2
  exit 1
fi

if ! grep -qF "std-codec-buffer-reuse-v1.md" analysis/std-bytes-v1.md 2>/dev/null; then
  echo "std-codec-buffer-reuse gate FAIL: std-bytes-v1 cross-link" >&2
  exit 1
fi

sym_miss="$(std_codec_buffer_reuse_symbols_ok "$CODEC_SU" "$BYTES_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_codec_buffer_reuse_emit_report "fail" 0 0
  exit 1
fi
echo "std-codec-buffer-reuse registry OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/compress/compress.o
COMPRESS_O="$(cd compiler && pwd)/../std/compress/compress.o"

SU_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-codec-buffer-reuse gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_codec_buffer_reuse_emit_report "fail" 0 0
    exit 1
  fi
  if std_codec_buffer_reuse_run_smoke "$SHUX_BIN" "$SMOKE_SU" "$COMPRESS_O"; then
    SU_OK=1
  else
    std_codec_buffer_reuse_emit_report "fail" 0 0
    exit 1
  fi
else
  echo "std-codec-buffer-reuse gate SKIP .sx smoke (no shux)" >&2
  SKIP=1
fi

std_codec_buffer_reuse_emit_report "ok" "$SU_OK" "$SKIP"
echo "std-codec-buffer-reuse gate OK"
