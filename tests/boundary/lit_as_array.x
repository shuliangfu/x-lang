// Isolated: `[lit] as [N]T` must parse (not P001) and keep the fixed array.
// Same as_suffix type_ref authority as `as []T`.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold parse.

/**
 * Exit 42 when `[10, 32] as [2]i32` parses and indexes.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  let a: [2]i32 = [10, 32] as [2]i32;
  if (a[0] != 10) { return 1; }
  if (a[1] != 32) { return 2; }
  return 42;
}
