// take_slice: see function docblock below.
/** Internal function `take_slice`.
 * Implements `take_slice`.
 * @param buf u8[]
 * @return i32
 */
function take_slice(buf: u8[]): i32 {
  let p: *u8 = buf.data;
  let n: usize = buf.length;
  if (n == 0) { return 0; }
  return (p != 0) ? 1 : -1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: u8[4] = [1, 2, 3, 4];
  let s: u8[] = arr;
  let r: i32 = take_slice(s);
  if (r != 1) { return 1; }
  if (s.length != 4) { return 2; }
  return 0;
}
