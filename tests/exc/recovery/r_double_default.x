// See implementation.
const result = import("core.result");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let v: i32 = result.unwrap_or_i32(result.err_i32(1), result.unwrap_or_i32(result.err_i32(2), 33));
  if (v != 33) { return 1; }
  return 0;
}
