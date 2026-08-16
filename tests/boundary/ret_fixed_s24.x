// Isolated green: return already-typed S24[2] (fixed TYPE_ARRAY of 24B NAMED).
// 4.2.17 leftover after wave632 ARRAY_LIT durable / wave633 let-from-CALL:
// `return s` / `return w.xs` lea'd the stack local (E* dangles → SEGV).
// Path B0 durables COMMON then returns E*; keep esz=24 (do not clamp to 4).
// Success = 110 = 5+6+50+49.
// PLATFORM: SHARED — Ubuntu gold typeck+emit.

struct S24 {
  a: i32
  b: i32
  c: i64
  d: i64
}

struct W {
  xs: [2]S24
}

/**
 * ARRAY_LIT return of S24[2] (wave632 durable E*).
 * @return S24[2] — [ {5,6,7,8}, {50,49,1,2} ]
 */
function lit(): S24[2] {
  return [
    { a: 5, b: 6, c: 7, d: 8 },
    { a: 50, b: 49, c: 1, d: 2 }
  ];
}

/**
 * Return a local S24[2] VAR (4.2.17 Path B0 dest TYPE_ARRAY).
 * @return S24[2] — durable copy of lit()
 */
function from_var(): S24[2] {
  let s: S24[2] = lit();
  return s;
}

/**
 * Return CALL of S24[2] (callee already returns E*).
 * @return S24[2] — lit()
 */
function from_call(): S24[2] {
  return lit();
}

/**
 * Return a named struct field S24[2] (4.2.17 Path B0 FIELD).
 * @return S24[2] — durable copy of w.xs
 */
function from_field(): S24[2] {
  let w: W = {
    xs: [
      { a: 5, b: 6, c: 7, d: 8 },
      { a: 50, b: 49, c: 1, d: 2 }
    ]
  };
  return w.xs;
}

/**
 * Same-layer neighborhood: [N]S24 → []S24 (Path B0 dest SLICE, esz>8).
 * @return []S24 — fat over a durable copy of lit()
 */
function from_var_slice(): []{
  let s: S24[2] = lit();
  return s;
}

/**
 * Sum the four i32 face fields used as the 110 oracle.
 * @param s S24[2] — E* formal
 * @return i32 — s[0].a + s[0].b + s[1].a + s[1].b
 */
function sum2(s: S24[2]): i32 {
  return s[0].a + s[0].b + s[1].a + s[1].b;
}

/**
 * Exit 110 when return S24[2] durables live payload on all four paths.
 * @return i32 — 110 ok; 10+sum / 21..52 name the miss
 */
function main(): i32 {
  let a: S24[2] = lit();
  if (sum2(a) != 110) { return 10 + sum2(a); }
  if (a[0].c != 7) { return 21; }
  if (a[1].d != 2) { return 22; }
  let b: S24[2] = from_var();
  if (sum2(b) != 110) { return 30 + sum2(b); }
  if (b[0].c != 7) { return 31; }
  if (b[1].d != 2) { return 32; }
  let c: S24[2] = from_call();
  if (sum2(c) != 110) { return 40 + sum2(c); }
  if (c[0].c != 7) { return 41; }
  if (c[1].d != 2) { return 42; }
  let d: S24[2] = from_field();
  if (sum2(d) != 110) { return 50 + sum2(d); }
  if (d[0].c != 7) { return 51; }
  if (d[1].d != 2) { return 52; }
  let e: []S24 = from_var_slice();
  if (e.length != 2) { return 61; }
  if (e[0].a != 5) { return 62; }
  if (e[0].b != 6) { return 63; }
  if (e[0].c != 7) { return 64; }
  if (e[1].a != 50) { return 65; }
  if (e[1].b != 49) { return 66; }
  if (e[1].d != 2) { return 67; }
  return 110;
}
