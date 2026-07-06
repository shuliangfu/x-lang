#!/usr/bin/env bash
#
# 【文件职责】std.fmt 模块回归：main.x + format_multi.x（STD-019）
# 【运行方式】在仓库根目录执行 bash tests/run-fmt-std.sh
#
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shux-c
# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"

run_one() {
  local x="$1"
  local exe="/tmp/shux_fmt_std_$$_${su##*/}"
  if ! $RUN_SHUX -L . "$x" -o "$exe" 2>&1; then
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
# print_any.x 是 println(struct) 前瞻性测试，该特性尚未实现（需 Display trait / JSON 风格格式化）
echo "fmt-std test OK (print_any.x skipped: println(struct) not yet implemented)"
