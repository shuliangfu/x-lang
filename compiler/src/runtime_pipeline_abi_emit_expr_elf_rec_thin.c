/*
 * Host-gcc first-wins twin of pipeline_asm_emit_expr_elf_rec (EXIT).
 *
 * DIG s260 Soft Cap (PLATFORM: WINDOWS host-cc):
 * Cap soft helpers_win.o first-wins but tip-compiled body is a 0x2bf8
 * probe frame. Soft Cap emit_return (s259) → emit_expr_elf_c → tipU
 * rec nests a second 0x2bf8 frame → SEGV (RIP=0) on `return x` after
 * let init. Mirror helpers_thin.x EXIT (fast + kind dispatch) as a
 * small host-cc frame; tip-land ahead of Cap soft helpers + win_patch
 * fold leftover tipU/W onto this T.
 *
 * G.7: complete existing helpers_thin emit_expr_elf_rec authority; do
 * not open a second probe. Named16 9..16 pair pre-check stays on Cap
 * soft helpers when that path is re-enabled; INT/VAR let probe is
 * covered by emit_expr_elf_fast (no extra UNDEF on Soft Cap).
 */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_fast(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_expr_if_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_expr_if_arm_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_match_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_panic_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_struct_lit_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_array_lit_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_index_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_addr_of_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_deref_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_call_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_method_call_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t glue_asm_emit_string_lit_ptr_rax_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t ta);
extern int32_t pipeline_asm_try_emit_inline_asm_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_cmp_elf(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_return_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_break_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_continue_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t ta);
extern int32_t pipeline_expr_binop_left_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_binop_add_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_binop_sub_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_binop_mul_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_binop_div_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_binop_mod_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_binop_and_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_binop_shift_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta, int32_t is_shr);
extern int32_t pipeline_asm_emit_binop_bitwise_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx, int32_t ta, int32_t is_xor);
extern int32_t pipeline_asm_emit_neg_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_bitnot_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_lognot_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t glue_expr_is_await_at_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_await_sync_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t glue_expr_is_x_as_cast_at_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_as_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_try_propagate_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_assign_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_logand_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_logor_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_expr_enum_namespace_field_tag(void *arena, int32_t expr_ref);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_emit_expr_elf_slow(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);

/**
 * Freestanding expr ELF recursion Soft Cap (helpers_thin EXIT shape).
 *
 * @param arena ASTArena*
 * @param elf_ctx ElfCodegenCtx*
 * @param expr_ref expression ref; <=0 skips kind load
 * @param ctx AsmFuncCtx*
 * @param ta 0 x86_64 / 1 arm64
 * @return 0 ok; negative error; -99 unhandled from slow
 * PLATFORM: WINDOWS host-cc Soft Cap; SHARED EXIT contract vs helpers_thin.x.
 */
int32_t pipeline_asm_emit_expr_elf_rec(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t ko;
  int32_t r;
  int32_t ns_tag;
  int32_t left_ref;
  int32_t right_ref;

  ko = -1;
  if (expr_ref > 0) {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  /* DIG Soft Cap: skip Cap soft named16 pre-check (pair helper stays in
   * helpers_win.o). Field 9..16 may fall through fast then kind-44 arm. */
  r = pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta);
  if (r != -99) {
    return r;
  }
  if (ko == 25 || ko == 27) {
    return pipeline_asm_emit_expr_if_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 26) {
    return pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 43) {
    return pipeline_asm_emit_match_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 42) {
    return pipeline_asm_emit_panic_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 45) {
    return pipeline_asm_emit_struct_lit_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 46) {
    return pipeline_asm_emit_array_lit_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 47) {
    return pipeline_asm_emit_index_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 51) {
    return pipeline_asm_emit_addr_of_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 52) {
    return pipeline_asm_emit_deref_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 48) {
    return pipeline_asm_emit_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 49) {
    return pipeline_asm_emit_method_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 59) {
    return glue_asm_emit_string_lit_ptr_rax_elf_c(arena, elf_ctx, expr_ref, ta);
  }
  if (ko == 60) {
    return pipeline_asm_try_emit_inline_asm_expr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko >= 14 && ko <= 19) {
    return pipeline_asm_emit_cmp_elf(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 41) {
    return pipeline_asm_emit_return_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 39) {
    return pipeline_asm_emit_break_elf_c(arena, elf_ctx, ctx, ta);
  }
  if (ko == 40) {
    return pipeline_asm_emit_continue_elf_c(arena, elf_ctx, ctx, ta);
  }
  if (ko == 4) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    return pipeline_asm_emit_binop_add_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
  if (ko == 5) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    return pipeline_asm_emit_binop_sub_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
  if (ko == 6) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    return pipeline_asm_emit_binop_mul_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
  if (ko == 7) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    return pipeline_asm_emit_binop_div_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
  if (ko == 8) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    return pipeline_asm_emit_binop_mod_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
  if (ko == 9) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    return pipeline_asm_emit_binop_shift_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, 0);
  }
  if (ko == 10) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    return pipeline_asm_emit_binop_shift_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, 1);
  }
  if (ko == 11) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    return pipeline_asm_emit_binop_and_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
  if (ko == 12) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    return pipeline_asm_emit_binop_bitwise_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, 0);
  }
  if (ko == 13) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    return pipeline_asm_emit_binop_bitwise_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, 1);
  }
  if (ko == 22) {
    return pipeline_asm_emit_neg_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 23) {
    return pipeline_asm_emit_bitnot_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 24) {
    return pipeline_asm_emit_lognot_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (glue_expr_is_await_at_c(arena, expr_ref) != 0) {
    return pipeline_asm_emit_await_sync_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (glue_expr_is_x_as_cast_at_c(arena, expr_ref) != 0) {
    return pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 58 || ko == 57) {
    return pipeline_asm_emit_try_propagate_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 28 || (ko >= 29 && ko <= 38)) {
    return pipeline_asm_emit_assign_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 20) {
    return pipeline_asm_emit_logand_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 21) {
    return pipeline_asm_emit_logor_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (ko == 44) {
    ns_tag = pipeline_expr_enum_namespace_field_tag(arena, expr_ref);
    if (ns_tag >= 0) {
      return backend_enc_mov_imm32_to_w0_arch(elf_ctx, ns_tag, ta);
    }
    return -1;
  }
  return backend_emit_expr_elf_slow(arena, elf_ctx, expr_ref, ctx, ta);
}
