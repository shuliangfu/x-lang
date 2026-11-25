/* Source-faithful arch_x86_64_enc_enc_neg_eax twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s149 hello build residual: uninstrumented fast compile_rc=3221225477
 * (0xC0000005) in 0.365s, no output file, 61-byte typool-garbled
 * emit-trace stderr. Debugger first-chance 0xC0000005 WRITE at typool
 * arch_x86_64_enc_enc_neg_eax+0x22 (0x1403b5bce), function
 * 0x1403b5bac, t=0.689s. write=1, fault/rbx=0xffffffffc7673e10,
 * rax=0xf7, rbp=0x103ea6f0, rsp=0x103ea4f0.
 * rbp-0x48d768e0 = 0xffffffffc7673e10, matching the fault. typool in a
 * small frame did lea [rbp-0x48d768e0] (disp32 0xb7289720) then
 * mov qword [rbx], rax (bytes 48 89 83 00 00 00 00). typool huge-frame
 * dual-slot: source `let ins: u8[2] = [247, 216]` (0xf7,0xd8) was
 * lifted to function entry, first store of 0xf7 before the elf_ctx
 * null check. Saved [rbp+8] caller is backend_enc_neg_eax_arch+0xa8
 * (0x1403c7540 / 0x1403c7498). HW exec BPs: s149 test_eax_eax thin at
 * 0x140003470 entered once and would return to
 * backend_enc_test_eax_eax_arch+0xa8; mid typool test_eax_eax
 * 0x1403b5c60 was not entered (last-only leftover not on the live
 * path); typool test_rbx_rbx 0x1403b5d14 was not entered; typool
 * neg_eax entered once from the arch wrapper then AV at +0x22.
 * Cousins test_rbx_rbx, cmp_rax_rbx, mov_rbx_to_rax,
 * mov_rax_to_arg_reg, typool uasb_put_i32, and typool note were not
 * the live first producer and were not folded. Mid typool
 * test_eax_eax was not JMP-patched.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_neg_eax(uint8_t *elf_ctx) {
  uint8_t ins[2];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 247;
  ins[1] = 216;
  return x86_enc_bytes(elf_ctx, ins, 2);
}
