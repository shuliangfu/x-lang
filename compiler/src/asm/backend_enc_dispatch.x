// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-9：backend_enc_dispatch 产品源迁 seeds/backend_enc_dispatch.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；分派实现仍在 seed C。
// 产品：cc seeds/backend_enc_dispatch.from_x.c → src/asm/backend_enc_dispatch.o
// G-02f-100：+ x86 jcc / append_u32 / arm64 call/add/sub/str 薄门闩。
// G-02f-101：+ arm64 load/store w0 from rbp 薄门闩。
// G-02f-206：backend_enc_*_arch 短 ta 分派壳真迁 .x（arm64/riscv/x86）。
// G-02f-207：x86-only / imm / lane / scale / disp encode 壳真迁。
// G-02f-208：x86 f32/xmm 编码壳；enc_dispatch `*_arch` 逻辑源闭合。

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

/* ---- G-02f-206：backend_enc_*_arch ta-dispatch shells ---- */

extern "C" function arch_arm64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_arm64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_arm64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_cltd(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_cmp_w0_imm12(elf_ctx: *u8, imm12: i32): i32;
extern "C" function arch_arm64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
extern "C" function arch_arm64_enc_enc_cset_w0_from_cc(elf_ctx: *u8, cc: i32): i32;
extern "C" function arch_arm64_enc_enc_epilogue(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
extern "C" function arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_arm64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_arm64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_arm64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
extern "C" function arch_arm64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
extern "C" function arch_arm64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_neg_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_not_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_pop_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
extern "C" function arch_arm64_enc_enc_push_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_push_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_arm64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_arm64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
extern "C" function arch_arm64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
extern "C" function arch_arm64_enc_enc_sub_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_riscv64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_call(elf_ctx: *u8, name: *u8, name_len: i32): i32;
extern "C" function arch_riscv64_enc_enc_cltd(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
extern "C" function arch_riscv64_enc_enc_epilogue(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
extern "C" function arch_riscv64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_load_rbp_to_a2(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_riscv64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
extern "C" function arch_riscv64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
extern "C" function arch_riscv64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_neg_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_not_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_pop_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
extern "C" function arch_riscv64_enc_enc_push_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_push_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_riscv64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
extern "C" function arch_riscv64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
extern "C" function arch_riscv64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_x86_64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_call(elf_ctx: *u8, name: *u8, name_len: i32): i32;
extern "C" function arch_x86_64_enc_enc_cltd(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_cmp_eax_imm32(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
extern "C" function arch_x86_64_enc_enc_epilogue(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
extern "C" function arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
extern "C" function arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
extern "C" function arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_neg_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_not_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_pop_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
extern "C" function arch_x86_64_enc_enc_push_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_push_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_x86_64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_sar_cl_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_shl_cl_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_shr_cl_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
extern "C" function arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
extern "C" function arch_x86_64_enc_enc_sub_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_label(elf_ctx, name, name_len, is_func); }
  if (ta == 2) { return arch_riscv64_enc_enc_label(elf_ctx, name, name_len, is_func); }
  return arch_x86_64_enc_enc_label(elf_ctx, name, name_len, is_func);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_prologue_arch(elf_ctx: *u8, frame_sz: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_prologue(elf_ctx, frame_sz); }
  if (ta == 2) { return arch_riscv64_enc_enc_prologue(elf_ctx, frame_sz); }
  return arch_x86_64_enc_enc_prologue(elf_ctx, frame_sz);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_epilogue_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_epilogue(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_epilogue(elf_ctx); }
  return arch_x86_64_enc_enc_epilogue(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_ret_imm32_arch(elf_ctx: *u8, imm32: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_ret_imm32(elf_ctx, imm32); }
  if (ta == 2) { return arch_riscv64_enc_enc_ret_imm32(elf_ctx, imm32); }
  return arch_x86_64_enc_enc_ret_imm32(elf_ctx, imm32);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm32: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32); }
  return arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi); }
  return arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_push_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_push_rax(elf_ctx); }
  return arch_x86_64_enc_enc_push_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_push_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_push_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_push_rbx(elf_ctx); }
  return arch_x86_64_enc_enc_push_rbx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_pop_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_pop_rax(elf_ctx); }
  return arch_x86_64_enc_enc_pop_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_pop_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_pop_rbx(elf_ctx); }
  return arch_x86_64_enc_enc_pop_rbx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_add_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_add_rax_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_rax_rbx(elf_ctx); }
  return arch_x86_64_enc_enc_add_rax_rbx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_sub_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_sub_rax_rbx(elf_ctx); }
  if (ta == 2) { return -1; }
  return arch_x86_64_enc_enc_sub_rax_rbx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_sub_rbx_rax_then_mov(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_sub_rbx_rax_then_mov(elf_ctx); }
  return arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_imul_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_imul_rbx_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_imul_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_mov_rax_to_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_rax_to_rbx(elf_ctx); }
  return arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_not_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_not_eax(elf_ctx); }
  return arch_x86_64_enc_enc_not_eax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_and_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_and_rbx_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_and_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_and_rbx_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_or_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_or_rbx_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_or_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_or_rbx_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_xor_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_xor_rbx_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_xor_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_mov_rbx_to_ecx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_mov_rbx_to_ecx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_rbx_to_ecx(elf_ctx); }
  return arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_shl_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_shl_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_shl_cl_eax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_shr_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_shr_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_shr_cl_eax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_sar_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_sar_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_sar_cl_eax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_shl_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_shl_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_shl_cl_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_shr_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_shr_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_shr_cl_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_sar_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_sar_cl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_sar_cl_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_cltd_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_cltd(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_cltd(elf_ctx); }
  return arch_x86_64_enc_enc_cltd(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_mov_edx_to_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx); }
  return arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_neg_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_neg_eax(elf_ctx); }
  return arch_x86_64_enc_enc_neg_eax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_test_eax_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_test_eax_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_test_eax_eax(elf_ctx); }
  return arch_x86_64_enc_enc_test_eax_eax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_test_rbx_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_test_rbx_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_test_rbx_rbx(elf_ctx); }
  return arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_setz_movzbl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_setz_movzbl_eax(elf_ctx); }
  return arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_cmp_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_cmp_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_cmp_rax_rbx(elf_ctx); }
  if (ta == 2) { return -1; }
  return arch_x86_64_enc_enc_cmp_rax_rbx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc); }
  if (ta == 2) { return arch_riscv64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc); }
  return arch_x86_64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc);
}

