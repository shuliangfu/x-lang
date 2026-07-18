// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[4] = [0, 0, 0, 0];
  buf[1] = 42;
  return buf[1] as i32;
}
