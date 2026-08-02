/**
 * pipeline_typeck_orch.c — typeck orchestration entry cluster (wave1187).
 *
 * Purpose: Colocate the top-level typeck orchestration functions that drive
 * whole-module type checking. These functions form the entry path:
 *   pipeline_typeck_x_ast_c → _impl_c → _check_one_func_c → check_block_c
 * plus the library variant (_library_c), dep prerun (_dep_prerun_module_c),
 * and the layout-validation glue helpers used by impl/library paths.
 *
 * The XLANG_WEAK standalone entries (pipeline_typeck_diag_soft_suppress_set/get,
 * pipeline_typeck_set_dep_ctx/get_dep_ctx, pipeline_typeck_dep_prerun_module_c)
 * allow product pure code (runtime_pipeline_abi.x) to provide strong-symbol
 * overrides; the cold fallbacks here serve non-PREFER / pipeline.x thin links.
 *
 * Migration source: pipeline_glue.c L6953-L7299 (same-TU #include).
 * PLATFORM: SHARED — no platform-specific code; all deps are extern.
 *
 * wave1187 G.7: typeck orchestration cluster (10 fns + 2 statics + 3 XLANG_WEAK).
 */

/* extern forward declarations — definitions visible via same-TU #include chain
 * (pipeline_typeck_check_block.c, ast_pool_module_func.c, ast_pool_dep_ctx.c,
 *  pipeline_typeck_method_call.c, pipeline_asm_emit_struct_lit.c, ast_pool.c,
 *  ast_pool_struct_layout.c) or earlier in pipeline_glue.c itself. */
extern void pipeline_typeck_linear_reset_c(void);
extern int32_t pipeline_module_func_num_generic_params_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_is_extern_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t fi);
extern void pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t fi, uint8_t *out);
extern int32_t pipeline_typeck_check_block_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                              int32_t block_ref, int32_t return_type_ref,
                                              struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_func_body_has_implicit_return_tail_c(struct ast_ASTArena *arena,
                                                                     int32_t body_ref);
extern int32_t pipeline_typeck_validate_struct_layouts_zero_padding_c(struct ast_Module *module,
                                                                       struct ast_ASTArena *arena);
extern void pipeline_typeck_patch_all_body_parent_links_c(struct ast_Module *module,
                                                           struct ast_ASTArena *arena);
extern void pipeline_typeck_set_entry_module_for_dep_map_c(struct ast_Module *module);
extern void pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t pipeline_module_main_func_index(struct ast_Module *m);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t ref);
extern int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *m);
extern int32_t pipeline_module_num_funcs(struct ast_Module *m);
extern int32_t pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi);
extern int32_t typeck_typeck_struct_layout_metrics(struct ast_Module *module,
                                                    struct ast_ASTArena *arena, int32_t li,
                                                    int32_t depth, int32_t want_align,
                                                    int32_t *out_size, int32_t *out_align);
extern void driver_diagnostic_typeck_func_fail(int32_t fi, uint8_t *name, int32_t name_len,
                                                int32_t code);
extern char *link_abi_getenv(const char *name);
extern int32_t typeck_typeck_x_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);

