const result = import("core.result");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return result.expect_i32_or_panic(result.ok_i32(5));
}