#[no_mangle]
function backend_enc_cmp_w0_imm12_arch(elf_ctx: *u8, imm12: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_cmp_w0_imm12(elf_ctx, imm12); }
  if (ta == 2) { return arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx); }
  return arch_x86_64_enc_enc_cmp_eax_imm32(elf_ctx, imm12);
}

#[no_mangle]
function backend_enc_cset_w0_from_cc_arch(elf_ctx: *u8, cc: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_cset_w0_from_cc(elf_ctx, cc); }
  return backend_enc_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx, offset); }
  if (ta == 2) { return arch_riscv64_enc_enc_store_rax_to_rbp(elf_ctx, offset); }
  return arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx, offset); }
  if (ta == 2) { return arch_riscv64_enc_enc_load_rbp_to_rax(elf_ctx, offset); }
  return arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx, offset);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx, offset); }
  if (ta == 2) { return arch_riscv64_enc_enc_lea_rbp_to_rax(elf_ctx, offset); }
  return arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_lea_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset); }
  if (ta == 2) { return arch_riscv64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset); }
  return arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_rax_plus_rbx_scale4_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_rax_plus_rbx_scale4(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_rax_plus_rbx_scale4(elf_ctx); }
  return arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_rax_plus_rbx_scale1_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_rax_plus_rbx_scale1(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_rax_plus_rbx_scale1(elf_ctx); }
  return arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_rax_plus_rbx_scale8_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_rax_plus_rbx_scale8(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_rax_plus_rbx_scale8(elf_ctx); }
  return arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx: *u8, elem_sz: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz); }
  if (ta == 2) { return arch_riscv64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz); }
  return arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_load_zext8_from_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_load_zext8_from_rax(elf_ctx); }
  return arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_add_imm_to_rax(elf_ctx, imm); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_imm_to_rax(elf_ctx, imm); }
  return arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx, imm);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_add_imm_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_add_imm_to_rbx(elf_ctx, imm); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx, imm); }
  return arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_load_rbp_index_scratch_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx, offset); }
  if (ta == 2) { return arch_riscv64_enc_enc_load_rbp_to_a2(elf_ctx, offset); }
  return arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx, offset);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_load_64_from_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_load_64_from_rax(elf_ctx); }
  return arch_x86_64_enc_enc_load_64_from_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, offset: i32, store_size: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size); }
  if (ta == 2) { return arch_riscv64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size); }
  return arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_mov_rbx_to_rax(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_rbx_to_rax(elf_ctx); }
  return arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_jz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_jz(elf_ctx, label, label_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_jz(elf_ctx, label, label_len); }
  return arch_x86_64_enc_enc_jz(elf_ctx, label, label_len);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_jeq_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_jeq(elf_ctx, label, label_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_jeq(elf_ctx, label, label_len); }
  return arch_x86_64_enc_enc_jeq(elf_ctx, label, label_len);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_jge_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_jge(elf_ctx, label, label_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_jge(elf_ctx, label, label_len); }
  return arch_x86_64_enc_enc_jge(elf_ctx, label, label_len);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_jnz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_jnz(elf_ctx, label, label_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_jnz(elf_ctx, label, label_len); }
  return arch_x86_64_enc_enc_jnz(elf_ctx, label, label_len);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_jmp(elf_ctx, label, label_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_jmp(elf_ctx, label, label_len); }
  return arch_x86_64_enc_enc_jmp(elf_ctx, label, label_len);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k); }
  if (ta == 2) { return arch_riscv64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k); }
  return arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_call_arch(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if (ta == 1) { return backend_enc_arm64_call_c(elf_ctx, name, name_len); }
  if (ta == 2) { return arch_riscv64_enc_enc_call(elf_ctx, name, name_len); }
  return arch_x86_64_enc_enc_call(elf_ctx, name, name_len);
}

