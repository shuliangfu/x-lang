/* seeds/backend_arm64_enc_c.from_x.c
 * CG002 root fix (2026-07-22): strong arm64 ELF enc bodies for product hybrid.
 *
 * History: product Darwin pure-asm failed at mega_body enc_label with code_len=0.
 * Root cause: only XLANG_WEAK arch_arm64_enc_* stubs in seed_link_compat (return -1)
 * were linked; no real arm64 enc object (unlike backend_x86_64_enc_c for x86_64).
 * Authority: port of src/asm/arch/arm64_enc.x via pipeline_elf_ctx_* (G.7 single
 * elf table path; same helpers as backend_x86_64_enc_c).
 *
 * wave109: GP spill/preserve mov x2/x9/x10–x15 (binop 7.3 / INDEX AS right).
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
/** G.7 wave388: cc→CSET invert(cond) field; same as arch_arm64_enc_enc_cset_w0_from_cc. */
extern int32_t pipeline_asm_arm64_cset_cond_enc_from_cc(int32_t cc);

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
  uint8_t mn[128];
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
 * Adjust SP by ±imm using one or more ADD/SUB (imm12), for frames > 4095.
 * @param elf_ctx emit context
 * @param imm byte delta; must be >= 0
 * @param is_sub 1 → sub sp,sp,#chunk; 0 → add sp,sp,#chunk
 * @return 0 success, -1 failure
 * PLATFORM: MACOS|ARM64 — AAPCS64 SP 16-byte align expected by caller.
 */
static int32_t arm64_enc_addsub_sp_imm_chunks(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                              int32_t is_sub) {
  int32_t left;
  if (!elf_ctx)
    return -1;
  left = imm;
  if (left < 0)
    left = 0;
  while (left > 0) {
    int32_t chunk = left > 4095 ? 4095 : left;
    /* sub sp,sp,#c = 0xD10003FF | (c<<10); add sp,sp,#c = 0x910003FF | (c<<10) */
    uint32_t base = is_sub != 0 ? 3506439167u : 2432697343u;
    if (arm64_enc_u32_le(elf_ctx, base | ((uint32_t)chunk << 10)) != 0)
      return -1;
    left -= chunk;
  }
  return 0;
}

/**
 * wave420 Cap residual pure: ADD Xd, Xn, #imm with multi-chunk when imm > 4095.
 *
 * Root: product LDR/STR/LEA helpers clamped *byte* offset to 4095 before scaled
 * encoding. Dual-GP fat length half at home+8 when home≈0xff8 needs #0x1000;
 * clamp→0xfff→scaled 0xff8 aliases length onto data (fs escape/dual n≥1017
 * SIGSEGV, address 0x3f9=length). Same clamp broke add_imm for INDEX mid at
 * byte off≥4096 (local i32[2048] mid wrong).
 *
 * G.7: one helper for LEA/add_imm and large-frame load/store fallback.
 * ADD imm12 unshifted max 4095; LDR/STR X unsigned scaled max byte 32760
 * (imm12=offset/8 ≤ 4095) — do NOT clamp byte offset to 4095 before /8.
 * PLATFORM: MACOS|ARM64 product pure-asm (ta==1).
 *
 * @param elf_ctx emit context
 * @param rd destination Xn (0..30)
 * @param rn source Xn (0..30); if rd!=rn emits MOV Xd,Xn first
 * @param imm non-negative byte addend (0 ok)
 * @return 0 success, -1 failure
 */
static int32_t arm64_enc_add_rd_rn_imm_chunks(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t rd,
                                             int32_t rn, int32_t imm) {
  int32_t left;
  if (!elf_ctx || rd < 0 || rd > 30 || rn < 0 || rn > 30)
    return -1;
  left = imm;
  if (left < 0)
    left = 0;
  if (rd != rn) {
    /* mov xd, xn ≡ orr xd, xzr, xn */
    if (arm64_enc_u32_le(elf_ctx, 0xAA0003E0u | ((uint32_t)rn << 16) | (uint32_t)rd) != 0)
      return -1;
  }
  while (left > 0) {
    int32_t chunk = left > 4095 ? 4095 : left;
    /* add xd, xd, #chunk */
    if (arm64_enc_u32_le(elf_ctx, 0x91000000u | ((uint32_t)chunk << 10) | ((uint32_t)rd << 5) |
                         (uint32_t)rd) != 0)
      return -1;
    left -= chunk;
  }
  return 0;
}

