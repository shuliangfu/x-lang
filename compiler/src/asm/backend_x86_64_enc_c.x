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
export extern "C" function pipeline_elf_ctx_append_reloc(ctx: *u8, offset: i32, name: *u8, name_len: i32): i32;
export extern "C" function pipeline_elf_ctx_add_label(ctx: *u8, name: *u8, name_len: i32, offset: i32): i32;
export extern "C" function pipeline_elf_ctx_pad_code_to_4(ctx: *u8): i32;
export extern "C" function pipeline_elf_ctx_add_sym(ctx: *u8, name: *u8, name_len: i32, offset: i32): i32;
export extern "C" function pipeline_elf_ctx_macho_leading_underscore(ctx: *u8): i32;

/** Exported function `x86_enc_u8`.
 * Implements `x86_enc_u8`.
 * @param elf_ctx *u8
 * @param b u8
 * @return i32
 */
#[no_mangle]
export function x86_enc_u8(elf_ctx: *u8, b: u8): i32 {
  let bb: u8 = b;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &bb, 1);
  }
  return 0 - 1;
}

/** Exported function `x86_enc_bytes`.
 * Implements `x86_enc_bytes`.
 * @param elf_ctx *u8
 * @param buf *u8
 * @param n i32
 * @return i32
 */
#[no_mangle]
export function x86_enc_bytes(elf_ctx: *u8, buf: *u8, n: i32): i32 {
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, buf, n);
  }
  return 0 - 1;
}

/** Exported function `x86_enc_u32_le`.
 * Implements `x86_enc_u32_le`.
 * @param elf_ctx *u8
 * @param imm i32
 * @return i32
 */
#[no_mangle]
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
/** Exported function `x86_enc_jcc_rel32`.
 * Implements `x86_enc_jcc_rel32`.
 * @param elf_ctx *u8
 * @param opcode2 u8
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
#[no_mangle]
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

/** Exported function `x86_enc_movq_from_rbp_neg`.
 * Implements `x86_enc_movq_from_rbp_neg`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param disp8_modrm u8
 * @param disp32_modrm u8
 * @return i32
 */
#[no_mangle]
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

/** Exported function `x86_enc_lea_from_rbp_neg`.
 * Implements `x86_enc_lea_from_rbp_neg`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param disp8_modrm u8
 * @param disp32_modrm u8
 * @return i32
 */
#[no_mangle]
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

/** Exported function `x86_enc_movl_from_rbp_neg32`.
 * Implements `x86_enc_movl_from_rbp_neg32`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param disp8_modrm u8
 * @param disp32_modrm u8
 * @return i32
 */
#[no_mangle]
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

/** Exported function `x86_enc_store_rax_to_rbp_neg`.
 * Implements `x86_enc_store_rax_to_rbp_neg`.
 * @param elf_ctx *u8
 * @param offset i32
 * @return i32
 */
#[no_mangle]
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

/** Exported function `x86_enc_store_rdx_to_rbp_neg`.
 * Implements `x86_enc_store_rdx_to_rbp_neg`.
 * @param elf_ctx *u8
 * @param offset i32
 * @return i32
 */
#[no_mangle]
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

/** Exported function `x86_enc_alu_imm32_to_reg`.
 * Implements `x86_enc_alu_imm32_to_reg`.
 * @param elf_ctx *u8
 * @param imm i32
 * @param op_prefix u8
 * @param reg_modrm u8
 * @return i32
 */
#[no_mangle]
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


// ---- Cap residual pure R2 wave1: arch_x86_64_enc fixed/multi insn (product C ABI) ----
// G.7: product authority for arch_x86_64_enc_* C symbols is this TU + seed FROM_X rest;
// arch/x86_64_enc.x is high-level import API (different names/types), not this link surface.

/** Emit x86_64 function prologue: push rbp; mov rbp,rsp; push rbx; sub rsp,frame.
 * Saves rbx (callee-saved) because body may use it as array/const base (SysV).
 * PLATFORM: SHARED — x86_64 SysV. Cap residual pure R2 wave1.
 * @param elf_ctx opaque ElfCodegenCtx*
 * @param frame_size stack frame bytes (LE encoded into sub imm32)
 * @return 0 on success, -1 on failure
 */
