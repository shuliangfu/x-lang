// main: see function docblock below.
/** Internal function `main`.
 * C5 EXPR_MATCH CTFE: const subject + const arms folds to selected arm's const.
 * @return i32
 */
function main(): i32 {
  const X: i32 = 2;
  let Y: i32 = match X {
    1 => 10;
    2 => 20;
    3 => 30;
    _ => 40;
  };
  return Y;
}
