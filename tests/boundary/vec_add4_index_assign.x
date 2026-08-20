// Isolated: INDEX dest of a 2-arg vector binop CALL / UFCS METHOD
// (`arr[0] = add4(a,b)` / `arr[0] = a.add4(b)`). FIELD dest
// `h.v = add4` is already gated by vec_add4_field_assign.x.
// After ARRAY_LIT SIMD VAR the ctor `[z,z]` is green; INDEX dest
// CALL used dest-in-rbx + struct let-init −2 then a real CALL.
// Darwin ARM64 callee only adds lane0 so arr[0][1] stayed 0 (exit 2).
// This gate checks every lane on INDEX dest copy / CALL / METHOD
// with a VAR+lit dest (`arr[0]`). Slice dest / nested `arr[0][0]`
// / INDEX `arr[1]` are leftovers.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without let-init.

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
 * Exit 0 when INDEX dest copy/CALL/METHOD (VAR+lit) writes every lane.
 * @return i32 — 0 ok; 1..4 copy; 10..40 CALL add; 11..41 METHOD add
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let z: i32x4 = [0, 0, 0, 0];
  let arr: [2]i32x4 = [z, z];
  arr[0] = a;
  let c0: i32x4 = arr[0];
  if (c0[0] != 1) { return 1; }
  if (c0[1] != 2) { return 2; }
  if (c0[2] != 3) { return 3; }
  if (c0[3] != 4) { return 4; }
  arr[0] = add4(a, b);
  let t: i32x4 = arr[0];
  if (t[0] != 11) { return 10; }
  if (t[1] != 22) { return 20; }
  if (t[2] != 33) { return 30; }
  if (t[3] != 44) { return 40; }
  arr[0] = a.add4(b);
  let m: i32x4 = arr[0];
  if (m[0] != 11) { return 11; }
  if (m[1] != 22) { return 21; }
  if (m[2] != 33) { return 31; }
  if (m[3] != 44) { return 41; }
  return 0;
}
