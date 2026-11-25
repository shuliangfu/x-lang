/**
 * PLATFORM: WINDOWS tip PE only — tip.x-faithful INDEX rvalue emit.
 *
 * Soft Cap mega pipeline_asm_emit_index_elf_c CG002 on Win INDEX rvalue
 * (buf[0] / *u8 bp[0]). ADDR_OF INDEX + Mac tip.x thin green. Ban Prefer
 * body copy. No assign-addr cache (cache helper VAs unstable on tip PE).
 */
#include <stdint.h>

extern int32_t pipeline_expr_index_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_index_elem_byte_sz_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t glue_emit_index_eff_addr_scaled_elf_c(void *arena, void *elf_ctx, int32_t ix_ref,
                                                    int32_t base_ref, int32_t idx_ref, void *ctx,
                                                    int32_t ta, int32_t esz);
extern int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_zext8_from_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_i32_indirect_to_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_64_from_rax_arch(void *elf_ctx, int32_t ta);

int32_t pipeline_asm_emit_index_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                      int32_t ta) {
  int32_t base_ref;
  int32_t idx_ref;
  int32_t esz;
  int32_t res_ty;
  int32_t rtk;
  int32_t rc;

  (void)ctx;
  if (arena == 0 || elf_ctx == 0) {
    return -1;
  }
  base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
  if (base_ref <= 0 || idx_ref <= 0) {
    return -1;
  }
  esz = pipeline_asm_index_elem_byte_sz_c(arena, expr_ref);
  rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, expr_ref, base_ref, idx_ref, ctx, ta,
                                            esz);
  if (rc != 0) {
    return -1;
  }
  res_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (res_ty > 0) {
    rtk = pipeline_type_kind_ord_at(arena, res_ty);
    if (rtk == 10) {
      return 0;
    }
    if (rtk == 11) {
      return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
    }
  }
  if (esz > 8 && esz <= 16) {
    return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
  }
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
    return 0;
  }
  if (esz == 1) {
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  }
  if (esz == 4) {
    return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
  }
  return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
}
