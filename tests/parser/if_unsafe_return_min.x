// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (1 == 1) {
    unsafe {
      return 1;
    }
  }
  return 0;
}
