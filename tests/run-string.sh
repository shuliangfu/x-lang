#!/usr/bin/env bash
# 测试 std.string：string_empty、string_from_slice/eq/len、string_compare/append/find/starts_with/ends_with/copy_to
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/string/string.o
SHU=${SHU:-./compiler/shu}
# shellcheck source=lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"
LINK_SHU="$RUN_SHU"
# MSYS2/Alpine 默认栈偏小，string 测试链 std/heap 后易 SIGSEGV。
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

STRING_OUT="${TMPDIR:-/tmp}/shu_string"

$LINK_SHU -L . tests/string/main.su -o "$STRING_OUT" 2>&1
exitcode=0; "$STRING_OUT" >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (string_empty), got $exitcode"; exit 1; }

$LINK_SHU -L . tests/string/from_slice_eq.su -o "${TMPDIR:-/tmp}/shu_string_fs" 2>&1
exitcode=0; "${TMPDIR:-/tmp}/shu_string_fs" >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (from_slice_eq), got $exitcode"; exit 1; }

$LINK_SHU -L . tests/string/compare_append_find.su -o "${TMPDIR:-/tmp}/shu_string_caf" 2>&1
exitcode=0; "${TMPDIR:-/tmp}/shu_string_caf" >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (compare_append_find), got $exitcode"; exit 1; }

$LINK_SHU -L . tests/string/contains_trim_replace.su -o "${TMPDIR:-/tmp}/shu_string_ctr" 2>&1
exitcode=0; "${TMPDIR:-/tmp}/shu_string_ctr" >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (contains_trim_replace), got $exitcode"; exit 1; }

$LINK_SHU -L . tests/string/view_zerocopy.su -o "${TMPDIR:-/tmp}/shu_string_view" 2>&1
exitcode=0; "${TMPDIR:-/tmp}/shu_string_view" >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (view_zerocopy), got $exitcode"; exit 1; }

echo "string test OK"
