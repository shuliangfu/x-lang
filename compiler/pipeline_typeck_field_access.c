/**
 * pipeline_typeck_field_access.c — EXPR_FIELD_ACCESS typeck C thin surfaces (8.3.3).
 *
 * Included by pipeline_glue.c (same TU; not a separate .o).
 * All business logic migrated to typeck.x (G.7 single authority). This TU keeps
 * thin C forwarders for strict_glue / seed / residual C callers only.
 * bare-import-const: typeck_reject_bare_import_const (shared with check_expr_var).
 * Orchestrator: typeck_check_expr_field_access; C surface is thin (OMIT_X_DUP).
 * PLATFORM: SHARED.
 */

/**
 * R2 (8.3.3): bare VAR access to dep top-level const → must be binding.CONST.
 * Body migrated to typeck.x as typeck_reject_bare_import_const (G.7 with VAR path).
 * Zero business logic — thin surface for pipeline_typeck_check_expr_c VAR arm.
 * PLATFORM: SHARED.
 */
extern int32_t typeck_reject_bare_import_const(struct ast_Module *module, struct ast_ASTArena *arena,
                                               int32_t expr_ref, struct ast_PipelineDepCtx *ctx, uint8_t *vbuf,
                                               int32_t vnlen);

int32_t pipeline_typeck_reject_bare_import_const_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t expr_ref, struct ast_PipelineDepCtx *ctx, uint8_t *vbuf,
                                                   int32_t vnlen) {
  return typeck_reject_bare_import_const(module, arena, expr_ref, ctx, vbuf, vnlen);
}

/**
 * EXPR_FIELD_ACCESS: prebind untyped VAR base as TYPE_NAMED of same spelling.
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_prebind.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 */
void typeck_field_prebind(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                          struct ast_PipelineDepCtx *ctx);

void pipeline_typeck_field_prebind_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                    struct ast_PipelineDepCtx *ctx) {
  typeck_field_prebind(module, arena, expr_ref, ctx);
}

/**
 * EXPR_FIELD_ACCESS: *ASTArena / *Module known-field special-case.
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_known_ptr.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 * @return 1 = matched and stamped; 0 = continue field fallbacks.
 */
int32_t typeck_field_known_ptr(struct ast_Module *module, struct ast_ASTArena *arena,
                               int32_t expr_ref, int32_t base_ref,
                               int32_t num_struct_layouts);

int32_t pipeline_typeck_field_known_ptr_types_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                       int32_t expr_ref, int32_t base_ref,
                                                       int32_t num_struct_layouts) {
  return typeck_field_known_ptr(module, arena, expr_ref, base_ref, num_struct_layouts);
}

/**
 * EXPR_FIELD_ACCESS: named-type layout / enum / TypeKind / TokenKind.
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_layout_named.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 * @return 2 = user enum done (caller returns 0); 0 = continue field fallbacks.
 */
int32_t typeck_field_layout_named(struct ast_Module *module, struct ast_ASTArena *arena,
                                  int32_t expr_ref, int32_t base_ref,
                                  struct ast_PipelineDepCtx *ctx);

int32_t pipeline_typeck_field_layout_named_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t expr_ref, int32_t base_ref,
                                                    struct ast_PipelineDepCtx *ctx) {
  return typeck_field_layout_named(module, arena, expr_ref, base_ref, ctx);
}

/**
 * EXPR_FIELD_ACCESS：T[] 的 .length（usize）与 .data（*elem for any T）.
 *
 * Fat layout (PLATFORM: SHARED / SysV dual-GP home): { .data @ +0, .length @ +8 }.
 * Asm stack homes register byte0 at slot_off; high half at slot_off-8 (see
 * asm_local_slot_reg_offset / param dual-home). Emit must use field_access_offset so
 * lea base + add offset hits the correct half — previously offset stayed 0 and
 * s.length loaded .data (tests/slice/data_field.x exit 2).
 *
 * G.7 complete: .data must resolve to TYPE_PTR(elem) for i32/u8/u64/… — not only U8.
 * Old U8-only gate left s.data untyped for i32[] → INDEX `s.data[i]` T001 on Ubuntu
 * (formal core/slice/mod.x get_i32 / length.x co-emit typeck). mac often soft-pathed.
 *
 * wave346 Cap residual pure: TYPE_ARRAY / TYPE_VECTOR `.length` is also usize (compile-time
 * N). Prior: only TYPE_SLICE → fixed `a.length` never stamped; host C emitted `a.length`
 * on a C array (illegal); freestanding loaded slot[0] as length (run=10 not 3).
 * G.7: extend this authority — no second field_array helper. Emit paths use array_size_at.
 * PLATFORM: SHARED — typeck; host+fs emit co-land same wave.
 */
/**
 * EXPR_FIELD_ACCESS: slice / fixed-array / vector built-in field typing.
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_slice.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 */
void typeck_field_slice(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref);

void pipeline_typeck_field_slice_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref) {
  typeck_field_slice(arena, expr_ref, base_ref);
}

