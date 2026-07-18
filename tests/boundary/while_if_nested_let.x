// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let i: i32 = 0;
  while (i < 10) {
    if (i > 0) {
      let fr: i32 = i + 1;
      i = fr;
    } else {
      i = i + 1;
    }
  }
  return i;
}
