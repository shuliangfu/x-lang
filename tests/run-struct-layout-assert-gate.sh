#!/bin/sh
# X5: Struct layout static assert gate — verify AST/IR struct offsetof stability.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHUX_C="$SCRIPT_DIR/../compiler/shux-c"
WORKDIR="${TMPDIR:-/tmp}"
PASS=0
FAIL=0

echo "=== X5: Struct layout static assert gate ==="

# Test 1: Basic struct sizes
cat > "$WORKDIR/struct_layout.x" << 'XEOF'
#[repr(C)]
struct Layout8 { a: u8; b: u8; }
#[repr(C)]
struct Layout16 { a: u16; b: u16; }
#[repr(C)]
struct Layout32 { a: u32; b: u32; }
#[repr(C)]
struct Layout64 { a: u64; b: u64; }
#[repr(C)]
struct LayoutMixed { a: u8; b: u32; c: u8; }
// Force struct emission via function signatures
#[used] function get_a8(s: Layout8): i32 { return s.a as i32; }
#[used] function get_a16(s: Layout16): i32 { return s.a as i32; }
#[used] function get_a32(s: Layout32): i32 { return s.a as i32; }
#[used] function get_a64(s: Layout64): i64 { return s.a as i64; }
#[used] function get_mix(s: LayoutMixed): i32 { return s.a as i32; }
function main(): i32 { return 0; }
XEOF

echo "  Check: struct definitions emitted in C output"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$WORKDIR/struct_layout.x" > "$WORKDIR/struct_layout.c" 2>&1
if grep -q "struct Layout8 {" "$WORKDIR/struct_layout.c" && grep -q "struct Layout32 {" "$WORKDIR/struct_layout.c"; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL: struct definitions not found"
    FAIL=$((FAIL + 1))
fi

echo "  Check: struct sizes match expected values (static_assert)"
cat >> "$WORKDIR/struct_layout.c" << 'CEOF'
#include <assert.h>
#include <stddef.h>
_Static_assert(sizeof(struct Layout8) == 2, "Layout8 should be 2 bytes");
_Static_assert(sizeof(struct Layout16) == 4, "Layout16 should be 4 bytes");
_Static_assert(sizeof(struct Layout32) == 8, "Layout32 should be 8 bytes");
_Static_assert(sizeof(struct Layout64) == 16, "Layout64 should be 16 bytes");
_Static_assert(offsetof(struct LayoutMixed, a) == 0, "LayoutMixed.a at offset 0");
_Static_assert(offsetof(struct LayoutMixed, b) == 4, "LayoutMixed.b at offset 4 (aligned)");
CEOF
if cc -O2 -o /dev/null -c "$WORKDIR/struct_layout.c" 2>&1; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL: static_assert failed"
    FAIL=$((FAIL + 1))
fi

# Test 2: Kernel struct layouts (x86 cross-compile)
echo "  Check: kernel struct layout stable on x86-linux target"
cat > "$WORKDIR/struct_x86.x" << 'XEOF'
#[repr(C)]
struct IDTEntry { offset_low: u16; selector: u16; zero: u8; flags: u8; offset_high: u16; }
#[repr(C)]
struct MB1Header { magic: u32; flags: u32; checksum: u32; }
#[repr(C)]
struct Context { sp: u32; }
#[used] function idt_off(s: IDTEntry): i32 { return s.offset_low as i32; }
#[used] function mb1_magic(s: MB1Header): i32 { return s.magic as i32; }
#[used] function ctx_sp(s: Context): i32 { return s.sp as i32; }
function main(): i32 { return 0; }
XEOF
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$WORKDIR/struct_x86.x" > "$WORKDIR/struct_x86.c" 2>&1
cat >> "$WORKDIR/struct_x86.c" << 'CEOF'
#include <assert.h>
#include <stddef.h>
_Static_assert(sizeof(struct IDTEntry) == 8, "IDTEntry 8 bytes");
_Static_assert(offsetof(struct IDTEntry, offset_low) == 0, "offset_low at 0");
_Static_assert(offsetof(struct IDTEntry, selector) == 2, "selector at 2");
_Static_assert(offsetof(struct IDTEntry, flags) == 5, "flags at 5");
_Static_assert(sizeof(struct MB1Header) == 12, "MB1Header 12 bytes");
_Static_assert(sizeof(struct Context) == 4, "Context 4 bytes");
CEOF
if XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" zig cc -target x86-linux-gnu -ffreestanding -c -o /dev/null "$WORKDIR/struct_x86.c" 2>&1; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL: cross-compile static_assert failed"
    FAIL=$((FAIL + 1))
fi

# Test 3: Packed struct (no padding)
echo "  Check: packed struct has no padding"
cat > "$WORKDIR/packed.x" << 'XEOF'
struct PackedMixed packed { a: u8; b: u32; c: u8; }
#[used] function pk_a(s: PackedMixed): i32 { return s.a as i32; }
function main(): i32 { return 0; }
XEOF
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$WORKDIR/packed.x" > "$WORKDIR/packed.c" 2>&1
cat >> "$WORKDIR/packed.c" << 'CEOF'
#include <assert.h>
#include <stddef.h>
_Static_assert(sizeof(struct PackedMixed) == 6, "PackedMixed 6 bytes (no padding)");
CEOF
if cc -O2 -o /dev/null -c "$WORKDIR/packed.c" 2>&1; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL: packed struct has unexpected padding"
    FAIL=$((FAIL + 1))
fi

# Test 4: Bitfield struct layout
echo "  Check: bitfield struct layout"
cat > "$WORKDIR/bf.x" << 'XEOF'
#[repr(C)]
struct BF3 { a: u32 : 3; b: u32 : 5; c: u32 : 24; }
#[used] function bf_a(s: BF3): i32 { return s.a as i32; }
function main(): i32 { return 0; }
XEOF
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$WORKDIR/bf.x" > "$WORKDIR/bf.c" 2>&1
cat >> "$WORKDIR/bf.c" << 'CEOF'
#include <assert.h>
#include <stddef.h>
/* All bitfields fit in one u32 (3+5+24=32 bits) */
_Static_assert(sizeof(struct BF3) == 4, "BF3 should be 4 bytes (32 bits in one u32)");
CEOF
if cc -O2 -o /dev/null -c "$WORKDIR/bf.c" 2>&1; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL: bitfield layout assertion failed"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== STRUCT LAYOUT ASSERT SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
GATEEOF
sh tests/run-struct-layout-assert-gate.sh 2>&1; echo "EXIT: $?"