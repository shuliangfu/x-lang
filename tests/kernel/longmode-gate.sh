#!/bin/sh
# x86_64 QEMU boot gate — 32-bit multiboot1 + long mode switch + 64-bit serial output.
# Proves shux can boot a 64-bit kernel in QEMU via 32-bit entry -> long mode transition.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${TMPDIR:-/tmp}"
SHUX_C="$SCRIPT_DIR/../../compiler/shux-c"
PASS=0
FAIL=0

echo "=== x86_64 QEMU boot gate (long mode switch) ==="

# 1. Compile longmode_boot.s as 32-bit
echo "  Check: compile boot code (32-bit)"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86-linux-gnu -ffreestanding -fno-sanitize=all \
    -c -o "$WORKDIR/longmode_gate_boot.o" "$SCRIPT_DIR/longmode_boot.s" 2>&1; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
fi

# 2. Compile shux kernel (32-bit, provides multiboot1 header)
echo "  Check: compile shux kernel (32-bit, multiboot1 header)"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    "$SHUX_C" -E "$SCRIPT_DIR/longmode.sx" > "$WORKDIR/longmode_gate.c" 2>&1 && \
    XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86-linux-gnu -ffreestanding -fno-sanitize=all -fno-stack-protector \
    -c -o "$WORKDIR/longmode_gate.o" "$WORKDIR/longmode_gate.c" 2>&1; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
fi

# 3. Link as 32-bit ELF
echo "  Check: link 32-bit ELF (boot + kernel + stubs)"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86-linux-gnu -ffreestanding -nostdlib -fno-sanitize=all \
    -T "$SCRIPT_DIR/kernel.ld" -o "$WORKDIR/longmode_gate.elf" \
    "$WORKDIR/longmode_gate_boot.o" "$WORKDIR/longmode_gate.o" \
    "$WORKDIR/shux_freestanding_stubs.o" 2>&1; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
fi

# 4. Verify ELF is 32-bit
echo "  Check: ELF is 32-bit (multiboot1 compatible)"
ELF_INFO=$(file "$WORKDIR/longmode_gate.elf" 2>/dev/null)
if echo "$ELF_INFO" | grep -q 'ELF 32-bit'; then
    echo "    PASS: $ELF_INFO"
    PASS=$((PASS + 1))
else
    echo "    FAIL: $ELF_INFO"
    FAIL=$((FAIL + 1))
fi

# 5. QEMU boot test — verify 64-bit serial output
echo "  Check: QEMU boots and 64-bit code outputs 'Q:64'"
rm -f "$WORKDIR/longmode_gate.serial"
qemu-system-x86_64 -kernel "$WORKDIR/longmode_gate.elf" -no-reboot -display none \
    -serial file:"$WORKDIR/longmode_gate.serial" &
QPID=$!
sleep 3
kill "$QPID" 2>/dev/null
wait "$QPID" 2>/dev/null
ACTUAL=$(cat "$WORKDIR/longmode_gate.serial" 2>/dev/null | sed 's/ *$//')
echo "    expected: Q:64"
echo "    actual:   $ACTUAL"
if [ "$ACTUAL" = "Q:64" ]; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
fi

# 6. Verify 64-bit code section exists
echo "  Check: 64-bit code in .text section (_start64)"
if objdump -d -j .text "$WORKDIR/longmode_gate.elf" 2>/dev/null | grep -q '_start64'; then
    echo "    PASS: _start64 symbol present"
    PASS=$((PASS + 1))
else
    echo "    FAIL: _start64 not found"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== LONGMODE SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
GATEEOF
chmod +x tests/kernel/longmode-gate.sh
sh tests/kernel/longmode-gate.sh 2>&1; echo "EXIT: $?"