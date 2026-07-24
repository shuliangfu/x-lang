// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// PREFER_X_O：thin.o + seed-rest（-DXLANG_L2_ENC_DISPATCH_THIN_FROM_X）ld -r → backend_enc_dispatch.o
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// RBP lane：LDUR 0xB8400000 / STUR 0xB8000000 + simm9 + Rn=x29。
// See implementation.
//

export extern "C" function backend_enc_append_u32_le_c_impl(elf_ctx: *u8, word: u32): i32;
export extern "C" function backend_enc_append_u8_c_impl(elf_ctx: *u8, byte: i32): i32;
export extern "C" function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, val: i32): i32;
export extern "C" function backend_enc_arm64_call_c_impl(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_call_impl(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_mov_rax_to_arg_reg_impl(elf_ctx: *u8, k: i32): i32;

// ADD X31, X31, #imm12  （SP+imm）
/** Exported function `backend_enc_arm64_add_sp_imm12_c`.
 * Implements `backend_enc_arm64_add_sp_imm12_c`.
 * @param elf_ctx *u8
 * @param imm i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_arm64_add_sp_imm12_c(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (imm <= 0) {
    return 0;
  }
  if (imm > 4095) {
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, 2432697343 | (4095 * 1024));
    }
    return 0 - 1;
  }
  unsafe {
    return backend_enc_append_u32_le_c_impl(elf_ctx, 2432697343 | ((imm as u32) * 1024));
  }
  return 0 - 1;
}

// SUB X31, X31, #imm12
/** Exported function `backend_enc_arm64_sub_sp_imm12_c`.
 * Implements `backend_enc_arm64_sub_sp_imm12_c`.
 * @param elf_ctx *u8
 * @param imm i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_arm64_sub_sp_imm12_c(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (imm <= 0) {
    return 0;
  }
  if (imm > 4095) {
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, 3506439167 | (4095 * 1024));
    }
    return 0 - 1;
  }
  unsafe {
    return backend_enc_append_u32_le_c_impl(elf_ctx, 3506439167 | ((imm as u32) * 1024));
  }
  return 0 - 1;
}

// STR X0, [SP, #imm12*8]
/** Exported function `backend_enc_arm64_str_x0_sp_offset_c`.
 * Implements `backend_enc_arm64_str_x0_sp_offset_c`.
 * @param elf_ctx *u8
 * @param off_bytes i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_arm64_str_x0_sp_offset_c(elf_ctx: *u8, off_bytes: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (off_bytes < 0) {
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, 4177527776);
    }
    return 0 - 1;
  }
  if (off_bytes / 8 > 4095) {
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, 4177527776 | (4095 * 1024));
    }
    return 0 - 1;
  }
  unsafe {
    return backend_enc_append_u32_le_c_impl(elf_ctx, 4177527776 | (((off_bytes / 8) as u32) * 1024));
  }
  return 0 - 1;
}

// arm64_enc_load_w0_from_rbp_c: see function docblock below.
/** Exported function `arm64_enc_load_w0_from_rbp_c`.
 * Implements `arm64_enc_load_w0_from_rbp_c`.
 * @param elf_ctx *u8
 * @param offset i32
 * @return i32
 */
#[no_mangle]
export function arm64_enc_load_w0_from_rbp_c(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (offset < 0) {
    return 0 - 1;
  }
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

// STUR w0, [x29, #-offset]
/** Exported function `arm64_enc_store_w0_to_rbp_c`.
 * Implements `arm64_enc_store_w0_to_rbp_c`.
 * @param elf_ctx *u8
 * @param offset i32
 * @return i32
 */
#[no_mangle]
export function arm64_enc_store_w0_to_rbp_c(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (offset < 0) {
    return 0 - 1;
  }
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
  unsafe {
    return backend_enc_arm64_call_c_impl(elf_ctx, name, name_len);
  }
  return 0 - 1;
}

/** Exported function `arch_riscv64_enc_enc_call`.
 * Implements `arch_riscv64_enc_enc_call`.
 * @param elf_ctx *u8
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
#[no_mangle]
export function arch_riscv64_enc_enc_call(elf_ctx: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    return arch_riscv64_enc_enc_call_impl(elf_ctx, name, name_len);
  }
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
  unsafe {
    return arch_riscv64_enc_enc_mov_rax_to_arg_reg_impl(elf_ctx, k);
  }
  return 0 - 1;
}

// See implementation.
export extern "C" function arch_arm64_enc_enc_push_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_push_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_push_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_push_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_push_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_push_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_pop_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_pop_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_pop_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_epilogue(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_epilogue(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_epilogue(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_sub_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_sub_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;

/** Exported function `backend_enc_push_rax_arch`.
 * Implements `backend_enc_push_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_push_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_push_rax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_push_rax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_push_rbx_arch`.
 * Implements `backend_enc_push_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_push_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_push_rbx(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_push_rbx(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_push_rbx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_pop_rax_arch`.
 * Implements `backend_enc_pop_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_pop_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_pop_rax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_pop_rax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_pop_rbx_arch`.
 * Implements `backend_enc_pop_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_pop_rbx(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_pop_rbx(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_pop_rbx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_epilogue_arch`.
 * Implements `backend_enc_epilogue_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_epilogue_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_epilogue(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_epilogue(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_epilogue(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_add_rax_rbx_arch`.
 * Implements `backend_enc_add_rax_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_add_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_add_rax_rbx(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_add_rax_rbx(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_add_rax_rbx(elf_ctx); }
  return 0 - 1;
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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_sub_rax_rbx(elf_ctx); }
  }
  if (ta == 2) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_sub_rax_rbx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_imul_rbx_rax_arch`.
 * Implements `backend_enc_imul_rbx_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_imul_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_imul_rbx_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_imul_rbx_rax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx); }
  return 0 - 1;
}

// See implementation.
export extern "C" function arch_arm64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_not_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_not_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_not_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_cltd(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_cltd(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_cltd(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_neg_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_neg_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_neg_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;

/** Exported function `backend_enc_mov_rax_to_rbx_arch`.
 * Implements `backend_enc_mov_rax_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_mov_rax_to_rbx(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_mov_rax_to_rbx(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_not_eax_arch`.
 * Implements `backend_enc_not_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_not_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_not_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_not_eax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_and_rbx_rax_arch`.
 * Implements `backend_enc_and_rbx_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_and_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_and_rbx_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_and_rbx_rax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_and_rbx_rax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_or_rbx_rax_arch`.
 * Implements `backend_enc_or_rbx_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_or_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_or_rbx_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_or_rbx_rax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_or_rbx_rax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_xor_rbx_rax_arch`.
 * Implements `backend_enc_xor_rbx_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_xor_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_xor_rbx_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_xor_rbx_rax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_mov_rbx_to_ecx_arch`.
 * Implements `backend_enc_mov_rbx_to_ecx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_rbx_to_ecx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_mov_rbx_to_ecx(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_mov_rbx_to_ecx(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_cltd_arch`.
 * Implements `backend_enc_cltd_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cltd_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_cltd(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_cltd(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_cltd(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_neg_eax_arch`.
 * Implements `backend_enc_neg_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_neg_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_neg_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_neg_eax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_test_eax_eax_arch`.
 * Implements `backend_enc_test_eax_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_test_eax_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_test_eax_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_test_eax_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_test_eax_eax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_test_rbx_rbx_arch`.
 * Implements `backend_enc_test_rbx_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_test_rbx_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_test_rbx_rbx(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_test_rbx_rbx(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx); }
  return 0 - 1;
}

// See implementation.
export extern "C" function arch_arm64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_shl_cl_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_shr_cl_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_sar_cl_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_div_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_sar_cl_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_shl_cl_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_shr_cl_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_xor_edx_edx(elf_ctx: *u8): i32;

/** Exported function `backend_enc_shl_cl_eax_arch`.
 * Implements `backend_enc_shl_cl_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_shl_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_shl_cl_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_shl_cl_eax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_shr_cl_eax_arch`.
 * Implements `backend_enc_shr_cl_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_shr_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_shr_cl_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_shr_cl_eax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_sar_cl_eax_arch`.
 * Implements `backend_enc_sar_cl_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_sar_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_sar_cl_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_sar_cl_eax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_mov_edx_to_eax_arch`.
 * Implements `backend_enc_mov_edx_to_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_edx_to_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_setz_movzbl_eax_arch`.
 * Implements `backend_enc_setz_movzbl_eax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_setz_movzbl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_setz_movzbl_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_cmp_rbx_rax_arch`.
 * Comparison/utility `backend_enc_cmp_rbx_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cmp_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_sub_rbx_rax_then_mov_arch`.
 * Implements `backend_enc_sub_rbx_rax_then_mov_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_sub_rbx_rax_then_mov(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_sub_rbx_rax_then_mov(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_shl_cl_rax_arch`.
 * Implements `backend_enc_shl_cl_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_shl_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  /* wave306: arm64 64-bit lsl x0 (not 32-bit eax alias). */
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_shl_cl_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_shl_cl_rax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_shr_cl_rax_arch`.
 * Implements `backend_enc_shr_cl_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_shr_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  /* wave306: arm64 64-bit lsr x0 for i64/u64 is_64bit path. */
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_shr_cl_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_shr_cl_rax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_sar_cl_rax_arch`.
 * Implements `backend_enc_sar_cl_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_sar_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  /* wave306: arm64 64-bit asr x0 for signed i64 is_64bit path. */
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_sar_cl_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_sar_cl_rax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_cmp_rax_rbx_arch`.
 * Comparison/utility `backend_enc_cmp_rax_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cmp_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_cmp_rax_rbx(elf_ctx); }
  }
  if (ta == 2) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_cmp_rax_rbx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_idiv_rbx_arch`.
 * Implements `backend_enc_idiv_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_idiv_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_idiv_rbx(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_idiv_rbx(elf_ctx); }
  }
  unsafe {
    if (arch_x86_64_enc_enc_cltd(elf_ctx) != 0) {
      return 0 - 1;
    }
    return arch_x86_64_enc_enc_idiv_rbx(elf_ctx);
  }
  return 0 - 1;
}

