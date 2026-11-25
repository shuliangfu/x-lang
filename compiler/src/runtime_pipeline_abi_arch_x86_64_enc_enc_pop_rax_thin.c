/* Source-faithful arch_x86_64_enc_enc_pop_rax twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s152 hello build residual: uninstrumented fast compile_rc=3221225477
 * (0xC0000005) in 0.347s, no output file, 61-byte typool-garbled
 * emit-trace stderr. Debugger first-chance 0xC0000005 WRITE at typool
 * arch_x86_64_enc_enc_pop_rax+0x22 (0x1403b6516), function
 * 0x1403b64f4, t=0.658s. write=1, fault/rbx=0xffffffffc767d8a0,
 * rax=0x58, rbp=0x103f4180, rsp=0x103f3f80.
 * rbp-0x48d768e0 = 0xffffffffc767d8a0, matching the fault. typool did
 * lea [rbp-0x48d768e0] (disp32 0xb7289720) then mov qword [rbx], rax
 * (bytes 48 89 83 00 00 00 00). typool huge-frame dual-slot: source
 * `let ins: u8[1] = [88]` (0x58) was lifted to function entry, first
 * store of 0x58 before the elf_ctx null check. Saved [rbp+8] caller is
 * backend_enc_pop_rax_arch+0xa8 (0x1403c6b88 / 0x1403c6ae0).
 * HW exec BPs: s152 push_rax thin at 0x140003560 entered twice and
 * would return to backend_enc_push_rax_arch+0xa8; mid typool push_rax
 * 0x1403b6320 was not entered (last-only leftover not on the live
 * path); typool push_rbx 0x1403b63bc was not entered; typool pop_rax
 * entered once from the arch wrapper then AV at +0x22. Cousins
 * push_rbx, rsub_ecx_edx, test_rbx_rbx, cmp_rax_rbx, shl_cl_eax,
 * mov_rbx_to_rax, mov_rax_to_arg_reg, typool uasb_put_i32, and typool
 * note were not the live first producer and were not folded. Mid typool
 * push_rax was not JMP-patched.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_pop_rax(uint8_t *elf_ctx) {
  uint8_t ins[1];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 88;
  return x86_enc_bytes(elf_ctx, ins, 1);
}
