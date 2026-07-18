// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// See implementation.
//
// See implementation.
// ElfCodegenCtx.code；
// See implementation.
//
// See implementation.
// reloc、elf_add_sym）。
// See implementation.

const elf = import("platform.elf");

/* See implementation. */
export extern function pipeline_asm_arm64_cset_cond_enc_from_cc(cc: i32): i32;

/** Exported function `enc_u32_le`.
 * Implements `enc_u32_le`.
 * @param ctx *ElfCodegenCtx
 * @param val i64
 * @return i32
 */
export function enc_u32_le(ctx: *ElfCodegenCtx, val: i64): i32 {
  let buf: u8[4] = [];
  buf[0] = elf.elf_u32_byte_at(val, 0);
  buf[1] = elf.elf_u32_byte_at(val, 1);
  buf[2] = elf.elf_u32_byte_at(val, 2);
  buf[3] = elf.elf_u32_byte_at(val, 3);
  return elf.append_elf_bytes(ctx, buf, 4);
}

/** Exported function `enc_prologue`.
 * Implements `enc_prologue`.
 * @param ctx *ElfCodegenCtx
 * @param frame_size i32
 * @return i32
 */
export function enc_prologue(ctx: *ElfCodegenCtx, frame_size: i32): i32 {
  ctx.current_frame_size = frame_size;
  /* stp x29, x30, [sp, #-16]! */
  if (enc_u32_le(ctx, 2847898621) != 0) { return -1; }
  /* mov x29, sp */
  if (enc_u32_le(ctx, 2432697341) != 0) { return -1; }
  /* sub sp, sp, #frame_size */
  let imm12: i32 = frame_size;
  if (imm12 > 4095) { imm12 = 4095; }
  return enc_u32_le(ctx, 3506439167 | (imm12 << 10));
}

/** Exported function `enc_epilogue`.
 * Implements `enc_epilogue`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_epilogue(ctx: *ElfCodegenCtx): i32 {
  let imm12: i32 = ctx.current_frame_size;
  if (imm12 > 4095) { imm12 = 4095; }
  /* add sp, sp, #frame_size */
  if (enc_u32_le(ctx, 2432697343 | (imm12 << 10)) != 0) { return -1; }
  /* ldp x29, x30, [sp], #16 */
  if (enc_u32_le(ctx, 2831252477) != 0) { return -1; }
  /* ret */
  return enc_u32_le(ctx, 3596551104);
}

/** Exported function `enc_mov_imm32_to_w0`.
 * Implements `enc_mov_imm32_to_w0`.
 * @param ctx *ElfCodegenCtx
 * @param imm32 i32
 * @return i32
 */
