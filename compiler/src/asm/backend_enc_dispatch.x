// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// backend_enc_dispatch_x_doc_anchor: see function docblock below.

/** Exported function `backend_enc_dispatch_x_doc_anchor`.
 * Implements `backend_enc_dispatch_x_doc_anchor`.
 * @return i32
 */
export function backend_enc_dispatch_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-100 / G-02f-146：enc helpers ---- */
/* See implementation. */

// See implementation.







/* See implementation. */

// See implementation.
// See implementation.

export extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;
export extern "C" function pipeline_elf_ctx_emit_code_len(ctx: *u8): i32;
export extern "C" function pipeline_elf_ctx_ensure_label(ctx: *u8, name: *u8, name_len: i32): i32;
export extern "C" function pipeline_elf_ctx_append_patch(ctx: *u8, rel32_offset: i32, name: *u8, name_len: i32, imm_bits: i32): i32;
export extern "C" function pipeline_elf_ctx_append_reloc(ctx: *u8, at: i32, name: *u8, name_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, word: i32): i32;

// backend_enc_x86_jcc_rel32_c: see function docblock below.
/** Exported function `backend_enc_x86_jcc_rel32_c`.
 * Implements `backend_enc_x86_jcc_rel32_c`.
 * @param elf_ctx *u8
 * @param opcode2 u8
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_x86_jcc_rel32_c(elf_ctx: *u8, opcode2: u8, label: *u8, label_len: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (label == 0) { return 0 - 1; }
  if (label_len <= 0) { return 0 - 1; }
  let b0: u8 = 15;
  let b1: u8 = opcode2;
  let z: u8 = 0;
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b0, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b1, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &z, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &z, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &z, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &z, 1) != 0) { return 0 - 1; }
    let rel32_at: i32 = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4;
    if (pipeline_elf_ctx_ensure_label(elf_ctx, label, label_len) != 0) { return 0 - 1; }
    return pipeline_elf_ctx_append_patch(elf_ctx, rel32_at, label, label_len, 32);
  }
  return 0 - 1;
}

/** Exported function `backend_enc_append_u32_le_c`.
 * Implements `backend_enc_append_u32_le_c`.
 * @param elf_ctx *u8
 * @param word u32
 * @return i32
 */
#[no_mangle]
export function backend_enc_append_u32_le_c(elf_ctx: *u8, word: u32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let b0: u8 = (word & 255) as u8;
  let b1: u8 = ((word / 256) & 255) as u8;
  let b2: u8 = ((word / 65536) & 255) as u8;
  let b3: u8 = ((word / 16777216) & 255) as u8;
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b0, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b1, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b2, 1) != 0) { return 0 - 1; }
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b3, 1);
  }
  return 0 - 1;
}

// G-02f-146：ARM64 BL stub + reloc；macho_leading_underscore @ ElfCodegenCtx+598052 LE
/** Exported function `backend_enc_arm64_call_c`.
 * Implements `backend_enc_arm64_call_c`.
 * @param elf_ctx *u8
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_arm64_call_c(elf_ctx: *u8, name: *u8, name_len: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (name == 0) { return 0 - 1; }
  if (name_len <= 0) { return 0 - 1; }
  unsafe {
    // 0x94000000 BL imm26 placeholder
    if (backend_enc_append_u32_le_c(elf_ctx, 2483027968) != 0) { return 0 - 1; }
    let at: i32 = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4;
    if (at < 0) { return 0 - 1; }
    // macho_leading_underscore i32 @ offset 598052
    let m: i32 = 256;
    let macho: i32 = elf_ctx[598052] as i32;
    macho = macho + (elf_ctx[598053] as i32) * m;
    macho = macho + (elf_ctx[598054] as i32) * (m * m);
    macho = macho + (elf_ctx[598055] as i32) * (m * m * m);
    if (macho != 0) {
      if (name_len <= 63) {
        if (name[0] != 95) {
          let reloc_name: u8[64] = [];
          reloc_name[0] = 95;
          let i: i32 = 0;
          while (i < name_len) {
            if (i >= 63) { break; }
            reloc_name[i + 1] = name[i];
            i = i + 1;
          }
          let reloc_len: i32 = name_len + 1;
          return pipeline_elf_ctx_append_reloc(elf_ctx, at, &reloc_name[0], reloc_len);
        }
      }
    }
    return pipeline_elf_ctx_append_reloc(elf_ctx, at, name, name_len);
  }
  return 0 - 1;
}

// ADD X31, X31, #imm12 — 0x910003ff | (imm12<<10)
/** Exported function `backend_enc_arm64_add_sp_imm12_c`.
 * Implements `backend_enc_arm64_add_sp_imm12_c`.
 * @param elf_ctx *u8
 * @param imm i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_arm64_add_sp_imm12_c(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (imm <= 0) { return 0; }
  if (imm > 4095) {
    return backend_enc_append_u32_le_c(elf_ctx, 2432697343 | (4095 * 1024));
  }
  return backend_enc_append_u32_le_c(elf_ctx, 2432697343 | ((imm as u32) * 1024));
}

// SUB X31, X31, #imm12 — 0xd10003ff | (imm12<<10)
/** Exported function `backend_enc_arm64_sub_sp_imm12_c`.
 * Implements `backend_enc_arm64_sub_sp_imm12_c`.
 * @param elf_ctx *u8
 * @param imm i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_arm64_sub_sp_imm12_c(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (imm <= 0) { return 0; }
  if (imm > 4095) {
    return backend_enc_append_u32_le_c(elf_ctx, 3506439167 | (4095 * 1024));
  }
  return backend_enc_append_u32_le_c(elf_ctx, 3506439167 | ((imm as u32) * 1024));
}

// STR X0, [SP, #imm12*8] — 0xf90003e0 | (imm12<<10)
/** Exported function `backend_enc_arm64_str_x0_sp_offset_c`.
 * Implements `backend_enc_arm64_str_x0_sp_offset_c`.
 * @param elf_ctx *u8
 * @param off_bytes i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_arm64_str_x0_sp_offset_c(elf_ctx: *u8, off_bytes: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (off_bytes < 0) {
    return backend_enc_append_u32_le_c(elf_ctx, 4177527776);
  }
  if (off_bytes / 8 > 4095) {
    return backend_enc_append_u32_le_c(elf_ctx, 4177527776 | (4095 * 1024));
  }
  return backend_enc_append_u32_le_c(elf_ctx, 4177527776 | (((off_bytes / 8) as u32) * 1024));
}

// LDUR w0, [x29, #-offset] — 0xB8400000 | (u9<<12) | (29<<5)
/** Exported function `arm64_enc_load_w0_from_rbp_c`.
 * Implements `arm64_enc_load_w0_from_rbp_c`.
 * @param elf_ctx *u8
 * @param offset i32
 * @return i32
 */
#[no_mangle]
export function arm64_enc_load_w0_from_rbp_c(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (offset < 0) { return 0 - 1; }
  if (offset > 256) {
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, (3091202048 | (256 * 4096) | 928) as i32);
    }
    return 0 - 1;
  }
  unsafe {
    let u9: i32 = (0 - offset) & 511;
    return arch_arm64_enc_enc_u32_le(elf_ctx, (3091202048 | ((u9 as u32) * 4096) | 928) as i32);
  }
  return 0 - 1;
}

// STUR w0, [x29, #-offset] — 0xB8000000 | (u9<<12) | (29<<5)
/** Exported function `arm64_enc_store_w0_to_rbp_c`.
 * Implements `arm64_enc_store_w0_to_rbp_c`.
 * @param elf_ctx *u8
 * @param offset i32
 * @return i32
 */
#[no_mangle]
export function arm64_enc_store_w0_to_rbp_c(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (offset < 0) { return 0 - 1; }
  if (offset > 256) {
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, (3087007744 | (256 * 4096) | 928) as i32);
    }
    return 0 - 1;
  }
  unsafe {
    let u9: i32 = (0 - offset) & 511;
    return arch_arm64_enc_enc_u32_le(elf_ctx, (3087007744 | ((u9 as u32) * 4096) | 928) as i32);
  }
  return 0 - 1;
}

/* ---- G-02f-206：backend_enc_*_arch ta-dispatch shells ---- */

