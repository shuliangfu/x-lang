/* PLATFORM: WINDOWS leftover-PE — real glue_emit_assign_field_elf_c.
 * windows_link_stubs historically returned -1; Class R scalar path.
 * Link FIRST with -Wl,--allow-multiple-definition over the stub in pabi.
 * Authority twin: runtime_pipeline_abi_assign_field_scalar_thin.x
 * w1509 (终局待办 10.32): compound ops (kinds 29..38) on a scalar field take
 * the value from glue_emit_assign_rhs_to_rax_elf_c, as the twin does.
 * A named field wider than 16 bytes copies through let-init slot -3 when
 * the right-hand side is a frame VAR, a FIELD, or a STRUCT_LIT. A CALL
 * of that width puts the field address in rcx and uses the existing
 * hidden-return shift, so the call writes the value. Exactly 16 bytes
 * on a frame local stays the one-GPR store. METHOD and INDEX stay on
 * that store.
 * Darwin links this seed too (its pabi body was the same kind-28-only code).
 * The wide-field arm is ta == 0 only. PLATFORM: WINDOWS + MACOS|DARWIN.
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
extern int32_t pipeline_expr_field_access_load_byte_sz(void *arena, void *mod, int32_t expr_ref);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t glue_field_access_field_type_ref_c(void *arena, void *mod, int32_t fa_ref);
extern int32_t glue_type_named_layout_size_any_module_elf_c(void *arena, int32_t ty_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_expr_field_access_base_ref(void *arena, int32_t expr_ref);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t glue_emit_struct_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                    void *ctx, int32_t ta, int32_t let_ty_ref,
                                                    int32_t stack_slot_off);
extern void pipeline_asm_set_call_expected_ret_ty_c(int32_t type_ref);
extern void pipeline_asm_emit_set_call_sret_reg_shift_c(int32_t v);
extern int32_t backend_enc_mov_rbx_to_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);

int32_t glue_emit_assign_field_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                    int32_t right_ref, void *ctx, int32_t ta) {
  int32_t sz;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  int32_t ek = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ek != 28 && (ek < 29 || ek > 38))
    return -1;
  /* PLATFORM: WINDOWS x86_64. This object is the field-assign body the
   * link keeps (it is ahead of the pabi stub). A named layout wider than
   * 16 bytes does not fit in one GPR. A frame VAR or a FIELD on the
   * right is copied by the existing let-init (destination already in rbx,
   * slot -3). A STRUCT_LIT on the right, for a layout wider than 16
   * bytes, uses that same let-init: rbx already holds the field, and
   * the existing writer stores each field there. A CALL on the right,
   * for a layout wider than 16 bytes, places the field address in rcx
   * before the call. The sret shift keeps the source pointer in rdx,
   * and the call writes the value. Let-init is not used for that call:
   * its dest-in-rbx arm emits and then returns -2. METHOD and INDEX
   * stay on the one-GPR store below. Exactly 16 bytes still copies
   * only when the base variable is a pointer (type kind 9). A frame
   * local of exactly 16 bytes stays on the one-GPR store below. The
   * destination lvalue is emitted first. Once it is written, a later
   * failure does not fall through. ta != 0 is unchanged, including
   * Darwin. */
  if (ek == 28 && ta == 0) {
    void *mod = pipeline_asm_emit_module_ref_c();
    int32_t fty = glue_field_access_field_type_ref_c(arena, mod, left_ref);
    int32_t wide = 0;
    int32_t fk = 0;
    int32_t ptr_base = 0;
    int32_t wide_local = 0;
    if (fty > 0) {
      wide = glue_type_named_layout_size_any_module_elf_c(arena, fty);
      fk = pipeline_type_kind_ord_at(arena, fty);
    }
    if (fk == 8 && wide > 16)
      wide_local = 1;
    if (fk == 8 && wide == 16) {
      int32_t base = pipeline_expr_field_access_base_ref(arena, left_ref);
      if (base > 0 && pipeline_expr_kind_ord_at(arena, base) == 3) {
        int32_t bty = glue_var_decl_type_ref_elf_c(arena, ctx, base);
        int32_t rty = pipeline_expr_resolved_type_ref(arena, base);
        if (bty > 0 && pipeline_type_kind_ord_at(arena, bty) == 9)
          ptr_base = 1;
        if (!ptr_base && rty > 0 && pipeline_type_kind_ord_at(arena, rty) == 9)
          ptr_base = 1;
      }
    }
    if (wide_local || ptr_base) {
      int32_t rko = pipeline_expr_kind_ord_at(arena, right_ref);
      int32_t pre = 0;
      if (rko == 3)
        pre = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref) >= 0;
      else if (rko == 44)
        pre = 1;
      /* STRUCT_LIT (45). wide_local only: the let-init writer stores
       * each field through rbx. Exactly 16 bytes, including a pointer
       * base, stays on the one-GPR store below. INDEX (47) stays below:
       * let-init still returns -2 for it. PLATFORM: WINDOWS x86_64. */
      else if (wide_local && rko == 45)
        pre = 1;
      if (pre) {
        int32_t irc;
        if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
          return -1;
        irc = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, fty, -3);
        if (irc == 0)
          return 0;
        return -1;
      }
      /* CALL (48). The field address is the hidden return slot. rcx is
       * set before emit, and the sret shift keeps the source pointer in
       * rdx. A later one-qword store would write the returned pointer
       * over the first word. wide_local only: exactly 16 bytes stays
       * below. METHOD (49) and INDEX (47) stay below.
       * PLATFORM: WINDOWS x86_64. ta != 0 does not enter this function's
       * wide gate. */
      if (wide_local && rko == 48) {
        int32_t erc;
        if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
          return -1;
        pipeline_asm_set_call_expected_ret_ty_c(fty > 0 ? fty : 0);
        pipeline_asm_emit_set_call_sret_reg_shift_c(1);
        erc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
        pipeline_asm_emit_set_call_sret_reg_shift_c(0);
        pipeline_asm_set_call_expected_ret_ty_c(0);
        if (erc != 0)
          return -1;
        return 0;
      }
    }
  }
  sz = pipeline_expr_field_access_load_byte_sz(arena, pipeline_asm_emit_module_ref_c(), left_ref);
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
