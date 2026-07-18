// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  if (arr[1] < arr[0] + arr[1]) {
    return 1;
  }
  return 0;
}
