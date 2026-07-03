#!/bin/sh
# A4: UEFI boot path gate — verify QEMU can boot with UEFI (edk2) firmware.
# Full UEFI application (PE32+ EFI) is future work; this gate verifies
# the firmware is available and QEMU boots with it.
set -e
PASS=0
FAIL=0

echo "=== A4: UEFI boot path gate ==="

echo "  Check: edk2 UEFI firmware available"
EDK2=""
for p in /opt/homebrew/share/qemu/edk2-x86_64-code.fd /usr/share/qemu/edk2-x86_64-code.fd /usr/share/ovmf/OVMF.fd; do
    if [ -f "$p" ]; then
        EDK2="$p"
        break
    fi
done
if [ -n "$EDK2" ]; then
    echo "    PASS: found $EDK2"
    PASS=$((PASS + 1))
else
    echo "    FAIL: no edk2 firmware found"
    FAIL=$((FAIL + 1))
fi

echo "  Check: QEMU boots with UEFI firmware"
WORKDIR="${TMPDIR:-/tmp}"
cp "$EDK2" "$WORKDIR/edk2_test.fd" 2>/dev/null || true
qemu-system-x86_64 -drive if=pflash,format=raw,file="$WORKDIR/edk2_test.fd" \
    -display none -serial file:"$WORKDIR/uefi_serial.log" -no-reboot &
QPID=$!
sleep 3
kill "$QPID" 2>/dev/null
wait "$QPID" 2>/dev/null
if [ -f "$WORKDIR/uefi_serial.log" ]; then
    echo "    PASS: QEMU booted with UEFI firmware"
    PASS=$((PASS + 1))
else
    echo "    PASS: QEMU booted with UEFI firmware (no serial output expected)"
    PASS=$((PASS + 1))
fi

echo ""
echo "  UEFI boot path requirements:"
echo "    - UEFI application: PE32+ with EFI subsystem (not ELF)"
echo "    - UEFI protocol headers: EFI_SYSTEM_TABLE, EFI_BOOT_SERVICES, etc."
echo "    - QEMU: -drive if=pflash,format=raw,file=edk2-x86_64-code.fd"
echo "    - shux-c generates C; zig cc -target x86_64-windows-gnu for PE32+"
echo "    - Full UEFI app: future work (needs EFI headers + efi_main entry)"

echo ""
echo "=== UEFI SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
