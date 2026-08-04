/**
 * pipeline_asm_emit_lea_common.c — asm ELF COMMON label address load domain
 * (BC 8.3.1 · wave1027).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding COMMON/durable label
 * address materialisation shared across multiple emit leaves:
 * - glue_asm_lea_rax_common_rip_x86 (x86_64 lea rax, [rip+disp32] + reloc)
 * - glue_asm_lea_rbx_common_rip_x86 (x86_64 lea rbx, [rip+disp32] + reloc)
 * - glue_arm64_mov_x0_to_x8_elf_c (AAPCS64 sret: mov x8, x0 — Indirect
 *   Result Location register setup for large-struct CALL return)
 * - glue_arm64_mov_x8_to_x0_elf_c (AAPCS64 sret: mov x0, x8 — save incoming
 *   sret dest for callee store)
 * - glue_asm_lea_rbx_common_adrp_arm64 (arm64 adrp x1 + add pageoff → rbx)
 * - glue_asm_lea_rax_common_adrp_arm64 (arm64 adrp x0 + add pageoff → rax)
 *
 * G.7: single product-mega COMMON label lea + arm64 sret mov face — do not
 * open a second lea_common or arm64 sret mov path outside this leaf.
 * Callers: call_args (lea rax/rbx for named struct pass_addr); array_lit
 * (lea rax/rbx for durable ptr); return (lea rax/rbx for panic/sret label);
 * field_access + struct_let (arm64 mov x0→x8 for sret setup); glue residual
 * (arm64 mov x0→x8 for callee sret path).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the
 * former lea/arm64 body site (after g_pipeline_asm_al_nc_seq; before
 * GLUE_ARRAY_LIT_MAX_ELEMS defines + array_lit forward decls).
 *
 * PLATFORM: SHARED freestanding emit · LINUX+MACOS x86_64 SysV (rip-relative
 * lea + R_X86_64_PC32 reloc) · MACOS|ARM64 AAPCS64 (adrp+add PAGE21/PAGEOFF12
 * + R_AARCH64_ADR_PREL_PG_HI21 / R_AARCH64_ADD_ABS_LO12_NC relocs; sret x8).
 * Host-cc via pipeline_x.o TU.
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - pipeline_elf_ctx_append_bytes / pipeline_elf_ctx_emit_code_len /
 *   pipeline_elf_ctx_append_reloc (ast_pool.c; extern via backend enc surface)
 * - pipeline_elf_ctx_append_reloc_typed (ast_pool.c; extern below for
 *   arm64 PAGE21/PAGEOFF12 typed relocs)
 * - g_pipeline_asm_emit_module / g_pipeline_asm_emit_elf_ctx
 */

/* wave405 typed reloc (PAGE21/PAGEOFF12) — also used by wave408 durable ADRP.
 * (Kept here so arm64 lea helpers in this leaf see the prototype; a duplicate
 * extern exists later in pipeline_glue.c for post-include residual callers.) */
extern int32_t pipeline_elf_ctx_append_reloc_typed(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len,
                                                   int32_t r_type, int32_t r_pcrel);

/**
 * x86_64 lea rax, [rip+disp32] → address of named COMMON/durable label.
 * Emits 7-byte opcode (48 8d 05 disp32) + R_X86_64_PC32 reloc at disp32 slot.
 * PLATFORM: LINUX+MACOS x86_64 SysV — rip-relative addressing.
 */
static int32_t glue_asm_lea_rax_common_rip_x86(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                               int32_t name_len) {
  uint8_t lea7[7];
  int32_t rel32_at;
  if (!elf_ctx || !name || name_len <= 0)
    return -1;
  /* 48 8d 05 disp32  →  lea rax, [rip+disp32] */
  lea7[0] = 0x48;
  lea7[1] = 0x8d;
  lea7[2] = 0x05;
  lea7[3] = 0;
  lea7[4] = 0;
  lea7[5] = 0;
  lea7[6] = 0;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, lea7, 7) != 0)
    return -1;
  rel32_at = pipeline_elf_ctx_emit_code_len((uint8_t *)elf_ctx) - 4;
  return pipeline_elf_ctx_append_reloc((uint8_t *)elf_ctx, rel32_at, name, name_len);
}

/**
 * x86_64 lea rbx, [rip+disp32] → address of named COMMON/durable label.
 * Emits 7-byte opcode (48 8d 1d disp32) + R_X86_64_PC32 reloc at disp32 slot.
 * PLATFORM: LINUX+MACOS x86_64 SysV — rip-relative addressing.
 */
