#!/bin/sh
# A3: Cross-architecture kernel target gate — verify shux-c C output
# cross-compiles to x86, arm64, riscv64 via zig cc.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHUX_C="$SCRIPT_DIR/../../compiler/shux-c"
WORKDIR="${TMPDIR:-/tmp}"
PASS=0
FAIL=0

echo "=== A3: Cross-architecture kernel target gate ==="

# Simple arch-neutral kernel (no arch-specific asm in body)
cat > "$WORKDIR/cross_arch.sx" << 'SXEOF'
function kmain(): i32 { return 42; }
function main(): i32 { return kmain(); }
SXEOF

XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$WORKDIR/cross_arch.sx" > "$WORKDIR/cross_arch.c" 2>/dev/null

# Test x86 (32-bit)
echo "  Check: x86 (i386) compilation"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86-linux-gnu -ffreestanding -fno-sanitize=all -c -o "$WORKDIR/cross_x86.o" "$WORKDIR/cross_arch.c" 2>&1; then
    ARCH=$(file "$WORKDIR/cross_x86.o" 2>/dev/null)
    if echo "$ARCH" | grep -q 'Intel 80386\|i386'; then
        echo "    PASS: $ARCH"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: wrong arch: $ARCH"
        FAIL=$((FAIL + 1))
    fi
else
    echo "    FAIL: compilation failed"
    FAIL=$((FAIL + 1))
fi

# Test x86_64
echo "  Check: x86_64 compilation"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target x86_64-linux-gnu -ffreestanding -fno-sanitize=all -c -o "$WORKDIR/cross_x64.o" "$WORKDIR/cross_arch.c" 2>&1; then
    ARCH=$(file "$WORKDIR/cross_x64.o" 2>/dev/null)
    if echo "$ARCH" | grep -q 'x86-64'; then
        echo "    PASS: $ARCH"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: wrong arch: $ARCH"
        FAIL=$((FAIL + 1))
    fi
else
    echo "    FAIL: compilation failed"
    FAIL=$((FAIL + 1))
fi

# Test arm64
echo "  Check: arm64 (aarch64) compilation"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target aarch64-linux-gnu -ffreestanding -fno-sanitize=all -c -o "$WORKDIR/cross_arm64.o" "$WORKDIR/cross_arch.c" 2>&1; then
    ARCH=$(file "$WORKDIR/cross_arm64.o" 2>/dev/null)
    if echo "$ARCH" | grep -q 'ARM aarch64'; then
        echo "    PASS: $ARCH"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: wrong arch: $ARCH"
        FAIL=$((FAIL + 1))
    fi
else
    echo "    FAIL: compilation failed"
    FAIL=$((FAIL + 1))
fi

# Test riscv64
echo "  Check: riscv64 compilation"
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" \
    zig cc -target riscv64-linux-gnu -ffreestanding -fno-sanitize=all -c -o "$WORKDIR/cross_riscv.o" "$WORKDIR/cross_arch.c" 2>&1; then
    ARCH=$(file "$WORKDIR/cross_riscv.o" 2>/dev/null)
    if echo "$ARCH" | grep -q 'RISC-V'; then
        echo "    PASS: $ARCH"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: wrong arch: $ARCH"
        FAIL=$((FAIL + 1))
    fi
else
    echo "    FAIL: compilation failed"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== CROSS-ARCH SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