/* ---- G-02f-206b：残短 ta 壳 + idiv/rem ---- */
extern "C" function arch_arm64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_jne(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx: *u8, reg: i32, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_add_a2_a3(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_add_rbx_a3(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_add_sp_imm12(elf_ctx: *u8, nbytes: i32): i32;
extern "C" function arch_riscv64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_mul_a2_a3(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_mul_rbx_a3(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_rsub_a2_a3(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_rsub_rbx_a3(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_sub_a2_a3(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_sub_rbx_a3(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_add_ebx_edx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_add_ecx_edx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_add_rsp_imm(elf_ctx: *u8, nbytes: i32): i32;
extern "C" function arch_x86_64_enc_enc_div_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_imul_ebx_edx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_imul_ecx_edx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_rsub_ebx_edx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_rsub_ecx_edx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_sub_ebx_edx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_sub_ecx_edx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_xor_edx_edx(elf_ctx: *u8): i32;

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_store_x_reg_to_rbp_arch(elf_ctx: *u8, reg: i32, offset: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, reg, offset); }
  return 0 - 1;
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_jne_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_jne(elf_ctx, label, label_len); }
  return backend_enc_jnz_arch(elf_ctx, label, label_len, ta);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_call_stack_cleanup_arch(elf_ctx: *u8, nbytes: i32, ta: i32): i32 {
  if (nbytes <= 0) { return 0; }
  if (ta == 1) { return backend_enc_arm64_add_sp_imm12_c(elf_ctx, nbytes); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_sp_imm12(elf_ctx, nbytes); }
  return arch_x86_64_enc_enc_add_rsp_imm(elf_ctx, nbytes);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_call_stack_reserve_arch(elf_ctx: *u8, nbytes: i32, ta: i32): i32 {
  if (nbytes <= 0) { return 0; }
  if (ta == 1) { return backend_enc_arm64_sub_sp_imm12_c(elf_ctx, nbytes); }
  return 0;
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_store_x0_sp_offset_arch(elf_ctx: *u8, off_bytes: i32, ta: i32): i32 {
  if (ta == 1) { return backend_enc_arm64_str_x0_sp_offset_c(elf_ctx, off_bytes); }
  return 0 - 1;
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_index_scratch_add_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 184746050); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_a2_a3(elf_ctx); }
  return arch_x86_64_enc_enc_add_ecx_edx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_index_scratch_sub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258487874); }
  if (ta == 2) { return arch_riscv64_enc_enc_sub_a2_a3(elf_ctx); }
  return arch_x86_64_enc_enc_sub_ecx_edx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_index_scratch_rsub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258422370); }
  if (ta == 2) { return arch_riscv64_enc_enc_rsub_a2_a3(elf_ctx); }
  return arch_x86_64_enc_enc_rsub_ecx_edx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_rbx_index_rsub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258356833); }
  if (ta == 2) { return arch_riscv64_enc_enc_rsub_rbx_a3(elf_ctx); }
  return arch_x86_64_enc_enc_rsub_ebx_edx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_rbx_index_add_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 184746017); }
  if (ta == 2) { return arch_riscv64_enc_enc_add_rbx_a3(elf_ctx); }
  return arch_x86_64_enc_enc_add_ebx_edx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_rbx_index_sub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258487841); }
  if (ta == 2) { return arch_riscv64_enc_enc_sub_rbx_a3(elf_ctx); }
  return arch_x86_64_enc_enc_sub_ebx_edx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_index_scratch_mul_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 453213250); }
  if (ta == 2) { return arch_riscv64_enc_enc_mul_a2_a3(elf_ctx); }
  return arch_x86_64_enc_enc_imul_ecx_edx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_rbx_index_mul_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, 453213217); }
  if (ta == 2) { return arch_riscv64_enc_enc_mul_rbx_a3(elf_ctx); }
  return arch_x86_64_enc_enc_imul_ebx_edx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_idiv_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_idiv_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_idiv_rbx(elf_ctx); }
  if (arch_x86_64_enc_enc_cltd(elf_ctx) != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_idiv_rbx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_div_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_enc_enc_idiv_rbx(elf_ctx); }
  if (ta == 2) { return arch_riscv64_enc_enc_idiv_rbx(elf_ctx); }
  if (arch_x86_64_enc_enc_xor_edx_edx(elf_ctx) != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_div_rbx(elf_ctx);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_rem_mod_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta); }
  if (backend_enc_cltd_arch(elf_ctx, ta) != 0) { return 0 - 1; }
  if (backend_enc_idiv_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
  return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
}

