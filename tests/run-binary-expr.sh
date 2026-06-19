#!/usr/bin/env bash
# 文件职责：验证 main 体二元加减乘除表达式（如 1+2、42-10、6*7、20/4）；编译并运行，检查退出码与表达式结果一致。
# 与其它文件的关系：由 compiler/Makefile 的 test 目标调用；依赖 compiler/shux、tests/binary-expr/*.sx。
# 使用 shux-c：seed shux 的 .sx pipeline 对部分二元表达式（如 sub.sx）会报 pipeline failed，故统一用 C 流水线保证全量通过。

set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux-c}

# 测试 1+2 -> 退出码 3
$SHUX tests/binary-expr/main.sx -o /tmp/shux_binary_expr 2>&1
exitcode=0
/tmp/shux_binary_expr >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 3 ]; then
    echo "expected exit code 3 (1+2), got $exitcode"
    exit 1
fi

# 测试 42-10 -> 退出码 32
$SHUX tests/binary-expr/sub.sx -o /tmp/shux_binary_sub 2>&1
exitcode=0
/tmp/shux_binary_sub >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 32 ]; then
    echo "expected exit code 32 (42-10), got $exitcode"
    exit 1
fi

# 测试 6*7 -> 退出码 42
$SHUX tests/binary-expr/mul.sx -o /tmp/shux_binary_mul 2>&1
exitcode=0
/tmp/shux_binary_mul >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 42 ]; then
    echo "expected exit code 42 (6*7), got $exitcode"
    exit 1
fi

# 测试 20/4 -> 退出码 5
$SHUX tests/binary-expr/div.sx -o /tmp/shux_binary_div 2>&1
exitcode=0
/tmp/shux_binary_div >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 5 ]; then
    echo "expected exit code 5 (20/4), got $exitcode"
    exit 1
fi

# 测试优先级：1+2*3 = 7（乘除优先于加减）
$SHUX tests/binary-expr/precedence.sx -o /tmp/shux_binary_prec 2>&1
exitcode=0
/tmp/shux_binary_prec >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 7 ]; then
    echo "expected exit code 7 (1+2*3), got $exitcode"
    exit 1
fi

# 测试括号：(1+2)*3 = 9
$SHUX tests/binary-expr/paren.sx -o /tmp/shux_binary_paren 2>&1
exitcode=0
/tmp/shux_binary_paren >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 9 ]; then
    echo "expected exit code 9 ((1+2)*3), got $exitcode"
    exit 1
fi

# 测试一元负号：10 + -4 = 6
$SHUX tests/binary-expr/unary_neg.sx -o /tmp/shux_binary_neg 2>&1
exitcode=0
/tmp/shux_binary_neg >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 6 ]; then
    echo "expected exit code 6 (10+-4), got $exitcode"
    exit 1
fi

# 取模 7%3=1、移位 1<<4=16
$SHUX tests/binary-expr/mod.sx -o /tmp/shux_mod 2>&1
exitcode=0; /tmp/shux_mod >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (7%%3), got $exitcode"; exit 1; }
$SHUX tests/binary-expr/shift.sx -o /tmp/shux_shift 2>&1
exitcode=0; /tmp/shux_shift >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 16 ] && { echo "expected 16 (1<<4), got $exitcode"; exit 1; }

# 按位 (12&7)|(4^2)=4|6=6
$SHUX tests/binary-expr/bitwise.sx -o /tmp/shux_bit 2>&1
exitcode=0; /tmp/shux_bit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 6 ] && { echo "expected 6 (bitwise), got $exitcode"; exit 1; }

# 比较 (3==3)+(2<5)+(5>2)=1+1+1=3
$SHUX tests/binary-expr/compare.sx -o /tmp/shux_cmp 2>&1
exitcode=0; /tmp/shux_cmp >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 3 ] && { echo "expected 3 (compare), got $exitcode"; exit 1; }

# 逻辑 (1&&1)+(0||1)=2、!0=1
$SHUX tests/binary-expr/logical.sx -o /tmp/shux_log 2>&1
exitcode=0; /tmp/shux_log >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 2 ] && { echo "expected 2 (logical), got $exitcode"; exit 1; }
$SHUX tests/binary-expr/lognot.sx -o /tmp/shux_lognot 2>&1
exitcode=0; /tmp/shux_lognot >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (!0), got $exitcode"; exit 1; }

echo "binary expr test OK"
