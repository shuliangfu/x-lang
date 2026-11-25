/* Source-faithful arch_x86_64_enc_enc_idiv_rbx twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s185 hello-build residual: check green; build AV 0xC0000005 in ~0.64s.
 * first-chance WRITE at arch_x86_64_enc_enc_idiv_rbx+0x22 (0x1403c759a),
 * T 0x1403c7578, during std.io (FN stderr/from_fd/read/write/timeout_from_ctx).
 * write=1, fault/rbx=0xffffffffc767df30, rax=0x48, rbp=0x103f4810.
 * rbp-0x48d768e0 matches. typool huge-frame dual-slot: source
 * `let ins: u8[3] = [72, 247, 251]` lifted to entry. Cousin of load_zext8 /
 * setz_movzbl / load_32 thins.
 * Good dual T @ 0x1403e9bc8 is not the call target.
 * docs-only .x, do not idx8.
 * PLATFORM: WINDOWS DIG host-cc first-wins; SHARED encode bytes.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_idiv_rbx(uint8_t *elf_ctx) {
  uint8_t ins[3];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  /* 48 f7 fb — REX.W idiv %rbx */
  ins[0] = 72;
  ins[1] = 247;
  ins[2] = 251;
  return x86_enc_bytes(elf_ctx, ins, 3);
}
