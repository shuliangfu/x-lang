// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: Vec8i = [1, 1, 1, 1, 1, 1, 1, 1];
  let b: Vec8i = [2, 2, 2, 2, 2, 2, 2, 2];
  let c: Vec8i = a + b;
  let z: Vec8i = c - c;
  let w: Vec8i = z + z;
  let v: Vec8i = w - w;
  return 0;
}