export function enc_mov_imm32_to_w0(ctx: *ElfCodegenCtx, imm32: i32): i32 {
  let lo: i32 = imm32 & 65535;
  let hi: i32 = (imm32 >> 16) & 65535;
  /* MOVZ w0, #lo */
  if (enc_u32_le(ctx, 1384120320 | (lo << 5)) != 0) { return -1; }
  if (hi != 0) {
    /* MOVK w0, #hi, lsl #16 */
    if (enc_u32_le(ctx, 1923219456 | (hi << 5)) != 0) { return -1; }
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function enc_ret_imm32(ctx: *ElfCodegenCtx, imm32: i32): i32 {
  if (enc_mov_imm32_to_w0(ctx, imm32) != 0) { return -1; }
  if (ctx.current_frame_size > 0) {
    return enc_epilogue(ctx);
  }
  return enc_u32_le(ctx, 3596551104);
}

/** Exported function `enc_mov_imm32_to_rbx`.
 * Implements `enc_mov_imm32_to_rbx`.
 * @param ctx *ElfCodegenCtx
 * @param imm32 i32
 * @return i32
 */
export function enc_mov_imm32_to_rbx(ctx: *ElfCodegenCtx, imm32: i32): i32 {
  let lo: i32 = imm32 & 65535;
  let hi: i32 = (imm32 >> 16) & 65535;
  /* MOVZ w1, #lo */
  if (enc_u32_le(ctx, 1384120321 | (lo << 5)) != 0) { return -1; }
  if (hi != 0) {
    /* MOVK w1, #hi, lsl #16 */
    if (enc_u32_le(ctx, 1923219457 | (hi << 5)) != 0) { return -1; }
  }
  return 0;
}

/** Exported function `enc_mov_imm64_to_rax`.
 * Implements `enc_mov_imm64_to_rax`.
 * @param ctx *ElfCodegenCtx
 * @param lo i32
 * @param hi i32
 * @return i32
 */
export function enc_mov_imm64_to_rax(ctx: *ElfCodegenCtx, lo: i32, hi: i32): i32 {
  let lo0: i32 = lo & 65535;
  let lo1: i32 = (lo >> 16) & 65535;
  let hi0: i32 = hi & 65535;
  let hi1: i32 = (hi >> 16) & 65535;
  /* See implementation. */
  */
  if (enc_u32_le(ctx, 3531603968 | (lo0 << 5)) != 0) { return -1; }
  /* See implementation. */
  if (enc_u32_le(ctx, 4070572032 | (lo1 << 5)) != 0) { return -1; }
  /* See implementation. */
  if (enc_u32_le(ctx, 4072669184 | (hi0 << 5)) != 0) { return -1; }
  /* See implementation. */
  return enc_u32_le(ctx, 4074766336 | (hi1 << 5));
}

/** Exported function `enc_push_rax`.
 * Implements `enc_push_rax`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_push_rax(ctx: *ElfCodegenCtx): i32 {
  /* sub sp, sp, #16 */
  if (enc_u32_le(ctx, 3506455551) != 0) { return -1; }
  /* str x0, [sp] */
  return enc_u32_le(ctx, 4177527776);
}

/**
* See implementation.
* See implementation.
*/
export function enc_sub_sp_imm12(ctx: *ElfCodegenCtx, imm: i32): i32 {
  if (imm <= 0) {
    return 0;
  }
  let imm12: i32 = imm;
  if (imm12 > 4095) {
    imm12 = 4095;
  }
  /* See implementation. */
  return enc_u32_le(ctx, 3506439167 | (imm12 << 10));
}

/**
* See implementation.
* off_bytes/8（≤4095）。
* See implementation.
*/
export function enc_str_x0_sp_offset(ctx: *ElfCodegenCtx, off_bytes: i32): i32 {
  let off: i32 = off_bytes;
  if (off < 0) {
    off = 0;
  }
  let imm12: i32 = off >> 3;
  if (imm12 > 4095) {
    imm12 = 4095;
  }
  /** 4177527776 == 0xf90003e0：Rn=31(sp)、Rt=x0、imm12=0。 */
  return enc_u32_le(ctx, 4177527776 | (imm12 << 10));
}

/** Exported function `enc_push_rbx`.
 * Implements `enc_push_rbx`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_push_rbx(ctx: *ElfCodegenCtx): i32 {
  /* sub sp, sp, #16 */
  if (enc_u32_le(ctx, 3506455551) != 0) { return -1; }
  /* str x1, [sp] — Rt=x1 */
  return enc_u32_le(ctx, 4177527777);
}

/** Exported function `enc_pop_rbx`.
 * Implements `enc_pop_rbx`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_pop_rbx(ctx: *ElfCodegenCtx): i32 {
  /* ldr x1, [sp] */
  if (enc_u32_le(ctx, 4181722081) != 0) { return -1; }
  /* add sp, sp, #16 */
  return enc_u32_le(ctx, 2432713727);
}

/** Exported function `enc_pop_rax`.
 * Implements `enc_pop_rax`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_pop_rax(ctx: *ElfCodegenCtx): i32 {
  /* ldr x0, [sp] */
  if (enc_u32_le(ctx, 4181722080) != 0) { return -1; }
  /* add sp, sp, #16 */
  return enc_u32_le(ctx, 2432713727);
}

/**
* See implementation.
* See implementation.
* slot=0。
*/
export function enc_ldr_sp_slot_to_xreg(ctx: *ElfCodegenCtx, slot: i32, reg: i32): i32 {
  let s: i32 = slot;
  if (s < 0) {
    s = 0;
  }
  if (s > 7) {
    s = 7;
  }
  let rd: i32 = reg;
  if (rd < 0) {
    rd = 0;
  }
  if (rd > 7) {
    rd = 7;
  }
  let imm12: i32 = s * 2;
  /** 0xF9400000 | (imm12<<10) | (Rn=31<<5) | Rt — LDR Xreg, [SP, #slot*16]。 */
  return enc_u32_le(ctx, 4181721088 | (imm12 << 10) | (31 << 5) | (rd & 31));
}

