/* Source-faithful arch_x86_64_enc_enc_mov_rax_to_arg_reg twin
 * (compiler/src/asm/backend_x86_64_enc_c.x, Windows cfg).
 * s163 hello-build residual: uninstrumented compile_rc=3221225477
 * (0xC0000005) in 0.357s, no output. first-chance / DEBUG_ONLY_THIS_PROCESS
 * WRITE at typool arch_x86_64_enc_enc_mov_rax_to_arg_reg+0x2b
 * (0x1403c0b43), function T 0x1403c0b18, t=0.753s. write=1,
 * fault/rbx=0xffffffffc7677660, rax=0x48, rbp=0x103edf40,
 * rsp=0x103eda60. rbp-0x48d768e0 = 0xffffffffc7677660, matching
 * the fault. typool prologue sub rsp,0x4d8 then lea [rbp-0x48d768e0]
 * (disp32 0xb7289720), mov rbx,rax, mov eax,0x48, mov qword [rbx],rax
 * (bytes 48 89 83 00 00 00 00). typool huge-frame dual-slot: source
 * Windows `let b0: u8[3] = [72, 137, 193]` and later u8[N] literals
 * were lifted to function entry, first store of 0x48 before the
 * elf_ctx null check. This is not the already-folded cousin
 * mov_arg_reg_to_rax, and not typool for_call_args (s163 thin
 * first-wins 0x140004900, leftovers JMP'd). typool n_stack / typool
 * lookup / typool note / typool store-or-load / typool glue /
 * typool other enc_* cousins were not this writer and were not
 * folded. Later arms in this same function are included only
 * because they live in the proven typool symbol, not as a batch
 * fold of cousins. docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_mov_rax_to_arg_reg(uint8_t *elf_ctx, int32_t k) {
  int32_t idx_r2a_win;
  int32_t slot;
  int32_t off;
  uint8_t b0[3];
  uint8_t b1[3];
  uint8_t b2[3];
  uint8_t b3[3];
  uint8_t b4[5];
  uint8_t b8[8];

  if (elf_ctx == 0) {
    return 0 - 1;
  }
  idx_r2a_win = k;
  if (idx_r2a_win < 0) {
    idx_r2a_win = 0;
  }
  if (idx_r2a_win > 63) {
    idx_r2a_win = 63;
  }
  if (idx_r2a_win == 0) {
    b0[0] = 72;
    b0[1] = 137;
    b0[2] = 193;
    return x86_enc_bytes(elf_ctx, b0, 3);
  }
  if (idx_r2a_win == 1) {
    b1[0] = 72;
    b1[1] = 137;
    b1[2] = 194;
    return x86_enc_bytes(elf_ctx, b1, 3);
  }
  if (idx_r2a_win == 2) {
    b2[0] = 73;
    b2[1] = 137;
    b2[2] = 192;
    return x86_enc_bytes(elf_ctx, b2, 3);
  }
  if (idx_r2a_win == 3) {
    b3[0] = 73;
    b3[1] = 137;
    b3[2] = 193;
    return x86_enc_bytes(elf_ctx, b3, 3);
  }
  /* k>=4: mov [rsp+disp], rax; disp = 0x20 + 8*(k-4). disp8 through k=15. */
  slot = idx_r2a_win - 4;
  off = 32 + slot * 8;
  if (off <= 127) {
    b4[0] = 72;
    b4[1] = 137;
    b4[2] = 68;
    b4[3] = 36;
    b4[4] = (uint8_t)off;
    return x86_enc_bytes(elf_ctx, b4, 5);
  }
  b8[0] = 72;
  b8[1] = 137;
  b8[2] = 132;
  b8[3] = 36;
  b8[4] = 0;
  b8[5] = 0;
  b8[6] = 0;
  b8[7] = 0;
  b8[4] = (uint8_t)(off & 255);
  b8[5] = (uint8_t)((off / 256) & 255);
  b8[6] = (uint8_t)((off / 65536) & 255);
  b8[7] = (uint8_t)((off / 16777216) & 255);
  return x86_enc_bytes(elf_ctx, b8, 8);
}
