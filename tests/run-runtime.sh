#!/usr/bin/env bash
# 【文件职责】std.runtime 回归：runtime_ready + panic_hook_align（STD-028）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler -q ../std/runtime/runtime.o 2>/dev/null || make -C compiler ../std/runtime/runtime.o
make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c

# shellcheck source=tests/lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"

run_one() {
  local src="$1"
  local label="$2"
  local exe="/tmp/shu_runtime_$$_${label}"
  if ! $RUN_SHU -L . "$src" -o "$exe" 2>&1; then
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

run_one tests/runtime/main.su ready
run_one tests/exc/panic_hook_align.su panic_hook
echo "runtime test OK (all)"
rm -f /tmp/shu_runtime_$$_*
