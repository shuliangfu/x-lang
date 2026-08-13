// Isolated green: []i64 ARRAY_LIT call-arg (4.2.11 verify-closed).
// wave622 stamped formal force_esz so take([10,32]) idx1=32 sum=42
// (pre-fix s[1]=0 sum=10). Neighborhood i32 / u8 / f64 same pack.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold freestanding + host-C.

/**
 * Read []i64 call-arg lanes (idx1 + sum).
 * @param s []i64 — two-element slice from ARRAY_LIT
 * @return i32 — 42 ok, else the failing check
 */
function take_i64(s: []i64): i32 {
  if (s.length != 2) { return 1; }
  if (s[1] != 32) { return 10; }
  if ((s[0] + s[1]) != 42) { return 11; }
  return 42;
}

/**
 * Read []i32 call-arg lanes (idx1 + sum).
 * @param s []i32 — two-element slice from ARRAY_LIT
 * @return i32 — 42 ok, else the failing check
 */
function take_i32(s: []i32): i32 {
  if (s.length != 2) { return 1; }
  if (s[1] != 32) { return 10; }
  if ((s[0] + s[1]) != 42) { return 11; }
  return 42;
}

/**
 * Read []u8 call-arg lanes (idx1 + sum).
 * @param s []u8 — two-element slice from ARRAY_LIT
 * @return i32 — 42 ok, else the failing check
 */
function take_u8(s: []u8): i32 {
  if (s.length != 2) { return 1; }
  if ((s[1] as i32) != 32) { return 10; }
  if (((s[0] as i32) + (s[1] as i32)) != 42) { return 11; }
  return 42;
}

/**
 * Read []f64 call-arg lanes (truncated idx1 + sum).
 * @param s []f64 — two-element slice from ARRAY_LIT
 * @return i32 — 42 ok, else the failing check
 */
function take_f64(s: []f64): i32 {
  if (s.length != 2) { return 1; }
  if ((s[1] as i32) != 32) { return 10; }
  if (((s[0] as i32) + (s[1] as i32)) != 42) { return 11; }
  return 42;
}

/**
 * Exit 42 when scalar-slice lit call-arg packs esz correctly.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  if (take_i64([10, 32]) != 42) { return 2; }
  let a: []i64 = [10, 32];
  if (take_i64(a) != 42) { return 3; }
  if (take_i32([10, 32]) != 42) { return 4; }
  if (take_u8([10, 32]) != 42) { return 5; }
  if (take_f64([10.0, 32.0]) != 42) { return 6; }
  return 42;
}
