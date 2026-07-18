/**
 * See implementation.
 */
const types = import("core.types");
const debug = import("core.debug");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (types.size_of_i16() != 2) { return 1; }
  if (types.size_of_u16() != 2) { return 2; }
  if (types.align_of_i16() != 2) { return 3; }
  if (types.align_of_u16() != 2) { return 4; }
  if (types.size_of_i16() != types.size_of_u16()) { return 5; }
  debug.assert_eq_i32(types.size_of_i16(), 2);
  debug.assert_eq_i32(types.align_of_u16(), 2);
  return 0;
}
