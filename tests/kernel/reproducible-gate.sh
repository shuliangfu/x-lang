#!/bin/sh
# G7: Reproducible build gate — same input → bit-identical output.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${TMPDIR:-/tmp}"
ELF1="$WORKDIR/repro1.elf"
ELF2="$WORKDIR/repro2.elf"

echo "=== G7: Reproducible build gate ==="
sh "$SCRIPT_DIR/build-kernel.sh" "$SCRIPT_DIR/timer_isr.sx" "$ELF1" 2>/dev/null
sh "$SCRIPT_DIR/build-kernel.sh" "$SCRIPT_DIR/timer_isr.sx" "$ELF2" 2>/dev/null
H1=$(shasum -a 256 "$ELF1" | awk '{print $1}')
H2=$(shasum -a 256 "$ELF2" | awk '{print $1}')
echo "  build1: $H1"
echo "  build2: $H2"
if [ "$H1" = "$H2" ]; then
    echo "  G7: PASS (bit-identical)"
    exit 0
else
    echo "  G7: FAIL (hashes differ)"
    exit 1
fi
