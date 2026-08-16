// Isolated: TYPE_NAMED INDEX dest (`arr[0] = id16(x)` / `xs[0] = id16(x)`).
// Bulk CALL used let_ty_ref=0 so store_retval_pair wrote rax only
// (Darwin arr[0].b leftover 0). Dest = INDEX eff_addr then
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
 * Slice dest 16B CALL.
 * @param xs []Pair — dest slice
 * @param x Pair — payload
 * @return i32 — 0 ok; 1..2 fail
 */
function via_slc16(xs: []Pair, x: Pair): i32 {
  xs[0] = id16(x);
  if (xs[0].a != 1) { return 1; }
  if (xs[0].b != 2) { return 2; }
  return 0;
}

/**
 * Exit 0 when INDEX dest writes every half.
 * @return i32 — 0 ok; 1..14 fail
 */
function main(): i32 {
  let x: Pair = { a: 1, b: 2 };
  let q: Quad = { a: 1, b: 2, c: 3, d: 4 };
  let arr16: [2]Pair = [ { a: 0, b: 0 }, { a: 9, b: 9 } ];
  arr16[0] = id16(x);
  if (arr16[0].a != 1) { return 3; }
  if (arr16[0].b != 2) { return 4; }
  if (arr16[1].a != 9) { return 5; }
  let arr16c: [2]Pair = [ { a: 0, b: 0 }, { a: 9, b: 9 } ];
  arr16c[0] = x;
  if (arr16c[0].a != 1) { return 6; }
  if (arr16c[0].b != 2) { return 7; }
  if (arr16c[1].a != 9) { return 8; }
  let slc: [2]Pair = [ { a: 0, b: 0 }, { a: 9, b: 9 } ];
  let rc: i32 = via_slc16(slc, x);
  if (rc != 0) { return rc; }
  if (slc[1].a != 9) { return 9; }
  let arr32: [2]Quad = [
    { a: 0, b: 0, c: 0, d: 0 },
    { a: 9, b: 9, c: 9, d: 9 }
  ];
  arr32[0] = id32(q);
  if (arr32[0].a != 1) { return 10; }
  if (arr32[0].b != 2) { return 11; }
  if (arr32[0].c != 3) { return 12; }
  if (arr32[0].d != 4) { return 13; }
  if (arr32[1].a != 9) { return 14; }
  return 0;
}
