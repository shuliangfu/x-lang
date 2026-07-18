// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  while (i < 10000000) {
    n = n + i;
    i = i + 1;
  }
  return n;
}
