// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  const V: i32 = (1 && 0) || (1 && 1);
  return V;
}
