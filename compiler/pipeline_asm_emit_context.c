/**
 * pipeline_asm_emit_context.c — asm emit global context setters/getters domain
 * (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega asm emit context management:
 * - pipeline_asm_emit_set_module / module_ref_c (current emit module)
 * - pipeline_asm_emit_set_dep_pipe / dep_pipe_c (current dep pipe)
 * - pipeline_asm_emit_set_arena (current emit AST arena)
 * - pipeline_asm_emit_set_call_param_type_ref (callee formal type_ref)
 * - pipeline_asm_emit_call_arg_begin_c / end_c / active_c (CALL arg depth)
 * - pipeline_asm_emit_set_func_index / func_index_c (current emit func index)
 * - pipeline_asm_emit_set_elf_ctx (current emit ElfCodegenCtx)
 * - pipeline_asm_emit_func_param_is_ptr_by_name_c (lookup *T param by name)
 * - pipeline_asm_var_is_emit_func_param_ptr_c (wrapper: VAR expr → name lookup)
 *
 * G.7: single product-mega asm emit context face — do not open a second
 * setter/getter family. All static globals stay in pipeline_glue.c
 * (g_pipeline_asm_emit_module / _func_index / _arena / _call_param_ty_ref /
 *  g_glue_emit_call_arg_depth / g_pipeline_asm_emit_dep_pipe /
 *  g_pipeline_asm_emit_elf_ctx) because they are also read directly by
 * pipeline_asm_emit_field_access.c (same-TU #include) for CALL-arg struct
 * pass-by-address classification.
 *
 * Static globals (defined in pipeline_glue.c L132-188, before this file's
 * #include site) — visible in this file via same TU:
 *  - g_pipeline_asm_emit_module          (struct ast_Module *)
 *  - g_pipeline_asm_emit_func_index      (int32_t, init -1)
 *  - g_pipeline_asm_emit_arena           (struct ast_ASTArena *)
 *  - g_pipeline_asm_emit_call_param_ty_ref (int32_t)
 *  - g_glue_emit_call_arg_depth          (int32_t)
 *  - g_pipeline_asm_emit_dep_pipe        (struct ast_PipelineDepCtx *)
 *  - g_pipeline_asm_emit_elf_ctx         (struct platform_elf_ElfCodegenCtx *)
 *
 * Forward decls in pipeline_glue.c retained:
 *  - L180: pipeline_asm_emit_call_arg_active_c (called by field_access.c
 *          #included at L2111, before this file's #include at L3191)
 *  - L186: pipeline_asm_emit_dep_pipe_c (called by vector_simd.c #included
 *          at L1940, before this file's #include at L3191)
 *
 * External dependencies (all declared elsewhere in pipeline_x.o TU):
 *  - pipeline_elf_pgo_hot_enabled / pipeline_elf_ctx_set_emit_hot
 *    / pipeline_asm_wpo_pgo_is_hot_func (PGO-Lite hot section switch)
 *  - pipeline_module_func_param_type_ref_for_name (module formal table)
 *  - pipeline_type_kind_ord_at (type kind ordinal)
 *  - pipeline_expr_kind_ord_at / pipeline_expr_var_name_len / _into
 *    (expr accessor domain)
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at L3191
 * (wave1180 include site; replaces former inline definitions L3192-3297).
 *
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV — context only (encoding in callees)
 *   · MACOS|ARM64 AAPCS64 — same context twin
 */

/**
 * Set the module currently being emitted by asm_codegen_ast_to_elf.
 * Why: backend.x main emit loop sets this once per function so FIELD_ACCESS
 *      on enum-typed VAR can resolve variant tags via the module enum sidecar
 *      (pipeline_expr_enum_namespace_field_tag) and CALL-arg struct layout
 *      can be looked up by field name (glue_field_access_field_type_ref_c).
 * Contract: NULL is allowed (clears the binding); no return value.
 */
void pipeline_asm_emit_set_module(struct ast_Module *m) {
  g_pipeline_asm_emit_module = m;
}

/**
 * Read the module currently being emitted.
 * Why: CALL-arg emit compares callee formal type_ref against the current
 *      module's struct layout table (glue_field_access_field_type_ref_c);
 *      backend_try_inline reads it for cross-module inlining decisions.
 * Contract: returns NULL when no module is bound (e.g. before first
 *           asm_codegen_ast_to_elf call).
 */
