#!/bin/sh
# K6e/K6d: Multiboot2 header gate — verify byte layout, end tag, header_length, alignment.
# QEMU -kernel does not support multiboot2 (needs GRUB), so this is a T1 static gate.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${TMPDIR:-/tmp}"
PASS=0
FAIL=0

sh "$SCRIPT_DIR/build-kernel.sh" "$SCRIPT_DIR/multiboot2.sx" "$WORKDIR/mb2_gate.elf" 2>&1

echo "=== K6e: Multiboot2 header gate ==="

# Check 1: .boot section is 24 bytes (0x18)
BOOT_SIZE=$(objdump -h "$WORKDIR/mb2_gate.elf" 2>/dev/null | grep '\.boot' | awk '{print $3}')
# objdump prints 8-hex-digit size; strip leading zeros for comparison
BOOT_SIZE_DEC=$((16#$BOOT_SIZE))
if [ "$BOOT_SIZE_DEC" = "24" ]; then
    echo "  Check: .boot section size = 24 bytes (0x18)"
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  Check: .boot section size = 24 — got $BOOT_SIZE_DEC (0x$BOOT_SIZE)"
    echo "  FAIL"
    FAIL=$((FAIL + 1))
fi

# Check 2: magic = 0xE85250D6 at offset 0 (LE: d65052e8)
LINE1=$(objdump -s -j .boot "$WORKDIR/mb2_gate.elf" 2>/dev/null | grep '100000' | awk '{print $2 $3 $4 $5}')
MAGIC_LE=$(printf '%s' "$LINE1" | cut -c1-8)
if [ "$MAGIC_LE" = "d65052e8" ]; then
    echo "  Check: magic = 0xE85250D6 (LE: d65052e8)"
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  Check: magic — got $MAGIC_LE"
    echo "  FAIL"
    FAIL=$((FAIL + 1))
fi

# Check 3: header_length = 24 (0x18) at offset 8 (LE: 18000000)
LEN_HEX=$(printf '%s' "$LINE1" | cut -c17-24)
if [ "$LEN_HEX" = "18000000" ]; then
    echo "  Check: header_length = 24 (0x18)"
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  Check: header_length — got $LEN_HEX"
    echo "  FAIL"
    FAIL=$((FAIL + 1))
fi

# Check 4: checksum = 0x17ADAF12 at offset 12 (LE: 12afad17)
CKSUM_HEX=$(printf '%s' "$LINE1" | cut -c25-32)
if [ "$CKSUM_HEX" = "12afad17" ]; then
    echo "  Check: checksum = 0x17ADAF12 (= -(0xE85250D6 + 0 + 24))"
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  Check: checksum — got $CKSUM_HEX"
    echo "  FAIL"
    FAIL=$((FAIL + 1))
fi

# Check 5: end tag at offset 16 — type+flags=0 (4 bytes) then size=8 (LE: 08000000)
LINE2=$(objdump -s -j .boot "$WORKDIR/mb2_gate.elf" 2>/dev/null | grep '100010' | awk '{print $2 $3}')
if [ "$LINE2" = "0000000008000000" ]; then
    echo "  Check: end tag (type=0, flags=0, size=8)"
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  Check: end tag — got $LINE2"
    echo "  FAIL"
    FAIL=$((FAIL + 1))
fi

# Check 6 (K6d): .boot section at 4-byte aligned address
BOOT_ADDR=$(objdump -h "$WORKDIR/mb2_gate.elf" 2>/dev/null | grep '\.boot' | awk '{print $4}')
BOOT_ADDR_DEC=$((16#$BOOT_ADDR))
if [ $((BOOT_ADDR_DEC % 4)) = "0" ]; then
    echo "  Check: .boot at 4-byte aligned address (0x$BOOT_ADDR)"
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  Check: .boot alignment — 0x$BOOT_ADDR not 4-byte aligned"
    echo "  FAIL"
    FAIL=$((FAIL + 1))
fi

# Check 7 (K6d): .boot at physical address 0x100000 (first in ELF)
if [ "$BOOT_ADDR" = "00100000" ]; then
    echo "  Check: .boot at physical address 0x100000"
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  Check: .boot physical address — got 0x$BOOT_ADDR"
    echo "  FAIL"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== MULTIBOOT2 SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
GATEEOF
chmod +x tests/kernel/multiboot2-gate.sh
sh tests/kernel/multiboot2-gate.sh 2>&1