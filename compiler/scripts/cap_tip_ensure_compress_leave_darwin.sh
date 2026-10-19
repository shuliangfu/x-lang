#!/usr/bin/env bash
# Cap tip leftover: true-cold wipe drops runtime_compress_zlib_glue.o
# (deflateInit2/inflateInit2) and ondemand never pulls core/mem for nested
# U from gzip/zstd/brotli. Rebuild zlib glue pure-asm; merge weak core_mem
# stubs into gzip.o only (satisfies all three algos). Prefer asm; no FORCE_CC.
# PLATFORM: MACOS|DARWIN arm64 Cap tip.
# cwd: compiler/ (or any; we cd next to this script's parent).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

OC="${LLVM_OBJCOPY:-}"
[ -n "$OC" ] || { [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ] && OC=/opt/homebrew/opt/llvm/bin/llvm-objcopy; }
[ -n "$OC" ] || { [ -x /usr/local/opt/llvm/bin/llvm-objcopy ] && OC=/usr/local/opt/llvm/bin/llvm-objcopy; }

mkdir -p build_asm/selfhost_pabi ../std/compress/gzip

# 1) zlib Init2 glue (Cap tip ondemand links this .o when present)
FORCE=1 bash scripts/ensure_host_cc_seed_o.sh try-heat runtime_compress_zlib_glue.o \
  || FORCE=1 bash scripts/ensure_host_cc_seed_o.sh try-heat runtime_compress_zlib_glue.o
[ -s runtime_compress_zlib_glue.o ] \
  || { echo "cap_tip_ensure_compress: missing runtime_compress_zlib_glue.o" >&2; exit 1; }
nm -gU runtime_compress_zlib_glue.o 2>/dev/null | grep -q 'T _inflateInit2$' \
  || { echo "cap_tip_ensure_compress: glue missing _inflateInit2" >&2; exit 1; }

# 2) core_mem stubs → gzip.o
if [ ! -f src/asm/runtime_core_mem_compress_stubs_a64.s ]; then
  echo "cap_tip_ensure_compress: missing stubs .s" >&2
  exit 1
fi
clang -c -arch arm64 src/asm/runtime_core_mem_compress_stubs_a64.s \
  -o build_asm/selfhost_pabi/core_mem_compress_stubs_a64.o
gz=../std/compress/gzip/gzip.o
[ -s "$gz" ] || { echo "cap_tip_ensure_compress: missing $gz" >&2; exit 1; }
[ -s "${gz}.bak_pre_compress_overlay" ] || cp -f "$gz" "${gz}.bak_pre_compress_overlay"
cp -f "${gz}.bak_pre_compress_overlay" "$gz"
# If bak already had stubs from prior run, strip by restoring once more from
# a pre-overlay if nm shows hollow-only — bak_pre is the authority.
ld -r -o "${gz}.tmp" build_asm/selfhost_pabi/core_mem_compress_stubs_a64.o "$gz"
mv -f "${gz}.tmp" "$gz"
nm -gU "$gz" 2>/dev/null | grep -q 'T _core_mem_mem_zero$' \
  || nm -m "$gz" 2>/dev/null | grep -q '_core_mem_mem_zero' \
  || { echo "cap_tip_ensure_compress: gzip missing mem_zero" >&2; exit 1; }
echo "cap_tip_ensure_compress: OK glue+gzip mem stubs" >&2
