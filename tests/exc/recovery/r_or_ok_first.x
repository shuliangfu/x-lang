// See implementation.
const result = import("core.result");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: Result_i32 = result.or_i32(result.ok_i32(5), result.ok_i32(9));
  if (result.expect_i32_or_panic(a) != 5) { return 1; }
  return 0;
}
