// Isolated green: slice-of-fixed-array INDEX (`[][2]i32`).
// Durable ARRAY_LIT must store contiguous [2]i32 rows (not pointers).
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold emit.

/**
 * Index a [2]i32 row passed by E* (call-arg consume of INDEX).
 * @param r [2]i32 — one row from `[][2]i32`
 * @return i32 — r[1]
 * PLATFORM: SHARED
 */
function take_row(r: [2]i32): i32 {
  return r[1];
}

/**
 * Prove `[][2]i32` INDEX + mid-let + take + VAR-row + `[][3]i32`.
 * @return i32 — 42 on success; 1..6 names the failing case
 * PLATFORM: SHARED — Ubuntu gold emit
 */
function main(): i32 {
  let x: [][2]i32 = [[10, 32], [1, 2]];
  if (x[0][1] != 32) {
    return 1;
  }
  if (x[1][0] != 1) {
    return 2;
  }
  let r: [2]i32 = x[0];
  if (r[1] != 32) {
    return 3;
  }
  if (take_row(x[0]) != 32) {
    return 4;
  }
  let a: [2]i32 = [10, 32];
  let y: [][2]i32 = [a];
  if (y[0][1] != 32) {
    return 5;
  }
  let z: [][3]i32 = [[7, 8, 9]];
  if (z[0][2] != 9) {
    return 6;
  }
  return 42;
}
