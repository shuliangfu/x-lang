/**
 * pipeline_typeck_assign.c — typeck assign domain Cap residual thin (BC 8.3.1
 * wave225 pure leave).
 *
 * wave225 G.7 pure leave: product-mega assign + diag-fmt cluster bodies
 * retired from host-cc residual. Live authority is typeck.x
 * (typeck_check_expr_assign + typeck_diag_*). Cap residual keeps only:
 *   1. C ABI face names used by residual check_expr mega / return diag
 *   2. Same-TU helper pipeline_typeck_module_num_imports_c (method_call)
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * check_expr_deref and before pipeline_typeck_soa.c.
 *
 * Dual-export ban: do NOT re-open second assign/diag body here or in
 * runtime_pipeline_abi; typeck.x is single authority.
 *
 * PLATFORM: SHARED — freestanding typeck faces via typeck_x.o link.
 */

/* Live authority in typeck_x.o (typeck.x exports). */
extern int32_t typeck_check_expr_assign(struct ast_Module *module, struct ast_ASTArena *arena,
                                        int32_t expr_ref, int32_t return_type_ref,
                                        struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_diag_append_lit(uint8_t *out, int32_t pos, int32_t cap, uint8_t *lit,
                                     int32_t lit_len);
extern int32_t typeck_diag_append_u32_dec(uint8_t *out, int32_t pos, int32_t cap, int32_t v);
extern int32_t typeck_diag_fmt_type_at(struct ast_ASTArena *arena, int32_t ref, uint8_t *out,
                                      int32_t cur, int32_t cap);
extern int32_t typeck_diag_fmt_type_into(struct ast_ASTArena *arena, int32_t ref, uint8_t *out,
                                        int32_t cap);
extern int32_t typeck_diag_fmt_type_or_question(struct ast_ASTArena *arena, int32_t ref,
                                               uint8_t *out);

/* wave224 pure BSS active-module cell (runtime_pipeline_abi). */
extern void pipeline_typeck_active_module_set_c(struct ast_Module *m);

extern int32_t parser_get_module_num_imports(struct ast_Module *module);

/**
 * Product-mega C face for EXPR_ASSIGN / compound assign.
 *
 * Sets active-module cell (wave224 pure BSS; residual assign historically
 * stamped here before type matching) then delegates to typeck.x authority.
 *
 * Why thin: G.7 kill dual residual body (~550 LOC) that drifted from
 * typeck.x (void diag, Linear fmt, lit coerce waves). Callers:
 * pipeline_typeck_check_expr_impl_mega_c assign arm.
 *
 * Contract: same as typeck_check_expr_assign — 0 ok, -1 fail.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                            int32_t expr_ref, int32_t return_type_ref,
                                            struct ast_PipelineDepCtx *ctx) {
  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  pipeline_typeck_active_module_set_c(module);
  return typeck_check_expr_assign(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * wave1066 G.7: unified import-count reader for method_call residual.
 * Prefer parser face; fall back to Module.num_imports. Kept in this
 * residual leaf (same TU) because method_call.c still host-cc.
 *
 * PLATFORM: SHARED.
 */
static int32_t pipeline_typeck_module_num_imports_c(struct ast_Module *module) {
  int32_t n_imp;

  if (!module)
    return 0;
  n_imp = parser_get_module_num_imports(module);
  if (n_imp > 0)
    return n_imp;
  return module->num_imports;
}

/**
 * Diag fmt cluster Cap residual faces — thin to typeck.x (wave1156 cluster
 * pure leave wave225). Residual return-type mismatch in check_expr still
 * calls the _c names; assign mismatch now runs inside typeck.x directly.
 *
 * PLATFORM: SHARED — pure buffer/type formatting.
 */
int32_t pipeline_typeck_diag_append_lit_c(uint8_t *out, int32_t pos, int32_t cap, uint8_t *lit,
                                         int32_t lit_len) {
  return typeck_diag_append_lit(out, pos, cap, lit, lit_len);
}

int32_t pipeline_typeck_diag_append_u32_dec_c(uint8_t *out, int32_t pos, int32_t cap, int32_t v) {
  return typeck_diag_append_u32_dec(out, pos, cap, v);
}

int32_t pipeline_typeck_diag_fmt_type_at_c(struct ast_ASTArena *arena, int32_t ref, uint8_t *out,
                                          int32_t cur, int32_t cap) {
  return typeck_diag_fmt_type_at(arena, ref, out, cur, cap);
}

int32_t pipeline_typeck_diag_fmt_type_into_c(struct ast_ASTArena *arena, int32_t ref, uint8_t *out,
                                            int32_t cap) {
  return typeck_diag_fmt_type_into(arena, ref, out, cap);
}

int32_t pipeline_typeck_diag_fmt_type_or_question_c(struct ast_ASTArena *arena, int32_t ref,
                                                   uint8_t *out) {
  return typeck_diag_fmt_type_or_question(arena, ref, out);
}
