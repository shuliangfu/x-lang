// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 20;
  let a: i32[32] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let b: i32[32] = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let dst: i32[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let i: i32 = 0;
  while (i < n) {
    dst[i] = a[i] + b[i];
    i += 1;
  }
  return dst[0] + dst[19];
}
