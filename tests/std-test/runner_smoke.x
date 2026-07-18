// See implementation.
const test = import("std.test");

/** Internal function `case_add`.
 * Implements `case_add`.
 * @return i32
 */
function case_add(): i32 {
  if (test.expect_eq_i32(1 + 1, 2) != 0) { return 1; }
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  test.runner_reset();
  let n_ok: u8[7] = [99, 97, 115, 101, 95, 111, 107];
  test.runner_case(&n_ok[0], 7, case_add());
  let n_skip: u8[9] = [99, 97, 115, 101, 95, 115, 107, 105, 112];
  test.runner_skip(&n_skip[0], 9);
  return test.runner_finish();
}
