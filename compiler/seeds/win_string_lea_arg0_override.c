/* PLATFORM: WINDOWS leftover-PE — force Win64 string-lit arg0 lea rcx.
 * Public symbol wins first with -Wl,--allow-multiple-definition over SysV
 * .x-lowered glue_asm_emit_jmp_skip_string_then_lea (hardcoded 0x3d rdi).
 * Authority twin: backend_call_dispatch.x + _impl in backend_call_dispatch.from_x.c.
 */
#include <stdint.h>

extern int32_t pipeline_elf_ctx_append_bytes(void *ctx_bytes, const uint8_t *ptr, int32_t n);
extern int link_abi_host_is_windows(void);

int32_t glue_asm_emit_jmp_skip_string_then_lea(uint8_t *ctx_bytes, int32_t ta, int32_t reg_k,
                                               const uint8_t *sbuf, int32_t slen) {
  uint8_t jmp2[2];
  uint8_t lea7[7];
  uint8_t z;
  uint8_t pad_z;
  uint8_t b4[4];
  uint8_t adr4[4];
  int32_t disp32;
  int32_t raw, pad, skip, imm26, imm, i;
  uint32_t b_inst, adr_inst, imm_bits, immlo, immhi;
  int is_win;

  if (!ctx_bytes || !sbuf || slen < 0 || slen > 4095)
    return -1;
  if (ta != 0 && ta != 1)
    return -1;

  if (ta == 1) {
    raw = slen + 1;
    pad = (4 - (raw & 3)) & 3;
    skip = raw + pad;
    imm26 = 1 + (skip / 4);
    if (imm26 <= 0 || imm26 >= (1 << 25))
      return -1;
    b_inst = 0x14000000u | ((uint32_t)imm26 & 0x3FFFFFFu);
    b4[0] = (uint8_t)(b_inst);
    b4[1] = (uint8_t)(b_inst >> 8);
    b4[2] = (uint8_t)(b_inst >> 16);
    b4[3] = (uint8_t)(b_inst >> 24);
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, b4, 4) != 0)
      return -1;
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, (uint8_t *)sbuf, slen) != 0)
      return -1;
    z = 0;
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, &z, 1) != 0)
      return -1;
    pad_z = 0;
    for (i = 0; i < pad; i++) {
      if (pipeline_elf_ctx_append_bytes(ctx_bytes, &pad_z, 1) != 0)
        return -1;
    }
    imm = -skip;
    imm_bits = (uint32_t)imm & 0x1FFFFFu;
    immlo = imm_bits & 3u;
    immhi = (imm_bits >> 2) & 0x7FFFFu;
    (void)reg_k;
    adr_inst = 0x10000000u | (immlo << 29) | (immhi << 5);
    adr4[0] = (uint8_t)(adr_inst);
    adr4[1] = (uint8_t)(adr_inst >> 8);
    adr4[2] = (uint8_t)(adr_inst >> 16);
    adr4[3] = (uint8_t)(adr_inst >> 24);
    return pipeline_elf_ctx_append_bytes(ctx_bytes, adr4, 4);
  }

  if (slen + 1 <= 127) {
    jmp2[0] = 0xeb;
    jmp2[1] = (uint8_t)(slen + 1);
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, jmp2, 2) != 0)
      return -1;
  } else {
    uint8_t jmp5[5];
    uint32_t rel32 = (uint32_t)(slen + 1);
    jmp5[0] = 0xe9;
    jmp5[1] = (uint8_t)rel32;
    jmp5[2] = (uint8_t)(rel32 >> 8);
    jmp5[3] = (uint8_t)(rel32 >> 16);
    jmp5[4] = (uint8_t)(rel32 >> 24);
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, jmp5, 5) != 0)
      return -1;
  }
  if (pipeline_elf_ctx_append_bytes(ctx_bytes, (uint8_t *)sbuf, slen) != 0)
    return -1;
  z = 0;
  if (pipeline_elf_ctx_append_bytes(ctx_bytes, &z, 1) != 0)
    return -1;
  disp32 = -slen - 8;
  lea7[0] = 0x48;
  lea7[1] = 0x8d;
  is_win = link_abi_host_is_windows();
  if (reg_k == 0)
    lea7[2] = (uint8_t)(is_win != 0 ? 0x0d : 0x3d);
  else
    lea7[2] = 0x05;
  lea7[3] = (uint8_t)(disp32);
  lea7[4] = (uint8_t)((uint32_t)disp32 >> 8);
  lea7[5] = (uint8_t)((uint32_t)disp32 >> 16);
  lea7[6] = (uint8_t)((uint32_t)disp32 >> 24);
  return pipeline_elf_ctx_append_bytes(ctx_bytes, lea7, 7);
}
