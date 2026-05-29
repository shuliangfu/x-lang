#!/usr/bin/env bash
# 结构体：定义、字面量、字段访问、allow(padding)；负例：未 allow 的隐式 padding 报错
set -e
cd "$(dirname "$0")/.."
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
SHU=${SHU:-./compiler/shu}

$SHU tests/struct/simple.su -o /tmp/shu_struct_simple 2>&1
exitcode=0; /tmp/shu_struct_simple >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (struct simple p.x), got $exitcode"; exit 1; }

$SHU tests/struct/padding_allow.su -o /tmp/shu_struct_pad 2>&1
exitcode=0; /tmp/shu_struct_pad >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 2 ] && { echo "expected 2 (padding_allow x.b), got $exitcode"; exit 1; }

if $SHU tests/struct/padding_no_allow.su -o /tmp/shu_struct_fail 2>&1 | grep -q "implicit padding"; then
  : # 预期 typeck 报错
else
  echo "expected typeck error for struct without allow(padding)"
  exit 1
fi

# packed 结构体（memory-contract）：无隐式 padding
$SHU tests/memory-contract/packed_struct.su -o /tmp/shu_struct_packed 2>&1
exitcode=0; /tmp/shu_struct_packed >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (packed struct), got $exitcode"; exit 1; }

# add_pair 字段求和 CALL 内联（可变 struct 字段，return 12）
$SHU tests/boundary/struct_add_pair_inline.su -o /tmp/shu_struct_add_pair_inline 2>&1
exitcode=0; /tmp/shu_struct_add_pair_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 12 ] && { echo "expected 12 (struct_add_pair_inline), got $exitcode"; exit 1; }

echo "struct test OK"
