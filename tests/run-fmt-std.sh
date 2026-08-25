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

# i32[] must print JSON via schema A@ — exit0 alone hid empty/u8_slc fake-green.
run_one_i32_slc_json() {
  local x="tests/fmt-std/print_i32_slc.x"
  local exe="/tmp/xlang_fmt_std_$$_print_i32_slc"
  local out
  if ! $RUN_XLANG build -L . "$x" -o "$exe" 2>&1; then
    echo "fmt-std test: compile failed ($x)"
    rm -f "$exe"
    exit 1
  fi
  out="$($exe)" || { echo "fmt-std test: print_i32_slc run failed"; rm -f "$exe"; exit 1; }
  rm -f "$exe"
  echo "$out" | grep -q '\[10,20,30\]' || {
    echo "fmt-std test: print_i32_slc missing [10,20,30] JSON (got: $out)" >&2
    exit 1
  }
  echo "$out" | grep -q '\[1,2,3\]' || {
    echo "fmt-std test: print_i32_slc missing [1,2,3] JSON (got: $out)" >&2
    exit 1
  }
}

run_one tests/fmt-std/main.x
run_one tests/fmt-std/format_multi.x
run_one tests/fmt-std/print_scalar.x
run_one tests/fmt-std/print_any.x
run_one tests/fmt-std/print_u8_slc.x
run_one_i32_slc_json
echo "fmt-std test OK (incl. print_any JSON + print_u8_slc + print_i32_slc A@ schema)"