// G-02f-206：ta 分派壳真迁 .x
#[no_mangle]
function backend_enc_rem_mod_unsigned_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) { return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta); }
  if (backend_enc_div_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
  return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
}

/* ---- G-02f-207：enc 残短 x86-only / imm / lane / scale ---- */

extern "C" function arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_load_rbp_to_rdx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_mov_rdx_to_arg_reg(elf_ctx: *u8, k: i32): i32;
extern "C" function arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx: *u8, k: i32): i32;
extern "C" function arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx: *u8, off_pos: i32): i32;
extern "C" function arch_arm64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_load_rbp_to_eax32(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_load_rbp_to_ebx32(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_arm64_enc_enc_load_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_load_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_arm64_enc_enc_rbx_plus_x2_scale1(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_rbx_plus_x2_scale4(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_rbx_plus_x2_scale8(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_rbx_plus_a2_scale1(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_rbx_plus_a2_scale4(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_rbx_plus_a2_scale8(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_add_imm_to_a2(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_x86_64_enc_enc_add_imm_to_ecx(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_riscv64_enc_enc_sub_imm_from_a2(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_x86_64_enc_enc_sub_imm_from_ecx(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_x86_64_enc_enc_add_imm_to_ebx_index(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_riscv64_enc_enc_sub_imm_from_rbx_index(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_x86_64_enc_enc_sub_imm_from_ebx_index(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_riscv64_enc_enc_load_rbp_to_a3(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_load_rbp_to_edx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_mul_imm_to_a2(elf_ctx: *u8, lit: i32): i32;
extern "C" function arch_x86_64_enc_enc_imul_imm_to_ecx(elf_ctx: *u8, lit: i32): i32;
extern "C" function arch_riscv64_enc_enc_mul_imm_to_rbx(elf_ctx: *u8, lit: i32): i32;
extern "C" function arch_x86_64_enc_enc_imul_imm_to_ebx(elf_ctx: *u8, lit: i32): i32;

// G-02f-207：x86-only
#[no_mangle]
function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx, offset);
}

#[no_mangle]
function backend_enc_load_qword_from_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx);
}

#[no_mangle]
function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx);
}

#[no_mangle]
function backend_enc_load_rbp_to_rdx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_load_rbp_to_rdx(elf_ctx, offset);
}

#[no_mangle]
function backend_enc_mov_rdx_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  return arch_x86_64_enc_enc_mov_rdx_to_arg_reg(elf_ctx, k);
}

#[no_mangle]
function backend_enc_mov_arg_reg_to_rax_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta == 0) { return arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx, k); }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_load_rbp_pos_to_rax_arch(elf_ctx: *u8, off_pos: i32, ta: i32): i32 {
  if (ta == 0) { return arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx, off_pos); }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_jle_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  return backend_enc_x86_jcc_rel32_c(elf_ctx, 142, label, label_len);
}

#[no_mangle]
function backend_enc_jl_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta != 0) { return 0 - 1; }
  return backend_enc_x86_jcc_rel32_c(elf_ctx, 140, label, label_len);
}

// G-02f-207：load 32 from [rax]
#[no_mangle]
function backend_enc_load_32_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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

#[no_mangle]
function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
}

// G-02f-207：load rbp → rbx（含 x86 disp8/disp32）
#[no_mangle]
function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
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

// G-02f-207：store eax → rbp
#[no_mangle]
function backend_enc_store_eax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
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
#[no_mangle]
function backend_enc_load_rbp_lane_to_rax_arch(elf_ctx: *u8, offset: i32, esz: i32, ta: i32): i32 {
  if (ta == 0) {
    if (esz == 4) { return arch_x86_64_enc_enc_load_rbp_to_eax32(elf_ctx, offset); }
  }
  if (ta == 1) {
    if (esz == 4) { return arm64_enc_load_w0_from_rbp_c(elf_ctx, offset); }
  }
  return backend_enc_load_rbp_to_rax_arch(elf_ctx, offset, ta);
}

#[no_mangle]
function backend_enc_load_rbp_lane_to_rbx_arch(elf_ctx: *u8, offset: i32, esz: i32, ta: i32): i32 {
  if (ta == 0) {
    if (esz == 4) { return arch_x86_64_enc_enc_load_rbp_to_ebx32(elf_ctx, offset); }
  }
  return backend_enc_load_rbp_to_rbx_arch(elf_ctx, offset, ta);
}

// G-02f-207：arm64 ldr x0,[x29,#pos]
#[no_mangle]
function backend_enc_load_x29_pos_to_rax_arch(elf_ctx: *u8, off_pos: i32, ta: i32): i32 {
  if (ta == 1) {
    let off: i32 = off_pos;
    if (off < 0) { off = 0; }
    let imm12: i32 = off / 8;
    if (imm12 > 4095) { imm12 = 4095; }
    let base: u32 = 4181722016;
    let ins: u32 = base | ((imm12 as u32) * 1024);
    return arch_arm64_enc_enc_u32_le(elf_ctx, ins as i32);
  }
  return 0 - 1;
}

// G-02f-207：rbx + index_scratch * esz
#[no_mangle]
function backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx: *u8, esz: i32, ta: i32): i32 {
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

// G-02f-207：add imm → index_scratch
#[no_mangle]
function backend_enc_add_imm_to_index_scratch_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) {
    if (imm == 0) { return 0; }
    let imm12: i32 = imm;
    if (imm12 > 4095) { imm12 = 4095; }
    let ins: u32 = 285213762 + (((imm12 - 1) as u32) * 1024);
    return arch_arm64_enc_enc_u32_le(elf_ctx, ins as i32);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_add_imm_to_a2(elf_ctx, imm); }
  return arch_x86_64_enc_enc_add_imm_to_ecx(elf_ctx, imm);
}