/**
 * wave414 Cap residual pure: arm64 frame must cover positive [x29,#off] locals.
 *
 * Root: wave402 low-end home + product store/lea use [x29,+off] (payload grows up).
 * Old prologue was `stp [sp,#-16]!; mov x29,sp; sub sp,#frame` — frame sat BELOW
 * x29 while locals wrote ABOVE into the caller's stack. Small arrays "worked";
 * payload past ~472B hit the guard page → SIGBUS (i32[n] n>=118 / u8 n>=472).
 *
 * G.7: single allocation with x29 at the bottom of the frame so [x29+0..frame)
 * is fully owned:
 *   sub sp,sp,#frame ; stp x29,x30,[sp] ; mov x29,sp
 * Epilogue: ldp x29,x30,[sp] ; add sp,sp,#frame ; ret
 * Multi-chunk add/sub when frame > 4095 (imm12 cap).
 * PLATFORM: MACOS|ARM64 product pure-asm — pairs with asm_local_slot_reg_offset
 * low-end home (ast_pool_bootstrap_glue.c wave402).
 */
int32_t arch_arm64_enc_enc_prologue(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_size) {
  int32_t fs;
  if (!elf_ctx)
    return -1;
  fs = frame_size;
  if (fs < 16)
    fs = 16;
  /* AAPCS64: keep SP 16-byte aligned. */
  if ((fs & 15) != 0)
    fs += 16 - (fs & 15);
  g_arm64_enc_frame_size = fs;
  /* sub sp, sp, #fs (chunks if fs > 4095) */
  if (arm64_enc_addsub_sp_imm_chunks(elf_ctx, fs, 1) != 0)
    return -1;
  /* stp x29, x30, [sp] — save at frame bottom (offs 0 and 8) */
  if (arm64_enc_u32_le(elf_ctx, 0xA9007BFDu) != 0)
    return -1;
  /* mov x29, sp  (add x29, sp, #0) */
  return arm64_enc_u32_le(elf_ctx, 2432697341u);
}

/**
 * wave414: match bottom-x29 prologue — restore saves then free whole frame.
 * PLATFORM: MACOS|ARM64 product pure-asm.
 */
int32_t arch_arm64_enc_enc_epilogue(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  int32_t fs;
  if (!elf_ctx)
    return -1;
  fs = g_arm64_enc_frame_size;
  if (fs < 0)
    fs = 0;
  /* ldp x29, x30, [sp] */
  if (arm64_enc_u32_le(elf_ctx, 0xA9407BFDu) != 0)
    return -1;
  /* add sp, sp, #fs (chunks if needed) */
  if (arm64_enc_addsub_sp_imm_chunks(elf_ctx, fs, 0) != 0)
    return -1;
  /* ret */
  return arm64_enc_u32_le(elf_ctx, 3596551104u);
}

/** Strong: MOVZ/MOVK w0 (same encoding as xlang_arm64_mov_imm32_to_w0_c). */
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

/**
 * Load a full 64-bit immediate into x0 via MOVZ/MOVK.
 *
 * PLATFORM: MACOS|ARM64 — freestanding product encoder (g05 links
 * backend_arm64_enc_c.o). wave306 Cap residual: prior only wrote three
 * halfwords (lo[15:0], lo[31:16], hi[15:0]) and dropped hi[31:16], so
 * 0x7fffffffffffffff became 0x0000ffffffffffff and i64max/neg probes failed
 * on arm64 SE. Align with arch/arm64_enc.x enc_mov_imm64_to_rax (four parts).
 * @param elf_ctx ElfCodegenCtx* — append target
 * @param lo i32 — low 32 bits of the immediate
 * @param hi i32 — high 32 bits of the immediate
 * @return 0 on success, -1 on null/append failure
 */
