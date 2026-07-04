#!/usr/bin/env bash
# 向量 i32x4/u32x4：0 初始化、数组字面量、逐分量加法
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
# vec_add_verify 引用 shux_string_memcmp_c；purge 后须显式编 std/string/string.o。
make -C compiler -q ../std/string/string.o 2>/dev/null \
  || make -C compiler ../std/string/string.o

# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
SHUX=${SHUX:-./compiler/shux}
LINK_SHUX="${RUN_SHUX:-$SHUX}"

$LINK_SHUX tests/vector/i32x4.x -o /tmp/shux_vec_i32x4 2>&1
exitcode=0
/tmp/shux_vec_i32x4 >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "run-vector FAIL: i32x4 expected exit 0, got $exitcode"; exit 1; }

$LINK_SHUX tests/vector/u32x4_lit.x -o /tmp/shux_vec_u32 2>&1
exitcode=0
/tmp/shux_vec_u32 >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "run-vector FAIL: u32x4_lit expected exit 0, got $exitcode"; exit 1; }

$LINK_SHUX tests/vector/vec_add.x -o /tmp/shux_vec_add 2>&1
exitcode=0
/tmp/shux_vec_add >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "run-vector FAIL: vec_add expected exit 0, got $exitcode"; exit 1; }

$LINK_SHUX tests/vector/vec_add_check.x -o /tmp/shux_vec_add_check 2>&1
exitcode=0
/tmp/shux_vec_add_check >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "run-vector FAIL: vec_add_check expected exit 0, got $exitcode"; exit 1; }

$LINK_SHUX tests/vector/vec_add_lit.x -o /tmp/shux_vec_add_lit 2>&1
exitcode=0
/tmp/shux_vec_add_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "run-vector FAIL: vec_add_lit expected exit 0, got $exitcode"; exit 1; }

$LINK_SHUX tests/vector/vec_copy.x -o /tmp/shux_vec_copy 2>&1
exitcode=0
/tmp/shux_vec_copy >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "run-vector FAIL: vec_copy expected exit 0, got $exitcode"; exit 1; }

$LINK_SHUX tests/vector/vec_add_verify.x -o /tmp/shux_vec_add_verify 2>&1
exitcode=0
/tmp/shux_vec_add_verify >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "run-vector FAIL: vec_add_verify expected exit 0, got $exitcode"; exit 1; }

$LINK_SHUX tests/vector/i32x16.x -o /tmp/shux_vec_i32x16 2>&1
exitcode=0
/tmp/shux_vec_i32x16 >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "run-vector FAIL: i32x16 expected exit 0, got $exitcode"; exit 1; }

echo "vector test OK"
