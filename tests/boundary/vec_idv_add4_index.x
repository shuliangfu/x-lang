// Isolated: INDEX of a nested identity SIMD CALL
// (`return idv(add4(a,b))[i]` / `idv(add4)[i]` as a cmp operand).
// Let-init `let c = idv(add4)` is already green. Bare
// `return idv(add4)[1]` used to exit 0 on Darwin (lane leftover;
// host-C 22). Same produce point: SIMD CALL as INDEX base went
// through struct let-init → real CALL → callee lane0 only.
// G.7: reuse vector let-init (identity peel + binop2) then lea.
// Also gates `return add4(a,b)[i]` (same INDEX-base path).
// Does not fold FIELD-chain, second SIMD ARRAY_LIT, or nest 21.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail.

/**
 * Two-arg i32x4 add (fold: return p0 + p1).
 * @param self i32x4 — left lanes
 * @param other i32x4 — right lanes
 * @return i32x4 — self + other
 */
function add4(self: i32x4, other: i32x4): i32x4 {
  return self + other;
}

/**
 * 1-param identity (fold: return p0).
 * @param v i32x4 — value
 * @return i32x4 — v
 */
function idv(v: i32x4): i32x4 {
  return v;
}

/**
 * Return lane 1 of idv(add4) — the exact leftover emit_expr shape.
 * @return i32 — 22 when every lane of the nested CALL is live
 */
function ret_idv_lane1(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  return idv(add4(a, b))[1];
}

/**
 * Return lane 1 of add4 — same INDEX-base produce point, no identity.
 * @return i32 — 22 when binop2 wrote every lane
 */
function ret_add4_lane1(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  return add4(a, b)[1];
}

/**
 * Exit 0 when INDEX-of-CALL writes every lane (not leftover 0).
 * @return i32 — 0 ok; 1..4 idv INDEX; 10..40 add4 INDEX; 50/60 return helpers
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  if (idv(add4(a, b))[0] != 11) { return 1; }
  if (idv(add4(a, b))[1] != 22) { return 2; }
  if (idv(add4(a, b))[2] != 33) { return 3; }
  if (idv(add4(a, b))[3] != 44) { return 4; }
  if (add4(a, b)[0] != 11) { return 10; }
  if (add4(a, b)[1] != 22) { return 20; }
  if (add4(a, b)[2] != 33) { return 30; }
  if (add4(a, b)[3] != 44) { return 40; }
  if (ret_idv_lane1() != 22) { return 50; }
  if (ret_add4_lane1() != 22) { return 60; }
  return 0;
}