/** Exported function `backend_enc_div_rbx_arch`.
 * Implements `backend_enc_div_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_div_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_idiv_rbx(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_idiv_rbx(elf_ctx); }
  }
  unsafe {
    if (arch_x86_64_enc_enc_xor_edx_edx(elf_ctx) != 0) {
      return 0 - 1;
    }
    return arch_x86_64_enc_enc_div_rbx(elf_ctx);
  }
  return 0 - 1;
}

// See implementation.
export extern "C" function arch_arm64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_arm64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_arm64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
export extern "C" function arch_arm64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
export extern "C" function arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_arm64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_arm64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
export extern "C" function arch_arm64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
export extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
export extern "C" function arch_riscv64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
export extern "C" function arch_riscv64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_riscv64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
export extern "C" function arch_riscv64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
export extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_riscv64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
export extern "C" function arch_x86_64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
export extern "C" function arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
export extern "C" function arch_x86_64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
export extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
export extern "C" function arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;

/** Exported function `backend_enc_prologue_arch`.
 * Implements `backend_enc_prologue_arch`.
 * @param elf_ctx *u8
 * @param frame_sz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_prologue_arch(elf_ctx: *u8, frame_sz: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_prologue(elf_ctx, frame_sz); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_prologue(elf_ctx, frame_sz); }
  }
  unsafe { return arch_x86_64_enc_enc_prologue(elf_ctx, frame_sz); }
  return 0 - 1;
}

/** Exported function `backend_enc_ret_imm32_arch`.
 * Implements `backend_enc_ret_imm32_arch`.
 * @param elf_ctx *u8
 * @param imm32 i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_ret_imm32_arch(elf_ctx: *u8, imm32: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_ret_imm32(elf_ctx, imm32); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_ret_imm32(elf_ctx, imm32); }
  }
  unsafe { return arch_x86_64_enc_enc_ret_imm32(elf_ctx, imm32); }
  return 0 - 1;
}

/** Exported function `backend_enc_mov_imm32_to_rbx_arch`.
 * Implements `backend_enc_mov_imm32_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param imm32 i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm32: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32); }
  }
  unsafe { return arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32); }
  return 0 - 1;
}

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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi); }
  }
  unsafe { return arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi); }
  return 0 - 1;
}

/** Exported function `backend_enc_cmp_setcc_movzbl_arch`.
 * Comparison/utility `backend_enc_cmp_setcc_movzbl_arch`.
 * @param elf_ctx *u8
 * @param cc i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc); }
  }
  unsafe { return arch_x86_64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc); }
  return 0 - 1;
}

/** Exported function `backend_enc_store_rax_to_rbp_arch`.
 * Implements `backend_enc_store_rax_to_rbp_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx, offset); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_store_rax_to_rbp(elf_ctx, offset); }
  }
  unsafe { return arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx, offset); }
  return 0 - 1;
}

/** Exported function `backend_enc_load_rbp_to_rax_arch`.
 * Implements `backend_enc_load_rbp_to_rax_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx, offset); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_load_rbp_to_rax(elf_ctx, offset); }
  }
  unsafe { return arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx, offset); }
  return 0 - 1;
}

/** Exported function `backend_enc_lea_rbp_to_rax_arch`.
 * Implements `backend_enc_lea_rbp_to_rax_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx, offset); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_lea_rbp_to_rax(elf_ctx, offset); }
  }
  unsafe { return arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx, offset); }
  return 0 - 1;
}

/** Exported function `backend_enc_lea_rbp_to_rbx_arch`.
 * Implements `backend_enc_lea_rbp_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_lea_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset); }
  }
  unsafe { return arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset); }
  return 0 - 1;
}

/** Exported function `backend_enc_rax_plus_rbx_scale1_arch`.
 * Implements `backend_enc_rax_plus_rbx_scale1_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rax_plus_rbx_scale1_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_rax_plus_rbx_scale1(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_rax_plus_rbx_scale1(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_rax_plus_rbx_scale4_arch`.
 * Implements `backend_enc_rax_plus_rbx_scale4_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rax_plus_rbx_scale4_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_rax_plus_rbx_scale4(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_rax_plus_rbx_scale4(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_rax_plus_rbx_scale8_arch`.
 * Implements `backend_enc_rax_plus_rbx_scale8_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rax_plus_rbx_scale8_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_rax_plus_rbx_scale8(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_rax_plus_rbx_scale8(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_load_zext8_from_rax_arch`.
 * Implements `backend_enc_load_zext8_from_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_load_zext8_from_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_load_zext8_from_rax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_add_imm_to_rax_arch`.
 * Implements `backend_enc_add_imm_to_rax_arch`.
 * @param elf_ctx *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_add_imm_to_rax(elf_ctx, imm); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_add_imm_to_rax(elf_ctx, imm); }
  }
  unsafe { return arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx, imm); }
  return 0 - 1;
}

/** Exported function `backend_enc_add_imm_to_rbx_arch`.
 * Implements `backend_enc_add_imm_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_add_imm_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_add_imm_to_rbx(elf_ctx, imm); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx, imm); }
  }
  unsafe { return arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx, imm); }
  return 0 - 1;
}

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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_label(elf_ctx, name, name_len, is_func); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_label(elf_ctx, name, name_len, is_func); }
  }
  unsafe { return arch_x86_64_enc_enc_label(elf_ctx, name, name_len, is_func); }
  return 0 - 1;
}

// See implementation.
export extern "C" function arch_arm64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
export extern "C" function arch_riscv64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
export extern "C" function arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
export extern "C" function arch_arm64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_cdqe_rax_impl(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_load_rbp_to_a2(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_arm64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
export extern "C" function arch_riscv64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
export extern "C" function arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
export extern "C" function arch_arm64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_jne(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
export extern "C" function arch_arm64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
export extern "C" function arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
export extern "C" function arch_riscv64_enc_enc_add_sp_imm12(elf_ctx: *u8, nbytes: i32): i32;
export extern "C" function arch_x86_64_enc_enc_add_rsp_imm(elf_ctx: *u8, nbytes: i32): i32;
export extern "C" function arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx: *u8, reg: i32, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx: *u8, offset: i32): i32;

/** Exported function `backend_enc_store_rax_to_rbx_indirect_arch`.
 * Implements `backend_enc_store_rax_to_rbx_indirect_arch`.
 * @param elf_ctx *u8
 * @param elem_sz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx: *u8, elem_sz: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz); }
  }
  unsafe { return arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz); }
  return 0 - 1;
}

/** Exported function `backend_enc_load_32_from_rax_arch`.
 * Implements `backend_enc_load_32_from_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_32_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_load_32_from_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_load_32_from_rax(elf_ctx); }
  }
  unsafe {
    if (arch_x86_64_enc_enc_load_32_from_rax(elf_ctx) != 0) {
      return 0 - 1;
    }
    return arch_x86_64_enc_enc_cdqe_rax_impl(elf_ctx);
  }
  return 0 - 1;
}

/** Exported function `backend_enc_load_i32_indirect_to_rax_arch`.
 * Implements `backend_enc_load_i32_indirect_to_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_load_32_from_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_load_32_from_rax(elf_ctx); }
  }
  unsafe {
    if (arch_x86_64_enc_enc_load_32_from_rax(elf_ctx) != 0) {
      return 0 - 1;
    }
    return arch_x86_64_enc_enc_cdqe_rax_impl(elf_ctx);
  }
  return 0 - 1;
}

/** Exported function `backend_enc_load_rbp_index_scratch_arch`.
 * Implements `backend_enc_load_rbp_index_scratch_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_rbp_index_scratch_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx, offset); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_load_rbp_to_a2(elf_ctx, offset); }
  }
  unsafe { return arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx, offset); }
  return 0 - 1;
}

/** Exported function `backend_enc_load_64_from_rax_arch`.
 * Implements `backend_enc_load_64_from_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_load_64_from_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_load_64_from_rax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_load_64_from_rax(elf_ctx); }
  return 0 - 1;
}

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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size); }
  }
  unsafe { return arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size); }
  return 0 - 1;
}

/** Exported function `backend_enc_mov_rbx_to_rax_arch`.
 * Implements `backend_enc_mov_rbx_to_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_mov_rbx_to_rax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_mov_rbx_to_rax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx); }
  return 0 - 1;
}

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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_jz(elf_ctx, label, label_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_jz(elf_ctx, label, label_len); }
  }
  unsafe { return arch_x86_64_enc_enc_jz(elf_ctx, label, label_len); }
  return 0 - 1;
}

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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_jeq(elf_ctx, label, label_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_jeq(elf_ctx, label, label_len); }
  }
  unsafe { return arch_x86_64_enc_enc_jeq(elf_ctx, label, label_len); }
  return 0 - 1;
}

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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_jge(elf_ctx, label, label_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_jge(elf_ctx, label, label_len); }
  }
  unsafe { return arch_x86_64_enc_enc_jge(elf_ctx, label, label_len); }
  return 0 - 1;
}

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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_jnz(elf_ctx, label, label_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_jnz(elf_ctx, label, label_len); }
  }
  unsafe { return arch_x86_64_enc_enc_jnz(elf_ctx, label, label_len); }
  return 0 - 1;
}

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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_jne(elf_ctx, label, label_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_jnz(elf_ctx, label, label_len); }
  }
  unsafe { return arch_x86_64_enc_enc_jnz(elf_ctx, label, label_len); }
  return 0 - 1;
}

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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_jmp(elf_ctx, label, label_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_jmp(elf_ctx, label, label_len); }
  }
  unsafe { return arch_x86_64_enc_enc_jmp(elf_ctx, label, label_len); }
  return 0 - 1;
}

/** Exported function `backend_enc_mov_rax_to_arg_reg_arch`.
 * Implements `backend_enc_mov_rax_to_arg_reg_arch`.
 * @param elf_ctx *u8
 * @param k i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k); }
  }
  unsafe { return arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k); }
  return 0 - 1;
}

/** Exported function `backend_enc_rem_mod_arch`.
 * Implements `backend_enc_rem_mod_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rem_mod_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe {
      if (arch_riscv64_enc_enc_cltd(elf_ctx) != 0) {
        return 0 - 1;
      }
      if (arch_riscv64_enc_enc_idiv_rbx(elf_ctx) != 0) {
        return 0 - 1;
      }
      return arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx);
    }
  }
  unsafe {
    if (arch_x86_64_enc_enc_cltd(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (arch_x86_64_enc_enc_idiv_rbx(elf_ctx) != 0) {
      return 0 - 1;
    }
    return arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx);
  }
  return 0 - 1;
}

/**
 * Unsigned integer remainder: dividend in rax/eax, divisor in rbx/ebx → remainder in eax.
 * PLATFORM: SHARED arith / LINUX+MACOS x86_64 emit (arm64/riscv64 stubs).
 * wave322 Cap residual pure: x86_64 must xor edx before div (same as backend_enc_div_rbx_arch).
 * Without xor, garbage edx makes divl #DE (Ubuntu freestanding u32/u64 % → SIGFPE exit 136).
 * Full dispatch already routes through backend_enc_div_rbx_arch; thin is product authority and
 * must emit the same xor+div+mov_edx_to_eax sequence (G.7 complete, no second rem path).
 * @param elf_ctx *u8 — ElfCodegenCtx*
 * @param ta i32 — 0=x86_64, 1=arm64, 2=riscv64
 * @return i32 — 0 success, -1 encode failure
 */
