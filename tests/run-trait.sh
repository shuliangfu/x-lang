#!/usr/bin/env bash
# 验证 trait/impl 与方法调用：Double for i32，21.double() 返回 42。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX tests/trait/main.sx -o /tmp/shux_trait 2>&1
exitcode=0
/tmp/shux_trait >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 42 ]; then
    echo "expected exit code 42 (21.double()), got $exitcode"
    exit 1
fi

# 边界：对无 impl 的类型调用方法，应报 no impl for type ... with method ...
err=$($SHUX tests/trait/method_no_impl.sx -o /tmp/shux_trait_fail 2>&1) || true
echo "$err" | grep -q "no impl for type" || { echo "expected no impl error, got: $err"; exit 1; }

echo "trait test OK"
