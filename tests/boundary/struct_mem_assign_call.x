// Isolated: >16B MEMORY-class struct assign dest after X-to-X CALL.
// Let-init `let y = id32(x)` already installs AAPCS64 x8 / SysV rdi sret
// so the callee memcpy writes the slot. VAR assign used to emit CALL
// without sret dest, then memcpy(y, *rax) → Darwin SIGBUS 138.
// 24B and 32B share the same produce point (store_retval_pair sz>16).
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without sret.

allow(padding) struct Trip {
  a: i64
  b: i64
  c: i64
}

allow(padding) struct Quad {
  a: i64
  b: i64
  c: i64
  d: i64
}

/**
 * Identity on a 24B MEMORY-class struct (hidden sret dest).
 * @param p Trip — stack / sret payload
 * @return Trip — same trip via callee memcpy into dest
 */
function id24(p: Trip): Trip {
  return p;
}

/**
 * Identity on a 32B MEMORY-class struct (hidden sret dest).
 * @param p Quad — stack / sret payload
 * @return Quad — same quad via callee memcpy into dest
 */
function id32(p: Quad): Quad {
  return p;
}

/**
 * Nested dest-across-call: assign inner into a local, then return it.
 * @param p Quad — input
 * @return Quad — id32(p)
 */
function outer32(p: Quad): Quad {
  let t: Quad = { a: 0, b: 0, c: 0, d: 0 };
  t = id32(p);
  return t;
}

/**
 * Exit 0 when assign dest is the sret slot (callee writes all halves).
 * @return i32 — 0 ok; 1..3 = 24B; 4..7 = 32B; 8..11 = nested 32B
 */
function main(): i32 {
  let t: Trip = { a: 1, b: 2, c: 3 };
  let u: Trip = { a: 0, b: 0, c: 0 };
  u = id24(t);
  if (u.a != 1) { return 1; }
  if (u.b != 2) { return 2; }
  if (u.c != 3) { return 3; }
  let x: Quad = { a: 1, b: 2, c: 3, d: 4 };
  let y: Quad = { a: 0, b: 0, c: 0, d: 0 };
  y = id32(x);
  if (y.a != 1) { return 4; }
  if (y.b != 2) { return 5; }
  if (y.c != 3) { return 6; }
  if (y.d != 4) { return 7; }
  let z: Quad = { a: 0, b: 0, c: 0, d: 0 };
  z = outer32(x);
  if (z.a != 1) { return 8; }
  if (z.b != 2) { return 9; }
  if (z.c != 3) { return 10; }
  if (z.d != 4) { return 11; }
  return 0;
}
