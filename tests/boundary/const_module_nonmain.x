// Isolated leftover probe: non-main read of module const TYPE_ARRAY.
// hoist puts const TYPE_ARRAY into main only; prepare skips is_const so
// there is no COMMON home. Different produce from dest-SLICE COMMON LEA.
// Expected after that later leaf: compile = 0, run = 42.
// PLATFORM: SHARED — diagnostic; not this dest-SLICE COMMON knife.

const A: [2]i32 = [10, 32];
const B: [2][2]i32 = [[1, 2], [10, 32]];

/**
 * Read module const TYPE_ARRAY from a helper (not main).
 * @return i32 — 42 ok, else the failing case
 */
function read_const(): i32 {
  if (A[0] != 10) { return 1; }
  if (A[1] != 32) { return 2; }
  let s: []i32 = A;
  if (s.length != 2) { return 3; }
  if (s[1] != 32) { return 4; }
  let r: []i32 = B[1];
  if (r.length != 2) { return 5; }
  if (r[1] != 32) { return 6; }
  return 42;
}

/**
 * @return i32 — 42 ok, else helper failure
 */
function main(): i32 {
  return read_const();
}
