/**
 * PLATFORM: WINDOWS — host-gcc twin of pipe_modlet_bake_array_lit_elems_to_data.
 *
 * w1020 root: PE tip built from bake_elems_thin.x is non-deterministic
 * CG002 (elf_ec=-1). Same PE weaken+jmp path with this host-gcc body is
 * stable. Darwin/Linux keep the .x tip; Win true-pack opt-in
 * (XLANG_WIN_BAKE_TIP=1) must link this .o as bake_elems.o.
 *
 * True-pack: named i8 → esz 1; named i16/u16 → esz 2 (w1012/w1015/w1016).
 * Cap residual other named stay on force_esz / glue (typically 4).
 * Authority twin of runtime_pipeline_abi_modlet_bake_elems_thin.x.
 */
#include <stdint.h>

extern int32_t glue_array_lit_force_esz_from_elem_type_c(void *arena, int32_t et);
extern int32_t glue_fixed_array_total_bytes_c(void *arena, int32_t ty_ref, int32_t depth);
extern int32_t pipeline_elf_ctx_data_poke_u8(void *ctx, int32_t off, int32_t b);
extern int32_t pipeline_expr_array_lit_elem_ref(void *arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ref, uint8_t *out);
extern int32_t pipe_modlet_array_lit_elem_const_val(void *arena, int32_t eref,
                                                    int32_t *out_val, int32_t *out_hi);
extern int32_t pipe_modlet_bake_ptr_addr_elem_to_data(void *arena, void *elf_ctx, void *m,
                                                     int32_t eref, int32_t esz, int32_t slot);
extern int32_t pipe_modlet_bake_string_lit_elem_to_data(void *arena, void *elf_ctx,
                                                       int32_t eref, int32_t slot);
extern int32_t pipe_modlet_bake_struct_lit_to_data(void *arena, void *elf_ctx, int32_t lit_ref,
                                                  int32_t elem_base, void *m);

/**
 * Bake one module ARRAY_LIT into an already-reserved data span.
 * See bake_elems_thin.x for fold return-code poke rules.
 */
int32_t pipe_modlet_bake_array_lit_elems_to_data(
    void *arena, void *elf_ctx, int32_t init_ref, int32_t elem_ty, int32_t data_base,
    int32_t base_off, int32_t span_bytes, void *m) {
  int32_t ne, ei, eref, ek, ev, esz, etk, inner_et, row_sz, rc, skip, slot;
  int32_t b0, b1, b2, b3, hi, ehi, h0, h1, h2, h3;
  uint8_t sn[64];
  int32_t sl;

  if (!arena || !elf_ctx || init_ref <= 0)
    return 0;

  etk = 0;
  if (elem_ty > 0)
    etk = pipeline_type_kind_ord_at(arena, elem_ty);

  /* Nested TYPE_ARRAY (kind 10): one row per element. */
  if (etk == 10) {
    inner_et = pipeline_type_elem_ref_at(arena, elem_ty);
    ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
    row_sz = glue_fixed_array_total_bytes_c(arena, elem_ty, 0);
    if (row_sz <= 0)
      row_sz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty);
    if (ne <= 0)
      return 0;
    if (row_sz > 0 && ne > span_bytes / row_sz)
      return -1;
    for (ei = 0; ei < ne; ei++) {
      eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei);
      if (eref > 0 && pipeline_expr_kind_ord_at(arena, eref) == 46) {
        rc = pipe_modlet_bake_array_lit_elems_to_data(
            arena, elf_ctx, eref, inner_et, data_base, base_off + ei * row_sz, row_sz, m);
        if (rc != 0)
          return rc;
      }
    }
    return 0;
  }

  esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty);
  /* True-pack named i8/i16/u16 when force_esz still Cap residual 4. */
  if (etk == 8 && esz == 4) {
    sl = pipeline_type_named_name_into(arena, elem_ty, sn);
    if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8')
      esz = 1;
    if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
      esz = 2;
    if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
      esz = 2;
  }
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
    if (etk != 8 || esz <= 0)
      esz = 4;
  }

  ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  if (ne <= 0)
    return 0;
  if (esz > 0 && ne > span_bytes / esz)
    return -1;

  for (ei = 0; ei < ne; ei++) {
    eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei);
    if (eref <= 0)
      continue;
    ek = pipeline_expr_kind_ord_at(arena, eref);
    skip = 0;
    if (ek == 59) {
      slot = data_base + base_off + ei * esz;
      if (pipe_modlet_bake_string_lit_elem_to_data(arena, elf_ctx, eref, slot) != 0)
        return -1;
      skip = 1;
    }
    if (skip == 0 && ek == 45) {
      slot = data_base + base_off + ei * esz;
      if (pipe_modlet_bake_struct_lit_to_data(arena, elf_ctx, eref, slot, m) != 0)
        return -1;
      skip = 1;
    }
    if (skip == 0 && (etk == 9 || etk == 18) && m) {
      slot = data_base + base_off + ei * esz;
      rc = pipe_modlet_bake_ptr_addr_elem_to_data(arena, elf_ctx, m, eref, esz, slot);
      if (rc < 0)
        return -1;
      if (rc == 0)
        skip = 1;
    }
    if (skip == 0) {
      rc = pipe_modlet_array_lit_elem_const_val(arena, eref, &ev, &ehi);
      if (rc == 0)
        return -1;
      b0 = ev & 255;
      b1 = (ev >> 8) & 255;
      b2 = (ev >> 16) & 255;
      b3 = (ev >> 24) & 255;
      hi = 0;
      if (ev < 0 && rc != 2 && rc != 4 && rc != 5)
        hi = 255;
      h0 = hi;
      h1 = hi;
      h2 = hi;
      h3 = hi;
      if (rc == 3 || rc == 5) {
        h0 = ehi & 255;
        h1 = (ehi >> 8) & 255;
        h2 = (ehi >> 16) & 255;
        h3 = (ehi >> 24) & 255;
      }
      slot = data_base + base_off + ei * esz;
      if (esz > 0 && pipeline_elf_ctx_data_poke_u8(elf_ctx, slot, b0) != 0)
        return -1;
      if (esz > 1 && pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 1, b1) != 0)
        return -1;
      if (esz > 2 && pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 2, b2) != 0)
        return -1;
      if (esz > 3 && pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 3, b3) != 0)
        return -1;
      if (esz > 4 && pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 4, h0) != 0)
        return -1;
      if (esz > 5 && pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 5, h1) != 0)
        return -1;
      if (esz > 6 && pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 6, h2) != 0)
        return -1;
      if (esz > 7 && pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 7, h3) != 0)
        return -1;
    }
  }
  return 0;
}