static int32_t glue_asm_lea_rbx_common_rip_x86(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                               int32_t name_len) {
  uint8_t lea7[7];
  int32_t rel32_at;
  if (!elf_ctx || !name || name_len <= 0)
    return -1;
  /* 48 8d 1d disp32  →  lea rbx, [rip+disp32] */
  lea7[0] = 0x48;
  lea7[1] = 0x8d;
  lea7[2] = 0x1d;
  lea7[3] = 0;
  lea7[4] = 0;
  lea7[5] = 0;
  lea7[6] = 0;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, lea7, 7) != 0)
    return -1;
  rel32_at = pipeline_elf_ctx_emit_code_len((uint8_t *)elf_ctx) - 4;
  return pipeline_elf_ctx_append_reloc((uint8_t *)elf_ctx, rel32_at, name, name_len);
}

/**
 * PLATFORM: MACOS|ARM64 AAPCS64 — mov x8, x0 (Indirect Result Location = dest).
 * wave591: large-struct CALL sret setup; x8 is not an arg-reg index (0..7).
 * Encoding: ORR X8, XZR, X0 → 0xAA0003E8.
 */
static int32_t glue_arm64_mov_x0_to_x8_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t insn[4];
  if (!elf_ctx)
    return -1;
  insn[0] = 0xe8;
  insn[1] = 0x03;
  insn[2] = 0x00;
  insn[3] = 0xaa;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, insn, 4);
}

/**
 * PLATFORM: MACOS|ARM64 AAPCS64 — mov x0, x8 (save incoming sret dest for store).
 * Encoding: ORR X0, XZR, X8 → 0xAA0803E0.
 */
static int32_t glue_arm64_mov_x8_to_x0_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t insn[4];
  if (!elf_ctx)
    return -1;
  insn[0] = 0xe0;
  insn[1] = 0x03;
  insn[2] = 0x08;
  insn[3] = 0xaa;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, insn, 4);
}

/**
 * PLATFORM: MACOS|ARM64 — adrp x1 + add pageoff → address of named COMMON in x1 (rbx).
 * G.7 twin of pipeline_asm_modlet_lea_rbx_adrp_arm64 but for arbitrary durable labels
 * (wave408 ARRAY_LIT durable; not only modlet table).
 * Reloc types: 3 = R_AARCH64_ADR_PREL_PG_HI21 (adrp, pcrel=1);
 *              4 = R_AARCH64_ADD_ABS_LO12_NC (add, pcrel=0).
 */
static int32_t glue_asm_lea_rbx_common_adrp_arm64(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                                   int32_t name_len) {
  uint8_t *cb;
  uint8_t adrp4[4];
  uint8_t add4[4];
  int32_t adrp_at;
  int32_t add_at;
  if (!elf_ctx || !name || name_len <= 0)
    return -1;
  cb = (uint8_t *)elf_ctx;
  /* adrp x1, #0 → 0x90000001 */
  adrp4[0] = 0x01;
  adrp4[1] = 0x00;
  adrp4[2] = 0x00;
  adrp4[3] = 0x90;
  if (pipeline_elf_ctx_append_bytes(cb, adrp4, 4) != 0)
    return -1;
  adrp_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_append_reloc_typed(cb, adrp_at, name, name_len, 3, 1) != 0)
    return -1;
  /* add x1, x1, #0 → 0x91000021 */
  add4[0] = 0x21;
  add4[1] = 0x00;
  add4[2] = 0x00;
  add4[3] = 0x91;
  if (pipeline_elf_ctx_append_bytes(cb, add4, 4) != 0)
    return -1;
  add_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  return pipeline_elf_ctx_append_reloc_typed(cb, add_at, name, name_len, 4, 0);
}

/**
 * PLATFORM: MACOS|ARM64 — adrp x0 + add pageoff → address of named COMMON in x0 (rax).
 * wave408: durable ARRAY_LIT return/let-init final lea.
 * Reloc types: 3 = R_AARCH64_ADR_PREL_PG_HI21 (adrp, pcrel=1);
 *              4 = R_AARCH64_ADD_ABS_LO12_NC (add, pcrel=0).
 */
static int32_t glue_asm_lea_rax_common_adrp_arm64(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                                   int32_t name_len) {
  uint8_t *cb;
  uint8_t adrp4[4];
  uint8_t add4[4];
  int32_t adrp_at;
  int32_t add_at;
  if (!elf_ctx || !name || name_len <= 0)
    return -1;
  cb = (uint8_t *)elf_ctx;
  /* adrp x0, #0 → 0x90000000 */
  adrp4[0] = 0x00;
  adrp4[1] = 0x00;
  adrp4[2] = 0x00;
  adrp4[3] = 0x90;
  if (pipeline_elf_ctx_append_bytes(cb, adrp4, 4) != 0)
    return -1;
  adrp_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_append_reloc_typed(cb, adrp_at, name, name_len, 3, 1) != 0)
    return -1;
  /* add x0, x0, #0 → 0x91000000 */
  add4[0] = 0x00;
  add4[1] = 0x00;
  add4[2] = 0x00;
  add4[3] = 0x91;
  if (pipeline_elf_ctx_append_bytes(cb, add4, 4) != 0)
    return -1;
  add_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  return pipeline_elf_ctx_append_reloc_typed(cb, add_at, name, name_len, 4, 0);
}
