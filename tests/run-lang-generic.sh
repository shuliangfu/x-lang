#!/usr/bin/env bash
# LANG-003：泛型单态化烟测（单模块 + 跨模块 prototype）
#
# 用法：./tests/run-lang-generic.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/lang-generic.sh
. tests/lib/lang-generic.sh

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if lang_generic_native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ] || ! lang_generic_native_shu "$SHUX_BIN"; then
  echo "lang-generic SKIP (no native shux, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "lang-generic OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

echo "=== LANG-003: generic smoke (SHUX=$SHUX_BIN) ==="
chmod +x tests/run-generic.sh tests/run-multi-file-generic.sh
SHUX="$SHUX_BIN" ./tests/run-generic.sh

# 跨模块泛型仅 shux-c prototype 路径稳定。
if [ -x ./compiler/shux-c ] && lang_generic_native_shu ./compiler/shux-c; then
  ./tests/run-multi-file-generic.sh
else
  echo "lang-generic SKIP multi-file (no native shux-c)"
fi

echo "lang-generic OK"
