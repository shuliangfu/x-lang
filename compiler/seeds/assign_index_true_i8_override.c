/**
 * PLATFORM: SHARED tip — INDEX assign with tip INDEX esz (true-pack i8).
 *
 * Mega/pabi_weak same-TU bl to local Cap residual index_elem (esz=4) while
 * tip emit_index reads esz=1 → store at +4, load at +1. This override emits
 * lvalue via glue_emit_index_eff_addr_scaled with tip pipeline_asm_index_elem
 * so address scale matches bake/load. G.7 twin of win_assign_index_override
 * scalar core + tip esz. Link FIRST (Darwin strong / PE first-wins / Linux).
 */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                           int32_t ta);
extern int32_t glue_emit_index_eff_addr_scaled_elf_c(void *arena, void *elf_ctx, int32_t ix_ref,
                                                     int32_t base_ref, int32_t idx_ref, void *ctx,
                                                     int32_t ta, int32_t esz);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_indirect_arch(void *elf_ctx, int32_t elem_sz, int32_t ta);
extern int32_t pipeline_asm_index_elem_byte_sz_c(void *arena, int32_t expr_ref);

int32_t glue_emit_assign_index_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                    int32_t right_ref, void *ctx, int32_t ta) {
  int32_t sz;
  int32_t base_ref;
  int32_t idx_ref;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 28)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 47)
    return -1;
  base_ref = pipeline_expr_index_base_ref(arena, left_ref);
  idx_ref = pipeline_expr_index_index_ref(arena, left_ref);
  if (base_ref <= 0 || idx_ref <= 0)
    return -1;
  /* Tip INDEX esz (true-pack i8 → 1). PLATFORM: SHARED. */
  sz = pipeline_asm_index_elem_byte_sz_c(arena, left_ref);
  if (sz <= 0)
    sz = 8;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta,
                                           sz) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, sz, ta);
}
