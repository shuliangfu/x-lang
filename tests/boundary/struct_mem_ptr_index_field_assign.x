// Isolated: TYPE_NAMED FIELD dest whose root is a pointer or INDEX
// (`p.s = q` / `id32` / `id16`; `arr[0].s = …`; Prefixed via *T;
// mid-chain `w.p.s`). VAR-root mag must not fire on *T (would write
// into the pointer slot → Darwin 139). Dest = lvalue then
// glue_emit_struct_type_let_init DEST_IN_RBX=-3.
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

allow(padding) struct Prefixed {
  tag: i32
  s: Quad
}

allow(padding) struct WrapPtr {
  p: *Holder32
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
 * Pointer dest 16B CALL.
 * @param p *Holder16 — dest holder
 * @param x Pair — payload
 * @return i32 — 0 ok; 1..2 fail
 */
function via16(p: *Holder16, x: Pair): i32 {
  p.s = id16(x);
  if (p.s.a != 1) { return 1; }
  if (p.s.b != 2) { return 2; }
  return 0;
}

/**
 * Pointer dest 32B copy.
 * @param p *Holder32 — dest holder
 * @param q Quad — payload
 * @return i32 — 0 ok; 3..6 fail
 */
function via_copy(p: *Holder32, q: Quad): i32 {
  p.s = q;
  if (p.s.a != 1) { return 3; }
  if (p.s.b != 2) { return 4; }
  if (p.s.c != 3) { return 5; }
  if (p.s.d != 4) { return 6; }
  return 0;
}

/**
 * Pointer dest 32B CALL sret.
 * @param p *Holder32 — dest holder
 * @param q Quad — payload
 * @return i32 — 0 ok; 7..10 fail
 */
function via_call(p: *Holder32, q: Quad): i32 {
  p.s = id32(q);
  if (p.s.a != 1) { return 7; }
  if (p.s.b != 2) { return 8; }
  if (p.s.c != 3) { return 9; }
  if (p.s.d != 4) { return 10; }
  return 0;
}

/**
 * Pointer dest Prefixed field_off!=0 copy.
 * @param p *Prefixed — dest
 * @param q Quad — payload
 * @return i32 — 0 ok; 11..15 fail
 */
function via_pref(p: *Prefixed, q: Quad): i32 {
  p.s = q;
  if (p.tag != 7) { return 11; }
  if (p.s.a != 1) { return 12; }
  if (p.s.b != 2) { return 13; }
  if (p.s.c != 3) { return 14; }
  if (p.s.d != 4) { return 15; }
  return 0;
}

/**
 * Mid-chain *T FIELD dest (`w.p.s = q`).
 * @param w *WrapPtr — wrap holding a pointer
 * @param q Quad — payload
 * @return i32 — 0 ok; 16..19 fail
 */
function via_mid(w: *WrapPtr, q: Quad): i32 {
  w.p.s = q;
  if (w.p.s.a != 1) { return 16; }
  if (w.p.s.b != 2) { return 17; }
  if (w.p.s.c != 3) { return 18; }
  if (w.p.s.d != 4) { return 19; }
  return 0;
}

/**
 * Exit 0 when pointer / INDEX FIELD dest writes every half.
 * @return i32 — 0 ok; see via_* / INDEX codes
 */
function main(): i32 {
  let x: Pair = Pair { a: 1, b: 2 };
  let q: Quad = Quad { a: 1, b: 2, c: 3, d: 4 };
  let h16: Holder16 = Holder16 { s: Pair { a: 0, b: 0 } };
  let rc: i32 = via16(&h16, x);
  if (rc != 0) { return rc; }
  let h32: Holder32 = Holder32 { s: Quad { a: 0, b: 0, c: 0, d: 0 } };
  rc = via_copy(&h32, q);
  if (rc != 0) { return rc; }
  let h32c: Holder32 = Holder32 { s: Quad { a: 0, b: 0, c: 0, d: 0 } };
  rc = via_call(&h32c, q);
  if (rc != 0) { return rc; }
  let hp: Prefixed = Prefixed { tag: 7, s: Quad { a: 0, b: 0, c: 0, d: 0 } };
  rc = via_pref(&hp, q);
  if (rc != 0) { return rc; }
  let hmid: Holder32 = Holder32 { s: Quad { a: 0, b: 0, c: 0, d: 0 } };
  let w: WrapPtr = WrapPtr { p: &hmid };
  rc = via_mid(&w, q);
  if (rc != 0) { return rc; }
  let arr16: [2]Holder16 = [
    Holder16 { s: Pair { a: 0, b: 0 } },
    Holder16 { s: Pair { a: 9, b: 9 } }
  ];
  arr16[0].s = id16(x);
  if (arr16[0].s.a != 1) { return 20; }
  if (arr16[0].s.b != 2) { return 21; }
  if (arr16[1].s.a != 9) { return 22; }
  let arr32: [2]Holder32 = [
    Holder32 { s: Quad { a: 0, b: 0, c: 0, d: 0 } },
    Holder32 { s: Quad { a: 9, b: 9, c: 9, d: 9 } }
  ];
  arr32[0].s = q;
  if (arr32[0].s.a != 1) { return 23; }
  if (arr32[0].s.b != 2) { return 24; }
  if (arr32[0].s.c != 3) { return 25; }
  if (arr32[0].s.d != 4) { return 26; }
  if (arr32[1].s.a != 9) { return 27; }
  let arr32c: [2]Holder32 = [
    Holder32 { s: Quad { a: 0, b: 0, c: 0, d: 0 } },
    Holder32 { s: Quad { a: 9, b: 9, c: 9, d: 9 } }
  ];
  arr32c[0].s = id32(q);
  if (arr32c[0].s.a != 1) { return 28; }
  if (arr32c[0].s.b != 2) { return 29; }
  if (arr32c[0].s.c != 3) { return 30; }
  if (arr32c[0].s.d != 4) { return 31; }
  if (arr32c[1].s.a != 9) { return 32; }
  return 0;
}
