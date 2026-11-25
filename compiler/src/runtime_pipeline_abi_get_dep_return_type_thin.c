/*
 * Host-gcc twin of get_dep_return_type_in_caller_arena.
 * Root (s44 SI check T001 ok_i32): typool/gcc of this face always overwrites
 *   the ctx dep arena with driver_dep_arena_buf when that buffer is non-null,
 *   skipping the ctx_dm == drv_dm (and empty-ctx) guard in the .x authority.
 * gdb: result.ok_i32 is func_ix=22, unbound typeref=67, but get_dep(dep=2, 67)
 *   used driver arena (num_types at +0 = 30) instead of ctx arena, so typeref
 *   67 skipped the TYPE_NAMED arm and dep_return_type_to_caller_arena returned 0.
 *   option.some_i32 / unwrap_or_i32 still mapped (their driver slot matched).
 *   Short name get_dep_return_type_in_caller_arena JMP's a xor-eax stub;
 *   typool method_call / overload call the typool-mangled live face.
 * Fold allowlist: short, typool-mangled, and typeck_ prefixed stub names.
 * Bind g_typeck_entry_module_for_dep_map at the proven BSS VA (no .refptr).
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>

#define G_TYPECK_ENTRY_MODULE (*(uint8_t **)(uintptr_t)0x1497ee0c8ULL)

uint8_t *typeck_scratch64_slot(int32_t i);
uint8_t *pipeline_dep_ctx_arena_at(uint8_t *ctx, int32_t i);
uint8_t *pipeline_get_dep_arena_slot(int32_t i);
uint8_t *typeck_driver_dep_arena_buf(int32_t i);
uint8_t *pipeline_dep_ctx_module_at(uint8_t *ctx, int32_t i);
uint8_t *typeck_driver_dep_module_buf(int32_t i);
int32_t pipeline_module_num_funcs(uint8_t *mod);
int32_t pipeline_dep_ctx_ndep(uint8_t *ctx);
int32_t pipeline_type_kind_ord_at(uint8_t *arena, int32_t type_ref);
int32_t pipeline_type_named_name_into(uint8_t *arena, int32_t type_ref, uint8_t *out);
int32_t typeck_map_import_binding_named_to_caller(uint8_t *entry_mod, int32_t dep_ix,
                                                 uint8_t *caller_arena, uint8_t *nm, int32_t nlen);
int32_t pipeline_type_elem_ref_at(uint8_t *arena, int32_t type_ref);
int32_t typeck_find_or_alloc_ptr_type_ref(uint8_t *arena, int32_t elem_ref);
int32_t typeck_find_or_alloc_linear_type_ref(uint8_t *arena, int32_t elem_ref);
int32_t pipeline_type_region_label_len_at(uint8_t *arena, int32_t type_ref);
int32_t pipeline_type_region_label_into(uint8_t *arena, int32_t type_ref, uint8_t *out);
int32_t pipeline_type_find_or_alloc_slice(uint8_t *arena, int32_t elem_ref, uint8_t *rlab, int32_t rlen);
int32_t typeck_dep_return_type_to_caller_arena(uint8_t *dep_arena, int32_t dep_return_type_ref,
                                               uint8_t *caller_arena);

static int32_t get_dep_return_type_in_caller_arena_impl(int32_t from_dep_index,
                                                       int32_t dep_return_type_ref,
                                                       uint8_t *caller_arena,
                                                       uint8_t *ctx) {
  uint8_t *dep_arena;
  uint8_t *alt_arena;
  uint8_t *ctx_dm;
  uint8_t *drv_dm;
  int32_t kind;
  int32_t nlen;
  uint8_t *nm_buf;
  int32_t ord_named;
  int32_t ndep_ret;
  int32_t ord_ptr_gd;
  int32_t ord_slice_gd;
  int32_t ord_linear_gd;
  int32_t elem_gd;
  int32_t inner_gd;
  int32_t rlen_gd;
  uint8_t *rbuf_gd;
  int32_t nt;

  nm_buf = typeck_scratch64_slot(0);
  ord_named = 8;
  if (from_dep_index < 0 || ctx == 0) {
    return 0;
  }
  dep_arena = pipeline_dep_ctx_arena_at(ctx, from_dep_index);
  if (dep_arena == 0) {
    dep_arena = pipeline_get_dep_arena_slot(from_dep_index);
  }
  alt_arena = typeck_driver_dep_arena_buf(from_dep_index);
  if (alt_arena != 0) {
    ctx_dm = pipeline_dep_ctx_module_at(ctx, from_dep_index);
    drv_dm = typeck_driver_dep_module_buf(from_dep_index);
    if (dep_arena == 0 || ctx_dm == 0 || ctx_dm == drv_dm) {
      dep_arena = alt_arena;
    } else if (pipeline_module_num_funcs(ctx_dm) == 0 && drv_dm != 0
               && pipeline_module_num_funcs(drv_dm) > 0) {
      dep_arena = alt_arena;
    }
  }
  if (dep_arena == 0) {
    return 0;
  }
  ndep_ret = pipeline_dep_ctx_ndep(ctx);
  if (from_dep_index >= ndep_ret) {
    if (pipeline_dep_ctx_module_at(ctx, from_dep_index) == 0) {
      return 0;
    }
  }
  if (G_TYPECK_ENTRY_MODULE != 0 && dep_return_type_ref > 0) {
    nt = *(int32_t *)dep_arena;
    if (dep_return_type_ref <= nt) {
      kind = pipeline_type_kind_ord_at(dep_arena, dep_return_type_ref);
      if (kind == ord_named) {
        nlen = pipeline_type_named_name_into(dep_arena, dep_return_type_ref, nm_buf);
        if (nlen > 0) {
          return typeck_map_import_binding_named_to_caller(G_TYPECK_ENTRY_MODULE,
                                                          from_dep_index, caller_arena, nm_buf, nlen);
        }
      }
      ord_ptr_gd = 9;
      ord_slice_gd = 11;
      ord_linear_gd = 12;
      if (kind == ord_ptr_gd || kind == ord_slice_gd || kind == ord_linear_gd) {
        elem_gd = pipeline_type_elem_ref_at(dep_arena, dep_return_type_ref);
        if (elem_gd > 0) {
          inner_gd = get_dep_return_type_in_caller_arena_impl(from_dep_index, elem_gd,
                                                             caller_arena, ctx);
          if (inner_gd > 0) {
            if (kind == ord_ptr_gd) {
              return typeck_find_or_alloc_ptr_type_ref(caller_arena, inner_gd);
            }
            if (kind == ord_linear_gd) {
              return typeck_find_or_alloc_linear_type_ref(caller_arena, inner_gd);
            }
            rlen_gd = pipeline_type_region_label_len_at(dep_arena, dep_return_type_ref);
            rbuf_gd = typeck_scratch64_slot(14);
            if (rlen_gd > 0) {
              pipeline_type_region_label_into(dep_arena, dep_return_type_ref, rbuf_gd);
            }
            return pipeline_type_find_or_alloc_slice(caller_arena, inner_gd, rbuf_gd, rlen_gd);
          }
        }
      }
    }
  }
  return typeck_dep_return_type_to_caller_arena(dep_arena, dep_return_type_ref, caller_arena);
}

int32_t get_dep_return_type_in_caller_arena(int32_t from_dep_index, int32_t dep_return_type_ref,
                                           uint8_t *caller_arena, uint8_t *ctx) {
  return get_dep_return_type_in_caller_arena_impl(from_dep_index, dep_return_type_ref,
                                                  caller_arena, ctx);
}

int32_t typeck_get_dep_return_type_in_caller_arena(int32_t from_dep_index, int32_t dep_return_type_ref,
                                                   uint8_t *caller_arena, uint8_t *ctx) {
  return get_dep_return_type_in_caller_arena_impl(from_dep_index, dep_return_type_ref,
                                                  caller_arena, ctx);
}

int32_t typeck_get_dep_return_type_in_caller_arena_i32_i32_ASTArena_ptr_PipelineDepCtx_ptr_reti32(
    int32_t from_dep_index, int32_t dep_return_type_ref, uint8_t *caller_arena, uint8_t *ctx) {
  return get_dep_return_type_in_caller_arena_impl(from_dep_index, dep_return_type_ref,
                                                  caller_arena, ctx);
}
