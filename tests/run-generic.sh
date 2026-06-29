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

GENERIC_ERR=$("$LINK_SHUX" -L . tests/generic/wrong_type_args.sx -o "${TMPDIR:-/tmp}/shux_generic_wrong" 2>&1 || true)
echo "$GENERIC_ERR" | grep -q "expects 1 type arguments, got 2" || {
    echo "expected generic type-arg count diagnostic, got: $GENERIC_ERR"
    exit 1
}

echo "generic test OK"
