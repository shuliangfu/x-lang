/*
 * Host-gcc twin of glue_asm_emit_jmp_skip_string_then_lea
 * (language in compiler/src/asm/backend_call_dispatch.x).
 *
 * Root (s53 unofficial hello product run 0xC0000096): typool first-wins T
 *   0x1403f484c (frame 0x928) is called from host-cc fmt_string_lit at
 *   typool 0x14a3e345a. typool of `let jmp2: u8[2]` / `let lea7: u8[7]`
 *   (and typool aarch64 / e9 buffers) stores each element at typool
 *   scale-8 (`lea buf; add $index*8`), then packed-appends the first N
 *   bytes. Live x86_64 slen=11 path therefore emits `eb 00` (jmp2[1]
 *   written at +8, leftover 0) and lea `48 00 00 00 00 00 00` (only
 *   lea7[0]=0x48 in the packed 7 bytes). The product `main` then
 *   `jmp .+0` into the inlined "Hello World\0" payload. First-chance
 *   CONTEXT.Rip = main+14 (file VA 0x14000149e; ASLR
 *   0x7ff7b42f149e this run), bytes `48 65 6c 6c 6f 20 57 6f 72 6c
 *   64 00` ("Hello World\0"); `gs insb` is STATUS_PRIVILEGED_INSTRUCTION
 *   0xC0000096, info0=0, info1=0.
 *
 * Class: typool u8[N] scale-8 then packed append of first n bytes
 *   (48 00 00 leftover / eb 00).
 * Fold allowlist: glue_asm_emit_jmp_skip_string_then_lea only.
 * Do not fold typool try_emit, typool bind_eq, typool pend BSS, typool
 * mid_ret, typool fmt_any, typool w1545_pend_rcx_emit, or typool
 * fmt_string_lit (already folded).
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>

int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx, const uint8_t *buf, int32_t n);
int32_t link_abi_host_is_windows(void);

int32_t glue_asm_emit_jmp_skip_string_then_lea(uint8_t *ctx_bytes, int32_t ta,
                                               int32_t reg_k, uint8_t *sbuf,
                                               int32_t slen) {
  int32_t raw;
  int32_t pad;
  int32_t skip;
  int32_t imm26;
  uint32_t b_inst;
  uint8_t b4[4];
  uint8_t z;
  int32_t pi;
  int32_t imm;
  uint32_t imm_bits;
  uint32_t immlo;
  uint32_t immhi;
  uint32_t adr_inst;
  uint8_t adr4[4];
  uint8_t jmp2[2];
  uint8_t jmp5[5];
  uint32_t rel32;
  uint8_t z0;
  int32_t d;
  uint32_t u;
  uint8_t lea7[7];

  if (ctx_bytes == 0) {
    return 0 - 1;
  }
  if (sbuf == 0) {
    return 0 - 1;
  }
  if (slen < 0) {
    return 0 - 1;
  }
  if (slen > 4095) {
    return 0 - 1;
  }
  if (ta != 0) {
    if (ta != 1) {
      return 0 - 1;
    }
  }

  if (ta == 1) {
    raw = slen + 1;
    pad = (4 - (raw & 3)) & 3;
    skip = raw + pad;
    imm26 = (1 + (skip / 4));
    if (imm26 <= 0) {
      return 0 - 1;
    }
    if (imm26 >= 33554432) {
      return 0 - 1;
    }
    b_inst = (335544320u | (imm26 & 67108863u));
    b4[0] = (uint8_t)(b_inst & 255u);
    b4[1] = (uint8_t)((b_inst / 256u) & 255u);
    b4[2] = (uint8_t)((b_inst / 65536u) & 255u);
    b4[3] = (uint8_t)((b_inst / 16777216u) & 255u);
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, b4, 4) != 0) {
      return 0 - 1;
    }
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, sbuf, slen) != 0) {
      return 0 - 1;
    }
    z = 0;
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, &z, 1) != 0) {
      return 0 - 1;
    }
    pi = 0;
    while (pi < pad) {
      if (pipeline_elf_ctx_append_bytes(ctx_bytes, &z, 1) != 0) {
        return 0 - 1;
      }
      pi = pi + 1;
    }
    imm = (0 - skip);
    imm_bits = ((uint32_t)imm) & 2097151u;
    immlo = imm_bits & 3u;
    immhi = (imm_bits / 4u) & 524287u;
    adr_inst = (268435456u | (immlo * 536870912u) | (immhi * 32u));
    adr4[0] = (uint8_t)(adr_inst & 255u);
    adr4[1] = (uint8_t)((adr_inst / 256u) & 255u);
    adr4[2] = (uint8_t)((adr_inst / 65536u) & 255u);
    adr4[3] = (uint8_t)((adr_inst / 16777216u) & 255u);
    (void)reg_k;
    return pipeline_elf_ctx_append_bytes(ctx_bytes, adr4, 4);
  }

  if (slen + 1 <= 127) {
    jmp2[0] = 235;
    jmp2[1] = (uint8_t)(slen + 1);
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, jmp2, 2) != 0) {
      return 0 - 1;
    }
  } else {
    rel32 = (uint32_t)(slen + 1);
    jmp5[0] = 233;
    jmp5[1] = (uint8_t)(rel32 & 255u);
    jmp5[2] = (uint8_t)((rel32 / 256u) & 255u);
    jmp5[3] = (uint8_t)((rel32 / 65536u) & 255u);
    jmp5[4] = (uint8_t)((rel32 / 16777216u) & 255u);
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, jmp5, 5) != 0) {
      return 0 - 1;
    }
  }
  if (pipeline_elf_ctx_append_bytes(ctx_bytes, sbuf, slen) != 0) {
    return 0 - 1;
  }
  z0 = 0;
  if (pipeline_elf_ctx_append_bytes(ctx_bytes, &z0, 1) != 0) {
    return 0 - 1;
  }
  d = ((0 - slen) - 8);
  u = (uint32_t)d;
  lea7[0] = 72;
  lea7[1] = 141;
  if (reg_k == 0) {
    if (link_abi_host_is_windows() != 0) {
      lea7[2] = 13;
    } else {
      lea7[2] = 61;
    }
  } else {
    lea7[2] = 5;
  }
  lea7[3] = (uint8_t)(u & 255u);
  lea7[4] = (uint8_t)((u / 256u) & 255u);
  lea7[5] = (uint8_t)((u / 65536u) & 255u);
  lea7[6] = (uint8_t)((u / 16777216u) & 255u);
  return pipeline_elf_ctx_append_bytes(ctx_bytes, lea7, 7);
}
