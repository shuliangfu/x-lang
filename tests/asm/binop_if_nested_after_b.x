// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let c: i32 = a + b;
  if (1 == 1) {
    if (1 == 0) {
      a += 99;
    } else {
      a += 5;
    }
  } else {
    a += 0;
  }
  return a + b;
}