export extern "C" function arch_arm64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_arm64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_arm64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_cltd(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
export extern "C" function pipeline_asm_arm64_cset_cond_enc_from_cc(cc: i32): i32;
export extern "C" function arch_arm64_enc_enc_epilogue(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
export extern "C" function arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_arm64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_arm64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_arm64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
export extern "C" function arch_arm64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
export extern "C" function arch_arm64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_neg_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_not_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_pop_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
export extern "C" function arch_arm64_enc_enc_push_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_push_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_arm64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_arm64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
export extern "C" function arch_arm64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
export extern "C" function arch_arm64_enc_enc_sub_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_call(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_cltd(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
export extern "C" function arch_riscv64_enc_enc_epilogue(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
export extern "C" function arch_riscv64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_load_rbp_to_a2(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_riscv64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
export extern "C" function arch_riscv64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
export extern "C" function arch_riscv64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_neg_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_not_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_pop_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
export extern "C" function arch_riscv64_enc_enc_push_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_push_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_riscv64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
export extern "C" function arch_riscv64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
export extern "C" function arch_riscv64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_call(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_cltd(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_cmp_eax_imm32(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
export extern "C" function arch_x86_64_enc_enc_epilogue(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
export extern "C" function arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
export extern "C" function arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
export extern "C" function arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_neg_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_not_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_pop_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
export extern "C" function arch_x86_64_enc_enc_push_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_push_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_x86_64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_sar_cl_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_shl_cl_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_shr_cl_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
export extern "C" function arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
export extern "C" function arch_x86_64_enc_enc_sub_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;

// backend_enc_label_arch: see function docblock below.
/** Exported function `backend_enc_label_arch`.
 * Implements `backend_enc_label_arch`.
 * @param elf_ctx *u8
 * @param name *u8
 * @param name_len i32
 * @param is_func i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_label(elf_ctx, name, name_len, is_func); }
  if (ta == 2) { return arch_riscv64_enc_enc_label(elf_ctx, name, name_len, is_func); }
  return arch_x86_64_enc_enc_label(elf_ctx, name, name_len, is_func);
  }
}

// backend_enc_prologue_arch: see function docblock below.
/** Exported function `backend_enc_prologue_arch`.
 * Implements `backend_enc_prologue_arch`.
 * @param elf_ctx *u8
 * @param frame_sz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_prologue_arch(elf_ctx: *u8, frame_sz: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_prologue(elf_ctx, frame_sz); }
  if (ta == 2) { return arch_riscv64_enc_enc_prologue(elf_ctx, frame_sz); }
  return arch_x86_64_enc_enc_prologue(elf_ctx, frame_sz);
  }
}

// backend_enc_epilogue_arch: see function docblock below.
/** Exported function `backend_enc_epilogue_arch`.
 * Implements `backend_enc_epilogue_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_epilogue_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_epilogue(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_epilogue(elf_ctx); }
  return arch_x86_64_enc_enc_epilogue(elf_ctx);
  }
}

// backend_enc_ret_imm32_arch: see function docblock below.
/** Exported function `backend_enc_ret_imm32_arch`.
 * Implements `backend_enc_ret_imm32_arch`.
 * @param elf_ctx *u8
 * @param imm32 i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_ret_imm32_arch(elf_ctx: *u8, imm32: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_ret_imm32(elf_ctx, imm32); }
  if (ta == 2) { return arch_riscv64_enc_enc_ret_imm32(elf_ctx, imm32); }
  return arch_x86_64_enc_enc_ret_imm32(elf_ctx, imm32);
  }
}

// backend_enc_mov_imm32_to_rbx_arch: see function docblock below.
/** Exported function `backend_enc_mov_imm32_to_rbx_arch`.
 * Implements `backend_enc_mov_imm32_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param imm32 i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm32: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32); }
  return arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32);
  }
}

// backend_enc_mov_imm64_to_rax_arch: see function docblock below.
/** Exported function `backend_enc_mov_imm64_to_rax_arch`.
 * Implements `backend_enc_mov_imm64_to_rax_arch`.
 * @param elf_ctx *u8
 * @param lo i32
 * @param hi i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi); }
  return arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi);
  }
}

// backend_enc_push_rax_arch: see function docblock below.
/** Exported function `backend_enc_push_rax_arch`.
 * Implements `backend_enc_push_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_push_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_push_rax(elf_ctx); }
  return arch_x86_64_enc_enc_push_rax(elf_ctx);
  }
}

// backend_enc_push_rbx_arch: see function docblock below.
/** Exported function `backend_enc_push_rbx_arch`.
 * Implements `backend_enc_push_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_push_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_push_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_push_rbx(elf_ctx); }
  return arch_x86_64_enc_enc_push_rbx(elf_ctx);
  }
}

// backend_enc_pop_rax_arch: see function docblock below.
/** Exported function `backend_enc_pop_rax_arch`.
 * Implements `backend_enc_pop_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_pop_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_pop_rax(elf_ctx); }
  return arch_x86_64_enc_enc_pop_rax(elf_ctx);
  }
}

// backend_enc_pop_rbx_arch: see function docblock below.
/** Exported function `backend_enc_pop_rbx_arch`.
 * Implements `backend_enc_pop_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_pop_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_pop_rbx(elf_ctx); }
  return arch_x86_64_enc_enc_pop_rbx(elf_ctx);
  }
}

// backend_enc_add_rax_rbx_arch: see function docblock below.
/** Exported function `backend_enc_add_rax_rbx_arch`.
 * Implements `backend_enc_add_rax_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_add_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_add_rax_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_rax_rbx(elf_ctx); }
  return arch_x86_64_enc_enc_add_rax_rbx(elf_ctx);
  }
}

// backend_enc_sub_rax_rbx_arch: see function docblock below.
/** Exported function `backend_enc_sub_rax_rbx_arch`.
 * Implements `backend_enc_sub_rax_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_sub_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_sub_rax_rbx(elf_ctx); }
  if (ta == 2) { return -1; }
  return arch_x86_64_enc_enc_sub_rax_rbx(elf_ctx);
  }
}

// backend_enc_sub_rbx_rax_then_mov_arch: see function docblock below.
/** Exported function `backend_enc_sub_rbx_rax_then_mov_arch`.
 * Implements `backend_enc_sub_rbx_rax_then_mov_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_sub_rbx_rax_then_mov(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_sub_rbx_rax_then_mov(elf_ctx); }
  return arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx);
  }
}

// backend_enc_imul_rbx_rax_arch: see function docblock below.
/** Exported function `backend_enc_imul_rbx_rax_arch`.
 * Implements `backend_enc_imul_rbx_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_imul_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_imul_rbx_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_imul_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx);
  }
}

// backend_enc_mov_rax_to_rbx_arch: see function docblock below.
/** Exported function `backend_enc_mov_rax_to_rbx_arch`.
 * Implements `backend_enc_mov_rax_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_mov_rax_to_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_rax_to_rbx(elf_ctx); }
  return arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx);
  }
}

// backend_enc_not_eax_arch: see function docblock below.
/** Exported function `backend_enc_not_eax_arch`.
 * Implements `backend_enc_not_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_not_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_not_eax(elf_ctx); }
  return arch_x86_64_enc_enc_not_eax(elf_ctx);
  }
}

// backend_enc_and_rbx_rax_arch: see function docblock below.
/** Exported function `backend_enc_and_rbx_rax_arch`.
 * Implements `backend_enc_and_rbx_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_and_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_and_rbx_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_and_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_and_rbx_rax(elf_ctx);
  }
}

// backend_enc_or_rbx_rax_arch: see function docblock below.
/** Exported function `backend_enc_or_rbx_rax_arch`.
 * Implements `backend_enc_or_rbx_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_or_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_or_rbx_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_or_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_or_rbx_rax(elf_ctx);
  }
}

// backend_enc_xor_rbx_rax_arch: see function docblock below.
/** Exported function `backend_enc_xor_rbx_rax_arch`.
 * Implements `backend_enc_xor_rbx_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_xor_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_xor_rbx_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_xor_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx);
  }
}

// backend_enc_mov_rbx_to_ecx_arch: see function docblock below.
/** Exported function `backend_enc_mov_rbx_to_ecx_arch`.
 * Implements `backend_enc_mov_rbx_to_ecx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_rbx_to_ecx_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_mov_rbx_to_ecx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_rbx_to_ecx(elf_ctx); }
  return arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx);
  }
}

// backend_enc_shl_cl_eax_arch: see function docblock below.
/** Exported function `backend_enc_shl_cl_eax_arch`.
 * Implements `backend_enc_shl_cl_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_shl_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_shl_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_shl_cl_eax(elf_ctx);
  }
}

// backend_enc_shr_cl_eax_arch: see function docblock below.
/** Exported function `backend_enc_shr_cl_eax_arch`.
 * Implements `backend_enc_shr_cl_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_shr_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_shr_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_shr_cl_eax(elf_ctx);
  }
}

// backend_enc_sar_cl_eax_arch: see function docblock below.
/** Exported function `backend_enc_sar_cl_eax_arch`.
 * Implements `backend_enc_sar_cl_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_sar_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_sar_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_sar_cl_eax(elf_ctx);
  }
}

// backend_enc_shl_cl_rax_arch: see function docblock below.
/** Exported function `backend_enc_shl_cl_rax_arch`.
 * Implements `backend_enc_shl_cl_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_shl_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_shl_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_shl_cl_rax(elf_ctx);
  }
}

// backend_enc_shr_cl_rax_arch: see function docblock below.
/** Exported function `backend_enc_shr_cl_rax_arch`.
 * Implements `backend_enc_shr_cl_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_shr_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_shr_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_shr_cl_rax(elf_ctx);
  }
}

// backend_enc_sar_cl_rax_arch: see function docblock below.
/** Exported function `backend_enc_sar_cl_rax_arch`.
 * Implements `backend_enc_sar_cl_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_sar_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_sar_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_sar_cl_rax(elf_ctx);
  }
}

// backend_enc_cltd_arch: see function docblock below.
/** Exported function `backend_enc_cltd_arch`.
 * Implements `backend_enc_cltd_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cltd_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_cltd(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_cltd(elf_ctx); }
  return arch_x86_64_enc_enc_cltd(elf_ctx);
  }
}

// backend_enc_mov_edx_to_eax_arch: see function docblock below.
/** Exported function `backend_enc_mov_edx_to_eax_arch`.
 * Implements `backend_enc_mov_edx_to_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_edx_to_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx); }
  return arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx);
  }
}

// backend_enc_neg_eax_arch: see function docblock below.
/** Exported function `backend_enc_neg_eax_arch`.
 * Implements `backend_enc_neg_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_neg_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_neg_eax(elf_ctx); }
  return arch_x86_64_enc_enc_neg_eax(elf_ctx);
  }
}

// backend_enc_test_eax_eax_arch: see function docblock below.
/** Exported function `backend_enc_test_eax_eax_arch`.
 * Implements `backend_enc_test_eax_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_test_eax_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_test_eax_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_test_eax_eax(elf_ctx); }
  return arch_x86_64_enc_enc_test_eax_eax(elf_ctx);
  }
}

// backend_enc_test_rbx_rbx_arch: see function docblock below.
/** Exported function `backend_enc_test_rbx_rbx_arch`.
 * Implements `backend_enc_test_rbx_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_test_rbx_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_test_rbx_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_test_rbx_rbx(elf_ctx); }
  return arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx);
  }
}

// backend_enc_setz_movzbl_eax_arch: see function docblock below.
/** Exported function `backend_enc_setz_movzbl_eax_arch`.
 * Implements `backend_enc_setz_movzbl_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_setz_movzbl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_setz_movzbl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx);
  }
}

// backend_enc_cmp_rbx_rax_arch: see function docblock below.
/** Exported function `backend_enc_cmp_rbx_rax_arch`.
 * Comparison/utility `backend_enc_cmp_rbx_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cmp_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx);
  }
}

// backend_enc_cmp_rax_rbx_arch: see function docblock below.
/** Exported function `backend_enc_cmp_rax_rbx_arch`.
 * Comparison/utility `backend_enc_cmp_rax_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cmp_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_cmp_rax_rbx(elf_ctx); }
  if (ta == 2) { return -1; }
  return arch_x86_64_enc_enc_cmp_rax_rbx(elf_ctx);
  }
}

// backend_enc_cmp_setcc_movzbl_arch: see function docblock below.
/** Exported function `backend_enc_cmp_setcc_movzbl_arch`.
 * Comparison/utility `backend_enc_cmp_setcc_movzbl_arch`.
 * @param elf_ctx *u8
 * @param cc i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc); }
  if (ta == 2) { return arch_riscv64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc); }
  return arch_x86_64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc);
  }
}

/** Exported function `backend_enc_cmp_w0_imm12_arch`.
 * Comparison/utility `backend_enc_cmp_w0_imm12_arch`.
 * @param elf_ctx *u8
 * @param imm12 i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cmp_w0_imm12_arch(elf_ctx: *u8, imm12: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_cmp_w0_imm12(elf_ctx, imm12); }
  if (ta == 2) { return arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_cmp_eax_imm32(elf_ctx, imm12);
  }
}

/** Exported function `backend_enc_cset_w0_from_cc_arch`.
 * Implements `backend_enc_cset_w0_from_cc_arch`.
 * @param elf_ctx *u8
 * @param cc i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cset_w0_from_cc_arch(elf_ctx: *u8, cc: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_cset_w0_from_cc(elf_ctx, cc); }
  return backend_enc_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
}

// backend_enc_store_rax_to_rbp_arch: see function docblock below.
/** Exported function `backend_enc_store_rax_to_rbp_arch`.
 * Implements `backend_enc_store_rax_to_rbp_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx, offset); }
  if (ta == 2) { return arch_riscv64_enc_enc_store_rax_to_rbp(elf_ctx, offset); }
  return arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
  }
}

// backend_enc_load_rbp_to_rax_arch: see function docblock below.
/** Exported function `backend_enc_load_rbp_to_rax_arch`.
 * Implements `backend_enc_load_rbp_to_rax_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx, offset); }
  if (ta == 2) { return arch_riscv64_enc_enc_load_rbp_to_rax(elf_ctx, offset); }
  return arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx, offset);
  }
}

// backend_enc_lea_rbp_to_rax_arch: see function docblock below.
/** Exported function `backend_enc_lea_rbp_to_rax_arch`.
 * Implements `backend_enc_lea_rbp_to_rax_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx, offset); }
  if (ta == 2) { return arch_riscv64_enc_enc_lea_rbp_to_rax(elf_ctx, offset); }
  return arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
  }
}

// backend_enc_lea_rbp_to_rbx_arch: see function docblock below.
/** Exported function `backend_enc_lea_rbp_to_rbx_arch`.
 * Implements `backend_enc_lea_rbp_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_lea_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset); }
  if (ta == 2) { return arch_riscv64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset); }
  return arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
  }
}

// backend_enc_rax_plus_rbx_scale4_arch: see function docblock below.
/** Exported function `backend_enc_rax_plus_rbx_scale4_arch`.
 * Implements `backend_enc_rax_plus_rbx_scale4_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rax_plus_rbx_scale4_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_rax_plus_rbx_scale4(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_rax_plus_rbx_scale4(elf_ctx); }
  return arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx);
  }
}

// backend_enc_rax_plus_rbx_scale1_arch: see function docblock below.
/** Exported function `backend_enc_rax_plus_rbx_scale1_arch`.
 * Implements `backend_enc_rax_plus_rbx_scale1_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rax_plus_rbx_scale1_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_rax_plus_rbx_scale1(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_rax_plus_rbx_scale1(elf_ctx); }
  return arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx);
  }
}

// backend_enc_rax_plus_rbx_scale8_arch: see function docblock below.
/** Exported function `backend_enc_rax_plus_rbx_scale8_arch`.
 * Implements `backend_enc_rax_plus_rbx_scale8_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rax_plus_rbx_scale8_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_rax_plus_rbx_scale8(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_rax_plus_rbx_scale8(elf_ctx); }
  return arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx);
  }
}

// backend_enc_store_rax_to_rbx_indirect_arch: see function docblock below.
/** Exported function `backend_enc_store_rax_to_rbx_indirect_arch`.
 * Implements `backend_enc_store_rax_to_rbx_indirect_arch`.
 * @param elf_ctx *u8
 * @param elem_sz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx: *u8, elem_sz: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz); }
  if (ta == 2) { return arch_riscv64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz); }
  return arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz);
  }
}

// backend_enc_load_zext8_from_rax_arch: see function docblock below.
/** Exported function `backend_enc_load_zext8_from_rax_arch`.
 * Implements `backend_enc_load_zext8_from_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_load_zext8_from_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_load_zext8_from_rax(elf_ctx); }
  return arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx);
  }
}

// backend_enc_add_imm_to_rax_arch: see function docblock below.
/** Exported function `backend_enc_add_imm_to_rax_arch`.
 * Implements `backend_enc_add_imm_to_rax_arch`.
 * @param elf_ctx *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_add_imm_to_rax(elf_ctx, imm); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_imm_to_rax(elf_ctx, imm); }
  return arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx, imm);
  }
}

// backend_enc_add_imm_to_rbx_arch: see function docblock below.
/** Exported function `backend_enc_add_imm_to_rbx_arch`.
 * Implements `backend_enc_add_imm_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_add_imm_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_add_imm_to_rbx(elf_ctx, imm); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx, imm); }
  return arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
  }
}

// backend_enc_load_rbp_index_scratch_arch: see function docblock below.
/** Exported function `backend_enc_load_rbp_index_scratch_arch`.
 * Implements `backend_enc_load_rbp_index_scratch_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_rbp_index_scratch_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx, offset); }
  if (ta == 2) { return arch_riscv64_enc_enc_load_rbp_to_a2(elf_ctx, offset); }
  return arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx, offset);
  }
}

// backend_enc_load_64_from_rax_arch: see function docblock below.
/** Exported function `backend_enc_load_64_from_rax_arch`.
 * Implements `backend_enc_load_64_from_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_load_64_from_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_load_64_from_rax(elf_ctx); }
  return arch_x86_64_enc_enc_load_64_from_rax(elf_ctx);
  }
}

// backend_enc_store_rax_to_rbx_offset_arch: see function docblock below.
/** Exported function `backend_enc_store_rax_to_rbx_offset_arch`.
 * Implements `backend_enc_store_rax_to_rbx_offset_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param store_size i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, offset: i32, store_size: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size); }
  if (ta == 2) { return arch_riscv64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size); }
  return arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size);
  }
}

// backend_enc_mov_rbx_to_rax_arch: see function docblock below.
/** Exported function `backend_enc_mov_rbx_to_rax_arch`.
 * Implements `backend_enc_mov_rbx_to_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_mov_rbx_to_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_rbx_to_rax(elf_ctx); }
  return arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx);
  }
}

// backend_enc_jz_arch: see function docblock below.
/** Exported function `backend_enc_jz_arch`.
 * Implements `backend_enc_jz_arch`.
 * @param elf_ctx *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_jz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_jz(elf_ctx, label, label_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_jz(elf_ctx, label, label_len); }
  return arch_x86_64_enc_enc_jz(elf_ctx, label, label_len);
  }
}

// backend_enc_jeq_arch: see function docblock below.
/** Exported function `backend_enc_jeq_arch`.
 * Implements `backend_enc_jeq_arch`.
 * @param elf_ctx *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_jeq_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_jeq(elf_ctx, label, label_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_jeq(elf_ctx, label, label_len); }
  return arch_x86_64_enc_enc_jeq(elf_ctx, label, label_len);
  }
}

// backend_enc_jge_arch: see function docblock below.
/** Exported function `backend_enc_jge_arch`.
 * Implements `backend_enc_jge_arch`.
 * @param elf_ctx *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_jge_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_jge(elf_ctx, label, label_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_jge(elf_ctx, label, label_len); }
  return arch_x86_64_enc_enc_jge(elf_ctx, label, label_len);
  }
}

// backend_enc_jnz_arch: see function docblock below.
/** Exported function `backend_enc_jnz_arch`.
 * Implements `backend_enc_jnz_arch`.
 * @param elf_ctx *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_jnz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_jnz(elf_ctx, label, label_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_jnz(elf_ctx, label, label_len); }
  return arch_x86_64_enc_enc_jnz(elf_ctx, label, label_len);
  }
}

// backend_enc_jmp_arch: see function docblock below.
/** Exported function `backend_enc_jmp_arch`.
 * Implements `backend_enc_jmp_arch`.
 * @param elf_ctx *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_jmp(elf_ctx, label, label_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_jmp(elf_ctx, label, label_len); }
  return arch_x86_64_enc_enc_jmp(elf_ctx, label, label_len);
  }
}

// backend_enc_mov_rax_to_arg_reg_arch: see function docblock below.
/** Exported function `backend_enc_mov_rax_to_arg_reg_arch`.
 * Implements `backend_enc_mov_rax_to_arg_reg_arch`.
 * @param elf_ctx *u8
 * @param k i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k); }
  return arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
  }
}

// backend_enc_call_arch: see function docblock below.
/** Exported function `backend_enc_call_arch`.
 * Implements `backend_enc_call_arch`.
 * @param elf_ctx *u8
 * @param name *u8
 * @param name_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_call_arch(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return backend_enc_arm64_call_c(elf_ctx, name, name_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_call(elf_ctx, name, name_len); }
  return arch_x86_64_enc_enc_call(elf_ctx, name, name_len);
  }
}

/* See implementation. */
export extern "C" function arch_arm64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_jne(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx: *u8, reg: i32, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_add_a2_a3(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_add_rbx_a3(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_add_sp_imm12(elf_ctx: *u8, nbytes: i32): i32;
export extern "C" function arch_riscv64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mul_a2_a3(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mul_rbx_a3(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rsub_a2_a3(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rsub_rbx_a3(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_sub_a2_a3(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_sub_rbx_a3(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_add_ebx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_add_ecx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_add_rsp_imm(elf_ctx: *u8, nbytes: i32): i32;
export extern "C" function arch_x86_64_enc_enc_div_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_imul_ebx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_imul_ecx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_rsub_ebx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_rsub_ecx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_sub_ebx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_sub_ecx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_xor_edx_edx(elf_ctx: *u8): i32;

// backend_enc_store_x_reg_to_rbp_arch: see function docblock below.
/** Exported function `backend_enc_store_x_reg_to_rbp_arch`.
 * Implements `backend_enc_store_x_reg_to_rbp_arch`.
 * @param elf_ctx *u8
 * @param reg i32
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_x_reg_to_rbp_arch(elf_ctx: *u8, reg: i32, offset: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, reg, offset); }
  return 0 - 1;
  }
}

// backend_enc_jne_arch: see function docblock below.
/** Exported function `backend_enc_jne_arch`.
 * Implements `backend_enc_jne_arch`.
 * @param elf_ctx *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_jne_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_jne(elf_ctx, label, label_len); }
  return backend_enc_jnz_arch(elf_ctx, label, label_len, ta);
  }
}

// backend_enc_call_stack_cleanup_arch: see function docblock below.
/** Exported function `backend_enc_call_stack_cleanup_arch`.
 * Implements `backend_enc_call_stack_cleanup_arch`.
 * @param elf_ctx *u8
 * @param nbytes i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_call_stack_cleanup_arch(elf_ctx: *u8, nbytes: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (nbytes <= 0) { return 0; }
  if (ta == 1) { return backend_enc_arm64_add_sp_imm12_c(elf_ctx, nbytes); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_sp_imm12(elf_ctx, nbytes); }
  return arch_x86_64_enc_enc_add_rsp_imm(elf_ctx, nbytes);
  }
}

// backend_enc_call_stack_reserve_arch: see function docblock below.
/** Exported function `backend_enc_call_stack_reserve_arch`.
 * Implements `backend_enc_call_stack_reserve_arch`.
 * @param elf_ctx *u8
 * @param nbytes i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_call_stack_reserve_arch(elf_ctx: *u8, nbytes: i32, ta: i32): i32 {
  if (nbytes <= 0) { return 0; }
  if (ta == 1) { return backend_enc_arm64_sub_sp_imm12_c(elf_ctx, nbytes); }
  return 0;
}

// backend_enc_store_x0_sp_offset_arch: see function docblock below.
/** Exported function `backend_enc_store_x0_sp_offset_arch`.
 * Implements `backend_enc_store_x0_sp_offset_arch`.
 * @param elf_ctx *u8
 * @param off_bytes i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_x0_sp_offset_arch(elf_ctx: *u8, off_bytes: i32, ta: i32): i32 {
  if (ta == 1) { return backend_enc_arm64_str_x0_sp_offset_c(elf_ctx, off_bytes); }
  return 0 - 1;
}

// backend_enc_index_scratch_add_secondary_arch: see function docblock below.
/** Exported function `backend_enc_index_scratch_add_secondary_arch`.
 * Implements `backend_enc_index_scratch_add_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_index_scratch_add_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 184746050); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_a2_a3(elf_ctx); }
  return arch_x86_64_enc_enc_add_ecx_edx(elf_ctx);
  }
}

// backend_enc_index_scratch_sub_secondary_arch: see function docblock below.
/** Exported function `backend_enc_index_scratch_sub_secondary_arch`.
 * Implements `backend_enc_index_scratch_sub_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_index_scratch_sub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258487874); }
  if (ta == 2) { return arch_riscv64_enc_enc_sub_a2_a3(elf_ctx); }
  return arch_x86_64_enc_enc_sub_ecx_edx(elf_ctx);
  }
}

// backend_enc_index_scratch_rsub_secondary_arch: see function docblock below.
/** Exported function `backend_enc_index_scratch_rsub_secondary_arch`.
 * Implements `backend_enc_index_scratch_rsub_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_index_scratch_rsub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258422370); }
  if (ta == 2) { return arch_riscv64_enc_enc_rsub_a2_a3(elf_ctx); }
  return arch_x86_64_enc_enc_rsub_ecx_edx(elf_ctx);
  }
}

// backend_enc_rbx_index_rsub_secondary_arch: see function docblock below.
/** Exported function `backend_enc_rbx_index_rsub_secondary_arch`.
 * Implements `backend_enc_rbx_index_rsub_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rbx_index_rsub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258356833); }
  if (ta == 2) { return arch_riscv64_enc_enc_rsub_rbx_a3(elf_ctx); }
  return arch_x86_64_enc_enc_rsub_ebx_edx(elf_ctx);
  }
}

// backend_enc_rbx_index_add_secondary_arch: see function docblock below.
/** Exported function `backend_enc_rbx_index_add_secondary_arch`.
 * Implements `backend_enc_rbx_index_add_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rbx_index_add_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 184746017); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_rbx_a3(elf_ctx); }
  return arch_x86_64_enc_enc_add_ebx_edx(elf_ctx);
  }
}

// backend_enc_rbx_index_sub_secondary_arch: see function docblock below.
/** Exported function `backend_enc_rbx_index_sub_secondary_arch`.
 * Implements `backend_enc_rbx_index_sub_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rbx_index_sub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258487841); }
  if (ta == 2) { return arch_riscv64_enc_enc_sub_rbx_a3(elf_ctx); }
  return arch_x86_64_enc_enc_sub_ebx_edx(elf_ctx);
  }
}

// backend_enc_index_scratch_mul_secondary_arch: see function docblock below.
/** Exported function `backend_enc_index_scratch_mul_secondary_arch`.
 * Implements `backend_enc_index_scratch_mul_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_index_scratch_mul_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 453213250); }
  if (ta == 2) { return arch_riscv64_enc_enc_mul_a2_a3(elf_ctx); }
  return arch_x86_64_enc_enc_imul_ecx_edx(elf_ctx);
  }
}

// backend_enc_rbx_index_mul_secondary_arch: see function docblock below.
/** Exported function `backend_enc_rbx_index_mul_secondary_arch`.
 * Implements `backend_enc_rbx_index_mul_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rbx_index_mul_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 453213217); }
  if (ta == 2) { return arch_riscv64_enc_enc_mul_rbx_a3(elf_ctx); }
  return arch_x86_64_enc_enc_imul_ebx_edx(elf_ctx);
  }
}

// backend_enc_idiv_rbx_arch: see function docblock below.
/** Exported function `backend_enc_idiv_rbx_arch`.
 * Implements `backend_enc_idiv_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_idiv_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_idiv_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_idiv_rbx(elf_ctx); }
  if (arch_x86_64_enc_enc_cltd(elf_ctx) != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_idiv_rbx(elf_ctx);
  }
}

// backend_enc_div_rbx_arch: see function docblock below.
/** Exported function `backend_enc_div_rbx_arch`.
 * Implements `backend_enc_div_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_div_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_idiv_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_idiv_rbx(elf_ctx); }
  if (arch_x86_64_enc_enc_xor_edx_edx(elf_ctx) != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_div_rbx(elf_ctx);
  }
}

// backend_enc_rem_mod_arch: see function docblock below.
/** Exported function `backend_enc_rem_mod_arch`.
 * Implements `backend_enc_rem_mod_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rem_mod_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta); }
  if (backend_enc_cltd_arch(elf_ctx, ta) != 0) { return 0 - 1; }
  if (backend_enc_idiv_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
  return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
}

/**
 * Unsigned rem: routes through backend_enc_div_rbx_arch (xor edx + div) then mov remainder.
 * PLATFORM: SHARED — full-dispatch twin of thin wave322 fix (thin is product authority when L2).
 * @param elf_ctx *u8 — ElfCodegenCtx*
 * @param ta i32 — target arch
 * @return i32 — 0 success, -1 failure
 */
#[no_mangle]
export function backend_enc_rem_mod_unsigned_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta); }
  /* backend_enc_div_rbx_arch already emits xor_edx + divl %ebx (wave322 / G.7). */
  if (backend_enc_div_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
  return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
}

/* See implementation. */

export extern "C" function arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_rdx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_mov_rdx_to_arg_reg(elf_ctx: *u8, k: i32): i32;
export extern "C" function arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx: *u8, k: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx: *u8, off_pos: i32): i32;
export extern "C" function arch_arm64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_eax32(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_ebx32(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_arm64_enc_enc_load_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_load_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_arm64_enc_enc_rbx_plus_x2_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_rbx_plus_x2_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_rbx_plus_x2_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rbx_plus_a2_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rbx_plus_a2_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rbx_plus_a2_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_add_imm_to_a2(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_enc_enc_add_imm_to_ecx(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_enc_enc_sub_imm_from_a2(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_enc_enc_sub_imm_from_ecx(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_enc_enc_add_imm_to_ebx_index(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_enc_enc_sub_imm_from_rbx_index(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_enc_enc_sub_imm_from_ebx_index(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_enc_enc_load_rbp_to_a3(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_edx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_mul_imm_to_a2(elf_ctx: *u8, lit: i32): i32;
export extern "C" function arch_x86_64_enc_enc_imul_imm_to_ecx(elf_ctx: *u8, lit: i32): i32;
export extern "C" function arch_riscv64_enc_enc_mul_imm_to_rbx(elf_ctx: *u8, lit: i32): i32;
export extern "C" function arch_x86_64_enc_enc_imul_imm_to_ebx(elf_ctx: *u8, lit: i32): i32;

// G-02f-207：x86-only
/** Exported function `backend_enc_store_rdx_to_rbp_arch`.
 * Implements `backend_enc_store_rdx_to_rbp_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx, offset);
  }
}

/** Exported function `backend_enc_load_qword_from_rbx_to_rax_arch`.
 * Implements `backend_enc_load_qword_from_rbx_to_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_qword_from_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx);
  }
}

/** Exported function `backend_enc_load_qword_rbx8_to_rdx_arch`.
 * Implements `backend_enc_load_qword_rbx8_to_rdx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx);
  }
}

/** Exported function `backend_enc_load_rbp_to_rdx_arch`.
 * Implements `backend_enc_load_rbp_to_rdx_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_rbp_to_rdx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_load_rbp_to_rdx(elf_ctx, offset);
  }
}

/** Exported function `backend_enc_mov_rdx_to_arg_reg_arch`.
 * Implements `backend_enc_mov_rdx_to_arg_reg_arch`.
 * @param elf_ctx *u8
 * @param k i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_rdx_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_mov_rdx_to_arg_reg(elf_ctx, k);
  }
}

/** Exported function `backend_enc_mov_arg_reg_to_rax_arch`.
 * Implements `backend_enc_mov_arg_reg_to_rax_arch`.
 * @param elf_ctx *u8
 * @param k i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_arg_reg_to_rax_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 0) { return arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx, k); }
  return 0 - 1;
  }
}

/** Exported function `backend_enc_load_rbp_pos_to_rax_arch`.
 * Implements `backend_enc_load_rbp_pos_to_rax_arch`.
 * @param elf_ctx *u8
 * @param off_pos i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_rbp_pos_to_rax_arch(elf_ctx: *u8, off_pos: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 0) { return arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx, off_pos); }
  return 0 - 1;
  }
}

/** Exported function `backend_enc_jle_arch`.
 * Implements `backend_enc_jle_arch`.
 * @param elf_ctx *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_jle_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  return backend_enc_x86_jcc_rel32_c(elf_ctx, 142, label, label_len);
}

/** Exported function `backend_enc_jl_arch`.
 * Implements `backend_enc_jl_arch`.
 * @param elf_ctx *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_jl_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  return backend_enc_x86_jcc_rel32_c(elf_ctx, 140, label, label_len);
}

// G-02f-207：load 32 from [rax]
/** Exported function `backend_enc_load_32_from_rax_arch`.
 * Implements `backend_enc_load_32_from_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_32_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) {
    if (arch_arm64_enc_enc_load_32_from_rax(elf_ctx) != 0) { return 0 - 1; }
    return 0;
  }
  if (ta == 2) {
    if (arch_riscv64_enc_enc_load_32_from_rax(elf_ctx) != 0) { return 0 - 1; }
    return 0;
  }
  if (arch_x86_64_enc_enc_load_32_from_rax(elf_ctx) != 0) { return 0 - 1; }
  return 0;
  }
}

/** Exported function `backend_enc_load_i32_indirect_to_rax_arch`.
 * Implements `backend_enc_load_i32_indirect_to_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
}

// backend_enc_load_rbp_to_rbx_arch: see function docblock below.
/** Exported function `backend_enc_load_rbp_to_rbx_arch`.
 * Implements `backend_enc_load_rbp_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) { return arch_arm64_enc_enc_load_rbp_to_rbx(elf_ctx, offset); }
  if (ta == 2) { return arch_riscv64_enc_enc_load_rbp_to_rbx(elf_ctx, offset); }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let disp: i32 = 0 - offset;
    let u: u32 = disp as u32;
    let b: u8[7] = [];
    if (disp >= 0 - 128) {
      if (disp <= 0 - 1) {
        b[0] = 72;
        b[1] = 139;
        b[2] = 93;
        b[3] = (u & 255) as u8;
        return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 4);
      }
    }
    b[0] = 72;
    b[1] = 139;
    b[2] = 157;
    b[3] = (u & 255) as u8;
    b[4] = ((u / 256) & 255) as u8;
    b[5] = ((u / 65536) & 255) as u8;
    b[6] = ((u / 16777216) & 255) as u8;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 7);
  }
  return 0 - 1;
  }
}

// G-02f-207：store eax → rbp
/** Exported function `backend_enc_store_eax_to_rbp_arch`.
 * Implements `backend_enc_store_eax_to_rbp_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_eax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) { return arm64_enc_store_w0_to_rbp_c(elf_ctx, offset); }
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let disp: i32 = 0 - offset;
    let u: u32 = disp as u32;
    let b: u8[7] = [];
    if (disp >= 0 - 128) {
      if (disp <= 0 - 1) {
        b[0] = 137;
        b[1] = 69;
        b[2] = (u & 255) as u8;
        return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 3);
      }
    }
    b[0] = 137;
    b[1] = 133;
    b[2] = (u & 255) as u8;
    b[3] = ((u / 256) & 255) as u8;
    b[4] = ((u / 65536) & 255) as u8;
    b[5] = ((u / 16777216) & 255) as u8;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 6);
  }
  return 0 - 1;
}

// G-02f-207：lane load
/** Exported function `backend_enc_load_rbp_lane_to_rax_arch`.
 * Implements `backend_enc_load_rbp_lane_to_rax_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param esz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_rbp_lane_to_rax_arch(elf_ctx: *u8, offset: i32, esz: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 0) {
    if (esz == 4) { return arch_x86_64_enc_enc_load_rbp_to_eax32(elf_ctx, offset); }
  }
  if (ta == 1) {
    if (esz == 4) { return arm64_enc_load_w0_from_rbp_c(elf_ctx, offset); }
  }
  return backend_enc_load_rbp_to_rax_arch(elf_ctx, offset, ta);
  }
}

/** Exported function `backend_enc_load_rbp_lane_to_rbx_arch`.
 * Implements `backend_enc_load_rbp_lane_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param esz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_rbp_lane_to_rbx_arch(elf_ctx: *u8, offset: i32, esz: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 0) {
    if (esz == 4) { return arch_x86_64_enc_enc_load_rbp_to_ebx32(elf_ctx, offset); }
  }
  return backend_enc_load_rbp_to_rbx_arch(elf_ctx, offset, ta);
  }
}

// G-02f-207：arm64 ldr x0,[x29,#pos] — 0xf9400000 | (imm12<<10) | (29<<5) ≈ 4181722016 base
/** Exported function `backend_enc_load_x29_pos_to_rax_arch`.
 * Implements `backend_enc_load_x29_pos_to_rax_arch`.
 * @param elf_ctx *u8
 * @param off_pos i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_x29_pos_to_rax_arch(elf_ctx: *u8, off_pos: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) {
    let off: i32 = off_pos;
    if (off < 0) { off = 0; }
    let imm12: i32 = off / 8;
    if (imm12 > 4095) { imm12 = 4095; }
    return arch_arm64_enc_enc_u32_le(elf_ctx, (4181722016 | ((imm12 as u32) * 1024)) as i32);
  }
  return 0 - 1;
  }
}

// G-02f-207：rbx + index_scratch * esz
/** Exported function `backend_enc_rbx_plus_index_scratch_scaled_arch`.
 * Implements `backend_enc_rbx_plus_index_scratch_scaled_arch`.
 * @param elf_ctx *u8
 * @param esz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx: *u8, esz: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (esz == 1) {
    if (ta == 1) { return arch_arm64_enc_enc_rbx_plus_x2_scale1(elf_ctx); }
    if (ta == 2) { return arch_riscv64_enc_enc_rbx_plus_a2_scale1(elf_ctx); }
    return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(elf_ctx);
  }
  if (esz == 4) {
    if (ta == 1) { return arch_arm64_enc_enc_rbx_plus_x2_scale4(elf_ctx); }
    if (ta == 2) { return arch_riscv64_enc_enc_rbx_plus_a2_scale4(elf_ctx); }
    return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(elf_ctx);
  }
  if (ta == 1) { return arch_arm64_enc_enc_rbx_plus_x2_scale8(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_rbx_plus_a2_scale8(elf_ctx); }
  return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(elf_ctx);
  }
}

// G-02f-207：add imm → index_scratch
/** Exported function `backend_enc_add_imm_to_index_scratch_arch`.
 * Implements `backend_enc_add_imm_to_index_scratch_arch`.
 * @param elf_ctx *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_add_imm_to_index_scratch_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) {
    if (imm == 0) { return 0; }
    let imm12: i32 = imm;
    if (imm12 > 4095) { imm12 = 4095; }
    return arch_arm64_enc_enc_u32_le(elf_ctx, (285213762 + ((imm12 - 1) * 1024)) as i32);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_add_imm_to_a2(elf_ctx, imm); }
  return arch_x86_64_enc_enc_add_imm_to_ecx(elf_ctx, imm);
  }
}

/** Exported function `backend_enc_sub_imm_from_index_scratch_arch`.
 * Implements `backend_enc_sub_imm_from_index_scratch_arch`.
 * @param elf_ctx *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_sub_imm_from_index_scratch_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) {
    if (imm == 0) { return 0; }
    let imm12: i32 = imm;
    if (imm12 > 4095) { imm12 = 4095; }
    return arch_arm64_enc_enc_u32_le(elf_ctx, (1358955586 + ((imm12 - 1) * 1024)) as i32);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_sub_imm_from_a2(elf_ctx, imm); }
  return arch_x86_64_enc_enc_sub_imm_from_ecx(elf_ctx, imm);
  }
}

/** Exported function `backend_enc_add_imm_to_rbx_index_arch`.
 * Implements `backend_enc_add_imm_to_rbx_index_arch`.
 * @param elf_ctx *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_add_imm_to_rbx_index_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (imm == 0) { return 0; }
  if (ta == 1) {
    let imm12: i32 = imm;
    if (imm12 > 4095) { imm12 = 4095; }
    return arch_arm64_enc_enc_u32_le(elf_ctx, (285213729 + ((imm12 - 1) * 1024)) as i32);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx, imm); }
  return arch_x86_64_enc_enc_add_imm_to_ebx_index(elf_ctx, imm);
  }
}

/** Exported function `backend_enc_sub_imm_from_rbx_index_arch`.
 * Implements `backend_enc_sub_imm_from_rbx_index_arch`.
 * @param elf_ctx *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_sub_imm_from_rbx_index_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (imm == 0) { return 0; }
  if (ta == 1) {
    let imm12: i32 = imm;
    if (imm12 > 4095) { imm12 = 4095; }
    return arch_arm64_enc_enc_u32_le(elf_ctx, (1358955553 + ((imm12 - 1) * 1024)) as i32);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_sub_imm_from_rbx_index(elf_ctx, imm); }
  return arch_x86_64_enc_enc_sub_imm_from_ebx_index(elf_ctx, imm);
  }
}

/** Exported function `backend_enc_load_rbp_index_secondary_scratch_arch`.
 * Implements `backend_enc_load_rbp_index_secondary_scratch_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (ta == 1) {
    let simm9: i32 = 0 - offset;
    if (simm9 < 0 - 256) { simm9 = 0 - 256; }
    let u9: i32 = simm9 & 511;
    return arch_arm64_enc_enc_u32_le(elf_ctx, (3090513920 | ((u9 as u32) * 4096) | (29 * 32) | 3) as i32);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_load_rbp_to_a3(elf_ctx, offset); }
  return arch_x86_64_enc_enc_load_rbp_to_edx(elf_ctx, offset);
  }
}

/** Exported function `backend_enc_mul_imm_to_index_scratch_arch`.
 * Implements `backend_enc_mul_imm_to_index_scratch_arch`.
 * @param elf_ctx *u8
 * @param lit i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mul_imm_to_index_scratch_arch(elf_ctx: *u8, lit: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (lit <= 1) { return 0; }
  if (lit > 65535) { return 0 - 1; }
  if (ta == 1) {
    if (arch_arm64_enc_enc_u32_le(elf_ctx, (1384120320 | ((lit as u32) * 32) | 3) as i32) != 0) { return 0 - 1; }
    return arch_arm64_enc_enc_u32_le(elf_ctx, 453213250);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_mul_imm_to_a2(elf_ctx, lit); }
  return arch_x86_64_enc_enc_imul_imm_to_ecx(elf_ctx, lit);
  }
}

/** Exported function `backend_enc_mul_imm_to_rbx_arch`.
 * Implements `backend_enc_mul_imm_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param lit i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mul_imm_to_rbx_arch(elf_ctx: *u8, lit: i32, ta: i32): i32 {
  // See implementation.
  unsafe {
  if (lit <= 1) { return 0; }
  if (lit > 65535) { return 0 - 1; }
  if (ta == 1) {
    if (arch_arm64_enc_enc_u32_le(elf_ctx, (1384120320 | ((lit as u32) * 32) | 3) as i32) != 0) { return 0 - 1; }
    return arch_arm64_enc_enc_u32_le(elf_ctx, 453213217);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_mul_imm_to_rbx(elf_ctx, lit); }
  return arch_x86_64_enc_enc_imul_imm_to_ebx(elf_ctx, lit);
  }
}

/* See implementation. */

// G-02f-208：addss via xmm0/xmm1
/** Exported function `backend_enc_addss_rax_rbx_arch`.
 * Implements `backend_enc_addss_rax_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_addss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let a: u8[4] = [];
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 203;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    a[0] = 243; a[1] = 15; a[2] = 88; a[3] = 193;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    a[0] = 102; a[1] = 15; a[2] = 126; a[3] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4);
  }
  return 0 - 1;
}

/**
 * Scalar f32 multiply: IEEE bits in eax/rbx low 32 → product bits in eax (mulss).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `*` (wave294 Cap residual pure).
 * G.7: complete authority next to addss / mulsd (not integer imul on float bits).
 */
#[no_mangle]
export function backend_enc_mulss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let a: u8[4] = [];
    /* movd xmm0, eax — 66 0f 6e c0 */
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* movd xmm1, ebx — 66 0f 6e cb */
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 203;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* mulss xmm0, xmm1 — f3 0f 59 c1 */
    a[0] = 243; a[1] = 15; a[2] = 89; a[3] = 193;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* movd eax, xmm0 — 66 0f 7e c0 */
    a[0] = 102; a[1] = 15; a[2] = 126; a[3] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4);
  }
  return 0 - 1;
}

/**
 * Scalar f32 sub: left bits in ebx, right in eax → (left-right) bits in eax (subss).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `-` (wave298 Cap residual pure).
 * G.7: complete authority next to addss/mulss/subsd (not integer sub on float bits).
 */
#[no_mangle]
export function backend_enc_subss_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let a: u8[4] = [];
    /* movd xmm0, ebx — 66 0f 6e c3 */
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 195;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* movd xmm1, eax — 66 0f 6e c8 */
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 200;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* subss xmm0, xmm1 — f3 0f 5c c1 */
    a[0] = 243; a[1] = 15; a[2] = 92; a[3] = 193;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* movd eax, xmm0 — 66 0f 7e c0 */
    a[0] = 102; a[1] = 15; a[2] = 126; a[3] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4);
  }
  return 0 - 1;
}

/**
 * Scalar f32 sub: left bits in eax, right in ebx → (left-right) bits in eax (subss).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `-` (wave298 Cap residual pure).
 * G.7 twin of subss_rbx_rax (rax-rbx placement convention).
 */
#[no_mangle]
export function backend_enc_subss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let a: u8[4] = [];
    /* movd xmm0, eax — 66 0f 6e c0 */
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* movd xmm1, ebx — 66 0f 6e cb */
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 203;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* subss xmm0, xmm1 — f3 0f 5c c1 */
    a[0] = 243; a[1] = 15; a[2] = 92; a[3] = 193;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* movd eax, xmm0 — 66 0f 7e c0 */
    a[0] = 102; a[1] = 15; a[2] = 126; a[3] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4);
  }
  return 0 - 1;
}

/**
 * Scalar f32 divide: left bits in eax, right in ebx → quotient bits in eax (divss).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `/` (wave298 Cap residual pure).
 * G.7: complete authority next to mulss/divsd (not integer idiv on float bits).
 * IEEE Inf/NaN on /0 (no integer div-zero panic).
 */
#[no_mangle]
export function backend_enc_divss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let a: u8[4] = [];
    /* movd xmm0, eax — 66 0f 6e c0 */
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* movd xmm1, ebx — 66 0f 6e cb */
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 203;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* divss xmm0, xmm1 — f3 0f 5e c1 */
    a[0] = 243; a[1] = 15; a[2] = 94; a[3] = 193;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* movd eax, xmm0 — 66 0f 7e c0 */
    a[0] = 102; a[1] = 15; a[2] = 126; a[3] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4);
  }
  return 0 - 1;
}

/** Exported function `backend_enc_cvttss2si_eax_from_f32_bits_arch`.
 * Implements `backend_enc_cvttss2si_eax_from_f32_bits_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cvttss2si_eax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let a: u8[4] = [];
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    a[0] = 243; a[1] = 15; a[2] = 44; a[3] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4);
  }
  return 0 - 1;
}

/**
 * Truncate f64 bits in rax to i32 in eax (cvttsd2si).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `as i32` from f64 (wave291).
 */
#[no_mangle]
export function backend_enc_cvttsd2si_eax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    /* movq xmm0, rax — 66 48 0f 6e c0 (must include 66 + REX.W). */
    let q: u8[5] = [];
    q[0] = 102; q[1] = 72; q[2] = 15; q[3] = 110; q[4] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &q[0], 5) != 0) { return 0 - 1; }
    /* cvttsd2si eax, xmm0 — f2 0f 2c c0 */
    let a: u8[4] = [];
    a[0] = 242; a[1] = 15; a[2] = 44; a[3] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4);
  }
  return 0 - 1;
}

/**
 * Truncate f32 bits in eax to i64 in rax (REX.W cvttss2si).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `as i64/u64/usize/isize` from f32 (wave303).
 * Encoding: movd xmm0,eax (66 0F 6E C0) ; cvttss2si rax,xmm0 (F3 48 0F 2C C0).
 */
#[no_mangle]
export function backend_enc_cvttss2si_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    /* movd xmm0, eax — 66 0f 6e c0 */
    let m: u8[4] = [];
    m[0] = 102; m[1] = 15; m[2] = 110; m[3] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &m[0], 4) != 0) { return 0 - 1; }
    /* cvttss2si rax, xmm0 — f3 48 0f 2c c0 */
    let a: u8[5] = [];
    a[0] = 243; a[1] = 72; a[2] = 15; a[3] = 44; a[4] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 5);
  }
  return 0 - 1;
}

/**
 * Truncate f64 bits in rax to i64 in rax (REX.W cvttsd2si).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `as i64/u64/usize/isize` from f64 (wave303).
 * Encoding: movq xmm0,rax (66 REX.W 0F 6E C0) ; cvttsd2si rax,xmm0 (F2 48 0F 2C C0).
 */
#[no_mangle]
export function backend_enc_cvttsd2si_rax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    /* movq xmm0, rax — 66 48 0f 6e c0 */
    let q: u8[5] = [];
    q[0] = 102; q[1] = 72; q[2] = 15; q[3] = 110; q[4] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &q[0], 5) != 0) { return 0 - 1; }
    /* cvttsd2si rax, xmm0 — f2 48 0f 2c c0 */
    let a: u8[5] = [];
    a[0] = 242; a[1] = 72; a[2] = 15; a[3] = 44; a[4] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 5);
  }
  return 0 - 1;
}

