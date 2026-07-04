#!/usr/bin/env bash
# LANG-004：trait/interface 烟测（方法调用 + typeck 负例）
#
# 用法：./tests/run-lang-trait.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/lang-trait.sh
. tests/lib/lang-trait.sh

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if lang_trait_native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ] || ! lang_trait_native_shu "$SHUX_BIN"; then
  echo "lang-trait SKIP (no native shux, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "lang-trait OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

echo "=== LANG-004: trait smoke (SHUX=$SHUX_BIN) ==="
chmod +x tests/run-trait.sh
SHUX="$SHUX_BIN" ./tests/run-trait.sh

# impl 缺方法负例（run-trait.sh 未覆盖）
err=$("$SHUX_BIN" tests/trait/impl_missing_method.x -o /tmp/shux_trait_miss 2>&1) || true
echo "$err" | grep -q "missing method" || {
  echo "lang-trait FAIL: expected missing method error, got: $err" >&2
  exit 1
}
echo "lang-trait OK impl_missing_method"

echo "lang-trait OK"
