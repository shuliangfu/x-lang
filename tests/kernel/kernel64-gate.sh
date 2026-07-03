#!/bin/sh
# K11/L10: 64-bit kernel code model + RIP-relative addressing + no red zone gate.
# T1 only: verifies compilation, encoding, and linker script.
# T2 (QEMU 64-bit boot) requires mixed 32/64-bit linking (future work).
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHUX_C="$SCRIPT_DIR/../../compiler/shux-c"
WORKDIR="${TMPDIR:-/tmp}"
PASS=0
FAIL=0

echo "=== K11/L10: 64-bit kernel code model gate (T1) ==="

# Compile test kernel as x86_64 with kernel code model + no red zone
SX_FILE="$SCRIPT_DIR/kernel64_check.sx"
C_FILE="$WORKDIR/kernel64_check.c"
OBJ_FILE="$WORKDIR/kernel64_check.o"
ELF_FILE="$WORKDIR/kernel64_check.elf"
STUBS_O="$WORKDIR/shux_freestanding_stubs64.o"

# Build 64-bit stubs
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86_64-linux-gnu -ffreestanding -fno-sanitize=all -c -o "$STUBS_O" "$SCRIPT_DIR/freestanding_stubs.c"

# 1. shux-c -E
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$SX_FILE" > "$C_FILE"

# 2. zig cc: compile as x86_64 with -mcmodel=kernel -mno-red-zone
echo "  Check: compilation with -mcmodel=kernel -mno-red-zone"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86_64-linux-gnu -ffreestanding -fno-sanitize=all -fno-stack-protector \
    -mcmodel=kernel -mno-red-zone -c -o "$OBJ_FILE" "$C_FILE" 2>&1; then
    echo "    PASS: compiled as x86_64 kernel code model"
    PASS=$((PASS + 1))
else
    echo "    FAIL: compilation failed"
    FAIL=$((FAIL + 1))
fi

# 3. Link with high-half linker script
echo "  Check: linking with high-half linker script (0xFFFFFFFF80000000)"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86_64-linux-gnu -ffreestanding -nostdlib -fno-sanitize=all \
    -T "$SCRIPT_DIR/kernel64.ld" -o "$ELF_FILE" "$OBJ_FILE" "$STUBS_O" 2>&1; then
    echo "    PASS: linked at high-half address"
    PASS=$((PASS + 1))
else
    echo "    FAIL: linking failed"
    FAIL=$((FAIL + 1))
fi

# 4. K11: Check RIP-relative addressing
echo "  Check: K11 RIP-relative data addressing"
RIP_COUNT=$(objdump -d "$ELF_FILE" 2>/dev/null | grep -c '%rip' || echo 0)
if [ "$RIP_COUNT" -ge 2 ]; then
    echo "    PASS: found $RIP_COUNT RIP-relative instructions"
    PASS=$((PASS + 1))
else
    echo "    FAIL: expected >=2 RIP-relative instructions, found $RIP_COUNT"
    FAIL=$((FAIL + 1))
fi

# 5. L10: Check no red zone (no sub $0x80, %rsp or sub $128, %rsp)
echo "  Check: L10 no red zone (no 128-byte stack pre-allocation)"
RED_ZONE=$(objdump -d "$ELF_FILE" 2>/dev/null | grep -E 'sub.*\$0x80.*%rsp|sub.*\$128.*%rsp' || true)
if [ -z "$RED_ZONE" ]; then
    echo "    PASS: no red zone allocation found"
    PASS=$((PASS + 1))
else
    echo "    FAIL: red zone found: $RED_ZONE"
    FAIL=$((FAIL + 1))
fi

# 6. Check ELF is 64-bit
echo "  Check: ELF format is elf64-x86-64"
ELF_FORMAT=$(objdump -d "$ELF_FILE" 2>/dev/null | head -3 | grep 'file format')
if echo "$ELF_FORMAT" | grep -q 'elf64-x86-64'; then
    echo "    PASS: $ELF_FORMAT"
    PASS=$((PASS + 1))
else
    echo "    FAIL: $ELF_FORMAT"
    FAIL=$((FAIL + 1))
fi

# 7. Check high-half addresses
echo "  Check: code linked at high-half (0xFFFFFFFF80000000)"
HIGH_HALF=$(objdump -d "$ELF_FILE" 2>/dev/null | grep -c 'ffffffff80' || echo 0)
if [ "$HIGH_HALF" -ge 1 ]; then
    echo "    PASS: high-half addresses present ($HIGH_HALF found)"
    PASS=$((PASS + 1))
else
    echo "    FAIL: no high-half addresses found"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== K11/L10 SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