#[no_mangle]
export function backend_enc_rem_mod_unsigned_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe {
      if (arch_riscv64_enc_enc_idiv_rbx(elf_ctx) != 0) {
        return 0 - 1;
      }
      return arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx);
    }
  }
  unsafe {
    /* Zero high half of dividend (edx:eax) before unsigned divl %ebx. */
    if (arch_x86_64_enc_enc_xor_edx_edx(elf_ctx) != 0) {
      return 0 - 1;
    }
    if (arch_x86_64_enc_enc_div_rbx(elf_ctx) != 0) {
      return 0 - 1;
    }
    return arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx);
  }
  return 0 - 1;
}

/** Exported function `backend_enc_call_stack_cleanup_arch`.
 * Implements `backend_enc_call_stack_cleanup_arch`.
 * @param elf_ctx *u8
 * @param nbytes i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_call_stack_cleanup_arch(elf_ctx: *u8, nbytes: i32, ta: i32): i32 {
  if (nbytes <= 0) {
    return 0;
  }
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) {
      return 0 - 1;
    }
    if (nbytes > 4095) {
      unsafe {
        return backend_enc_append_u32_le_c_impl(elf_ctx, 2432697343 | (4095 * 1024));
      }
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, 2432697343 | ((nbytes as u32) * 1024));
    }
    return 0 - 1;
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_add_sp_imm12(elf_ctx, nbytes); }
  }
  unsafe { return arch_x86_64_enc_enc_add_rsp_imm(elf_ctx, nbytes); }
  return 0 - 1;
}

/** Exported function `backend_enc_call_stack_reserve_arch`.
 * Implements `backend_enc_call_stack_reserve_arch`.
 * @param elf_ctx *u8
 * @param nbytes i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_call_stack_reserve_arch(elf_ctx: *u8, nbytes: i32, ta: i32): i32 {
  if (nbytes <= 0) {
    return 0;
  }
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) {
      return 0 - 1;
    }
    if (nbytes > 4095) {
      unsafe {
        return backend_enc_append_u32_le_c_impl(elf_ctx, 3506439167 | (4095 * 1024));
      }
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, 3506439167 | ((nbytes as u32) * 1024));
    }
    return 0 - 1;
  }
  return 0;
}

/** Exported function `backend_enc_store_x0_sp_offset_arch`.
 * Implements `backend_enc_store_x0_sp_offset_arch`.
 * @param elf_ctx *u8
 * @param off_bytes i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_x0_sp_offset_arch(elf_ctx: *u8, off_bytes: i32, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) {
      return 0 - 1;
    }
    if (off_bytes < 0) {
      unsafe {
        return backend_enc_append_u32_le_c_impl(elf_ctx, 4177527776);
      }
      return 0 - 1;
    }
    if (off_bytes / 8 > 4095) {
      unsafe {
        return backend_enc_append_u32_le_c_impl(elf_ctx, 4177527776 | (4095 * 1024));
      }
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, 4177527776 | (((off_bytes / 8) as u32) * 1024));
    }
    return 0 - 1;
  }
  return 0 - 1;
}

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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, reg, offset); }
  }
  return 0 - 1;
}

/** Exported function `backend_enc_load_qword_from_rbx_to_rax_arch`.
 * Implements `backend_enc_load_qword_from_rbx_to_rax_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_qword_from_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_load_qword_rbx8_to_rdx_arch`.
 * Implements `backend_enc_load_qword_rbx8_to_rdx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_store_rdx_to_rbp_arch`.
 * Implements `backend_enc_store_rdx_to_rbp_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx, offset); }
  return 0 - 1;
}

// See implementation.
export extern "C" function arch_riscv64_enc_enc_add_a2_a3(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_add_ecx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_sub_a2_a3(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_sub_ecx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rsub_a2_a3(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_rsub_ecx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rsub_rbx_a3(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_rsub_ebx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_add_rbx_a3(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_add_ebx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_sub_rbx_a3(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_sub_ebx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mul_a2_a3(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_imul_ecx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_mul_rbx_a3(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_imul_ebx_edx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_call(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_rdx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_mov_rdx_to_arg_reg(elf_ctx: *u8, k: i32): i32;
export extern "C" function arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx: *u8, k: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx: *u8, off_pos: i32): i32;
export extern "C" function arch_arm64_enc_enc_rbx_plus_x2_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rbx_plus_a2_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_rbx_plus_x2_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rbx_plus_a2_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_rbx_plus_x2_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_riscv64_enc_enc_rbx_plus_a2_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_eax32(elf_ctx: *u8, offset: i32): i32;
export extern "C" function backend_enc_x86_jcc_rel32_c_impl(elf_ctx: *u8, opcode2: i32, label: *u8, label_len: i32): i32;

/** Exported function `backend_enc_index_scratch_add_secondary_arch`.
 * Implements `backend_enc_index_scratch_add_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_index_scratch_add_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, 184680514); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_add_a2_a3(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_add_ecx_edx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_index_scratch_sub_secondary_arch`.
 * Implements `backend_enc_index_scratch_sub_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_index_scratch_sub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258553410); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_sub_a2_a3(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_sub_ecx_edx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_index_scratch_rsub_secondary_arch`.
 * Implements `backend_enc_index_scratch_rsub_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_index_scratch_rsub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258487906); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_rsub_a2_a3(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_rsub_ecx_edx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_rbx_index_rsub_secondary_arch`.
 * Implements `backend_enc_rbx_index_rsub_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rbx_index_rsub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258422369); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_rsub_rbx_a3(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_rsub_ebx_edx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_rbx_index_add_secondary_arch`.
 * Implements `backend_enc_rbx_index_add_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rbx_index_add_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, 184680481); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_add_rbx_a3(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_add_ebx_edx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_rbx_index_sub_secondary_arch`.
 * Implements `backend_enc_rbx_index_sub_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rbx_index_sub_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, 1258553377); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_sub_rbx_a3(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_sub_ebx_edx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_index_scratch_mul_secondary_arch`.
 * Implements `backend_enc_index_scratch_mul_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_index_scratch_mul_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, 453213250); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_mul_a2_a3(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_imul_ecx_edx(elf_ctx); }
  return 0 - 1;
}

/** Exported function `backend_enc_rbx_index_mul_secondary_arch`.
 * Implements `backend_enc_rbx_index_mul_secondary_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rbx_index_mul_secondary_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, 453213217); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_mul_rbx_a3(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_imul_ebx_edx(elf_ctx); }
  return 0 - 1;
}

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
  if (ta == 1) {
    unsafe { return backend_enc_arm64_call_c_impl(elf_ctx, name, name_len); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_call(elf_ctx, name, name_len); }
  }
  unsafe { return arch_x86_64_enc_enc_call(elf_ctx, name, name_len); }
  return 0 - 1;
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
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_load_rbp_to_rdx(elf_ctx, offset); }
  return 0 - 1;
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
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_mov_rdx_to_arg_reg(elf_ctx, k); }
  return 0 - 1;
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
  if (ta == 0) {
    unsafe { return arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx, k); }
  }
  return 0 - 1;
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
  if (ta == 0) {
    unsafe { return arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx, off_pos); }
  }
  return 0 - 1;
}

/** Exported function `backend_enc_rbx_plus_index_scratch_scaled_arch`.
 * Implements `backend_enc_rbx_plus_index_scratch_scaled_arch`.
 * @param elf_ctx *u8
 * @param esz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_rbx_plus_index_scratch_scaled_arch(elf_ctx: *u8, esz: i32, ta: i32): i32 {
  if (esz == 1) {
    if (ta == 1) {
      unsafe { return arch_arm64_enc_enc_rbx_plus_x2_scale1(elf_ctx); }
    }
    if (ta == 2) {
      unsafe { return arch_riscv64_enc_enc_rbx_plus_a2_scale1(elf_ctx); }
    }
    unsafe { return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(elf_ctx); }
    return 0 - 1;
  }
  if (esz == 4) {
    if (ta == 1) {
      unsafe { return arch_arm64_enc_enc_rbx_plus_x2_scale4(elf_ctx); }
    }
    if (ta == 2) {
      unsafe { return arch_riscv64_enc_enc_rbx_plus_a2_scale4(elf_ctx); }
    }
    unsafe { return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(elf_ctx); }
    return 0 - 1;
  }
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_rbx_plus_x2_scale8(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_rbx_plus_a2_scale8(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(elf_ctx); }
  return 0 - 1;
}

// backend_enc_load_rbp_lane_to_rax_arch: see function docblock below.
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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx, offset); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_load_rbp_to_rax(elf_ctx, offset); }
  }
  if (esz == 4) {
    unsafe { return arch_x86_64_enc_enc_load_rbp_to_eax32(elf_ctx, offset); }
  }
  unsafe { return arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx, offset); }
  return 0 - 1;
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
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return backend_enc_x86_jcc_rel32_c_impl(elf_ctx, 142, label, label_len); }
  return 0 - 1;
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
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return backend_enc_x86_jcc_rel32_c_impl(elf_ctx, 140, label, label_len); }
  return 0 - 1;
}

// See implementation.
export extern "C" function arch_riscv64_enc_enc_add_imm_to_a2(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_enc_enc_add_imm_to_ecx(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_enc_enc_load_rbp_to_a3(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_edx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_sub_imm_from_a2(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_enc_enc_sub_imm_from_ecx(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_enc_enc_mul_imm_to_a2(elf_ctx: *u8, lit: i32): i32;
export extern "C" function arch_x86_64_enc_enc_imul_imm_to_ecx(elf_ctx: *u8, lit: i32): i32;
export extern "C" function arch_riscv64_enc_enc_mul_imm_to_rbx(elf_ctx: *u8, lit: i32): i32;
export extern "C" function arch_x86_64_enc_enc_imul_imm_to_ebx(elf_ctx: *u8, lit: i32): i32;
export extern "C" function arch_x86_64_enc_enc_add_imm_to_ebx_index(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_riscv64_enc_enc_sub_imm_from_rbx_index(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_x86_64_enc_enc_sub_imm_from_ebx_index(elf_ctx: *u8, imm: i32): i32;
export extern "C" function arch_arm64_enc_enc_load_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_riscv64_enc_enc_load_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_rbp_to_ebx32(elf_ctx: *u8, offset: i32): i32;

// arm64 only：LDR x0, [x29, #off]；imm12 = off/8
/** Exported function `backend_enc_load_x29_pos_to_rax_arch`.
 * Implements `backend_enc_load_x29_pos_to_rax_arch`.
 * @param elf_ctx *u8
 * @param off_pos i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_x29_pos_to_rax_arch(elf_ctx: *u8, off_pos: i32, ta: i32): i32 {
  if (ta != 1) {
    return 0 - 1;
  }
  if (off_pos < 0) {
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, 4181722016 as i32);
    }
    return 0 - 1;
  }
  if ((off_pos / 8) > 4095) {
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, (4181722016 | (4095 * 1024)) as i32);
    }
    return 0 - 1;
  }
  unsafe {
    return arch_arm64_enc_enc_u32_le(elf_ctx, (4181722016 | (((off_pos / 8) as u32) * 1024)) as i32);
  }
  return 0 - 1;
}

/** Exported function `backend_enc_add_imm_to_index_scratch_arch`.
 * Implements `backend_enc_add_imm_to_index_scratch_arch`.
 * @param elf_ctx *u8
 * @param imm i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_add_imm_to_index_scratch_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  if (ta == 1) {
    if (imm == 0) {
      return 0;
    }
    if (imm > 4095) {
      unsafe {
        return arch_arm64_enc_enc_u32_le(elf_ctx, (285213762 + ((4095 - 1) * 1024)) as i32);
      }
      return 0 - 1;
    }
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, (285213762 + ((imm - 1) * 1024)) as i32);
    }
    return 0 - 1;
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_add_imm_to_a2(elf_ctx, imm); }
  }
  unsafe { return arch_x86_64_enc_enc_add_imm_to_ecx(elf_ctx, imm); }
  return 0 - 1;
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
  if (ta == 1) {
    if (offset > 256) {
      unsafe {
        return arch_arm64_enc_enc_u32_le(elf_ctx, (3091202048 | (256 * 4096) | 931) as i32);
      }
      return 0 - 1;
    }
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, (3091202048 | ((((0 - offset) & 511) as u32) * 4096) | 931) as i32);
    }
    return 0 - 1;
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_load_rbp_to_a3(elf_ctx, offset); }
  }
  unsafe { return arch_x86_64_enc_enc_load_rbp_to_edx(elf_ctx, offset); }
  return 0 - 1;
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
  if (ta == 1) {
    if (imm == 0) {
      return 0;
    }
    if (imm > 4095) {
      unsafe {
        return arch_arm64_enc_enc_u32_le(elf_ctx, (1358955586 + ((4095 - 1) * 1024)) as i32);
      }
      return 0 - 1;
    }
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, (1358955586 + ((imm - 1) * 1024)) as i32);
    }
    return 0 - 1;
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_sub_imm_from_a2(elf_ctx, imm); }
  }
  unsafe { return arch_x86_64_enc_enc_sub_imm_from_ecx(elf_ctx, imm); }
  return 0 - 1;
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
  if (lit <= 1) {
    return 0;
  }
  if (lit > 65535) {
    return 0 - 1;
  }
  if (ta == 1) {
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (1384120320 | ((lit as u32) * 32) | 3) as i32) != 0) {
        return 0 - 1;
      }
      return arch_arm64_enc_enc_u32_le(elf_ctx, 453213250);
    }
    return 0 - 1;
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_mul_imm_to_a2(elf_ctx, lit); }
  }
  unsafe { return arch_x86_64_enc_enc_imul_imm_to_ecx(elf_ctx, lit); }
  return 0 - 1;
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
  if (lit <= 1) {
    return 0;
  }
  if (lit > 65535) {
    return 0 - 1;
  }
  if (ta == 1) {
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (1384120320 | ((lit as u32) * 32) | 3) as i32) != 0) {
        return 0 - 1;
      }
      return arch_arm64_enc_enc_u32_le(elf_ctx, 453213217);
    }
    return 0 - 1;
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_mul_imm_to_rbx(elf_ctx, lit); }
  }
  unsafe { return arch_x86_64_enc_enc_imul_imm_to_ebx(elf_ctx, lit); }
  return 0 - 1;
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
  if (imm == 0) {
    return 0;
  }
  if (ta == 1) {
    if (imm > 4095) {
      unsafe {
        return arch_arm64_enc_enc_u32_le(elf_ctx, (285213729 + ((4095 - 1) * 1024)) as i32);
      }
      return 0 - 1;
    }
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, (285213729 + ((imm - 1) * 1024)) as i32);
    }
    return 0 - 1;
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx, imm); }
  }
  unsafe { return arch_x86_64_enc_enc_add_imm_to_ebx_index(elf_ctx, imm); }
  return 0 - 1;
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
  if (imm == 0) {
    return 0;
  }
  if (ta == 1) {
    if (imm > 4095) {
      unsafe {
        return arch_arm64_enc_enc_u32_le(elf_ctx, (1358955553 + ((4095 - 1) * 1024)) as i32);
      }
      return 0 - 1;
    }
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, (1358955553 + ((imm - 1) * 1024)) as i32);
    }
    return 0 - 1;
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_sub_imm_from_rbx_index(elf_ctx, imm); }
  }
  unsafe { return arch_x86_64_enc_enc_sub_imm_from_ebx_index(elf_ctx, imm); }
  return 0 - 1;
}

/** Exported function `backend_enc_load_rbp_to_rbx_arch`.
 * Implements `backend_enc_load_rbp_to_rbx_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_load_rbp_to_rbx(elf_ctx, offset); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_load_rbp_to_rbx(elf_ctx, offset); }
  }
  unsafe { return arch_x86_64_enc_enc_load_rbp_to_rbx(elf_ctx, offset); }
  return 0 - 1;
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
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_load_rbp_to_rbx(elf_ctx, offset); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_load_rbp_to_rbx(elf_ctx, offset); }
  }
  if (esz == 4) {
    unsafe { return arch_x86_64_enc_enc_load_rbp_to_ebx32(elf_ctx, offset); }
  }
  unsafe { return arch_x86_64_enc_enc_load_rbp_to_rbx(elf_ctx, offset); }
  return 0 - 1;
}

// backend_enc_addss_rax_rbx_arch: see function docblock below.

/** Exported function `backend_enc_addss_rax_rbx_arch`.
 * Implements `backend_enc_addss_rax_rbx_arch`.
 * @param elf_ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_addss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3228438374) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3412987750) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3243773939) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, 3229486950);
  }
  return 0 - 1;
}

/**
 * Scalar f32 multiply (mulss); thin u32 LE twin of full seed.
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `*` (wave294 Cap residual pure).
 * Encoding mirror of addss with mulss opcode F3 0F 59 C1
 * (u32 le 0xc1590ff3 = 3243839475; addss is 0xc1580ff3 = 3243773939).
 */
