/*
 * Override arch_x86_64_enc_enc_prologue (+ epilogue) with a Windows-safe
 * stack probe and w1043 lean small-frame path.
 *
 * A bare sub rsp,imm32 larger than one page skips the guard page and
 * SEGVs on Windows (deep AS/compare array folds).
 *
 * w1043: host thin trampolines use push rbp; sub $0x30 (no push rbx).
 * Tip always pushed rbx and padded sub to ≡8 (mod 16), so a 48B
 * param-home frame became sub $0x48. For frame_sz <= 48 skip rbx and
 * pad to ≡0 (mod 16) so compute_frame 48 → sub $0x30 matching host.
 * Epilogue mirrors the flag (mov rsp,rbp; pop rbp when rbx omitted).
 *
 * Linked first on LINUX|WINDOWS like cltd_cqo.o (PE first-wins).
 * PLATFORM: LINUX|UBUNTU / WINDOWS — x86_64 only.
 */
#include <stdint.h>

/* Match the product encoder append helpers (same names as the .x externs). */
extern int x86_enc_u8(void *elf_ctx, int b);
extern int x86_enc_bytes(void *elf_ctx, unsigned char *p, int n);

/* 1 = prologue saved rbx (lea/[rbp-8] epilogue); 0 = lean host-like. */
static int g_x86_prologue_saved_rbx = 1;

/**
 * Emit push rbp; mov rbp,rsp; [push rbx]; then allocate frame_sz bytes.
 * Frames larger than 4096 probe in 4096-byte steps so Windows commits
 * guard pages before RSP crosses them.
 * w1043: frame_sz <= 48 skips rbx (host trampoline class).
 */