#[no_mangle]
export function arch_x86_64_enc_enc_prologue(elf_ctx: *u8, frame_size: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 85) != 0) { return 0 - 1; }
  let mov: u8[3] = [72, 137, 229];
  if (x86_enc_bytes(elf_ctx, mov, 3) != 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 83) != 0) { return 0 - 1; }
  let sub: u8[7] = [72, 129, 236, 0, 0, 0, 0];
  let fs: u32 = frame_size as u32;
  sub[3] = (fs & 255) as u8;
  sub[4] = ((fs / 256) & 255) as u8;
  sub[5] = ((fs / 65536) & 255) as u8;
  sub[6] = ((fs / 16777216) & 255) as u8;
  return x86_enc_bytes(elf_ctx, sub, 7);
}

/** Emit x86_64 epilogue: lea rsp,[rbp-8]; pop rbx; pop rbp; ret.
 * Mirrors prologue push rbx. PLATFORM: SHARED — x86_64 SysV.
 * Cap residual pure R2 wave1.
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on failure
 */
#[no_mangle]
export function arch_x86_64_enc_enc_epilogue(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let lea: u8[4] = [72, 141, 101, 248];
  if (x86_enc_bytes(elf_ctx, lea, 4) != 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 91) != 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 93) != 0) { return 0 - 1; }
  return x86_enc_u8(elf_ctx, 195);
}

