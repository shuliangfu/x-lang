// Isolated compile-fail: import.binding METHOD extra ARRAY_LIT with
// n_elems != SIMD lanes must T001 (≡ CALL take_vec([1,2,3]) /
// same-module [1,2,3].take0()). first_idx same-arity bind is not a pass.
// typeck: typeck_check_call_arg_types after import resolve.
// Expected: compile != 0 (T001). Do not -o / run.
// PLATFORM: SHARED — Ubuntu gold.

const simd = import("std.simd");

/**
 * Must not typeck: 3-lane extra vs Vec4f formal.
 * @return i32 — unused (compile must fail)
 */
function main(): i32 {
  return simd.hsum([1.0, 2.0, 3.0]) as i32;
}
