// Isolated: DEREF rvalue into VAR dest (`y = *p` / `let z = *p`).
// Prior emit_deref loaded only 8B (elem_sz) so 16B leftover .b /
// SLICE length leftover / >16B only first qword.
// Authority = INDEX rvalue twin: deref_struct16 for 9–16B / SLICE;
// >16B leaves the pointer then let-init memcpy.
// Deref read is unsafe.
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
 * Exit 0 when DEREF rvalue copies every half.
 * @return i32 — 0 ok; 1..12 fail
 */
function main(): i32 {
  let x: Pair = Pair { a: 1, b: 2 };
  let p: *Pair = &x;
  let y: Pair = Pair { a: 9, b: 9 };
  unsafe { y = *p }
  if (y.a != 1) { return 1; }
  if (y.b != 2) { return 2; }

  unsafe {
    let z: Pair = *p;
    if (z.a != 1) { return 3; }
    if (z.b != 2) { return 4; }
  }

  let q: Quad = Quad { a: 1, b: 2, c: 3, d: 4 };
  let pq: *Quad = &q;
  let yq: Quad = Quad { a: 9, b: 9, c: 9, d: 9 };
  unsafe { yq = *pq }
  if (yq.a != 1) { return 5; }
  if (yq.b != 2) { return 6; }
  if (yq.c != 3) { return 7; }
  if (yq.d != 4) { return 8; }

  let a: [2]i32 = [10, 20];
  let s0: []i32 = a;
  let ps: *[]i32 = &s0;
  let s: []i32 = [0];
  unsafe { s = *ps }
  if (s.length != 2) { return 9; }
  if (s[0] != 10) { return 10; }
  if (s[1] != 20) { return 11; }

  return 0;
}
