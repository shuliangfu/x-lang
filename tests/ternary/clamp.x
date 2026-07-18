// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let x: i32 = -3;
  let v: i32 = x < 0 ? 0 : (x > 10 ? 10 : x);
  return v;
}
