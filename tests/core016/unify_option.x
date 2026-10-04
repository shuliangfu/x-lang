/**
 * See implementation.
 */
const option = import("core.option");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* some_i32 writes through an out pointer. */
  let g: Option<i32> = { is_some: false, value: 0 };
  option.some_i32(&g, 42);
  let f: Option_i32 = { is_some: false, value: 0 };
  option.some_i32(&f, 7);
  let mix: Option_i32 = g;
  if (!option.is_some_i32(mix) || option.unwrap_or_i32(mix, 0) != 42) { return 1; }
  if (!option.is_some_i32(f) || option.unwrap_or_i32(f, 0) != 7) { return 2; }
  return 0;
}