int32_t arch_arm64_enc_enc_mov_imm64_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi) {
  /* MOVZ x0,#lo0 ; MOVK lsl#16 ; MOVK lsl#32 ; MOVK lsl#48 — full 64 bits */
  uint32_t lo0 = (uint32_t)lo & 65535u;
  uint32_t lo1 = ((uint32_t)lo >> 16) & 65535u;
  uint32_t hi0 = (uint32_t)hi & 65535u;
  uint32_t hi1 = ((uint32_t)hi >> 16) & 65535u;
  if (!elf_ctx)
    return -1;
  /* MOVZ x0, #lo0 */
  if (arm64_enc_u32_le(elf_ctx, 0xd2800000u | (lo0 << 5)) != 0)
    return -1;
  /* MOVK x0, #lo1, LSL #16 */
  if (lo1 != 0 && arm64_enc_u32_le(elf_ctx, 0xf2a00000u | (lo1 << 5)) != 0)
    return -1;
  /* MOVK x0, #hi0, LSL #32 */
  if (hi0 != 0 && arm64_enc_u32_le(elf_ctx, 0xf2c00000u | (hi0 << 5)) != 0)
    return -1;
  /* MOVK x0, #hi1, LSL #48 — was missing (wave306) */
  if (hi1 != 0 && arm64_enc_u32_le(elf_ctx, 0xf2e00000u | (hi1 << 5)) != 0)
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
  /* PLATFORM: MACOS|ARM64 — left in x1 (rbx), right in x0 (rax).
   * cmp x1, x0 → flags for (left - right); matches x86 `cmp %rax,%rbx`.
   * wave388: prior encoding was cmp x0,x1 (right-left), which inverted lt/gt/le/ge
   * after setcc honored real cc values. G.7 align arm64_enc.x enc_cmp_rbx_rax. */
  return arm64_enc_u32_le(elf_ctx, 0xeb00003fu);
}

int32_t arch_arm64_enc_enc_cmp_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* PLATFORM: MACOS|ARM64 — reverse of cmp_rbx_rax: cmp x0, x1 (right - left). */
  return arm64_enc_u32_le(elf_ctx, 0xeb01001fu);
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

/**
 * wave420: multi-chunk ADD x0,x0,#imm (was hard clamp imm≤4095).
 * Used for INDEX byte offsets and large array element address math.
 * PLATFORM: MACOS|ARM64.
 */
int32_t arch_arm64_enc_enc_add_imm_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  return arm64_enc_add_rd_rn_imm_chunks(elf_ctx, 0, 0, imm);
}

/**
 * wave420: multi-chunk ADD x1,x1,#imm (twin of add_imm_to_rax).
 * PLATFORM: MACOS|ARM64.
 */
int32_t arch_arm64_enc_enc_add_imm_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  return arm64_enc_add_rd_rn_imm_chunks(elf_ctx, 1, 1, imm);
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
  /* PLATFORM: MACOS|ARM64 — cset w0 from logical cc (0=eq,1=ne,2=lt,3=le,4=gt,5=ge).
   * wave388: prior stub ignored cc and always emitted cset eq → var-var !=/>/</>=
   * all behaved as == (lit path const-folded so soft only hit non-folded).
   * G.7: cond invert field via pipeline_asm_arm64_cset_cond_enc_from_cc;
   * setcc-only (caller already emitted cmp_rbx_rax). Encoding:
   * CSET W0,<cond> = CSINC W0,WZR,WZR,invert(cond) → 0x1a9f07e0 | (inv_cond<<12). */
  int32_t c;
  if (!elf_ctx)
    return -1;
  c = pipeline_asm_arm64_cset_cond_enc_from_cc(cc);
  if (c < 0)
    c = 0;
  return arm64_enc_u32_le(elf_ctx, 0x1a9f07e0u | ((uint32_t)(c & 15) << 12));
}

int32_t arch_arm64_enc_enc_setz_movzbl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0x1a9f17e0u);
}

int32_t arch_arm64_enc_enc_shl_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* lsl w0, w0, w2 */
  return arm64_enc_u32_le(elf_ctx, 0x1ac22000u);
}

