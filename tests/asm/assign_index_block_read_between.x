// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: i32[4] = [10, 20, 30, 40];
  let i: i32 = 1;
  let j: i32 = 0;
  let k: i32 = 0;
  arr[(i - j + k) * 2] = 11;
  let t: i32 = arr[(i - j + k) * 2];
  arr[(i - j + k) * 2] = 22;
  return t + arr[2];
}
