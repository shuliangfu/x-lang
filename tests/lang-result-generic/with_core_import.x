/**
 * See implementation.
 */
const result = import("core.result");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let g: Result<i32, i32> = result.ok_i32(42);
  let f: Result_i32 = result.ok_i32(7);
  if (g.err != 0 || g.value != 42) { return 1; }
  if (!result.is_ok_i32(f) || result.unwrap_or_i32(f, 0) != 7) { return 2; }
  return 0;
}
