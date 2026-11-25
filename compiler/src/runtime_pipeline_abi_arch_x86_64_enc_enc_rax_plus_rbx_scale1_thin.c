/* Source-faithful arch_x86_64_enc_enc_rax_plus_rbx_scale1 twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s153 hello build residual: uninstrumented 25.119s timeout,
 * compile_rc=null, no output file, ~61-byte typool-garbled emit-trace
 * stderr. Debugger first-chance 0xC0000005 WRITE at typool
 * arch_x86_64_enc_enc_rax_plus_rbx_scale1+0x22 (0x1403b6e26), function
 * 0x1403b6e04, t=0.722s. write=1, fault/rbx=0xffffffffc767d860,
 * rax=0x48, rbp=0x103f4140, rsp=0x103f3f40.
 * rbp-0x48d768e0 = 0xffffffffc767d860, matching the fault. typool did
 * lea [rbp-0x48d768e0] (disp32 0xb7289720) then mov qword [rbx], rax
 * (bytes 48 89 83 00 00 00 00). typool huge-frame dual-slot: source
 * `let ins: u8[4] = [72, 141, 4, 24]` (0x48) was lifted to function
 * entry, first store of 0x48 before the elf_ctx null check. Saved
 * [rbp+8] caller is backend_enc_rax_plus_rbx_scale1_arch+0xa8
 * (0x1403c8bec / 0x1403c8b44). The uninstrumented 25s timeout was
 * SEH unwind after this WRITE, not a loop hang.
 * Cousins typool shl_cl_eax, push_rbx, rsub_ecx_edx, test_rbx_rbx,
 * cmp_rax_rbx, mid typool pop_rax, typool uasb_put_i32, typool note,
 * and scale4/scale8 were not folded unless a live pin proved one was
 * the first producer.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_rax_plus_rbx_scale1(uint8_t *elf_ctx) {
  uint8_t ins[4];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 72;
  ins[1] = 141;
  ins[2] = 4;
  ins[3] = 24;
  return x86_enc_bytes(elf_ctx, ins, 4);
}
