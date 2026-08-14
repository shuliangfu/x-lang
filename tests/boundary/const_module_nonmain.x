// Isolated: non-main INDEX of module const TYPE_ARRAY.
// prepare used to skip is_const (no COMMON); hoist copied the array into
// main only — helper INDEX was CG002 (code_len=12). Same COMMON + seed
// path as mutable TYPE_ARRAY. dest-SLICE wrap of module VAR from a helper
// is a different leftover (host-C try_emit; do not reopen).
// Expected: compile = 0, run = 42 (asm / host-C / xlang-c).
// PLATFORM: SHARED — Ubuntu gold non-main INDEX of const TYPE_ARRAY.

const A: [2]i32 = [10, 32];
const B: [2][2]i32 = [[1, 2], [10, 32]];

/**
 * Read module const TYPE_ARRAY from a helper (not main).
 * @return i32 — 42 ok, else the failing case
 */
function read_const(): i32 {
  if (A[0] != 10) { return 1; }
  if (A[1] != 32) { return 2; }
  if (B[1][0] != 10) { return 3; }
  if (B[1][1] != 32) { return 4; }
  return 42;
}

/**
 * Main also INDEXes the same COMMON const (hoist no longer copies it).
 * @return i32 — 42 ok, else helper or main INDEX failure
 */
function main(): i32 {
  if (A[0] != 10) { return 10; }
  if (B[0][1] != 2) { return 11; }
  return read_const();
}
