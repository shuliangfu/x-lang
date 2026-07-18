// set_at: see function docblock below.
/** Internal function `set_at`.
 * Implements `set_at`.
 * @param buf *i32
 * @param i i32
 * @param v i32
 * @return i32
 */
function set_at(buf: *i32, i: i32, v: i32): i32 {
  buf[i] = v;
  return buf[i];
}
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  return set_at(&arr[0], 1, 99);
}
