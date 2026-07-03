#!/bin/sh
# L4: Stack usage analysis gate — verify #[max_stack(N)] attribute is parsed and emitted.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHUX_C="$SCRIPT_DIR/../../compiler/shux-c"
WORKDIR="${TMPDIR:-/tmp}"
PASS=0
FAIL=0

echo "=== L4: Stack usage analysis gate ==="

SX_FILE="${1:-$SCRIPT_DIR/stack_check.sx}"
C_FILE="$WORKDIR/stack_check.c"
O_FILE="$WORKDIR/stack_check.o"

# Compile .sx → C → .o
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$SX_FILE" > "$C_FILE"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86-linux-gnu -ffreestanding -fno-sanitize=all -fno-stack-protector \
    -c -o "$O_FILE" "$C_FILE" 2>&1

# Check 1: max_stack comments are present in C output
echo "  Check: #[max_stack] comments in C output"
MAX_STACK_COUNT=$(grep -c 'shux_max_stack' "$C_FILE" 2>/dev/null || echo 0)
if [ "$MAX_STACK_COUNT" -ge 2 ]; then
    echo "    PASS: found $MAX_STACK_COUNT max_stack markers"
    PASS=$((PASS + 1))
else
    echo "    FAIL: expected >=2 max_stack markers, found $MAX_STACK_COUNT"
    FAIL=$((FAIL + 1))
fi

# Check 2: max_stack values match expected
echo "  Check: max_stack values"
VAL1=$(grep -o 'shux_max_stack:64' "$C_FILE" | head -1)
VAL2=$(grep -o 'shux_max_stack:32' "$C_FILE" | head -1)
if [ -n "$VAL1" ] && [ -n "$VAL2" ]; then
    echo "    PASS: found max_stack:64 and max_stack:32"
    PASS=$((PASS + 1))
else
    echo "    FAIL: missing expected max_stack values"
    FAIL=$((FAIL + 1))
fi

# Check 3: Compilation succeeds
echo "  Check: compilation succeeds"
if [ -f "$O_FILE" ]; then
    echo "    PASS: compiled successfully"
    PASS=$((PASS + 1))
else
    echo "    FAIL: compilation failed"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== STACK CHECK SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
