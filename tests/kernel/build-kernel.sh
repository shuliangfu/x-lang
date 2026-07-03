#!/bin/sh
# Build a shux kernel .sx → multiboot1 ELF for QEMU.
# Usage: build-kernel.sh input.sx output.elf
set -e
SX="$1"
ELF="${2:-kernel.elf}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHUX_C="$SCRIPT_DIR/../../compiler/shux-c"
LD_SCRIPT="$SCRIPT_DIR/kernel.ld"

if [ ! -f "$SHUX_C" ]; then
    echo "ERROR: shux-c not found at $SHUX_C" >&2
    exit 1
fi

WORKDIR="${TMPDIR:-/tmp}"
C_FILE="$WORKDIR/shux_kernel.c"
OBJ_FILE="$WORKDIR/shux_kernel.o"
STUBS_O="$WORKDIR/shux_freestanding_stubs.o"

# Build freestanding stubs (shux codegen always emits shux_panic_ refs)
if [ ! -f "$STUBS_O" ]; then
    XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
        zig cc -target x86-linux-gnu -ffreestanding -fno-sanitize=all -c -o "$STUBS_O" "$SCRIPT_DIR/freestanding_stubs.c"
fi

# 1. shux-c -E: .sx → C
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$SX" > "$C_FILE"

# 2. zig cc: C → .o (32-bit x86 freestanding)
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86-linux-gnu -ffreestanding -fno-sanitize=all -fno-stack-protector \
    -c -o "$OBJ_FILE" "$C_FILE"

# 3. zig cc: .o → ELF (nostdlib + linker script + freestanding stubs)
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86-linux-gnu -ffreestanding -nostdlib -fno-sanitize=all \
    -T "$LD_SCRIPT" -o "$ELF" "$OBJ_FILE" "$STUBS_O"

echo "Built $ELF"
