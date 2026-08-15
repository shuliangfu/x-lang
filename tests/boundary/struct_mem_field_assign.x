// Isolated: TYPE_NAMED FIELD dest assign (copy / CALL / STRUCT_LIT).
// VAR-slot assign already reuses struct let-init. FIELD dest used
// store_rax_to_rbx_offset only, so 16B lost hi (Darwin 2) and >16B
// CALL SIGBUS (138). Dest slot = var_off + field_off.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without reuse.

allow(padding) struct Pair {
  a: i64
  b: i64
}

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

allow(padding) struct Holder16 {
  s: Pair
}

allow(padding) struct Holder24 {
  s: Trip
}

allow(padding) struct Holder32 {
  s: Quad
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
 * Identity 32B (AAPCS64 / SysV MEMORY sret).
 * @param p Quad — stack / sret payload
 * @return Quad — same quad
 */
function id32(p: Quad): Quad {
  return p;
}

/**
 * Exit 0 when FIELD dest writes every half of 16B / 24B / 32B.
 * @return i32 — 0 ok; 1..2 = 16B copy; 3..4 = 16B CALL;
 *   5..7 = 24B copy; 8..11 = 32B copy; 12..15 = 32B CALL;
 *   16..19 = STRUCT_LIT
 * field_off!=0 (x86 stored -8) is a later leaf.
 */
function main(): i32 {
  let p: Pair = Pair { a: 1, b: 2 };
  let h16: Holder16 = Holder16 { s: Pair { a: 0, b: 0 } };
  h16.s = p;
  if (h16.s.a != 1) { return 1; }
  if (h16.s.b != 2) { return 2; }
  let h16c: Holder16 = Holder16 { s: Pair { a: 0, b: 0 } };
  h16c.s = id16(p);
  if (h16c.s.a != 1) { return 3; }
  if (h16c.s.b != 2) { return 4; }
  let t: Trip = Trip { a: 1, b: 2, c: 3 };
  let h24: Holder24 = Holder24 { s: Trip { a: 0, b: 0, c: 0 } };
  h24.s = t;
  if (h24.s.a != 1) { return 5; }
  if (h24.s.b != 2) { return 6; }
  if (h24.s.c != 3) { return 7; }
  let q: Quad = Quad { a: 1, b: 2, c: 3, d: 4 };
  let h32: Holder32 = Holder32 { s: Quad { a: 0, b: 0, c: 0, d: 0 } };
  h32.s = q;
  if (h32.s.a != 1) { return 8; }
  if (h32.s.b != 2) { return 9; }
  if (h32.s.c != 3) { return 10; }
  if (h32.s.d != 4) { return 11; }
  let h32c: Holder32 = Holder32 { s: Quad { a: 0, b: 0, c: 0, d: 0 } };
  h32c.s = id32(q);
  if (h32c.s.a != 1) { return 12; }
  if (h32c.s.b != 2) { return 13; }
  if (h32c.s.c != 3) { return 14; }
  if (h32c.s.d != 4) { return 15; }
  let hlit: Holder32 = Holder32 { s: Quad { a: 0, b: 0, c: 0, d: 0 } };
  hlit.s = Quad { a: 1, b: 2, c: 3, d: 4 };
  if (hlit.s.a != 1) { return 16; }
  if (hlit.s.b != 2) { return 17; }
  if (hlit.s.c != 3) { return 18; }
  if (hlit.s.d != 4) { return 19; }
  return 0;
}
