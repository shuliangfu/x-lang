/* Source-faithful arch_x86_64_enc_enc_load_zext8_from_rax twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s184 hello-build residual: check green; build AV 0xC0000005 in ~0.65s.
 * first-chance WRITE at arch_x86_64_enc_enc_load_zext8_from_rax+0x22
 * (0x1403c80be), T 0x1403c809c, during Result unwrap path
 * (FN and_then/or_else/ok_u8/err_u8/unwrap_or_u8). write=1,
 * fault/rbx=0xffffffffc7673770, rax=0xf, rbp=0x103ea050.
 * rbp-0x48d768e0 matches. typool huge-frame dual-slot: source
 * `let ins: u8[3] = [15, 182, 0]` lifted to entry. Cousin of load_32 /
 * load_64 / load_qword / setz_movzbl thins.
 * Good dual T @ 0x1403ea53c (append_u8 0f/b6/00) is not the call target.
 * docs-only .x, do not idx8.
 * PLATFORM: WINDOWS DIG host-cc first-wins; SHARED encode bytes.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_load_zext8_from_rax(uint8_t *elf_ctx) {
  uint8_t ins[3];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  /* 0f b6 00 */
  ins[0] = 15;
  ins[1] = 182;
  ins[2] = 0;
  return x86_enc_bytes(elf_ctx, ins, 3);
}
