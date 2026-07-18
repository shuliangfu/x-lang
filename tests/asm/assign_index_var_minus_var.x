// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  let i: i32 = 2;
  let j: i32 = 1;
  arr[i - j] = 99;
  return arr[1];
}
