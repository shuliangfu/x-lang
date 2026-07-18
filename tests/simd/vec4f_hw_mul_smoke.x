// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: Vec4f = [2.0, 2.0, 2.0, 2.0];
  let b: Vec4f = [3.0, 3.0, 3.0, 3.0];
  let c: Vec4f = a * b;
  let z: Vec4f = c - c;
  return 0;
}
