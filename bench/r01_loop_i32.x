// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 100000000;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    let t: i32 = i * 1103515245 + 12345;
    s = s ^ t;
    i = i + 1;
  }
  return s;
}
