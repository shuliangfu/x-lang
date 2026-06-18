#!/usr/bin/env bash
#
# 【文件职责】std.fmt 模块回归：main.su + format_multi.su（STD-019）
# 【运行方式】在仓库根目录执行 bash tests/run-fmt-std.sh
#
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shu-c
# shellcheck source=tests/lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"

run_one() {
  local su="$1"
  local exe="/tmp/shu_fmt_std_$$_${su##*/}"
  if ! $RUN_SHU -L . "$su" -o "$exe" 2>&1; then
    echo "fmt-std test: compile failed ($su)"
    rm -f "$exe"
    exit 1
  fi
  local exitcode=0
  $exe >/dev/null 2>&1 || exitcode=$?
  rm -f "$exe"
  if [ "$exitcode" -ne 0 ]; then
    echo "fmt-std test: expected exit 0 for $su, got $exitcode"
    exit 1
  fi
}

run_one tests/fmt-std/main.su
run_one tests/fmt-std/format_multi.su
echo "fmt-std test OK"
