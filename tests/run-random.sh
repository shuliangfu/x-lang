#!/usr/bin/env bash
#
# 【文件职责】std.random 模块的回归测试脚本；编译并运行 tests/random/*.x，校验退出码。
# 【测试目的】覆盖 fill_bytes、u32、u64、range_u32、bool，确保 API 行为符合预期。
# 【运行方式】在仓库根目录执行 ./tests/run-random.sh；可选环境变量 XLANG 指定编译器路径。
#
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
fi

XLANG="${XLANG:-./compiler/xlang}"
run_one() {
  local name="$1"
  local src="$2"
  local exe="/tmp/xlang_random_$$_${name}"
  if ! $XLANG build -L . "$src" -o "$exe" 2>&1; then
    echo "random test $name: compile failed"
    return 1
  fi
  local exitcode=0
  $exe >/dev/null 2>&1 || exitcode=$?
  rm -f "$exe"
  if [ "$exitcode" -ne 0 ]; then
    echo "random test $name: expected exit 0, got $exitcode"
    return 1
  fi
  return 0
}

run_one "main" "tests/random/main.x" || exit 1

echo "random test OK (all)"
rm -f /tmp/xlang_random_$$_*
