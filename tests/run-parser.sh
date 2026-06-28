#!/usr/bin/env bash
# 分号统一：语句结束必须加分号；仅 } 后可不加（} 后加也不报错）。正例：带分号通过；负例：return 后缺分号报错。
# `return (expr)` 在 `}` 前可省略分号：与 $SHUX（默认 ./compiler/shux，make test 常为 shux-c）共用 parser.c。
set -e
cd "$(dirname "$0")/.."
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
SHUX=${SHUX:-./compiler/shux}
# bstrict 前序脚本 make -C compiler 会把 shux 刷回 seed；parser 烟测须 stage2 asm（与 run-struct 策略一致）。
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -x ./compiler/shux_asm2 ]; then
  SHUX=./compiler/shux_asm2
elif [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -x ./compiler/shux_asm ]; then
  SHUX=./compiler/shux_asm
fi

# 负例诊断：seed asm 的 check 对 parse 失败常静默 exit 0；优先 parse/typeck 烟测（-L .）。
parser_expect_reject() {
  local sx="$1"
  local pattern="$2"
  local out
  out=$($SHUX -L . "$sx" 2>&1) || true
  if echo "$out" | grep -qE "$pattern"; then
    return 0
  fi
  out=$($SHUX check "$sx" 2>&1) || true
  echo "$out" | grep -qE "$pattern"
}

# 正例：return 0; 带分号应能编译
$SHUX -L . tests/parser/semicolon_required.sx -o /tmp/shux_parser_ok 2>&1 || { echo "parser: semicolon_required.sx (with semicolon) should compile"; exit 1; }
/tmp/shux_parser_ok || { echo "parser: semicolon_required binary should exit 0"; exit 1; }

# 负例：连续 return 间无分号应拒绝（impl 路径报 parse；buf 回退路径常落 typeck error）
if parser_expect_reject tests/parser/semicolon_missing.sx "expected ';' after return|parse produced no functions|typeck error"; then
  : # 预期报错
else
  echo "parser: expected parse error for missing semicolon between returns"
  exit 1
fi

# 负例：if 后缺少 '(' 应拒绝（同上：sx impl 或 buf 回退后 typeck 失败均可）
if parser_expect_reject tests/parser/if_missing_paren.sx "expected '\\(' after 'if'|parse produced no functions|typeck error"; then
  : # 预期报错
else
  echo "parser: expected parse error for if missing paren"
  exit 1
fi

# return (1+2) 无分号（`}` 前可略分号）：须正确建 AST 并得到退出码 3；与 compiler/shux、compiler/shux-c 共用 parser.c 时行为一致
$SHUX -L . tests/parser/return_paren_expr.sx -o /tmp/shux_parser_return_paren 2>&1 || {
  echo "parser: return_paren_expr.sx should compile with $SHUX"
  exit 1
}
exitcode=0
/tmp/shux_parser_return_paren >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 3 ]; then
  echo "parser: expected exit code 3 (return (1+2)), got $exitcode"
  exit 1
fi

# 负例：import 模块顶层 const 不得裸名访问
if parser_expect_reject tests/parser/async_const_bare_access.sx "must be qualified|typeck error"; then
  : # 预期报错
else
  echo "parser: expected typeck error for bare import const POLL_PENDING/POLL_READY"
  exit 1
fi

echo "parser test OK"
