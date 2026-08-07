/**
 * pipeline_typeck_orch.c — typeck orchestration Cap residual thin
 * (BC 8.3.1 wave228 pure leave).
 *
 * wave228 G.7 pure leave: product-mega typeck_x_ast_* dual bodies retired
 * from host-cc residual. Live orchestration authority is typeck.x
 * (typeck_x_ast / typeck_x_ast_impl / typeck_x_ast_library /
 * typeck_x_ast_check_one_func + check_all_funcs_loop). Cap residual keeps:
 *   1. Thin product faces pipeline_typeck_x_ast{,_impl,_library,_check_one_func}_c
 *      → typeck_x.o (ABI face names; product path already uses typeck_typeck_x_ast*)
 *   2. XLANG_WEAK cold fallbacks: diag soft-suppress, set/get_dep_ctx,
 *      dep_prerun_module (pure runtime_pipeline_abi owns strong when linked)
 *   3. Layout glue helpers (typeck_validate_struct_layouts_zero_padding_glue,
 *      typeck_x_type_{size,align}_from_layout_glue) + XLANG_WEAK zero-padding face
 *
 * Dual-export ban: do NOT re-open a second whole-module walker here or in
 * runtime_pipeline_abi; typeck.x is single authority (trait impl completeness,
 * main generic gate, pipe markers — residual C walker had drifted).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c.
 *
 * PLATFORM: SHARED — freestanding typeck faces via typeck_x.o link.
 */

/* Live orchestration authority in typeck_x.o (typeck.x exports). */
extern int32_t typeck_x_ast_check_one_func(struct ast_Module *module, struct ast_ASTArena *arena,
                                           struct ast_PipelineDepCtx *ctx, int32_t func_idx);
extern int32_t typeck_x_ast_impl(struct ast_Module *module, struct ast_ASTArena *arena,
                                 struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_x_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                    struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_x_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                            struct ast_PipelineDepCtx *ctx);

/* Link-alias / seed surfaces still call typeck_typeck_x_ast_library. */
extern int32_t typeck_typeck_x_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                           struct ast_PipelineDepCtx *ctx);

extern int32_t typeck_typeck_struct_layout_metrics(struct ast_Module *module,
                                                    struct ast_ASTArena *arena, int32_t li,
                                                    int32_t depth, int32_t want_align,
                                                    int32_t *out_size, int32_t *out_align);
extern int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *m);
extern int32_t pipeline_typeck_validate_struct_layouts_zero_padding_c(struct ast_Module *module,
                                                                       struct ast_ASTArena *arena);
extern void pipeline_typeck_patch_all_body_parent_links_c(struct ast_Module *module,
                                                           struct ast_ASTArena *arena);

/**
 * Product-mega C face for per-function body typeck.
 * Thin → typeck_x_ast_check_one_func (wave684+ generic body check).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_x_ast_check_one_func_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                struct ast_PipelineDepCtx *ctx, int32_t func_idx) {
  return typeck_x_ast_check_one_func(module, arena, ctx, func_idx);
}

/**
 * Product-mega C face for whole-module typeck (main preconditions + loop).
 * Thin → typeck_x_ast_impl (trait impl completeness + void main + pipe markers).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_x_ast_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                      struct ast_PipelineDepCtx *ctx) {
  return typeck_x_ast_impl(module, arena, ctx);
}

/**
 * Product-mega C face for library-module typeck (no main).
 * Thin → typeck_x_ast_library.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_x_ast_library_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                         struct ast_PipelineDepCtx *ctx) {
  return typeck_x_ast_library(module, arena, ctx);
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
 * Product-mega C face for whole-module typeck entry.
 * Thin → typeck_x_ast.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_x_ast_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                 struct ast_PipelineDepCtx *ctx) {
  return typeck_x_ast(module, arena, ctx);
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

/* wave1282 G.7: XLANG_WEAK cold fallback for zero-padding validate migrated
 * from pipeline_glue.c. Product pure (runtime_pipeline_abi) owns the strong
 * symbol; this weak path uses typeck_validate_struct_layouts_zero_padding_glue
 * when pure is not linked. Colocated with typeck orch (sole same-TU callers
 * of the public face). PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_typeck_validate_struct_layouts_zero_padding_c(
    struct ast_Module *module, struct ast_ASTArena *arena) {
  return typeck_validate_struct_layouts_zero_padding_glue(module, arena);
}