#[no_mangle]
export function backend_enc_mulss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movd xmm0,eax: 66 0f 6e c0 → 3228438374 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3228438374) != 0) {
      return 0 - 1;
    }
    /* movd xmm1,ebx: 66 0f 6e cb → 3412987750 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3412987750) != 0) {
      return 0 - 1;
    }
    /* mulss xmm0,xmm1: f3 0f 59 c1 → 3243839475 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3243839475) != 0) {
      return 0 - 1;
    }
    /* movd eax,xmm0: 66 0f 7e c0 → 3229486950 */
    return backend_enc_append_u32_le_c_impl(elf_ctx, 3229486950);
  }
  return 0 - 1;
}

/**
 * Scalar f32 sub left=rbx right=rax (subss); thin u32 LE twin.
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `-` (wave298 Cap residual pure).
 * Encoding: movd xmm0,ebx; movd xmm1,eax; subss F3 0F 5C C1 (u32 le 3244036083); movd eax,xmm0.
 */
#[no_mangle]
export function backend_enc_subss_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movd xmm0,ebx: 66 0f 6e c3 → 3278770022 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3278770022) != 0) {
      return 0 - 1;
    }
    /* movd xmm1,eax: 66 0f 6e c8 → 3362656102 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3362656102) != 0) {
      return 0 - 1;
    }
    /* subss xmm0,xmm1: f3 0f 5c c1 → 3244036083 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3244036083) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, 3229486950);
  }
  return 0 - 1;
}

/**
 * Scalar f32 sub left=rax right=rbx (subss); thin u32 LE twin.
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `-` (wave298 Cap residual pure).
 */