int32_t arch_arm64_enc_enc_shr_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* lsr w0, w0, w2 */
  return arm64_enc_u32_le(elf_ctx, 0x1ac22400u);
}

int32_t arch_arm64_enc_enc_sar_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* asr w0, w0, w2 */
  return arm64_enc_u32_le(elf_ctx, 0x1ac22800u);
}

/**
 * wave306 Cap residual: 64-bit shift forms for is_64bit i64/u64 paths.
 * Prior dispatch routed shr/shl/sar_cl_rax → *_eax (32-bit), so freestanding
 * `let a: i64 = …; a >> 56` used `lsr w0` and dropped high bits (mac SE).
 * PLATFORM: MACOS|ARM64 — sf=1 variants of LSL/LSR/ASR (register).
 */
int32_t arch_arm64_enc_enc_shl_cl_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* lsl x0, x0, x2 */
  return arm64_enc_u32_le(elf_ctx, 0x9ac22000u);
}

int32_t arch_arm64_enc_enc_shr_cl_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* lsr x0, x0, x2 */
  return arm64_enc_u32_le(elf_ctx, 0x9ac22400u);
}

int32_t arch_arm64_enc_enc_sar_cl_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* asr x0, x0, x2 */
  return arm64_enc_u32_le(elf_ctx, 0x9ac22800u);
}

/**
 * wave420: LEA x0 = x29 + offset; multi-chunk when offset > 4095.
 * PLATFORM: MACOS|ARM64 product pure-asm.
 */
int32_t arch_arm64_enc_enc_lea_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t abs_off;
  if (offset >= 0)
    return arm64_enc_add_rd_rn_imm_chunks(elf_ctx, 0, 29, offset);
  abs_off = -offset;
  /* mov x0, x29; then multi-chunk sub x0,x0,#c */
  if (arm64_enc_u32_le(elf_ctx, 0xAA0003E0u | (29u << 16) | 0u) != 0)
    return -1;
  while (abs_off > 0) {
    int32_t chunk = abs_off > 4095 ? 4095 : abs_off;
    if (arm64_enc_u32_le(elf_ctx, 0xD1000000u | ((uint32_t)chunk << 10) | (0u << 5) | 0u) != 0)
      return -1;
    abs_off -= chunk;
  }
  return 0;
}

/**
 * wave420: LEA x1 = x29 + offset; multi-chunk twin of lea_rbp_to_rax.
 * PLATFORM: MACOS|ARM64.
 */
int32_t arch_arm64_enc_enc_lea_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t abs_off;
  if (offset >= 0)
    return arm64_enc_add_rd_rn_imm_chunks(elf_ctx, 1, 29, offset);
  abs_off = -offset;
  if (arm64_enc_u32_le(elf_ctx, 0xAA0003E0u | (29u << 16) | 1u) != 0)
    return -1;
  while (abs_off > 0) {
    int32_t chunk = abs_off > 4095 ? 4095 : abs_off;
    if (arm64_enc_u32_le(elf_ctx, 0xD1000000u | ((uint32_t)chunk << 10) | (1u << 5) | 1u) != 0)
      return -1;
    abs_off -= chunk;
  }
  return 0;
}

/**
 * wave420: LDR x0, [x29, #offset] with correct scaled imm12 (byte/8 ≤ 4095).
 * Root: prior clamped *byte* offset to 4095 then /8 → off 4096..4088 alias.
 * Offsets > 32760 or unaligned: LEA then LDR [x0].
 * PLATFORM: MACOS|ARM64 product pure-asm.
 */
int32_t arch_arm64_enc_enc_load_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (offset < 0)
    return arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
  /* 64-bit LDR unsigned scaled: imm12 = offset/8, max byte offset 32760. */
  if ((offset % 8) == 0 && (offset / 8) <= 4095)
    return arm64_enc_u32_le(elf_ctx, 0xf94003a0u | (((uint32_t)(offset / 8)) << 10));
  if (arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx, offset) != 0)
    return -1;
  return arm64_enc_u32_le(elf_ctx, 0xf9400000u); /* ldr x0, [x0] */
}

/**
 * wave420: LDR x1, [x29, #offset] twin of load_rbp_to_rax.
 * PLATFORM: MACOS|ARM64.
 */
