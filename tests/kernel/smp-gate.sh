#!/bin/sh
# G5: QEMU SMP gate — verify kernel works with -smp 2 (BSP boots, APs halted).
# Full SMP test (AP wakeup, per-CPU contention) is future work.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${TMPDIR:-/tmp}"

echo "=== G5: QEMU SMP gate ==="

# Build showcase kernel
sh "$SCRIPT_DIR/build-kernel.sh" "$SCRIPT_DIR/showcase.x" "$WORKDIR/smp_gate.elf" 2>&1

# Run with -smp 2
rm -f "$WORKDIR/smp_serial.log"
qemu-system-x86_64 -kernel "$WORKDIR/smp_gate.elf" -no-reboot -display none \
    -serial file:"$WORKDIR/smp_serial.log" -smp 2 &
QPID=$!
sleep 3
kill "$QPID" 2>/dev/null
wait "$QPID" 2>/dev/null

ACTUAL="$(cat "$WORKDIR/smp_serial.log" 2>/dev/null | sed 's/ *$//')"
echo "  expected: K:1,2097152"
echo "  actual:   $ACTUAL"
if [ "$ACTUAL" = "K:1,2097152" ]; then
    echo "  G5: PASS (BSP boots correctly with -smp 2, APs halted)"
    exit 0
else
    echo "  G5: FAIL"
    exit 1
fi