/** add w0, w0, w1。 */
export function enc_add_rax_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 184614912);
}

/** Exported function `enc_sub_rbx_rax_then_mov`.
 * Implements `enc_sub_rbx_rax_then_mov`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_sub_rbx_rax_then_mov(ctx: *ElfCodegenCtx): i32 {
  /** 0x4B000020 — SUB W0, W1, W0。 */
  return enc_u32_le(ctx, 1258291232);
}

/** Exported function `enc_sub_rax_rbx`.
 * Implements `enc_sub_rax_rbx`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_sub_rax_rbx(ctx: *ElfCodegenCtx): i32 {
  /** 0x4B000001 — SUB W0, W0, W1。 */
  return enc_u32_le(ctx, 1258356736);
}

/** mul w0, w0, w1。 */
export function enc_imul_rbx_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 453082112);
}

/** Exported function `enc_mov_rax_to_rbx`.
 * Implements `enc_mov_rax_to_rbx`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rax_to_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127713);
}

/** mov x0, x1。 */
export function enc_mov_rbx_to_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (1 << 16));
}

/** Exported function `enc_mov_rax_to_x2`.
 * Implements `enc_mov_rax_to_x2`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rax_to_x2(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (0 << 16) | 2);
}

/** Exported function `enc_mov_x2_to_rax`.
 * Implements `enc_mov_x2_to_rax`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_x2_to_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (2 << 16) | 0);
}

/** Exported function `enc_mov_rax_to_x9`.
 * Implements `enc_mov_rax_to_x9`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rax_to_x9(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (0 << 16) | 9);
}

/** Exported function `enc_mov_x9_to_rax`.
 * Implements `enc_mov_x9_to_rax`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_x9_to_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (9 << 16) | 0);
}

/** Exported function `enc_mov_rax_to_x10`.
 * Implements `enc_mov_rax_to_x10`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rax_to_x10(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (0 << 16) | 10);
}

/** Exported function `enc_mov_x10_to_rax`.
 * Implements `enc_mov_x10_to_rax`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_x10_to_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (10 << 16) | 0);
}

/** Exported function `enc_mov_rbx_to_x10`.
 * Implements `enc_mov_rbx_to_x10`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rbx_to_x10(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (1 << 16) | 10);
}

/** Exported function `enc_mov_x10_to_rbx`.
 * Implements `enc_mov_x10_to_rbx`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_x10_to_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (10 << 16) | 1);
}

/** Exported function `enc_mov_rax_to_x11`.
 * Implements `enc_mov_rax_to_x11`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rax_to_x11(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (0 << 16) | 11);
}

/** mov x0, x11。 */
export function enc_mov_x11_to_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (11 << 16) | 0);
}

/** mov x11, x1。 */
export function enc_mov_rbx_to_x11(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (1 << 16) | 11);
}

/** mov x1, x11。 */
export function enc_mov_x11_to_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (11 << 16) | 1);
}

/** Exported function `enc_mov_rax_to_x12`.
 * Implements `enc_mov_rax_to_x12`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rax_to_x12(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (0 << 16) | 12);
}

/** mov x0, x12。 */
export function enc_mov_x12_to_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (12 << 16) | 0);
}

/** mov x12, x1。 */
export function enc_mov_rbx_to_x12(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (1 << 16) | 12);
}

/** mov x1, x12。 */
export function enc_mov_x12_to_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (12 << 16) | 1);
}

/** Exported function `enc_mov_rax_to_x13`.
 * Implements `enc_mov_rax_to_x13`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rax_to_x13(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (0 << 16) | 13);
}

/** mov x0, x13。 */
export function enc_mov_x13_to_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (13 << 16) | 0);
}

/** mov x13, x1。 */
export function enc_mov_rbx_to_x13(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (1 << 16) | 13);
}

/** mov x1, x13。 */
export function enc_mov_x13_to_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (13 << 16) | 1);
}

/** Exported function `enc_mov_rax_to_x14`.
 * Implements `enc_mov_rax_to_x14`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rax_to_x14(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (0 << 16) | 14);
}

/** mov x0, x14。 */
export function enc_mov_x14_to_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (14 << 16) | 0);
}

