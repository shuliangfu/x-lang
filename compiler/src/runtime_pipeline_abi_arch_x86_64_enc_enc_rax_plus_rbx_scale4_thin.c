/* Source-faithful arch_x86_64_enc_enc_rax_plus_rbx_scale4 twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s174 hello build residual: uninstrumented 90s timeout, no product.
 * Debugger / first-chance-only (no software BPs) 0xC0000005 WRITE at
 * typool arch_x86_64_enc_enc_rax_plus_rbx_scale4+0x22 (0x1403c8c26),
 * function 0x1403c8c04, t=1.336s. write=1, fault/rbx=0xffffffffc7672790,
 * rax=0x48, rbp=0x103e9070, rsp=0x103e8e70.
 * rbp-0x48d768e0 = 0xffffffffc7672790, matching the fault. typool did
 * lea [rbp-0x48d768e0] (disp32 0xb7289720) then mov qword [rbx], rax
 * (bytes 48 89 83 00 00 00 00). typool huge-frame dual-slot: source
 * `let ins: u8[4] = [72, 141, 4, 152]` (0x48) was lifted to function
 * entry, first store of 0x48 before the elf_ctx null check. Saved
 * caller is pipeline_asm_emit_lvalue_eff_addr_elf_c+0x7b0 through
 * typool backend_enc_rax_plus_rbx_scale4_arch (0x1403da930), which
 * calls first-wins typool scale4. The uninstrumented 90s timeout is
 * SEH unwind after this WRITE (SizeOfStackReserve 0x10000000), not a
 * typool tight loop. enc_rax_plus_rbx_scale4 is the live first
 * producer; scale8 and other pipe_* / lvalue cousins were not folded.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_rax_plus_rbx_scale4(uint8_t *elf_ctx) {
  uint8_t ins[4];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 72;
  ins[1] = 141;
  ins[2] = 4;
  ins[3] = 152;
  return x86_enc_bytes(elf_ctx, ins, 4);
}
