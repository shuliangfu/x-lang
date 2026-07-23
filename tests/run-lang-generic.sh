#!/usr/bin/env bash
# LANG-003：泛型单态化烟测（单模块 + 跨模块 prototype）
#
# 用法：./tests/run-lang-generic.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/lang-generic.sh
. tests/lib/lang-generic.sh

XLANG_BIN="${XLANG:-}"
if [ -z "$XLANG_BIN" ]; then
  for cand in ./compiler/xlang-c ./compiler/xlang; do
    if lang_generic_native_xlang "$cand"; then
      XLANG_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$XLANG_BIN" ] || ! lang_generic_native_xlang "$XLANG_BIN"; then
  echo "lang-generic SKIP (no native xlang, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "lang-generic OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

echo "=== LANG-003: generic smoke (XLANG=$XLANG_BIN) ==="
chmod +x tests/run-generic.sh tests/run-multi-file-generic.sh
XLANG="$XLANG_BIN" ./tests/run-generic.sh

# 跨模块泛型仅 xlang-c prototype 路径稳定。
if [ -x ./compiler/xlang-c ] && lang_generic_native_xlang ./compiler/xlang-c; then
  ./tests/run-multi-file-generic.sh
else
  echo "lang-generic SKIP multi-file (no native xlang-c)"
fi

echo "lang-generic OK"