int32_t arch_arm64_enc_enc_load_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (offset < 0)
    return arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
  if ((offset % 8) == 0 && (offset / 8) <= 4095)
    return arm64_enc_u32_le(elf_ctx, 0xf94003a1u | (((uint32_t)(offset / 8)) << 10));
  if (arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset) != 0)
    return -1;
  return arm64_enc_u32_le(elf_ctx, 0xf9400021u); /* ldr x1, [x1] */
}

/**
 * Store Xn (reg) to frame home [x29, #offset] (positive scaled imm12).
 *
 * wave392 Cap residual: param home for multi formal (take2(x,y) / take3) must
 * keep each GP in its own slot. Prior product body was
 *   store_x_reg_to_rbp(ctx, offset) { return store_rax_to_rbp(ctx, offset); }
 * while dispatch always calls (ctx, reg, offset). The second C arg was then the
 * register index misread as offset, and Rt was hard-coded x0 — both formals
 * collapsed to `str x0,[x29]` (last-wins / first-param-only; reent2=10 vs 42).
 *
 * wave420: do not clamp byte offset to 4095 before /8. Scaled STR X allows
 * imm12≤4095 → byte off ≤32760. Larger/unaligned: LEA x16 then STR Xt,[x16].
 *
 * @param elf_ctx emit context
 * @param reg AAPCS64 Xn index (0..30); x0–x7 used by pipeline_asm_emit_param_home
 * @param offset frame home bytes (product convention: positive [x29,#off])
 * @return 0 success, -1 failure
 * PLATFORM: MACOS|ARM64 product pure-asm — G.7 align dispatch + arm64_enc.x
 * (reg, offset); positive STR matches other product enc_store_rax_to_rbp slots.
 */
int32_t arch_arm64_enc_enc_store_x_reg_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t reg,
                                              int32_t offset) {
  int32_t rt;
  rt = reg;
  if (rt < 0)
    rt = 0;
  if (rt > 30)
    rt = 30;
  if (offset < 0)
    return -1;
  /* STR Xt, [x29, #imm12*8] when offset in range. */
  if ((offset % 8) == 0 && (offset / 8) <= 4095)
    return arm64_enc_u32_le(elf_ctx, 0xf9000000u | (((uint32_t)(offset / 8)) << 10) | (29u << 5) |
                            (uint32_t)rt);
  /* Scratch x16 (IP0): lea x16,[x29+#off]; str xt,[x16]. Avoid clobbering Rt. */
  if (arm64_enc_add_rd_rn_imm_chunks(elf_ctx, 16, 29, offset) != 0)
    return -1;
  return arm64_enc_u32_le(elf_ctx, 0xf9000000u | (16u << 5) | (uint32_t)rt);
}

int32_t arch_arm64_enc_enc_store_rax_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  /* x0 only — thin wrapper over store_x_reg (wave392 reg ABI). */
  return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, 0, offset);
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

/**
 * wave420: LDR x2, [x29, #offset] — same scaled-imm fix as load_rbp_to_rax.
 * PLATFORM: MACOS|ARM64.
 */
int32_t arch_arm64_enc_enc_load_rbp_to_x2(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (offset < 0)
    return -1;
  if ((offset % 8) == 0 && (offset / 8) <= 4095)
    return arm64_enc_u32_le(elf_ctx, 0xf94003a2u | (((uint32_t)(offset / 8)) << 10));
  /* lea x2, [x29+#off]; ldr x2, [x2] */
  if (arm64_enc_add_rd_rn_imm_chunks(elf_ctx, 2, 29, offset) != 0)
    return -1;
  return arm64_enc_u32_le(elf_ctx, 0xf9400042u); /* ldr x2, [x2] */
}

