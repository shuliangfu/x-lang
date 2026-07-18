// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 3;
  let r: i64 = n >= 0 ? n : -1;
  if (r < 0) {
    return 1;
  }
  return 0;
}
