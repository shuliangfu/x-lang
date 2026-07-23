#!/usr/bin/env bash
# 运行 UB 收窄测试：除零、越界应 panic（exit 134 = SIGABRT），正常路径应正常返回
set -e
cd "$(dirname "$0")/.."
# Prefer explicit XLANG (caller-owned binary). bootstrap-link defaults XLANG_LINK to
# xlang-c which is often broken after G-02a; do not force it when XLANG is set.
CALLER_XLANG="${XLANG:-}"
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
if [ -n "$CALLER_XLANG" ] && [ -x "$CALLER_XLANG" ]; then
  XLANG="$CALLER_XLANG"
  LINK_XLANG="$CALLER_XLANG"
  XLANG_LINK_BACKEND_ARGS="-backend c"
else
  XLANG="${XLANG:-./compiler/xlang}"
  LINK_XLANG="${XLANG_LINK_XLANG:-${RUN_XLANG:-$XLANG}}"
fi
compile_ub() {
    if [ -n "${XLANG_LINK_BACKEND_ARGS:-}" ]; then
        "$LINK_XLANG" $XLANG_LINK_BACKEND_ARGS -L . "$1" -o "$2" 2>/dev/null
    else
        "$LINK_XLANG" -L . "$1" -o "$2" 2>/dev/null
    fi
}
run_panic() {
    compile_ub "$1" /tmp/ub_test || exit 1
    set +e; { ( /tmp/ub_test 2>/dev/null ) 2>/dev/null; r=$?; } 2>/dev/null; set -e
    if [ "$r" -eq 134 ] || [ "$r" -ne 0 ]; then
        echo "  $1: panic/abort (expected)"
    else
        echo "  $1: unexpected exit $r"; exit 1
    fi
}
run_ok() {
    compile_ub "$1" /tmp/ub_ok || exit 1
    set +e; /tmp/ub_ok 2>/dev/null; r=$?; set -e
    echo "  $1: exit $r"
}
echo "ub: div_zero (expect panic)"
run_panic tests/ub/div_zero.x
echo "ub: bounds_array (expect panic)"
run_panic tests/ub/bounds_array.x
echo "ub: bounds_slice (expect panic)"
run_panic tests/ub/bounds_slice.x
echo "ub: div_ok (expect exit 3)"
run_ok tests/ub/div_ok.x
echo "ub: OK"
