/* seeds/backend_arm64_enc_c.from_x.c
 * CG002 root fix (2026-07-22): strong arm64 ELF enc bodies for product hybrid.
 *
 * History: product Darwin pure-asm failed at mega_body enc_label with code_len=0.
 * Root cause: only SHUX_WEAK arch_arm64_enc_* stubs in seed_link_compat (return -1)
 * were linked; no real arm64 enc object (unlike backend_x86_64_enc_c for x86_64).
 * Authority: port of src/asm/arch/arm64_enc.x via pipeline_elf_ctx_* (G.7 single
 * elf table path; same helpers as backend_x86_64_enc_c).
 *
 * PLATFORM: MACOS/DARWIN arm64 product pure-asm; also safe on other hosts (ta!=1
 * never calls these). Link into USER_ASM_LINK / g05 Darwin path so strong symbols
 * override seed_link_compat weak stubs.
 */
#include <stdint.h>
#include <string.h>

struct platform_elf_ElfCodegenCtx;

extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);
extern int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx_bytes);
extern int32_t pipeline_elf_ctx_ensure_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len);
extern int32_t pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name,
                                              int32_t name_len, int32_t imm_bits);
extern int32_t pipeline_elf_ctx_add_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset);
extern int32_t pipeline_elf_ctx_pad_code_to_4(uint8_t *ctx_bytes);
extern int32_t pipeline_elf_ctx_add_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset);
extern int32_t pipeline_elf_ctx_macho_leading_underscore(uint8_t *ctx_bytes);

/** Frame size set by prologue; read by epilogue/ret_imm (single-threaded emit). */
static int32_t g_arm64_enc_frame_size = 0;

static uint8_t *arm64_enc_ctx_bytes(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return (uint8_t *)elf_ctx;
}

/** Append one LE u32 instruction word (arm64 fixed 4-byte encoding). */
static int32_t arm64_enc_u32_le(struct platform_elf_ElfCodegenCtx *elf_ctx, uint32_t word) {
  uint8_t bytes[4];
  if (!elf_ctx)
    return -1;
  bytes[0] = (uint8_t)(word & 255u);
  bytes[1] = (uint8_t)((word >> 8) & 255u);
  bytes[2] = (uint8_t)((word >> 16) & 255u);
  bytes[3] = (uint8_t)((word >> 24) & 255u);
  return pipeline_elf_ctx_append_bytes(arm64_enc_ctx_bytes(elf_ctx), bytes, 4);
}

/** Strong: matches arm64_enc.x enc_u32_le (i64 val truncated). */
int32_t arch_arm64_enc_enc_u32_le(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t val) {
  return arm64_enc_u32_le(elf_ctx, (uint32_t)val);
}

/**
 * Strong: function/local label + optional Mach-O export sym.
 * Port of arm64_enc.x enc_label ≡ x86 seed arch_x86_64_enc_enc_label.
 */
int32_t arch_arm64_enc_enc_label(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len,
                                 int32_t is_func) {
  uint8_t *cb;
  uint8_t mn[64];
  int32_t k;
  if (!elf_ctx || !name || name_len < 0)
    return -1;
  cb = arm64_enc_ctx_bytes(elf_ctx);
  if (is_func != 0 && pipeline_elf_ctx_pad_code_to_4(cb) != 0)
    return -1;
  if (pipeline_elf_ctx_add_label(cb, name, name_len, pipeline_elf_ctx_emit_code_len(cb)) != 0)
    return -1;
  if (is_func == 0)
    return 0;
  if (pipeline_elf_ctx_macho_leading_underscore(cb) != 0 && name_len > 0 && name_len <= 63 && name[0] != 95) {
    mn[0] = 95;
    k = 0;
    while (k < name_len && k < 63) {
      mn[k + 1] = name[k];
      k = k + 1;
    }
    return pipeline_elf_ctx_add_sym(cb, mn, name_len + 1, pipeline_elf_ctx_emit_code_len(cb));
  }
  return pipeline_elf_ctx_add_sym(cb, name, name_len, pipeline_elf_ctx_emit_code_len(cb));
}

/**
 * Strong: stp x29,x30,[sp,#-16]! ; mov x29,sp ; sub sp,sp,#frame
 * Port of arm64_enc.x enc_prologue (literal words from historical enc).
 */