/**
 * typeck.x::typeck_x_ast_check_one_func C delegate.
 *
 * Why: typeck.x typeck_x_ast_check_one_func delegates to C for the
 * per-function body type-check loop. When typeck.o is linked, X strong
 * symbol overrides; otherwise glue calls pipeline_typeck_check_block_c.
 *
 * Contract: module/arena/ctx must be non-null; func_idx must be valid.
 * Returns 0 on success, -5 on check_block fail, -6 on implicit return tail fail.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_x_ast_check_one_func_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                struct ast_PipelineDepCtx *ctx, int32_t func_idx) {
  int32_t body_ref;
  int32_t ret_ty_ref;
  uint8_t fn_name_buf[128];
  int32_t fn_name_len;

  if (!module || !arena || !ctx)
    return 0;
  pipeline_typeck_linear_reset_c();
  if (pipeline_module_func_num_generic_params_at(module, func_idx) > 0)
    return 0;
  body_ref = pipeline_module_func_body_ref_at(module, func_idx);
  if (ast_ref_is_null(body_ref) || pipeline_module_func_is_extern_at(module, func_idx) != 0)
    return 0;
  ret_ty_ref = pipeline_module_func_return_type_at(module, func_idx);
  if (pipeline_typeck_check_block_c(module, arena, body_ref, ret_ty_ref, ctx) != 0) {
    fn_name_len = pipeline_module_func_name_len_at(module, func_idx);
    pipeline_asm_module_func_name_copy64(module, func_idx, fn_name_buf);
    driver_diagnostic_typeck_func_fail(func_idx, fn_name_buf, fn_name_len, -5);
    return -5;
  }
  if (!ast_ref_is_null(ret_ty_ref)) {
    int32_t rt_kind = pipeline_type_kind_ord_at(arena, ret_ty_ref);
    if (rt_kind != (int32_t)ast_TypeKind_TYPE_VOID &&
        pipeline_typeck_func_body_has_implicit_return_tail_c(arena, body_ref) != 0) {
      fn_name_len = pipeline_module_func_name_len_at(module, func_idx);
      pipeline_asm_module_func_name_copy64(module, func_idx, fn_name_buf);
      driver_diagnostic_typeck_func_fail(func_idx, fn_name_buf, fn_name_len, -6);
      return -6;
    }
  }
  return 0;
}

/**
 * typeck.x::typeck_x_ast_impl C delegate.
 *
 * Why: Iterates all functions with bodies in the module and type-checks each.
 * Self-contained glue while-loop (no typeck.o needed). Validates struct layouts,
 * patches parent links, sets entry module for dep map, then loops functions.
 *
 * Contract: module/arena/ctx non-null; main func must have body and return type.
 * Returns 0 on success; -1/-2/-3/-4 on main-func precondition fail; -5/-6/-7 on
 * check/implicit-return/layout-validation fail.
 * PLATFORM: SHARED — main may return i32/i64 or void (implicit exit 0).
 */
int32_t pipeline_typeck_x_ast_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                      struct ast_PipelineDepCtx *ctx) {
  int32_t mi;
  int32_t ret_kind;
  int32_t i;

  if (!module || !arena || !ctx)
    return -2;
  mi = pipeline_module_main_func_index(module);
  if (pipeline_module_func_is_extern_at(module, mi) != 0 &&
      ast_ref_is_null(pipeline_module_func_body_ref_at(module, mi)))
    return -1;
  if (ast_ref_is_null(pipeline_module_func_body_ref_at(module, mi)) &&
      ast_ref_is_null(pipeline_module_func_body_expr_ref_at(module, mi)))
    return -2;
  if (ast_ref_is_null(pipeline_module_func_return_type_at(module, mi)))
    return -3;
  /* PLATFORM: SHARED — main may return i32/i64 or void (implicit exit 0; see typeck.x). */
  ret_kind = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, mi));
  if (ret_kind != (int32_t)ast_TypeKind_TYPE_I32 && ret_kind != (int32_t)ast_TypeKind_TYPE_I64
      && ret_kind != (int32_t)ast_TypeKind_TYPE_VOID)
    return -4;
  if (pipeline_typeck_validate_struct_layouts_zero_padding_c(module, arena) != 0)
    return -7;
  pipeline_typeck_patch_all_body_parent_links_c(module, arena);
  pipeline_typeck_set_entry_module_for_dep_map_c(module);
  i = 0;
  while (i < module->num_funcs) {
    int32_t body_ref;
    int32_t ret_ty_ref;
    uint8_t fn_name_buf[128];
    int32_t fn_name_len;
    int32_t num_generic_params;

    pipeline_dep_ctx_set_current_func_index(ctx, i);
    pipeline_typeck_linear_reset_c();
    /* wave684 Cap residual: typecheck generic bodies (was skip num_generic_params). */
    num_generic_params = pipeline_module_func_num_generic_params_at(module, i);
    (void)num_generic_params;
    body_ref = pipeline_module_func_body_ref_at(module, i);
    if (!ast_ref_is_null(body_ref) && pipeline_module_func_is_extern_at(module, i) == 0) {
      ret_ty_ref = pipeline_module_func_return_type_at(module, i);
      if (pipeline_typeck_check_block_c(module, arena, body_ref, ret_ty_ref, ctx) != 0) {
        fn_name_len = pipeline_module_func_name_len_at(module, i);
        pipeline_asm_module_func_name_copy64(module, i, fn_name_buf);
        if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
          fn_name_buf[fn_name_len > 0 && fn_name_len < 64 ? fn_name_len : 0] = '\0';
          fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] library typeck fail i=%d name=%s\n", (int)i,
                  fn_name_len > 0 ? (char *)fn_name_buf : "?");
          fflush(stderr);
        }
        driver_diagnostic_typeck_func_fail(i, fn_name_buf, fn_name_len, -5);
        pipeline_dep_ctx_set_current_func_index(ctx, -1);
        return -5;
      }
      if (!ast_ref_is_null(ret_ty_ref)) {
        int32_t rt_kind;

        rt_kind = pipeline_type_kind_ord_at(arena, ret_ty_ref);
        if (rt_kind != (int32_t)ast_TypeKind_TYPE_VOID &&
            pipeline_typeck_func_body_has_implicit_return_tail_c(arena, body_ref) != 0) {
          fn_name_len = pipeline_module_func_name_len_at(module, i);
          pipeline_asm_module_func_name_copy64(module, i, fn_name_buf);
          driver_diagnostic_typeck_func_fail(i, fn_name_buf, fn_name_len, -6);
          pipeline_dep_ctx_set_current_func_index(ctx, -1);
          return -6;
        }
      }
    }
    pipeline_dep_ctx_set_current_func_index(ctx, -1);
    i = i + 1;
  }
  return 0;
}

