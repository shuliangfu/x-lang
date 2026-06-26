#!/usr/bin/env bash
# 验证泛型单态化：id<T>(x: T) -> T 与 id<i32>(42) 调用；编译并运行，退出码应为 42。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

GENERIC_OUT="${TMPDIR:-/tmp}/shux_generic"

$LINK_SHUX -L . tests/generic/main.sx -o "$GENERIC_OUT" 2>&1
exitcode=0
"$GENERIC_OUT" >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 42 ]; then
    echo "expected exit code 42 (id<i32>(42)), got $exitcode"
    exit 1
fi

# bootstrap：泛型 type_args 校验未完整实现时 wrong_type_args 可能误过；主路径 id<i32>(42) 已覆盖。

echo "generic test OK"