/** Exported function `backend_enc_cvtsd2ss_eax_from_f64_bits_arch`.
 * Implements `backend_enc_cvtsd2ss_eax_from_f64_bits_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cvtsd2ss_eax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let q: u8[5] = [];
    q[0] = 102; q[1] = 72; q[2] = 15; q[3] = 110; q[4] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &q[0], 5) != 0) { return 0 - 1; }
    let a: u8[4] = [];
    a[0] = 242; a[1] = 15; a[2] = 90; a[3] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    a[0] = 102; a[1] = 15; a[2] = 126; a[3] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4);
  }
  return 0 - 1;
}

/** Exported function `backend_enc_cvtsi2ss_eax_from_i32_arch`.
 * Implements `backend_enc_cvtsi2ss_eax_from_i32_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cvtsi2ss_eax_from_i32_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let a: u8[4] = [];
    a[0] = 243; a[1] = 15; a[2] = 42; a[3] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    a[0] = 102; a[1] = 15; a[2] = 126; a[3] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4);
  }
  return 0 - 1;
}

/**
 * Convert i64/u64 (value in i64 range) in rax to f32 bits in eax (REX.W cvtsi2ss).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `as f32` from u64/i64 (wave299 Cap residual).
 * Encoding: cvtsi2ss xmm0,rax (F3 48 0F 2A C0) ; movd eax,xmm0 (66 0F 7E C0).
 * Note: signed convert; unsigned >2^63-1 uses backend_enc_cvtsi2ss_eax_from_u64_arch (wave304).
 */
