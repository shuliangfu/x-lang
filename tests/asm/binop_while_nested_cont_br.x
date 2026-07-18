// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  let c: i32 = a + b;
  while (a < 3) {
    while (a < 2) {
      if (a == 0) {
        a += 1;
        continue;
      }
      if (a == 1) {
        break;
      }
      a += 1;
    }
    a += 1;
  }
  return a + b;
}
