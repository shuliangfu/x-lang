/**
 * PLATFORM: WINDOWS leftover-PE — first-wins glue_index_elem_byte_sz_from_type_ref_c.
 *
 * Mega runtime_pipeline_abi.o embeds an older leftover twin that hardcodes
 * Cap residual i8→1 for ARRAY elems, while bake still strides at glue size 4.
 * That made i8[4] INDEX read byte-stride (g[1]==0, sum==1).
 *
 * This object matches the fixed from_x leftover: PTR *i8 stays 1; ARRAY/SLICE
 * named elems use glue_type_size_simple (4 today). Authority: same body as
 * seeds/runtime_pipeline_abi.from_x.c glue_index_elem_byte_sz_from_type_ref_c
 * after wave1005. Link FIRST via g05 _WIN_ASSIGN_OVERRIDES.
 */
#include <stdint.h>

extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ty_ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t ty_ref);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ty_ref, uint8_t *out);
extern int32_t glue_fixed_array_total_bytes_c(void *arena, int32_t ty_ref, int32_t depth);
extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);
extern void *pipeline_asm_emit_module_ref_c(void);

int32_t glue_index_elem_byte_sz_from_type_ref_c(void *arena, int32_t tr) {
  int32_t kind_ord;
  int32_t pointee;
  int32_t asz;
  int32_t ssz;
  void *mod;
  if (tr <= 0 || arena == 0)
    return 4;
  kind_ord = pipeline_type_kind_ord_at(arena, tr);
  if (kind_ord == 9) {
    pointee = pipeline_type_elem_ref_at(arena, tr);
    if (pointee > 0) {
      kind_ord = pipeline_type_kind_ord_at(arena, pointee);
      if (kind_ord == 2 || kind_ord == 1)
        return 1;
      if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
        return 4;
      if (kind_ord == 15 || kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7)
        return 8;
      if (kind_ord == 9)
        return 8;
      if (kind_ord == 10) {
        asz = glue_fixed_array_total_bytes_c(arena, pointee, 0);
        if (asz > 0)
          return asz;
      }
      /* PTR *named: Cap residual i8/u8/bool stay byte loads. */
      if (kind_ord == 8) {
        uint8_t sn[64];
        int32_t sl = pipeline_type_named_name_into(arena, pointee, sn);
        if (sl == 2 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'8')
          return 1;
        if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8')
          return 1;
        if (sl == 4 && sn[0] == (uint8_t)'b' && sn[1] == (uint8_t)'o' &&
            sn[2] == (uint8_t)'o' && sn[3] == (uint8_t)'l')
          return 1;
        if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'3' && sn[2] == (uint8_t)'2')
          return 4;
        if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'3' && sn[2] == (uint8_t)'2')
          return 4;
        mod = pipeline_asm_emit_module_ref_c();
        if (mod) {
          ssz = glue_type_size_simple(mod, arena, pointee, 0);
          if (ssz > 0)
            return ssz;
        }
      }
    }
    return 4;
  }
  if (kind_ord == 10 || kind_ord == 11) {
    pointee = pipeline_type_elem_ref_at(arena, tr);
    if (pointee > 0) {
      kind_ord = pipeline_type_kind_ord_at(arena, pointee);
      if (kind_ord == 2 || kind_ord == 1)
        return 1;
      if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
        return 4;
      if (kind_ord == 15)
        return 8;
      if (kind_ord == 9 || kind_ord == 18)
        return 8;
      if (kind_ord == 10) {
        asz = glue_fixed_array_total_bytes_c(arena, pointee, 0);
        if (asz > 0)
          return asz;
      }
      if (kind_ord == 11)
        return 16;
      /* ARRAY/SLICE Cap residual: bake strides at 4 (product glue/typeck
       * disagree on named size). Force 4 for i8/i16/u16 so INDEX matches
       * bake; other named use glue_type_size_simple.
       * PLATFORM: WINDOWS leftover-PE.
       */
      if (kind_ord == 8) {
        uint8_t sn[64];
        int32_t sl = pipeline_type_named_name_into(arena, pointee, sn);
        if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8')
          return 4;
        if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
          return 4;
        if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
          return 4;
        mod = pipeline_asm_emit_module_ref_c();
        if (mod) {
          ssz = glue_type_size_simple(mod, arena, pointee, 0);
          if (ssz > 0)
            return ssz;
        }
      }
    }
  }
  if (kind_ord == 2 || kind_ord == 1)
    return 1;
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
    return 4;
  if (kind_ord == 15 || kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7)
    return 8;
  if (kind_ord == 11)
    return 16;
  if (kind_ord == 8) {
    uint8_t sn[64];
    int32_t sl = pipeline_type_named_name_into(arena, tr, sn);
    if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8')
      return 4;
    if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
      return 4;
    if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
      return 4;
    mod = pipeline_asm_emit_module_ref_c();
    if (mod) {
      ssz = glue_type_size_simple(mod, arena, tr, 0);
      if (ssz > 0)
        return ssz;
    }
  }
  return 8;
}