struct ast_Module *pipeline_asm_emit_module_ref_c(void) {
  return g_pipeline_asm_emit_module;
}

/**
 * Bind the current emit dep pipe (PipelineDepCtx).
 * Why: import-struct FIELD_ACCESS needs to walk dep_arenas/dep_modules for
 *      layout offset resolution when the struct is defined in an imported
 *      module (WPO-S3 cross_ret / SIMD field load). backend_try_inline also
 *      falls back to this when ctx->dep_pipe is NULL.
 * Contract: NULL is allowed (clears the binding).
 */
void pipeline_asm_emit_set_dep_pipe(struct ast_PipelineDepCtx *ctx) {
  g_pipeline_asm_emit_dep_pipe = ctx;
}

/**
 * Read the current emit dep pipe.
 * Why: backend_try_inline_dispatch / SIMD emit read this to resolve import
 *      struct layouts when ctx->dep_pipe is missing.
 * Contract: returns NULL when no dep pipe is bound.
 */
struct ast_PipelineDepCtx *pipeline_asm_emit_dep_pipe_c(void) {
  return g_pipeline_asm_emit_dep_pipe;
}

/**
 * Bind the AST arena currently being emitted.
 * Why: backend.x main emit loop sets this before each function so param
 *      homing can query expr kind (pipeline_asm_var_is_emit_func_param_ptr_c)
 *      without threading arena through every emit call.
 * Contract: NULL is allowed (clears the binding).
 */
void pipeline_asm_emit_set_arena(struct ast_ASTArena *arena) {
  g_pipeline_asm_emit_arena = arena;
}

/**
 * Set the callee formal type_ref corresponding to the current CALL argument
 * being emitted.
 * Why: f32 formal must be materialized as 32-bit IEEE bit-pattern (not the
 *      default 64-bit mov); struct formal >16B must be passed by address.
 *      type_ref is read by glue_field_access_call_arg_struct_by_addr_elf_c
 *      and glue_field_call_arg_try_load_agg_from_rax_elf_c.
 * Contract: 0 means "unknown" (fall back to layout scan by field name).
 */
void pipeline_asm_emit_set_call_param_type_ref(int32_t type_ref) {
  g_pipeline_asm_emit_call_param_ty_ref = type_ref;
}

/**
 * Increment CALL argument emit depth.
 * Why: when depth > 0, FIELD_ACCESS on a struct-typed VAR knows to leave the
 *      field address in rax (MEMORY class >16B) rather than loading the
 *      scalar value. backend_call_dispatch calls this before each arg emit.
 * Contract: unbalanced begin/end would misclassify subsequent emit; callers
 *           must pair begin/end in the same dispatch.
 */
void pipeline_asm_emit_call_arg_begin_c(void) {
  g_glue_emit_call_arg_depth++;
}

/**
 * Decrement CALL argument emit depth.
 * Why: closes the begin/end pair; depth 0 means scalar emit resumes.
 * Contract: clamps at 0 (no underflow); safe to call without matching begin
 *           (returns silently).
 */
void pipeline_asm_emit_call_arg_end_c(void) {
  if (g_glue_emit_call_arg_depth > 0)
    g_glue_emit_call_arg_depth--;
}

/**
 * Whether the current emit context is inside a CALL argument.
 * Why: glue_field_access_call_arg_struct_by_addr_elf_c and
 *      glue_field_call_arg_try_load_agg_from_rax_elf_c gate on this to decide
 *      whether to emit a by-address leave or a scalar load.
 * Contract: returns 1 when depth > 0, else 0.
 */
int32_t pipeline_asm_emit_call_arg_active_c(void) {
  return g_glue_emit_call_arg_depth > 0 ? 1 : 0;
}

/**
 * Set the current emit function index (backend.x main loop, per-function).
 * Why: g_pipeline_asm_emit_func_index is read by
 *      pipeline_asm_emit_func_param_is_ptr_by_name_c to look up the formal
 *      parameter table of the currently emitted function — needed when
 *      resolved_type is missing for a *T param VAR (load vs lea+offset).
 *      PGO-Lite: also flips .text / .text.hot section based on whether the
 *      function is in the PGO hot set (wave PGOLite hot section switch).
 * Contract: func_index must be in [0, mod->num_funcs); -1 clears the binding.
 *           PGO-Lite section switch only fires when elf_ctx + module are bound
 *           and pipeline_elf_pgo_hot_enabled() returns true.
 */
