// Isolated: UFCS METHOD let-init of a 2-arg vector binop (`a.add4(b)`).
// CALL neighborhood `add4(a, b)` must stay inlined (vec_add4_call_inline.x).
// Official array_lit_i32x4_method.x only checks lane 0 — that hid CALL-only
// emit (Darwin ARM64 passes first 8B and the callee does add w of lane 0).
// This gate checks every lane. Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without inline.

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
 * Exit 0 when METHOD let-init writes every lane (not only lane 0).
 * @return i32 — 0 ok; 1..4 METHOD add lane; 5..8 METHOD sub lane; 9 CALL add
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let c: i32x4 = a.add4(b);
  if (c[0] != 11) { return 1; }
  if (c[1] != 22) { return 2; }
  if (c[2] != 33) { return 3; }
  if (c[3] != 44) { return 4; }
  let d: i32x4 = c.sub4(b);
  if (d[0] != 1) { return 5; }
  if (d[1] != 2) { return 6; }
  if (d[2] != 3) { return 7; }
  if (d[3] != 4) { return 8; }
  let e: i32x4 = add4(a, b);
  if (e[0] != 11) { return 9; }
  if (e[3] != 44) { return 10; }
  return 0;
}
