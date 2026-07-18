// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  let i: i32 = 1;
  let a: i32 = 20;
  let b: i32 = 22;
  arr[i] = a + b;
  return arr[i];
}
