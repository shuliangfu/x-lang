/**
 * PLATFORM: SHARED tip — ARRAY_LIT force_esz true-pack named i8 → 1.
 *
 * Cap residual named_builtin / glue_type_size_simple still report 4 for i8
 * (struct fields). Local ARRAY_LIT flat stores used that 4 while INDEX
 * reads esz=1 → [1,2] local sum=1. Tip first-wins this face so local lit
 * stores pack like module bake. i16/u16 stay Cap residual 4.
 */
#include <stdint.h>

extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t et);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t et, uint8_t *out);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t glue_type_size_simple(void *mod, void *arena, int32_t et, int32_t depth);
extern int32_t glue_fixed_array_total_bytes_c(void *arena, int32_t et, int32_t depth);

int32_t glue_array_lit_force_esz_from_elem_type_c(void *arena, int32_t et) {
  int32_t ek;
  int32_t ssz;
  void *mod;
  if (!arena || et <= 0)
    return 0;
  ek = pipeline_type_kind_ord_at(arena, et);
  if (ek == 2 || ek == 1)
    return 1;
  if (ek == 0 || ek == 3 || ek == 13 || ek == 14)
    return 4;
  if (ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 15 || ek == 9 || ek == 18)
    return 8;
  if (ek == 8) {
    uint8_t sn[64];
    int32_t sl = pipeline_type_named_name_into(arena, et, sn);
    /* True-pack ARRAY_LIT named i8. PLATFORM: SHARED. */
    if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8')
      return 1;
    mod = pipeline_asm_emit_module_ref_c();
    if (mod) {
      ssz = glue_type_size_simple(mod, arena, et, 0);
      if (ssz > 0)
        return ssz;
    }
  }
  if (ek == 10) {
    ssz = glue_fixed_array_total_bytes_c(arena, et, 0);
    if (ssz > 0)
      return ssz;
  }
  if (ek == 11)
    return 16;
  return 0;
}
