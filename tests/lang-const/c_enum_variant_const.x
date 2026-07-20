// main: see function docblock below.
/** Internal function `main`.
 * C5 EXPR_ENUM_VARIANT CTFE:
 * - `const X: Color = Color.Green;` passes the const-init whitelist because
 *   glue_is_const_expr_ref now pre-marks FIELD_ACCESS via the typeck active
 *   module global and accepts enum-variant shapes.
 * - glue_typeck_fold_expr_ref's new FIELD_ACCESS handler stamps
 *   X.const_folded_val = Green's variant tag (1).
 * - `match X { Color.Red => 100; Color.Green => 200; Color.Blue => 300; _ => 400; }`
 *   folds via the EXPR_MATCH handler: subject_val=1 equals Green arm's
 *   variant_index=1, so Y folds to 200.
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
