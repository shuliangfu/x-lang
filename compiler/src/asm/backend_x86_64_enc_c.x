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

