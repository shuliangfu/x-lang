// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  let i: i32 = 0;
  arr[i + 1] = 99;
  return arr[1];
}
