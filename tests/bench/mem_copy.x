// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[4096] = [];
  let sum: i32 = 0;
  let r: i32 = 0;
  while (r < 8192) {
    let i: i32 = 0;
    while (i < 4096) {
      buf[i] = (i as u8);
      i = i + 1;
    }
    let j: i32 = 0;
    while (j < 4096) {
      sum = sum + (buf[j] as i32);
      j = j + 1;
    }
    r = r + 1;
  }
  return sum;
}
