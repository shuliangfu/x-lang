// Isolated: DEREF dest of SLICE / ARRAY / VECTOR (`*p = …`).
// Prior assign stored rax only through [rbx] (Darwin SLICE length leftover /
// ARRAY first-elem leftover / VECTOR 16B CALL SIGBUS). Dest = DEREF lvalue
// then dest-in-rbx let-init (SLICE/VECTOR) or E* glue_copy (ARRAY CALL).
// Deref write is unsafe (bare `*p =` drops the function at parse).
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail.

/**
 * Identity slice (dual-GP fat return).
 * @param xs []i32 — stack fat
 * @return []i32 — same slice
 */
function take(xs: []i32): []i32 {
  return xs;
}

/**
 * Identity [2]i32 (callee returns E*).
 * @return [2]i32 — {10, 20}
 */
function mk2(): [2]i32 {
  return [10, 20];
}

/**
 * Exit 0 when DEREF dest writes every half / lane / elem.
 * VECTOR CALL dest (`*p = add4(a,b)`) is a later leaf: callee
 * `return a+b` is still lane0-only when not inlined.
 * @return i32 — 0 ok; 1..18 fail
 */
function main(): i32 {
  let a: [2]i32 = [10, 20];
  let s: []i32 = a;
  let d: []i32 = [0];
  let p: *[]i32 = &d;
  unsafe { *p = s }
  if (d.length != 2) { return 1; }
  if (d[0] != 10) { return 2; }
  if (d[1] != 20) { return 3; }

  let d2: []i32 = [0];
  let p2: *[]i32 = &d2;
  unsafe { *p2 = take(a) }
  if (d2.length != 2) { return 4; }
  if (d2[0] != 10) { return 5; }
  if (d2[1] != 20) { return 6; }

  let src2: [2]i32 = [10, 20];
  let arr2: [2]i32 = [0, 0];
  let pa2: *[2]i32 = &arr2;
  unsafe { *pa2 = src2 }
  if (arr2[0] != 10) { return 7; }
  if (arr2[1] != 20) { return 8; }

  let arr2c: [2]i32 = [0, 0];
  let pa2c: *[2]i32 = &arr2c;
  unsafe { *pa2c = mk2() }
  if (arr2c[0] != 10) { return 9; }
  if (arr2c[1] != 20) { return 10; }

  let src4: [4]i32 = [1, 2, 3, 4];
  let arr4: [4]i32 = [0, 0, 0, 0];
  let pa4: *[4]i32 = &arr4;
  unsafe { *pa4 = src4 }
  if (arr4[0] != 1) { return 11; }
  if (arr4[1] != 2) { return 12; }
  if (arr4[2] != 3) { return 13; }
  if (arr4[3] != 4) { return 14; }

  let va: i32x4 = [1, 2, 3, 4];
  let vd: i32x4 = [0, 0, 0, 0];
  let pv: *i32x4 = &vd;
  unsafe { *pv = va }
  if (vd[0] != 1) { return 15; }
  if (vd[1] != 2) { return 16; }
  if (vd[2] != 3) { return 17; }
  if (vd[3] != 4) { return 18; }

  return 0;
}
