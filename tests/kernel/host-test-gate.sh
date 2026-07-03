#!/bin/sh
# G1: Host unit test gate — compile kernel logic for host, run as normal test.
# No QEMU needed. Tests pure-logic kernel functions (math, IDT entry building, etc.)
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHUX_C="$SCRIPT_DIR/../../compiler/shux-c"
WORKDIR="${TMPDIR:-/tmp}"
PASS=0
FAIL=0

echo "=== G1: Host unit test gate ==="

# Compile host_test.sx for host (not freestanding)
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$SCRIPT_DIR/host_test.sx" > "$WORKDIR/host_test.c"
cc -O2 -o "$WORKDIR/host_test" "$WORKDIR/host_test.c" 2>&1
RESULT=$("$WORKDIR/host_test"; echo $?)
RC=$(echo "$RESULT" | tail -1)
echo "  host_test: exit code $RC (0 = all assertions passed)"
if [ "$RC" = "0" ]; then
    echo "  G1: PASS"
    PASS=$((PASS + 1))
else
    echo "  G1: FAIL ($RC assertions failed)"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== HOST TEST SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
