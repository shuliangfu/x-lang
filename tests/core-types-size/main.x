// See implementation.
const types = import("core.types");
const debug = import("core.debug");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (types.size_of_i32() != 4) { return 1; }
  if (types.size_of_bool() != 1 || types.size_of_u8() != 1) { return 2; }
  if (types.size_of_i16() != 2 || types.size_of_u16() != 2) { return 21; }
  if (types.size_of_u32() != 4 || types.size_of_u64() != 8 || types.size_of_i64() != 8) { return 3; }
  if (types.size_of_usize() != 8 || types.size_of_isize() != 8) { return 4; }
  if (types.size_of_f32() != 4 || types.size_of_f64() != 8) { return 5; }
  if (types.size_of_pointer() != 8) { return 6; }
  if (types.align_of_i32() != 4 || types.align_of_bool() != 1 || types.align_of_u8() != 1) { return 7; }
  if (types.align_of_i16() != 2 || types.align_of_u16() != 2) { return 22; }
  if (types.align_of_u32() != 4 || types.align_of_u64() != 8 || types.align_of_i64() != 8) { return 8; }
  if (types.align_of_usize() != 8 || types.align_of_isize() != 8) { return 9; }
  if (types.align_of_f32() != 4 || types.align_of_f64() != 8) { return 10; }
  if (types.align_of_pointer() != 8) { return 11; }
  let ok: i32 = debug.assert(types.size_of_i32() == 4);
  return ok;
}
