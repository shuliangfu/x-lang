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
  local x="$1"
  local pattern="$2"
  local out
  out=$($SHUX -L . "$x" 2>&1) || true
  if echo "$out" | grep -qE "$pattern"; then
    return 0
  fi
  out=$($SHUX check "$x" 2>&1) || true
  echo "$out" | grep -qE "$pattern"
}

# 正例：return 0; 带分号应能编译
$SHUX -L . tests/parser/semicolon_required.x -o /tmp/shux_parser_ok 2>&1 || { echo "parser: semicolon_required.x (with semicolon) should compile"; exit 1; }
/tmp/shux_parser_ok || { echo "parser: semicolon_required binary should exit 0"; exit 1; }

# 负例：连续 return 间无分号应拒绝（impl 路径报 parse；buf 回退路径常落 typeck error）
if parser_expect_reject tests/parser/semicolon_missing.x "expected ';' after return|parse produced no functions|typeck error"; then
  : # 预期报错
else
  echo "parser: expected parse error for missing semicolon between returns"
  exit 1
fi

# 负例：if 后缺少 '(' 应拒绝（同上：x impl 或 buf 回退后 typeck 失败均可）
if parser_expect_reject tests/parser/if_missing_paren.x "expected '\\(' after 'if'|parse produced no functions|typeck error"; then
  : # 预期报错
else
  echo "parser: expected parse error for if missing paren"
  exit 1
fi

# 负例：check 模式下 parser 应能同步恢复并连续输出多条错误，而不是首错即停或刷屏超时
multi_out=$($SHUX check tests/parser/multi_error_recovery.x 2>&1) || true
if echo "$multi_out" | grep -q "expected ';' after let" \
  && echo "$multi_out" | grep -q "expected '(' after 'if'" \
  && echo "$multi_out" | grep -q "aborting due to" \
  && ! echo "$multi_out" | grep -q "parse_primary:"; then
  : # 预期多错误恢复
else
  echo "parser: expected multi-error recovery diagnostics in check mode"
  echo "$multi_out"
  exit 1
fi

# 负例：块内控制语句错误后应恢复到下一条语句，继续输出 defer/region 的后续错误
control_out=$($SHUX check tests/parser/control_stmt_recovery.x 2>&1) || true
if echo "$control_out" | grep -q "expected '{' after defer" \
  && echo "$control_out" | grep -q "expected region label after region" \
  && echo "$control_out" | grep -q "aborting due to" \
  && ! echo "$control_out" | grep -q "parse_primary:"; then
  : # 预期控制语句恢复
else
  echo "parser: expected control statement recovery diagnostics in check mode"
  echo "$control_out"
  exit 1
fi

# 负例：顶层声明错误后应恢复到下一条顶层声明，而不是整模块首错即停
top_out=$($SHUX check tests/parser/top_level_recovery.x 2>&1) || true
if echo "$top_out" | grep -q "expected ';' after top-level const" \
  && echo "$top_out" | grep -q "expected '{' before function body" \
  && echo "$top_out" | grep -q "aborting due to" \
  && ! echo "$top_out" | grep -q "parse_primary:"; then
  : # 预期顶层恢复
else
  echo "parser: expected top-level recovery diagnostics in check mode"
  echo "$top_out"
  exit 1
fi

# 负例：裸 unsafe 应命中专门语句诊断，而不是退化成通用表达式/分号错误
unsafe_out=$($SHUX check tests/parser/unsafe_stmt_recovery.x 2>&1) || true
if echo "$unsafe_out" | grep -q "expected '{' after unsafe" \
  && ! echo "$unsafe_out" | grep -q "expected ';' after expression"; then
  : # 预期 unsafe 专项诊断
else
  echo "parser: expected dedicated unsafe diagnostic in check mode"
  echo "$unsafe_out"
  exit 1
fi

# 负例：import 预扫描段出错后应恢复到后续顶层声明继续报错
import_out=$($SHUX check tests/parser/import_recovery.x 2>&1) || true
if echo "$import_out" | grep -q "expected const x = import(\"path\")" \
  && echo "$import_out" | grep -q "expected '{' before function body" \
  && echo "$import_out" | grep -q "aborting due to" \
  && ! echo "$import_out" | grep -q "parse_primary:"; then
  : # 预期 import 预扫描恢复
else
  echo "parser: expected import pre-scan recovery diagnostics in check mode"
  echo "$import_out"
  exit 1
fi

# return (1+2) 无分号（`}` 前可略分号）：须正确建 AST 并得到退出码 3；与 compiler/shux、compiler/shux-c 共用 parser.c 时行为一致
$SHUX -L . tests/parser/return_paren_expr.x -o /tmp/shux_parser_return_paren 2>&1 || {
  echo "parser: return_paren_expr.x should compile with $SHUX"
  exit 1
}
exitcode=0
/tmp/shux_parser_return_paren >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 3 ]; then
  echo "parser: expected exit code 3 (return (1+2)), got $exitcode"
  exit 1
fi

# 负例：import 模块顶层 const 不得裸名访问
if parser_expect_reject tests/parser/async_const_bare_access.x "must be qualified|typeck error"; then
  : # 预期报错
else
  echo "parser: expected typeck error for bare import const POLL_PENDING/POLL_READY"
  exit 1
fi

echo "parser test OK"
