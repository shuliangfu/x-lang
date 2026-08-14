// Isolated: [N]T INDEX / identity ascription as []T call-arg (4.2.10 leftover).
// Score already accepts array→slice without stamping. Emit must wrap
// take(a[i]) / take(a as [2]i32) as a fat — bare E* is not slice*.
// Neighborhood: take(local [2]i32) / take([lit]) already green.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold typeck+emit.

/**
 * Accept a []i32 fat and return the sum, or 1 when length is not 2.
 * @param s []i32 — coerced from [2]i32 INDEX / VAR / ascription
 * @return i32 — s[0]+s[1] when length==2, else 1
 */
function take(s: []i32): i32 {
  if (s.length != 2) { return 1; }
  return s[0] + s[1];
}

/**
 * Exit 42 when INDEX / ascription [N]T → []T call-arg wraps a live fat.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  let a: [2][2]i32 = [[1, 2], [3, 4]];
  /* a[1] proves scale uses sizeof([2]i32)=8, not a stamped 16B fat. */
  if (take(a[0]) != 3) { return 10; }
  if (take(a[1]) != 7) { return 11; }
  let b: [2]i32 = [10, 32];
  if (take(b) != 42) { return 12; }
  if (take(b as [2]i32) != 42) { return 13; }
  if (take([10, 32]) != 42) { return 14; }
  return 42;
}
