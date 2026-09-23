/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
/* Cold WEAK twins — pure owns strong under prefer rest / hybrid. */

static int32_t g_w285_typeck_diag_soft_suppress = 0;
static void *g_w285_typeck_dep_ctx_cold = 0;

XLANG_WEAK void pipeline_typeck_diag_soft_suppress_set(int32_t v) {
  g_w285_typeck_diag_soft_suppress = v ? 1 : 0;
}

XLANG_WEAK int32_t pipeline_typeck_diag_soft_suppress_get(void) {
  return g_w285_typeck_diag_soft_suppress;
}

XLANG_WEAK void pipeline_typeck_set_dep_ctx(void *ctx) {
  g_w285_typeck_dep_ctx_cold = ctx;
}

XLANG_WEAK void *pipeline_typeck_get_dep_ctx(void) {
  return g_w285_typeck_dep_ctx_cold;
}

XLANG_WEAK int32_t pipeline_typeck_validate_struct_layouts_zero_padding_c(void *module, void *arena) {
  return typeck_validate_struct_layouts_zero_padding_glue(module, arena);
}

/**
 * dep prerun typeck cold fallback (wave89 pure owns strong).
 * Prefer full library typeck; light-fallback padding+parent_link.
 * PLATFORM: SHARED — ELF weak overridden by pure when linked.
 */
XLANG_WEAK int32_t pipeline_typeck_dep_prerun_module_c(void *module, void *arena, void *ctx) {
  int32_t tc;
  if (!module || !arena || !ctx)
    return -5;
  pipeline_typeck_set_dep_ctx(ctx);
  pipeline_typeck_diag_soft_suppress_set(1);
  tc = typeck_typeck_x_ast_library(module, arena, ctx);
  pipeline_typeck_diag_soft_suppress_set(0);
  if (tc == 0)
    return 0;
  /* Class AV: Cap DEBUG note retired. */
  if (pipeline_typeck_validate_struct_layouts_zero_padding_c(module, arena) != 0)
    return -7;
  pipeline_typeck_patch_all_body_parent_links_c(module, arena);
  return 0;
}