/**
 * EXPR_FIELD_ACCESS: name fallback (CodegenOutBuf / inline array / scalar).
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_name_fallback.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 */
void typeck_field_name_fallback(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref);

void pipeline_typeck_field_name_fallback_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref) {
  typeck_field_name_fallback(arena, expr_ref, base_ref);
}

/**
 * EXPR_FIELD_ACCESS: LexerResult / formal-type field-name fallback.
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_lexer_fallback.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 */
void typeck_field_lexer_fallback(struct ast_Module *module, struct ast_ASTArena *arena,
                                 int32_t expr_ref, int32_t base_ref, struct ast_PipelineDepCtx *ctx);

void pipeline_typeck_field_lexer_fallback_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 int32_t expr_ref, int32_t base_ref, struct ast_PipelineDepCtx *ctx) {
  typeck_field_lexer_fallback(module, arena, expr_ref, base_ref, ctx);
}

/**
 * EXPR_FIELD_ACCESS: import binding resolve (dep function / const / enum).
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_import_binding.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 * @return 1 = matched and stamped; 0 = continue field typeck.
 */
int32_t typeck_field_import_binding(struct ast_Module *module, struct ast_ASTArena *arena,
                                    int32_t expr_ref, int32_t base_ref,
                                    struct ast_PipelineDepCtx *ctx);

int32_t pipeline_typeck_field_import_binding_resolve_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                        int32_t expr_ref, int32_t base_ref,
                                                        struct ast_PipelineDepCtx *ctx) {
  return typeck_field_import_binding(module, arena, expr_ref, base_ref, ctx);
}

/**
 * R2 (8.3.3): TYPE_NAMED module/dep concrete probe.
 * Body migrated to typeck.x as typeck_named_is_module_concrete.
 * Zero business logic — thin surface for strict_minimal + residual callers.
 * PLATFORM: SHARED.
 */
extern int32_t typeck_named_is_module_concrete(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                               uint8_t *name, int32_t name_len);

int32_t pipeline_typeck_named_is_module_concrete_c(struct ast_Module *module,
                                                          struct ast_PipelineDepCtx *ctx,
                                                          uint8_t *name,
                                                          int32_t name_len) {
  return typeck_named_is_module_concrete(module, ctx, name, name_len);
}

/**
 * R2 (8.3.3): mono free type-param field against monomorphized base.
 * Body migrated to typeck.x as typeck_mono_field_type_from_base.
 * Zero business logic — thin surface for field_access + STRUCT_LIT coerce.
 * PLATFORM: SHARED — G.7 mono field authority (wave466/467/682).
 */
extern int32_t typeck_mono_field_type_from_base(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t field_ty, int32_t base_ty);

int32_t pipeline_typeck_mono_field_type_from_base_c(struct ast_Module *module,
                                                   struct ast_ASTArena *arena,
                                                   int32_t field_ty,
                                                   int32_t base_ty) {
  return typeck_mono_field_type_from_base(module, arena, field_ty, base_ty);
}

/**
 * R2 (8.3.3): hard-fail unknown field on known base.
 * Body migrated to typeck.x as typeck_field_unknown_hard_fail.
 * Zero business logic — thin surface for strict_minimal weak twin + heavy path.
 * PLATFORM: SHARED — G.7 single gate (wave674/684/702).
 */
extern int32_t typeck_field_unknown_hard_fail(struct ast_Module *module, struct ast_ASTArena *arena,
                                              int32_t expr_ref, int32_t base_ref,
                                              struct ast_PipelineDepCtx *ctx);

int32_t pipeline_typeck_field_unknown_hard_fail_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 int32_t expr_ref, int32_t base_ref,
                                                 struct ast_PipelineDepCtx *ctx) {
  return typeck_field_unknown_hard_fail(module, arena, expr_ref, base_ref, ctx);
}

/**
 * R2 (8.3.3): EXPR_FIELD_ACCESS typeck orchestrator.
 * Body migrated to typeck.x as typeck_check_expr_field_access.
 * Zero business logic — thin surface for strict_glue / seed / OMIT_X_DUP.
 *
 * G.7 / wave465: mega pipeline_x (OMIT_X_DUP, no STANDALONE_TU) keeps a local
 * thin copy only — product export must come from pipeline_glue_standalone.o so
 * daily L2 rebuilds of field_access are not silently overridden by a stale
 * pipeline_x.o (Linux first-def-wins). PLATFORM: SHARED link discipline.
 */
extern int32_t typeck_check_expr_field_access(struct ast_Module *module, struct ast_ASTArena *arena,
                                              int32_t expr_ref, int32_t return_type_ref,
                                              struct ast_PipelineDepCtx *ctx);

#if defined(XLANG_PIPELINE_GLUE_OMIT_X_DUP_EXPORTS) && !defined(XLANG_PIPELINE_GLUE_STANDALONE_TU)
static
#endif
int32_t pipeline_typeck_check_expr_field_access_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                                  int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_field_access(module, arena, expr_ref, return_type_ref, ctx);
}