/** Emit fixed x86_64 insn `add_rax_rbx` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [72, 1, 216];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `and_rbx_rax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [33, 216];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `or_rbx_rax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [9, 216];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `xor_rbx_rax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [49, 216];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `mov_rax_to_rbx` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [72, 137, 195];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `mov_rbx_to_rax` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [72, 137, 216];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `mov_rbx_to_ecx` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [137, 217];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `mov_edx_to_eax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [137, 208];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `not_eax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_not_eax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [247, 208];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `neg_eax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_neg_eax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [247, 216];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `test_eax_eax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_test_eax_eax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [133, 192];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `test_rbx_rbx` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [133, 219];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `test_edx_edx` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_test_edx_edx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [133, 210];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `cmp_rbx_rax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [57, 195];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `cmp_rax_rbx` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [57, 216];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `cltd` (1 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cltd(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[1] = [153];
  return x86_enc_bytes(elf_ctx, ins, 1);
}

/** Emit fixed x86_64 insn `idiv_rbx` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_idiv_rbx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [247, 251];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `imul_rbx_rax` (4 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[4] = [72, 15, 175, 195];
  return x86_enc_bytes(elf_ctx, ins, 4);
}

/** Emit fixed x86_64 insn `push_rax` (1 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_push_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[1] = [80];
  return x86_enc_bytes(elf_ctx, ins, 1);
}

/** Emit fixed x86_64 insn `push_rbx` (1 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_push_rbx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[1] = [83];
  return x86_enc_bytes(elf_ctx, ins, 1);
}

/** Emit fixed x86_64 insn `pop_rbx` (1 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_pop_rbx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[1] = [91];
  return x86_enc_bytes(elf_ctx, ins, 1);
}

/** Emit fixed x86_64 insn `pop_rax` (1 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_pop_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[1] = [88];
  return x86_enc_bytes(elf_ctx, ins, 1);
}

/** Emit fixed x86_64 insn `shl_cl_eax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [211, 224];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `shr_cl_eax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [211, 232];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `sar_cl_eax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [211, 248];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `shl_cl_rax` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_shl_cl_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [72, 211, 224];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `shr_cl_rax` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_shr_cl_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [72, 211, 232];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `sar_cl_rax` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sar_cl_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [72, 211, 248];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `xor_edx_edx` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_xor_edx_edx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [49, 210];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `div_rbx` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_div_rbx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [247, 243];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `load_32_from_rax` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [139, 0];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `load_64_from_rax` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [72, 139, 0];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `load_zext8_from_rax` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [15, 182, 0];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `rax_plus_rbx_scale1` (4 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[4] = [72, 141, 4, 24];
  return x86_enc_bytes(elf_ctx, ins, 4);
}

/** Emit fixed x86_64 insn `rax_plus_rbx_scale4` (4 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[4] = [72, 141, 4, 152];
  return x86_enc_bytes(elf_ctx, ins, 4);
}

/** Emit fixed x86_64 insn `rax_plus_rbx_scale8` (4 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[4] = [72, 141, 4, 216];
  return x86_enc_bytes(elf_ctx, ins, 4);
}

/** Emit fixed x86_64 insn `lea_rbx_plus_rcx_scale1` (4 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[4] = [72, 141, 28, 11];
  return x86_enc_bytes(elf_ctx, ins, 4);
}

/** Emit fixed x86_64 insn `lea_rbx_plus_rcx_scale4` (4 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[4] = [72, 141, 28, 139];
  return x86_enc_bytes(elf_ctx, ins, 4);
}

/** Emit fixed x86_64 insn `lea_rbx_plus_rcx_scale8` (4 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[4] = [72, 141, 28, 203];
  return x86_enc_bytes(elf_ctx, ins, 4);
}

/** Emit fixed x86_64 insn `add_ecx_edx` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_add_ecx_edx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [1, 209];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `sub_ecx_edx` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_ecx_edx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [41, 209];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `add_ebx_edx` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_add_ebx_edx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [1, 211];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `sub_ebx_edx` (2 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_ebx_edx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[2] = [41, 211];
  return x86_enc_bytes(elf_ctx, ins, 2);
}

/** Emit fixed x86_64 insn `imul_ecx_edx` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_imul_ecx_edx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [15, 175, 209];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `imul_ebx_edx` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_imul_ebx_edx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [15, 175, 211];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `sub_rax_rbx` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_rax_rbx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [72, 41, 216];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `load_qword_from_rbx_to_rax` (3 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[3] = [72, 139, 3];
  return x86_enc_bytes(elf_ctx, ins, 3);
}

/** Emit fixed x86_64 insn `load_qword_rbx8_to_rdx` (4 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins: u8[4] = [72, 139, 83, 8];
  return x86_enc_bytes(elf_ctx, ins, 4);
}

/** Emit fixed x86_64 insn `sub_rbx_rax_then_mov` (6 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins0: u8[3] = [72, 41, 195];
  if (x86_enc_bytes(elf_ctx, ins0, 3) != 0) { return 0 - 1; }
  let ins1: u8[3] = [72, 137, 216];
  return x86_enc_bytes(elf_ctx, ins1, 3);
}

/** Emit fixed x86_64 insn `rsub_ecx_edx` (4 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_rsub_ecx_edx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins0: u8[2] = [41, 202];
  if (x86_enc_bytes(elf_ctx, ins0, 2) != 0) { return 0 - 1; }
  let ins1: u8[2] = [137, 209];
  return x86_enc_bytes(elf_ctx, ins1, 2);
}

/** Emit fixed x86_64 insn `rsub_ebx_edx` (4 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_rsub_ebx_edx(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins0: u8[2] = [41, 218];
  if (x86_enc_bytes(elf_ctx, ins0, 2) != 0) { return 0 - 1; }
  let ins1: u8[2] = [137, 211];
  return x86_enc_bytes(elf_ctx, ins1, 2);
}

/** Emit fixed x86_64 insn `setz_movzbl_eax` (6 bytes).
 * Cap residual pure R2 wave1: product C ABI bridge for backend_enc_dispatch.
 * PLATFORM: SHARED — x86_64 SysV encode path (Linux/macOS product asm).
 * @param elf_ctx opaque ElfCodegenCtx*
 * @return 0 on success, -1 on null/overflow
 */
#[no_mangle]
export function arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let ins0: u8[3] = [15, 148, 192];
  if (x86_enc_bytes(elf_ctx, ins0, 3) != 0) { return 0 - 1; }
  let ins1: u8[3] = [15, 182, 192];
  return x86_enc_bytes(elf_ctx, ins1, 3);
}

// ---- Cap residual pure R2 wave2: label/imm/jcc/rbp/arg/call (product C ABI) ----
// G.7: same authority as wave1 — this TU + seed FROM_X rest.

