// See implementation.
// parser.x）。
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: u8[3] = [10, 20, 30];
  let i: i32 = 0;
  let sum: i32 = 0;
  while (i < 3) {
    sum = sum + (arr[i] as i32);
    i = i + 1;
  }
  return sum;
}