#[no_mangle]
export function backend_enc_subss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3228438374) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3412987750) != 0) {
      return 0 - 1;
    }
    /* subss f3 0f 5c c1 → 3244036083 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3244036083) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, 3229486950);
  }
  return 0 - 1;
}

/**
 * Scalar f32 div left=rax right=rbx (divss); thin u32 LE twin.
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `/` (wave298 Cap residual pure).
 * Encoding mirror of mulss with divss opcode F3 0F 5E C1 (u32 le 3244167155).
 */
#[no_mangle]
export function backend_enc_divss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3228438374) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3412987750) != 0) {
      return 0 - 1;
    }
    /* divss xmm0,xmm1: f3 0f 5e c1 → 3244167155 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3244167155) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, 3229486950);
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
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3228438374) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, 3224113139);
  }
  return 0 - 1;
}

/**
 * Truncate f64 bits in rax to i32 in eax (cvttsd2si).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f64 `as i32` (wave291 Cap residual).
 */
#[no_mangle]
export function backend_enc_cvttsd2si_eax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movq xmm0,rax: 66 48 0f 6e + c0 (same lead as cvtsd2ss). */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 1846495334) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) {
      return 0 - 1;
    }
    /* cvttsd2si eax,xmm0: f2 0f 2c c0 → u32 le 0xc02c0ff2 = 3224113138 */
    return backend_enc_append_u32_le_c_impl(elf_ctx, 3224113138);
  }
  return 0 - 1;
}

