// main: see function docblock below.
/** Internal function `main`.
 * C5 EXPR_IF CTFE: with prior const X=2, both if-expressions fold at
 * typeck time. EXPR_IF shares the if_cond_ref / if_then_ref / if_else_ref
 * field layout with EXPR_TERNARY (ast_pool.c::asm_wpo_collect_edges_from_expr
 * L14836-14844), so one fold handler covers both kinds. The first picks
 * then-branch (X==2 is true -> 10); the second picks else-branch (X==9 is
 * false -> 90). Values chosen so Y+Z=100 fits in [0,255] exit-code range.
 * Combined exit 100.
 * @return i32
 */
function main(): i32 {
  const X: i32 = 2;
  const Y: i32 = if (X == 2) { 10 } else { 20 };
  const Z: i32 = if (X == 9) { 50 } else { 90 };
  return Y + Z;
}
