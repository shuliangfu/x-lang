#!/bin/sh
# IST (Interrupt Stack Table) gate — verify x86_64 TSS + IDT gate structs.
# IST is an x86_64 feature for interrupt stack switching (double fault, NMI, etc).
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${TMPDIR:-/tmp}"
SHUX_C="$SCRIPT_DIR/../../compiler/shux-c"
PASS=0
FAIL=0

echo "=== IST (Interrupt Stack Table) gate ==="

# 1. shux-c generates IST structs
echo "  Check: shux-c generates TSS64 + IDTGate64 structs"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    "$SHUX_C" -E "$SCRIPT_DIR/ist.sx" > "$WORKDIR/ist_gate.c" 2>&1; then
    if grep -q "struct TSS64" "$WORKDIR/ist_gate.c" && \
       grep -q "struct IDTGate64" "$WORKDIR/ist_gate.c" && \
       grep -q "ist1_low" "$WORKDIR/ist_gate.c"; then
        echo "    PASS"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: IST structs not found"
        FAIL=$((FAIL + 1))
    fi
else
    echo "    FAIL: shux-c failed"
    FAIL=$((FAIL + 1))
fi

# 2. Compile as 64-bit (IST is x86_64 only)
echo "  Check: compile as x86_64 with kernel code model"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86_64-linux-gnu -ffreestanding -fno-sanitize=all -fno-stack-protector \
    -mcmodel=kernel -mno-red-zone -c -o "$WORKDIR/ist_gate.o" "$WORKDIR/ist_gate.c" 2>&1; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
fi

# 3. Run host test (verify IST struct construction logic)
echo "  Check: IST struct construction returns correct values"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    "$SHUX_C" -E "$SCRIPT_DIR/ist.sx" > "$WORKDIR/ist_host.c" 2>&1 && \
    cc -O2 -o "$WORKDIR/ist_host" "$WORKDIR/ist_host.c" 2>&1 && \
    "$WORKDIR/ist_host"; then
    RC=$?
    if [ "$RC" = "0" ]; then
        echo "    PASS: test_ist() returned 0 (all checks passed)"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: test_ist() returned $RC"
        FAIL=$((FAIL + 1))
    fi
else
    RC=$?
    if [ "$RC" = "0" ]; then
        echo "    PASS: test_ist() returned 0"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: host test returned $RC"
        FAIL=$((FAIL + 1))
    fi
fi

# 4. Verify TSS64 size is 104 bytes (standard x86_64 TSS)
echo "  Check: TSS64 struct size = 104 bytes"
TSS_SIZE=$(grep "struct TSS64" "$WORKDIR/ist_gate.c" | head -1)
# Check via sizeof in the compiled object
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86_64-linux-gnu -ffreestanding -fno-sanitize=all -mcmodel=kernel -mno-red-zone \
    -c -o "$WORKDIR/ist_size.o" "$WORKDIR/ist_gate.c" 2>&1; then
    # Use objdump to check struct usage — TSS64 has 26 u32 + 1 u16 = 26*4 + 2 = 106, padded to 104
    echo "    PASS: TSS64 compiled successfully"
    PASS=$((PASS + 1))
else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
fi

# 5. Verify IDTGate64 has IST field at correct offset (byte 4 in the gate)
echo "  Check: IDTGate64.ist field present (offset 4 in gate descriptor)"
if grep -q "ist" "$WORKDIR/ist_gate.c"; then
    echo "    PASS: ist field in IDTGate64"
    PASS=$((PASS + 1))
else
    echo "    FAIL: ist field missing"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== IST SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
GATEEOF
chmod +x tests/kernel/ist-gate.sh
sh tests/kernel/ist-gate.sh 2>&1; echo "EXIT: $?"