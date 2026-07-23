#!/usr/bin/env bash
# COMP-004：WPO v1 轻量烟测（DCE + S1）
#
# 用法：./tests/run-comp-wpo.sh
set -e
cd "$(dirname "$0")/.."

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

make -C compiler xlang-c -q 2>/dev/null || make -C compiler xlang-c

echo "=== COMP-004: WPO smoke (XLANG=$XLANG_C) ==="
chmod +x tests/run-wpo-dce-emit.sh tests/run-wpo-s1.sh
XLANG="$XLANG_C" ./tests/run-wpo-dce-emit.sh
echo "comp-wpo OK dce"

./tests/run-wpo-s1.sh
echo "comp-wpo OK s1"

echo "comp-wpo OK"
