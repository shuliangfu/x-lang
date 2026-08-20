// Isolated: dest-SLICE / INDEX of a mutable module TYPE_ARRAY (COMMON).
// hoist leaves mutable TYPE_ARRAY in SHN_COMMON; prepare emits zero BSS;
// seed_nonzero writes ARRAY_LIT LIT elems (incl. one nested row level).
// dest-SLICE VAR wrap LEAs that COMMON. Function-scope dest-SLICE of a
// module VAR on host-C (`s = A`) is a different leftover (try_emit).
// Expected: host-C and asm compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold dest-SLICE COMMON LEA + ARRAY_LIT seed.

let A: [2]i32 = [10, 32];
let Rows: [2][2]i32 = [[1, 2], [10, 32]];
let m: []i32 = A;

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
 * LEAs the seeded COMMON home (module dest-SLICE let + INDEX).
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  if (m.length != 2) { return 4; }
  if (m[0] != 10) { return 5; }
  if (m[1] != 32) { return 6; }
  if (A[1] != 32) { return 7; }
  let r: []i32 = Rows[1];
  if (r.length != 2) { return 8; }
  if (r[0] != 10) { return 9; }
  if (r[1] != 32) { return 10; }
  if (idx_mut() != 42) { return idx_mut(); }
  return 42;
}
