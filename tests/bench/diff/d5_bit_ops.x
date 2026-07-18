// See implementation.
// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let acc: u32 = 0;
  let allones: u32 = 0xFFFFFFFF;

  // See implementation.
  let neg: i32 = -1;
  acc = acc ^ ((neg >> 1) as u32);

  // See implementation.
  let high: u32 = 0x80000000;
  acc = acc ^ (high >> 4);

  // See implementation.
  let one: u32 = 1;
  acc = acc ^ (one << 30);

  // See implementation.
  let mask: u32 = 0x0F0F;
  acc = acc ^ (allones ^ mask);

  // See implementation.
  let a1: u32 = 0xAA55;
  let a2: u32 = 0x0FF0;
  acc = acc ^ (a1 & a2);

  // See implementation.
  let v: u32 = 0xDEADBEEF;
  let ff: u32 = 0xFF;
  acc = acc ^ ((v >> 24) & ff);
  acc = acc ^ ((v >> 16) & ff);
  acc = acc ^ ((v >> 8) & ff);
  acc = acc ^ (v & ff);

  // See implementation.
  let x: u32 = 0;
  let bit7: u32 = one << 7;
  x = x | bit7;
  x = x & (allones ^ bit7);
  acc = acc ^ x;

  // See implementation.
  let ff16: u32 = ff << 16;
  acc = acc ^ (ff16 | ff);

  return (acc & 0xFF) as i32;
}
