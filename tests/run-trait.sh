#!/usr/bin/env bash
# 验证 trait/impl 与方法调用：Double for i32，21.double() 返回 42。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

TRAIT_OUT="${TMPDIR:-/tmp}/shux_trait"

$LINK_SHUX -L . tests/trait/main.sx -o "$TRAIT_OUT" 2>&1
exitcode=0
"$TRAIT_OUT" >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 42 ]; then
    echo "expected exit code 42 (21.double()), got $exitcode"
    exit 1
fi

# 边界：对无 impl 的类型调用方法，应报 no impl for type ... with method ...
err=$($TYPECK_SHUX tests/trait/method_no_impl.sx -o "${TMPDIR:-/tmp}/shux_trait_fail" 2>&1) || true
echo "$err" | grep -q "typeck error" || { echo "expected typeck error for method_no_impl, got: $err"; exit 1; }

echo "trait test OK"
