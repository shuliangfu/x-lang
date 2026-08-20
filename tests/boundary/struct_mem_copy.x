// Isolated: >16B MEMORY-class struct VAR copy (`y = x` / `let y = x`).
// Let-init and VAR assign of CALL already install sret. VAR-to-VAR used
// to store only rax (first 8B), so y.b stayed 0 (Darwin 2). 24B and 32B
// share the same produce (glue_emit_struct_type_let_init VAR + memcpy).
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without copy.

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
 * Copy a 32B formal into a local then return it (assign + sret return).
 * @param p Quad — stack / sret payload
 * @return Quad — same quad after VAR assign copy
 */
function via_assign(p: Quad): Quad {
  let y: Quad = { a: 0, b: 0, c: 0, d: 0 };
  y = p;
  return y;
}

/**
 * Exit 0 when VAR copy writes every half of 24B / 32B / let-init / param.
 * @return i32 — 0 ok; 1..3 = 24B assign; 4..7 = 32B assign;
 *   8..11 = 32B let-init; 12..15 = param assign
 */
function main(): i32 {
  let t: Trip = { a: 1, b: 2, c: 3 };
  let u: Trip = { a: 0, b: 0, c: 0 };
  u = t;
  if (u.a != 1) { return 1; }
  if (u.b != 2) { return 2; }
  if (u.c != 3) { return 3; }
  let x: Quad = { a: 1, b: 2, c: 3, d: 4 };
  let y: Quad = { a: 0, b: 0, c: 0, d: 0 };
  y = x;
  if (y.a != 1) { return 4; }
  if (y.b != 2) { return 5; }
  if (y.c != 3) { return 6; }
  if (y.d != 4) { return 7; }
  let z: Quad = x;
  if (z.a != 1) { return 8; }
  if (z.b != 2) { return 9; }
  if (z.c != 3) { return 10; }
  if (z.d != 4) { return 11; }
  let w: Quad = via_assign(x);
  if (w.a != 1) { return 12; }
  if (w.b != 2) { return 13; }
  if (w.c != 3) { return 14; }
  if (w.d != 4) { return 15; }
  return 0;
}
