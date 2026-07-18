// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: Vec8i = [10, 10, 10, 10, 10, 10, 10, 10];
  let b: Vec8i = [1, 2, 3, 4, 5, 6, 7, 8];
  let c: Vec8i = a - b;
  let z: Vec8i = c - c;
  let w: Vec8i = z - z;
  return 0;
}