/** Define a code label; pad+export sym when is_func!=0 (Mach-O leading underscore).
 * Cap residual pure R2 wave2. PLATFORM: SHARED — ELF/Mach-O product asm encode.
 * @param elf_ctx opaque ElfCodegenCtx*
 * @param name label/symbol bytes (not necessarily NUL-terminated; use name_len)
 * @param name_len byte length of name
 * @param is_func non-zero: pad code to 4 and add exported symbol
 * @return 0 on success, -1 on failure
 */
#[no_mangle]
export function arch_x86_64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (name == 0) { return 0 - 1; }
  if (name_len < 0) { return 0 - 1; }
  unsafe {
    if (is_func != 0) {
      if (pipeline_elf_ctx_pad_code_to_4(elf_ctx) != 0) { return 0 - 1; }
    }
    let code_len: i32 = pipeline_elf_ctx_emit_code_len(elf_ctx);
    if (pipeline_elf_ctx_add_label(elf_ctx, name, name_len, code_len) != 0) { return 0 - 1; }
    if (is_func == 0) { return 0; }
    // Mach-O: export with leading underscore when host requests it.
    if (pipeline_elf_ctx_macho_leading_underscore(elf_ctx) != 0 && name_len > 0 && name_len <= 63 && name[0] != 95) {
      let mn: u8[64] = [0];
      mn[0] = 95;
      let k: i32 = 0;
      while (k < name_len && k < 63) {
        mn[k + 1] = name[k];
        k = k + 1;
      }
      let code_len2: i32 = pipeline_elf_ctx_emit_code_len(elf_ctx);
      return pipeline_elf_ctx_add_sym(elf_ctx, &mn[0], name_len + 1, code_len2);
    }
    let code_len3: i32 = pipeline_elf_ctx_emit_code_len(elf_ctx);
    return pipeline_elf_ctx_add_sym(elf_ctx, name, name_len, code_len3);
  }
  return 0 - 1;
}

