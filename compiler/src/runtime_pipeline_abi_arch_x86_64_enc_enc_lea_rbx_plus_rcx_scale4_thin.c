/* Source-faithful arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4 twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s176 DIG face (after s175 rax_plus_rbx_scale4 fold).
 * Prior s176 const_lit AS-over-foldable experiment (uncommitted) crossed
 * IO_FIXED_MAX=8 as u32 leak and AV'd hello ~0.621s; debugger pinned
 * typool residual lea_rbx_plus_rcx_scale4+22 @ 0x1403c8f26 — same
 * huge-frame dual-slot store class as s175 (local u8[4] lit lifted to
 * function entry, first store before elf_ctx null check).
 * Experimental noaslr md5 a55354142de0a6e4cce01d82815babc7 was NOT
 * accepted; this thin is the DIG product body. docs-only .x, do not idx8.
 * PLATFORM: WINDOWS — typool huge-frame dual-slot store of local u8[4].
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(uint8_t *elf_ctx) {
  uint8_t ins[4];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  /* lea rbx, [rbx+rcx*4] — bytes match backend_x86_64_enc_c.x */
  ins[0] = 72;
  ins[1] = 141;
  ins[2] = 28;
  ins[3] = 139;
  return x86_enc_bytes(elf_ctx, ins, 4);
}
