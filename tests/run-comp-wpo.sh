#!/usr/bin/env bash
# COMP-004：WPO v1 轻量烟测（DCE + S1）
#
# 用法：./tests/run-comp-wpo.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/comp-wpo.sh
. tests/lib/comp-wpo.sh

SHU_C="${SHU:-./compiler/shu-c}"
if ! comp_wpo_native_exe "$SHU_C"; then
  if comp_wpo_native_exe ./compiler/shu; then
    SHU_C=./compiler/shu
  fi
fi

if ! comp_wpo_native_exe "$SHU_C"; then
  echo "comp-wpo SKIP (no native shu/shu-c, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "comp-wpo OK"
  exit 0
fi

make -C compiler shu-c -q 2>/dev/null || make -C compiler shu-c

echo "=== COMP-004: WPO smoke (SHU=$SHU_C) ==="
chmod +x tests/run-wpo-dce-emit.sh tests/run-wpo-s1.sh
SHU="$SHU_C" ./tests/run-wpo-dce-emit.sh
echo "comp-wpo OK dce"

./tests/run-wpo-s1.sh
echo "comp-wpo OK s1"

echo "comp-wpo OK"
