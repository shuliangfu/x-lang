/* Source-faithful arch_x86_64_enc_enc_push_rax twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s151 hello build residual: uninstrumented 25.135s timeout (empty RC,
 * no output file, 61-byte typool-garbled emit-trace stderr) is again a
 * typool WRITE AV followed by ntdll SEH unwind. Debugger first-chance
 * 0xC0000005 WRITE at typool arch_x86_64_enc_enc_push_rax+0x22
 * (0x1403b6302), function 0x1403b62e0, t=0.689s. write=1, fault/rbx=
 * 0xffffffffc767d900, rax=0x50, rbp=0x103f41e0, rsp=0x103f3fe0.
 * rbp-0x48d768e0 = 0xffffffffc767d900, matching the fault. typool did
 * lea [rbp-0x48d768e0] (disp32 0xb7289720) then mov qword [rbx], rax
 * (bytes 48 89 83 00 00 00 00). typool huge-frame dual-slot: source
 * `let ins: u8[1] = [80]` (0x50) was lifted to function entry, first
 * store of 0x50 before the elf_ctx null check. Saved [rbp+8] caller is
 * backend_enc_push_rax_arch+0xa8 (0x1403c69b0 / 0x1403c6908).
 * HW exec BPs: s151 sub_rbx_rax_then_mov thin at 0x1400034f0 entered
 * once and would return to backend_enc_sub_rbx_rax_then_mov_arch+0xa8;
 * mid typool sub_rbx_rax_then_mov 0x1403b7994 was not entered
 * (last-only leftover not on the live path); typool rsub_ecx_edx
 * 0x1403b7af8 was not entered; typool push_rax entered once from the
 * arch wrapper then AV at +0x22. Cousins rsub_ecx_edx, test_rbx_rbx,
 * cmp_rax_rbx, push_rbx, mov_rbx_to_rax, mov_rax_to_arg_reg, typool
 * uasb_put_i32, and typool note were not the live first producer and
 * were not folded. Mid typool sub_rbx_rax_then_mov was not JMP-patched.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_push_rax(uint8_t *elf_ctx) {
  uint8_t ins[1];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 80;
  return x86_enc_bytes(elf_ctx, ins, 1);
}
