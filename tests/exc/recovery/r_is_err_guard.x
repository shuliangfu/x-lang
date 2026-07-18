// See implementation.
const result = import("core.result");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let r: Result_i32 = result.err_i32(7);
  let v: i32 = result.is_err_i32(r) ? 66 : r.value;
  if (v != 66) { return 1; }
  return 0;
}
