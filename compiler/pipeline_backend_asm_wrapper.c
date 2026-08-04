/* ============================================================================
 * pipeline_backend_asm_wrapper.c — M8-tail backend asm codegen thin wrappers
 *
 * wave1279 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   pipeline_backend_asm_codegen_ast_c
 *   pipeline_backend_asm_codegen_ast_to_elf_c
 *
 * Thin C faces for backend.x `asm_codegen_ast` / `asm_codegen_ast_to_elf`:
 * hoist top-level lets, merge dep SoA layouts, fill ARRAY_LIT/FIELD_ACCESS,
 * set emit pipe/module/arena/elf_ctx, then call seed partial mega / mega_body.
 *
 * Include AFTER: ast_pool_top_level.c (hoist) and other pool domains that
 * wrappers call via public faces. Include BEFORE: module_enum / later asm domains.
 * Static forward asm_module_is_parser_emit_heavy is defined later in the host TU
 * (pipeline_asm_selfhost / parser_emit_heavy domain).
 *
 * PLATFORM: SHARED — host-cc residual; G.7 single authority with thin_delegate tables.
 * ============================================================================ */

/** seed partial (build_seed_asm_host) full mega; do not mix with thin wrappers (recursion). */
extern int32_t backend_asm_codegen_ast_seed_mega(struct ast_Module *m, struct ast_ASTArena *a,
                                                 struct codegen_CodegenOutBuf *out,
                                                 struct ast_PipelineDepCtx *pipeline_ctx);
extern int32_t backend_asm_codegen_ast_to_elf_seed_mega(struct ast_Module *m, struct ast_ASTArena *a,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        struct ast_PipelineDepCtx *pipeline_ctx);
extern void pipeline_asm_emit_set_elf_ctx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern void pipeline_asm_emit_set_dep_pipe(struct ast_PipelineDepCtx *ctx);
extern void pipeline_asm_emit_set_module(struct ast_Module *m);
extern void pipeline_asm_emit_set_arena(struct ast_ASTArena *arena);

/**
 * M8-tail: thin C face for `asm_codegen_ast`; hoist top-level lets then seed mega.
 */
int32_t pipeline_backend_asm_codegen_ast_c(struct ast_Module *m, struct ast_ASTArena *a,
                                            struct codegen_CodegenOutBuf *out,
                                            struct ast_PipelineDepCtx *pipeline_ctx) {
  if (!m || !a || !out || !pipeline_ctx)
    return -1;
  if (m->num_top_level_lets > 0)
    pipeline_module_hoist_top_level_lets_into_main(m, a);
  return backend_asm_codegen_ast_seed_mega(m, a, out, pipeline_ctx);
}

/** When .x typeck is skipped: fill ARRAY_LIT / SoA field types before emit (defs in glue). */
void pipeline_fill_array_lit_types_for_skipped_typeck(struct ast_Module *m, struct ast_ASTArena *arena);
void pipeline_fill_soa_field_access_for_asm_emit(struct ast_Module *m, struct ast_ASTArena *arena);
extern void pipeline_debug_trace_named_func_bodies(const char *phase, void *module, void *arena);
extern void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module *mod, struct ast_ASTArena *arena,
                                                              struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_wpo_unify_soa_layouts(struct ast_Module *entry, struct ast_PipelineDepCtx *ctx);

/** EMIT_HEAVY parser-module predicate (static def later in host TU). */
static int32_t asm_module_is_parser_emit_heavy(struct ast_Module *m);

/**
 * M8-tail: thin C face for `asm_codegen_ast_to_elf`; hoist, merge SoA, fill, mega_body + WPO thunks.
 */
int32_t pipeline_backend_asm_codegen_ast_to_elf_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   struct ast_PipelineDepCtx *pipeline_ctx) {
  int32_t rc;
  if (!m || !a || !elf_ctx || !pipeline_ctx)
    return -1;
  pipeline_debug_trace_named_func_bodies("backend_pre_hoist_top_level_lets", m, a);
  if (m->num_top_level_lets > 0)
    pipeline_module_hoist_top_level_lets_into_main(m, a);
  pipeline_debug_trace_named_func_bodies("backend_post_hoist_top_level_lets", m, a);
  /** DOD-S3: even when .x typeck is skipped, merge dep SoA into entry then promote. */
  pipeline_debug_trace_named_func_bodies("backend_pre_merge_dep_layouts", m, a);
  typeck_typeck_merge_dep_struct_layouts_into_entry(m, a, pipeline_ctx);
  pipeline_debug_trace_named_func_bodies("backend_post_merge_dep_layouts", m, a);
  typeck_typeck_wpo_unify_soa_layouts(m, pipeline_ctx);
  pipeline_debug_trace_named_func_bodies("backend_post_unify_soa_layouts", m, a);
  /** dep co-emit and entry need SoA stride / param types / FIELD_ACCESS offs (else SIGSEGV). */
  pipeline_asm_emit_set_dep_pipe(pipeline_ctx);
  pipeline_fill_array_lit_types_for_skipped_typeck(m, a);
  pipeline_fill_soa_field_access_for_asm_emit(m, a);
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: backend_asm_codegen fill done, calling mega_body_c\n");
  glue_wpo_mono_reset_pending();
  /** dep+entry write same elf_ctx: unique scope for tail_join/loop local labels. */
  pipeline_elf_label_mod_scope_begin_module();
  /** WPO-S3: import struct FIELD_ACCESS must see dep pool (backend.x mega also sets). */
  pipeline_asm_emit_set_module(m);
  pipeline_asm_emit_set_arena(a);
  pipeline_asm_emit_set_elf_ctx(elf_ctx);
  if (link_abi_getenv("XLANG_ASM_DEBUG") && m && asm_module_is_parser_emit_heavy(m))
    fprintf(stderr, "xlang: seed_mega parser nfunc=%d elf_ctx=%p code_len=%d\n", (int)m->num_funcs, (void *)elf_ctx,
            elf_ctx ? (int)elf_ctx->code_len : -1);
  rc = pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(m, a, elf_ctx, pipeline_ctx);
  pipeline_asm_emit_set_elf_ctx(NULL);
  if (rc != 0)
    return rc;
  return pipeline_asm_emit_wpo_mono_thunks_elf_c(m, a, elf_ctx, pipeline_ctx);
}
