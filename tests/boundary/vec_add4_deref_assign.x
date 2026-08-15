// Isolated: VECTOR dest-in-rbx CALL (`*p = add4(a, b)`).
// Real add4 callee only adds lane0 (`add w0,w1,w0`). VAR `d = add4`
// already reuses vector let-init. dest-in-rbx parks dest, let-inits a
// temp, memcpy dest-in-rbx. Does not save x19 in the prologue.
// Deref write is unsafe.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail.

/**
 * Identity add of two i32x4 (inlined at dest-in-rbx CALL via let-init).
 * @param a i32x4 — lhs
 * @param b i32x4 — rhs
 * @return i32x4 — a + b
 */
function add4(a: i32x4, b: i32x4): i32x4 {
  return a + b;
}

/**
 * Identity sub of two i32x4.
 * @param a i32x4 — lhs
 * @param b i32x4 — rhs
 * @return i32x4 — a - b
 */
function sub4(a: i32x4, b: i32x4): i32x4 {
  return a - b;
}

/**
 * Exit 0 when dest-in-rbx VECTOR CALL writes every lane.
 * @return i32 — 0 ok; 1..8 fail
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let d: i32x4 = [0, 0, 0, 0];
  let p: *i32x4 = &d;
  unsafe { *p = add4(a, b) }
  if (d[0] != 11) { return 1; }
  if (d[1] != 22) { return 2; }
  if (d[2] != 33) { return 3; }
  if (d[3] != 44) { return 4; }

  let e: i32x4 = [0, 0, 0, 0];
  let q: *i32x4 = &e;
  unsafe { *q = sub4(b, a) }
  if (e[0] != 9) { return 5; }
  if (e[1] != 18) { return 6; }
  if (e[2] != 27) { return 7; }
  if (e[3] != 36) { return 8; }

  return 0;
}
