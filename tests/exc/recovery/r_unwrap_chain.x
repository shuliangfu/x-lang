// See implementation.
const result = import("core.result");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let inner: Result_i32 = result.err_i32(1);
  let outer: i32 = result.unwrap_or_i32(inner, result.unwrap_or_i32(result.err_i32(2), 55));
  if (outer != 55) { return 1; }
  return 0;
}
