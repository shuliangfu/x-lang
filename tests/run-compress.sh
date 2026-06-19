#!/usr/bin/env bash
# std.compress 测试：gzip / zstd / Brotli 往返。若 compress.o 未启用对应库，分支跳过仍通过。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
# 优先 zlib+zstd；回退 zlib-only
if (cd compiler && make compress-o-zlib-zstd 2>/dev/null); then
  :
elif (cd compiler && make compress-o-zlib 2>/dev/null); then
  :
fi
SHUX="${SHUX:-./compiler/shux}"
exe="/tmp/shux_compress_$$"
if ! $SHUX -L . tests/compress/main.sx -o "$exe" 2>&1; then echo "compress test: compile failed"; rm -f "$exe"; exit 1; fi
$exe 2>/dev/null; exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "compress test: expected exit 0, got $exitcode"; exit 1; fi
echo "compress test OK"
