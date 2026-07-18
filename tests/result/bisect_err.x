const result = import("core.result");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let err_r: Result_i32 = result.err_i32(7);
  return result.unwrap_or_i32(err_r, 99);
}
