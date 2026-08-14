// Isolated: dest-SLICE return / assign of INDEX of [K][N]T.
// Path B0 previously only VAR/FIELD; INDEX left rax=E* without packing
// length (run=1 / SEGV). Host-C wrap was already a durable fat, but
// emit_type peeled `[2][2]i32` params to `int32_t **` so `(a)[0]`
// read the first row as a pointer (memcpy SEGV).
// Neighborhood: TYPE_ARRAY `return a[0]` and dest-SLICE `return a` already green.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold typeck+emit.

/**
 * Return one row of a [2][2]i32 param as []i32 (dest-SLICE INDEX).
 * @param a [2][2]i32 — caller-owned rows
 * @return []i32 — fat over a durable copy of a[0]
 */
function row0_slc(a: [2][2]i32): []i32 {
  return a[0];
}

/**
 * Return the second row of a local [2][2]i32 as []i32.
 * @return []i32 — fat over a durable copy of a[1]
 */
function local_slc(): []i32 {
  let a: [2][2]i32 = [[1, 2], [10, 32]];
  return a[1];
}

/**
 * Return one row as [2]i32 (TYPE_ARRAY E* neighborhood).
 * @param a [2][2]i32 — caller-owned rows
 * @return [2]i32 — durable E* of a[1]
 */
function row1_arr(a: [2][2]i32): [2]i32 {
  return a[1];
}

/**
 * Return a [2]i32 param as []i32 (VAR dest-SLICE neighborhood).
 * @param a [2]i32 — caller-owned row
 * @return []i32 — fat over a durable copy of a
 */
function as_slc(a: [2]i32): []i32 {
  return a;
}

/**
 * Exit 42 when dest-SLICE return/assign of INDEX wraps a live fat.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  let a: [2][2]i32 = [[1, 2], [10, 32]];
  let s: []i32 = row0_slc(a);
  if (s.length != 2) { return 1; }
  if (s[0] != 1) { return 2; }
  if (s[1] != 2) { return 3; }
  let t: []i32 = local_slc();
  if (t.length != 2) { return 4; }
  if (t[0] != 10) { return 5; }
  if (t[1] != 32) { return 6; }
  let r: [2]i32 = row1_arr(a);
  if (r[0] != 10) { return 7; }
  if (r[1] != 32) { return 8; }
  let u: []i32 = [0, 0];
  u = a[1];
  if (u.length != 2) { return 9; }
  if (u[0] != 10) { return 10; }
  if (u[1] != 32) { return 11; }
  let b: [2]i32 = [10, 32];
  let v: []i32 = as_slc(b);
  if (v.length != 2) { return 12; }
  if (v[0] != 10) { return 13; }
  return 42;
}
