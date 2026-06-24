#!/usr/bin/env bash
#
# 【文件职责】std.fmt 模块回归：main.sx + format_multi.sx（STD-019）
# 【运行方式】在仓库根目录执行 bash tests/run-fmt-std.sh
#
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shux-c
# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"

run_one() {
  local sx="$1"
  local exe="/tmp/shux_fmt_std_$$_${su##*/}"
  if ! $RUN_SHUX -L . "$sx" -o "$exe" 2>&1; then
    echo "fmt-std test: compile failed ($sx)"
    rm -f "$exe"
    exit 1
  fi
  local exitcode=0
  $exe >/dev/null 2>&1 || exitcode=$?
  rm -f "$exe"
  if [ "$exitcode" -ne 0 ]; then
    echo "fmt-std test: expected exit 0 for $sx, got $exitcode"
    exit 1
  fi
}

run_one tests/fmt-std/main.sx
run_one tests/fmt-std/format_multi.sx
run_one tests/fmt-std/print_scalar.sx
run_one tests/fmt-std/print_any.sx
echo "fmt-std test OK"
