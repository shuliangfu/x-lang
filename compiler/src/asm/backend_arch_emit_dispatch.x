// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-9：backend_arch_emit_dispatch 产品源迁 seeds/backend_arch_emit_dispatch.from_x.c。
// G-02f-209：backend_arch_emit_* 短 ta 分派壳真迁 .x（arm64/riscv/x86 text emit）。
// 产品：cc seeds/backend_arch_emit_dispatch.from_x.c → src/asm/backend_arch_emit_dispatch.o

function backend_arch_emit_dispatch_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-209：arch_emit ta-dispatch shells ---- */

extern "C" function arch_arm64_emit_add_imm_to_rax(out: *u8, imm: i32): i32;
extern "C" function arch_arm64_emit_add_rax_rbx(out: *u8): i32;
extern "C" function arch_arm64_emit_add_sp_imm(out: *u8, n: i32): i32;
extern "C" function arch_arm64_emit_and_rbx_rax(out: *u8): i32;
extern "C" function arch_arm64_emit_call(out: *u8, name: *u8, name_len: i32): i32;
extern "C" function arch_arm64_emit_cmp_rbx_rax(out: *u8): i32;
extern "C" function arch_arm64_emit_cmp_setcc(out: *u8, cc: i32): i32;
extern "C" function arch_arm64_emit_epilogue(out: *u8, frame_sz: i32): i32;
extern "C" function arch_arm64_emit_globl(out: *u8, name: *u8, name_len: i32): i32;
extern "C" function arch_arm64_emit_imul_rbx_rax(out: *u8): i32;
extern "C" function arch_arm64_emit_jeq(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_emit_jmp(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_emit_jnz(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_emit_jz(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_emit_label(out: *u8, name: *u8, name_len: i32): i32;
extern "C" function arch_arm64_emit_ldr_sp_offset_to_wi(out: *u8, i: i32): i32;
extern "C" function arch_arm64_emit_lea_rbp_to_rax(out: *u8, off: i32): i32;
extern "C" function arch_arm64_emit_load_32_from_rax(out: *u8): i32;
extern "C" function arch_arm64_emit_load_64_from_rax(out: *u8): i32;
extern "C" function arch_arm64_emit_load_rbp_to_rax(out: *u8, off: i32): i32;
extern "C" function arch_arm64_emit_load_zext8_from_rax(out: *u8): i32;
extern "C" function arch_arm64_emit_mov_imm32_to_rbx(out: *u8, imm: i32): i32;
extern "C" function arch_arm64_emit_mov_imm64_to_rax(out: *u8, lo: i32, hi: i32): i32;
extern "C" function arch_arm64_emit_mov_rax_to_rbx(out: *u8): i32;
extern "C" function arch_arm64_emit_mov_rbx_to_rax(out: *u8): i32;
extern "C" function arch_arm64_emit_neg_eax(out: *u8): i32;
extern "C" function arch_arm64_emit_not_eax(out: *u8): i32;
extern "C" function arch_arm64_emit_or_rbx_rax(out: *u8): i32;
extern "C" function arch_arm64_emit_pop_rax(out: *u8): i32;
extern "C" function arch_arm64_emit_pop_rbx(out: *u8): i32;
extern "C" function arch_arm64_emit_prologue(out: *u8, frame_sz: i32): i32;
extern "C" function arch_arm64_emit_push_rax(out: *u8): i32;
extern "C" function arch_arm64_emit_rax_plus_rbx_scale1(out: *u8): i32;
extern "C" function arch_arm64_emit_rax_plus_rbx_scale4(out: *u8): i32;
extern "C" function arch_arm64_emit_rax_plus_rbx_scale8(out: *u8): i32;
extern "C" function arch_arm64_emit_ret_imm32(out: *u8, imm: i32): i32;
extern "C" function arch_arm64_emit_sar_cl_eax(out: *u8): i32;
extern "C" function arch_arm64_emit_section_text(out: *u8): i32;
extern "C" function arch_arm64_emit_shl_cl_eax(out: *u8): i32;
extern "C" function arch_arm64_emit_shr_cl_eax(out: *u8): i32;
extern "C" function arch_arm64_emit_store_rax_to_rbp(out: *u8, off: i32): i32;
extern "C" function arch_arm64_emit_store_rax_to_rbx_indirect(out: *u8, elem_sz: i32): i32;
extern "C" function arch_arm64_emit_store_rax_to_rbx_offset(out: *u8, offset: i32, store_size: i32): i32;
extern "C" function arch_arm64_emit_sub_rbx_rax_then_mov(out: *u8): i32;
extern "C" function arch_arm64_emit_xor_rbx_rax(out: *u8): i32;
extern "C" function arch_riscv64_emit_add_imm_to_rax(out: *u8, imm: i32): i32;
extern "C" function arch_riscv64_emit_add_rax_rbx(out: *u8): i32;
extern "C" function arch_riscv64_emit_and_rbx_rax(out: *u8): i32;
extern "C" function arch_riscv64_emit_call(out: *u8, name: *u8, name_len: i32): i32;
extern "C" function arch_riscv64_emit_cmp_rbx_rax(out: *u8): i32;
extern "C" function arch_riscv64_emit_cmp_setcc(out: *u8, cc: i32): i32;
extern "C" function arch_riscv64_emit_epilogue(out: *u8, frame_sz: i32): i32;
extern "C" function arch_riscv64_emit_globl(out: *u8, name: *u8, name_len: i32): i32;
extern "C" function arch_riscv64_emit_imul_rbx_rax(out: *u8): i32;
extern "C" function arch_riscv64_emit_jeq(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_emit_jmp(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_emit_jnz(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_emit_jz(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_emit_label(out: *u8, name: *u8, name_len: i32): i32;
extern "C" function arch_riscv64_emit_lea_rbp_to_rax(out: *u8, off: i32): i32;
extern "C" function arch_riscv64_emit_load_32_from_rax(out: *u8): i32;
extern "C" function arch_riscv64_emit_load_64_from_rax(out: *u8): i32;
extern "C" function arch_riscv64_emit_load_rbp_to_rax(out: *u8, off: i32): i32;
extern "C" function arch_riscv64_emit_load_zext8_from_rax(out: *u8): i32;
extern "C" function arch_riscv64_emit_mov_imm32_to_rbx(out: *u8, imm: i32): i32;
extern "C" function arch_riscv64_emit_mov_imm64_to_rax(out: *u8, lo: i32, hi: i32): i32;
extern "C" function arch_riscv64_emit_mov_rax_to_arg_reg(out: *u8, k: i32): i32;
extern "C" function arch_riscv64_emit_mov_rax_to_rbx(out: *u8): i32;
extern "C" function arch_riscv64_emit_mov_rbx_to_ecx(out: *u8): i32;
extern "C" function arch_riscv64_emit_mov_rbx_to_rax(out: *u8): i32;
extern "C" function arch_riscv64_emit_neg_eax(out: *u8): i32;
extern "C" function arch_riscv64_emit_not_eax(out: *u8): i32;
extern "C" function arch_riscv64_emit_or_rbx_rax(out: *u8): i32;
extern "C" function arch_riscv64_emit_pop_rax(out: *u8): i32;
extern "C" function arch_riscv64_emit_pop_rbx(out: *u8): i32;
extern "C" function arch_riscv64_emit_prologue(out: *u8, frame_sz: i32): i32;
extern "C" function arch_riscv64_emit_push_rax(out: *u8): i32;
extern "C" function arch_riscv64_emit_rax_plus_rbx_scale1(out: *u8): i32;
extern "C" function arch_riscv64_emit_rax_plus_rbx_scale4(out: *u8): i32;
extern "C" function arch_riscv64_emit_rax_plus_rbx_scale8(out: *u8): i32;
extern "C" function arch_riscv64_emit_ret_imm32(out: *u8, imm: i32): i32;
extern "C" function arch_riscv64_emit_sar_cl_eax(out: *u8): i32;
extern "C" function arch_riscv64_emit_section_text(out: *u8): i32;
extern "C" function arch_riscv64_emit_shl_cl_eax(out: *u8): i32;
extern "C" function arch_riscv64_emit_shr_cl_eax(out: *u8): i32;
extern "C" function arch_riscv64_emit_store_rax_to_rbp(out: *u8, off: i32): i32;
extern "C" function arch_riscv64_emit_store_rax_to_rbx_indirect(out: *u8, elem_sz: i32): i32;
extern "C" function arch_riscv64_emit_store_rax_to_rbx_offset(out: *u8, offset: i32, store_size: i32): i32;
extern "C" function arch_riscv64_emit_sub_rbx_rax_then_mov(out: *u8): i32;
extern "C" function arch_riscv64_emit_xor_rbx_rax(out: *u8): i32;
extern "C" function arch_x86_64_emit_add_imm_to_rax(out: *u8, imm: i32): i32;
extern "C" function arch_x86_64_emit_add_rax_rbx(out: *u8): i32;
extern "C" function arch_x86_64_emit_and_rbx_rax(out: *u8): i32;
extern "C" function arch_x86_64_emit_call(out: *u8, name: *u8, name_len: i32): i32;
extern "C" function arch_x86_64_emit_cmp_rbx_rax(out: *u8): i32;
extern "C" function arch_x86_64_emit_cmp_setcc(out: *u8, cc: i32): i32;
extern "C" function arch_x86_64_emit_epilogue(out: *u8, frame_sz: i32): i32;
extern "C" function arch_x86_64_emit_globl(out: *u8, name: *u8, name_len: i32): i32;
extern "C" function arch_x86_64_emit_imul_rbx_rax(out: *u8): i32;
extern "C" function arch_x86_64_emit_jeq(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_emit_jmp(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_emit_jnz(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_emit_jz(out: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_emit_label(out: *u8, name: *u8, name_len: i32): i32;
extern "C" function arch_x86_64_emit_lea_rbp_to_rax(out: *u8, off: i32): i32;
extern "C" function arch_x86_64_emit_load_32_from_rax(out: *u8): i32;
extern "C" function arch_x86_64_emit_load_64_from_rax(out: *u8): i32;
extern "C" function arch_x86_64_emit_load_rbp_to_rax(out: *u8, off: i32): i32;
extern "C" function arch_x86_64_emit_load_zext8_from_rax(out: *u8): i32;
extern "C" function arch_x86_64_emit_mov_imm32_to_rbx(out: *u8, imm: i32): i32;
extern "C" function arch_x86_64_emit_mov_imm64_to_rax(out: *u8, lo: i32, hi: i32): i32;
extern "C" function arch_x86_64_emit_mov_rax_to_arg_reg(out: *u8, k: i32): i32;
extern "C" function arch_x86_64_emit_mov_rax_to_rbx(out: *u8): i32;
extern "C" function arch_x86_64_emit_mov_rbx_to_ecx(out: *u8): i32;
extern "C" function arch_x86_64_emit_mov_rbx_to_rax(out: *u8): i32;
extern "C" function arch_x86_64_emit_neg_eax(out: *u8): i32;
extern "C" function arch_x86_64_emit_not_eax(out: *u8): i32;
extern "C" function arch_x86_64_emit_or_rbx_rax(out: *u8): i32;
extern "C" function arch_x86_64_emit_pop_rax(out: *u8): i32;
extern "C" function arch_x86_64_emit_pop_rbx(out: *u8): i32;
extern "C" function arch_x86_64_emit_prologue(out: *u8, frame_sz: i32): i32;
extern "C" function arch_x86_64_emit_push_rax(out: *u8): i32;
extern "C" function arch_x86_64_emit_rax_plus_rbx_scale1(out: *u8): i32;
extern "C" function arch_x86_64_emit_rax_plus_rbx_scale4(out: *u8): i32;
extern "C" function arch_x86_64_emit_rax_plus_rbx_scale8(out: *u8): i32;
extern "C" function arch_x86_64_emit_ret_imm32(out: *u8, imm: i32): i32;
extern "C" function arch_x86_64_emit_sar_cl_eax(out: *u8): i32;
extern "C" function arch_x86_64_emit_section_text(out: *u8): i32;
extern "C" function arch_x86_64_emit_shl_cl_eax(out: *u8): i32;
extern "C" function arch_x86_64_emit_shr_cl_eax(out: *u8): i32;
extern "C" function arch_x86_64_emit_store_rax_to_rbp(out: *u8, off: i32): i32;
extern "C" function arch_x86_64_emit_store_rax_to_rbx_indirect(out: *u8, elem_sz: i32): i32;
extern "C" function arch_x86_64_emit_store_rax_to_rbx_offset(out: *u8, offset: i32, store_size: i32): i32;
extern "C" function arch_x86_64_emit_sub_rbx_rax_then_mov(out: *u8): i32;
extern "C" function arch_x86_64_emit_xor_rbx_rax(out: *u8): i32;

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_ret_imm32(out: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_ret_imm32(out, imm); }
  if (ta == 2) { return arch_riscv64_emit_ret_imm32(out, imm); }
  return arch_x86_64_emit_ret_imm32(out, imm);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_mov_imm64_to_rax(out: *u8, lo: i32, hi: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_mov_imm64_to_rax(out, lo, hi); }
  if (ta == 2) { return arch_riscv64_emit_mov_imm64_to_rax(out, lo, hi); }
  return arch_x86_64_emit_mov_imm64_to_rax(out, lo, hi);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_mov_imm32_to_rbx(out: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_mov_imm32_to_rbx(out, imm); }
  if (ta == 2) { return arch_riscv64_emit_mov_imm32_to_rbx(out, imm); }
  return arch_x86_64_emit_mov_imm32_to_rbx(out, imm);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_neg_eax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_neg_eax(out); }
  if (ta == 2) { return arch_riscv64_emit_neg_eax(out); }
  return arch_x86_64_emit_neg_eax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_cmp_rbx_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_cmp_rbx_rax(out); }
  if (ta == 2) { return arch_riscv64_emit_cmp_rbx_rax(out); }
  return arch_x86_64_emit_cmp_rbx_rax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_cmp_setcc(out: *u8, cc: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_cmp_setcc(out, cc); }
  if (ta == 2) { return arch_riscv64_emit_cmp_setcc(out, cc); }
  return arch_x86_64_emit_cmp_setcc(out, cc);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_push_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_push_rax(out); }
  if (ta == 2) { return arch_riscv64_emit_push_rax(out); }
  return arch_x86_64_emit_push_rax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_pop_rbx(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_pop_rbx(out); }
  if (ta == 2) { return arch_riscv64_emit_pop_rbx(out); }
  return arch_x86_64_emit_pop_rbx(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_pop_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_pop_rax(out); }
  if (ta == 2) { return arch_riscv64_emit_pop_rax(out); }
  return arch_x86_64_emit_pop_rax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_add_rax_rbx(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_add_rax_rbx(out); }
  if (ta == 2) { return arch_riscv64_emit_add_rax_rbx(out); }
  return arch_x86_64_emit_add_rax_rbx(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_sub_rbx_rax_then_mov(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_sub_rbx_rax_then_mov(out); }
  if (ta == 2) { return arch_riscv64_emit_sub_rbx_rax_then_mov(out); }
  return arch_x86_64_emit_sub_rbx_rax_then_mov(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_imul_rbx_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_imul_rbx_rax(out); }
  if (ta == 2) { return arch_riscv64_emit_imul_rbx_rax(out); }
  return arch_x86_64_emit_imul_rbx_rax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_mov_rax_to_rbx(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_mov_rax_to_rbx(out); }
  if (ta == 2) { return arch_riscv64_emit_mov_rax_to_rbx(out); }
  return arch_x86_64_emit_mov_rax_to_rbx(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_load_rbp_to_rax(out: *u8, off: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_load_rbp_to_rax(out, off); }
  if (ta == 2) { return arch_riscv64_emit_load_rbp_to_rax(out, off); }
  return arch_x86_64_emit_load_rbp_to_rax(out, off);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_store_rax_to_rbp(out: *u8, off: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_store_rax_to_rbp(out, off); }
  if (ta == 2) { return arch_riscv64_emit_store_rax_to_rbp(out, off); }
  return arch_x86_64_emit_store_rax_to_rbp(out, off);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_lea_rbp_to_rax(out: *u8, off: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_lea_rbp_to_rax(out, off); }
  if (ta == 2) { return arch_riscv64_emit_lea_rbp_to_rax(out, off); }
  return arch_x86_64_emit_lea_rbp_to_rax(out, off);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_rax_plus_rbx_scale4(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_rax_plus_rbx_scale4(out); }
  if (ta == 2) { return arch_riscv64_emit_rax_plus_rbx_scale4(out); }
  return arch_x86_64_emit_rax_plus_rbx_scale4(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_rax_plus_rbx_scale1(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_rax_plus_rbx_scale1(out); }
  if (ta == 2) { return arch_riscv64_emit_rax_plus_rbx_scale1(out); }
  return arch_x86_64_emit_rax_plus_rbx_scale1(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_rax_plus_rbx_scale8(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_rax_plus_rbx_scale8(out); }
  if (ta == 2) { return arch_riscv64_emit_rax_plus_rbx_scale8(out); }
  return arch_x86_64_emit_rax_plus_rbx_scale8(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_store_rax_to_rbx_indirect(out: *u8, elem_sz: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_store_rax_to_rbx_indirect(out, elem_sz); }
  if (ta == 2) { return arch_riscv64_emit_store_rax_to_rbx_indirect(out, elem_sz); }
  return arch_x86_64_emit_store_rax_to_rbx_indirect(out, elem_sz);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_load_32_from_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_load_32_from_rax(out); }
  if (ta == 2) { return arch_riscv64_emit_load_32_from_rax(out); }
  return arch_x86_64_emit_load_32_from_rax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_load_zext8_from_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_load_zext8_from_rax(out); }
  if (ta == 2) { return arch_riscv64_emit_load_zext8_from_rax(out); }
  return arch_x86_64_emit_load_zext8_from_rax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_add_imm_to_rax(out: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_add_imm_to_rax(out, imm); }
  if (ta == 2) { return arch_riscv64_emit_add_imm_to_rax(out, imm); }
  return arch_x86_64_emit_add_imm_to_rax(out, imm);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_load_64_from_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_load_64_from_rax(out); }
  if (ta == 2) { return arch_riscv64_emit_load_64_from_rax(out); }
  return arch_x86_64_emit_load_64_from_rax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_store_rax_to_rbx_offset(out: *u8, offset: i32, store_size: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_store_rax_to_rbx_offset(out, offset, store_size); }
  if (ta == 2) { return arch_riscv64_emit_store_rax_to_rbx_offset(out, offset, store_size); }
  return arch_x86_64_emit_store_rax_to_rbx_offset(out, offset, store_size);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_mov_rbx_to_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_mov_rbx_to_rax(out); }
  if (ta == 2) { return arch_riscv64_emit_mov_rbx_to_rax(out); }
  return arch_x86_64_emit_mov_rbx_to_rax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_mov_rax_to_arg_reg(out: *u8, k: i32, ta: i32): i32 {
  if (ta == 1) { return 0; }
  if (ta == 2) { return arch_riscv64_emit_mov_rax_to_arg_reg(out, k); }
  return arch_x86_64_emit_mov_rax_to_arg_reg(out, k);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_ldr_sp_offset_to_wi(out: *u8, i: i32, ta: i32): i32 {
  if (ta != 1) { return 0; }
  return arch_arm64_emit_ldr_sp_offset_to_wi(out, i);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_add_sp_imm(out: *u8, n: i32, ta: i32): i32 {
  if (ta != 1) { return 0; }
  return arch_arm64_emit_add_sp_imm(out, n);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_call(out: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_call(out, name, name_len); }
  if (ta == 2) { return arch_riscv64_emit_call(out, name, name_len); }
  return arch_x86_64_emit_call(out, name, name_len);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_jz(out: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_jz(out, label, label_len); }
  if (ta == 2) { return arch_riscv64_emit_jz(out, label, label_len); }
  return arch_x86_64_emit_jz(out, label, label_len);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_jeq(out: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_jeq(out, label, label_len); }
  if (ta == 2) { return arch_riscv64_emit_jeq(out, label, label_len); }
  return arch_x86_64_emit_jeq(out, label, label_len);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_jmp(out: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_jmp(out, label, label_len); }
  if (ta == 2) { return arch_riscv64_emit_jmp(out, label, label_len); }
  return arch_x86_64_emit_jmp(out, label, label_len);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_jnz(out: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_jnz(out, label, label_len); }
  if (ta == 2) { return arch_riscv64_emit_jnz(out, label, label_len); }
  return arch_x86_64_emit_jnz(out, label, label_len);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_not_eax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_not_eax(out); }
  if (ta == 2) { return arch_riscv64_emit_not_eax(out); }
  return arch_x86_64_emit_not_eax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_and_rbx_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_and_rbx_rax(out); }
  if (ta == 2) { return arch_riscv64_emit_and_rbx_rax(out); }
  return arch_x86_64_emit_and_rbx_rax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_or_rbx_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_or_rbx_rax(out); }
  if (ta == 2) { return arch_riscv64_emit_or_rbx_rax(out); }
  return arch_x86_64_emit_or_rbx_rax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_xor_rbx_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_xor_rbx_rax(out); }
  if (ta == 2) { return arch_riscv64_emit_xor_rbx_rax(out); }
  return arch_x86_64_emit_xor_rbx_rax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_mov_rbx_to_ecx(out: *u8, ta: i32): i32 {
  if (ta == 1) { return 0; }
  if (ta == 2) { return arch_riscv64_emit_mov_rbx_to_ecx(out); }
  return arch_x86_64_emit_mov_rbx_to_ecx(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_shl_cl_eax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_shl_cl_eax(out); }
  if (ta == 2) { return arch_riscv64_emit_shl_cl_eax(out); }
  return arch_x86_64_emit_shl_cl_eax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_shr_cl_eax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_shr_cl_eax(out); }
  if (ta == 2) { return arch_riscv64_emit_shr_cl_eax(out); }
  return arch_x86_64_emit_shr_cl_eax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_sar_cl_eax(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_sar_cl_eax(out); }
  if (ta == 2) { return arch_riscv64_emit_sar_cl_eax(out); }
  return arch_x86_64_emit_sar_cl_eax(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_label(out: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_label(out, name, name_len); }
  if (ta == 2) { return arch_riscv64_emit_label(out, name, name_len); }
  return arch_x86_64_emit_label(out, name, name_len);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_section_text(out: *u8, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_section_text(out); }
  if (ta == 2) { return arch_riscv64_emit_section_text(out); }
  return arch_x86_64_emit_section_text(out);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_globl(out: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_globl(out, name, name_len); }
  if (ta == 2) { return arch_riscv64_emit_globl(out, name, name_len); }
  return arch_x86_64_emit_globl(out, name, name_len);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_prologue(out: *u8, frame_sz: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_prologue(out, frame_sz); }
  if (ta == 2) { return arch_riscv64_emit_prologue(out, frame_sz); }
  return arch_x86_64_emit_prologue(out, frame_sz);
}

// G-02f-209：ta 分派壳真迁 .x
#[no_mangle]
function backend_arch_emit_epilogue(out: *u8, frame_sz: i32, ta: i32): i32 {
  if (ta == 1) { return arch_arm64_emit_epilogue(out, frame_sz); }
  if (ta == 2) { return arch_riscv64_emit_epilogue(out, frame_sz); }
  return arch_x86_64_emit_epilogue(out, frame_sz);
}
