/**
 * pipeline_typeck_ctfe.c — typeck CTFE Cap residual thin faces (wave238).
 *
 * wave238 G.7 pure leave: live CTFE producer is typeck.x / typeck_x.o
 * (typeck_fold_expr / typeck_fold_block_const_init / typeck_fold_expr_in_block /
 * typeck_block_const_init_is_const / typeck_const_init_not_constant /
 * typeck_expr_is_c_static_const_init). This slice keeps C ABI faces for
 * historical call sites (typeck_gen seed paths / codegen static-init gate).
 *
 * Dual-export ban: no second fold body here.
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

extern int32_t typeck_expr_is_c_static_const_init(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t typeck_block_const_init_is_const(struct ast_ASTArena *arena, int32_t block_ref, int32_t const_idx);
extern void typeck_const_init_not_constant(int32_t line, int32_t col);
extern void typeck_fold_expr(struct ast_ASTArena *arena, int32_t expr_ref);
extern void typeck_fold_block_const_init(struct ast_ASTArena *arena, int32_t block_ref, int32_t const_idx);
extern void typeck_fold_expr_in_block(struct ast_ASTArena *arena, int32_t block_ref, int32_t expr_ref);

/** PLATFORM: SHARED — thin → typeck_expr_is_c_static_const_init (wave238). */
int32_t pipeline_expr_is_c_static_const_init(struct ast_ASTArena *arena, int32_t expr_ref) {
  return typeck_expr_is_c_static_const_init(arena, expr_ref);
}

/** PLATFORM: SHARED — thin → typeck_block_const_init_is_const (wave238). */
int32_t pipeline_typeck_block_const_init_is_const_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t const_idx) {
  return typeck_block_const_init_is_const(arena, block_ref, const_idx);
}

/** PLATFORM: SHARED — thin → typeck_const_init_not_constant (wave238). */
void pipeline_typeck_const_init_not_constant_c(int32_t line, int32_t col) {
  typeck_const_init_not_constant(line, col);
}

/** PLATFORM: SHARED — thin → typeck_fold_expr (wave238). */
void pipeline_typeck_fold_expr_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  typeck_fold_expr(arena, expr_ref);
}

/** PLATFORM: SHARED — thin → typeck_fold_block_const_init (wave238). */
void pipeline_typeck_fold_block_const_init_c(struct ast_ASTArena *arena, int32_t block_ref,
                                            int32_t const_idx) {
  typeck_fold_block_const_init(arena, block_ref, const_idx);
}

/** PLATFORM: SHARED — thin → typeck_fold_expr_in_block (wave238). */
void pipeline_typeck_fold_expr_in_block_c(struct ast_ASTArena *arena, int32_t block_ref,
                                         int32_t expr_ref) {
  typeck_fold_expr_in_block(arena, block_ref, expr_ref);
}