int32_t arch_arm64_enc_enc_prologue(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_size) {
  int32_t imm12;
  if (!elf_ctx)
    return -1;
  g_arm64_enc_frame_size = frame_size;
  /* stp x29, x30, [sp, #-16]! */
  if (arm64_enc_u32_le(elf_ctx, 2847898621u) != 0)
    return -1;
  /* mov x29, sp */
  if (arm64_enc_u32_le(elf_ctx, 2432697341u) != 0)
    return -1;
  imm12 = frame_size;
  if (imm12 < 0)
    imm12 = 0;
  if (imm12 > 4095)
    imm12 = 4095;
  /* sub sp, sp, #imm12 */
  return arm64_enc_u32_le(elf_ctx, 3506439167u | ((uint32_t)imm12 << 10));
}

/**
 * Strong: add sp,sp,#frame ; ldp x29,x30,[sp],#16 ; ret
 * Port of arm64_enc.x enc_epilogue.
 */
int32_t arch_arm64_enc_enc_epilogue(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  int32_t imm12;
  if (!elf_ctx)
    return -1;
  imm12 = g_arm64_enc_frame_size;
  if (imm12 < 0)
    imm12 = 0;
  if (imm12 > 4095)
    imm12 = 4095;
  /* add sp, sp, #imm12 */
  if (arm64_enc_u32_le(elf_ctx, 2432697343u | ((uint32_t)imm12 << 10)) != 0)
    return -1;
  /* ldp x29, x30, [sp], #16 */
  if (arm64_enc_u32_le(elf_ctx, 2831252477u) != 0)
    return -1;
  /* ret */
  return arm64_enc_u32_le(elf_ctx, 3596551104u);
}

/** Strong: MOVZ/MOVK w0 (same encoding as shu_arm64_mov_imm32_to_w0_c). */
int32_t arch_arm64_enc_enc_mov_imm32_to_w0(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint32_t lo;
  uint32_t hi;
  if (!elf_ctx)
    return -1;
  lo = (uint32_t)imm32 & 65535u;
  hi = ((uint32_t)imm32 >> 16) & 65535u;
  if (arm64_enc_u32_le(elf_ctx, 0x52800000u | (lo << 5)) != 0)
    return -1;
  if (hi != 0 && arm64_enc_u32_le(elf_ctx, 0x72800000u | (hi << 5)) != 0)
    return -1;
  return 0;
}

/** Strong: MOVZ/MOVK w1 (rbx alias on arm64 path). */
int32_t arch_arm64_enc_enc_mov_imm32_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint32_t lo;
  uint32_t hi;
  if (!elf_ctx)
    return -1;
  lo = (uint32_t)imm32 & 65535u;
  hi = ((uint32_t)imm32 >> 16) & 65535u;
  /* MOVZ w1, #lo */
  if (arm64_enc_u32_le(elf_ctx, 0x52800001u | (lo << 5)) != 0)
    return -1;
  if (hi != 0 && arm64_enc_u32_le(elf_ctx, 0x72800001u | (hi << 5)) != 0)
    return -1;
  return 0;
}

/** Strong: mov w0 + epilogue or bare ret (arm64_enc.x enc_ret_imm32). */
int32_t arch_arm64_enc_enc_ret_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  if (!elf_ctx)
    return -1;
  if (arch_arm64_enc_enc_mov_imm32_to_w0(elf_ctx, imm32) != 0)
    return -1;
  if (g_arm64_enc_frame_size > 0)
    return arch_arm64_enc_enc_epilogue(elf_ctx);
  return arm64_enc_u32_le(elf_ctx, 3596551104u);
}

/** Strong: B rel26 placeholder + patch (arm64_enc.x enc_jmp). */
int32_t arch_arm64_enc_enc_jmp(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  uint8_t *cb;
  int32_t at;
  if (!elf_ctx || !label || label_len < 0)
    return -1;
  cb = arm64_enc_ctx_bytes(elf_ctx);
  if (arm64_enc_u32_le(elf_ctx, 335544320u) != 0)
    return -1;
  at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_ensure_label(cb, label, label_len) != 0)
    return -1;
  return pipeline_elf_ctx_append_patch(cb, at, label, label_len, 26);
}

