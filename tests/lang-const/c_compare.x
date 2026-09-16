// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * Compare CTFE + LANG-006 bool→int on const init (product forbids bool arith).
 * @return i32
 */
function main(): i32 {
  const A: i32 = 5 > 3;
  const B: i32 = 2 == 2;
  const C: i32 = 1 >= 2;
  return A + B + C;
}
