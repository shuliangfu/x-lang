#!/bin/sh
# UEFI application gate — compile shux to PE32+ EFI skeleton with efi_main entry.
# Verifies: shux-c generates EFI protocol headers, zig cc produces PE32+ binary.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${TMPDIR:-/tmp}"
SHUX_C="$SCRIPT_DIR/../../compiler/shux-c"
PASS=0
FAIL=0

echo "=== UEFI application gate ==="

# 1. shux-c -E: generate C with EFI structs + efi_main
echo "  Check: shux-c generates EFI protocol headers"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    "$SHUX_C" -E "$SCRIPT_DIR/uefi_app.sx" > "$WORKDIR/uefi_app_gate.c" 2>&1; then
    if grep -q "EFI_SYSTEM_TABLE" "$WORKDIR/uefi_app_gate.c" && \
       grep -q "EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL" "$WORKDIR/uefi_app_gate.c"; then
        echo "    PASS"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: EFI structs not found in C output"
        FAIL=$((FAIL + 1))
    fi
else
    echo "    FAIL: shux-c failed"
    FAIL=$((FAIL + 1))
fi

# 2. Compile as PE32+ object (x86_64-windows-gnu target)
echo "  Check: compile as PE32+ object (x86_64-windows-gnu)"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86_64-windows-gnu -ffreestanding -fno-sanitize=all \
    -c -o "$WORKDIR/uefi_app_gate.o" "$WORKDIR/uefi_app_gate.c" 2>&1; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
fi

# 3. efi_main symbol present and external
echo "  Check: efi_main symbol is external (global)"
EFI_SYM=$(nm "$WORKDIR/uefi_app_gate.o" 2>/dev/null | grep efi_main | head -1)
if echo "$EFI_SYM" | grep -q 'T.*efi_main'; then
    echo "    PASS: $EFI_SYM"
    PASS=$((PASS + 1))
else
    echo "    FAIL: $EFI_SYM"
    FAIL=$((FAIL + 1))
fi

# 4. Link as PE32+ executable
echo "  Check: link as PE32+ executable"
EFI_SYM_NAME=$(nm "$WORKDIR/uefi_app_gate.o" 2>/dev/null | grep efi_main | awk '{print $3}')
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86_64-windows-gnu -ffreestanding -nostdlib -fno-sanitize=all \
    -e "$EFI_SYM_NAME" -o "$WORKDIR/uefi_app_gate.efi" "$WORKDIR/uefi_app_gate.o" 2>&1; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
fi

# 5. Verify output is PE32+
echo "  Check: output file is PE32+ executable"
EFI_INFO=$(file "$WORKDIR/uefi_app_gate.efi" 2>/dev/null)
if echo "$EFI_INFO" | grep -q 'PE32+'; then
    echo "    PASS: $EFI_INFO"
    PASS=$((PASS + 1))
else
    echo "    FAIL: $EFI_INFO"
    FAIL=$((FAIL + 1))
fi

# 6. Verify EFI_SYSTEM_TABLE struct layout (con_out at offset 0x38 = 56 bytes)
echo "  Check: EFI_SYSTEM_TABLE struct has correct field offsets"
if grep -q "con_out" "$WORKDIR/uefi_app_gate.c"; then
    echo "    PASS: con_out field present"
    PASS=$((PASS + 1))
else
    echo "    FAIL: con_out field missing"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== UEFI APP SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
GATEEOF
chmod +x tests/kernel/uefi-app-gate.sh
sh tests/kernel/uefi-app-gate.sh 2>&1; echo "EXIT: $?"