/**
 * Truncate f32 bits in eax to i64 in rax (REX.W cvttss2si).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `as i64/u64` (wave303 Cap residual).
 * Encoding: movd xmm0,eax; cvttss2si rax,xmm0 F3 48 0F 2C C0.
 * thin first4 u32 le of F3 48 0F 2C = 0x2c0f48f3 = 739199219 (exact; do not miscompute).
 */
#[no_mangle]
export function backend_enc_cvttss2si_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movd xmm0,eax: 66 0f 6e c0 → 3228438374 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3228438374) != 0) {
      return 0 - 1;
    }
    /* cvttss2si rax,xmm0: f3 48 0f 2c → u32 le 0x2c0f48f3 = 739199219 ; + c0 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 739199219) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, 192);
  }
  return 0 - 1;
}

/**
 * Truncate f64 bits in rax to i64 in rax (REX.W cvttsd2si).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f64 `as i64/u64` (wave303 Cap residual).
 * Encoding: movq xmm0,rax; cvttsd2si rax,xmm0 F2 48 0F 2C C0.
 * thin first4 u32 le of F2 48 0F 2C = 0x2c0f48f2 = 739199218 (exact; do not miscompute).
 */
#[no_mangle]
export function backend_enc_cvttsd2si_rax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movq xmm0,rax: 66 48 0f 6e + c0 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 1846495334) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) {
      return 0 - 1;
    }
    /* cvttsd2si rax,xmm0: f2 48 0f 2c → u32 le 0x2c0f48f2 = 739199218 ; + c0 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 739199218) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, 192);
  }
  return 0 - 1;
}

/**
 * Convert full-range u64 in rax to f64 bits in rax (unsigned convert sequence).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding u64/usize `as f64` (wave304 Cap residual).
 * thin twin of seed seq (43 bytes; jns +28, jmp +10). Uses append_u8 for fixed blob.
 */