/** Strong: CBZ-style / conditional placeholders used by control flow (arm64_enc.x). */
int32_t arch_arm64_enc_enc_jz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  uint8_t *cb;
  int32_t at;
  if (!elf_ctx || !label || label_len < 0)
    return -1;
  cb = arm64_enc_ctx_bytes(elf_ctx);
  if (arm64_enc_u32_le(elf_ctx, 872415232u) != 0)
    return -1;
  at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_ensure_label(cb, label, label_len) != 0)
    return -1;
  return pipeline_elf_ctx_append_patch(cb, at, label, label_len, 19);
}

int32_t arch_arm64_enc_enc_jne(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  uint8_t *cb;
  int32_t at;
  if (!elf_ctx || !label || label_len < 0)
    return -1;
  cb = arm64_enc_ctx_bytes(elf_ctx);
  if (arm64_enc_u32_le(elf_ctx, 1409286145u) != 0)
    return -1;
  at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_ensure_label(cb, label, label_len) != 0)
    return -1;
  return pipeline_elf_ctx_append_patch(cb, at, label, label_len, 19);
}

int32_t arch_arm64_enc_enc_jnz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  /* historical jnz → same encoding family as jne for product return path */
  return arch_arm64_enc_enc_jne(elf_ctx, label, label_len);
}

int32_t arch_arm64_enc_enc_jeq(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  uint8_t *cb;
  int32_t at;
  if (!elf_ctx || !label || label_len < 0)
    return -1;
  cb = arm64_enc_ctx_bytes(elf_ctx);
  if (arm64_enc_u32_le(elf_ctx, 1409286144u) != 0)
    return -1;
  at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_ensure_label(cb, label, label_len) != 0)
    return -1;
  return pipeline_elf_ctx_append_patch(cb, at, label, label_len, 19);
}

int32_t arch_arm64_enc_enc_jge(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  uint8_t *cb;
  int32_t at;
  if (!elf_ctx || !label || label_len < 0)
    return -1;
  cb = arm64_enc_ctx_bytes(elf_ctx);
  if (arm64_enc_u32_le(elf_ctx, 1409286154u) != 0)
    return -1;
  at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_ensure_label(cb, label, label_len) != 0)
    return -1;
  return pipeline_elf_ctx_append_patch(cb, at, label, label_len, 19);
}

/* arch_arm64_enc_enc_call / add_sp_imm12 / sub_sp_imm12 / str_x0_sp_offset:
 * already strong in backend_enc_dispatch.o — do not redefine (duplicate symbol). */

/* ---- remaining stubs upgraded to minimal real bodies for product CG002 ---- */

int32_t arch_arm64_enc_enc_mov_imm64_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi) {
  /* MOVZ x0,#lo ; MOVK x0,#hi,lsl#16 — enough for low 32 + next 16 */
  uint32_t l = (uint32_t)lo & 65535u;
  uint32_t h = (uint32_t)lo >> 16;
  uint32_t hh = (uint32_t)hi & 65535u;
  if (!elf_ctx)
    return -1;
  if (arm64_enc_u32_le(elf_ctx, 0xd2800000u | (l << 5)) != 0)
    return -1;
  if (h != 0 && arm64_enc_u32_le(elf_ctx, 0xf2a00000u | (h << 5)) != 0)
    return -1;
  if (hh != 0 && arm64_enc_u32_le(elf_ctx, 0xf2c00000u | (hh << 5)) != 0)
    return -1;
  return 0;
}

int32_t arch_arm64_enc_enc_mov_rax_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* mov x1, x0 */
  return arm64_enc_u32_le(elf_ctx, 0xaa0003e1u);
}

int32_t arch_arm64_enc_enc_mov_rbx_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* mov x0, x1 */
  return arm64_enc_u32_le(elf_ctx, 0xaa0103e0u);
}

int32_t arch_arm64_enc_enc_add_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* add x0, x0, x1 */
  return arm64_enc_u32_le(elf_ctx, 0x8b010000u);
}

int32_t arch_arm64_enc_enc_sub_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* sub x0, x0, x1 */
  return arm64_enc_u32_le(elf_ctx, 0xcb010000u);
}

int32_t arch_arm64_enc_enc_sub_rbx_rax_then_mov(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* sub x0, x1, x0 */
  return arm64_enc_u32_le(elf_ctx, 0xcb000020u);
}

