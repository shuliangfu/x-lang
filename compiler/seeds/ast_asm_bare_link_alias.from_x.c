/* seeds/ast_asm_bare_link_alias.from_x.c — G-02f-17 product TU
 * Logic still C until full .x port.
 */
/**
 * ast_asm_bare_link_alias.c — ast.x 裸符号 → pipeline_glue 的 ast_ast_* 前缀实现
 *
 * strict 链 typeck_strict_link_partial 与 pipeline_glue_standalone 去重后，
 * typeck/codegen 仍引用 ast_block_* 等裸名；由本 TU 转发至 glue 内 ast_ast_*。
 */
#include <stdint.h>

struct ast_ASTArena;

extern int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
extern int32_t ast_ast_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern int32_t ast_ast_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern int32_t ast_ast_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t ast_ast_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
extern int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_ast_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_ast_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_ast_block_resolve_var_to_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                                     int32_t vlen);

/** ast.x ast_block_final_expr_ref → glue ast_ast_block_final_expr_ref。 */
int32_t ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br) {
  return ast_ast_block_final_expr_ref(a, br);
}

/** ast.x ast_block_region_body_ref → glue ast_ast_block_region_body_ref。 */
int32_t ast_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  return ast_ast_block_region_body_ref(a, br, ri);
}

/** ast.x ast_block_const_init_ref → glue ast_ast_block_const_init_ref。 */
int32_t ast_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return ast_ast_block_const_init_ref(a, br, ci);
}

/** ast.x ast_block_const_type_ref → glue ast_ast_block_const_type_ref。 */
int32_t ast_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return ast_ast_block_const_type_ref(a, br, ci);
}

/** ast.x ast_block_let_init_ref → glue ast_ast_block_let_init_ref。 */
int32_t ast_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return ast_ast_block_let_init_ref(a, br, li);
}

/** ast.x ast_block_let_type_ref → glue ast_ast_block_let_type_ref。 */
int32_t ast_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return ast_ast_block_let_type_ref(a, br, li);
}

/** ast.x ast_block_expr_stmt_ref → glue ast_ast_block_expr_stmt_ref。 */
int32_t ast_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei) {
  return ast_ast_block_expr_stmt_ref(a, br, ei);
}

/** ast.x ast_block_while_cond_ref → glue ast_ast_block_while_cond_ref。 */
int32_t ast_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  return ast_ast_block_while_cond_ref(a, br, wi);
}

/** ast.x ast_block_while_body_ref → glue ast_ast_block_while_body_ref。 */
int32_t ast_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  return ast_ast_block_while_body_ref(a, br, wi);
}

/** ast.x ast_block_for_init_ref → glue ast_ast_block_for_init_ref。 */
int32_t ast_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return ast_ast_block_for_init_ref(a, br, fi);
}

/** ast.x ast_block_for_cond_ref → glue ast_ast_block_for_cond_ref。 */
int32_t ast_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return ast_ast_block_for_cond_ref(a, br, fi);
}

/** ast.x ast_block_for_step_ref → glue ast_ast_block_for_step_ref。 */
int32_t ast_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return ast_ast_block_for_step_ref(a, br, fi);
}

/** ast.x ast_block_for_body_ref → glue ast_ast_block_for_body_ref。 */
int32_t ast_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  return ast_ast_block_for_body_ref(a, br, fi);
}

/** ast.x ast_block_if_cond_ref → glue ast_ast_block_if_cond_ref。 */
int32_t ast_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return ast_ast_block_if_cond_ref(a, br, ii);
}

/** ast.x ast_block_if_then_body_ref → glue ast_ast_block_if_then_body_ref。 */
int32_t ast_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return ast_ast_block_if_then_body_ref(a, br, ii);
}

/** ast.x ast_block_if_else_body_ref → glue ast_ast_block_if_else_body_ref。 */
int32_t ast_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return ast_ast_block_if_else_body_ref(a, br, ii);
}

/** ast.x ast_block_resolve_var_to_type_ref → glue ast_ast_block_resolve_var_to_type_ref。 */
int32_t ast_block_resolve_var_to_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname, int32_t vlen) {
  return ast_ast_block_resolve_var_to_type_ref(a, block_ref, vname, vlen);
}
