/* Source-faithful arch_x86_64_enc_enc_sub_rbx_rax_then_mov twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s150 hello build residual: uninstrumented fast compile_rc=3221225477
 * (0xC0000005) in 0.361s, no output file, 61-byte typool-garbled
 * emit-trace stderr. Debugger first-chance 0xC0000005 WRITE at typool
 * arch_x86_64_enc_enc_sub_rbx_rax_then_mov+0x22 (0x1403b7956),
 * function 0x1403b7934, t=0.668s. write=1, fault/rbx=
 * 0xffffffffc767d510, rax=0x48, rbp=0x103f3df0, rsp=0x103f3b70.
 * rbp-0x48d768e0 = 0xffffffffc767d510, matching the fault. typool in a
 * small frame did lea [rbp-0x48d768e0] (disp32 0xb7289720) then
 * mov qword [rbx], rax (bytes 48 89 83 00 00 00 00). typool huge-frame
 * dual-slot: source `let ins0: u8[3] = [72, 41, 195]` (0x48,0x29,0xc3)
 * was lifted to function entry, first store of 0x48 before the elf_ctx
 * null check. Saved [rbp+8] caller is
 * backend_enc_sub_rbx_rax_then_mov_arch+0xa8 (0x1403c7cac / 0x1403c7c04).
 * HW exec BPs: s150 neg_eax thin at 0x1400034b0 entered once and would
 * return to backend_enc_neg_eax_arch+0xa8; mid typool neg_eax
 * 0x1403b5bec was not entered (last-only leftover not on the live
 * path); typool test_rbx_rbx 0x1403b5d54 was not entered; typool
 * sub_rbx_rax_then_mov entered once from the arch wrapper then AV at
 * +0x22. Cousins test_rbx_rbx, cmp_rax_rbx, rsub_ecx_edx,
 * mov_rbx_to_rax, mov_rax_to_arg_reg, typool uasb_put_i32, and typool
 * note were not the live first producer and were not folded. Mid
 * typool neg_eax was not JMP-patched.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_sub_rbx_rax_then_mov(uint8_t *elf_ctx) {
  uint8_t ins0[3];
  uint8_t ins1[3];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins0[0] = 72;
  ins0[1] = 41;
  ins0[2] = 195;
  if (x86_enc_bytes(elf_ctx, ins0, 3) != 0) {
    return 0 - 1;
  }
  ins1[0] = 72;
  ins1[1] = 137;
  ins1[2] = 216;
  return x86_enc_bytes(elf_ctx, ins1, 3);
}
