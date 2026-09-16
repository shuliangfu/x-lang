/*
 * Thin pure: wave285/293 pipeline_typeck_orch Cap residual — layout glue only.
 * Product rename shims (typeck_x_ast*_c) live in
 * runtime_pipeline_abi_typeck_orch_thin.x (wave293 C→.x PREFER_ASM).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE285_TYPECK_ORCH_ALWAYS layout glue faces.
 * ensure: C inject this leaf, then .x overlay shims (stamp).
 * PLATFORM: SHARED host-cc typeck_orch layout glue Cap residual leave.
 */

/* XLANG_PABI_TYPECK_ORCH_LAYOUT_GLUE_THIN_BEGIN */

#include <stdint.h>
#include <stddef.h>

extern int32_t typeck_typeck_struct_layout_metrics(void *module, void *arena, int32_t li, int32_t depth,
                                                    int32_t want_align, int32_t *out_size, int32_t *out_align);
extern int32_t pipeline_module_num_struct_layouts_at(void *m);

/**
 * Validate all struct layouts have zero padding waste (host-cc era glue).
 * PLATFORM: SHARED — seed ALWAYS residual (wave285/293 C thin).
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

/* XLANG_PABI_TYPECK_ORCH_LAYOUT_GLUE_THIN_END */
