// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  let i: i32 = 0;
  let j: i32 = 1;
  let k: i32 = 2;
  arr[i] = 1;
  arr[j] = 2;
  arr[k] = 3;
  return arr[0] + arr[1] + arr[2];
}