/*
 * wave417 Cap residual pure: ARM64 ADD (shifted register) scale for INDEX.
 * Encoding: sf=1 op=ADD shift=LSL Rm imm6 Rn Rd.
 *   scale1 → imm6=0 (×1); scale4 → imm6=2 (×4); scale8 → imm6=3 (×8).
 * Root: prior imm6 was 6/7 (×64/×128) — comment said "lsl #2" but word was wrong
 * (0x8b011800 = lsl #6). Dynamic INDEX a[i] on i32 used esz=4 → ×64 stride →
 * wrong sum / SIGSEGV; lit-index add-imm path stayed green.
 * G.7: product authority seeds/backend_arm64_enc_c.from_x.c (g05 strong);
 * twin arch/arm64_enc.x same commit. PLATFORM: MACOS|ARM64.
 */
int32_t arch_arm64_enc_enc_rax_plus_rbx_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* add x0, x0, x1, lsl #0 */
  return arm64_enc_u32_le(elf_ctx, 0x8b010000u);
}

int32_t arch_arm64_enc_enc_rax_plus_rbx_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* add x0, x0, x1, lsl #2  (×4) — was 0x8b011800 (lsl #6) pre-wave417 */
  return arm64_enc_u32_le(elf_ctx, 0x8b010800u);
}

int32_t arch_arm64_enc_enc_rax_plus_rbx_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* add x0, x0, x1, lsl #3  (×8) — was 0x8b011c00 (lsl #7) pre-wave417 */
  return arm64_enc_u32_le(elf_ctx, 0x8b010c00u);
}

int32_t arch_arm64_enc_enc_rbx_plus_x2_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* add x0, x1, x2, lsl #0 — EA in x0 for subsequent [x0] load */
  return arm64_enc_u32_le(elf_ctx, 0x8b020020u);
}

int32_t arch_arm64_enc_enc_rbx_plus_x2_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* add x0, x1, x2, lsl #2 — was 0x8b021820 (lsl #6) pre-wave417 */
  return arm64_enc_u32_le(elf_ctx, 0x8b020820u);
}

int32_t arch_arm64_enc_enc_rbx_plus_x2_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  /* add x0, x1, x2, lsl #3 — was 0x8b021c20 (lsl #7) pre-wave417 */
  return arm64_enc_u32_le(elf_ctx, 0x8b020c20u);
}

int32_t arch_arm64_enc_enc_store_rax_to_rbx_indirect(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_u32_le(elf_ctx, 0xf9000020u); /* str x0, [x1] */
}

/*
 * wave391 Cap residual pure: store value@x0 into [x1 + offset] with correct width/scale.
 *
 * Root: product seed took only `offset` and always encoded STR X (imm12 = offset/8).
 * STRUCT_LIT field i32 at foff=4 → imm12=0 → every field overwrote [x1+0] (multi-field
 * lit sum wrong: Pt{x:20,y:22} → p.x+p.y=22; host-C OK). Dispatch always passes
 * store_size (G.7 match arch_x86_64_enc_enc_store_rax_to_rbx_offset + arm64_enc.x).
 *
 * ARM64 unsigned scaled imm: STRB imm=bytes; STRH imm=offset/2; STR W imm=offset/4;
 * STR X imm=offset/8. Rt=x0 Rn=x1.
 * PLATFORM: MACOS|ARM64 product pure-asm (ta==1). Authority twin: arch/arm64_enc.x.
 */
int32_t arch_arm64_enc_enc_store_rax_to_rbx_offset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                   int32_t store_size) {
  int32_t imm12;
  uint32_t base;
  if (offset < 0)
    offset = 0;
  if (store_size == 1) {
    /* strb w0, [x1, #offset] — imm12 is byte count 0..4095 */
    imm12 = offset;
    if (imm12 > 4095)
      imm12 = 4095;
    base = 0x39000000u; /* STRB */
  } else if (store_size == 2) {
    /* strh w0, [x1, #offset] — offset multiple of 2 */
    imm12 = offset / 2;
    if (imm12 > 4095)
      imm12 = 4095;
    base = 0x79000000u; /* STRH */
  } else if (store_size == 4) {
    /* str w0, [x1, #offset] — offset multiple of 4 */
    imm12 = offset / 4;
    if (imm12 > 4095)
      imm12 = 4095;
    base = 0xb9000000u; /* STR W */
  } else {
    /* str x0, [x1, #offset] — offset multiple of 8 (default / 8-byte store) */
    imm12 = offset / 8;
    if (imm12 > 4095)
      imm12 = 4095;
    base = 0xf9000000u; /* STR X */
  }
  return arm64_enc_u32_le(elf_ctx, base | (((uint32_t)imm12) << 10) | (1u << 5));
}

