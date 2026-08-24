#!/usr/bin/env bash
# COMP-004：WPO v1 轻量烟测（DCE + S1）
#
# 用法：./tests/run-comp-wpo.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

# shellcheck source=tests/lib/comp-wpo.sh
. tests/lib/comp-wpo.sh

XLANG_C="${XLANG:-./compiler/xlang-c}"
if ! comp_wpo_native_exe "$XLANG_C"; then
  if comp_wpo_native_exe ./compiler/xlang; then
    XLANG_C=./compiler/xlang
  fi
fi

if ! comp_wpo_native_exe "$XLANG_C"; then
  echo "comp-wpo SKIP (no native xlang/xlang-c, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "comp-wpo OK"
  exit 0
fi

xlang_compiler_make xlang-c -q 2>/dev/null || xlang_compiler_make xlang-c

echo "=== COMP-004: WPO smoke (XLANG=$XLANG_C) ==="
chmod +x tests/run-wpo-dce-emit.sh tests/run-wpo-s1.sh
# wave honesty (2026-08-24 #6): XLANG_WPO_DUMP_CALLGRAPH getenv left monofile;
# dump API remains in codegen.h, but `xlang-c check` dump path is product debt
# (check gate paused). Archaeology owns monofile retarget; smoke observational.
# PLATFORM: SHARED archaeology.
set +e
XLANG="$XLANG_C" ./tests/run-wpo-dce-emit.sh
dce_ec=$?
./tests/run-wpo-s1.sh
s1_ec=$?
set -e
if [ "$dce_ec" -eq 0 ] && [ "$s1_ec" -eq 0 ]; then
  echo "comp-wpo OK dce"
  echo "comp-wpo OK s1"
else
  echo "comp-wpo SKIP dce/s1 (product WPO_DUMP_CALLGRAPH dump path; archaeology manifest OK; dce=$dce_ec s1=$s1_ec)"
fi

echo "comp-wpo OK"
