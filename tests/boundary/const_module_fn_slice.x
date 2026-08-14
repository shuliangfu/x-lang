// Isolated: function-scope dest-SLICE of a module TYPE_ARRAY VAR.
// try_emit only scans block lets/consts (slot cap forbids a module walk
// there). File-scope dest-SLICE already wrapped via a caller fallback;
// a helper `let s:[]i32 = A` used to emit `s = A` (host-cc BLD001).
// Do not reopen try_emit. Function-scope `const s:[]T = A` is a different
// layer (typeck T001 const-expr / module VAR) — not this emit knife.
// Expected: compile = 0, run = 42 (three backends).
// PLATFORM: SHARED — Ubuntu gold host-C function-scope module VAR wrap.

const A: [2]i32 = [10, 32];
let B: [2]i32 = [10, 32];

/**
 * dest-SLICE let of a module const TYPE_ARRAY.
 * @return i32 — 42 ok, else the failing case
 */
function wrap_const(): i32 {
  let s: []i32 = A;
  if (s.length != 2) { return 1; }
  if (s[0] != 10) { return 2; }
  if (s[1] != 32) { return 3; }
  return 42;
}

/**
 * dest-SLICE let of a module mutable TYPE_ARRAY.
 * @return i32 — 42 ok, else the failing case
 */
function wrap_mut(): i32 {
  let s: []i32 = B;
  if (s.length != 2) { return 11; }
  if (s[0] != 10) { return 12; }
  if (s[1] != 32) { return 13; }
  return 42;
}

/**
 * dest-SLICE ARRAY_LIT row of a module TYPE_ARRAY (`[][]T = [A]`).
 * @return i32 — 42 ok, else the failing case
 */
function wrap_row(): i32 {
  let x: [][]i32 = [A];
  if (x.length != 1) { return 31; }
  if (x[0].length != 2) { return 32; }
  if (x[0][0] != 10) { return 33; }
  if (x[0][1] != 32) { return 34; }
  return 42;
}

/**
 * Main: all function-scope dest-SLICE-of-module-VAR wraps must be 42.
 * @return i32 — 42 ok, else the first failing helper code
 */
function main(): i32 {
  let rc: i32 = wrap_const();
  if (rc != 42) { return rc; }
  rc = wrap_mut();
  if (rc != 42) { return rc; }
  rc = wrap_row();
  if (rc != 42) { return rc; }
  return 42;
}
