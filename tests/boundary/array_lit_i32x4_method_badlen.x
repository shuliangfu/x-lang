// Isolated compile-fail: ARRAY_LIT METHOD receiver / extra with SIMD
// formal must T001 when n_elems != lanes (≡ CALL take_vec([1,2,3])).
// typeck: typeck_check_expr_method_call UFCS honors coerce 0 then
// driver_diagnostic_typeck_call_arg_type_mismatch.
// Expected: compile != 0 (T001). Do not -o / run.
// PLATFORM: SHARED — Ubuntu gold.

/**
 * Extract lane 0 of an i32x4 METHOD receiver.
 * @param self i32x4 — vector value (UFCS self)
 * @return i32 — lane 0
 */
function take0(self: i32x4): i32 {
  return self[0];
}

/**
 * Add two i32x4 values (METHOD self + extra SIMD arg).
 * @param self i32x4 — left lanes
 * @param other i32x4 — right lanes
 * @return i32x4 — self + other
 */
function add4(self: i32x4, other: i32x4): i32x4 {
  return self + other;
}

/**
 * Must not typeck: 3-lane receiver vs i32x4 self.
 * @return i32 — unused (compile must fail)
 */
function main(): i32 {
  return [1, 2, 3].take0();
}
