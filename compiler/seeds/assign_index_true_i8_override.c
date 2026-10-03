/**
 * PLATFORM: SHARED tip — INDEX assign with tip INDEX esz (true-pack i8).
 *
 * Mega/pabi_weak same-TU bl to local Cap residual index_elem (esz=4) while
 * tip emit_index reads esz=1 → store at +4, load at +1. This override emits
 * lvalue via glue_emit_index_eff_addr_scaled with tip pipeline_asm_index_elem
 * so address scale matches bake/load. G.7 twin of win_assign_index_override
 * scalar core + tip esz. Link FIRST (Darwin strong / PE first-wins / Linux).
 * w1508 (终局待办 10.33): compound ops (kinds 29..38, `a[i] += x`) returned
 * -1 here, so the whole function failed with CG002 on Darwin and Windows.
 * A scalar element (<= 8 bytes) now takes the value from
 * glue_emit_assign_rhs_to_rax_elf_c (loads the element, applies the op in
 * the element type), same as the authority twin
 * runtime_pipeline_abi_assign_index_generic_thin.x, then the usual store.
 * w1512 (终局待办 10.41): on x86-64 (ta == 0) a plain `=` of an element
 * wider than 8 bytes from an lvalue (VAR / FIELD / INDEX rhs) copies the
 * whole element with memcpy: rhs address in rax, element address in rbx,
 * glue_copy slot -3. Windows used to load the rhs value into rax (and rdx)
 * and run one 8-byte store, so 12/16/24-byte elements were partly copied.
 * A CALL rhs wider than 8 bytes used to emit the call with the source
 * pointer in rcx and then store that returned pointer as one qword.
 * The element address is placed in rcx first, with the same sret shift
 * the frame-slot let-init uses, so the call writes the value into the
 * element. METHOD and STRUCT_LIT stay on the one-qword store.
 * PLATFORM: WINDOWS x86_64 for the call arm. ta != 0 is unchanged.
 */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                           int32_t ta);
extern int32_t glue_emit_assign_rhs_to_rax_elf_c(void *arena, void *elf_ctx, int32_t assign_expr_ref,
                                                 int32_t left_ref, int32_t right_ref, void *ctx,
                                                 int32_t ta);
extern int32_t glue_emit_index_eff_addr_scaled_elf_c(void *arena, void *elf_ctx, int32_t ix_ref,
                                                     int32_t base_ref, int32_t idx_ref, void *ctx,
                                                     int32_t ta, int32_t esz);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_push_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_indirect_arch(void *elf_ctx, int32_t elem_sz, int32_t ta);
extern int32_t backend_enc_append_u32_le_c(void *elf_ctx, uint32_t word);
extern int32_t pipeline_asm_index_elem_byte_sz_c(void *arena, int32_t expr_ref);
extern int32_t glue_copy_large_struct_from_rax_ptr_elf_c(void *elf_ctx, int32_t slot_off,
                                                        int32_t sz, int32_t ta);
extern int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref,
                                                       void *ctx, int32_t ta);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern void pipeline_asm_set_call_expected_ret_ty_c(int32_t type_ref);
extern void pipeline_asm_emit_set_call_sret_reg_shift_c(int32_t v);
extern int32_t backend_enc_mov_rbx_to_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);

int32_t glue_emit_assign_index_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                    int32_t right_ref, void *ctx, int32_t ta) {
  int32_t sz;
  int32_t base_ref;
  int32_t idx_ref;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  int32_t ek = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ek != 28 && (ek < 29 || ek > 38))
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
  /* w1512: x86-64 whole-element copy from an lvalue. PLATFORM: LINUX|WINDOWS. */
  if (ek == 28 && ta == 0 && sz > 8) {
    int32_t rkx = pipeline_expr_kind_ord_at(arena, right_ref);
    if (rkx == 3 || rkx == 44 || rkx == 47) {
      if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
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
      return glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, -3, sz, ta);
    }
    /* CALL (48). The element address is already the hidden return slot.
     * rcx is set before emit, and the sret shift keeps the source pointer
     * in rdx. A later one-qword store would write the returned pointer
     * over the first word. METHOD (49) and STRUCT_LIT (45) are not here.
     * PLATFORM: WINDOWS x86_64. ta != 0 stays on the path below. */
    if (rkx == 48) {
      int32_t ety;
      int32_t erc;
      ety = pipeline_expr_resolved_type_ref(arena, left_ref);
      if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta,
                                               sz) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
        return -1;
      pipeline_asm_set_call_expected_ret_ty_c(ety > 0 ? ety : 0);
      pipeline_asm_emit_set_call_sret_reg_shift_c(1);
      erc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
      pipeline_asm_emit_set_call_sret_reg_shift_c(0);
      pipeline_asm_set_call_expected_ret_ty_c(0);
      if (erc != 0)
        return -1;
      return 0;
    }
  }
  if (ek != 28) {
    /* w1508: compound op on a scalar element. PLATFORM: SHARED. */
    if (sz > 8)
      return -1;
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
      return -1;
  } else if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  /* PLATFORM: MACOS|ARM64. A 9..16 byte element is a dual-GP value when the
   * RHS kind is VAR (3), FIELD (44), STRUCT_LIT (45), INDEX (47), CALL (48),
   * or METHOD (49): x0 is the low half and x1 is the high half. push_rax
   * keeps only x0, then mov_rax_to_rbx writes the element address into x1.
   * Save x1 first. ARRAY_LIT (46) is not this value. Size <= 8 and ta != 1
   * stay on the single push, including true-pack i8. */
  int32_t pair = 0;
  if (ta == 1 && sz > 8 && sz <= 16) {
    int32_t rko = pipeline_expr_kind_ord_at(arena, right_ref);
    if (rko == 3 || rko == 44 || rko == 45 || rko == 47 || rko == 48 || rko == 49)
      pair = 1;
  }
  if (pair) {
    if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta,
                                           sz) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pair) {
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    /* Spill the pair to a contiguous 16-byte slot and copy exactly sz
     * bytes. A 16-byte store would run four bytes into the next element
     * when the layout stride is 12 (three i32). glue_copy slot -3 uses the
     * address in x0 and the destination already parked in x19.
     * stp x0, x1, [sp, #-16]! ; mov x0, sp ; memcpy ; add sp, sp, #16. */
    if (backend_enc_append_u32_le_c(elf_ctx, 0xA9BF07E0u) != 0)
      return -1;
    if (backend_enc_append_u32_le_c(elf_ctx, 0x910003E0u) != 0)
      return -1;
    if (glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, -3, sz, ta) != 0)
      return -1;
    if (backend_enc_append_u32_le_c(elf_ctx, 0x910043FFu) != 0)
      return -1;
    return 0;
  }
  /* PLATFORM: MACOS|ARM64. An element larger than 16 bytes leaves its
   * address in rax for the same kinds. store_indirect writes one qword,
   * so the slot received the source address. Copy sz bytes via slot -3.
   * ARRAY_LIT (46) stays on the indirect store. A qword in rax must not
   * enter the memcpy. ta != 1 keeps that store. */
  if (ta == 1 && sz > 16) {
    int32_t rko = pipeline_expr_kind_ord_at(arena, right_ref);
    if (rko == 3 || rko == 44 || rko == 45 || rko == 47 || rko == 48 || rko == 49)
      return glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, -3, sz, ta);
  }
  return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, sz, ta);
}
