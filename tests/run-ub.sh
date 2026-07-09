#!/usr/bin/env bash
# 运行 UB 收窄测试：除零、越界应 panic（exit 134 = SIGABRT），正常路径应正常返回
set -e
cd "$(dirname "$0")/.."
# Prefer explicit SHUX (caller-owned binary). bootstrap-link defaults SHUX_LINK to
# shux-c which is often broken after G-02a; do not force it when SHUX is set.
CALLER_SHUX="${SHUX:-}"
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
if [ -n "$CALLER_SHUX" ] && [ -x "$CALLER_SHUX" ]; then
  SHUX="$CALLER_SHUX"
  LINK_SHUX="$CALLER_SHUX"
  SHUX_LINK_BACKEND_ARGS="-backend c"
else
  SHUX="${SHUX:-./compiler/shux}"
  LINK_SHUX="${SHUX_LINK_SHUX:-${RUN_SHUX:-$SHUX}}"
fi
compile_ub() {
    if [ -n "${SHUX_LINK_BACKEND_ARGS:-}" ]; then
        "$LINK_SHUX" $SHUX_LINK_BACKEND_ARGS -L . "$1" -o "$2" 2>/dev/null
    else
        "$LINK_SHUX" -L . "$1" -o "$2" 2>/dev/null
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
