// Isolated: INDEX on a METHOD/CALL that returns SIMD (Vec4f / i32x4).
// Documented leftover after import METHOD ARRAY_LIT SIMD T001:
// `simd.add(...)[0]` SEGV — let-then `let r = simd.add(...); r[0]` is green.
// Do not reopen dest-SLICE / nest>16 / TYPE_DYN / 4.2.4–5 / 4.2.7.
// Expected: compile = 0, run = 0 (host-C + asm).
// PLATFORM: SHARED — Ubuntu gold INDEX-on-METHOD.

const simd = import("std.simd");

/**
 * Add two i32x4 values so CALL-then-INDEX can be compared to METHOD-then-INDEX.
 * @param a i32x4 — left lanes
 * @param b i32x4 — right lanes
 * @return i32x4 — a + b
 */
function add4(a: i32x4, b: i32x4): i32x4 {
  return a + b;
}

/**
 * Exit 0 when INDEX of METHOD/CALL SIMD results yields the expected lane.
 * Non-const extras block WPO fold so run≠11 cannot hide behind mov-imm.
 * @return i32 — 0 ok, else the failing case
 */
function main(): i32 {
  /* Documented hole: INDEX directly on import METHOD SIMD result. */
  if (simd.add([1.0, 2.0, 3.0, 4.0], [10.0, 20.0, 30.0, 40.0])[0] != 11.0) {
    return 1;
  }
  /* Same-layer CALL twin (no import). */
  if (add4([1, 2, 3, 4], [10, 20, 30, 40])[0] != 11) {
    return 2;
  }
  /* let-then neighborhood already green on array_lit_vec4f_import. */
  let r: Vec4f = simd.add([1.0, 2.0, 3.0, 4.0], [10.0, 20.0, 30.0, 40.0]);
  if (r[0] != 11.0) { return 3; }
  /* Non-const: fold cannot mov-imm; must spill CALL/METHOD then INDEX. */
  let y: i32 = 10;
  if (add4([1, 2, 3, 4], [y, 20, 30, 40])[0] != 11) {
    return 4;
  }
  let z: f32 = 10.0;
  if (simd.add([1.0, 2.0, 3.0, 4.0], [z, 20.0, 30.0, 40.0])[0] != 11.0) {
    return 5;
  }
  return 0;
}
