/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

int32_t glue_array_lit_emit_scalar_elem_to_rax_elf_c(void *arena, void *elf_ctx, int32_t array_lit_ref,
                                                     int32_t elem_ref, void *ctx, int32_t ta, int32_t force_esz) {
  int32_t eko, ety, ek, lo, hi, fb;
  if (!arena || !elf_ctx || elem_ref <= 0) return -1;
  eko = pipeline_expr_kind_ord_at(arena, elem_ref);
  if (eko == 1) {
    ety = pipeline_asm_array_lit_elem_type_ref(arena, array_lit_ref);
    ek = ety > 0 ? pipeline_type_kind_ord_at(arena, ety) : -1;
    if (ek == 14 || ek == 15)
      return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, elem_ref, ta, ety, 0);
    if (force_esz == 4) {
      lo = pipeline_expr_float_bits_lo_at(arena, elem_ref);
      hi = pipeline_expr_float_bits_hi_at(arena, elem_ref);
      fb = glue_ieee_f64_bits_to_f32_bits(lo, hi);
      return backend_enc_mov_imm32_to_w0_arch(elf_ctx, fb, ta);
    }
    return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, elem_ref, ta, 0, 0);
  }
  if (!ctx) return -1;
  return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, elem_ref, ctx, ta);
}
