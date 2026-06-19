#!/usr/bin/env bash
# 测试 std.io：print_i32 输出 42，print_u32 输出 100
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

# run-all 默认 C 流水线（RUN_ALL_USE_C=1）时用 shux-c，避免 seed -o 在非 x86_64 挂起。
if [ -n "${RUN_ALL_USE_C:-}" ] && [ -x ./compiler/shux-c ]; then
  SHUX=./compiler/shux-c
elif [ -n "$SHUX" ]; then
  :
elif [ -x ./compiler/shux ]; then
  SHUX=./compiler/shux
elif [ -x ./compiler/shux-c ]; then
  SHUX=./compiler/shux-c
else
  SHUX=./compiler/shux-c
fi

make -C compiler -q ../std/process/process.o ../std/io/io.o 2>/dev/null \
  || make -C compiler ../std/process/process.o ../std/io/io.o

$SHUX -L . tests/io/main.sx -o /tmp/shux_io 2>&1
out=$(/tmp/shux_io 2>&1)
echo "$out" | grep -q "42" || { echo "expected stdout to contain 42, got: $out"; exit 1; }

$SHUX -L . tests/io/print_u32.sx -o /tmp/shux_io_u32 2>&1
out=$(/tmp/shux_io_u32 2>&1)
echo "$out" | grep -q "100" || { echo "expected stdout to contain 100 (print_u32), got: $out"; exit 1; }

$SHUX -L . tests/io/print_i64.sx -o /tmp/shux_io_i64 2>&1
out=$(/tmp/shux_io_i64 2>&1)
echo "$out" | grep -q "123" || { echo "expected stdout to contain 123 (print_i64), got: $out"; exit 1; }

$SHUX -L . tests/io/write_stdout.sx -o /tmp/shux_io_write 2>&1
out=$(/tmp/shux_io_write 2>&1)
echo "$out" | grep -q "Hi" || { echo "expected stdout to contain Hi (write_stdout), got: $out"; exit 1; }
ec=0; /tmp/shux_io_write >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (write_stdout), got $ec"; exit 1; }

$SHUX -L . tests/io/write_with_timeout.sx -o /tmp/shux_io_wto 2>&1
out=$(/tmp/shux_io_wto 2>&1)
echo "$out" | grep -q "Hi" || { echo "expected stdout to contain Hi (write_with_timeout), got: $out"; exit 1; }
ec=0; /tmp/shux_io_wto >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (write_with_timeout), got $ec"; exit 1; }

$SHUX -L . tests/io/print_str.sx -o /tmp/shux_io_print_str 2>&1
out=$(/tmp/shux_io_print_str 2>&1)
echo "$out" | grep -q "ok" || { echo "expected stdout to contain ok (print_str), got: $out"; exit 1; }

# 零拷贝读 read_stdin_ptr / read_ptr_len（管道喂入 "AB"）
$SHUX -L . tests/io/read_ptr.sx -o /tmp/shux_io_read_ptr 2>&1
echo -n "AB" | /tmp/shux_io_read_ptr
ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (read_stdin_ptr), got $ec"; exit 1; }

# M-5：read_ptr_slice / read_stdin_ptr_slice（管道喂入 "AB"）
$SHUX -L . tests/io/read_ptr_slice.sx -o /tmp/shux_io_read_ptr_slice 2>&1
echo -n "AB" | /tmp/shux_io_read_ptr_slice
ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (read_stdin_ptr_slice), got $ec"; exit 1; }

$SHUX -L . tests/io/read_ptr_slice_param.sx -o /tmp/shux_io_read_ptr_slice_param 2>&1
echo -n "AB" | /tmp/shux_io_read_ptr_slice_param
ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (read_ptr_slice_param), got $ec"; exit 1; }

echo "io test OK"
