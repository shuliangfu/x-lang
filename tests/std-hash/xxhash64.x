// See implementation.
const hash = import("std.hash");

/** Internal function `u64_lo`.
 * Implements `u64_lo`.
 * @param v u64
 * @return u32
 */
function u64_lo(v: u64): u32 {
  return (v & 4294967295) as u32;
}

/** Internal function `u64_hi`.
 * Implements `u64_hi`.
 * @param v u64
 * @return u32
 */
function u64_hi(v: u64): u32 {
  return ((v >> 32) & 4294967295) as u32;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[3] = [97, 98, 99];
  let empty: u64 = hash.xxhash64(0 as *u8, 0);
  let one: u64 = hash.xxhash64(&buf[0], 3);
  let hx: *u8 = hash.start_algo(2);
  let inc: u64 = 0;
  if (u64_lo(empty) != 1373170073 as u32) { return 1; }
  if (u64_hi(empty) != 4014398263 as u32) { return 2; }
  if (u64_lo(one) != 2910259609 as u32) { return 3; }
  if (u64_hi(one) != 1153182965 as u32) { return 4; }
  if (hx == 0) { return 5; }
  hash.write_bytes_algo(hx, &buf[0], 3);
  inc = hash.finish_algo(hx);
  hash.free_algo(hx);
  if (inc != one) { return 6; }
  return 0;
}
