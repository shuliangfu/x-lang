// Isolated: FIELD-as-receiver of a 2-arg vector binop
// (`h.v = h.v.add4(b)` / `h.v = h.v.sub4(b)` / `h.v = add4(h.v, b)`).
// FIELD dest with a VAR receiver is already gated by
// vec_add4_field_assign.x. Split `let t = h.v; t = t.add4(b)` was
// already 0 (binop2 VAR-base). Depth-1 FIELD receiver used to miss
// glue_vector_var_lane_stack_off (ko!=3) so binop2 fell to a real CALL
// and Darwin ARM64 callee only added lane0 (exit 22).
// FIELD-chain `w.h.v.sub4` is gated by vec_add4_field_chain.x.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without
// FIELD lane stack-off.

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
 * Two-arg i32x4 sub (same fold, different binop ko).
 * @param self i32x4 — left lanes
 * @param other i32x4 — right lanes
 * @return i32x4 — self - other
 */
function sub4(self: i32x4, other: i32x4): i32x4 {
  return self - other;
}

/**
 * Exit 0 when FIELD-as-receiver METHOD/CALL writes every lane.
 * @return i32 — 0 ok; 11..44 METHOD add; 1..4 METHOD sub; 51..52 CALL add
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let z: i32x4 = [0, 0, 0, 0];
  let h: Holder = Holder { v: z };
  h.v = a;
  h.v = h.v.add4(b);
  if (h.v[0] != 11) { return 11; }
  if (h.v[1] != 22) { return 22; }
  if (h.v[2] != 33) { return 33; }
  if (h.v[3] != 44) { return 44; }
  h.v = h.v.sub4(b);
  if (h.v[0] != 1) { return 1; }
  if (h.v[1] != 2) { return 2; }
  if (h.v[2] != 3) { return 3; }
  if (h.v[3] != 4) { return 4; }
  h.v = add4(h.v, b);
  if (h.v[0] != 11) { return 51; }
  if (h.v[1] != 22) { return 52; }
  if (h.v[2] != 33) { return 53; }
  if (h.v[3] != 44) { return 54; }
  return 0;
}
