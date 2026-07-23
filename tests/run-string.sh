#!/usr/bin/env bash
# 测试 std.string：string_empty、string_from_slice/eq/len、string_compare/append/find/starts_with/ends_with/copy_to
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
  # F-string v1：string.o 由 asm 编译 string.x（ensure_std_c_o 对纯 .x 模块为 no-op）。
  make -C compiler -q ../std/string/string.o 2>/dev/null || make -C compiler ../std/string/string.o
fi
XLANG=${XLANG:-./compiler/xlang}
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
LINK_XLANG="$RUN_XLANG"
# MSYS2/Alpine 默认栈偏小，string 测试链 std/heap 后易 SIGSEGV。
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

STRING_OUT="${TMPDIR:-/tmp}/xlang_string"

$LINK_XLANG build -L . tests/string/main.x -o "$STRING_OUT" 2>&1
exitcode=0; "$STRING_OUT" >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (string_empty), got $exitcode"; exit 1; }

$LINK_XLANG build -L . tests/string/from_slice_eq.x -o "${TMPDIR:-/tmp}/xlang_string_fs" 2>&1
exitcode=0; "${TMPDIR:-/tmp}/xlang_string_fs" >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (from_slice_eq), got $exitcode"; exit 1; }

$LINK_XLANG build -L . tests/string/compare_append_find.x -o "${TMPDIR:-/tmp}/xlang_string_caf" 2>&1
exitcode=0; "${TMPDIR:-/tmp}/xlang_string_caf" >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (compare_append_find), got $exitcode"; exit 1; }

$LINK_XLANG build -L . tests/string/contains_trim_replace.x -o "${TMPDIR:-/tmp}/xlang_string_ctr" 2>&1
exitcode=0; "${TMPDIR:-/tmp}/xlang_string_ctr" >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (contains_trim_replace), got $exitcode"; exit 1; }

$LINK_XLANG build -L . tests/string/view_zerocopy.x -o "${TMPDIR:-/tmp}/xlang_string_view" 2>&1
exitcode=0; "${TMPDIR:-/tmp}/xlang_string_view" >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (view_zerocopy), got $exitcode"; exit 1; }

echo "string test OK"
