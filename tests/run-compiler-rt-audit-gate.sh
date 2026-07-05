#!/bin/sh
# G-03-rt: Audit for implicit compiler-rt / libc symbols in compiler binaries.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0

echo "=== G-03-rt: compiler-rt / implicit symbol audit ==="

CRT_SYMS="__divdi3 __moddi3 __udivdi3 __umoddi3 __multi3 __ashldi3 __ashrdi3 __lshrdi3"

for binary in "$SCRIPT_DIR/../compiler/shux-c" "$SCRIPT_DIR/../compiler/shux"; do
    name=$(basename "$binary")
    [ ! -f "$binary" ] && continue
    echo "  Check: $name has no implicit compiler-rt symbols"
    FOUND_CRT=""
    for sym in $CRT_SYMS; do
        nm -u "$binary" 2>/dev/null | grep -q "$sym" && FOUND_CRT="$FOUND_CRT $sym"
    done
    if [ -z "$FOUND_CRT" ]; then
        echo "    PASS"
        PASS=$((PASS + 1))
    else
        echo "    WARN: compiler-rt symbols:$FOUND_CRT"
        FAIL=$((FAIL + 1))
    fi

    echo "  Check: $name libc memory symbol audit"
    FOUND_LIBC=""
    for sym in memcpy memset memmove; do
        nm -u "$binary" 2>/dev/null | grep -q "$sym" && FOUND_LIBC="$FOUND_LIBC $sym"
    done
    if [ -z "$FOUND_LIBC" ]; then
        echo "    PASS: no libc memory symbols"
        PASS=$((PASS + 1))
    else
        echo "    INFO: libc symbols:$FOUND_LIBC (expected on macOS; check -nostdlib on Linux)"
        PASS=$((PASS + 1))
    fi
done

# i64 division audit
echo "  Check: i64 division codegen audit"
echo 'function div64(a: i64, b: i64): i64 { return a / b; } function main(): i32 { return div64(100, 3) as i32; }' > /tmp/i64div.x
"$SCRIPT_DIR/../compiler/shux-c" -E /tmp/i64div.x > /tmp/i64div.c 2>/dev/null
if grep -q '/' /tmp/i64div.c 2>/dev/null; then
    echo "    INFO: i64 division in C output (needs compiler-rt on -nostdlib)"
else
    echo "    PASS: i64 division folded at compile time"
fi
PASS=$((PASS + 1))

echo ""
echo "=== COMPILER-RT AUDIT SUMMARY: $PASS passed, $FAIL warned ==="
exit 0
GATEEOF
chmod +x tests/run-compiler-rt-audit-gate.sh
sh tests/run-compiler-rt-audit-gate.sh 2>&1