/** cmp + setcc + movzbl %al,%eax for condition code cc (0..5).
 * Cap residual pure R2 wave2. PLATFORM: SHARED — x86_64 SysV encode.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let op: u8 = 148;
  if (cc == 1) { op = 149; }
  else if (cc == 2) { op = 156; }
  else if (cc == 3) { op = 158; }
  else if (cc == 4) { op = 159; }
  else if (cc == 5) { op = 157; }
  let s: u8[3] = [15, 0, 192];
  s[1] = op;
  if (x86_enc_bytes(elf_ctx, s, 3) != 0) { return 0 - 1; }
  let m: u8[3] = [15, 182, 192];
  return x86_enc_bytes(elf_ctx, m, 3);
}

/** mov imm32 to ebx (B8+reg form). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 187) != 0) { return 0 - 1; }
  return x86_enc_u32_le(elf_ctx, imm32);
}

/** mov imm32 to eax then return path (ret_imm32 surface). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 184) != 0) { return 0 - 1; }
  return x86_enc_u32_le(elf_ctx, imm32);
}

/** movabs imm64 (lo,hi) to rax. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 72) != 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 184) != 0) { return 0 - 1; }
  if (x86_enc_u32_le(elf_ctx, lo) != 0) { return 0 - 1; }
  return x86_enc_u32_le(elf_ctx, hi);
}

/** cmp eax, imm32. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_cmp_eax_imm32(elf_ctx: *u8, imm32: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 61) != 0) { return 0 - 1; }
  return x86_enc_u32_le(elf_ctx, imm32);
}

/** add imm32 to rax (REX.W add rax,imm32). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (imm == 0) { return 0; }
  if (x86_enc_u8(elf_ctx, 72) != 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 5) != 0) { return 0 - 1; }
  return x86_enc_u32_le(elf_ctx, imm);
}

/** add imm32 to rbx. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (imm == 0) { return 0; }
  if (x86_enc_u8(elf_ctx, 72) != 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 129) != 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 195) != 0) { return 0 - 1; }
  return x86_enc_u32_le(elf_ctx, imm);
}

/** movq %rax, -offset(%rbp). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_store_rax_to_rbp_neg(elf_ctx, offset);
}

/** movq -offset(%rbp), %rax. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_movq_from_rbp_neg(elf_ctx, offset, 69, 133);
}

/** movq -offset(%rbp), %rbx. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_movq_from_rbp_neg(elf_ctx, offset, 93, 157);
}

/** leaq -offset(%rbp), %rax. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_lea_from_rbp_neg(elf_ctx, offset, 69, 133);
}

/** leaq -offset(%rbp), %rbx. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_lea_from_rbp_neg(elf_ctx, offset, 93, 157);
}

/** movq +off_pos(%rbp), %rax (positive frame offset). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx: *u8, off_pos: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let disp: i32 = off_pos;
  if (disp < 0) { disp = 0; }
  if (disp <= 127) {
    let buf: u8[4] = [72, 139, 69, 0];
    buf[3] = disp as u8;
    return x86_enc_bytes(elf_ctx, buf, 4);
  }
  let buf2: u8[7] = [72, 139, 133, 0, 0, 0, 0];
  let w: u32 = disp as u32;
  buf2[3] = (w & 255) as u8;
  buf2[4] = ((w / 256) & 255) as u8;
  buf2[5] = ((w / 65536) & 255) as u8;
  buf2[6] = ((w / 16777216) & 255) as u8;
  return x86_enc_bytes(elf_ctx, buf2, 7);
}

/** movl -offset(%rbp), %eax. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_eax32(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_movl_from_rbp_neg32(elf_ctx, offset, 69, 133);
}

/** movl -offset(%rbp), %ebx. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_ebx32(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_movl_from_rbp_neg32(elf_ctx, offset, 93, 157);
}

/** movl -offset(%rbp), %ecx. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_movl_from_rbp_neg32(elf_ctx, offset, 77, 141);
}

/** movl -offset(%rbp), %edx. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_edx(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_movl_from_rbp_neg32(elf_ctx, offset, 85, 149);
}

/** add imm to ecx (alu_imm32 template). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_add_imm_to_ecx(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_alu_imm32_to_reg(elf_ctx, imm, 129, 193);
}

/** sub imm from ecx. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_imm_from_ecx(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_alu_imm32_to_reg(elf_ctx, imm, 129, 233);
}

/** add imm to ebx (index path). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_add_imm_to_ebx_index(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_alu_imm32_to_reg(elf_ctx, imm, 129, 195);
}

/** sub imm from ebx (index path). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_imm_from_ebx_index(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_alu_imm32_to_reg(elf_ctx, imm, 129, 235);
}

/** imul ecx,ecx,imm (skip if imm<=1). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_imul_imm_to_ecx(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (imm <= 1) { return 0; }
  if (imm >= 0 - 128 && imm <= 127) {
    let buf: u8[3] = [107, 201, 0];
    buf[2] = imm as u8;
    return x86_enc_bytes(elf_ctx, buf, 3);
  }
  let buf2: u8[6] = [105, 201, 0, 0, 0, 0];
  let w: u32 = imm as u32;
  buf2[2] = (w & 255) as u8;
  buf2[3] = ((w / 256) & 255) as u8;
  buf2[4] = ((w / 65536) & 255) as u8;
  buf2[5] = ((w / 16777216) & 255) as u8;
  return x86_enc_bytes(elf_ctx, buf2, 6);
}

/** imul ebx,ebx,imm (skip if imm<=1). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_imul_imm_to_ebx(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (imm <= 1) { return 0; }
  if (imm >= 0 - 128 && imm <= 127) {
    let buf: u8[3] = [107, 219, 0];
    buf[2] = imm as u8;
    return x86_enc_bytes(elf_ctx, buf, 3);
  }
  let buf2: u8[6] = [105, 219, 0, 0, 0, 0];
  let w: u32 = imm as u32;
  buf2[2] = (w & 255) as u8;
  buf2[3] = ((w / 256) & 255) as u8;
  buf2[4] = ((w / 65536) & 255) as u8;
  buf2[5] = ((w / 16777216) & 255) as u8;
  return x86_enc_bytes(elf_ctx, buf2, 6);
}

/** mov SysV arg_reg[k] -> rax (k clamped 0..5). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx: *u8, k: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let idx: i32 = k;
  if (idx < 0) { idx = 0; }
  if (idx > 5) { idx = 5; }
  if (idx == 0) {
    let b0: u8[3] = [72, 137, 248];
    return x86_enc_bytes(elf_ctx, b0, 3);
  }
  if (idx == 1) {
    let b1: u8[3] = [72, 137, 240];
    return x86_enc_bytes(elf_ctx, b1, 3);
  }
  if (idx == 2) {
    let b2: u8[3] = [72, 137, 208];
    return x86_enc_bytes(elf_ctx, b2, 3);
  }
  if (idx == 3) {
    let b3: u8[3] = [72, 137, 200];
    return x86_enc_bytes(elf_ctx, b3, 3);
  }
  if (idx == 4) {
    let b4: u8[3] = [76, 137, 192];
    return x86_enc_bytes(elf_ctx, b4, 3);
  }
  let b5: u8[3] = [76, 137, 200];
  return x86_enc_bytes(elf_ctx, b5, 3);
}

/** mov rax -> SysV arg_reg[k] (k clamped 0..5). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let idx: i32 = k;
  if (idx < 0) { idx = 0; }
  if (idx > 5) { idx = 5; }
  if (idx == 0) {
    let b0: u8[3] = [72, 137, 199];
    return x86_enc_bytes(elf_ctx, b0, 3);
  }
  if (idx == 1) {
    let b1: u8[3] = [72, 137, 198];
    return x86_enc_bytes(elf_ctx, b1, 3);
  }
  if (idx == 2) {
    let b2: u8[3] = [72, 137, 194];
    return x86_enc_bytes(elf_ctx, b2, 3);
  }
  if (idx == 3) {
    let b3: u8[3] = [72, 137, 193];
    return x86_enc_bytes(elf_ctx, b3, 3);
  }
  if (idx == 4) {
    let b4: u8[3] = [73, 137, 192];
    return x86_enc_bytes(elf_ctx, b4, 3);
  }
  let b5: u8[3] = [73, 137, 193];
  return x86_enc_bytes(elf_ctx, b5, 3);
}

/** jz rel32 label (0F 84). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_jcc_rel32(elf_ctx, 132, label, label_len);
}

/** jeq alias of jz. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_jcc_rel32(elf_ctx, 132, label, label_len);
}

/** jge rel32 label (0F 8D). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_jcc_rel32(elf_ctx, 141, label, label_len);
}

/** jnz rel32 label (0F 85). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_jcc_rel32(elf_ctx, 133, label, label_len);
}

/** jmp rel32 + patch. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (label == 0) { return 0 - 1; }
  if (label_len <= 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 233) != 0) { return 0 - 1; }
  if (x86_enc_u32_le(elf_ctx, 0) != 0) { return 0 - 1; }
  unsafe {
    let rel32_at: i32 = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4;
    if (pipeline_elf_ctx_ensure_label(elf_ctx, label, label_len) != 0) { return 0 - 1; }
    return pipeline_elf_ctx_append_patch(elf_ctx, rel32_at, label, label_len, 0);
  }
  return 0 - 1;
}

/** call rel32 + reloc (Mach-O leading underscore when required).
 * Cap residual pure R2 wave2. PLATFORM: SHARED — ELF/Mach-O product asm.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_call(elf_ctx: *u8, name: *u8, name_len: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (name == 0) { return 0 - 1; }
  if (name_len <= 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 232) != 0) { return 0 - 1; }
  if (x86_enc_u32_le(elf_ctx, 0) != 0) { return 0 - 1; }
  unsafe {
    let rel32_at: i32 = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4;
    if (pipeline_elf_ctx_macho_leading_underscore(elf_ctx) != 0 && name_len > 0 && name_len <= 63 && name[0] != 95) {
      let rn: u8[64] = [0];
      rn[0] = 95;
      let k: i32 = 0;
      while (k < name_len && k < 63) {
        rn[k + 1] = name[k];
        k = k + 1;
      }
      return pipeline_elf_ctx_append_reloc(elf_ctx, rel32_at, &rn[0], name_len + 1);
    }
    return pipeline_elf_ctx_append_reloc(elf_ctx, rel32_at, name, name_len);
  }
  return 0 - 1;
}

/** add rsp, nbytes (imm8 or imm32). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_add_rsp_imm(elf_ctx: *u8, nbytes: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (nbytes <= 0) { return 0; }
  if (nbytes <= 127) {
    if (x86_enc_u8(elf_ctx, 72) != 0) { return 0 - 1; }
    if (x86_enc_u8(elf_ctx, 131) != 0) { return 0 - 1; }
    if (x86_enc_u8(elf_ctx, 196) != 0) { return 0 - 1; }
    return x86_enc_u8(elf_ctx, nbytes as u8);
  }
  if (x86_enc_u8(elf_ctx, 72) != 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 129) != 0) { return 0 - 1; }
  if (x86_enc_u8(elf_ctx, 196) != 0) { return 0 - 1; }
  return x86_enc_u32_le(elf_ctx, nbytes);
}

/** store rax through (%rbx) by elem size 1/4/8. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (elem_sz == 1) {
    let b1: u8[2] = [136, 3];
    return x86_enc_bytes(elf_ctx, b1, 2);
  }
  if (elem_sz == 4) {
    let b4: u8[2] = [137, 3];
    return x86_enc_bytes(elf_ctx, b4, 2);
  }
  let b8: u8[3] = [72, 137, 3];
  return x86_enc_bytes(elf_ctx, b8, 3);
}

/** store rax to offset(%rbx) size 1/4/8. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let w: u32 = offset as u32;
  let b0: u8 = (w & 255) as u8;
  let b1: u8 = ((w / 256) & 255) as u8;
  let b2: u8 = ((w / 65536) & 255) as u8;
  let b3: u8 = ((w / 16777216) & 255) as u8;
  if (store_size == 1) {
    let buf: u8[6] = [136, 131, 0, 0, 0, 0];
    buf[2] = b0; buf[3] = b1; buf[4] = b2; buf[5] = b3;
    return x86_enc_bytes(elf_ctx, buf, 6);
  }
  if (store_size == 4) {
    let buf: u8[6] = [137, 131, 0, 0, 0, 0];
    buf[2] = b0; buf[3] = b1; buf[4] = b2; buf[5] = b3;
    return x86_enc_bytes(elf_ctx, buf, 6);
  }
  let buf8: u8[7] = [72, 137, 131, 0, 0, 0, 0];
  buf8[3] = b0; buf8[4] = b1; buf8[5] = b2; buf8[6] = b3;
  return x86_enc_bytes(elf_ctx, buf8, 7);
}

/** movq %rdx, -offset(%rbp) (16B struct high half). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_store_rdx_to_rbp_neg(elf_ctx, offset);
}

/** movq -offset(%rbp), %rdx. Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_rdx(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return x86_enc_movq_from_rbp_neg(elf_ctx, offset, 85, 149);
}

/** movq %rdx, arg_reg[k] (SysV 16B struct second GPR). Cap residual pure R2 wave2. PLATFORM: SHARED */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rdx_to_arg_reg(elf_ctx: *u8, k: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let idx: i32 = k;
  if (idx < 0) { idx = 0; }
  if (idx > 5) { idx = 5; }
  if (idx == 0) {
    let b0: u8[3] = [72, 137, 215];
    return x86_enc_bytes(elf_ctx, b0, 3);
  }
  if (idx == 1) {
    let b1: u8[3] = [72, 137, 214];
    return x86_enc_bytes(elf_ctx, b1, 3);
  }
  if (idx == 2) {
    let b2: u8[3] = [72, 137, 210];
    return x86_enc_bytes(elf_ctx, b2, 3);
  }
  if (idx == 3) {
    let b3: u8[3] = [72, 137, 209];
    return x86_enc_bytes(elf_ctx, b3, 3);
  }
  if (idx == 4) {
    let b4: u8[3] = [73, 137, 208];
    return x86_enc_bytes(elf_ctx, b4, 3);
  }
  let b5: u8[3] = [73, 137, 209];
  return x86_enc_bytes(elf_ctx, b5, 3);
}
