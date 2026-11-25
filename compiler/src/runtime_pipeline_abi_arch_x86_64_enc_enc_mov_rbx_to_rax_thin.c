/* Source-faithful arch_x86_64_enc_enc_mov_rbx_to_rax twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s157 hello build residual: uninstrumented 25.13s timeout,
 * compile_rc=null, no output file, ~61-byte typool-garbled emit-trace
 * stderr. Debugger first-chance 0xC0000005 WRITE at typool
 * arch_x86_64_enc_enc_mov_rbx_to_rax+0x22 (0x1403b5b8a), function
 * 0x1403b5b68, t=0.676s. write=1, fault/rbx=0xffffffffc767d190,
 * rax=0x48, rbp=0x103f3a70, rsp=0x103f3870.
 * rbp-0x48d768e0 = 0xffffffffc767d190, matching the fault. typool did
 * lea [rbp-0x48d768e0] (disp32 0xb7289720) then mov qword [rbx], rax
 * (bytes 48 89 83 00 00 00 00). typool huge-frame dual-slot: source
 * `let ins: u8[3] = [72, 137, 216]` (0x48) was lifted to function
 * entry, first store of 0x48 before the elf_ctx null check. Saved
 * [rbp+8] caller is backend_enc_mov_rbx_to_rax_arch+0xa8 (0x1403c9950 /
 * 0x1403c98a8). The uninstrumented 25s timeout was SEH unwind after
 * this WRITE, not a loop hang. This is mov_rbx_to_rax, not the already
 * folded cousin mov_rax_to_rbx.
 * Cousins typool shr_cl_rax, shl_cl_eax, mov_edx_to_eax,
 * store_rax_to_rbx_offset, scale4, mid typool shl_cl_rax, typool
 * uasb_put_i32, and typool note were not folded unless a live pin
 * proved one was the first producer.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_mov_rbx_to_rax(uint8_t *elf_ctx) {
  uint8_t ins[3];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 72;
  ins[1] = 137;
  ins[2] = 216;
  return x86_enc_bytes(elf_ctx, ins, 3);
}
