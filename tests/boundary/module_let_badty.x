// Isolated red: module-level let type mismatch must T001.
// LANG-006 C5 owns `let N: i32 = [1,2,…]` → length fold (not a mismatch).
// This case uses f64 init vs i32 decl — must stay hard T001.
// Expected: compile T001.
// PLATFORM: SHARED — Ubuntu gold typeck.

let x: i32 = 1.5;

/**
 * Unreachable if typeck rejects the module let.
 * @return i32 — 0
 */
function main(): i32 {
  return 0;
}
