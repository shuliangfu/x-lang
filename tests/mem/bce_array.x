// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: i32[8] = [1, 2, 3, 4, 5, 6, 7, 8];
  let sum: i32 = 0;
  for (let i: i32 = 0; i < 8; i = i + 1) {
    sum = sum + arr[i];
  }
  return sum;
}
