#!/usr/bin/env bash
# 验证 while 循环：条件为假时不执行体，最终表达式作为返回值。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
# -o 链接走 RUN_SHUX（bootstrap 下非 x86_64 为 shux-c）；typeck 负例仍用 seed SHU。
LINK_SHUX="$RUN_SHUX"
TYPECK_SHUX="${TYPECK_SHUX:-$SHUX}"

# while 0 { 1 }; 42 -> 42（循环不执行）
$LINK_SHUX tests/while/never.sx -o /tmp/shux_while_never 2>&1
exitcode=0
/tmp/shux_while_never >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "expected 42 (while never), got $exitcode"; exit 1; }

# while 1 { break }; 42 -> 42（break 跳出循环）
$LINK_SHUX tests/while/break_out.sx -o /tmp/shux_while_break 2>&1
exitcode=0
/tmp/shux_while_break >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "expected 42 (while break), got $exitcode"; exit 1; }

# while 0 { continue }; 42 -> 42（循环不执行，continue 不执行）
$LINK_SHUX tests/while/continue_never.sx -o /tmp/shux_while_cont 2>&1
exitcode=0
/tmp/shux_while_cont >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "expected 42 (continue never), got $exitcode"; exit 1; }

# loop { break }; 42 -> 42（无限循环用 break 退出）
$LINK_SHUX tests/while/loop_break.sx -o /tmp/shux_loop_break 2>&1
exitcode=0
/tmp/shux_loop_break >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "expected 42 (loop break), got $exitcode"; exit 1; }

# break 不在循环体内 -> typeck 报错
if $TYPECK_SHUX tests/while/break_outside.sx -o /tmp/shux_break_out 2>&1 | grep -q "only allowed inside a loop"; then
  : "break outside loop correctly rejected"
else
  echo "expected typeck error for break outside loop"
  exit 1
fi

# while 体内 index + as cast（path[i] as i32 / arr[i] as i32）
$LINK_SHUX tests/while/index_as_cast.sx -o /tmp/shux_while_index_as 2>&1
exitcode=0
/tmp/shux_while_index_as >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 60 ] && { echo "expected 60 (10+20+30+0), got $exitcode"; exit 1; }

echo "while test OK"
