#!/usr/bin/env bash
# 测试 std.string：string_empty、string_from_slice/eq/len、string_compare/append/find/starts_with/ends_with/copy_to
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/string/string.o
SHU=${SHU:-./compiler/shu}

$SHU -L . tests/string/main.su -o /tmp/shu_string 2>&1
exitcode=0; /tmp/shu_string >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (string_empty), got $exitcode"; exit 1; }

$SHU -L . tests/string/from_slice_eq.su -o /tmp/shu_string_fs 2>&1
exitcode=0; /tmp/shu_string_fs >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (from_slice_eq), got $exitcode"; exit 1; }

$SHU -L . tests/string/compare_append_find.su -o /tmp/shu_string_caf 2>&1
exitcode=0; /tmp/shu_string_caf >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (compare_append_find), got $exitcode"; exit 1; }

$SHU -L . tests/string/contains_trim_replace.su -o /tmp/shu_string_ctr 2>&1
exitcode=0; /tmp/shu_string_ctr >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (contains_trim_replace), got $exitcode"; exit 1; }

$SHU -L . tests/string/view_zerocopy.su -o /tmp/shu_string_view 2>&1
exitcode=0; /tmp/shu_string_view >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (view_zerocopy), got $exitcode"; exit 1; }

echo "string test OK"