/** mov x14, x1。 */
export function enc_mov_rbx_to_x14(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (1 << 16) | 14);
}

/** mov x1, x14。 */
export function enc_mov_x14_to_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (14 << 16) | 1);
}

/** Exported function `enc_mov_rax_to_x15`.
 * Implements `enc_mov_rax_to_x15`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rax_to_x15(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (0 << 16) | 15);
}

/** mov x0, x15。 */
export function enc_mov_x15_to_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (15 << 16) | 0);
}

/** mov x15, x1。 */
export function enc_mov_rbx_to_x15(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (1 << 16) | 15);
}

/** mov x1, x15。 */
export function enc_mov_x15_to_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (15 << 16) | 1);
}

/** Exported function `enc_mov_rbx_to_x2`.
 * Implements `enc_mov_rbx_to_x2`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rbx_to_x2(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (1 << 16) | 2);
}

/** Exported function `enc_mov_x2_to_rbx`.
 * Implements `enc_mov_x2_to_rbx`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_x2_to_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2852127712 | (2 << 16) | 1);
}

/** mvn w0, w0。 */
export function enc_not_eax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 706741216);
}

/** and w0, w0, w1。 */
export function enc_and_rbx_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 167837696);
}

/** orr w0, w0, w1。 */
export function enc_or_rbx_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 704708608);
}

/** eor w0, w0, w1。 */
export function enc_xor_rbx_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 1241579520);
}

/** Exported function `enc_mov_rbx_to_ecx`.
 * Implements `enc_mov_rbx_to_ecx`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_rbx_to_ecx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 704709602);
}

/** lslv w0, w0, w2。 */
export function enc_shl_cl_eax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 448929792);
}

/** lsrv w0, w0, w2。 */
export function enc_shr_cl_eax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 448930816);
}

/** asrv w0, w0, w2。 */
export function enc_sar_cl_eax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 448931840);
}

/** Exported function `enc_cltd`.
 * Implements `enc_cltd`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_cltd(ctx: *ElfCodegenCtx): i32 {
  return 0;
}

/** sdiv w0, w0, w1。 */
export function enc_idiv_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 448859136);
}

/** Exported function `enc_mov_edx_to_eax`.
 * Implements `enc_mov_edx_to_eax`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_mov_edx_to_eax(ctx: *ElfCodegenCtx): i32 {
  /* sdiv w2, w0, w1 */
  if (enc_u32_le(ctx, 448859138) != 0) { return -1; }
  /* msub w0, w2, w1, w0 */
  return enc_u32_le(ctx, 453083200);
}

/** neg w0, w0。 */
export function enc_neg_eax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 1258292192);
}

/** cmp w0, #0。 */
export function enc_test_eax_eax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 1895825439);
}

/** Exported function `enc_test_rbx_rbx`.
 * Implements `enc_test_rbx_rbx`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_test_rbx_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 1895825471);
}

/** cset w0, eq。 */
export function enc_setz_movzbl_eax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 446633952);
}

/** cmp w1, w0。 */
export function enc_cmp_rbx_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 1795162175);
}

/** Exported function `enc_cmp_rax_rbx`.
 * Comparison/utility `enc_cmp_rax_rbx`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_cmp_rax_rbx(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2038255711);
}

/** Exported function `enc_cmp_w0_imm12`.
 * Comparison/utility `enc_cmp_w0_imm12`.
 * @param ctx *ElfCodegenCtx
 * @param imm12 i32
 * @return i32
 */
export function enc_cmp_w0_imm12(ctx: *ElfCodegenCtx, imm12: i32): i32 {
  let imm: i32 = imm12 & 4095;
  return enc_u32_le(ctx, 1895825439 | (imm << 10));
}

/** Exported function `enc_cset_w0_from_cc`.
 * Implements `enc_cset_w0_from_cc`.
 * @param ctx *ElfCodegenCtx
 * @param cc i32
 * @return i32
 */
export function enc_cset_w0_from_cc(ctx: *ElfCodegenCtx, cc: i32): i32 {
  let c: i32 = pipeline_asm_arm64_cset_cond_enc_from_cc(cc);
  return enc_u32_le(ctx, 446629856 | (c << 12));
}

