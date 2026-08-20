// Isolated red: `[true, false] as []i32` must not coerce (elem mismatch).
// Expected: typeck T001 (not P001 no functions).
// PLATFORM: SHARED — Ubuntu gold typeck.

/**
 * Mismatched `[lit] as []i32` must hard-fail at typeck.
 * @return []i32 — unreachable when typeck is correct
 */
function main(): []i32 {
  return [true, false] as []i32;
}
