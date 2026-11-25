/* Source-faithful arch_x86_64_enc_enc_setz_movzbl_eax twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s181 hello-build residual: check green; build AV 0xC0000005 in ~0.71s.
 * first-chance WRITE at arch_x86_64_enc_enc_setz_movzbl_eax+0x22
 * (0x1403c904a), T 0x1403c9028, during xlang_io_submit_read_batch
 * (read_ptr_slice already past). write=1, fault/rbx=0xffffffffc767dfd0,
 * rax=0xf, rbp=0x103f48b0. rbp-0x48d768e0 matches. typool huge-frame
 * dual-slot: source `let ins0: u8[3] = [15, 148, 192]` (and ins1) lifted
 * to entry. Cousin of load_32 / load_64 / load_qword thins.
 * Good dual T @ 0x1403eb3c8 (thin.x append_u8) is not the call target.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_setz_movzbl_eax(uint8_t *elf_ctx) {
  uint8_t ins0[3];
  uint8_t ins1[3];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  /* 0f 94 c0 */
  ins0[0] = 15;
  ins0[1] = 148;
  ins0[2] = 192;
  if (x86_enc_bytes(elf_ctx, ins0, 3) != 0) {
    return 0 - 1;
  }
  /* 0f b6 c0 */
  ins1[0] = 15;
  ins1[1] = 182;
  ins1[2] = 192;
  return x86_enc_bytes(elf_ctx, ins1, 3);
}
