#!/usr/bin/env bash
#
# 【文件职责】std.fmt 模块回归：main.x + format_multi.x（STD-019）
# 【运行方式】在仓库根目录执行 bash tests/run-fmt-std.sh
#
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make xlang-c
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

run_one() {
  local x="$1"
  local exe="/tmp/xlang_fmt_std_$$_${x##*/}"
  if ! $RUN_XLANG build -L . "$x" -o "$exe" 2>&1; then
    echo "fmt-std test: compile failed ($x)"
    rm -f "$exe"
    exit 1
  fi
  local exitcode=0
  $exe >/dev/null 2>&1 || exitcode=$?
  rm -f "$exe"
  if [ "$exitcode" -ne 0 ]; then
    echo "fmt-std test: expected exit 0 for $x, got $exitcode"
    exit 1
  fi
}

run_one tests/fmt-std/main.x
run_one tests/fmt-std/format_multi.x
run_one tests/fmt-std/print_scalar.x
run_one tests/fmt-std/print_any.x
run_one tests/fmt-std/print_u8_slc.x
echo "fmt-std test OK (incl. print_any JSON + print_u8_slc pointer ABI)"
