// See implementation.
const random = import("std.random");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (random.fill_bytes(&buf[0], 16) != 16) { return 1; }
  let all_zero: i32 = 1;
  let i: i32 = 0;
  while (i < 16) {
    if (buf[i] != 0) { all_zero = 0; }
    i = i + 1;
  }
  if (all_zero == 1) { return 2; }
  return 0;
}