#[no_mangle]
function backend_enc_sub_imm_from_index_scratch_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) {
    if (imm == 0) { return 0; }
    let imm12: i32 = imm;
    if (imm12 > 4095) { imm12 = 4095; }
    let ins: u32 = 1358955586 + (((imm12 - 1) as u32) * 1024);
    return arch_arm64_enc_enc_u32_le(elf_ctx, ins as i32);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_sub_imm_from_a2(elf_ctx, imm); }
  return arch_x86_64_enc_enc_sub_imm_from_ecx(elf_ctx, imm);
}

#[no_mangle]
function backend_enc_add_imm_to_rbx_index_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  if (imm == 0) { return 0; }
  if (ta == 1) {
    let imm12: i32 = imm;
    if (imm12 > 4095) { imm12 = 4095; }
    let ins: u32 = 285213729 + (((imm12 - 1) as u32) * 1024);
    return arch_arm64_enc_enc_u32_le(elf_ctx, ins as i32);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx, imm); }
  return arch_x86_64_enc_enc_add_imm_to_ebx_index(elf_ctx, imm);
}

#[no_mangle]
function backend_enc_sub_imm_from_rbx_index_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  if (imm == 0) { return 0; }
  if (ta == 1) {
    let imm12: i32 = imm;
    if (imm12 > 4095) { imm12 = 4095; }
    let ins: u32 = 1358955553 + (((imm12 - 1) as u32) * 1024);
    return arch_arm64_enc_enc_u32_le(elf_ctx, ins as i32);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_sub_imm_from_rbx_index(elf_ctx, imm); }
  return arch_x86_64_enc_enc_sub_imm_from_ebx_index(elf_ctx, imm);
}