void pipeline_asm_emit_set_func_index(int32_t func_index) {
  g_pipeline_asm_emit_func_index = func_index;
  /* PGO-Lite: switch .text / .text.hot in lockstep with enc_label.
   * PLATFORM: SHARED — partial mega also walks this path. */
  if (g_pipeline_asm_emit_elf_ctx && g_pipeline_asm_emit_module && pipeline_elf_pgo_hot_enabled())
    pipeline_elf_ctx_set_emit_hot((uint8_t *)g_pipeline_asm_emit_elf_ctx,
                                  pipeline_asm_wpo_pgo_is_hot_func(g_pipeline_asm_emit_module, func_index));
}

/**
 * Bind the ElfCodegenCtx currently being written by asm_codegen_ast_to_elf.
 * Why: PGO-Lite emit section switch (pipeline_asm_emit_set_func_index) needs
 *      to call pipeline_elf_ctx_set_emit_hot on the live ctx; must be cleared
 *      (NULL) after emit to avoid dangling pointer use by later functions.
 * Contract: NULL is allowed (clears the binding, disables PGO-Lite switch).
 */
void pipeline_asm_emit_set_elf_ctx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  g_pipeline_asm_emit_elf_ctx = elf_ctx;
}

/**
 * Read the current emit function index.
 * Why: backend_try_inline reads this to skip inlining the function being
 *      currently emitted (would cause infinite recursion in mono path).
 * Contract: returns -1 when no function is bound.
 */
int32_t pipeline_asm_emit_func_index_c(void) {
  return g_pipeline_asm_emit_func_index;
}

/**
 * Look up whether a named formal of the currently emitted function is *T
 * (TYPE_PTR) by scanning the module formal table.
 * Why: backend.x X-path sometimes has resolved_type missing or non-PTR for
 *      a *T param VAR (especially in partial-module emit); this C helper
 *      scans module_func_param_type_ref_for_name to recover the *T bit so
 *      field/index emit can choose load (8B pointer) over lea+offset.
 * Contract: returns 1 when the named formal is TYPE_PTR (kind 9), 0 otherwise
 *           (including arena/mod null, vname null, vlen out of [1,127],
 *            func_index out of range, or formal not found).
 * Dependencies: pipeline_module_func_param_type_ref_for_name + pipeline_type_kind_ord_at.
 */
int32_t pipeline_asm_emit_func_param_is_ptr_by_name_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                      uint8_t *vname, int32_t vlen) {
  int32_t fi;
  int32_t param_ty;
  int32_t kind;
  if (!arena || !mod || !vname || vlen <= 0 || vlen > 127)
    return 0;
  fi = g_pipeline_asm_emit_func_index;
  if (fi < 0 || fi >= mod->num_funcs)
    return 0;
  param_ty = pipeline_module_func_param_type_ref_for_name(mod, fi, vname, vlen);
  if (param_ty <= 0)
    return 0;
  kind = pipeline_type_kind_ord_at(arena, param_ty);
  return (kind == 9) ? 1 : 0;
}

/**
 * Wrapper: determine whether a VAR expr_ref refers to a *T formal of the
 * currently emitted function.
 * Why: backend.x X-path calls this with (arena, mod, asm_ctx, var_expr_ref);
 *      resolves the var name via pipeline_expr_var_name_len/into then delegates
 *      to pipeline_asm_emit_func_param_is_ptr_by_name_c. asm_ctx is unused
 *      (kept for ABI compatibility with the .x call signature).
 * Contract: returns 1 when the VAR is a *T formal of the current function,
 *           0 otherwise (including null arena/mod, expr_ref out of range,
 *           expr kind != VAR (3), or name length out of [1,127]).
 * Dependencies: pipeline_expr_kind_ord_at + pipeline_expr_var_name_len/into +
 *               pipeline_asm_emit_func_param_is_ptr_by_name_c (same file).
 */
int32_t pipeline_asm_var_is_emit_func_param_ptr_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                  uint8_t *asm_ctx, int32_t var_expr_ref) {
  uint8_t vname[128];
  int32_t vlen;
  (void)asm_ctx;
  if (!arena || !mod || var_expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, var_expr_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  if (vlen <= 0 || vlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, var_expr_ref, vname);
  return pipeline_asm_emit_func_param_is_ptr_by_name_c(arena, mod, vname, vlen);
}
