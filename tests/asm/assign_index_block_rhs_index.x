// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: i32[4] = [10, 20, 30, 40];
  let j: i32 = 1;
  arr[2] = 11;
  arr[2] = arr[j];
  return arr[2];
}
