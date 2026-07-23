#!/usr/bin/env bash
# 【文件职责】std.dynlib 回归：open(null) + open/sym/close 烟测（STD-027）
set -e
cd "$(dirname "$0")/.."
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
  make -C compiler -q ../std/dynlib/dynlib.o 2>/dev/null || make -C compiler ../std/dynlib/dynlib.o
  make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c
fi

# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

run_one() {
  local src="$1"
  local label="$2"
  local exe="/tmp/xlang_dynlib_$$_${label}"
  if ! $RUN_XLANG build -L . "$src" -o "$exe" 2>&1; then
    echo "dynlib test ($label): compile failed"
    rm -f "$exe"
    exit 1
  fi
  local exitcode=0
  $exe 2>/dev/null || exitcode=$?
  rm -f "$exe"
  if [ "$exitcode" -ne 0 ]; then
    echo "dynlib test ($label): expected exit 0, got $exitcode"
    exit 1
  fi
  echo "dynlib test OK ($label)"
}

run_one tests/dynlib/main.x null
run_one tests/dynlib/open_sym_close.x open_sym_close
run_one tests/dynlib/last_error.x last_error
echo "dynlib test OK (all)"
rm -f /tmp/xlang_dynlib_$$_*
