// See implementation.
const result = import("core.result");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let r: Result_i32 = result.ok_i32(17);
  if (result.unwrap_or_i32(r, 0) != 17) { return 1; }
  if (result.expect_i32(r, 0) != 17) { return 2; }
  return 0;
}
