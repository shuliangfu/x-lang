// Isolated: TYPE_NAMED DEREF dest (`*p = id16(x)` / `*p = src`).
// Prior assign stored rax only through [rbx] (Darwin 16B leftover /
// >16B CALL SIGBUS). Dest = DEREF lvalue then
// glue_emit_struct_type_let_init DEST_IN_RBX=-3.
// Deref write is unsafe (bare `*p =` drops the function at parse).
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail.

allow(padding) struct Pair {
  a: i64
  b: i64
}

allow(padding) struct Triple {
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
 * Identity 16B (dual-GP return).
 * @param p Pair — stack payload
 * @return Pair — same pair
 */
function id16(p: Pair): Pair {
  return p;
}

/**
 * Identity 24B (AAPCS64 / SysV MEMORY sret).
 * @param p Triple — stack / sret payload
 * @return Triple — same triple
 */
function id24(p: Triple): Triple {
  return p;
}

/**
 * Identity 32B (AAPCS64 / SysV MEMORY sret).
 * @param p Quad — stack / sret payload
 * @return Quad — same quad
 */
function id32(p: Quad): Quad {
  return p;
}

/**
 * Exit 0 when DEREF dest writes every half.
 * @return i32 — 0 ok; 1..20 fail
 */
function main(): i32 {
  let x: Pair = { a: 1, b: 2 };
  let t: Triple = { a: 1, b: 2, c: 3 };
  let q: Quad = { a: 1, b: 2, c: 3, d: 4 };

  let d16: Pair = { a: 9, b: 9 };
  let p16: *Pair = &d16;
  unsafe { *p16 = id16(x) }
  if (d16.a != 1) { return 1; }
  if (d16.b != 2) { return 2; }

  let d16c: Pair = { a: 9, b: 9 };
  let p16c: *Pair = &d16c;
  unsafe { *p16c = x }
  if (d16c.a != 1) { return 3; }
  if (d16c.b != 2) { return 4; }

  let d24: Triple = { a: 9, b: 9, c: 9 };
  let p24: *Triple = &d24;
  unsafe { *p24 = id24(t) }
  if (d24.a != 1) { return 5; }
  if (d24.b != 2) { return 6; }
  if (d24.c != 3) { return 7; }

  let d32: Quad = { a: 9, b: 9, c: 9, d: 9 };
  let p32: *Quad = &d32;
  unsafe { *p32 = id32(q) }
  if (d32.a != 1) { return 8; }
  if (d32.b != 2) { return 9; }
  if (d32.c != 3) { return 10; }
  if (d32.d != 4) { return 11; }

  let d32c: Quad = { a: 9, b: 9, c: 9, d: 9 };
  let p32c: *Quad = &d32c;
  unsafe { *p32c = q }
  if (d32c.a != 1) { return 12; }
  if (d32c.b != 2) { return 13; }
  if (d32c.c != 3) { return 14; }
  if (d32c.d != 4) { return 15; }

  let d32n: Quad = { a: 9, b: 9, c: 9, d: 9 };
  let p32n: *Quad = &d32n;
  unsafe { *p32n = id32(id32(q)) }
  if (d32n.a != 1) { return 16; }
  if (d32n.b != 2) { return 17; }
  if (d32n.c != 3) { return 18; }
  if (d32n.d != 4) { return 19; }

  let dlit: Quad = { a: 9, b: 9, c: 9, d: 9 };
  let plit: *Quad = &dlit;
  unsafe { *plit = { a: 1, b: 2, c: 3, d: 4 } }
  if (dlit.a != 1) { return 20; }
  if (dlit.b != 2) { return 21; }
  if (dlit.c != 3) { return 22; }
  if (dlit.d != 4) { return 23; }

  return 0;
}
