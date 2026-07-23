#!/usr/bin/env bash
# LANG-004：trait/interface 烟测（方法调用 + typeck 负例）
#
# 用法：./tests/run-lang-trait.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/lang-trait.sh
. tests/lib/lang-trait.sh

XLANG_BIN="${XLANG:-}"
if [ -z "$XLANG_BIN" ]; then
  for cand in ./compiler/xlang-c ./compiler/xlang; do
    if lang_trait_native_shu "$cand"; then
      XLANG_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$XLANG_BIN" ] || ! lang_trait_native_shu "$XLANG_BIN"; then
  echo "lang-trait SKIP (no native xlang, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "lang-trait OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

echo "=== LANG-004: trait smoke (XLANG=$XLANG_BIN) ==="
chmod +x tests/run-trait.sh
XLANG="$XLANG_BIN" ./tests/run-trait.sh

# impl 缺方法负例（run-trait.sh 未覆盖）
err=$("$XLANG_BIN" build tests/trait/impl_missing_method.x -o /tmp/xlang_trait_miss 2>&1) || true
echo "$err" | grep -q "missing method" || {
  echo "lang-trait FAIL: expected missing method error, got: $err" >&2
  exit 1
}
echo "lang-trait OK impl_missing_method"

echo "lang-trait OK"
