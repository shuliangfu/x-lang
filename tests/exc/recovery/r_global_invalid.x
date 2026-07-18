// See implementation.
const result = import("core.result");
const err = import("std.error");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let r: Result_i32 = result.err_i32(code_invalid());
  let v: i32 = result.unwrap_or_i32(r, 999);
  if (v != 999) { return 1; }
  return 0;
}
