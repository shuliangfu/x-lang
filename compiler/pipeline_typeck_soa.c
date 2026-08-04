/**
 * pipeline_typeck_soa.c — DOD-S1 SoA layout typeck surface (host-cc residual).
 *
 * Included by pipeline_glue.c into the same translation unit.
 * R2 (8.3.3): all SoA algorithms live in typeck.x → typeck_x.o.
 * This file keeps only:
 *   - extern decls for same-TU callers (emit / field_access)
 *   - thin public surfaces that forward to .x authority
 *
 * PLATFORM: SHARED — no arch dependency.
 */

extern struct ast_PipelineDepCtx *pipeline_asm_emit_dep_pipe_c(void);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);

/**
 * Find struct layout index by name in module.struct_layouts; -1 if not found.
 * R2 (8.3.3): impl migrated to typeck.x authority; .c callers resolve via link to typeck_x.o.
 * PLATFORM: SHARED — visible via pipeline_x.o TU + typeck_x.o.
 */
int32_t typeck_soa_find_layout_idx_by_name(struct ast_Module *module, uint8_t *name, int32_t name_len);

/**
 * Find SoA layout by name in primary module or WPO dep pool; on hit write *out_layout_mod.
 * R2 (8.3.3): impl migrated to typeck.x authority; same-TU field_soa_index resolves via link.
 * PLATFORM: SHARED — visible via pipeline_x.o TU + typeck_x.o.
 */
int32_t typeck_soa_find_layout_module_and_idx(struct ast_Module *module, uint8_t *name, int32_t name_len,
                                             struct ast_Module **out_layout_mod);

/**
 * SoA column base: columns before field fi occupy N * sizeof(field) (with align).
 * R2 (8.3.3): impl migrated to typeck.x authority (uses typeck_x_type_align/size).
 * PLATFORM: SHARED — visible via pipeline_x.o TU + typeck_x.o.
 */
int32_t typeck_soa_col_base_for_field(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
                                      int32_t field_idx, int32_t array_len, int32_t depth);

/**
 * EXPR_FIELD_ACCESS with INDEX base: SoA `arr[i].field` stamps col_base + stride.
 * Returns 1 if handled; 0 if not SoA.
 * R2 (8.3.3): impl migrated to typeck.x as typeck_soa_field_soa_index
 * (stride via typeck_x_type_size). Surface name kept for emit/typeck callers.
 * PLATFORM: SHARED — visible via pipeline_x.o TU + typeck_x.o.
 */
int32_t typeck_soa_field_soa_index(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                   int32_t base_ref);

/**
 * Before asm emit: fill SoA col_base+stride and AoS layout offsets for
 * FIELD_ACCESS (skip-typeck repair + STRUCT_LIT layout merge + DOD-CL align).
 * R2 (8.3.3): impl migrated to typeck.x as typeck_soa_fill_field_access_for_asm_emit.
 * PLATFORM: SHARED — visible via pipeline_x.o TU + typeck_x.o.
 */
void typeck_soa_fill_field_access_for_asm_emit(struct ast_Module *module, struct ast_ASTArena *arena);

/**
 * Stable surface for historical callers (emit / field_access / fill_soa).
 * Zero business logic — forwards to typeck.x authority.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_field_soa_index_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                          int32_t base_ref) {
  return typeck_soa_field_soa_index(module, arena, expr_ref, base_ref);
}

/**
 * Public SoA / field-access fill entry for asm emit.
 * Zero business logic — forwards to typeck.x authority
 * (typeck_soa_fill_field_access_for_asm_emit).
 *
 * Callers (cross-TU / same-TU after this #include):
 *  - ast_pool.c / pipeline_backend_asm_wrapper.c
 *  - runtime_pipeline_abi.x / seeds (export / surface)
 *  - runtime_driver_strict_glue_stubs.from_x.c (XLANG_WEAK cold stub)
 *
 * PLATFORM: SHARED — pure thin surface, no arch dependency.
 */
void pipeline_fill_soa_field_access_for_asm_emit(struct ast_Module *m, struct ast_ASTArena *arena) {
  typeck_soa_fill_field_access_for_asm_emit(m, arena);
}
