/**
 * See implementation.
 */
const builtin = import("core.builtin");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (builtin.bswap_u32(16777216 as u32) != 1 as u32) { return 1; }
  if (builtin.rotl_u32(1 as u32, 1 as u32) != 2 as u32) { return 2; }
  if (builtin.rotr_u32(2 as u32, 1 as u32) != 1 as u32) { return 3; }
  return 0;
}
