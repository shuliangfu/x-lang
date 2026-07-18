// See implementation.
const result = import("core.result");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let r: Result_i32 = result.ok_i32(21);
  let v: i32 = result.expect_i32(r, 0);
  if (v != 21) { return 1; }
  return 0;
}
