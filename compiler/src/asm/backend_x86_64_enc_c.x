// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// backend_x86_64_enc_c_x_doc_anchor: see function docblock below.

/** Exported function `backend_x86_64_enc_c_x_doc_anchor`.
 * Implements `backend_x86_64_enc_c_x_doc_anchor`.
 * @return i32
 */
export function backend_x86_64_enc_c_x_doc_anchor(): i32 {
  return 0;
}

// See implementation.

export extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;
export extern "C" function pipeline_elf_ctx_emit_code_len(ctx: *u8): i32;
export extern "C" function pipeline_elf_ctx_ensure_label(ctx: *u8, name: *u8, name_len: i32): i32;
export extern "C" function pipeline_elf_ctx_append_patch(ctx: *u8, rel32_offset: i32, name: *u8, name_len: i32, imm_bits: i32): i32;

#[no_mangle]
/** Exported function `x86_enc_u8`.
 * Implements `x86_enc_u8`.
 * @param elf_ctx *u8
 * @param b u8
 * @return i32
 */
export function x86_enc_u8(elf_ctx: *u8, b: u8): i32 {
  let bb: u8 = b;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &bb, 1);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `x86_enc_bytes`.
 * Implements `x86_enc_bytes`.
 * @param elf_ctx *u8
 * @param buf *u8
 * @param n i32
 * @return i32
 */
export function x86_enc_bytes(elf_ctx: *u8, buf: *u8, n: i32): i32 {
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, buf, n);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `x86_enc_u32_le`.
 * Implements `x86_enc_u32_le`.
 * @param elf_ctx *u8
 * @param imm i32
 * @return i32
 */
export function x86_enc_u32_le(elf_ctx: *u8, imm: i32): i32 {
  // See implementation.
  let w: u32 = imm as u32;
  let b0: u8 = (w & 255) as u8;
  let b1: u8 = ((w / 256) & 255) as u8;
  let b2: u8 = ((w / 65536) & 255) as u8;
  let b3: u8 = ((w / 16777216) & 255) as u8;
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b0, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b1, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b2, 1) != 0) { return 0 - 1; }
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b3, 1);
  }
  return 0 - 1;
}

// x86_enc_jcc_rel32: see function docblock below.
#[no_mangle]
/** Exported function `x86_enc_jcc_rel32`.
 * Implements `x86_enc_jcc_rel32`.
 * @param elf_ctx *u8
 * @param opcode2 u8
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function x86_enc_jcc_rel32(elf_ctx: *u8, opcode2: u8, label: *u8, label_len: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (label == 0) { return 0 - 1; }
  if (label_len <= 0) { return 0 - 1; }
  let b0: u8 = 15; // 0x0F
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
    return pipeline_elf_ctx_append_patch(elf_ctx, rel32_at, label, label_len, 0);
  }
  return 0 - 1;
}

// G-02f-130：rbp/alu enc pure helpers

/** Exported function `x86_enc_append_i32_le`.
 * Implements `x86_enc_append_i32_le`.
 * @param elf_ctx *u8
 * @param v i32
 * @return i32
 */
export function x86_enc_append_i32_le(elf_ctx: *u8, v: i32): i32 {
  let w: u32 = v as u32;
  let b0: u8 = (w & 255) as u8;
  let b1: u8 = ((w / 256) & 255) as u8;
  let b2: u8 = ((w / 65536) & 255) as u8;
  let b3: u8 = ((w / 16777216) & 255) as u8;
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b0, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b1, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b2, 1) != 0) { return 0 - 1; }
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b3, 1);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `x86_enc_movq_from_rbp_neg`.
 * Implements `x86_enc_movq_from_rbp_neg`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param disp8_modrm u8
 * @param disp32_modrm u8
 * @return i32
 */
export function x86_enc_movq_from_rbp_neg(elf_ctx: *u8, offset: i32, disp8_modrm: u8, disp32_modrm: u8): i32 {
  let disp: i32 = 0 - offset;
  let r64: u8 = 72;
  let op: u8 = 139; // 0x8B
  if (disp >= 0 - 128 && disp <= 0 - 1) {
    let d8: u8 = disp as u8;
    unsafe {
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &r64, 1) != 0) { return 0 - 1; }
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &op, 1) != 0) { return 0 - 1; }
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &disp8_modrm, 1) != 0) { return 0 - 1; }
      return pipeline_elf_ctx_append_bytes(elf_ctx, &d8, 1);
    }
    return 0 - 1;
  }
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &r64, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &op, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &disp32_modrm, 1) != 0) { return 0 - 1; }
  }
  return x86_enc_append_i32_le(elf_ctx, disp);
}

#[no_mangle]
/** Exported function `x86_enc_lea_from_rbp_neg`.
 * Implements `x86_enc_lea_from_rbp_neg`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param disp8_modrm u8
 * @param disp32_modrm u8
 * @return i32
 */