#[no_mangle]
export function backend_enc_cvtsi2ss_eax_from_i64_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    /* cvtsi2ss xmm0, rax — f3 48 0f 2a c0 */
    let a: u8[5] = [];
    a[0] = 243; a[1] = 72; a[2] = 15; a[3] = 42; a[4] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 5) != 0) { return 0 - 1; }
    /* movd eax, xmm0 — 66 0f 7e c0 */
    let m: u8[4] = [];
    m[0] = 102; m[1] = 15; m[2] = 126; m[3] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &m[0], 4);
  }
  return 0 - 1;
}

/**
 * Convert i32 in eax to f64 bits in rax (cvtsi2sd).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `as f64` from i32 (wave292).
 */
#[no_mangle]
export function backend_enc_cvtsi2sd_rax_from_i32_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    /* cvtsi2sd xmm0, eax — f2 0f 2a c0 */
    let a: u8[4] = [];
    a[0] = 242; a[1] = 15; a[2] = 42; a[3] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* movq rax, xmm0 — 66 48 0f 7e c0 (must include 66 + REX.W). */
    let q: u8[5] = [];
    q[0] = 102; q[1] = 72; q[2] = 15; q[3] = 126; q[4] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &q[0], 5);
  }
  return 0 - 1;
}

/**
 * Convert i64/u64 (value in i64 range) in rax to f64 bits in rax (REX.W cvtsi2sd).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `as f64` from u64/i64 (wave295 Cap residual).
 * Encoding: cvtsi2sd xmm0,rax (F2 48 0F 2A C0) ; movq rax,xmm0 (66 REX.W 0F 7E C0).
 * Note: signed convert; unsigned >2^63-1 uses backend_enc_cvtsi2sd_rax_from_u64_arch (wave304).
 */