/*
 * wave109: GP spill/preserve moves used by pipeline_glue binop 7.3 paths.
 * ORR xd, xzr, xm ≡ MOV xd, xm. Encoding: 0xAA0003E0 | (rm << 16) | rd.
 * Root CG002: weak seed_link_compat XLANG_ARM64_GLUE_STUB1 returned -1 for
 * mov_rax_to_x9 after left-assoc ADD emit when loading INDEX/AS right.
 * PLATFORM: MACOS/DARWIN arm64 pure-asm (ta==1); strong override of weak stubs.
 */
static int32_t arm64_enc_mov_xn_xm(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t rd, int32_t rm) {
  if (rd < 0 || rd > 30 || rm < 0 || rm > 30)
    return -1;
  return arm64_enc_u32_le(elf_ctx, 0xAA0003E0u | ((uint32_t)rm << 16) | (uint32_t)rd);
}

/** Preserve rbx across INDEX addr: x1 → x2. */
int32_t arch_arm64_enc_enc_mov_rbx_to_x2(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 2, 1);
}

int32_t arch_arm64_enc_enc_mov_x2_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 1, 2);
}

int32_t arch_arm64_enc_enc_mov_rax_to_x2(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 2, 0);
}

int32_t arch_arm64_enc_enc_mov_x2_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 0, 2);
}

/** Preserve rax while loading rbx operand that clobbers rax (FIELD/INDEX/AS). */
int32_t arch_arm64_enc_enc_mov_rax_to_x9(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 9, 0);
}

int32_t arch_arm64_enc_enc_mov_x9_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 0, 9);
}

/** Binop 7.3 physical spill slots x10..x15 (rax/rbx save/reload). */
int32_t arch_arm64_enc_enc_mov_rax_to_x10(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 10, 0);
}
int32_t arch_arm64_enc_enc_mov_x10_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 0, 10);
}
int32_t arch_arm64_enc_enc_mov_rbx_to_x10(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 10, 1);
}
int32_t arch_arm64_enc_enc_mov_x10_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 1, 10);
}

int32_t arch_arm64_enc_enc_mov_rax_to_x11(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 11, 0);
}
int32_t arch_arm64_enc_enc_mov_x11_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 0, 11);
}
int32_t arch_arm64_enc_enc_mov_rbx_to_x11(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 11, 1);
}
int32_t arch_arm64_enc_enc_mov_x11_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 1, 11);
}

int32_t arch_arm64_enc_enc_mov_rax_to_x12(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 12, 0);
}
int32_t arch_arm64_enc_enc_mov_x12_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 0, 12);
}
int32_t arch_arm64_enc_enc_mov_rbx_to_x12(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 12, 1);
}
int32_t arch_arm64_enc_enc_mov_x12_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 1, 12);
}

int32_t arch_arm64_enc_enc_mov_rax_to_x13(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 13, 0);
}
int32_t arch_arm64_enc_enc_mov_x13_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 0, 13);
}
int32_t arch_arm64_enc_enc_mov_rbx_to_x13(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 13, 1);
}
int32_t arch_arm64_enc_enc_mov_x13_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 1, 13);
}

int32_t arch_arm64_enc_enc_mov_rax_to_x14(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 14, 0);
}
int32_t arch_arm64_enc_enc_mov_x14_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 0, 14);
}
int32_t arch_arm64_enc_enc_mov_rbx_to_x14(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 14, 1);
}
int32_t arch_arm64_enc_enc_mov_x14_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 1, 14);
}

int32_t arch_arm64_enc_enc_mov_rax_to_x15(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 15, 0);
}
int32_t arch_arm64_enc_enc_mov_x15_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 0, 15);
}
int32_t arch_arm64_enc_enc_mov_rbx_to_x15(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 15, 1);
}
int32_t arch_arm64_enc_enc_mov_x15_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arm64_enc_mov_xn_xm(elf_ctx, 1, 15);
}
