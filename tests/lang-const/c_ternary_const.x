// main: see function docblock below.
/** Internal function `main`.
 * C5 EXPR_TERNARY CTFE: with prior const X=2, both ternaries fold at
 * typeck time. The first picks the then-branch (X==2 is true -> 10); the
 * second picks the else-branch (X==9 is false -> 90). Verifies the
 * whitelist accepts `const Y = (X==k) ? a : b;` (recursive on
 * cond/then/else) and the fold handler stamps the selected branch's
 * constant. Values chosen so Y+Z=100 fits in [0,255] exit-code range.
 * Combined exit 100.
 * @return i32
 */
function main(): i32 {
  const X: i32 = 2;
  const Y: i32 = (X == 2) ? 10 : 20;
  const Z: i32 = (X == 9) ? 50 : 90;
  return Y + Z;
}