#[no_mangle]
export function backend_enc_cvtsi2sd_rax_from_i64_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    /* cvtsi2sd xmm0, rax — f2 48 0f 2a c0 */
    let a: u8[5] = [];
    a[0] = 242; a[1] = 72; a[2] = 15; a[3] = 42; a[4] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 5) != 0) { return 0 - 1; }
    /* movq rax, xmm0 — 66 48 0f 7e c0 */
    let q: u8[5] = [];
    q[0] = 102; q[1] = 72; q[2] = 15; q[3] = 126; q[4] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &q[0], 5);
  }
  return 0 - 1;
}

/**
 * Convert full-range u64 in rax to f64 bits in rax (unsigned convert sequence).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `as f64` from u64/usize (wave304 Cap residual).
 * Root: signed REX.W cvtsi2sd makes values >2^63-1 negative → freestanding run=0.
 * Algorithm (gcc/clang): if high bit clear, signed convert; else (v>>1)|(v&1) convert + add.
 * Fixed rel8: jns +28, jmp +10. G.7 next to signed i64 form.
 */
#[no_mangle]
export function backend_enc_cvtsi2sd_rax_from_u64_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let s: u8[43] = [];
    /* test rax,rax */
    s[0] = 72; s[1] = 133; s[2] = 192;
    /* jns +28 */
    s[3] = 121; s[4] = 28;
    /* mov rdx,rax; shr rdx,1; and eax,1; or rdx,rax */
    s[5] = 72; s[6] = 137; s[7] = 194;
    s[8] = 72; s[9] = 209; s[10] = 234;
    s[11] = 131; s[12] = 224; s[13] = 1;
    s[14] = 72; s[15] = 9; s[16] = 194;
    /* cvtsi2sd xmm0,rdx; addsd xmm0,xmm0; movq rax,xmm0 */
    s[17] = 242; s[18] = 72; s[19] = 15; s[20] = 42; s[21] = 194;
    s[22] = 242; s[23] = 15; s[24] = 88; s[25] = 192;
    s[26] = 102; s[27] = 72; s[28] = 15; s[29] = 126; s[30] = 192;
    /* jmp +10 */
    s[31] = 235; s[32] = 10;
    /* fit: cvtsi2sd xmm0,rax; movq rax,xmm0 */
    s[33] = 242; s[34] = 72; s[35] = 15; s[36] = 42; s[37] = 192;
    s[38] = 102; s[39] = 72; s[40] = 15; s[41] = 126; s[42] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &s[0], 43);
  }
  return 0 - 1;
}

