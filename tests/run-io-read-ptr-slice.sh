#!/usr/bin/env bash
# M-5：read_ptr_slice / read_stdin_ptr_slice 运行时烟测 + 局部/形参 slice 字段访问 codegen。
# 用法：./tests/run-io-read-ptr-slice.sh
set -e
cd "$(dirname "$0")/.."

if [ -n "$SHUX" ]; then
  :
elif [ -x ./compiler/shux ]; then
  SHUX=./compiler/shux
elif [ -x ./compiler/shux-c ]; then
  SHUX=./compiler/shux-c
else
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  SHUX=./compiler/shux-c
fi

# 非 x86_64：-o 链接用 shux-c，避免 seed asm 产出 x86_64 ELF（EM:62）在 ARM64 上 ld 失败。
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"

make -C compiler -q ../std/process/process.o ../std/io/io.o 2>/dev/null \
  || make -C compiler ../std/process/process.o ../std/io/io.o

$RUN_SHUX -L . tests/io/read_ptr_slice.x -o /tmp/shux_io_read_ptr_slice 2>&1
echo -n "AB" | /tmp/shux_io_read_ptr_slice
ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (read_stdin_ptr_slice), got $ec"; exit 1; }

$RUN_SHUX -L . tests/io/read_ptr_slice_param.x -o /tmp/shux_io_read_ptr_slice_param 2>&1
echo -n "AB" | /tmp/shux_io_read_ptr_slice_param
ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (read_ptr_slice_param local/param field), got $ec"; exit 1; }

echo "io read_ptr_slice OK"
