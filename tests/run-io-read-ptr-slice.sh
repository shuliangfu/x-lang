#!/usr/bin/env bash
# M-5：read_ptr_slice / read_stdin_ptr_slice 运行时烟测 + 局部/形参 slice 字段访问 codegen。
# 用法：./tests/run-io-read-ptr-slice.sh
set -e
cd "$(dirname "$0")/.."

if [ -n "$SHU" ]; then
  :
elif [ -x ./compiler/shu ]; then
  SHU=./compiler/shu
elif [ -x ./compiler/shu-c ]; then
  SHU=./compiler/shu-c
else
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c
  SHU=./compiler/shu-c
fi

make -C compiler -q ../std/process/process.o ../std/io/io.o 2>/dev/null \
  || make -C compiler ../std/process/process.o ../std/io/io.o

$SHU -L . tests/io/read_ptr_slice.su -o /tmp/shu_io_read_ptr_slice 2>&1
echo -n "AB" | /tmp/shu_io_read_ptr_slice
ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (read_stdin_ptr_slice), got $ec"; exit 1; }

$SHU -L . tests/io/read_ptr_slice_param.su -o /tmp/shu_io_read_ptr_slice_param 2>&1
echo -n "AB" | /tmp/shu_io_read_ptr_slice_param
ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (read_ptr_slice_param local/param field), got $ec"; exit 1; }

echo "io read_ptr_slice OK"
