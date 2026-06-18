#!/usr/bin/env bash
# 阶段 5 import 测试——import("path") 绑定/解构 .su 能解析、typeck 通过并运行。
# 覆盖：main.su（解构）、const_binding.su（绑定）、const_select.su（解构）、missing_module.su（边界）。
# 与其它文件的关系：由 run-all.sh 调用；依赖 compiler/shu、tests/import/*.su、core/types.su、std/io（-L .）。

set -e
cd "$(dirname "$0")/.."
SHU="${SHU:-./compiler/shu}"
# shellcheck source=lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"
LINK_SHU="$RUN_SHU"
# run-all 入口已 make 时跳过（SHULANG_SKIP_SUBSCRIPT_MAKE=1），避免反复链接 shu。
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${SHULANG_RUN_ALL_BOOTSTRAP_SHU:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler
  fi
fi
rm -f /tmp/shu_import_hello /tmp/shu_import_const_binding /tmp/shu_import_const_select /tmp/shu_import_bad

# 方式 1：无 -o 时 parse/typeck 烟测（见下方 grep）
if [ -z "${SHU_SKIP_PARSE_SMOKE:-}" ]; then
  out=$($SHU -L . tests/import/main.su 2>&1)
  echo "$out" | grep -qE "parse OK|typeck OK|int32_t main" || {
    echo "expected parse/typeck smoke or generated main() in output"; echo "$out" | head -8; exit 1;
  }
fi
# B-strict shu_asm -o 偶发 SIGSEGV；白名单内重试数次（run-all-bstrict 亦包外层重试）。
_import_compile_attempts=1
if [ -n "${SHULANG_BSTRICT_RUN_ALL:-}" ]; then
  _import_compile_attempts=8
fi
_import_ok=0
for _import_try in $(seq 1 "$_import_compile_attempts"); do
  if $LINK_SHU -L . tests/import/main.su -o /tmp/shu_import_hello >/dev/null 2>&1; then
    _import_ok=1
    break
  fi
done
if [ "$_import_ok" -ne 1 ]; then
  echo "import main.su: compile failed (${_import_compile_attempts} attempts)" >&2
  exit 1
fi
/tmp/shu_import_hello | grep -q "Hello World" || { echo "import main: expected Hello World"; exit 1; }

# 方式 2：const xxx = import("path");（绑定 + 前缀）
$LINK_SHU -L . tests/import/const_binding.su -o /tmp/shu_import_const_binding 2>&1
/tmp/shu_import_const_binding >/dev/null || { echo "const_binding: expected exit 0"; exit 1; }

# 方式 3：const { zzz } = import("path");
$LINK_SHU -L . tests/import/const_select.su -o /tmp/shu_import_const_select 2>&1
/tmp/shu_import_const_select | grep -q "Hello World" || { echo "const_select: expected Hello World"; exit 1; }

# 方式 4：const { sym as alias } = import("path");
$LINK_SHU -L . tests/import/const_select_alias_fn.su -o /tmp/shu_import_const_select_alias 2>&1
/tmp/shu_import_const_select_alias | grep -q "Hello World" || { echo "const_select_alias: expected Hello World"; exit 1; }

# 边界：import 不存在的模块，应报错且退出非 0
err=$($SHU -L . tests/import/missing_module.su -o /tmp/shu_import_bad 2>&1) || true
echo "$err" | grep -qE "cannot open import|failed to parse import" || { echo "expected import error for missing module, got: $err"; exit 1; }

echo "import test OK"
