/*
 * pipeline_asm_emit_var_decl.c — BC 8.3.1 wave1023 G.7 fold
 *
 * Shared VAR-decl type-ref + lazy block-let append infrastructure for the
 * asm ELF emit pipeline. Extracted from pipeline_glue.c residual (same TU;
 * no new DEPS count — #included from pipeline_glue.c at the former definition
 * site after glue_var_expr_stack_off_elf_c / before later glue residual).
 *
 * G.7: single product-mega VAR-decl type resolution face — do not open a
 * second block-let slot registration path or second param/let type-ref
 * resolver. All asm emit leaves (assign/unary/binop/call_args/expr_rec/
 * block_inits/block_body) forward-declare these two statics and rely on
 * same-TU visibility via this include.
 *
 * Callers (same TU static):
 *   - glue_var_decl_type_ref_elf_c:
 *       pipeline_asm_emit_call_args.c (call_arg VAR type resolve)
 *       pipeline_asm_emit_binop.c (try_binop operand VAR type)
 *       pipeline_asm_emit_assign.c (assign lhs / compound-assign base type)
 *       pipeline_asm_emit_unary.c (unary operand VAR type)
 *       pipeline_asm_emit_expr_rec.c (emit_expr_elf VAR arm)
 *       pipeline_glue.c body (emit_expr / emit_stmt VAR fallback)
 *   - glue_lazy_append_block_let_local:
 *       pipeline_asm_emit_call_args.c (block body let lazy register)
 *       pipeline_asm_emit_block_inits.c (block inits let lazy register)
 *       pipeline_asm_emit_block_body.c (block body let lazy register)
 *       pipeline_glue.c body (stmt_order let lazy register)
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the
 * former var_decl_type_ref definition site (after glue_var_expr_stack_off
 * definition + lazy_append forward; before later glue residual / call_args
 * include via forward or later definition).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV stack slot layout (rbp negative offset)
 *   · f32 param homing priority (typeck widen f32→f64 must not truncate)
 */

/**
 * Local VAR declaration type-ref (block-let / param / expr-resolved fallback).
 *
 * Resolution order (G.7 single authority — no second resolver):
 *  1. Inner block-let shadow param: scope_block_ref → pipeline_block_resolve_var_type_ref
 *  2. Param table: pipeline_module_func_param_type_ref_for_name (f32 must
 *     precede expr-resolved to avoid 64-bit load truncating f32 homed params)
 *  3. Expr-resolved type-ref: pipeline_expr_resolved_type_ref (typeck fallback)
 *
 * Returns type_ref > 0 on success; 0 on failure / invalid VAR expr.
 * Invariants: var_expr_ref must be EXPR_KIND_VAR; vname fits 127 bytes.
 */
static int32_t glue_var_decl_type_ref_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                             int32_t var_expr_ref) {
  uint8_t vname[128];
  int32_t vlen;
  int32_t scope_br;
  int32_t tr;
  if (!arena || !ctx || var_expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, var_expr_ref) != GLUE_EXPR_KIND_VAR)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  if (vlen <= 0 || vlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, var_expr_ref, vname);
  /** Inner block-let shadowing param takes precedence (block decl wins). */
  scope_br = asm_ctx_scope_block_ref_at((uint8_t *)ctx);
  if (scope_br > 0) {
    tr = pipeline_block_resolve_var_type_ref(arena, scope_br, vname, vlen);
    if (tr > 0)
      return tr;
  }
  /**
   * Param table f32 must precede expr-resolved (short names like x get widened
   * to f64 by typeck; do not let 64-bit load truncate an f32-homed param to 0).
   */
  if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0) {
    tr = pipeline_module_func_param_type_ref_for_name(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index,
                                                      vname, vlen);
    if (tr > 0)
      return tr;
  }
  tr = pipeline_expr_resolved_type_ref(arena, var_expr_ref);
  if (tr > 0)
    return tr;
  return 0;
}

/**
 * stmt_order path: lazy-register a block-let local slot when fill_tree has
 * not yet entered the let (use asm_local_slot_reg_offset, not backend slot
 * 0 → rbp+0 which would alias the return address).
 *
 * Guards (G.7 — no double registration / no clobber of fill_tree layout):
 *  - Already registered (asm_ctx_local_find_offset >= 0) → no-op return 0
 *  - fill_tree/ensure already set block slot (asm_ctx_block_slot_get >= 0)
 *    → no-op return 0 (with_arena v overlaps Arena64; do not next_offset)
 *  - Otherwise: pipeline_block_let_type_ref → asm_local_slot_reg_offset
 *    → asm_ctx_local_append; bump ly->next_offset + ly->num_locals
 *
 * Returns 0 on success (incl. no-op); -1 on invalid args / append failure.
 */
static int32_t glue_lazy_append_block_let_local(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                 int32_t block_ref, int32_t let_idx, uint8_t *name, int32_t name_len) {
  int32_t tref;
  int32_t off;
  int32_t slot_off;
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!arena || !ctx || !name || name_len <= 0 || block_ref <= 0 || let_idx < 0)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  if (asm_ctx_local_find_offset((uint8_t *)ctx, name, name_len) >= 0)
    return 0;
  /** fill_tree/ensure already registered this block's stack layout; do not
   * next_offset append again (with_arena v overlaps Arena64). */
  if (asm_ctx_block_slot_get((uint8_t *)ctx, block_ref) >= 0)
    return 0;
  tref = pipeline_block_let_type_ref(arena, block_ref, let_idx);
  off = ly->next_offset;
  slot_off = asm_local_slot_reg_offset(arena, tref, off, &off);
  ly->next_offset = off;
  if (asm_ctx_local_append((uint8_t *)ctx, name, name_len, slot_off) < 0)
    return -1;
  ly->num_locals = asm_ctx_local_count((uint8_t *)ctx);
  return 0;
}
