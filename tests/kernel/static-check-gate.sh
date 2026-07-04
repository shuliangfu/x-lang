#!/bin/sh
# G3: Static check gate — verify ELF sections, symbols, relocations.
# G4: Purity gate — reject any undefined host-libc/OS symbols.
# Usage: static-check-gate.sh [elf-file]
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${TMPDIR:-/tmp}"
ELF="${1:-$WORKDIR/gate_timer_isr.x.elf}"
PASS=0
FAIL=0
check() {
    NAME="$1"
    if eval "$2"; then
        echo "  $NAME: PASS"
        PASS=$((PASS + 1))
    else
        echo "  $NAME: FAIL"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== G3: Static check gate ($ELF) ==="

# Build if not exists
if [ ! -f "$ELF" ]; then
    sh "$SCRIPT_DIR/build-kernel.sh" "$SCRIPT_DIR/timer_isr.x" "$ELF" 2>&1
fi

# G3-1: _start symbol exists and is global (T = text global)
check "G3-1 _start is global text symbol" \
    "nm \$ELF 2>/dev/null | grep -q 'T _start'"

# G3-2: .boot section exists (multiboot header)
check "G3-2 .boot section present" \
    "objdump -h \$ELF 2>/dev/null | grep -q '\.boot'"

# G3-3: .text section exists
check "G3-4 .text section present" \
    "objdump -h \$ELF 2>/dev/null | grep -q '\.text'"

# G3-4: timer_handler symbol exists (#[used] prevents DCE)
check "G3-5 timer_handler not DCE'd (#[used] works)" \
    "nm \$ELF 2>/dev/null | grep -q 'timer_handler'"

# G3-5: No .rela.dyn with host relocations (kernel is statically linked)
check "G3-6 no dynamic relocs" \
    "! objdump -R \$ELF 2>/dev/null | grep -q 'R_'"

echo ""
echo "=== G4: Purity gate ==="

# G4-1: No undefined symbols (everything resolved, no libc deps)
# Allow __stack_chk_fail (provided by stubs) and known stub symbols
UNDEFS=$(nm "$ELF" 2>/dev/null | grep ' U ' || true)
if [ -z "$UNDEFS" ]; then
    echo "  G4-1 no undefined symbols: PASS"
    PASS=$((PASS + 1))
else
    echo "  G4-1 undefined symbols found: $UNDEFS"
    echo "  G4-1: FAIL"
    FAIL=$((FAIL + 1))
fi

# G4-2: No unexpected libc symbols (allow known freestanding stubs)
# Our freestanding_stubs.c provides: abort, fclose, fopen, fprintf, snprintf,
# getenv, getpid, __stack_chk_fail, stderr — all empty stubs, not real libc.
ALLOWED_STUBS="abort fclose fopen fprintf snprintf getenv getpid __stack_chk_fail memcpy memset"
BAD_SYMS=""
for s in $(nm "$ELF" 2>/dev/null | grep -iE 'printf|malloc|free|exit|abort|memcpy|memset|memcmp|strlen|write|read|fopen|fclose|snprintf|getenv|getpid' | awk '{print $3}' | sort -u); do
    case "$ALLOWED_STUBS" in
        *"$s"*) ;;  # allowed stub
        *) BAD_SYMS="$BAD_SYMS $s" ;;
    esac
done
if [ -z "$BAD_SYMS" ]; then
    echo "  G4-2 no unexpected libc symbols: PASS"
    PASS=$((PASS + 1))
else
    echo "  G4-2 unexpected libc symbols:$BAD_SYMS"
    echo "  G4-2: FAIL"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== STATIC CHECK SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
