// See implementation.
// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let acc: u32 = 0;

  // See implementation.
  let buf: u8[16] = 0;
  let i: i32 = 0;
  while (i < 16) {
    buf[i] = 0xAB;
    i = i + 1;
  }
  i = 0;
  while (i < 16) {
    acc = acc ^ (buf[i] as u32);
    i = i + 1;
  }

  // See implementation.
  let src: u8[8] = [1, 2, 3, 4, 5, 6, 7, 8];
  let dst: u8[8] = 0;
  i = 0;
  while (i < 8) {
    dst[i] = src[i];
    i = i + 1;
  }
  i = 0;
  while (i < 8) {
    acc = acc ^ (dst[i] as u32);
    i = i + 1;
  }

  // See implementation.
  let z: u8[4] = 0;
  i = 0;
  while (i < 0) {
    z[i] = 0xFF;
    i = i + 1;
  }
  i = 0;
  while (i < 4) {
    acc = acc ^ (z[i] as u32);
    i = i + 1;
  }

  return (acc & 0xFF) as i32;
}
