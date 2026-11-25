/* Source-faithful arch_x86_64_enc_enc_load_qword_from_rbx_to_rax twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s179 hello-build residual after res_mod thin: hang cleared; build AV
 * 0xC0000005 in 0.696s. first-chance WRITE at
 * arch_x86_64_enc_enc_load_qword_from_rbx_to_rax+0x22 (0x1403c8a2e),
 * T 0x1403c8a0c, during xlang_io_read_ptr_slice. write=1,
 * fault/rbx=0xffffffffc76770b0, rax=0x48, rbp=0x103ed990.
 * rbp-0x48d768e0 matches the fault. typool store mov qword [rbx],rax
 * then lea [rbp-0x48d768e0]. typool huge-frame dual-slot: source
 * `let ins: u8[3] = [72, 139, 3]` lifted to entry. Cousin of
 * load_32_from_rax_thin (s178) / load_64_from_rax_thin (s167).
 * Good dual T @ 0x1403eea10 (thin.x append_u8) is not the call target.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(uint8_t *elf_ctx) {
  uint8_t ins[3];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 72;
  ins[1] = 139;
  ins[2] = 3;
  return x86_enc_bytes(elf_ctx, ins, 3);
}
