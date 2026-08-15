// Isolated: UFCS METHOD VAR-assign of a 2-arg vector binop (`d = a.add4(b)`).
// let-init `let c = a.add4(b)` is already gated by vec_add4_method_inline.x.
// Non-let assign used to emit a real CALL; Darwin ARM64 callee only adds
// lane0 so d[1] stayed 0 (exit 12). This gate checks every lane on assign.
// Expected exit 0.
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
 * Exit 0 when METHOD/CALL VAR-assign writes every lane (not only lane 0).
 * @return i32 — 0 ok; 1..4 METHOD add; 5..8 METHOD sub; 9..10 CALL add
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let d: i32x4 = [0, 0, 0, 0];
  d = a.add4(b);
  if (d[0] != 11) { return 1; }
  if (d[1] != 22) { return 2; }
  if (d[2] != 33) { return 3; }
  if (d[3] != 44) { return 4; }
  d = d.sub4(b);
  if (d[0] != 1) { return 5; }
  if (d[1] != 2) { return 6; }
  if (d[2] != 3) { return 7; }
  if (d[3] != 4) { return 8; }
  d = add4(a, b);
  if (d[0] != 11) { return 9; }
  if (d[3] != 44) { return 10; }
  return 0;
}
