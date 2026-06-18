/**
 * CORE-013 烟测：core.types i16/u16 size_of_* 与 align_of_* 宽度金样。
 */
const types = import("core.types");
const debug = import("core.debug");

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