/**
 * typeck.x::typeck_x_ast_library C delegate.
 *
 * Why: Library modules have no main function; this variant skips main-func
 * preconditions and directly iterates all functions for type checking.
 * Used by dep prerun and library-only compilation paths.
 *
 * Contract: module/arena/ctx non-null. Returns 0 on success; -5/-6/-7 on fail.
 * PLATFORM: SHARED — freestanding co-emit may have incomplete dep slots.
 */
int32_t pipeline_typeck_x_ast_library_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                         struct ast_PipelineDepCtx *ctx) {
  int32_t i;

  if (!module || !arena || !ctx) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] typeck_x_ast_library_c null arg m=%p a=%p ctx=%p\n", (void *)module,
              (void *)arena, (void *)ctx);
    return -5;
  }
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] enter library_c module->num_funcs=%d pipeline_num=%d\n",
            (int)module->num_funcs, (int)pipeline_module_num_funcs(module));
  if (pipeline_typeck_validate_struct_layouts_zero_padding_c(module, arena) != 0)
    return -7;
  pipeline_typeck_patch_all_body_parent_links_c(module, arena);
  pipeline_typeck_set_entry_module_for_dep_map_c(module);
  i = 0;
  while (i < module->num_funcs) {
    int32_t body_ref;
    int32_t ret_ty_ref;
    uint8_t fn_name_buf[128];
    int32_t fn_name_len;
    int32_t num_generic_params;

    pipeline_dep_ctx_set_current_func_index(ctx, i);
    pipeline_typeck_linear_reset_c();
    /* wave684 Cap residual: typecheck generic bodies (was skip num_generic_params). */
    num_generic_params = pipeline_module_func_num_generic_params_at(module, i);
    (void)num_generic_params;
    body_ref = pipeline_module_func_body_ref_at(module, i);
    if (!ast_ref_is_null(body_ref) && pipeline_module_func_is_extern_at(module, i) == 0) {
      ret_ty_ref = pipeline_module_func_return_type_at(module, i);
      if (pipeline_typeck_check_block_c(module, arena, body_ref, ret_ty_ref, ctx) != 0) {
        fn_name_len = pipeline_module_func_name_len_at(module, i);
        pipeline_asm_module_func_name_copy64(module, i, fn_name_buf);
        if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
          fn_name_buf[fn_name_len > 0 && fn_name_len < 64 ? fn_name_len : 0] = '\0';
          fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] library typeck fail i=%d name=%s\n", (int)i,
                  fn_name_len > 0 ? (char *)fn_name_buf : "?");
          fflush(stderr);
        }
        driver_diagnostic_typeck_func_fail(i, fn_name_buf, fn_name_len, -5);
        pipeline_dep_ctx_set_current_func_index(ctx, -1);
        return -5;
      }
      if (!ast_ref_is_null(ret_ty_ref)) {
        int32_t rt_kind;

        rt_kind = pipeline_type_kind_ord_at(arena, ret_ty_ref);
        if (rt_kind != (int32_t)ast_TypeKind_TYPE_VOID &&
            pipeline_typeck_func_body_has_implicit_return_tail_c(arena, body_ref) != 0) {
          fn_name_len = pipeline_module_func_name_len_at(module, i);
          pipeline_asm_module_func_name_copy64(module, i, fn_name_buf);
          driver_diagnostic_typeck_func_fail(i, fn_name_buf, fn_name_len, -6);
          pipeline_dep_ctx_set_current_func_index(ctx, -1);
          return -6;
        }
      }
    }
    pipeline_dep_ctx_set_current_func_index(ctx, -1);
    i = i + 1;
  }
  return 0;
}

