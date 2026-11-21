/* Source-faithful arch_x86_64_enc_enc_shl_cl_rax twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s156 hello build residual: uninstrumented fast compile_rc=3221225477
 * (0xC0000005) in 0.391s, no output file, ~61-byte typool-garbled
 * emit-trace stderr. Debugger first-chance 0xC0000005 WRITE at typool
 * arch_x86_64_enc_enc_shl_cl_rax+0x22 (0x1403b694e), function
 * 0x1403b692c, t=0.687s. write=1, fault/rbx=0xffffffffc767b190,
 * rax=0x48, rbp=0x103f1a70, rsp=0x103f1870.
 * rbp-0x48d768e0 = 0xffffffffc767b190, matching the fault. typool did
 * lea [rbp-0x48d768e0] (disp32 0xb7289720) then mov qword [rbx], rax
 * (bytes 48 89 83 00 00 00 00). typool huge-frame dual-slot: source
 * `let ins: u8[3] = [72, 211, 224]` (0x48) was lifted to function
 * entry, first store of 0x48 before the elf_ctx null check. Saved
 * [rbp+8] caller is backend_enc_shl_cl_rax_arch+0xa8 (0x1403c7f98 /
 * 0x1403c7ef0). This is shl_cl_rax, not the cousin shl_cl_eax.
 * Cousins typool mov_edx_to_eax, store_rax_to_rbx_offset, shl_cl_eax,
 * shr_cl_rax, scale4/scale8, push_rbx, mid typool mov_rbx_to_ecx,
 * typool uasb_put_i32, and typool note were not folded unless a live
 * pin proved one was the first producer.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_shl_cl_rax(uint8_t *elf_ctx) {
  uint8_t ins[3];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 72;
  ins[1] = 211;
  ins[2] = 224;
  return x86_enc_bytes(elf_ctx, ins, 3);
}
