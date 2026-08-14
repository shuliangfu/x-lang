// Isolated: dest-SLICE wrap of a mutable module TYPE_ARRAY (COMMON).
// hoist leaves mutable TYPE_ARRAY in SHN_COMMON; dest-SLICE VAR must LEA
// that COMMON cell (INDEX already does). Const TYPE_ARRAY is hoisted into
// main only — non-main read of those is a different leftover.
// Expected: host-C and asm compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold dest-SLICE COMMON LEA.

let A: [2]i32 = [10, 32];
let Rows: [2][2]i32 = [[1, 2], [10, 32]];
let m: []i32 = A;

/**
 * dest-SLICE wrap of mutable COMMON A in a non-main helper.
 * @return i32 — 42 ok, else the failing case (20+)
 */
function take_mut(): i32 {
  let s: []i32 = A;
  if (s.length != 2) { return 20; }
  if (s[0] != 10) { return 21; }
  if (s[1] != 32) { return 22; }
  return 42;
}

/**
 * INDEX of mutable COMMON from a non-main helper (neighborhood).
 * @return i32 — 42 ok, else 30+
 */
function idx_mut(): i32 {
  if (A[0] != 10) { return 30; }
  if (A[1] != 32) { return 31; }
  return 42;
}

/**
 * Exit 42 when dest-SLICE wrap / INDEX of mutable module TYPE_ARRAY
 * LEAs the COMMON home (main + helper + module dest-SLICE let).
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  let s: []i32 = A;
  if (s.length != 2) { return 1; }
  if (s[0] != 10) { return 2; }
  if (s[1] != 32) { return 3; }
  if (m.length != 2) { return 4; }
  if (m[0] != 10) { return 5; }
  if (m[1] != 32) { return 6; }
  if (A[1] != 32) { return 7; }
  let r: []i32 = Rows[1];
  if (r.length != 2) { return 8; }
  if (r[0] != 10) { return 9; }
  if (r[1] != 32) { return 10; }
  if (take_mut() != 42) { return take_mut(); }
  if (idx_mut() != 42) { return idx_mut(); }
  return 42;
}
