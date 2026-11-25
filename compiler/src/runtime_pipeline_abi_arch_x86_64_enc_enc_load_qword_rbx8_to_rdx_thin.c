/* Source-faithful arch_x86_64_enc_enc_load_qword_rbx8_to_rdx twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s180 hello-build residual after load_qword_from_rbx_to_rax thin: check
 * green; build AV 0xC0000005 in 0.677s. first-chance WRITE at
 * arch_x86_64_enc_enc_load_qword_rbx8_to_rdx+0x22 (0x1403c8b36),
 * during xlang_io_read_ptr_slice. write=1, fault/rbx=0xffffffffc76770b0,
 * rax=0x48, rbp=0x103ed990. rbp-0x48d768e0 matches. typool huge-frame
 * dual-slot: source `let ins: u8[4] = [72, 139, 83, 8]` lifted to entry.
 * Immediate cousin of load_qword_from_rbx_to_rax_thin (s180).
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(uint8_t *elf_ctx) {
  uint8_t ins[4];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 72;
  ins[1] = 139;
  ins[2] = 83;
  ins[3] = 8;
  return x86_enc_bytes(elf_ctx, ins, 4);
}
