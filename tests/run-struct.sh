#!/usr/bin/env bash
# 结构体：定义、字面量、字段访问、allow(padding)；负例：未 allow 的隐式 padding 报错
set -e
cd "$(dirname "$0")/.."
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
SHU=${SHU:-./compiler/shu}
# shellcheck source=lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"
LINK_SHU="$RUN_SHU"

$LINK_SHU tests/struct/simple.su -o /tmp/shu_struct_simple 2>&1
exitcode=0; /tmp/shu_struct_simple >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (struct simple p.x), got $exitcode"; exit 1; }

$LINK_SHU tests/struct/padding_allow.su -o /tmp/shu_struct_pad 2>&1
exitcode=0; /tmp/shu_struct_pad >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 2 ] && { echo "expected 2 (padding_allow x.b), got $exitcode"; exit 1; }

if $SHU tests/struct/padding_no_allow.su -o /tmp/shu_struct_fail 2>&1 | grep -q "implicit padding"; then
  : # 预期 typeck 报错
else
  echo "expected typeck error for struct without allow(padding)"
  exit 1
fi

# packed 结构体（memory-contract）：无隐式 padding
$LINK_SHU tests/memory-contract/packed_struct.su -o /tmp/shu_struct_packed 2>&1
exitcode=0; /tmp/shu_struct_packed >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (packed struct), got $exitcode"; exit 1; }

# add_pair 字段求和 CALL 内联（可变 struct 字段，return 12）
$LINK_SHU tests/boundary/struct_add_pair_inline.su -o /tmp/shu_struct_add_pair_inline 2>&1
exitcode=0; /tmp/shu_struct_add_pair_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 12 ] && { echo "expected 12 (struct_add_pair_inline), got $exitcode"; exit 1; }

# get_a 单字段 CALL 内联（可变 struct 字段，return 0+1+2+3+4=10）
$LINK_SHU tests/boundary/struct_get_field_inline.su -o /tmp/shu_struct_get_field_inline 2>&1
exitcode=0; /tmp/shu_struct_get_field_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 10 ] && { echo "expected 10 (struct_get_field_inline), got $exitcode"; exit 1; }

# get_a(mk(i,2)) 嵌套内联（struct 按值返回 + 单字段，return 10）
$LINK_SHU tests/boundary/struct_mk_field_inline.su -o /tmp/shu_struct_mk_field_inline 2>&1
exitcode=0; /tmp/shu_struct_mk_field_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 10 ] && { echo "expected 10 (struct_mk_field_inline), got $exitcode"; exit 1; }

# add_pair(mk(i,2)) 嵌套内联（struct 按值返回 + 字段求和，return 20）
$LINK_SHU tests/boundary/struct_mk_pair_sum_inline.su -o /tmp/shu_struct_mk_pair_sum_inline 2>&1
exitcode=0; /tmp/shu_struct_mk_pair_sum_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 20 ] && { echo "expected 20 (struct_mk_pair_sum_inline), got $exitcode"; exit 1; }

# let p = mk(...) 独立内联 + 字段读（return 1+2+3+4=10）
$LINK_SHU tests/boundary/struct_mk_let_inline.su -o /tmp/shu_struct_mk_let_inline 2>&1
exitcode=0; /tmp/shu_struct_mk_let_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 10 ] && { echo "expected 10 (struct_mk_let_inline), got $exitcode"; exit 1; }

# while 体内 let p = mk(...); 累加字段（return 0+2 + 1+3 + 2+4 = 9）
$LINK_SHU tests/boundary/struct_mk_while_let_inline.su -o /tmp/shu_struct_mk_while_let_inline 2>&1
exitcode=0; /tmp/shu_struct_mk_while_let_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 9 ] && { echo "expected 9 (struct_mk_while_let_inline), got $exitcode"; exit 1; }

# while 体内 if-then 嵌套 let + 赋值（return 10）
$LINK_SHU tests/boundary/while_if_nested_let.su -o /tmp/shu_while_if_nested_let 2>&1
exitcode=0; /tmp/shu_while_if_nested_let >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 10 ] && { echo "expected 10 (while_if_nested_let), got $exitcode"; exit 1; }

echo "struct test OK"
