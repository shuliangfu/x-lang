/**
 * PLATFORM: SHARED tip — ARRAY_LIT true-pack named i8 → 1, i16/u16 → 2.
 *
 * Cap residual named_builtin / glue_type_size_simple still report 4 for
 * i8/i16/u16 (struct fields). Tip first-wins force_esz + elem_byte_sz so
 * local lit stores pack like module bake. w1014 i8; w1015 i16; w1016 u16.
 */
#include <stdint.h>

extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t et);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t et, uint8_t *out);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t glue_type_size_simple(void *mod, void *arena, int32_t et, int32_t depth);
extern int32_t glue_fixed_array_total_bytes_c(void *arena, int32_t et, int32_t depth);
extern int32_t pipeline_asm_array_lit_elem_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(void *arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *arena, int32_t expr_ref);

/**
 * Force ARRAY_LIT element store/INDEX stride from dest elem type kind.
 * True-pack named i8 → 1. PLATFORM: SHARED.
 * w1020: compile with -DXLANG_WIN_ELEM_BYTE_SZ_ONLY to omit this and
 * keep only pipeline_asm_array_lit_elem_byte_sz_c in a separate .o.
 */
#if !defined(XLANG_WIN_ELEM_BYTE_SZ_ONLY)
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
    /* True-pack ARRAY_LIT named i8 / i16 / u16. PLATFORM: SHARED. */
    if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8')
      return 1;
    if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
      return 2;
    if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
      return 2;
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
#endif /* !XLANG_WIN_ELEM_BYTE_SZ_ONLY */

/**
 * Infer ARRAY_LIT element byte width (force_esz=0 local flat path).
 * True-pack named i8 → 1 so local stores match INDEX tip.
 * PLATFORM: SHARED — twin of fnptr_array_esz_thin.x (w1014).
 * w1020: on Windows tip stack, compile with -DXLANG_WIN_FORCE_ESZ_ONLY so
 * this twin is omitted from the force .o (same-.o dual T PE footgun);
 * build a second .o with -DXLANG_WIN_ELEM_BYTE_SZ_ONLY for local lit.
 */
#if !defined(XLANG_WIN_FORCE_ESZ_ONLY)
int32_t pipeline_asm_array_lit_elem_byte_sz_c(void *arena, int32_t expr_ref) {
  int32_t elem_ty;
  int32_t kind_ord;
  int32_t nested;
  int32_t first_ref;
  int32_t ssz;
  int32_t n_inner;
  int32_t iesz;
  void *mod;
  elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, expr_ref);
  if (elem_ty > 0) {
    kind_ord = pipeline_type_kind_ord_at(arena, elem_ty);
    if (kind_ord == 10) {
      nested = glue_fixed_array_total_bytes_c(arena, elem_ty, 0);
      if (nested > 0)
        return nested;
    }
    if (kind_ord == 2 || kind_ord == 1)
      return 1;
    if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
      return 4;
    if (kind_ord == 15 || kind_ord == 4 || kind_ord == 5 || kind_ord == 6 ||
        kind_ord == 7 || kind_ord == 9 || kind_ord == 18)
      return 8;
    if (kind_ord == 11)
      return 16;
    if (kind_ord == 8) {
      uint8_t sn[64];
      int32_t sl = pipeline_type_named_name_into(arena, elem_ty, sn);
      /* True-pack named i8 / i16 / u16 (w1014–w1016 local flat). PLATFORM: SHARED. */
      if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8')
        return 1;
      if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
        return 2;
      if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
        return 2;
      mod = pipeline_asm_emit_module_ref_c();
      if (mod) {
        ssz = glue_type_size_simple(mod, arena, elem_ty, 0);
        if (ssz > 0)
          return ssz;
      }
    }
  }
  first_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, 0);
  if (first_ref > 0 && pipeline_expr_kind_ord_at(arena, first_ref) == 46) {
    n_inner = pipeline_expr_array_lit_num_elems_at(arena, first_ref);
    iesz = pipeline_asm_array_lit_elem_byte_sz_c(arena, first_ref);
    if (n_inner > 0 && iesz > 0)
      return n_inner * iesz;
  }
  return 4;
}
#endif /* !XLANG_WIN_FORCE_ESZ_ONLY */