/**
 * Soft-suppress XT001 while dep prerun tries full library typeck then
 * light-falls-back.
 *
 * Why: PLATFORM: SHARED — freestanding co-emit one_ctx often has incomplete
 * dep slots (ndep=1 empty); full typeck fails on import METHOD_CALL
 * (heap.default_alloc / mem.mem_set) then light fallback continues.
 * Emitting XT001 for that exploratory fail is product noise.
 * Entry / final typeck still report hard XT001 (suppress cleared after
 * prerun attempt).
 *
 * wave90: product pure owns pipeline_typeck_diag_soft_suppress_set / _get
 * (runtime_pipeline_abi.x BSS). Keep XLANG_WEAK cold fallback for links
 * without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
static int32_t g_pipeline_typeck_diag_soft_suppress = 0;

XLANG_WEAK void pipeline_typeck_diag_soft_suppress_set(int32_t v) {
  g_pipeline_typeck_diag_soft_suppress = v ? 1 : 0;
}

XLANG_WEAK int32_t pipeline_typeck_diag_soft_suppress_get(void) {
  return g_pipeline_typeck_diag_soft_suppress;
}

/**
 * wave91: product pure owns pipeline_typeck_set_dep_ctx / get_dep_ctx
 * (runtime_pipeline_abi.x LP64 BSS). Keep XLANG_WEAK cold fallback for links
 * without pure pipeline_abi / PREFER hybrid. Independent cold BSS (not shared
 * with pure).
 * PLATFORM: SHARED — ELF weak overridden by pure; ast_pool enum fallback calls get.
 */
static struct ast_PipelineDepCtx *g_pipeline_typeck_dep_ctx_cold = 0;

XLANG_WEAK void pipeline_typeck_set_dep_ctx(struct ast_PipelineDepCtx *ctx) {
  g_pipeline_typeck_dep_ctx_cold = ctx;
}

XLANG_WEAK struct ast_PipelineDepCtx *pipeline_typeck_get_dep_ctx(void) {
  return g_pipeline_typeck_dep_ctx_cold;
}

/**
 * dep prerun typeck: prefer full library typeck (writes CALL resolved_func_index
 * for overload mangle).
 *
 * Why: -E co-emit only typecks entry; dep if only light typeck then body
 *   alloc(al,size) has no resolve, codegen emits raw std_heap_alloc which
 *   mismatches defined std_heap_alloc_Allocator_usize.
 * Large-library full fail falls back to padding+parent_link (matches old
 * behavior, avoids codegen.x etc EMIT_HEAVY炸 prerun).
 *
 * wave89: product pure owns pipeline_typeck_dep_prerun_module_c
 * (runtime_pipeline_abi.x). Keep XLANG_WEAK cold fallback for links without
 * pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure; same steps as pure orch.
 */
