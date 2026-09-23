/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

/* Stage 12.0.5 cold twin: canonicalize formal in rax before param_home store.
 * PLATFORM: SHARED — pure leave owns product; cold under #ifndef FROM_X. */
int32_t glue_enc_canonicalize_param_in_rax_elf_c(void *elf_ctx, void *arena, void *mod,
                                                  int32_t func_index, int32_t param_index,
                                                  int32_t ta) {
  int32_t pty;
  int32_t kind_ord;
  if (!elf_ctx)
    return -1;
  if (!arena || !mod || func_index < 0 || param_index < 0)
    return 0;
  pty = pipeline_module_func_param_type_ref_at(mod, func_index, param_index);
  if (pty <= 0)
    return 0;
  kind_ord = pipeline_type_kind_ord_at(arena, pty);
  if (kind_ord == 0)
    return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
  if (kind_ord == 3)
    return glue_enc_zxt_u32_result_to_rax_elf_c(elf_ctx, ta);
  if (kind_ord == 1 || kind_ord == 2)
    return glue_enc_zxt_u8_result_to_rax_elf_c(elf_ctx, ta);
  return 0;
}

/* Stage 12.0.5 cold twin: ARM64 MOV X0, Xn. PLATFORM: MACOS|ARM64. */
int32_t glue_enc_arm64_mov_xn_to_x0_elf_c(void *elf_ctx, int32_t reg) {
  uint8_t insn[4];
  int32_t word;
  if (!elf_ctx)
    return -1;
  if (reg <= 0 || reg > 31)
    return 0;
  word = (int32_t)0xAA0003E0 | (reg << 16);
  insn[0] = (uint8_t)(word & 255);
  insn[1] = (uint8_t)((word >> 8) & 255);
  insn[2] = (uint8_t)((word >> 16) & 255);
  insn[3] = (uint8_t)((word >> 24) & 255);
  return pipeline_elf_ctx_append_bytes(elf_ctx, insn, 4);
}

