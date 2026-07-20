// C5 EXPR_STRUCT_LIT field CTFE 扩全 — struct lit field inits fold to immediates.
struct P { x: i32, y: i32 }

/** Internal function `main`.
 * C5 EXPR_STRUCT_LIT field CTFE: with prior const A=2, the field initializers
 * `A + 1` and `A * 3` fold to 3 and 6 respectively; the struct node itself
 * stays const_folded_valid=0 (struct cannot fit in i32). Verifies that the
 * field init recursion does not corrupt field values and that downstream
 * field-access + binop evaluates to the expected 9.
 * @return i32
 */
function main(): i32 {
  const A: i32 = 2;
  let p: P = P { x: A + 1, y: A * 3 };
  return p.x + p.y;
}
