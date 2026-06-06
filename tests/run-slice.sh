#!/usr/bin/env bash
# 切片 []T：从数组初始化、下标访问；core.slice len_i32；[]u8 字段 .data/.length
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c

if [ -n "$SHU" ]; then
  :
elif [ -x ./compiler/shu ]; then
  SHU=./compiler/shu
elif [ -x ./compiler/shu-c ]; then
  SHU=./compiler/shu-c
else
  SHU=./compiler/shu-c
fi

make -C compiler -q ../std/process/process.o 2>/dev/null || make -C compiler ../std/process/process.o

$SHU tests/slice/main.su -o /tmp/shu_slice 2>&1
exitcode=0; /tmp/shu_slice >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 20 ] && { echo "expected 20 (slice s[1]), got $exitcode"; exit 1; }

$SHU tests/slice/data_field.su -o /tmp/shu_slice_data_field 2>&1
exitcode=0; /tmp/shu_slice_data_field >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (data_field), got $exitcode"; exit 1; }

# core.slice + core.option 全链（Linux CI 有完整链接环境）
$SHU -L . tests/slice/length.su -o /tmp/shu_slice_length 2>&1
exitcode=0; /tmp/shu_slice_length >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (len_i32), got $exitcode"; exit 1; }

# 边界：对非数组/切片取下标，应报 subscript base must be array, slice or pointer
err=$($SHU tests/slice/subscript_not_slice.su -o /tmp/shu_slice_fail 2>&1) || true
echo "$err" | grep -q "subscript base must be array" || { echo "expected subscript base error, got: $err"; exit 1; }

echo "slice test OK"
