// Isolated: FIELD-chain receiver of a 2-arg vector binop
// (`w.h.v = w.h.v.add4(b)` / `w.h.v = w.h.v.sub4(b)` /
// `w.h.v = add4(w.h.v, b)`). Observe via `let t: i32x4 = w.h.v`
// (vector let-init FIELD source); do not INDEX `w.h.v[i]`
// (FIELD-chain SIMD INDEX leftover) and do not fold prefixed
// `tag + Holder` (field_off≠0 SIMD dest leftover).
// Depth-1 FIELD receiver is already gated by vec_add4_field_recv.x.
// Split `let t = w.h.v; t = t.add4(b)` was already 0 (binop2 VAR-base).
// Chain receiver used to miss glue_vector_var_lane_stack_off
// (base_ko!=3) so binop2 fell to a real CALL and Darwin ARM64
// callee only added lane0 (exit 22). Copy-out used to be an 8B
// struct fallthrough (t[2] leftover).
// Does not fold pointer *Holder, nest 21, or second SIMD ARRAY_LIT.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without
// FIELD-chain lane stack-off.

allow(padding) struct Holder {
  v: i32x4
}

allow(padding) struct Wrap {
  h: Holder
}

/**
 * Two-arg i32x4 add used as both free CALL and UFCS METHOD.
 * @param self i32x4 — left lanes (UFCS receiver / CALL arg0)
 * @param other i32x4 — right lanes
 * @return i32x4 — self + other (fold: return p0 + p1)
 */
function add4(self: i32x4, other: i32x4): i32x4 {
  return self + other;
}

/**
 * Two-arg i32x4 sub (same fold, different binop ko).
 * @param self i32x4 — left lanes
 * @param other i32x4 — right lanes
 * @return i32x4 — self - other
 */
function sub4(self: i32x4, other: i32x4): i32x4 {
  return self - other;
}

/**
 * Exit 0 when FIELD-chain receiver METHOD/CALL writes every lane.
 * @return i32 — 0 ok; 11..44 METHOD add; 1..4 METHOD sub;
 *   51..54 CALL add
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let z: i32x4 = [0, 0, 0, 0];
  let inner: Holder = Holder { v: z };
  let w: Wrap = Wrap { h: inner };
  w.h.v = a;
  w.h.v = w.h.v.add4(b);
  let t: i32x4 = w.h.v;
  if (t[0] != 11) { return 11; }
  if (t[1] != 22) { return 22; }
  if (t[2] != 33) { return 33; }
  if (t[3] != 44) { return 44; }
  w.h.v = w.h.v.sub4(b);
  let u: i32x4 = w.h.v;
  if (u[0] != 1) { return 1; }
  if (u[1] != 2) { return 2; }
  if (u[2] != 3) { return 3; }
  if (u[3] != 4) { return 4; }
  w.h.v = add4(w.h.v, b);
  let c: i32x4 = w.h.v;
  if (c[0] != 11) { return 51; }
  if (c[1] != 22) { return 52; }
  if (c[2] != 33) { return 53; }
  if (c[3] != 44) { return 54; }
  return 0;
}
