#!/bin/sh
# K11/L10: Build a shux kernel for x86_64 (high-half, kernel code model, no red zone).
# Produces a 64-bit ELF. For QEMU boot, needs 32-bit multiboot1 entry that
# switches to long mode (see boot64.s).
# Usage: build-kernel64.sh input.sx output.elf [boot32.o]
set -e
SX="$1"
ELF="${2:-kernel64.elf}"
BOOT32="${3:-}"  # optional 32-bit boot object
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHUX_C="$SCRIPT_DIR/../../compiler/shux-c"
LD_SCRIPT="$SCRIPT_DIR/kernel64.ld"

WORKDIR="${TMPDIR:-/tmp}"
C_FILE="$WORKDIR/shux_kernel64.c"
OBJ_FILE="$WORKDIR/shux_kernel64.o"
STUBS_O="$WORKDIR/shux_freestanding_stubs64.o"

# Build 64-bit freestanding stubs
if [ ! -f "$STUBS_O" ]; then
    XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
        zig cc -target x86_64-linux-gnu -ffreestanding -fno-sanitize=all -c -o "$STUBS_O" "$SCRIPT_DIR/freestanding_stubs.c"
fi

# 1. shux-c -E: .sx → C
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$SX" > "$C_FILE"

# 2. zig cc: C → .o (64-bit x86_64, kernel code model, no red zone)
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86_64-linux-gnu -ffreestanding -fno-sanitize=all -fno-stack-protector \
    -mcmodel=kernel -mno-red-zone -c -o "$OBJ_FILE" "$C_FILE"

# 3. zig cc: .o → ELF (nostdlib + linker script + stubs + optional 32-bit boot)
if [ -n "$BOOT32" ] && [ -f "$BOOT32" ]; then
    XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
        zig cc -target x86_64-linux-gnu -ffreestanding -nostdlib -fno-sanitize=all \
        -T "$LD_SCRIPT" -o "$ELF" "$OBJ_FILE" "$STUBS_O" "$BOOT32"
else
    XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
        zig cc -target x86_64-linux-gnu -ffreestanding -nostdlib -fno-sanitize=all \
        -T "$LD_SCRIPT" -o "$ELF" "$OBJ_FILE" "$STUBS_O"
fi

echo "Built $ELF (x86_64, kernel code model, no red zone)"
