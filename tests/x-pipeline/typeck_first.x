const ast = import("ast");
/** Internal function `expr_type_ref_impl`.
 * Implements `expr_type_ref_impl`.
 * @param arena *ASTArena
 * @param expr_ref i32
 * @return i32
 */
function expr_type_ref_impl(arena: *ASTArena, expr_ref: i32): i32 {
  let e: Expr = ast_arena_expr_get(arena, expr_ref);
  return e.resolved_type_ref;
}
