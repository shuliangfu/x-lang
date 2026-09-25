/**
 * PLATFORM: SHARED tip — INDEX load arms with true-pack signed i8/i16.
 *
 * Cap residual esz==4 uses movslq/LDRSW. True-pack esz==1 for named i8
 * must sign-extend (movsbl / LDRSB); esz==2 for named i16 uses movswl /
 * LDRSH. u8/bool keep zext8; bare esz==2 without named i16 uses zext16.
 * G.7 tip first-wins over weak pabi emit_index (HARD BAN PREFER into mega).
 * w1015: add esz==2 sext16/zext16 arms.
 */
#include <stdint.h>

extern int32_t backend_enc_load_64_from_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_i32_indirect_to_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_zext8_from_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_append_u8_c(void *elf_ctx, int32_t b);
extern int32_t backend_enc_append_u32_le_c(void *elf_ctx, uint32_t w);
extern int32_t glue_emit_index_eff_addr_scaled_elf_c(void *arena, void *elf_ctx, int32_t ix_ref,
                                                     int32_t base_ref, int32_t idx_ref, void *ctx,
                                                     int32_t ta, int32_t esz);
extern void glue_index_assign_addr_cache_clear(void);
extern int32_t glue_index_assign_addr_cache_hit(void *arena, void *ctx, int32_t base_ref,
                                                int32_t idx_ref, int32_t esz);
extern int32_t glue_index_load_from_cached_assign_addr_elf_c(void *elf_ctx, int32_t esz, int32_t ta);
extern int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(void *elf_ctx, int32_t ta);
extern int32_t pipeline_asm_index_elem_byte_sz_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t type_ref, uint8_t *out);

/** Emit movsbl (%rax),%eax or LDRSB W0,[X0]. ta==2 falls back to zext. */
static int32_t enc_load_sext8_from_rax(void *elf_ctx, int32_t ta) {
  if (ta == 1)
    return backend_enc_append_u32_le_c(elf_ctx, 0x39C00000u); /* LDRSB W0,[X0] */
  if (ta == 2)
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  if (backend_enc_append_u8_c(elf_ctx, 0x0f) != 0)
    return -1;
  if (backend_enc_append_u8_c(elf_ctx, 0xbe) != 0)
    return -1;
  return backend_enc_append_u8_c(elf_ctx, 0x00); /* movsbl (%rax), %eax */
}

/** Emit movzwl (%rax),%eax or LDRH W0,[X0]. */
static int32_t enc_load_zext16_from_rax(void *elf_ctx, int32_t ta) {
  if (ta == 1)
    return backend_enc_append_u32_le_c(elf_ctx, 0x79400000u); /* LDRH W0,[X0] */
  if (ta == 2)
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  if (backend_enc_append_u8_c(elf_ctx, 0x0f) != 0)
    return -1;
  if (backend_enc_append_u8_c(elf_ctx, 0xb7) != 0)
    return -1;
  return backend_enc_append_u8_c(elf_ctx, 0x00); /* movzwl (%rax), %eax */
}

/** Emit movswl (%rax),%eax or LDRSH W0,[X0]. */
static int32_t enc_load_sext16_from_rax(void *elf_ctx, int32_t ta) {
  if (ta == 1)
    return backend_enc_append_u32_le_c(elf_ctx, 0x79C00000u); /* LDRSH W0,[X0] */
  if (ta == 2)
    return enc_load_zext16_from_rax(elf_ctx, ta);
  if (backend_enc_append_u8_c(elf_ctx, 0x0f) != 0)
    return -1;
  if (backend_enc_append_u8_c(elf_ctx, 0xbf) != 0)
    return -1;
  return backend_enc_append_u8_c(elf_ctx, 0x00); /* movswl (%rax), %eax */
}

static int32_t resolved_is_named_i8(void *arena, int32_t expr_ref) {
  int32_t rty;
  uint8_t sn[64];
  int32_t sl;
  rty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (rty <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, rty) != 8)
    return 0;
  sl = pipeline_type_named_name_into(arena, rty, sn);
  return (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8') ? 1 : 0;
}

static int32_t resolved_is_named_i16(void *arena, int32_t expr_ref) {
  int32_t rty;
  uint8_t sn[64];
  int32_t sl;
  rty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (rty <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, rty) != 8)
    return 0;
  sl = pipeline_type_named_name_into(arena, rty, sn);
  return (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
             ? 1
             : 0;
}

int32_t glue_emit_index_load_arms_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t ta,
                                        int32_t esz) {
  int32_t rty;
  int32_t rtk;
  rty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (rty > 0) {
    rtk = pipeline_type_kind_ord_at(arena, rty);
    if (rtk == 10)
      return 0;
    if (rtk == 11)
      return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
  }
  if (esz > 8 && esz <= 16)
    return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8)
    return 0;
  if (esz == 1) {
    if (resolved_is_named_i8(arena, expr_ref))
      return enc_load_sext8_from_rax(elf_ctx, ta);
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  }
  if (esz == 2) {
    /* True-pack named i16: sext16. Other esz=2 keep zext16. PLATFORM: SHARED. */
    if (resolved_is_named_i16(arena, expr_ref))
      return enc_load_sext16_from_rax(elf_ctx, ta);
    return enc_load_zext16_from_rax(elf_ctx, ta);
  }
  if (esz == 4)
    return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
  return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
}

int32_t pipeline_asm_emit_index_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                     int32_t ta) {
  int32_t base_ref;
  int32_t idx_ref;
  int32_t esz;
  int32_t hit;
  int32_t rc;
  base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
  if (base_ref <= 0 || idx_ref <= 0)
    return -1;
  esz = pipeline_asm_index_elem_byte_sz_c(arena, expr_ref);
  hit = glue_index_assign_addr_cache_hit(arena, ctx, base_ref, idx_ref, esz);
  if (hit != 0)
    return glue_index_load_from_cached_assign_addr_elf_c(elf_ctx, esz, ta);
  glue_index_assign_addr_cache_clear();
  rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, expr_ref, base_ref, idx_ref, ctx, ta,
                                            esz);
  if (rc != 0)
    return -1;
  return glue_emit_index_load_arms_elf_c(arena, elf_ctx, expr_ref, ta, esz);
}
