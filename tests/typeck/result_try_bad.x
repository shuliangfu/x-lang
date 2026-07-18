// See implementation.

const result = import("core.result");

/** Internal function `may_fail`.
 * Implements `may_fail`.
 * @return Result_i32
 */
function may_fail(): Result_i32 {
  return result.err_i32(1);
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let v: i32 = may_fail()?;
  return v;
}