/** Exported function `enc_cmp_setcc_movzbl`.
 * Comparison/utility `enc_cmp_setcc_movzbl`.
 * @param ctx *ElfCodegenCtx
 * @param cc i32
 * @return i32
 */
export function enc_cmp_setcc_movzbl(ctx: *ElfCodegenCtx, cc: i32): i32 {
  /* cmp w1, w0 */
  if (enc_u32_le(ctx, 1795162175) != 0) { return -1; }
  let c: i32 = pipeline_asm_arm64_cset_cond_enc_from_cc(cc);
  /* See implementation. */
  return enc_u32_le(ctx, 446629856 | (c << 12));
}

/** Exported function `enc_store_rax_to_rbp`.
 * Implements `enc_store_rax_to_rbp`.
 * @param ctx *ElfCodegenCtx
 * @param offset i32
 * @return i32
 */
export function enc_store_rax_to_rbp(ctx: *ElfCodegenCtx, offset: i32): i32 {
  return enc_store_x_reg_to_rbp(ctx, 0, offset);
}

/** Exported function `enc_load_rbp_to_rax`.
 * Implements `enc_load_rbp_to_rax`.
 * @param ctx *ElfCodegenCtx
 * @param offset i32
 * @return i32
 */
export function enc_load_rbp_to_rax(ctx: *ElfCodegenCtx, offset: i32): i32 {
  let simm9: i32 = 0 - offset;
  if (simm9 < -256) { simm9 = -256; }
  let u9: i32 = simm9 & 511;
  let base: i32 = 0 - 130023424;
  return enc_u32_le(ctx, base | (u9 << 12) | (29 << 5) | 0);
}

/** Exported function `enc_load_rbp_to_rbx`.
 * Implements `enc_load_rbp_to_rbx`.
 * @param ctx *ElfCodegenCtx
 * @param offset i32
 * @return i32
 */
export function enc_load_rbp_to_rbx(ctx: *ElfCodegenCtx, offset: i32): i32 {
  let simm9: i32 = 0 - offset;
  if (simm9 < -256) { simm9 = -256; }
  let u9: i32 = simm9 & 511;
  let base: i32 = 0 - 130023424;
  return enc_u32_le(ctx, base | (u9 << 12) | (29 << 5) | 1);
}

/**
* See implementation.
* See implementation.
*/
export function enc_load_x29_pos_to_rax(ctx: *ElfCodegenCtx, off_pos: i32): i32 {
  let off: i32 = off_pos;
  if (off < 0) {
    off = 0;
  }
  let imm12: i32 = off >> 3;
  if (imm12 > 4095) {
    imm12 = 4095;
  }
/** See implementation for details. */
  let base: i32 = 0 - 113246720;
  let tail: i32 = 928 | (imm12 << 10);
  return enc_u32_le(ctx, base | tail);
}

/** Exported function `enc_store_x_reg_to_rbp`.
 * Implements `enc_store_x_reg_to_rbp`.
 * @param ctx *ElfCodegenCtx
 * @param reg i32
 * @param offset i32
 * @return i32
 */
export function enc_store_x_reg_to_rbp(ctx: *ElfCodegenCtx, reg: i32, offset: i32): i32 {
  let simm9: i32 = 0 - offset;
  if (simm9 < -256) { simm9 = -256; }
  let u9: i32 = simm9 & 511;
  let rt: i32 = reg;
  if (rt < 0) { rt = 0; }
  if (rt > 30) { rt = 30; }
  /* See implementation. */
  let base: i32 = 0 - 134217728;
  return enc_u32_le(ctx, base | (u9 << 12) | (29 << 5) | rt);
}

/** Exported function `enc_lea_rbp_to_rax`.
 * Implements `enc_lea_rbp_to_rax`.
 * @param ctx *ElfCodegenCtx
 * @param offset i32
 * @return i32
 */
export function enc_lea_rbp_to_rax(ctx: *ElfCodegenCtx, offset: i32): i32 {
  let imm12: i32 = offset;
  if (imm12 > 4095) { imm12 = 4095; }
  return enc_u32_le(ctx, 3506439072 | (imm12 << 10));
}

/** Exported function `enc_lea_rbp_to_rbx`.
 * Implements `enc_lea_rbp_to_rbx`.
 * @param ctx *ElfCodegenCtx
 * @param offset i32
 * @return i32
 */
