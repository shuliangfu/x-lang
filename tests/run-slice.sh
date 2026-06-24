#!/usr/bin/env bash
# 切片 T[]：从数组初始化、下标访问；core.slice len_i32；u8[] 字段 .data/.length
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c

if [ -n "$SHUX" ]; then
  :
elif [ -x ./compiler/shux ]; then
  SHUX=./compiler/shux
elif [ -x ./compiler/shux-c ]; then
  SHUX=./compiler/shux-c
else
  SHUX=./compiler/shux-c
fi

# 非 x86_64：seed shux -o 可能走 asm 产出 x86_64 .o，链接 EM:62 失败；可执行链用 shux-c。
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"

# core/slice C 实现（length.sx 等）；勿强编 process.o（arm64 shux-c 无 asm backend）。
make -C compiler -q ../core/slice/slice.o 2>/dev/null \
  || make -C compiler ../core/slice/slice.o 2>/dev/null || true

$RUN_SHUX tests/slice/main.sx -o /tmp/shux_slice 2>&1
exitcode=0; /tmp/shux_slice >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 20 ] && { echo "expected 20 (slice s[1]), got $exitcode"; exit 1; }

$RUN_SHUX tests/slice/data_field.sx -o /tmp/shux_slice_data_field 2>&1
exitcode=0; /tmp/shux_slice_data_field >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (data_field), got $exitcode"; exit 1; }

# core.slice + core.option 全链（Linux CI 有完整链接环境）
$RUN_SHUX -L . tests/slice/length.sx -o /tmp/shux_slice_length 2>&1
exitcode=0; /tmp/shux_slice_length >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (len_i32), got $exitcode"; exit 1; }

# CORE-004：subslice / split_at / chunks
$RUN_SHUX -L . tests/slice/subslice_split_chunks.sx -o /tmp/shux_slice_subsplit 2>&1
exitcode=0; /tmp/shux_slice_subsplit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (subslice_split_chunks), got $exitcode"; exit 1; }

# 边界：对非数组/切片取下标，应报 subscript base must be array, slice or pointer
# typeck 边界须 shux-c（seed shux 可能无完整 typeck 诊断）；与 $RUN_SHUX 一致。
err=$($RUN_SHUX tests/slice/subscript_not_slice.sx -o /tmp/shux_slice_fail 2>&1) || true
echo "$err" | grep -q "subscript base must be array" || { echo "expected subscript base error, got: $err"; exit 1; }

echo "slice test OK"
