// See implementation.
// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let acc: u32 = 0;

  // See implementation.
  let m1: u32 = 0xFFFFFFFF;
  acc = acc ^ (m1 + 1);

  // See implementation.
  let neg1: i32 = -1;
  acc = acc ^ (neg1 as u32);

  // See implementation.
  let neg7: i32 = -7;
  acc = acc ^ ((neg7 / 2) as u32);

  // See implementation.
  acc = acc ^ ((neg7 % 2) as u32);

  // See implementation.
  acc = acc ^ (m1 / 2);

  // See implementation.
  let one: u32 = 1;
  acc = acc ^ (one << 31);

  // See implementation.
  let high: u32 = 0x80000000;
  acc = acc ^ (high >> 1);

  // See implementation.
  acc = acc ^ (0xF0F0 & 0x0FF0);

  // See implementation.
  acc = acc ^ (0xF0F0 | 0x0FF0);

  // See implementation.
  acc = acc ^ (0xFF00 ^ 0x0FF0);

  // See implementation.
  // See implementation.
  let one64: i64 = 1;
  let big: i64 = one64 << 40;
  acc = acc ^ (big as u32);

  // See implementation.
  acc = acc ^ ((big * (3 as i64)) as u32);

  return (acc & 0xFF) as i32;
}
