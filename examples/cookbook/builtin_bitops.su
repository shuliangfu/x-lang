/**
 * Cookbook BUILT-01：core.builtin 位运算 bswap/rotl/rotr（CORE-018）。
 */
const builtin = import("core.builtin");

function main(): i32 {
  if (builtin.bswap_u32(16777216 as u32) != 1 as u32) { return 1; }
  if (builtin.rotl_u32(1 as u32, 1 as u32) != 2 as u32) { return 2; }
  if (builtin.rotr_u32(2 as u32, 1 as u32) != 1 as u32) { return 3; }
  return 0;
}
