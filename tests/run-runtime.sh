#!/usr/bin/env bash
# 【文件职责】std.runtime 回归：runtime_ready + panic_hook_align（STD-028）
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
xlang_compiler_make -q ../std/runtime/runtime.o 2>/dev/null || xlang_compiler_make ../std/runtime/runtime.o
xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c

# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

run_one() {
  local src="$1"
  local label="$2"
  local exe="/tmp/xlang_runtime_$$_${label}"
  if ! $RUN_XLANG build -L . "$src" -o "$exe" 2>&1; then
    echo "runtime test ($label): compile failed"
    rm -f "$exe"
    exit 1
  fi
  local exitcode=0
  $exe >/dev/null 2>&1 || exitcode=$?
  rm -f "$exe"
  if [ "$exitcode" -ne 0 ]; then
    echo "runtime test ($label): expected exit 0, got $exitcode"
    exit 1
  fi
  echo "runtime test OK ($label)"
}

run_one tests/runtime/main.x ready
run_one tests/exc/panic_hook_align.x panic_hook
echo "runtime test OK (all)"
rm -f /tmp/xlang_runtime_$$_*