#[no_mangle]
export function backend_enc_cvtsi2sd_rax_from_u64_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* 43-byte unsigned seq; thin path uses append_u8 (no pipeline_elf_ctx). */
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 133) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 121) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 28) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 137) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 194) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 209) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 234) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 131) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 224) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 1) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 9) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 194) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 242) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 42) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 194) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 242) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 88) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 102) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 126) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 235) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 10) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 242) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 42) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 102) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 126) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c_impl(elf_ctx, 192);
  }
  return 0 - 1;
}

/**
 * Convert full-range u64 in rax to f32 bits in eax (unsigned convert sequence).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding u64/usize `as f32` (wave304 Cap residual).
 * thin twin of seed seq (41 bytes; jns +27, jmp +9).
 */
#[no_mangle]
export function backend_enc_cvtsi2ss_eax_from_u64_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 133) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 121) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 27) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 137) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 194) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 209) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 234) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 131) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 224) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 1) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 9) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 194) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 243) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 42) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 194) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 243) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 88) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 102) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 126) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 235) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 9) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 243) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 72) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 42) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 102) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, 126) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c_impl(elf_ctx, 192);
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
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 1846495334) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3227127794) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, 3229486950);
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
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3223982067) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, 3229486950);
  }
  return 0 - 1;
}

/**
 * Convert i64/u64 (value in i64 range) in rax to f32 bits in eax (REX.W cvtsi2ss).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding u64/i64 `as f32` (wave299 Cap residual).
 * Encoding: cvtsi2ss xmm0,rax F3 48 0F 2A C0; movd eax,xmm0 66 0F 7E C0.
 * thin first4 u32 le of F3 48 0F 2A = 0x2a0f48f3 = 705644787 (exact; do not miscompute).
 */
#[no_mangle]
export function backend_enc_cvtsi2ss_eax_from_i64_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* cvtsi2ss xmm0,rax: f3 48 0f 2a → u32 le 0x2a0f48f3 = 705644787 ; + c0 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 705644787) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) {
      return 0 - 1;
    }
    /* movd eax,xmm0: 66 0f 7e c0 = 0xc07e0f66 = 3229486950 */
    return backend_enc_append_u32_le_c_impl(elf_ctx, 3229486950);
  }
  return 0 - 1;
}

/**
 * Convert i32 in eax to f64 bits in rax (cvtsi2sd).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding i32 `as f64` (wave292 Cap residual).
 */
