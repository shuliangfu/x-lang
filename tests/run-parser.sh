#!/usr/bin/env bash
# 分号统一：语句结束必须加分号；仅 } 后可不加（} 后加也不报错）。正例：带分号通过；负例：return 后缺分号报错。
# `return (expr)` 在 `}` 前可省略分号：与 $SHU（默认 ./compiler/shu，make test 常为 shu-c）共用 parser.c。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHU=${SHU:-./compiler/shu}

# 正例：return 0; 带分号应能编译
$SHU tests/parser/semicolon_required.su -o /tmp/shu_parser_ok 2>&1 || { echo "parser: semicolon_required.su (with semicolon) should compile"; exit 1; }
/tmp/shu_parser_ok || { echo "parser: semicolon_required binary should exit 0"; exit 1; }

# 负例：return 后无分号应报 parse error
if $SHU tests/parser/semicolon_missing.su -o /tmp/shu_parser_fail 2>&1 | grep -q "expected ';' after return"; then
  : # 预期报错
else
  echo "parser: expected parse error for missing semicolon after return"
  exit 1
fi

# 负例：if 后缺少 '(' 应报 parse error
if $SHU tests/parser/if_missing_paren.su -o /tmp/shu_parser_fail2 2>&1 | grep -q "expected '(' after 'if'"; then
  : # 预期报错
else
  echo "parser: expected parse error for if missing paren"
  exit 1
fi

# return (1+2) 无分号（`}` 前可略分号）：须正确建 AST 并得到退出码 3；与 compiler/shu、compiler/shu-c 共用 parser.c 时行为一致
$SHU tests/parser/return_paren_expr.su -o /tmp/shu_parser_return_paren 2>&1 || {
  echo "parser: return_paren_expr.su should compile with $SHU"
  exit 1
}
exitcode=0
/tmp/shu_parser_return_paren >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 3 ]; then
  echo "parser: expected exit code 3 (return (1+2)), got $exitcode"
  exit 1
fi

echo "parser test OK"
