/* Source-faithful arch_x86_64_enc_enc_mov_rbx_to_ecx twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s155 hello build residual: uninstrumented fast compile_rc=3221225477
 * (0xC0000005) in 0.362s, no output file, ~61-byte typool-garbled
 * emit-trace stderr. Debugger first-chance 0xC0000005 WRITE at typool
 * arch_x86_64_enc_enc_mov_rbx_to_ecx+0x22 (0x1403b5bd2), function
 * 0x1403b5bb0, t=0.67s. write=1, fault/rbx=0xffffffffc767b190,
 * rax=0x89, rbp=0x103f1a70, rsp=0x103f1870.
 * rbp-0x48d768e0 = 0xffffffffc767b190, matching the fault. typool did
 * lea [rbp-0x48d768e0] (disp32 0xb7289720) then mov qword [rbx], rax
 * (bytes 48 89 83 00 00 00 00). typool huge-frame dual-slot: source
 * `let ins: u8[2] = [137, 217]` (0x89) was lifted to function entry,
 * first store of 0x89 before the elf_ctx null check. Saved [rbp+8]
 * caller is backend_enc_mov_rbx_to_ecx_arch+0xa8 (0x1403c75c8 /
 * 0x1403c7520).
 * Cousins typool store_rax_to_rbx_offset, scale4, scale8, shl_cl_eax,
 * push_rbx, mid typool store, mov_edx_to_eax, typool uasb_put_i32, and
 * typool note were not folded unless a live pin proved one was the
 * first producer.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_mov_rbx_to_ecx(uint8_t *elf_ctx) {
  uint8_t ins[2];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 137;
  ins[1] = 217;
  return x86_enc_bytes(elf_ctx, ins, 2);
}
