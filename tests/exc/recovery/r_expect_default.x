// See implementation.
const result = import("core.result");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let r: Result_i32 = result.err_i32(5);
  if (result.expect_i32(r, 88) != 88) { return 1; }
  return 0;
}
