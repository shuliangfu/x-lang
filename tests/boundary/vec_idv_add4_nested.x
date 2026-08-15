// Isolated: nested identity CALL of a 2-arg vector binop
// (`let c = idv(add4(a,b))`). Split `let t = add4; let c = idv(t)`
// is already green. Nested let-init used to emit a real CALL of idv;
// the add4 arg was a real CALL whose callee only adds lane0
// (Darwin 2). G.7: peel 1-param `return p0` and reuse vector
// let-init on arg0 (add4 then hits binop2). Does not fold
// FIELD-as-receiver or non-identity wrap. return idv(add4)[i]
// is gated by vec_idv_add4_index.x.
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
 * Exit 0 when idv(add4(a,b)) writes every lane.
 * @return i32 — 0 ok; 1..4 nested let; 10..40 split let
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let c: i32x4 = idv(add4(a, b));
  if (c[0] != 11) { return 1; }
  if (c[1] != 22) { return 2; }
  if (c[2] != 33) { return 3; }
  if (c[3] != 44) { return 4; }
  let t: i32x4 = add4(a, b);
  let d: i32x4 = idv(t);
  if (d[0] != 11) { return 10; }
  if (d[1] != 22) { return 20; }
  if (d[2] != 33) { return 30; }
  if (d[3] != 44) { return 40; }
  return 0;
}