/**
 * Convert full-range u64 in rax to f32 bits in eax (unsigned convert sequence).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `as f32` from u64/usize (wave304 Cap residual).
 * Same algorithm as u64→f64 with cvtsi2ss/addss/movd. jns +27, jmp +9.
 * G.7 next to signed backend_enc_cvtsi2ss_eax_from_i64_arch.
 */
#[no_mangle]
export function backend_enc_cvtsi2ss_eax_from_u64_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let s: u8[41] = [];
    s[0] = 72; s[1] = 133; s[2] = 192;
    s[3] = 121; s[4] = 27;
    s[5] = 72; s[6] = 137; s[7] = 194;
    s[8] = 72; s[9] = 209; s[10] = 234;
    s[11] = 131; s[12] = 224; s[13] = 1;
    s[14] = 72; s[15] = 9; s[16] = 194;
    s[17] = 243; s[18] = 72; s[19] = 15; s[20] = 42; s[21] = 194;
    s[22] = 243; s[23] = 15; s[24] = 88; s[25] = 192;
    s[26] = 102; s[27] = 15; s[28] = 126; s[29] = 192;
    s[30] = 235; s[31] = 9;
    s[32] = 243; s[33] = 72; s[34] = 15; s[35] = 42; s[36] = 192;
    s[37] = 102; s[38] = 15; s[39] = 126; s[40] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &s[0], 41);
  }
  return 0 - 1;
}

