// Isolated: nested >16B MEMORY CALL as arg of another MEMORY CALL.
// `y = id32(x)` already installs sret dest. `y = id32(id32(x))` used
// to overwrite x8/rdi with the inner temp, so the outer bl wrote the
// temp and left y zero (Darwin RUN 1 / dump 0). 16B nested is dual-GP
// and already green. field_off!=0 Prefixed is a later leaf.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail.

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
 * Exit 0 when nested sret writes every half of the outer dest.
 * @return i32 — 0 ok; 1..3 = 24B assign; 4..7 = 32B assign;
 *   8..11 = 32B let-init; 12..15 = 32B 3-deep
 */
function main(): i32 {
  let t: Trip = Trip { a: 1, b: 2, c: 3 };
  let u: Trip = Trip { a: 0, b: 0, c: 0 };
  u = id24(id24(t));
  if (u.a != 1) { return 1; }
  if (u.b != 2) { return 2; }
  if (u.c != 3) { return 3; }
  let x: Quad = Quad { a: 1, b: 2, c: 3, d: 4 };
  let y: Quad = Quad { a: 0, b: 0, c: 0, d: 0 };
  y = id32(id32(x));
  if (y.a != 1) { return 4; }
  if (y.b != 2) { return 5; }
  if (y.c != 3) { return 6; }
  if (y.d != 4) { return 7; }
  let z: Quad = id32(id32(x));
  if (z.a != 1) { return 8; }
  if (z.b != 2) { return 9; }
  if (z.c != 3) { return 10; }
  if (z.d != 4) { return 11; }
  let w: Quad = Quad { a: 0, b: 0, c: 0, d: 0 };
  w = id32(id32(id32(x)));
  if (w.a != 1) { return 12; }
  if (w.b != 2) { return 13; }
  if (w.c != 3) { return 14; }
  if (w.d != 4) { return 15; }
  return 0;
}
