// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  let j: i32 = 2;
  arr[1] = arr[j];
  return arr[1];
}
