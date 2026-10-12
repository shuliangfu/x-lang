/* PLATFORM: WINDOWS leftover-PE — real glue_emit_assign_index_elf_c.
 * windows_link_stubs historically returned -1; Class T scalar path.
 * Link FIRST with -Wl,--allow-multiple-definition over the stub in pabi.
 * Authority twin: runtime_pipeline_abi_assign_index_generic_thin (scalar core).
 * w1508 (终局待办 10.33): compound ops (kinds 29..38) on a scalar element
 * take the value from glue_emit_assign_rhs_to_rax_elf_c, as the twin does.
 */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                           int32_t ta);
extern int32_t glue_emit_assign_rhs_to_rax_elf_c(void *arena, void *elf_ctx, int32_t assign_expr_ref,
                                                 int32_t left_ref, int32_t right_ref, void *ctx,
                                                 int32_t ta);
extern int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref,
                                                       void *ctx, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_indirect_arch(void *elf_ctx, int32_t elem_sz, int32_t ta);
extern int32_t pipeline_asm_index_elem_byte_sz_c(void *arena, int32_t expr_ref);

int32_t glue_emit_assign_index_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                    int32_t right_ref, void *ctx, int32_t ta) {
  int32_t sz;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  int32_t ek = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ek != 28 && (ek < 29 || ek > 38))
    return -1;
  sz = pipeline_asm_index_elem_byte_sz_c(arena, left_ref);
  if (sz <= 0)
    sz = 8;
  if (ek != 28) {
    if (sz > 8)
      return -1;
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
      return -1;
  } else if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, sz, ta);
}
