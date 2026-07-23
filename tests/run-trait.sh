#!/usr/bin/env bash
# 验证 trait/impl 与方法调用：Double for i32，21.double() 返回 42。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
XLANG=${XLANG:-./compiler/xlang}
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
LINK_XLANG="$RUN_XLANG"
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

TRAIT_OUT="${TMPDIR:-/tmp}/xlang_trait"

$LINK_XLANG build -L . tests/trait/main.x -o "$TRAIT_OUT" 2>&1
exitcode=0
"$TRAIT_OUT" >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 42 ]; then
    echo "expected exit code 42 (21.double()), got $exitcode"
    exit 1
fi

# 边界：对无 impl 的类型调用方法，应报 no impl for type ... with method ...
err=$($TYPECK_XLANG build tests/trait/method_no_impl.x -o "${TMPDIR:-/tmp}/xlang_trait_fail" 2>&1) || true
echo "$err" | grep -q "typeck error" || { echo "expected typeck error for method_no_impl, got: $err"; exit 1; }

echo "trait test OK"
