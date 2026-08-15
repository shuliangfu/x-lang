// Isolated: FIELD dest of a 2-arg vector binop CALL / UFCS METHOD
// (`h.v = add4(a,b)` / `h.v = a.add4(b)`). VAR dest
// `d = a.add4(b)` is already gated by vec_add4_method_assign.x.
// FIELD dest used to emit a real CALL then 16B dual-GP store;
// Darwin ARM64 callee only adds lane0 so h.v[1] stayed 0 (exit 20).
// This gate checks every lane on FIELD dest copy / CALL / METHOD
// with a VAR receiver. FIELD-as-receiver (`h.v = h.v.sub4(b)`)
// is gated by vec_add4_field_recv.x.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without let-init.

allow(padding) struct Holder {
  v: i32x4
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
 * Exit 0 when FIELD dest copy/CALL/METHOD (VAR receiver) writes every lane.
 * @return i32 — 0 ok; 1..4 copy; 10..40 CALL add; 11..41 METHOD add
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let z: i32x4 = [0, 0, 0, 0];
  let h: Holder = Holder { v: z };
  h.v = a;
  if (h.v[0] != 1) { return 1; }
  if (h.v[1] != 2) { return 2; }
  if (h.v[2] != 3) { return 3; }
  if (h.v[3] != 4) { return 4; }
  h.v = add4(a, b);
  if (h.v[0] != 11) { return 10; }
  if (h.v[1] != 22) { return 20; }
  if (h.v[2] != 33) { return 30; }
  if (h.v[3] != 44) { return 40; }
  h.v = a.add4(b);
  if (h.v[0] != 11) { return 11; }
  if (h.v[1] != 22) { return 21; }
  if (h.v[2] != 33) { return 31; }
  if (h.v[3] != 44) { return 41; }
  return 0;
}
