#!/usr/bin/env bash
# 分号统一：语句结束须 `;` 或 ASI 后继为语句头（wave654–656）。正例：带分号通过；
# 负例：return 操作数后接 INT_LIT（非语句头，ASI 拒绝）。与 $XLANG 共用产品 parser。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
fi
XLANG=${XLANG:-./compiler/xlang}
# PLATFORM: SHARED — product bstrict / L4 must use this-SHA xlang_asm.
# Preferring leftover Stage2 xlang_asm2 over product is a July-14 wrong-binary path
# (stale gen2 can false-accept bad if / false-fail green cases). Opt-in only:
# XLANG_BSTRICT_USE_ASM2=1 (aligns with run-all-bstrict.sh).
if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ]; then
  if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && [ -x ./compiler/xlang_asm2 ]; then
    XLANG=./compiler/xlang_asm2
  elif [ -x ./compiler/xlang_asm ]; then
    XLANG=./compiler/xlang_asm
  fi
fi

# 负例诊断：seed asm 的 check 对 parse 失败常静默 exit 0；优先 parse/typeck 烟测（-L .）。
parser_expect_reject() {
  local x="$1"
  local pattern="$2"
  local out
  out=$($XLANG build -L . "$x" 2>&1) || true
  if echo "$out" | grep -qE "$pattern"; then
    return 0
  fi
  out=$($XLANG check "$x" 2>&1) || true
  echo "$out" | grep -qE "$pattern"
}

# 正例：return 0; 带分号应能编译
$XLANG build -L . tests/parser/semicolon_required.x -o /tmp/xlang_parser_ok 2>&1 || { echo "parser: semicolon_required.x (with semicolon) should compile"; exit 1; }
/tmp/xlang_parser_ok || { echo "parser: semicolon_required binary should exit 0"; exit 1; }

# 负例：return 操作数后接 INT_LIT（非语句头）应拒绝；bare 双 return 已由 Cap-T001+ASI 放行
if parser_expect_reject tests/parser/semicolon_missing.x "expected ';' after return|parse produced no functions|typeck error|pipeline failed|XP003"; then
  : # 预期报错
else
  echo "parser: expected parse error for return operand then INT_LIT (ASI refuse)"
  exit 1
fi

# 负例：statement `if` 缺条件（fixture 名历史遗留；if-expr 无需括号故已改体）
if parser_expect_reject tests/parser/if_missing_paren.x "expected|parse produced no functions|typeck error|P00[0-9]+|parse error"; then
  : # 预期报错
else
  echo "parser: expected parse error for incomplete if statement"
  exit 1
fi

# 负例：check 模式对坏源至少输出一条 parse 诊断（多错恢复仍在演进；
# 旧期望含 expected '(' after if / aborting due to 已与 if-expr 合法语义漂移）。
multi_out=$($XLANG check tests/parser/multi_error_recovery.x 2>&1) || true
if echo "$multi_out" | grep -qE "error\[P00|expected ';' after let|parse error|P001" \
  && ! echo "$multi_out" | grep -q "parse_primary:"; then
  : # 预期至少一条 parse 诊断、无内部 dump 刷屏
else
  echo "parser: expected parse diagnostics in check mode for multi_error_recovery"
  echo "$multi_out"
  exit 1
fi

# 负例：块内控制语句错误后应恢复到下一条语句，继续输出 defer/region 的后续错误
control_out=$($XLANG check tests/parser/control_stmt_recovery.x 2>&1) || true
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
top_out=$($XLANG check tests/parser/top_level_recovery.x 2>&1) || true
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
unsafe_out=$($XLANG check tests/parser/unsafe_stmt_recovery.x 2>&1) || true
if echo "$unsafe_out" | grep -q "expected '{' after unsafe" \
  && ! echo "$unsafe_out" | grep -q "expected ';' after expression"; then
  : # 预期 unsafe 专项诊断
else
  echo "parser: expected dedicated unsafe diagnostic in check mode"
  echo "$unsafe_out"
  exit 1
fi

# 负例：import 预扫描段出错后应恢复到后续顶层声明继续报错
import_out=$($XLANG check tests/parser/import_recovery.x 2>&1) || true
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

# return (1+2) 无分号（`}` 前可略分号）：须正确建 AST 并得到退出码 3；与 compiler/xlang、compiler/xlang-c 共用 parser.c 时行为一致
$XLANG build -L . tests/parser/return_paren_expr.x -o /tmp/xlang_parser_return_paren 2>&1 || {
  echo "parser: return_paren_expr.x should compile with $XLANG"
  exit 1
}
exitcode=0
/tmp/xlang_parser_return_paren >/dev/null 2>&1 || exitcode=$?
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
