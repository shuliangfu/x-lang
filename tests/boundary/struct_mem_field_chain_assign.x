// Isolated: TYPE_NAMED FIELD dest whose base is itself a FIELD
// (`w.h.s = q` / `id32` / `id16`). Immediate-VAR `h.s` already
// reuses let-init. Nested FIELD used push/pop store_rax only, so
// 16B lost hi (Darwin 2) and >16B CALL SIGBUS (138). Dest = nested
// glue_struct_field_frame_mag_c from the VAR root.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail.

allow(padding) struct Pair {
  a: i64
  b: i64
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

allow(padding) struct Holder32 {
  s: Quad
}

allow(padding) struct Wrap16 {
  h: Holder16
}

allow(padding) struct Wrap32 {
  h: Holder32
}

allow(padding) struct Prefixed {
  tag: i32
  s: Quad
}

allow(padding) struct WrapPref {
  h: Prefixed
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
 * Exit 0 when FIELD-chain dest writes every half.
 * @return i32 — 0 ok; 1..2 = 16B CALL; 3..6 = 32B copy;
 *   7..10 = 32B CALL; 11..15 = Prefixed chain
 */
function main(): i32 {
  let p: Pair = Pair { a: 1, b: 2 };
  let w16: Wrap16 = Wrap16 { h: Holder16 { s: Pair { a: 0, b: 0 } } };
  w16.h.s = id16(p);
  if (w16.h.s.a != 1) { return 1; }
  if (w16.h.s.b != 2) { return 2; }
  let q: Quad = Quad { a: 1, b: 2, c: 3, d: 4 };
  let w32: Wrap32 = Wrap32 { h: Holder32 { s: Quad { a: 0, b: 0, c: 0, d: 0 } } };
  w32.h.s = q;
  if (w32.h.s.a != 1) { return 3; }
  if (w32.h.s.b != 2) { return 4; }
  if (w32.h.s.c != 3) { return 5; }
  if (w32.h.s.d != 4) { return 6; }
  let w32c: Wrap32 = Wrap32 { h: Holder32 { s: Quad { a: 0, b: 0, c: 0, d: 0 } } };
  w32c.h.s = id32(q);
  if (w32c.h.s.a != 1) { return 7; }
  if (w32c.h.s.b != 2) { return 8; }
  if (w32c.h.s.c != 3) { return 9; }
  if (w32c.h.s.d != 4) { return 10; }
  let wp: WrapPref = WrapPref { h: Prefixed { tag: 7, s: Quad { a: 0, b: 0, c: 0, d: 0 } } };
  wp.h.s = q;
  if (wp.h.tag != 7) { return 11; }
  if (wp.h.s.a != 1) { return 12; }
  if (wp.h.s.b != 2) { return 13; }
  if (wp.h.s.c != 3) { return 14; }
  if (wp.h.s.d != 4) { return 15; }
  return 0;
}