#[no_mangle]
function backend_enc_load_rbp_index_secondary_scratch_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    let simm9: i32 = 0 - offset;
    if (simm9 < 0 - 256) { simm9 = 0 - 256; }
    let u9: u32 = (simm9 & 511) as u32;
    let ins: u32 = 3090513920 | (u9 * 4096) | (29 * 32) | 3;
    return arch_arm64_enc_enc_u32_le(elf_ctx, ins as i32);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_load_rbp_to_a3(elf_ctx, offset); }
  return arch_x86_64_enc_enc_load_rbp_to_edx(elf_ctx, offset);
}

#[no_mangle]
function backend_enc_mul_imm_to_index_scratch_arch(elf_ctx: *u8, lit: i32, ta: i32): i32 {
  if (lit <= 1) { return 0; }
  if (lit > 65535) { return 0 - 1; }
  if (ta == 1) {
    let ins: u32 = 1384120320 | ((lit as u32) * 32) | 3;
    if (arch_arm64_enc_enc_u32_le(elf_ctx, ins as i32) != 0) { return 0 - 1; }
    return arch_arm64_enc_enc_u32_le(elf_ctx, 453213250);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_mul_imm_to_a2(elf_ctx, lit); }
  return arch_x86_64_enc_enc_imul_imm_to_ecx(elf_ctx, lit);
}

#[no_mangle]
function backend_enc_mul_imm_to_rbx_arch(elf_ctx: *u8, lit: i32, ta: i32): i32 {
  if (lit <= 1) { return 0; }
  if (lit > 65535) { return 0 - 1; }
  if (ta == 1) {
    let ins: u32 = 1384120320 | ((lit as u32) * 32) | 3;
    if (arch_arm64_enc_enc_u32_le(elf_ctx, ins as i32) != 0) { return 0 - 1; }
    return arch_arm64_enc_enc_u32_le(elf_ctx, 453213217);
  }
  if (ta == 2) { return arch_riscv64_enc_enc_mul_imm_to_rbx(elf_ctx, lit); }
  return arch_x86_64_enc_enc_imul_imm_to_ebx(elf_ctx, lit);
}

/* ---- G-02f-208：x86 f32/xmm 编码壳 ---- */

// G-02f-208：addss via xmm0/xmm1
#[no_mangle]
function backend_enc_addss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
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

#[no_mangle]
function backend_enc_cvttss2si_eax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32 {
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

#[no_mangle]
function backend_enc_cvtsd2ss_eax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32 {
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

#[no_mangle]
function backend_enc_cvtsi2ss_eax_from_i32_arch(elf_ctx: *u8, ta: i32): i32 {
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

#[no_mangle]
function backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
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

#[no_mangle]
function backend_enc_mov_xmm_arg_reg_to_eax_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
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
