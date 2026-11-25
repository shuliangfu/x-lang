#!/usr/bin/env bash
# Cap tip leftover: true-cold wipe drops runtime_compress_zlib_glue.o
# (deflateInit2/inflateInit2). Nested core_mem U from gzip/zstd/brotli
# never pulls mem.o. Rebuild zlib glue; merge core_mem stubs into gzip.o.
# Prefer asm; no FORCE_CC. PLATFORM: MACOS|DARWIN arm64 Cap tip.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

mkdir -p build_asm/selfhost_pabi ../std/compress/gzip

FORCE=1 bash scripts/ensure_host_cc_seed_o.sh try-heat runtime_compress_zlib_glue.o
[ -s runtime_compress_zlib_glue.o ] \
  || { echo "cap_tip_ensure_compress: missing runtime_compress_zlib_glue.o" >&2; exit 1; }
nm -gU runtime_compress_zlib_glue.o 2>/dev/null | grep -q 'T _inflateInit2$' \
  || { echo "cap_tip_ensure_compress: glue missing _inflateInit2" >&2; exit 1; }

[ -f src/asm/runtime_core_mem_compress_stubs_a64.s ] \
  || { echo "cap_tip_ensure_compress: missing stubs .s" >&2; exit 1; }
clang -c -arch arm64 src/asm/runtime_core_mem_compress_stubs_a64.s \
  -o build_asm/selfhost_pabi/core_mem_compress_stubs_a64.o

gz=../std/compress/gzip/gzip.o
if [ ! -s "$gz" ] && [ -n "${XLANG_CAP_TIP_L4_CACHE:-}" ] \
   && [ -s "$XLANG_CAP_TIP_L4_CACHE/leaves/gzip.o" ]; then
  cp -f "$XLANG_CAP_TIP_L4_CACHE/leaves/gzip.o" "$gz"
  echo "cap_tip_ensure_compress: restored gzip.o from L4 leaves cache" >&2
fi
[ -s "$gz" ] || { echo "cap_tip_ensure_compress: missing $gz" >&2; exit 1; }

# bak = first-seen leaf without our stubs (or cache copy)
if [ ! -s "${gz}.bak_pre_compress_overlay" ]; then
  cp -f "$gz" "${gz}.bak_pre_compress_overlay"
fi
# Re-apply from bak so re-entry does not stack stubs
cp -f "${gz}.bak_pre_compress_overlay" "$gz"
# If bak already has stubs (snapshotted overlaid leaf), skip merge
if nm -gU "$gz" 2>/dev/null | grep -q 'T _core_mem_mem_zero$'; then
  echo "cap_tip_ensure_compress: gzip leaf already has mem stubs" >&2
else
  ld -r -o "${gz}.tmp" build_asm/selfhost_pabi/core_mem_compress_stubs_a64.o "$gz"
  mv -f "${gz}.tmp" "$gz"
fi
nm -gU "$gz" 2>/dev/null | grep -q 'T _core_mem_mem_zero$' \
  || nm -m "$gz" 2>/dev/null | grep -q '_core_mem_mem_zero' \
  || { echo "cap_tip_ensure_compress: gzip missing mem_zero" >&2; exit 1; }
echo "cap_tip_ensure_compress: OK glue+gzip mem stubs" >&2
