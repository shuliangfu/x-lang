// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// PREFER_X_O：thin.o + seed-rest（-DXLANG_L2_ARCH_EMIT_THIN_FROM_X）ld -r → backend_arch_emit_dispatch.o
// See implementation.
// See implementation.
// See implementation.
//

export extern "C" function arch_arm64_emit_add_imm_to_rax(out: *u8, imm: i32): i32;
export extern "C" function arch_arm64_emit_add_rax_rbx(out: *u8): i32;
export extern "C" function arch_arm64_emit_add_sp_imm(out: *u8, n: i32): i32;
export extern "C" function arch_arm64_emit_and_rbx_rax(out: *u8): i32;
export extern "C" function arch_arm64_emit_call(out: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_arm64_emit_cmp_rbx_rax(out: *u8): i32;
export extern "C" function arch_arm64_emit_cmp_setcc(out: *u8, cc: i32): i32;
export extern "C" function arch_arm64_emit_epilogue(out: *u8, frame_sz: i32): i32;
export extern "C" function arch_arm64_emit_globl(out: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_arm64_emit_imul_rbx_rax(out: *u8): i32;
export extern "C" function arch_arm64_emit_jeq(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_emit_jmp(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_emit_jnz(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_emit_jz(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_emit_label(out: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_arm64_emit_ldr_sp_offset_to_wi(out: *u8, i: i32): i32;
export extern "C" function arch_arm64_emit_lea_rbp_to_rax(out: *u8, off: i32): i32;
export extern "C" function arch_arm64_emit_load_32_from_rax(out: *u8): i32;
export extern "C" function arch_arm64_emit_load_64_from_rax(out: *u8): i32;
export extern "C" function arch_arm64_emit_load_rbp_to_rax(out: *u8, off: i32): i32;
export extern "C" function arch_arm64_emit_load_zext8_from_rax(out: *u8): i32;
export extern "C" function arch_arm64_emit_mov_imm32_to_rbx(out: *u8, imm: i32): i32;
export extern "C" function arch_arm64_emit_mov_imm64_to_rax(out: *u8, lo: i32, hi: i32): i32;
export extern "C" function arch_arm64_emit_mov_rax_to_rbx(out: *u8): i32;
export extern "C" function arch_arm64_emit_mov_rbx_to_rax(out: *u8): i32;
export extern "C" function arch_arm64_emit_neg_eax(out: *u8): i32;
export extern "C" function arch_arm64_emit_not_eax(out: *u8): i32;
export extern "C" function arch_arm64_emit_or_rbx_rax(out: *u8): i32;
export extern "C" function arch_arm64_emit_pop_rax(out: *u8): i32;
export extern "C" function arch_arm64_emit_pop_rbx(out: *u8): i32;
export extern "C" function arch_arm64_emit_prologue(out: *u8, frame_sz: i32): i32;
export extern "C" function arch_arm64_emit_push_rax(out: *u8): i32;
export extern "C" function arch_arm64_emit_rax_plus_rbx_scale1(out: *u8): i32;
export extern "C" function arch_arm64_emit_rax_plus_rbx_scale4(out: *u8): i32;
export extern "C" function arch_arm64_emit_rax_plus_rbx_scale8(out: *u8): i32;
export extern "C" function arch_arm64_emit_ret_imm32(out: *u8, imm: i32): i32;
export extern "C" function arch_arm64_emit_sar_cl_eax(out: *u8): i32;
export extern "C" function arch_arm64_emit_section_text(out: *u8): i32;
export extern "C" function arch_arm64_emit_shl_cl_eax(out: *u8): i32;
export extern "C" function arch_arm64_emit_shr_cl_eax(out: *u8): i32;
export extern "C" function arch_arm64_emit_store_rax_to_rbp(out: *u8, off: i32): i32;
export extern "C" function arch_arm64_emit_store_rax_to_rbx_indirect(out: *u8, elem_sz: i32): i32;
export extern "C" function arch_arm64_emit_store_rax_to_rbx_offset(out: *u8, offset: i32, store_size: i32): i32;
export extern "C" function arch_arm64_emit_sub_rbx_rax_then_mov(out: *u8): i32;
export extern "C" function arch_arm64_emit_xor_rbx_rax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_add_imm_to_rax(out: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_emit_add_rax_rbx(out: *u8): i32;
export extern "C" function arch_riscv64_emit_and_rbx_rax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_call(out: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_riscv64_emit_cmp_rbx_rax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_cmp_setcc(out: *u8, cc: i32): i32;
export extern "C" function arch_riscv64_emit_epilogue(out: *u8, frame_sz: i32): i32;
export extern "C" function arch_riscv64_emit_globl(out: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_riscv64_emit_imul_rbx_rax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_jeq(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_emit_jmp(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_emit_jnz(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_emit_jz(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_emit_label(out: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_riscv64_emit_lea_rbp_to_rax(out: *u8, off: i32): i32;
export extern "C" function arch_riscv64_emit_load_32_from_rax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_load_64_from_rax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_load_rbp_to_rax(out: *u8, off: i32): i32;
export extern "C" function arch_riscv64_emit_load_zext8_from_rax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_mov_imm32_to_rbx(out: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_emit_mov_imm64_to_rax(out: *u8, lo: i32, hi: i32): i32;
export extern "C" function arch_riscv64_emit_mov_rax_to_arg_reg(out: *u8, k: i32): i32;
export extern "C" function arch_riscv64_emit_mov_rax_to_rbx(out: *u8): i32;
export extern "C" function arch_riscv64_emit_mov_rbx_to_ecx(out: *u8): i32;
export extern "C" function arch_riscv64_emit_mov_rbx_to_rax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_neg_eax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_not_eax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_or_rbx_rax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_pop_rax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_pop_rbx(out: *u8): i32;
export extern "C" function arch_riscv64_emit_prologue(out: *u8, frame_sz: i32): i32;
export extern "C" function arch_riscv64_emit_push_rax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_rax_plus_rbx_scale1(out: *u8): i32;
export extern "C" function arch_riscv64_emit_rax_plus_rbx_scale4(out: *u8): i32;
export extern "C" function arch_riscv64_emit_rax_plus_rbx_scale8(out: *u8): i32;
export extern "C" function arch_riscv64_emit_ret_imm32(out: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_emit_sar_cl_eax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_section_text(out: *u8): i32;
export extern "C" function arch_riscv64_emit_shl_cl_eax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_shr_cl_eax(out: *u8): i32;
export extern "C" function arch_riscv64_emit_store_rax_to_rbp(out: *u8, off: i32): i32;
export extern "C" function arch_riscv64_emit_store_rax_to_rbx_indirect(out: *u8, elem_sz: i32): i32;
export extern "C" function arch_riscv64_emit_store_rax_to_rbx_offset(out: *u8, offset: i32, store_size: i32): i32;
export extern "C" function arch_riscv64_emit_sub_rbx_rax_then_mov(out: *u8): i32;
export extern "C" function arch_riscv64_emit_xor_rbx_rax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_add_imm_to_rax(out: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_emit_add_rax_rbx(out: *u8): i32;
export extern "C" function arch_x86_64_emit_and_rbx_rax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_call(out: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_x86_64_emit_cmp_rbx_rax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_cmp_setcc(out: *u8, cc: i32): i32;
export extern "C" function arch_x86_64_emit_epilogue(out: *u8, frame_sz: i32): i32;
export extern "C" function arch_x86_64_emit_globl(out: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_x86_64_emit_imul_rbx_rax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_jeq(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_emit_jmp(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_emit_jnz(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_emit_jz(out: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_emit_label(out: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_x86_64_emit_lea_rbp_to_rax(out: *u8, off: i32): i32;
export extern "C" function arch_x86_64_emit_load_32_from_rax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_load_64_from_rax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_load_rbp_to_rax(out: *u8, off: i32): i32;
export extern "C" function arch_x86_64_emit_load_zext8_from_rax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_mov_imm32_to_rbx(out: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_emit_mov_imm64_to_rax(out: *u8, lo: i32, hi: i32): i32;
export extern "C" function arch_x86_64_emit_mov_rax_to_arg_reg(out: *u8, k: i32): i32;
export extern "C" function arch_x86_64_emit_mov_rax_to_rbx(out: *u8): i32;
export extern "C" function arch_x86_64_emit_mov_rbx_to_ecx(out: *u8): i32;
export extern "C" function arch_x86_64_emit_mov_rbx_to_rax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_neg_eax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_not_eax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_or_rbx_rax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_pop_rax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_pop_rbx(out: *u8): i32;
export extern "C" function arch_x86_64_emit_prologue(out: *u8, frame_sz: i32): i32;
export extern "C" function arch_x86_64_emit_push_rax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_rax_plus_rbx_scale1(out: *u8): i32;
export extern "C" function arch_x86_64_emit_rax_plus_rbx_scale4(out: *u8): i32;
export extern "C" function arch_x86_64_emit_rax_plus_rbx_scale8(out: *u8): i32;
export extern "C" function arch_x86_64_emit_ret_imm32(out: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_emit_sar_cl_eax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_section_text(out: *u8): i32;
export extern "C" function arch_x86_64_emit_shl_cl_eax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_shr_cl_eax(out: *u8): i32;
export extern "C" function arch_x86_64_emit_store_rax_to_rbp(out: *u8, off: i32): i32;
export extern "C" function arch_x86_64_emit_store_rax_to_rbx_indirect(out: *u8, elem_sz: i32): i32;
export extern "C" function arch_x86_64_emit_store_rax_to_rbx_offset(out: *u8, offset: i32, store_size: i32): i32;
export extern "C" function arch_x86_64_emit_sub_rbx_rax_then_mov(out: *u8): i32;
export extern "C" function arch_x86_64_emit_xor_rbx_rax(out: *u8): i32;

/** Exported function `backend_arch_emit_ret_imm32`.
 * Implements `backend_arch_emit_ret_imm32`.
 * @param out *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_ret_imm32(out: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_ret_imm32(out, imm); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_ret_imm32(out, imm); }
  }
  unsafe { return arch_x86_64_emit_ret_imm32(out, imm); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_mov_imm64_to_rax`.
 * Implements `backend_arch_emit_mov_imm64_to_rax`.
 * @param out *u8
 * @param lo i32
 * @param hi i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_mov_imm64_to_rax(out: *u8, lo: i32, hi: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_mov_imm64_to_rax(out, lo, hi); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_mov_imm64_to_rax(out, lo, hi); }
  }
  unsafe { return arch_x86_64_emit_mov_imm64_to_rax(out, lo, hi); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_mov_imm32_to_rbx`.
 * Implements `backend_arch_emit_mov_imm32_to_rbx`.
 * @param out *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_mov_imm32_to_rbx(out: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_mov_imm32_to_rbx(out, imm); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_mov_imm32_to_rbx(out, imm); }
  }
  unsafe { return arch_x86_64_emit_mov_imm32_to_rbx(out, imm); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_neg_eax`.
 * Implements `backend_arch_emit_neg_eax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_neg_eax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_neg_eax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_neg_eax(out); }
  }
  unsafe { return arch_x86_64_emit_neg_eax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_cmp_rbx_rax`.
 * Comparison/utility `backend_arch_emit_cmp_rbx_rax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_cmp_rbx_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_cmp_rbx_rax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_cmp_rbx_rax(out); }
  }
  unsafe { return arch_x86_64_emit_cmp_rbx_rax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_cmp_setcc`.
 * Comparison/utility `backend_arch_emit_cmp_setcc`.
 * @param out *u8
 * @param cc i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_cmp_setcc(out: *u8, cc: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_cmp_setcc(out, cc); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_cmp_setcc(out, cc); }
  }
  unsafe { return arch_x86_64_emit_cmp_setcc(out, cc); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_push_rax`.
 * Implements `backend_arch_emit_push_rax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_push_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_push_rax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_push_rax(out); }
  }
  unsafe { return arch_x86_64_emit_push_rax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_pop_rbx`.
 * Implements `backend_arch_emit_pop_rbx`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_pop_rbx(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_pop_rbx(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_pop_rbx(out); }
  }
  unsafe { return arch_x86_64_emit_pop_rbx(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_pop_rax`.
 * Implements `backend_arch_emit_pop_rax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_pop_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_pop_rax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_pop_rax(out); }
  }
  unsafe { return arch_x86_64_emit_pop_rax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_add_rax_rbx`.
 * Implements `backend_arch_emit_add_rax_rbx`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_add_rax_rbx(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_add_rax_rbx(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_add_rax_rbx(out); }
  }
  unsafe { return arch_x86_64_emit_add_rax_rbx(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_sub_rbx_rax_then_mov`.
 * Implements `backend_arch_emit_sub_rbx_rax_then_mov`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_sub_rbx_rax_then_mov(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_sub_rbx_rax_then_mov(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_sub_rbx_rax_then_mov(out); }
  }
  unsafe { return arch_x86_64_emit_sub_rbx_rax_then_mov(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_imul_rbx_rax`.
 * Implements `backend_arch_emit_imul_rbx_rax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_imul_rbx_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_imul_rbx_rax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_imul_rbx_rax(out); }
  }
  unsafe { return arch_x86_64_emit_imul_rbx_rax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_mov_rax_to_rbx`.
 * Implements `backend_arch_emit_mov_rax_to_rbx`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_mov_rax_to_rbx(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_mov_rax_to_rbx(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_mov_rax_to_rbx(out); }
  }
  unsafe { return arch_x86_64_emit_mov_rax_to_rbx(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_load_rbp_to_rax`.
 * Implements `backend_arch_emit_load_rbp_to_rax`.
 * @param out *u8
 * @param off i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_load_rbp_to_rax(out: *u8, off: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_load_rbp_to_rax(out, off); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_load_rbp_to_rax(out, off); }
  }
  unsafe { return arch_x86_64_emit_load_rbp_to_rax(out, off); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_store_rax_to_rbp`.
 * Implements `backend_arch_emit_store_rax_to_rbp`.
 * @param out *u8
 * @param off i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_store_rax_to_rbp(out: *u8, off: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_store_rax_to_rbp(out, off); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_store_rax_to_rbp(out, off); }
  }
  unsafe { return arch_x86_64_emit_store_rax_to_rbp(out, off); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_lea_rbp_to_rax`.
 * Implements `backend_arch_emit_lea_rbp_to_rax`.
 * @param out *u8
 * @param off i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_lea_rbp_to_rax(out: *u8, off: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_lea_rbp_to_rax(out, off); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_lea_rbp_to_rax(out, off); }
  }
  unsafe { return arch_x86_64_emit_lea_rbp_to_rax(out, off); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_rax_plus_rbx_scale4`.
 * Implements `backend_arch_emit_rax_plus_rbx_scale4`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_rax_plus_rbx_scale4(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_rax_plus_rbx_scale4(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_rax_plus_rbx_scale4(out); }
  }
  unsafe { return arch_x86_64_emit_rax_plus_rbx_scale4(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_rax_plus_rbx_scale1`.
 * Implements `backend_arch_emit_rax_plus_rbx_scale1`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_rax_plus_rbx_scale1(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_rax_plus_rbx_scale1(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_rax_plus_rbx_scale1(out); }
  }
  unsafe { return arch_x86_64_emit_rax_plus_rbx_scale1(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_rax_plus_rbx_scale8`.
 * Implements `backend_arch_emit_rax_plus_rbx_scale8`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_rax_plus_rbx_scale8(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_rax_plus_rbx_scale8(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_rax_plus_rbx_scale8(out); }
  }
  unsafe { return arch_x86_64_emit_rax_plus_rbx_scale8(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_store_rax_to_rbx_indirect`.
 * Implements `backend_arch_emit_store_rax_to_rbx_indirect`.
 * @param out *u8
 * @param elem_sz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_store_rax_to_rbx_indirect(out: *u8, elem_sz: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_store_rax_to_rbx_indirect(out, elem_sz); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_store_rax_to_rbx_indirect(out, elem_sz); }
  }
  unsafe { return arch_x86_64_emit_store_rax_to_rbx_indirect(out, elem_sz); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_load_32_from_rax`.
 * Implements `backend_arch_emit_load_32_from_rax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_load_32_from_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_load_32_from_rax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_load_32_from_rax(out); }
  }
  unsafe { return arch_x86_64_emit_load_32_from_rax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_load_zext8_from_rax`.
 * Implements `backend_arch_emit_load_zext8_from_rax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_load_zext8_from_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_load_zext8_from_rax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_load_zext8_from_rax(out); }
  }
  unsafe { return arch_x86_64_emit_load_zext8_from_rax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_add_imm_to_rax`.
 * Implements `backend_arch_emit_add_imm_to_rax`.
 * @param out *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_add_imm_to_rax(out: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_add_imm_to_rax(out, imm); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_add_imm_to_rax(out, imm); }
  }
  unsafe { return arch_x86_64_emit_add_imm_to_rax(out, imm); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_load_64_from_rax`.
 * Implements `backend_arch_emit_load_64_from_rax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_load_64_from_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_load_64_from_rax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_load_64_from_rax(out); }
  }
  unsafe { return arch_x86_64_emit_load_64_from_rax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_store_rax_to_rbx_offset`.
 * Implements `backend_arch_emit_store_rax_to_rbx_offset`.
 * @param out *u8
 * @param offset i32
 * @param store_size i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_store_rax_to_rbx_offset(out: *u8, offset: i32, store_size: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_store_rax_to_rbx_offset(out, offset, store_size); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_store_rax_to_rbx_offset(out, offset, store_size); }
  }
  unsafe { return arch_x86_64_emit_store_rax_to_rbx_offset(out, offset, store_size); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_mov_rbx_to_rax`.
 * Implements `backend_arch_emit_mov_rbx_to_rax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_mov_rbx_to_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_mov_rbx_to_rax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_mov_rbx_to_rax(out); }
  }
  unsafe { return arch_x86_64_emit_mov_rbx_to_rax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_mov_rax_to_arg_reg`.
 * Implements `backend_arch_emit_mov_rax_to_arg_reg`.
 * @param out *u8
 * @param k i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_mov_rax_to_arg_reg(out: *u8, k: i32, ta: i32): i32 {
  if (ta == 1) {
    return 0;
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_mov_rax_to_arg_reg(out, k); }
  }
  unsafe { return arch_x86_64_emit_mov_rax_to_arg_reg(out, k); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_ldr_sp_offset_to_wi`.
 * Implements `backend_arch_emit_ldr_sp_offset_to_wi`.
 * @param out *u8
 * @param i i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_ldr_sp_offset_to_wi(out: *u8, i: i32, ta: i32): i32 {
  if (ta != 1) {
    return 0;
  }
  unsafe { return arch_arm64_emit_ldr_sp_offset_to_wi(out, i); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_add_sp_imm`.
 * Implements `backend_arch_emit_add_sp_imm`.
 * @param out *u8
 * @param n i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_add_sp_imm(out: *u8, n: i32, ta: i32): i32 {
  if (ta != 1) {
    return 0;
  }
  unsafe { return arch_arm64_emit_add_sp_imm(out, n); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_call`.
 * Implements `backend_arch_emit_call`.
 * @param out *u8
 * @param name *u8
 * @param name_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_call(out: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_call(out, name, name_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_call(out, name, name_len); }
  }
  unsafe { return arch_x86_64_emit_call(out, name, name_len); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_jz`.
 * Implements `backend_arch_emit_jz`.
 * @param out *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_jz(out: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_jz(out, label, label_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_jz(out, label, label_len); }
  }
  unsafe { return arch_x86_64_emit_jz(out, label, label_len); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_jeq`.
 * Implements `backend_arch_emit_jeq`.
 * @param out *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_jeq(out: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_jeq(out, label, label_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_jeq(out, label, label_len); }
  }
  unsafe { return arch_x86_64_emit_jeq(out, label, label_len); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_jmp`.
 * Implements `backend_arch_emit_jmp`.
 * @param out *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_jmp(out: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_jmp(out, label, label_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_jmp(out, label, label_len); }
  }
  unsafe { return arch_x86_64_emit_jmp(out, label, label_len); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_jnz`.
 * Implements `backend_arch_emit_jnz`.
 * @param out *u8
 * @param label *u8
 * @param label_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_jnz(out: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_jnz(out, label, label_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_jnz(out, label, label_len); }
  }
  unsafe { return arch_x86_64_emit_jnz(out, label, label_len); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_not_eax`.
 * Implements `backend_arch_emit_not_eax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_not_eax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_not_eax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_not_eax(out); }
  }
  unsafe { return arch_x86_64_emit_not_eax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_and_rbx_rax`.
 * Implements `backend_arch_emit_and_rbx_rax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_and_rbx_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_and_rbx_rax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_and_rbx_rax(out); }
  }
  unsafe { return arch_x86_64_emit_and_rbx_rax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_or_rbx_rax`.
 * Implements `backend_arch_emit_or_rbx_rax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_or_rbx_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_or_rbx_rax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_or_rbx_rax(out); }
  }
  unsafe { return arch_x86_64_emit_or_rbx_rax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_xor_rbx_rax`.
 * Implements `backend_arch_emit_xor_rbx_rax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_xor_rbx_rax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_xor_rbx_rax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_xor_rbx_rax(out); }
  }
  unsafe { return arch_x86_64_emit_xor_rbx_rax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_mov_rbx_to_ecx`.
 * Implements `backend_arch_emit_mov_rbx_to_ecx`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_mov_rbx_to_ecx(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    return 0;
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_mov_rbx_to_ecx(out); }
  }
  unsafe { return arch_x86_64_emit_mov_rbx_to_ecx(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_shl_cl_eax`.
 * Implements `backend_arch_emit_shl_cl_eax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_shl_cl_eax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_shl_cl_eax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_shl_cl_eax(out); }
  }
  unsafe { return arch_x86_64_emit_shl_cl_eax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_shr_cl_eax`.
 * Implements `backend_arch_emit_shr_cl_eax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_shr_cl_eax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_shr_cl_eax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_shr_cl_eax(out); }
  }
  unsafe { return arch_x86_64_emit_shr_cl_eax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_sar_cl_eax`.
 * Implements `backend_arch_emit_sar_cl_eax`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_sar_cl_eax(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_sar_cl_eax(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_sar_cl_eax(out); }
  }
  unsafe { return arch_x86_64_emit_sar_cl_eax(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_label`.
 * Implements `backend_arch_emit_label`.
 * @param out *u8
 * @param name *u8
 * @param name_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_label(out: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_label(out, name, name_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_label(out, name, name_len); }
  }
  unsafe { return arch_x86_64_emit_label(out, name, name_len); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_section_text`.
 * Implements `backend_arch_emit_section_text`.
 * @param out *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_section_text(out: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_section_text(out); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_section_text(out); }
  }
  unsafe { return arch_x86_64_emit_section_text(out); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_globl`.
 * Implements `backend_arch_emit_globl`.
 * @param out *u8
 * @param name *u8
 * @param name_len i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_globl(out: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_globl(out, name, name_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_globl(out, name, name_len); }
  }
  unsafe { return arch_x86_64_emit_globl(out, name, name_len); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_prologue`.
 * Implements `backend_arch_emit_prologue`.
 * @param out *u8
 * @param frame_sz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_prologue(out: *u8, frame_sz: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_prologue(out, frame_sz); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_prologue(out, frame_sz); }
  }
  unsafe { return arch_x86_64_emit_prologue(out, frame_sz); }
  return 0 - 1;
}

/** Exported function `backend_arch_emit_epilogue`.
 * Implements `backend_arch_emit_epilogue`.
 * @param out *u8
 * @param frame_sz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_arch_emit_epilogue(out: *u8, frame_sz: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_emit_epilogue(out, frame_sz); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_emit_epilogue(out, frame_sz); }
  }
  unsafe { return arch_x86_64_emit_epilogue(out, frame_sz); }
  return 0 - 1;
}