export function x86_enc_lea_from_rbp_neg(elf_ctx: *u8, offset: i32, disp8_modrm: u8, disp32_modrm: u8): i32 {
  let disp: i32 = 0 - offset;
  let r64: u8 = 72;
  let op: u8 = 141; // 0x8D
  if (disp >= 0 - 128 && disp <= 0 - 1) {
    let d8: u8 = disp as u8;
    unsafe {
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &r64, 1) != 0) { return 0 - 1; }
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &op, 1) != 0) { return 0 - 1; }
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &disp8_modrm, 1) != 0) { return 0 - 1; }
      return pipeline_elf_ctx_append_bytes(elf_ctx, &d8, 1);
    }
    return 0 - 1;
  }
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &r64, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &op, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &disp32_modrm, 1) != 0) { return 0 - 1; }
  }
  return x86_enc_append_i32_le(elf_ctx, disp);
}

#[no_mangle]
/** Exported function `x86_enc_movl_from_rbp_neg32`.
 * Implements `x86_enc_movl_from_rbp_neg32`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param disp8_modrm u8
 * @param disp32_modrm u8
 * @return i32
 */
export function x86_enc_movl_from_rbp_neg32(elf_ctx: *u8, offset: i32, disp8_modrm: u8, disp32_modrm: u8): i32 {
  let disp: i32 = 0 - offset;
  let op: u8 = 139; // 0x8B
  if (disp >= 0 - 128 && disp <= 0 - 1) {
    let d8: u8 = disp as u8;
    unsafe {
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &op, 1) != 0) { return 0 - 1; }
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &disp8_modrm, 1) != 0) { return 0 - 1; }
      return pipeline_elf_ctx_append_bytes(elf_ctx, &d8, 1);
    }
    return 0 - 1;
  }
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &op, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &disp32_modrm, 1) != 0) { return 0 - 1; }
  }
  return x86_enc_append_i32_le(elf_ctx, disp);
}

#[no_mangle]
/** Exported function `x86_enc_store_rax_to_rbp_neg`.
 * Implements `x86_enc_store_rax_to_rbp_neg`.
 * @param elf_ctx *u8
 * @param offset i32
 * @return i32
 */
export function x86_enc_store_rax_to_rbp_neg(elf_ctx: *u8, offset: i32): i32 {
  let disp: i32 = 0 - offset;
  let r64: u8 = 72;
  let op: u8 = 137; // 0x89
  if (disp >= 0 - 128 && disp <= 0 - 1) {
    let modrm: u8 = 69; // 0x45
    let d8: u8 = disp as u8;
    unsafe {
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &r64, 1) != 0) { return 0 - 1; }
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &op, 1) != 0) { return 0 - 1; }
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &modrm, 1) != 0) { return 0 - 1; }
      return pipeline_elf_ctx_append_bytes(elf_ctx, &d8, 1);
    }
    return 0 - 1;
  }
  let modrm32: u8 = 133; // 0x85
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &r64, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &op, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &modrm32, 1) != 0) { return 0 - 1; }
  }
  return x86_enc_append_i32_le(elf_ctx, disp);
}

#[no_mangle]
/** Exported function `x86_enc_store_rdx_to_rbp_neg`.
 * Implements `x86_enc_store_rdx_to_rbp_neg`.
 * @param elf_ctx *u8
 * @param offset i32
 * @return i32
 */
export function x86_enc_store_rdx_to_rbp_neg(elf_ctx: *u8, offset: i32): i32 {
  let disp: i32 = 0 - offset;
  let r64: u8 = 72;
  let op: u8 = 137; // 0x89
  if (disp >= 0 - 128 && disp <= 0 - 1) {
    let modrm: u8 = 85; // 0x55
    let d8: u8 = disp as u8;
    unsafe {
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &r64, 1) != 0) { return 0 - 1; }
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &op, 1) != 0) { return 0 - 1; }
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &modrm, 1) != 0) { return 0 - 1; }
      return pipeline_elf_ctx_append_bytes(elf_ctx, &d8, 1);
    }
    return 0 - 1;
  }
  let modrm32: u8 = 149; // 0x95
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &r64, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &op, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &modrm32, 1) != 0) { return 0 - 1; }
  }
  return x86_enc_append_i32_le(elf_ctx, disp);
}

#[no_mangle]
/** Exported function `x86_enc_alu_imm32_to_reg`.
 * Implements `x86_enc_alu_imm32_to_reg`.
 * @param elf_ctx *u8
 * @param imm i32
 * @param op_prefix u8
 * @param reg_modrm u8
 * @return i32
 */
export function x86_enc_alu_imm32_to_reg(elf_ctx: *u8, imm: i32, op_prefix: u8, reg_modrm: u8): i32 {
  if (imm == 0) { return 0; }
  if (imm >= 0 - 128 && imm <= 127) {
    let op83: u8 = 131; // 0x83
    let d8: u8 = imm as u8;
    unsafe {
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &op83, 1) != 0) { return 0 - 1; }
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &reg_modrm, 1) != 0) { return 0 - 1; }
      return pipeline_elf_ctx_append_bytes(elf_ctx, &d8, 1);
    }
    return 0 - 1;
  }
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &op_prefix, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &reg_modrm, 1) != 0) { return 0 - 1; }
  }
  return x86_enc_append_i32_le(elf_ctx, imm);
}