export function enc_lea_rbp_to_rbx(ctx: *ElfCodegenCtx, offset: i32): i32 {
  let imm12: i32 = offset;
  if (imm12 > 4095) { imm12 = 4095; }
  return enc_u32_le(ctx, 3506439072 | (imm12 << 10) | 1);
}

/**
* See implementation.
*/
export function enc_memset_rbp_zero(ctx: *ElfCodegenCtx, rbp_off: i32, nbytes: i32): i32 {
  if (nbytes <= 0) {
    return 0;
  }
  if (enc_lea_rbp_to_rax(ctx, rbp_off) != 0) {
    return -1;
  }
  let lo2: i32 = nbytes & 65535;
  let hi2: i32 = (nbytes >> 16) & 65535;
  if (enc_u32_le(ctx, 1384120322 | (lo2 << 5)) != 0) {
    return -1;
  }
  if (hi2 != 0) {
    if (enc_u32_le(ctx, 1923219458 | (hi2 << 5)) != 0) {
      return -1;
    }
  }
  if (enc_mov_imm32_to_rbx(ctx, 0) != 0) {
    return -1;
  }
  let memset_nm: u8[64] = [109, 101, 109, 115, 101, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return enc_call(ctx, memset_nm, 6);
}

/** Exported function `enc_rax_plus_rbx_scale1`.
 * Implements `enc_rax_plus_rbx_scale1`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_rax_plus_rbx_scale1(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2334212096);
}

/** Exported function `enc_rax_plus_rbx_scale4`.
 * Implements `enc_rax_plus_rbx_scale4`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_rax_plus_rbx_scale4(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2334214144);
}

/** Exported function `enc_rax_plus_rbx_scale8`.
 * Implements `enc_rax_plus_rbx_scale8`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_rax_plus_rbx_scale8(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2334215168);
}

/** Exported function `enc_store_rax_to_rbx_indirect`.
 * Implements `enc_store_rax_to_rbx_indirect`.
 * @param ctx *ElfCodegenCtx
 * @param elem_sz i32
 * @return i32
 */
export function enc_store_rax_to_rbx_indirect(ctx: *ElfCodegenCtx, elem_sz: i32): i32 {
  if (elem_sz == 1) {
    /* strb w0, [x1] */
    return enc_u32_le(ctx, 956301344);
  }
  if (elem_sz == 4) {
    /* str w0, [x1] */
    return enc_u32_le(ctx, 3103784992);
  }
  /* See implementation. */
  return enc_u32_le(ctx, 4177526816);
}

/** ldr w0, [x0]。 */
export function enc_load_32_from_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 3107979264);
}

/** Exported function `enc_load_zext8_from_rax`.
 * Implements `enc_load_zext8_from_rax`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_load_zext8_from_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 960495616);
}

/** Exported function `enc_add_imm_to_rax`.
 * Implements `enc_add_imm_to_rax`.
 * @param ctx *ElfCodegenCtx
 * @param imm i32
 * @return i32
 */
export function enc_add_imm_to_rax(ctx: *ElfCodegenCtx, imm: i32): i32 {
  if (imm == 0) { return 0; }
  let imm12: i32 = imm;
  if (imm12 > 4095) { imm12 = 4095; }
  return enc_u32_le(ctx, 2432696320 | (imm12 << 10));
}

/** Exported function `enc_add_imm_to_rbx`.
 * Implements `enc_add_imm_to_rbx`.
 * @param ctx *ElfCodegenCtx
 * @param imm i32
 * @return i32
 */
export function enc_add_imm_to_rbx(ctx: *ElfCodegenCtx, imm: i32): i32 {
  if (imm == 0) { return 0; }
  let imm12: i32 = imm;
  if (imm12 > 4095) { imm12 = 4095; }
  /* See implementation. */
  return enc_u32_le(ctx, 2432696320 | (imm12 << 10) | 1 | (1 << 5));
}

/** Exported function `enc_load_rbp_to_x2`.
 * Implements `enc_load_rbp_to_x2`.
 * @param ctx *ElfCodegenCtx
 * @param offset i32
 * @return i32
 */
