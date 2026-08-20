// Isolated red: module-level const type mismatch must T001.
// `const x: i32 = [1, 2]` used to compile (typeck skipped module lets).
// Expected: compile T001.
// PLATFORM: SHARED — Ubuntu gold typeck.

const x: i32 = [1, 2];

/**
 * Unreachable if typeck rejects the module const.
 * @return i32 — 0
 */
function main(): i32 {
  return 0;
}
