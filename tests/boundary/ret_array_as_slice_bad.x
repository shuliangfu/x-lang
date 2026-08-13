// Isolated red: [2]bool must not return as []i32 (elem mismatch).
// Expected: compile T001.
// PLATFORM: SHARED — Ubuntu gold typeck.

/**
 * Illegal: bool[2] is not []i32.
 * @return []i32 — must not typeck
 */
function f(): []i32 {
  let a: [2]bool = [true, false];
  return a;
}

/**
 * Unreachable if typeck rejects f.
 * @return i32 — 0
 */
function main(): i32 {
  return 0;
}
