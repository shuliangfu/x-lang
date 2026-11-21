/* Source-faithful arch_x86_64_enc_enc_mov_arg_reg_to_rax Windows twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s144 hello build AV: first-chance 0xC0000005 WRITE at typool
 * arch_x86_64_enc_enc_mov_arg_reg_to_rax+0x2b (0x1403bb5c7), function
 * 0x1403bb59c, t=0.926s, 1ms after the second export_sym thin enter.
 * Fault / rbx = 0xffffffffc76804c0, rax=0x48, rbp=0x103f6da0, rsp in
 * stack. typool did lea rax,[rbp-0x48d768e0] (disp32 0xb7289720) then
 * mov qword [rbx], 0x48. rbp+disp32 = 0xffffffffc76804c0, matching the
 * fault. Frame was only sub rsp,0x4c8. This is typool huge-frame
 * dual-slot: hoisted init of source `let b7: u8[7] = [72, 139, 133, 0,
 * 0, 0, 0]` (0x48,0x8b,0x85,...) through a wild local address, also
 * stored as qwords at stride 0xfe1. The first store AVs before the
 * elf_ctx null check. typool uasb_put_i32 and the cousin
 * arch_x86_64_enc_enc_mov_rax_to_arg_reg were not the live first
 * producer and were not folded. docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_mov_arg_reg_to_rax(uint8_t *elf_ctx, int32_t k) {
  int32_t idx_a2r_win;
  int32_t slot;
  int32_t off;
  uint8_t b0[3];
  uint8_t b1[3];
  uint8_t b2[3];
  uint8_t b3[3];
  uint8_t b4[4];
  uint8_t b7[7];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  idx_a2r_win = k;
  if (idx_a2r_win < 0) {
    idx_a2r_win = 0;
  }
  if (idx_a2r_win > 63) {
    idx_a2r_win = 63;
  }
  if (idx_a2r_win == 0) {
    b0[0] = 72;
    b0[1] = 137;
    b0[2] = 200;
    return x86_enc_bytes(elf_ctx, b0, 3);
  }
  if (idx_a2r_win == 1) {
    b1[0] = 72;
    b1[1] = 137;
    b1[2] = 208;
    return x86_enc_bytes(elf_ctx, b1, 3);
  }
  if (idx_a2r_win == 2) {
    b2[0] = 76;
    b2[1] = 137;
    b2[2] = 192;
    return x86_enc_bytes(elf_ctx, b2, 3);
  }
  if (idx_a2r_win == 3) {
    b3[0] = 76;
    b3[1] = 137;
    b3[2] = 200;
    return x86_enc_bytes(elf_ctx, b3, 3);
  }
  slot = idx_a2r_win - 4;
  off = 48 + slot * 8;
  if (off <= 127) {
    b4[0] = 72;
    b4[1] = 139;
    b4[2] = 69;
    b4[3] = (uint8_t)off;
    return x86_enc_bytes(elf_ctx, b4, 4);
  }
  b7[0] = 72;
  b7[1] = 139;
  b7[2] = 133;
  b7[3] = 0;
  b7[4] = 0;
  b7[5] = 0;
  b7[6] = 0;
  b7[3] = (uint8_t)(off & 255);
  b7[4] = (uint8_t)((off / 256) & 255);
  b7[5] = (uint8_t)((off / 65536) & 255);
  b7[6] = (uint8_t)((off / 16777216) & 255);
  return x86_enc_bytes(elf_ctx, b7, 7);
}