export function enc_load_rbp_to_x2(ctx: *ElfCodegenCtx, offset: i32): i32 {
  let simm9: i32 = 0 - offset;
  if (simm9 < -256) { simm9 = -256; }
  let u9: i32 = simm9 & 511;
  /* See implementation. */
  let base64: i32 = 0 - 130023424;
  let base: i32 = base64 - 1073741824;
  return enc_u32_le(ctx, base | (u9 << 12) | (29 << 5) | 2);
}

/** Exported function `enc_rbx_plus_x2_scale1`.
 * Implements `enc_rbx_plus_x2_scale1`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_rbx_plus_x2_scale1(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2334212096 + 65569);
}

/** add x1, x1, w2, uxtw #2（×4）。 */
export function enc_rbx_plus_x2_scale4(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2334214144 + 65569);
}

/** Exported function `enc_rbx_plus_x2_scale8`.
 * Implements `enc_rbx_plus_x2_scale8`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function enc_rbx_plus_x2_scale8(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 2334215168 + 65569);
}

/** ldr x0, [x0]。 */
export function enc_load_64_from_rax(ctx: *ElfCodegenCtx): i32 {
  return enc_u32_le(ctx, 4181721088);
}

/* See implementation. */
export function enc_store_rax_to_rbx_offset(ctx: *ElfCodegenCtx, offset: i32, store_size:
i32): i32 {
  if (store_size == 1) {
    /* strb w0, [x1, #offset] — imm12 bytes 0..4095 (u8[] array-lit byte-wise init). */
    let imm12: i32 = offset;
    if (imm12 > 4095) {
      imm12 = 4095;
    }
    return enc_u32_le(ctx, 956301312 | (imm12 << 10) | (1 << 5));
  }
  if (store_size == 4) {
    /* str w0, [x1, #offset] — offset must be a multiple of 4 */
    let imm12: i32 = offset / 4;
    if (imm12 > 4095) { imm12 = 4095; }
    return enc_u32_le(ctx, 3103784960 | (imm12 << 10) | (1 << 5));
  }
  /* str x0, [x1, #offset] — offset must be a multiple of 8 */
  let imm12: i32 = offset / 8;
  if (imm12 > 4095) { imm12 = 4095; }
  return enc_u32_le(ctx, 4177526784 | (imm12 << 10) | (1 << 5));
}

/** Exported function `enc_jz`.
 * Implements `enc_jz`.
 * @param ctx *ElfCodegenCtx
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function enc_jz(ctx: *ElfCodegenCtx, label: *u8, label_len: i32): i32 {
  if (enc_u32_le(ctx, 872415232) != 0) { return -1; }
  let at: i32 = ctx.code_len - 4;
  if (elf.elf_ensure_label_slot(ctx, label, label_len) != 0) { return -1; }
  return elf.elf_add_patch_with_bits(ctx, at, label, label_len, 19);
}

/** Exported function `enc_jeq`.
 * Implements `enc_jeq`.
 * @param ctx *ElfCodegenCtx
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function enc_jeq(ctx: *ElfCodegenCtx, label: *u8, label_len: i32): i32 {
  if (enc_u32_le(ctx, 1409286144) != 0) { return -1; }
  let at: i32 = ctx.code_len - 4;
  if (elf.elf_ensure_label_slot(ctx, label, label_len) != 0) { return -1; }
  return elf.elf_add_patch_with_bits(ctx, at, label, label_len, 19);
}

/** Exported function `enc_jge`.
 * Implements `enc_jge`.
 * @param ctx *ElfCodegenCtx
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function enc_jge(ctx: *ElfCodegenCtx, label: *u8, label_len: i32): i32 {
  if (enc_u32_le(ctx, 1409286154) != 0) { return -1; }
  let at: i32 = ctx.code_len - 4;
  if (elf.elf_ensure_label_slot(ctx, label, label_len) != 0) { return -1; }
  return elf.elf_add_patch_with_bits(ctx, at, label, label_len, 19);
}

/** Exported function `enc_jne`.
 * Implements `enc_jne`.
 * @param ctx *ElfCodegenCtx
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function enc_jne(ctx: *ElfCodegenCtx, label: *u8, label_len: i32): i32 {
  if (enc_u32_le(ctx, 1409286145) != 0) { return -1; }
  let at: i32 = ctx.code_len - 4;
  if (elf.elf_ensure_label_slot(ctx, label, label_len) != 0) { return -1; }
  return elf.elf_add_patch_with_bits(ctx, at, label, label_len, 19);
}

/** Exported function `enc_jnz`.
 * Implements `enc_jnz`.
 * @param ctx *ElfCodegenCtx
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function enc_jnz(ctx: *ElfCodegenCtx, label: *u8, label_len: i32): i32 {
  if (enc_u32_le(ctx, 889192448) != 0) { return -1; }
  let at: i32 = ctx.code_len - 4;
  if (elf.elf_ensure_label_slot(ctx, label, label_len) != 0) { return -1; }
  return elf.elf_add_patch_with_bits(ctx, at, label, label_len, 19);
}

/** Exported function `enc_jmp`.
 * Implements `enc_jmp`.
 * @param ctx *ElfCodegenCtx
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function enc_jmp(ctx: *ElfCodegenCtx, label: *u8, label_len: i32): i32 {
  if (enc_u32_le(ctx, 335544320) != 0) { return -1; }
  let at: i32 = ctx.code_len - 4;
  if (elf.elf_ensure_label_slot(ctx, label, label_len) != 0) { return -1; }
  return elf.elf_add_patch_with_bits(ctx, at, label, label_len, 26);
}

/**
* See implementation.
* See implementation.
*/
export function enc_mov_rax_to_arg_reg(ctx: *ElfCodegenCtx, k: i32): i32 {
  let rd: i32 = k;
  if (rd < 0) { rd = 0; }
  if (rd > 7) { rd = 7; }
  if (rd == 0) { return 0; }
  /** 0xAA0003E0 | Rd — mov xd,x0 */
  return enc_u32_le(ctx, 2852127712 | (rd & 31));
}

