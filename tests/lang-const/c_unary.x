// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  const v: i32 = -(-5) + (~0 & 255);
  return v & 255;
}
