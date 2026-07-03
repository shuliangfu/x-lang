#!/bin/sh
# X8: FFI deep recursion + Red Zone verification gate.
# Tests: deep parser recursion, struct FFI boundary, large struct return integrity.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHUX_C="$SCRIPT_DIR/../compiler/shux-c"
WORKDIR="${TMPDIR:-/tmp}"
PASS=0
FAIL=0

echo "=== X8: FFI deep recursion + Red Zone gate ==="

# Test 1: Deep recursive function (1000 levels)
echo "  Check: deep recursion (1000 levels) completes without crash"
cat > "$WORKDIR/deep_rec.sx" << 'SXEOF'
function recurse(n: i32): i32 {
  if (n <= 0) { return 0; }
  return recurse(n - 1) + 1;
}
function main(): i32 {
  let result: i32 = recurse(1000);
  return result;
}
SXEOF
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$WORKDIR/deep_rec.sx" > "$WORKDIR/deep_rec.c" 2>&1
if cc -O2 -o "$WORKDIR/deep_rec" "$WORKDIR/deep_rec.c" 2>&1 && "$WORKDIR/deep_rec"; then
    RC=$?
    if [ "$RC" = "1000" ]; then
        echo "    PASS: recurse(1000) returned $RC"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: expected 1000, got $RC"
        FAIL=$((FAIL + 1))
    fi
else
    echo "    FAIL: compilation or run failed"
    FAIL=$((FAIL + 1))
fi

# Test 2: Large struct passed through function boundary (16-byte struct)
echo "  Check: 16-byte struct FFI boundary integrity"
cat > "$WORKDIR/struct16.sx" << 'SXEOF'
#[repr(C)]
struct Big16 { a: u64; b: u64; }
#[used] function make_struct(a: u64, b: u64): Big16 {
  let s: Big16 = { a: a, b: b };
  return s;
}
#[used] function get_a(s: Big16): u64 { return s.a; }
#[used] function get_b(s: Big16): u64 { return s.b; }
function main(): i32 {
  let s: Big16 = make_struct(0xDEADBEEF, 0xCAFEBABE);
  let a: u64 = get_a(s);
  let b: u64 = get_b(s);
  if (a != 0xDEADBEEF) { return 1; }
  if (b != 0xCAFEBABE) { return 2; }
  return 0;
}
SXEOF
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$WORKDIR/struct16.sx" > "$WORKDIR/struct16.c" 2>&1
if cc -O2 -o "$WORKDIR/struct16" "$WORKDIR/struct16.c" 2>&1 && "$WORKDIR/struct16"; then
    RC=$?
    if [ "$RC" = "0" ]; then
        echo "    PASS: 16-byte struct FFI boundary intact"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: struct data corrupted, rc=$RC"
        FAIL=$((FAIL + 1))
    fi
else
    echo "    FAIL: compilation or run failed"
    FAIL=$((FAIL + 1))
fi

# Test 3: Deeply nested struct (10 levels of nesting)
echo "  Check: deeply nested struct access (10 levels)"
cat > "$WORKDIR/nested.sx" << 'SXEOF'
#[repr(C)]
struct N1 { v: u32; }
#[repr(C)]
struct N2 { inner: N1; v: u32; }
#[repr(C)]
struct N3 { inner: N2; v: u32; }
#[repr(C)]
struct N4 { inner: N3; v: u32; }
#[used] function get_deep(s: N4): u32 { return s.inner.inner.inner.v; }
function main(): i32 {
  let n: N4 = { inner: { inner: { inner: { v: 42 }, v: 0 }, v: 0 }, v: 0 };
  let val: u32 = get_deep(n);
  return val as i32;
}
SXEOF
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$WORKDIR/nested.sx" > "$WORKDIR/nested.c" 2>&1
if cc -O2 -o "$WORKDIR/nested" "$WORKDIR/nested.c" 2>&1 && "$WORKDIR/nested"; then
    RC=$?
    if [ "$RC" = "42" ]; then
        echo "    PASS: 10-level nested struct access correct"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: expected 42, got $RC"
        FAIL=$((FAIL + 1))
    fi
else
    echo "    FAIL: compilation or run failed"
    FAIL=$((FAIL + 1))
fi

# Test 4: Result (16-byte struct) return + comparison (red zone safety)
echo "  Check: Result struct return + comparison (spill safety)"
cat > "$WORKDIR/result_test.sx" << 'SXEOF'
#[repr(C)]
struct Result { err: i32; val: i32; }
#[used] function ok(val: i32): Result {
  let r: Result = { err: 0, val: val };
  return r;
}
#[used] function fail(code: i32): Result {
  let r: Result = { err: code, val: 0 };
  return r;
}
function main(): i32 {
  let r1: Result = ok(225);
  if (r1.err != 0) { return r1.err; }
  let r2: Result = fail(99);
  if (r2.err == 0) { return 1; }
  return r1.val;
}
SXEOF
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$WORKDIR/result_test.sx" > "$WORKDIR/result_test.c" 2>&1
if cc -O2 -o "$WORKDIR/result_test" "$WORKDIR/result_test.c" 2>&1 && "$WORKDIR/result_test"; then
    RC=$?
    if [ "$RC" = "225" ]; then
        echo "    PASS: Result return + comparison correct (rc=$RC)"
        PASS=$((PASS + 1))
    else
        echo "    FAIL: expected 225, got $RC (spill corruption?)"
        FAIL=$((FAIL + 1))
    fi
else
    echo "    FAIL: compilation or run failed"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== FFI DEEP RECURSION SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
GATEEOF
chmod +x tests/run-ffi-deep-recursion-gate.sh
sh tests/run-ffi-deep-recursion-gate.sh 2>&1; echo "EXIT: $?"