/**
 * Convert f32 bits in eax to f64 bits in rax (cvtss2sd).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `as f64` from f32 (wave293 Cap residual).
 */
#[no_mangle]
export function backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    /* movd xmm0, eax — 66 0f 6e c0 */
    let a: u8[4] = [];
    a[0] = 102; a[1] = 15; a[2] = 110; a[3] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* cvtss2sd xmm0, xmm0 — f3 0f 5a c0 */
    a[0] = 243; a[1] = 15; a[2] = 90; a[3] = 192;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &a[0], 4) != 0) { return 0 - 1; }
    /* movq rax, xmm0 — 66 48 0f 7e c0 */
    let q: u8[5] = [];
    q[0] = 102; q[1] = 72; q[2] = 15; q[3] = 126; q[4] = 192;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &q[0], 5);
  }
  return 0 - 1;
}

/** Exported function `backend_enc_mov_eax_to_xmm_arg_reg_arch`.
 * Implements `backend_enc_mov_eax_to_xmm_arg_reg_arch`.
 * @param elf_ctx *u8
 * @param k i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  if (k < 0) { return 0 - 1; }
  if (k > 7) { return 0 - 1; }
  unsafe {
    let p: u8[3] = [];
    p[0] = 102; p[1] = 15; p[2] = 110;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &p[0], 3) != 0) { return 0 - 1; }
    let modrm: u8 = (192 | ((k * 8) & 255)) as u8;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &modrm, 1);
  }
  return 0 - 1;
}

/** Exported function `backend_enc_mov_xmm_arg_reg_to_eax_arch`.
 * Implements `backend_enc_mov_xmm_arg_reg_to_eax_arch`.
 * @param elf_ctx *u8
 * @param k i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_xmm_arg_reg_to_eax_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  if (k < 0) { return 0 - 1; }
  if (k > 7) { return 0 - 1; }
  unsafe {
    let p: u8[3] = [];
    p[0] = 102; p[1] = 15; p[2] = 126;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &p[0], 3) != 0) { return 0 - 1; }
    let modrm: u8 = (192 | ((k * 8) & 255)) as u8;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &modrm, 1);
  }
  return 0 - 1;
}

/* See implementation. */

