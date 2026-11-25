/* Source-faithful arch_x86_64_enc_enc_mov_rax_to_rbx twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s145 hello build residual AV: first-chance 0xC0000005 WRITE at typool
 * arch_x86_64_enc_enc_mov_rax_to_rbx+0x22 (0x1403b5662), function
 * 0x1403b5640, after the s145 mov_arg_reg_to_rax thin had entered
 * (k=0/1/2) from backend_enc_mov_arg_reg_to_rax_arch+0x5a and returned.
 * Fault / rbx = 0xffffffffc767e9f0, rax=0x48, rbp=0x103f52d0, rsp in
 * stack. typool in a small frame sub rsp,0x1f8 did
 * lea rax,[rbp-0x48d768e0] (disp32 0xb7289720) then mov qword [rbx],0x48.
 * rbp+disp32 = 0xffffffffc767e9f0, matching the fault. typool huge-frame
 * dual-slot: source `let ins: u8[3] = [72, 137, 195]` (0x48,0x89,0xc3)
 * was lifted to function entry, stored as qwords at stride 0x4f1, first
 * store before the elf_ctx null check. Later typool then called
 * x86_enc_bytes with a different slot lea [rbp-0x20]. Cousins
 * arch_x86_64_enc_enc_mov_rbx_to_rax, mov_rax_to_arg_reg, and
 * uasb_put_i32 were not the live first producer and were not folded.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_mov_rax_to_rbx(uint8_t *elf_ctx) {
  uint8_t ins[3];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 72;
  ins[1] = 137;
  ins[2] = 195;
  return x86_enc_bytes(elf_ctx, ins, 3);
}