/** Exported function `enc_add_sp_imm12`.
 * Implements `enc_add_sp_imm12`.
 * @param ctx *ElfCodegenCtx
 * @param imm i32
 * @return i32
 */
export function enc_add_sp_imm12(ctx: *ElfCodegenCtx, imm: i32): i32 {
  if (imm <= 0) {
    return 0;
  }
  let imm12: i32 = imm;
  if (imm12 > 4095) { imm12 = 4095; }
  return enc_u32_le(ctx, 2432697343 | (imm12 << 10));
}

/** Exported function `enc_call`.
 * Implements `enc_call`.
 * @param ctx *ElfCodegenCtx
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function enc_call(ctx: *ElfCodegenCtx, name: *u8, name_len: i32): i32 {
  /* See implementation. */
  if (name_len <= 0) {
    return -1;
  }
  if (enc_u32_le(ctx, 2483027968) != 0) { return -1; }
  let at: i32 = ctx.code_len - 4;
  /**
  * See implementation.
  * See implementation.
  * See implementation.
  * See implementation.
  */
  if (ctx.macho_leading_underscore != 0 && name_len > 0 && name_len <= 63 && name[0] != 95) {
    let rn: u8[64] = [];
    rn[0] = 95;
    let k: i32 = 0;
    while (k < name_len && k < 63) {
      rn[k + 1] = name[k];
      k = k + 1;
    }
    return elf.elf_add_reloc(ctx, at, &rn[0], name_len + 1);
  }
  return elf.elf_add_reloc(ctx, at, &name[0], name_len);
}

/** Exported function `enc_label`.
 * Implements `enc_label`.
 * @param ctx *ElfCodegenCtx
 * @param name *u8
 * @param name_len i32
 * @param is_func i32
 * @return i32
 */
export function enc_label(ctx: *ElfCodegenCtx, name: *u8, name_len: i32, is_func: i32): i32 {
  if (is_func != 0) {
    if (elf.elf_pad_code_to_4(ctx) != 0) { return -1; }
  }
  if (elf.elf_add_label(ctx, name, name_len) != 0) { return -1; }
  if (is_func != 0) {
    if (ctx.macho_leading_underscore != 0) {
      let macho_name: u8[64] = [];
      macho_name[0] = 95;
      let k: i32 = 0;
      while (k < name_len && k < 63) {
        macho_name[k + 1] = name[k];
        k = k + 1;
      }
      return elf.elf_add_sym(ctx, macho_name, name_len + 1, elf.elf_section_code_len(ctx));
    }
    return elf.elf_add_sym(ctx, name, name_len, elf.elf_section_code_len(ctx));
  }
  return 0;
}