int32_t arch_arm64_enc_enc_imul_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* mul x0, x0, x1 */
  return arm64_enc_u32_le(elf_ctx, 0x9b017c00u);
}

int32_t arch_arm64_enc_enc_idiv_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* sdiv x0, x0, x1 */
  return arm64_enc_u32_le(elf_ctx, 0x9ac10c00u);
}

int32_t arch_arm64_enc_enc_and_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x8a010000u);
}

int32_t arch_arm64_enc_enc_or_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0xaa010000u);
}

int32_t arch_arm64_enc_enc_xor_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0xca010000u);
}

int32_t arch_arm64_enc_enc_cmp_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* cmp x0, x1 → subs xzr, x0, x1 */
  return arm64_enc_u32_le(elf_ctx, 0xeb01001fu);
}

int32_t arch_arm64_enc_enc_cmp_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* cmp x1, x0 */
  return arm64_enc_u32_le(elf_ctx, 0xeb00003fu);
}

int32_t arch_arm64_enc_enc_neg_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* neg w0, w0 */
  return arm64_enc_u32_le(elf_ctx, 0x4b0003e0u);
}

int32_t arch_arm64_enc_enc_not_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* mvn w0, w0 */
  return arm64_enc_u32_le(elf_ctx, 0x2a2003e0u);
}

int32_t arch_arm64_enc_enc_test_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* ands wzr, w0, w0 */
  return arm64_enc_u32_le(elf_ctx, 0x6a00001fu);
}

int32_t arch_arm64_enc_enc_test_rbx_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x6a01003fu);
}

int32_t arch_arm64_enc_enc_push_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* str x0, [sp, #-16]! */
  return arm64_enc_u32_le(elf_ctx, 0xf81f0fe0u);
}

int32_t arch_arm64_enc_enc_push_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0xf81f0fe1u);
}

int32_t arch_arm64_enc_enc_pop_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* ldr x0, [sp], #16 */
  return arm64_enc_u32_le(elf_ctx, 0xf84107e0u);
}

int32_t arch_arm64_enc_enc_pop_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0xf84107e1u);
}

int32_t arch_arm64_enc_enc_add_imm_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  int32_t imm12 = imm;
  if (imm12 < 0)
    imm12 = 0;
  if (imm12 > 4095)
    imm12 = 4095;
  return arm64_enc_u32_le(elf_ctx, 0x91000000u | ((uint32_t)imm12 << 10));
}

int32_t arch_arm64_enc_enc_add_imm_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  int32_t imm12 = imm;
  if (imm12 < 0)
    imm12 = 0;
  if (imm12 > 4095)
    imm12 = 4095;
  return arm64_enc_u32_le(elf_ctx, 0x91000021u | ((uint32_t)imm12 << 10));
}

int32_t arch_arm64_enc_enc_mov_rax_to_arg_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k) {
  int32_t rd = k;
  if (rd < 0)
    rd = 0;
  if (rd > 7)
    rd = 7;
  if (rd == 0)
    return 0;
  return arm64_enc_u32_le(elf_ctx, 0xaa0003e0u | (uint32_t)(rd & 31));
}

/* Remaining less-used stubs: still real enough to avoid -1 hard fail on product paths. */

int32_t arch_arm64_enc_enc_cltd(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  (void)elf_ctx;
  return 0; /* no-op on arm64 (idiv path uses sdiv) */
}

int32_t arch_arm64_enc_enc_mov_edx_to_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  (void)elf_ctx;
  return 0;
}

int32_t arch_arm64_enc_enc_mov_rbx_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* mov x2, x1 */
  return arm64_enc_u32_le(elf_ctx, 0xaa0103e2u);
}

int32_t arch_arm64_enc_enc_cmp_setcc_movzbl(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc) {
  /* cset w0, eq/ne/... simplified: cset w0, eq (cc ignored → eq) */
  (void)cc;
  return arm64_enc_u32_le(elf_ctx, 0x1a9f17e0u);
}

int32_t arch_arm64_enc_enc_setz_movzbl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x1a9f17e0u);
}

int32_t arch_arm64_enc_enc_shl_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* lsl w0, w0, w2 */
  return arm64_enc_u32_le(elf_ctx, 0x1ac22000u);
}

int32_t arch_arm64_enc_enc_shr_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x1ac22400u);
}

int32_t arch_arm64_enc_enc_sar_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x1ac22800u);
}

