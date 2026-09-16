// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * Logical CTFE with bool operands; LANG-006 bool→int on `const V: i32`.
 * @return i32
 */
function main(): i32 {
  const V: i32 = (true && false) || (true && true);
  return V;
}
