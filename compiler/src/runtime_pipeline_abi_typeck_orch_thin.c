/*
 * Thin pure: wave285 pipeline_typeck_orch Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE285_TYPECK_ORCH_ALWAYS product faces (typeck_x_ast*_c thin +
 * layout glue size/align/zero_padding). Cold WEAK twins (soft_suppress /
 * dep_ctx / dep_prerun) stay seed-only under !FROM_X — pure owns strong.
 *
 * Independent C thin (Darwin additive-leaf rule). No file-local BSS.
 * Callees via typeck_x.o / prior Cap thins (void* faces).
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc typeck_orch Cap residual leave.
 */

/* XLANG_PABI_TYPECK_ORCH_THIN_BEGIN */

#include <stdint.h>
#include <stddef.h>
#include <stdio.h>

/* Prefer void* faces (match pure / earlier ALWAYS blocks; dual-decl safe). */
extern int32_t typeck_x_ast_check_one_func(void *module, void *arena, void *ctx, int32_t func_idx);
extern int32_t typeck_x_ast_impl(void *module, void *arena, void *ctx);
extern int32_t typeck_x_ast_library(void *module, void *arena, void *ctx);
extern int32_t typeck_x_ast(void *module, void *arena, void *ctx);
extern int32_t typeck_typeck_x_ast_library(void *module, void *arena, void *ctx);
extern int32_t typeck_typeck_struct_layout_metrics(void *module, void *arena, int32_t li, int32_t depth,
                                                    int32_t want_align, int32_t *out_size, int32_t *out_align);
extern int32_t pipeline_module_num_struct_layouts_at(void *m);
extern void pipeline_typeck_patch_all_body_parent_links_c(void *module, void *arena);

/**
 * Product-mega C face for per-function body typeck.
 * Thin → typeck_x_ast_check_one_func (wave684+ generic body check).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_x_ast_check_one_func_c(void *module, void *arena, void *ctx, int32_t func_idx) {
  return typeck_x_ast_check_one_func(module, arena, ctx, func_idx);
}

/**
 * Product-mega C face for whole-module typeck (main preconditions + loop).
 * Thin → typeck_x_ast_impl.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_x_ast_impl_c(void *module, void *arena, void *ctx) {
  return typeck_x_ast_impl(module, arena, ctx);
}

/**
 * Product-mega C face for library-module typeck (no main).
 * Thin → typeck_x_ast_library.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_x_ast_library_c(void *module, void *arena, void *ctx) {
  return typeck_x_ast_library(module, arena, ctx);
}

/**
 * Product-mega C face for whole-module typeck entry.
 * Thin → typeck_x_ast.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_x_ast_c(void *module, void *arena, void *ctx) {
  return typeck_x_ast(module, arena, ctx);
}

/**
 * Validate all struct layouts have zero padding waste (host-cc era glue).
 * Iterates layout metrics; pure product path prefers typeck.x face via
 * pipeline_typeck_validate_struct_layouts_zero_padding_c.
 * PLATFORM: SHARED.
 */
int32_t typeck_validate_struct_layouts_zero_padding_glue(void *module, void *arena) {
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
 * PLATFORM: SHARED — typeck.x / pure call as extern (void* ABI).
 */
int32_t typeck_x_type_size_from_layout_glue(void *module, void *arena, int32_t li, int32_t depth) {
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
 * PLATFORM: SHARED — typeck.x calls as extern.
 */
int32_t typeck_x_type_align_from_layout_glue(void *module, void *arena, int32_t li, int32_t depth) {
  int32_t z2 = 0;
  int32_t al2 = 1;
  if (li < 0)
    return 1;
  if (typeck_typeck_struct_layout_metrics(module, arena, li, depth, 0, &z2, &al2) != 0)
    return 1;
  return al2 > 0 ? al2 : 1;
}

/* XLANG_PABI_TYPECK_ORCH_THIN_END */
