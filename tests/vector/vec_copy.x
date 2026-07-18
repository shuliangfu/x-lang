// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let c: i32x4 = a;
  let d: i32x4 = c - a;
  let z: i32x4 = d - d;
  return 0;
}
