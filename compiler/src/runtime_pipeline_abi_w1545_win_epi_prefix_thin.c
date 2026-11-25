/* Host-gcc twin of w1545_win_epi_prefix_c (backend_call_dispatch.x).
 * typool first-wins T 0x1403f5d0c compiles `let b: u8[8] = []` with
 * scale-8 qword stores. b[2] = 157 (0x9d, the ModRM byte of
 * `mov r11,[rbp-disp32]`) lands at [rbp-0x10] and overwrites the saved
 * elf_ctx. Writer RIP typool 0x1403f5e9b. typool-rebuild of
 * runtime_asm_io_stubs.x then called leftover pipeline_elf_ctx_append_bytes
 * / pipe_load_i32_le with rcx=0x9d during std_io_read_stdin_ptr_slice
 * (SET_FUNC 86/121) → SIGSEGV at pipe_load_i32_le 0x14015b251.
 * Same class as typool mid_ret u8[8] scale-8 (already folded). Do not
 * idx8 the documentation .x twin. Bind typool epi BSS VAs directly
 * (Mingw .refptr is unresolved by pe_fold_append_last).
 * s184: Lxml_* by name (typool second T: fi/off/sz/mod). */
#include <stdint.h>

extern int32_t pipeline_asm_emit_func_index_c(void);
extern uint8_t *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *elf_ctx, uint8_t *b, int32_t n);

/* typool w1545_epi_{fi,off,sz,mod} BSS — bind live Lxml_* (s184).
 * Absolute tip VAs 0x1404f072c/30/34 and 0x14a061888 drifted after thin growth.
 * PLATFORM: WINDOWS DIG full gcc link resolves D/B; pe_fold .refptr N/A here. */
extern int32_t Lxml_0d51f80f7ed6acf6;
extern int32_t Lxml_dd451da47ed6acf6;
extern int32_t Lxml_54be1c7d7ed6acf6;
extern uint8_t *Lxml_b5c4f9457ed6acf6;
#define W1545_EPI_FI  (Lxml_0d51f80f7ed6acf6)
#define W1545_EPI_OFF (Lxml_dd451da47ed6acf6)
#define W1545_EPI_SZ  (Lxml_54be1c7d7ed6acf6)
#define W1545_EPI_MOD (Lxml_b5c4f9457ed6acf6)

static int32_t w1545_put(uint8_t *elf_ctx, uint8_t *b, int32_t n) {
  return pipeline_elf_ctx_append_bytes(elf_ctx, b, n);
}

int32_t w1545_win_epi_prefix_c(uint8_t *elf_ctx) {
  uint8_t b[8];
  int32_t d, rem, at, fi;
  uint32_t du;
  uint8_t *md;
  int32_t i;

  if (elf_ctx == 0 || W1545_EPI_OFF <= 0)
    return 0;
  fi = pipeline_asm_emit_func_index_c();
  md = pipeline_asm_emit_module_ref_c();
  if (fi != W1545_EPI_FI || md != W1545_EPI_MOD)
    return 0;

  for (i = 0; i < 8; i++)
    b[i] = 0;

  /* mov r11, [rbp-off]  (4C 8B 9D disp32) */
  d = 0 - W1545_EPI_OFF;
  du = (uint32_t)d;
  b[0] = 76;
  b[1] = 139;
  b[2] = 157;
  b[3] = (uint8_t)(du & 255);
  b[4] = (uint8_t)((du >> 8) & 255);
  b[5] = (uint8_t)((du >> 16) & 255);
  b[6] = (uint8_t)((du >> 24) & 255);
  if (w1545_put(elf_ctx, &b[0], 7) != 0)
    return -1;

  /* mov [r11], rax  (49 89 03) */
  b[0] = 73;
  b[1] = 137;
  b[2] = 3;
  if (w1545_put(elf_ctx, &b[0], 3) != 0)
    return -1;

  rem = W1545_EPI_SZ - 8;
  at = 8;
  if (rem >= 8) {
    /* mov [r11+8], rdx  (49 89 53 08) */
    b[0] = 73;
    b[1] = 137;
    b[2] = 83;
    b[3] = 8;
    if (w1545_put(elf_ctx, &b[0], 4) != 0)
      return -1;
    rem = 0;
  }
  if (rem >= 4) {
    /* mov [r11+at], edx  (41 89 53 at); shr rdx, 32  (48 C1 EA 20) */
    b[0] = 65;
    b[1] = 137;
    b[2] = 83;
    b[3] = (uint8_t)at;
    if (w1545_put(elf_ctx, &b[0], 4) != 0)
      return -1;
    b[0] = 72;
    b[1] = 193;
    b[2] = 234;
    b[3] = 32;
    if (w1545_put(elf_ctx, &b[0], 4) != 0)
      return -1;
    at = at + 4;
    rem = rem - 4;
  }
  if (rem >= 2) {
    /* mov [r11+at], dx  (66 41 89 53 at); shr rdx, 16  (48 C1 EA 10) */
    b[0] = 102;
    b[1] = 65;
    b[2] = 137;
    b[3] = 83;
    b[4] = (uint8_t)at;
    if (w1545_put(elf_ctx, &b[0], 5) != 0)
      return -1;
    b[0] = 72;
    b[1] = 193;
    b[2] = 234;
    b[3] = 16;
    if (w1545_put(elf_ctx, &b[0], 4) != 0)
      return -1;
    at = at + 2;
    rem = rem - 2;
  }
  if (rem >= 1) {
    /* mov [r11+at], dl  (41 88 53 at) */
    b[0] = 65;
    b[1] = 136;
    b[2] = 83;
    b[3] = (uint8_t)at;
    if (w1545_put(elf_ctx, &b[0], 4) != 0)
      return -1;
  }
  /* mov rax, r11  (4C 89 D8) */
  b[0] = 76;
  b[1] = 137;
  b[2] = 216;
  return w1545_put(elf_ctx, &b[0], 3);
}