// arch_arm64_enc_enc_cmp_w0_imm12: see function docblock below.
/** Exported function `arch_arm64_enc_enc_cmp_w0_imm12`.
 * Comparison/utility `arch_arm64_enc_enc_cmp_w0_imm12`.
 * @param elf_ctx *u8
 * @param imm12 i32
 * @return i32
 */
#[no_mangle]
export function arch_arm64_enc_enc_cmp_w0_imm12(elf_ctx: *u8, imm12: i32): i32 {
  // See implementation.
  unsafe {
  let imm: i32 = imm12 & 4095;
  return arch_arm64_enc_enc_u32_le(elf_ctx, (1895825439 | (imm * 1024)) as i32);
  }
}

// arm64 cset w0,cond — 0x1a9f07e0 | (cond<<12)
/** Exported function `arch_arm64_enc_enc_cset_w0_from_cc`.
 * Implements `arch_arm64_enc_enc_cset_w0_from_cc`.
 * @param elf_ctx *u8
 * @param cc i32
 * @return i32
 */
#[no_mangle]
export function arch_arm64_enc_enc_cset_w0_from_cc(elf_ctx: *u8, cc: i32): i32 {
  unsafe {
    let c: i32 = pipeline_asm_arm64_cset_cond_enc_from_cc(cc);
    return arch_arm64_enc_enc_u32_le(elf_ctx, (446629856 | (c * 4096)) as i32);
  }
  return 0 - 1;
}

// arch_arm64_enc_enc_add_sp_imm12: see function docblock below.
/** Exported function `arch_arm64_enc_enc_add_sp_imm12`.
 * Implements `arch_arm64_enc_enc_add_sp_imm12`.
 * @param elf_ctx *u8
 * @param imm i32
 * @return i32
 */
#[no_mangle]
export function arch_arm64_enc_enc_add_sp_imm12(elf_ctx: *u8, imm: i32): i32 {
  return backend_enc_arm64_add_sp_imm12_c(elf_ctx, imm);
}

/** Exported function `arch_arm64_enc_enc_sub_sp_imm12`.
 * Implements `arch_arm64_enc_enc_sub_sp_imm12`.
 * @param elf_ctx *u8
 * @param imm i32
 * @return i32
 */
#[no_mangle]
export function arch_arm64_enc_enc_sub_sp_imm12(elf_ctx: *u8, imm: i32): i32 {
  return backend_enc_arm64_sub_sp_imm12_c(elf_ctx, imm);
}

/** Exported function `arch_arm64_enc_enc_str_x0_sp_offset`.
 * Implements `arch_arm64_enc_enc_str_x0_sp_offset`.
 * @param elf_ctx *u8
 * @param off_bytes i32
 * @return i32
 */
#[no_mangle]
export function arch_arm64_enc_enc_str_x0_sp_offset(elf_ctx: *u8, off_bytes: i32): i32 {
  return backend_enc_arm64_str_x0_sp_offset_c(elf_ctx, off_bytes);
}

/** Exported function `arch_arm64_enc_enc_call`.
 * Implements `arch_arm64_enc_enc_call`.
 * @param elf_ctx *u8
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
#[no_mangle]
export function arch_arm64_enc_enc_call(elf_ctx: *u8, name: *u8, name_len: i32): i32 {
  return backend_enc_arm64_call_c(elf_ctx, name, name_len);
}

// arch_riscv64_enc_enc_call: see function docblock below.
/** Exported function `arch_riscv64_enc_enc_call`.
 * Implements `arch_riscv64_enc_enc_call`.
 * @param elf_ctx *u8
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
#[no_mangle]
export function arch_riscv64_enc_enc_call(elf_ctx: *u8, name: *u8, name_len: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (name == 0) { return 0 - 1; }
  if (name_len <= 0) { return 0 - 1; }
  return 0 - 1;
}

/** Exported function `arch_riscv64_enc_enc_mov_rax_to_arg_reg`.
 * Implements `arch_riscv64_enc_enc_mov_rax_to_arg_reg`.
 * @param elf_ctx *u8
 * @param k i32
 * @return i32
 */
#[no_mangle]
export function arch_riscv64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (k < 0) { return 0 - 1; }
  return 0 - 1;
}

// backend_enc_append_u8_c: see function docblock below.
/** Exported function `backend_enc_append_u8_c`.
 * Implements `backend_enc_append_u8_c`.
 * @param elf_ctx *u8
 * @param byte i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_append_u8_c(elf_ctx: *u8, byte: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let b: u8 = (byte & 255) as u8;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b, 1);
  }
  return 0 - 1;
}

// x86_64 cdqe：48 98
/** Exported function `arch_x86_64_enc_enc_cdqe_rax`.
 * Implements `arch_x86_64_enc_enc_cdqe_rax`.
 * @param elf_ctx *u8
 * @return i32
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cdqe_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let cdqe: u8[2] = [];
    cdqe[0] = 72;
    cdqe[1] = 152;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &cdqe[0], 2);
  }
  return 0 - 1;
}
