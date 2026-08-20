// Isolated red: module-level let type mismatch must T001.
// `let x: i32 = [1, 2]` used to compile (typeck skipped module lets).
// Expected: compile T001.
// PLATFORM: SHARED — Ubuntu gold typeck.

let x: i32 = [1, 2];

/**
 * Unreachable if typeck rejects the module let.
 * @return i32 — 0
 */
function main(): i32 {
  return 0;
}