#[no_mangle]
export function backend_enc_cvtsi2sd_rax_from_i32_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* cvtsi2sd xmm0,eax: f2 0f 2a c0 → u32 le 0xc02a0ff2 = 3223982066
     * (same family as cvtsi2ss F3… = 3223982067; do not miscompute decimal). */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3223982066) != 0) {
      return 0 - 1;
    }
    /* movq rax,xmm0: 66 48 0f 7e + c0 → first4 u32 le 0x7e0f4866 = 2114930790 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 2114930790) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, 192);
  }
  return 0 - 1;
}

/**
 * Convert i64/u64 (value in i64 range) in rax to f64 bits in rax (REX.W cvtsi2sd).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding u64/i64 `as f64` (wave295 Cap residual).
 * Encoding: cvtsi2sd xmm0,rax F2 48 0F 2A C0; movq rax,xmm0 66 REX.W 0F 7E C0.
 * thin first4 u32 le of F2 48 0F 2A = 0x2a0f48f2 = 705644786 (exact; do not miscompute).
 */
#[no_mangle]
export function backend_enc_cvtsi2sd_rax_from_i64_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* cvtsi2sd xmm0,rax: f2 48 0f 2a → u32 le 0x2a0f48f2 = 705644786 ; + c0 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 705644786) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, 192) != 0) {
      return 0 - 1;
    }
    /* movq rax,xmm0: 66 48 0f 7e + c0 → first4 = 2114930790 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 2114930790) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, 192);
  }
  return 0 - 1;
}

/**
 * Convert f32 bits in eax to f64 bits in rax (cvtss2sd).
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `as f64` (wave293 Cap residual).
 */
#[no_mangle]
export function backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movd xmm0,eax: 66 0f 6e c0 → u32 le 0xc06e0f66 = 3228438374 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3228438374) != 0) {
      return 0 - 1;
    }
    /* cvtss2sd xmm0,xmm0: f3 0f 5a c0 → u32 le 0xc05a0ff3 = 3227127795
     * (cvtsd2ss is f2… = 3227127794; keep exact decimal). */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 3227127795) != 0) {
      return 0 - 1;
    }
    /* movq rax,xmm0: 66 48 0f 7e + c0 → first4 = 2114930790 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, 2114930790) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, 192);
  }
  return 0 - 1;
}

// movd xmmK, eax：66 0F 6E /r ；modrm = C0 | (k<<3)
/** Exported function `backend_enc_mov_eax_to_xmm_arg_reg_arch`.
 * Implements `backend_enc_mov_eax_to_xmm_arg_reg_arch`.
 * @param elf_ctx *u8
 * @param k i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (k < 0) {
    return 0 - 1;
  }
  if (k > 7) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u8_c_impl(elf_ctx, 102) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, 110) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, 192 + (k * 8));
  }
  return 0 - 1;
}

// movd eax, xmmK：66 0F 7E /r
/** Exported function `backend_enc_mov_xmm_arg_reg_to_eax_arch`.
 * Implements `backend_enc_mov_xmm_arg_reg_to_eax_arch`.
 * @param elf_ctx *u8
 * @param k i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_mov_xmm_arg_reg_to_eax_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (k < 0) {
    return 0 - 1;
  }
  if (k > 7) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u8_c_impl(elf_ctx, 102) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, 15) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, 126) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, 192 + (k * 8));
  }
  return 0 - 1;
}

// backend_enc_store_eax_to_rbp_arch: see function docblock below.
/** Exported function `backend_enc_store_eax_to_rbp_arch`.
 * Implements `backend_enc_store_eax_to_rbp_arch`.
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_store_eax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) {
      return 0 - 1;
    }
    if (offset < 0) {
      return 0 - 1;
    }
    if (offset > 256) {
      unsafe {
        return arch_arm64_enc_enc_u32_le(elf_ctx, (3087007744 | (256 * 4096) | 928) as i32);
      }
      return 0 - 1;
    }
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, (3087007744 | ((((0 - offset) & 511) as u32) * 4096) | 928) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  // See implementation.
  unsafe {
    if (backend_enc_append_u8_c_impl(elf_ctx, 137) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, 133) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((0 - offset) as u32) & 255) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, (((0 - offset) as u32) / 256) & 255) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, (((0 - offset) as u32) / 65536) & 255) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, (((0 - offset) as u32) / 16777216) & 255);
  }
  return 0 - 1;
}

// ---- G-02f-419：append/call/jcc/cdqe → seed impl pure forward ----
/** Exported function `backend_enc_append_u32_le_c`.
 * Implements `backend_enc_append_u32_le_c`.
 * @param elf_ctx *u8
 * @param word u32
 * @return i32
 */
#[no_mangle]
export function backend_enc_append_u32_le_c(elf_ctx: *u8, word: u32): i32 {
  unsafe { return backend_enc_append_u32_le_c_impl(elf_ctx, word); }
  return 0 - 1;
}

/** Exported function `backend_enc_append_u8_c`.
 * Implements `backend_enc_append_u8_c`.
 * @param elf_ctx *u8
 * @param byte i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_append_u8_c(elf_ctx: *u8, byte: i32): i32 {
  unsafe { return backend_enc_append_u8_c_impl(elf_ctx, byte); }
  return 0 - 1;
}

/** Exported function `backend_enc_arm64_call_c`.
 * Implements `backend_enc_arm64_call_c`.
 * @param elf_ctx *u8
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_arm64_call_c(elf_ctx: *u8, name: *u8, name_len: i32): i32 {
  unsafe { return backend_enc_arm64_call_c_impl(elf_ctx, name, name_len); }
  return 0 - 1;
}

/** Exported function `backend_enc_x86_jcc_rel32_c`.
 * Implements `backend_enc_x86_jcc_rel32_c`.
 * @param elf_ctx *u8
 * @param opcode2 i32
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
#[no_mangle]
export function backend_enc_x86_jcc_rel32_c(elf_ctx: *u8, opcode2: i32, label: *u8, label_len: i32): i32 {
  unsafe { return backend_enc_x86_jcc_rel32_c_impl(elf_ctx, opcode2, label, label_len); }
  return 0 - 1;
}

/** Exported function `arch_x86_64_enc_enc_cdqe_rax`.
 * Implements `arch_x86_64_enc_enc_cdqe_rax`.
 * @param elf_ctx *u8
 * @return i32
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cdqe_rax(elf_ctx: *u8): i32 {
  unsafe { return arch_x86_64_enc_enc_cdqe_rax_impl(elf_ctx); }
  return 0 - 1;
}
