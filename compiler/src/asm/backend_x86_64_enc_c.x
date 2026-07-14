// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-15：backend_x86_64_enc_c 产品源迁 seeds/backend_x86_64_enc_c.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；实现仍在 seed C。
// 产品：cc seeds/backend_x86_64_enc_c.from_x.c → src/asm/backend_x86_64_enc_c.o
// G-02f-101：+ x86_enc_u8 / u32_le / bytes / jcc_rel32 薄门闩。
// G-02f-102：+ movq/lea/movl/store/alu rbp helpers 薄门闩。

export function backend_x86_64_enc_c_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-124/128/129/130：x86 enc pure helpers 真迁 .x

export extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;
export extern "C" function pipeline_elf_ctx_emit_code_len(ctx: *u8): i32;
export extern "C" function pipeline_elf_ctx_ensure_label(ctx: *u8, name: *u8, name_len: i32): i32;
export extern "C" function pipeline_elf_ctx_append_patch(ctx: *u8, rel32_offset: i32, name: *u8, name_len: i32, imm_bits: i32): i32;

#[no_mangle]
export function x86_enc_u8(elf_ctx: *u8, b: u8): i32 {
  let bb: u8 = b;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &bb, 1);
  }
  return 0 - 1;
}

#[no_mangle]
export function x86_enc_bytes(elf_ctx: *u8, buf: *u8, n: i32): i32 {
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, buf, n);
  }
  return 0 - 1;
}

#[no_mangle]
export function x86_enc_u32_le(elf_ctx: *u8, imm: i32): i32 {
  // 小端 4 字节；imm 按两补码位型写入
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

// G-02f-129：0F opcode2 + rel32 zero + patch（imm_bits=0，与 seed 一致）
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

