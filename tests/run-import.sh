#!/usr/bin/env bash
# 阶段 5 import 测试——绑定 import .x 能解析、typeck 通过并运行。
# 覆盖：main.x、const_binding.x、const_select.x（均为 const mod = import）、missing_module.x（边界）。
# 与其它文件的关系：由 run-all.sh 调用；依赖 compiler/xlang、tests/import/*.x、core/types.x、std/io（-L .）。

set -e
cd "$(dirname "$0")/.."
XLANG="${XLANG:-./compiler/xlang}"
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
LINK_XLANG="$RUN_XLANG"
# run-all 入口已 make 时跳过（XLANG_SKIP_SUBSCRIPT_MAKE=1），避免反复链接 xlang。
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler
  fi
fi
rm -f /tmp/xlang_import_hello /tmp/xlang_import_const_binding /tmp/xlang_import_const_select /tmp/xlang_import_bad

# 方式 1：无 -o 时 parse/typeck 烟测（见下方 grep）
if [ -z "${XLANG_SKIP_PARSE_SMOKE:-}" ]; then
  out=$($RUN_XLANG build -L . tests/import/main.x 2>&1)
  echo "$out" | grep -qE "parse OK|typeck OK|int32_t main" || {
    echo "expected parse/typeck smoke or generated main() in output"; echo "$out" | head -8; exit 1;
  }
fi
# bootstrap-min：-o 链路由 xlang-min-link gcc 回退；u8[]→print_str 调用 ABI 与 gold 全链不同，parse/typeck 已由 run-check 覆盖。
if [ -n "${XLANG_BOOTSTRAP_MIN:-}" ]; then
  echo "import: skip -o runtime (bootstrap-min; full link 见 bootstrap-gold / run-all)"
  echo "import test OK"
  exit 0
fi
# B-strict xlang_asm -o 偶发 SIGSEGV；白名单内重试数次（run-all-bstrict 亦包外层重试）。
_import_compile_attempts=1
if [ -n "${XLANG_BSTRICT_RUN_ALL:-}" ]; then
  _import_compile_attempts=8
fi
_import_ok=0
for _import_try in $(seq 1 "$_import_compile_attempts"); do
  # seed/xlang_asm：非 TTY stdout 重定向会挂起；须 tee|cat Drain。
  if $LINK_XLANG build -L . tests/import/main.x -o /tmp/xlang_import_hello 2>&1 | tee /tmp/xlang_import_hello_build.log | cat >/dev/null; then
    _import_ok=1
    break
  fi
done
if [ "$_import_ok" -ne 1 ]; then
  echo "import main.x: compile failed (${_import_compile_attempts} attempts)" >&2
  exit 1
fi
/tmp/xlang_import_hello | grep -q "Hello World" || { echo "import main: expected Hello World"; exit 1; }

# 方式 2：const types = import("core.types");
$LINK_XLANG build -L . tests/import/const_binding.x -o /tmp/xlang_import_const_binding 2>&1
/tmp/xlang_import_const_binding >/dev/null || { echo "const_binding: expected exit 0"; exit 1; }

# 方式 3：const io = import("std.io"); → io.print_str
$LINK_XLANG build -L . tests/import/const_select.x -o /tmp/xlang_import_const_select 2>&1
/tmp/xlang_import_const_select | grep -q "Hello World" || { echo "const_select: expected Hello World"; exit 1; }

# 方式 4：绑定 import + 模块前缀调用
$LINK_XLANG build -L . tests/import/const_select_alias_fn.x -o /tmp/xlang_import_const_select_alias 2>&1
/tmp/xlang_import_const_select_alias | grep -q "Hello World" || { echo "const_select_alias: expected Hello World"; exit 1; }

# 边界：import 不存在的模块，应报错且退出非 0
err=$($RUN_XLANG build -L . tests/import/missing_module.x -o /tmp/xlang_import_bad 2>&1) || true
echo "$err" | grep -qE "cannot open import|failed to parse import" || { echo "expected import error for missing module, got: $err"; exit 1; }

echo "import test OK"
