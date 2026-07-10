// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-9：backend_enc_dispatch 产品源迁 seeds/backend_enc_dispatch.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；分派实现仍在 seed C。
// 产品：cc seeds/backend_enc_dispatch.from_x.c → src/asm/backend_enc_dispatch.o
// G-02f-100：+ x86 jcc / append_u32 / arm64 call/add/sub/str 薄门闩。
// G-02f-101：+ arm64 load/store w0 from rbp 薄门闩。

function backend_enc_dispatch_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-100 / G-02f-146：enc helpers ---- */
/* backend_enc_x86_jcc_rel32_c 真迁见文件尾 G-02f-130 */

// G-02f-146 前向：arm64 call 真迁见下方（append_u32 / reloc / macho underscore@598052）







/* ---- G-02f-101：arm64 load/store w0 门闩 ---- */

// G-02f-127：arm64/x86 enc pure helpers 真迁 .x
// G-02f-130：backend_enc_x86_jcc_rel32_c 真迁 .x

extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;
extern "C" function pipeline_elf_ctx_emit_code_len(ctx: *u8): i32;
extern "C" function pipeline_elf_ctx_ensure_label(ctx: *u8, name: *u8, name_len: i32): i32;
extern "C" function pipeline_elf_ctx_append_patch(ctx: *u8, rel32_offset: i32, name: *u8, name_len: i32, imm_bits: i32): i32;
extern "C" function pipeline_elf_ctx_append_reloc(ctx: *u8, at: i32, name: *u8, name_len: i32): i32;
extern "C" function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, word: i32): i32;

// G-02f-130：0F opcode2 + rel32 + patch（imm_bits=32，与 seed 一致）
#[no_mangle]
function backend_enc_x86_jcc_rel32_c(elf_ctx: *u8, opcode2: u8, label: *u8, label_len: i32): i32 {
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

#[no_mangle]
function backend_enc_append_u32_le_c(elf_ctx: *u8, word: u32): i32 {
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
#[no_mangle]
function backend_enc_arm64_call_c(elf_ctx: *u8, name: *u8, name_len: i32): i32 {
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

#[no_mangle]
function backend_enc_arm64_add_sp_imm12_c(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (imm <= 0) { return 0; }
  let imm12: i32 = imm;
  if (imm12 > 4095) { imm12 = 4095; }
  let word: u32 = 2432697343 | ((imm12 as u32) * 1024);
  return backend_enc_append_u32_le_c(elf_ctx, word);
}

#[no_mangle]
function backend_enc_arm64_sub_sp_imm12_c(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (imm <= 0) { return 0; }
  let imm12: i32 = imm;
  if (imm12 > 4095) { imm12 = 4095; }
  let word: u32 = 3506439167 | ((imm12 as u32) * 1024);
  return backend_enc_append_u32_le_c(elf_ctx, word);
}

#[no_mangle]
function backend_enc_arm64_str_x0_sp_offset_c(elf_ctx: *u8, off_bytes: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let off: i32 = off_bytes;
  if (off < 0) { off = 0; }
  let imm12: i32 = off / 8;
  if (imm12 > 4095) { imm12 = 4095; }
  let word: u32 = 4177527776 | ((imm12 as u32) * 1024);
  return backend_enc_append_u32_le_c(elf_ctx, word);
}

#[no_mangle]
function arm64_enc_load_w0_from_rbp_c(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (offset < 0) { return 0 - 1; }
  let simm9: i32 = 0 - offset;
  if (simm9 < 0 - 256) { simm9 = 0 - 256; }
  let u9: i32 = simm9 & 511;
  let word: u32 = 3087007744 | ((u9 as u32) * 4096) | 928;
  unsafe {
    return arch_arm64_enc_enc_u32_le(elf_ctx, word as i32);
  }
  return 0 - 1;
}

#[no_mangle]
function arm64_enc_store_w0_to_rbp_c(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (offset < 0) { return 0 - 1; }
  let simm9: i32 = 0 - offset;
  if (simm9 < 0 - 256) { simm9 = 0 - 256; }
  let u9: i32 = simm9 & 511;
  let word: u32 = 3087007744 | ((u9 as u32) * 4096) | 928;
  unsafe {
    return arch_arm64_enc_enc_u32_le(elf_ctx, word as i32);
  }
  return 0 - 1;
}

