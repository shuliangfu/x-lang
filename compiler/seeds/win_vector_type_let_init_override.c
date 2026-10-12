/* PLATFORM: WINDOWS leftover-PE — real glue_emit_vector_type_let_init_elf_c.
 * Twin of FROM_X (partial: no select/shuffle/fma3 on leftover). Class X.
 * Link FIRST with -Wl,--allow-multiple-definition over leftover stub in pabi.
 */
#include <stdint.h>

/* wave773 Class X: was empty stub return -2. Twin of FROM_X glue_emit_vector_type_let_init
 * (ARRAY_LIT→mangled vector_let_init; VAR/binop/splat/binop2). select/shuffle/fma3 absent
 * on Win PE leftover — leave -2. PLATFORM: WINDOWS leftover-PE. */
extern int32_t asm_type_is_simd_vector_spelling(void *arena, int32_t type_ref);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32(
    void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta, int32_t stack_slot_off);
extern int32_t pipeline_asm_emit_vector_var_copy_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                       void *ctx, int32_t ta, int32_t stack_slot_off,
                                                       int32_t type_ref);
extern int32_t glue_is_vector_lane_scalar_binop_ko(int32_t ko);
extern int32_t pipeline_asm_emit_vector_binop_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                             void *ctx, int32_t ta, int32_t stack_slot_off,
                                                             int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_select_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                             void *ctx, int32_t ta, int32_t stack_slot_off,
                                                             int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_shuffle_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                              void *ctx, int32_t ta, int32_t stack_slot_off,
                                                              int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_fma3_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                            void *ctx, int32_t ta, int32_t stack_slot_off,
                                                            int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_splat_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                             void *ctx, int32_t ta, int32_t stack_slot_off,
                                                             int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_binop2_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                              void *ctx, int32_t ta, int32_t stack_slot_off,
                                                              int32_t type_ref);
int32_t glue_emit_vector_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx,
                                             int32_t ta, int32_t stack_slot_off, int32_t type_ref) {
  int32_t ko;
  int32_t inl;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0 || !asm_type_is_simd_vector_spelling(arena, type_ref))
    return -2;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (ko == 46)
    return pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32(
        arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
  if (ko == 3)
    return pipeline_asm_emit_vector_var_copy_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off,
                                                   type_ref);
  if (glue_is_vector_lane_scalar_binop_ko(ko))
    return pipeline_asm_emit_vector_binop_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         stack_slot_off, type_ref);
  /* CALL=48 / METHOD_CALL=49 — Class Y: wire select/shuffle/fma3 */
  if (ko == 48 || ko == 49) {
    inl = pipeline_asm_simd_try_inline_splat_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                        stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_select_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                        stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_shuffle_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_fma3_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                       stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_binop2_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
  }
  return -2;
}
