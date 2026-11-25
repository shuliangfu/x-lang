/* Source-faithful fixed-insn arch_x86_64_enc_enc_* twins
 * (backend_x86_64_enc_c.x).
 *
 * s217 DIG: tipU first-wins bodies for many fixed encoders plant
 * `lea -0x48d768e0(%rbp)` then store opcode bytes there (poison local
 * u8[N] init). AV on `i *=` / `/=` / `&=` / `|=` / `^=` / `<<=` / `>>=`
 * (and div's test_rbx_rbx / cltd / idiv path). Same undersized-local
 * class as s187/s214/s216. Aside poison-scan jmp→second T greened the
 * matrix (*=…>>= -c RC=0); emit still lacks load_lr (s213 twin).
 *
 * Host-cc twins call x86_enc_bytes with real stack byte arrays.
 * Tip-land via g05 LINK_WINNERS. docs-only .x must not first-wins.
 * PLATFORM: SHARED host-cc first-wins (x86_64 enc path).
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(void *elf_ctx, const uint8_t *buf, int32_t n);

static int32_t enc_fixed(void *elf_ctx, const uint8_t *ins, int32_t n) {
  if (elf_ctx == 0) {
    return -1;
  }
  return x86_enc_bytes(elf_ctx, ins, n);
}

int32_t arch_x86_64_enc_enc_and_rbx_rax(void *elf_ctx) {
  static const uint8_t ins[3] = {72, 33, 216};
  return enc_fixed(elf_ctx, ins, 3);
}

int32_t arch_x86_64_enc_enc_or_rbx_rax(void *elf_ctx) {
  static const uint8_t ins[3] = {72, 9, 216};
  return enc_fixed(elf_ctx, ins, 3);
}

int32_t arch_x86_64_enc_enc_xor_rbx_rax(void *elf_ctx) {
  static const uint8_t ins[3] = {72, 49, 216};
  return enc_fixed(elf_ctx, ins, 3);
}

int32_t arch_x86_64_enc_enc_test_rbx_rbx(void *elf_ctx) {
  static const uint8_t ins[2] = {133, 219};
  return enc_fixed(elf_ctx, ins, 2);
}

int32_t arch_x86_64_enc_enc_cltd(void *elf_ctx) {
  /* cqo (48 99), not 32-bit cltd — match .x wave676 note. */
  static const uint8_t ins[2] = {72, 153};
  return enc_fixed(elf_ctx, ins, 2);
}

int32_t arch_x86_64_enc_enc_idiv_rbx(void *elf_ctx) {
  static const uint8_t ins[3] = {72, 247, 251};
  return enc_fixed(elf_ctx, ins, 3);
}

int32_t arch_x86_64_enc_enc_imul_rbx_rax(void *elf_ctx) {
  static const uint8_t ins[4] = {72, 15, 175, 195};
  return enc_fixed(elf_ctx, ins, 4);
}

int32_t arch_x86_64_enc_enc_shl_cl_eax(void *elf_ctx) {
  static const uint8_t ins[2] = {211, 224};
  return enc_fixed(elf_ctx, ins, 2);
}

int32_t arch_x86_64_enc_enc_shr_cl_eax(void *elf_ctx) {
  static const uint8_t ins[2] = {211, 232};
  return enc_fixed(elf_ctx, ins, 2);
}

int32_t arch_x86_64_enc_enc_sar_cl_eax(void *elf_ctx) {
  static const uint8_t ins[2] = {211, 248};
  return enc_fixed(elf_ctx, ins, 2);
}

int32_t arch_x86_64_enc_enc_shl_cl_rax(void *elf_ctx) {
  static const uint8_t ins[3] = {72, 211, 224};
  return enc_fixed(elf_ctx, ins, 3);
}

int32_t arch_x86_64_enc_enc_shr_cl_rax(void *elf_ctx) {
  static const uint8_t ins[3] = {72, 211, 232};
  return enc_fixed(elf_ctx, ins, 3);
}

int32_t arch_x86_64_enc_enc_sar_cl_rax(void *elf_ctx) {
  static const uint8_t ins[3] = {72, 211, 248};
  return enc_fixed(elf_ctx, ins, 3);
}

int32_t arch_x86_64_enc_enc_xor_edx_edx(void *elf_ctx) {
  static const uint8_t ins[2] = {49, 210};
  return enc_fixed(elf_ctx, ins, 2);
}

int32_t arch_x86_64_enc_enc_div_rbx(void *elf_ctx) {
  static const uint8_t ins[3] = {72, 247, 243};
  return enc_fixed(elf_ctx, ins, 3);
}
