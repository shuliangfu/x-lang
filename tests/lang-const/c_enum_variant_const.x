// main: see function docblock below.
/** Internal function `main`.
 * C5 EXPR_ENUM_VARIANT CTFE:
 * - `const X: Color = Color.Green;` passes the const-init whitelist because
 *   FIELD_ACCESS enum-variant shapes are accepted as const exprs.
 * - fold stamps X.const_folded_val = Green's variant tag (1).
 * - `match X { ... }` folds via the EXPR_MATCH handler to arm result 200.
 * @return i32
 */
enum Color { Red, Green, Blue }

function main(): i32 {
  const X: Color = Color.Green;
  let Y: i32 = match X {
    Color.Red => 100;
    Color.Green => 200;
    Color.Blue => 300;
    _ => 400;
  };
  return Y;
}