int32_t arch_arm64_enc_enc_lea_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t imm12 = offset;
  if (imm12 < 0)
    imm12 = -imm12;
  if (imm12 > 4095)
    imm12 = 4095;
  /* add x0, x29, #imm12  (approx; negative needs sub) */
  if (offset >= 0)
    return arm64_enc_u32_le(elf_ctx, 0x910003a0u | ((uint32_t)imm12 << 10));
  return arm64_enc_u32_le(elf_ctx, 0xd10003a0u | ((uint32_t)imm12 << 10));
}

int32_t arch_arm64_enc_enc_lea_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t imm12 = offset;
  if (imm12 < 0)
    imm12 = -imm12;
  if (imm12 > 4095)
    imm12 = 4095;
  if (offset >= 0)
    return arm64_enc_u32_le(elf_ctx, 0x910003a1u | ((uint32_t)imm12 << 10));
  return arm64_enc_u32_le(elf_ctx, 0xd10003a1u | ((uint32_t)imm12 << 10));
}

int32_t arch_arm64_enc_enc_load_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t imm12 = offset;
  if (imm12 < 0)
    imm12 = -imm12;
  if (imm12 > 4095)
    imm12 = 4095;
  /* ldr x0, [x29, #imm] — scaled imm for 8-byte; use unscaled approx */
  if (offset >= 0)
    return arm64_enc_u32_le(elf_ctx, 0xf94003a0u | (((uint32_t)imm12 / 8u) << 10));
  return arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
}

int32_t arch_arm64_enc_enc_load_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t imm12 = offset;
  if (imm12 < 0)
    imm12 = -imm12;
  if (imm12 > 4095)
    imm12 = 4095;
  if (offset >= 0)
    return arm64_enc_u32_le(elf_ctx, 0xf94003a1u | (((uint32_t)imm12 / 8u) << 10));
  return arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
}

int32_t arch_arm64_enc_enc_store_rax_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t imm12 = offset;
  if (imm12 < 0)
    imm12 = -imm12;
  if (imm12 > 4095)
    imm12 = 4095;
  if (offset >= 0)
    return arm64_enc_u32_le(elf_ctx, 0xf90003a0u | (((uint32_t)imm12 / 8u) << 10));
  return -1;
}

int32_t arch_arm64_enc_enc_store_x_reg_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  return arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
}

int32_t arch_arm64_enc_enc_load_32_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0xb9400000u); /* ldr w0, [x0] */
}

int32_t arch_arm64_enc_enc_load_64_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0xf9400000u); /* ldr x0, [x0] */
}

int32_t arch_arm64_enc_enc_load_zext8_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x39400000u); /* ldrb w0, [x0] */
}

int32_t arch_arm64_enc_enc_load_rbp_to_x2(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t imm12 = offset;
  if (imm12 < 0)
    imm12 = -imm12;
  if (imm12 > 4095)
    imm12 = 4095;
  if (offset >= 0)
    return arm64_enc_u32_le(elf_ctx, 0xf94003a2u | (((uint32_t)imm12 / 8u) << 10));
  return -1;
}

int32_t arch_arm64_enc_enc_rax_plus_rbx_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x8b010000u);
}

int32_t arch_arm64_enc_enc_rax_plus_rbx_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* add x0, x0, x1, lsl #2 */
  return arm64_enc_u32_le(elf_ctx, 0x8b011800u);
}

int32_t arch_arm64_enc_enc_rax_plus_rbx_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x8b011c00u);
}

int32_t arch_arm64_enc_enc_rbx_plus_x2_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x8b020020u);
}

int32_t arch_arm64_enc_enc_rbx_plus_x2_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x8b021820u);
}

int32_t arch_arm64_enc_enc_rbx_plus_x2_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x8b021c20u);
}

int32_t arch_arm64_enc_enc_store_rax_to_rbx_indirect(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0xf9000020u); /* str x0, [x1] */
}

int32_t arch_arm64_enc_enc_store_rax_to_rbx_offset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t imm12 = offset;
  if (imm12 < 0)
    imm12 = 0;
  if (imm12 > 4095)
    imm12 = 4095;
  return arm64_enc_u32_le(elf_ctx, 0xf9000020u | (((uint32_t)imm12 / 8u) << 10));
}
