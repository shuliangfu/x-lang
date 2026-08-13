// Isolated red: [2]bool field must not stamp into []i32 (4.2.10).
// wave672 mismatch stays hard-fail; slice_from_array requires equal elems.
// Expected: typeck T001 argument type mismatch.
// PLATFORM: SHARED — Ubuntu gold typeck.

struct Wb {
  xs: [2]bool
}

/**
 * Formal is []i32 so a [2]bool field must T001.
 * @param s []i32 — unused (call must not typeck)
 * @return i32 — never reached
 */
function take(s: []i32): i32 {
  return 1;
}

/**
 * Must not compile: bool elems ≠ i32 slice elem.
 * @return i32 — never reached
 */
function main(): i32 {
  return take(Wb { xs: [true, false] }.xs);
}