XLANG_WEAK int32_t pipeline_typeck_dep_prerun_module_c(struct ast_Module *module,
                                                                  struct ast_ASTArena *arena,
                                                                  struct ast_PipelineDepCtx *ctx) {
  int32_t tc;
  if (!module || !arena || !ctx)
    return -5;
  pipeline_typeck_set_dep_ctx(ctx);
  /* Suppress soft XT001 for exploratory full typeck; light fallback is intentional. */
  pipeline_typeck_diag_soft_suppress_set(1);
  tc = typeck_typeck_x_ast_library(module, arena, ctx);
  pipeline_typeck_diag_soft_suppress_set(0);
  if (tc == 0)
    return 0;
  if (link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep prerun full typeck rc=%d, light fallback\n", (int)tc);
  if (pipeline_typeck_validate_struct_layouts_zero_padding_c(module, arena) != 0)
    return -7;
  pipeline_typeck_patch_all_body_parent_links_c(module, arena);
  return 0;
}

/**
 * typeck.x::typeck_x_ast C delegate.
 *
 * Why: Entry point for whole-module type checking. Validates main function
 * index then delegates to pipeline_typeck_x_ast_impl_c.
 *
 * Contract: module non-null; main func index must be valid.
 * Returns impl_c result on success; -10/-11 on main-index precondition fail.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_x_ast_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                 struct ast_PipelineDepCtx *ctx) {
  int32_t mi;

  if (!module)
    return -10;
  mi = pipeline_module_main_func_index(module);
  if (mi < 0)
    return -10;
  if (mi >= module->num_funcs)
    return -11;
  return pipeline_typeck_x_ast_impl_c(module, arena, ctx);
}

/**
 * Validate all struct layouts have zero padding waste.
 *
 * Why: typeck.x typeck_validate_struct_layouts_zero_padding iterates struct
 * layouts and checks size/align metrics via typeck_typeck_struct_layout_metrics.
 * This glue wrapper provides the C-callable interface.
 *
 * Contract: module/arena non-null. Returns 0 on success, -1 on any layout fail.
 * PLATFORM: SHARED.
 */
int32_t typeck_validate_struct_layouts_zero_padding_glue(struct ast_Module *module, struct ast_ASTArena *arena) {
  int32_t li;
  int32_t nsl;
  if (!module || !arena)
    return -1;
  nsl = pipeline_module_num_struct_layouts_at(module);
  for (li = 0; li < nsl; li++) {
    int32_t dz = 0;
    int32_t da = 1;
    if (typeck_typeck_struct_layout_metrics(module, arena, li, 0, 1, &dz, &da) != 0)
      return -1;
  }
  return 0;
}

/**
 * Compute TYPE_NAMED size from struct_layout when layout exists.
 *
 * Why: typeck.x typeck_x_type_size uses struct_layout metrics for TYPE_NAMED.
 * C stack out params; .x check_block must not pass &local.
 *
 * Contract: li >= 0 for valid layout; returns 0 for invalid index.
 * PLATFORM: SHARED.
 */
int32_t typeck_x_type_size_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
    int32_t depth) {
  int32_t z2 = 0;
  int32_t al2 = 1;
  if (li < 0)
    return 0;
  if (typeck_typeck_struct_layout_metrics(module, arena, li, depth, 0, &z2, &al2) != 0)
    return 0;
  return z2;
}

/**
 * Compute TYPE_NAMED align from struct_layout when layout exists.
 *
 * Why: typeck.x typeck_x_type_align ko==8 branch uses struct_layout metrics.
 * Matches typeck.x semantics for TYPE_NAMED alignment resolution.
 *
 * Contract: li >= 0 for valid layout; returns 1 for invalid index.
 * PLATFORM: SHARED.
 */
int32_t typeck_x_type_align_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
    int32_t depth) {
  int32_t z2 = 0;
  int32_t al2 = 1;
  if (li < 0)
    return 1;
  if (typeck_typeck_struct_layout_metrics(module, arena, li, depth, 0, &z2, &al2) != 0)
    return 1;
  return al2 > 0 ? al2 : 1;
}