int arch_x86_64_enc_enc_prologue(void *elf_ctx, int frame_sz) {
  int fs;
  int rem;
  int add;
  int aligned;
  int save_rbx;
  unsigned u;
  unsigned char sub7[7];
  unsigned char or5[5];
  unsigned char sub5[5];
  unsigned char cmp5[5];
  unsigned char jae2[2];
  unsigned char subrax[3];
  const int page = 4096;

  if (elf_ctx == 0) {
    return -1;
  }
  /* push rbp */
  if (x86_enc_u8(elf_ctx, 85) != 0) {
    return -1;
  }
  /* mov rbp, rsp */
  if (x86_enc_u8(elf_ctx, 72) != 0) {
    return -1;
  }
  if (x86_enc_u8(elf_ctx, 137) != 0) {
    return -1;
  }
  if (x86_enc_u8(elf_ctx, 229) != 0) {
    return -1;
  }

  fs = frame_sz;
  if (fs < 0) {
    fs = 0;
  }
  /*
   * w1043: small frames (param-home trampolines / tiny leaves) match host
   * thin — no push rbx. After push rbp only, RSP ≡ 0 (mod 16), so sub
   * must be ≡ 0 (mod 16). Larger frames keep rbx (array/const base) and
   * the historic ≡ 8 (mod 16) pad.
   */
  save_rbx = (fs > 48) ? 1 : 0;
  g_x86_prologue_saved_rbx = save_rbx;
  if (save_rbx != 0) {
    if (x86_enc_u8(elf_ctx, 83) != 0) {
      return -1;
    }
    rem = fs & 15;
    add = (8 - rem) & 15;
    aligned = fs + add;
  } else {
    rem = fs & 15;
    if (rem != 0) {
      aligned = fs + (16 - rem);
    } else {
      aligned = fs;
    }
  }

  /* Small frame: one-shot sub rsp, imm32. */
  if (!(page < aligned)) {
    u = (unsigned)aligned;
    sub7[0] = 72;
    sub7[1] = 129;
    sub7[2] = 236;
    sub7[3] = (unsigned char)(u & 255);
    sub7[4] = (unsigned char)((u >> 8) & 255);
    sub7[5] = (unsigned char)((u >> 16) & 255);
    sub7[6] = (unsigned char)((u >> 24) & 255);
    return x86_enc_bytes(elf_ctx, sub7, 7);
  }

  /* mov eax, aligned */
  if (x86_enc_u8(elf_ctx, 184) != 0) {
    return -1;
  }
  u = (unsigned)aligned;
  if (x86_enc_u8(elf_ctx, (int)(u & 255)) != 0) {
    return -1;
  }
  if (x86_enc_u8(elf_ctx, (int)((u >> 8) & 255)) != 0) {
    return -1;
  }
  if (x86_enc_u8(elf_ctx, (int)((u >> 16) & 255)) != 0) {
    return -1;
  }
  if (x86_enc_u8(elf_ctx, (int)((u >> 24) & 255)) != 0) {
    return -1;
  }
  /* jmp check (rel8 = 17) */
  if (x86_enc_u8(elf_ctx, 235) != 0) {
    return -1;
  }
  if (x86_enc_u8(elf_ctx, 17) != 0) {
    return -1;
  }
  /* page: sub rsp, 0x1000 */
  sub7[0] = 72;
  sub7[1] = 129;
  sub7[2] = 236;
  sub7[3] = 0;
  sub7[4] = 16;
  sub7[5] = 0;
  sub7[6] = 0;
  if (x86_enc_bytes(elf_ctx, sub7, 7) != 0) {
    return -1;
  }
  /* or qword [rsp], 0 */
  or5[0] = 72;
  or5[1] = 131;
  or5[2] = 12;
  or5[3] = 36;
  or5[4] = 0;
  if (x86_enc_bytes(elf_ctx, or5, 5) != 0) {
    return -1;
  }
  /* sub eax, 0x1000 */
  sub5[0] = 45;
  sub5[1] = 0;
  sub5[2] = 16;
  sub5[3] = 0;
  sub5[4] = 0;
  if (x86_enc_bytes(elf_ctx, sub5, 5) != 0) {
    return -1;
  }
  /* check: cmp eax, 0x1000 */
  cmp5[0] = 61;
  cmp5[1] = 0;
  cmp5[2] = 16;
  cmp5[3] = 0;
  cmp5[4] = 0;
  if (x86_enc_bytes(elf_ctx, cmp5, 5) != 0) {
    return -1;
  }
  /* jae page (rel8 = -24) */
  jae2[0] = 115;
  jae2[1] = 232;
  if (x86_enc_bytes(elf_ctx, jae2, 2) != 0) {
    return -1;
  }
  /* sub rsp, rax */
  subrax[0] = 72;
  subrax[1] = 41;
  subrax[2] = 196;
  if (x86_enc_bytes(elf_ctx, subrax, 3) != 0) {
    return -1;
  }
  return 0;
}

/**
 * Epilogue twin of the lean/full prologue (w1043).
 * PLATFORM: LINUX|UBUNTU / WINDOWS — x86_64.
 */
int arch_x86_64_enc_enc_epilogue(void *elf_ctx) {
  unsigned char lea[4];
  if (elf_ctx == 0) {
    return -1;
  }
  if (g_x86_prologue_saved_rbx != 0) {
    /* lea rsp, [rbp-8]; pop rbx; pop rbp; ret */
    lea[0] = 72;
    lea[1] = 141;
    lea[2] = 101;
    lea[3] = 248;
    if (x86_enc_bytes(elf_ctx, lea, 4) != 0) {
      return -1;
    }
    if (x86_enc_u8(elf_ctx, 91) != 0) {
      return -1;
    }
  } else {
    /* mov rsp, rbp — host-like lean frame (no rbx). */
    if (x86_enc_u8(elf_ctx, 72) != 0) {
      return -1;
    }
    if (x86_enc_u8(elf_ctx, 137) != 0) {
      return -1;
    }
    if (x86_enc_u8(elf_ctx, 236) != 0) {
      return -1;
    }
  }
  if (x86_enc_u8(elf_ctx, 93) != 0) {
    return -1;
  }
  return x86_enc_u8(elf_ctx, 195);
}
