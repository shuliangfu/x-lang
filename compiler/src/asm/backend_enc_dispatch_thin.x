// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-352～361/419：backend_enc_dispatch R2 thin full — arm64 encode + ta 分派壳（120 公共面）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_ENC_DISPATCH_THIN_FROM_X）ld -r → backend_enc_dispatch.o
// Prove IDENTICAL：seeds/backend_enc_dispatch_thin_surface.from_x.c（本 thin 公共面；_impl 仍 U）
// Cap residual：*_impl / enc C 尾仍在 full seed rest。
// 对照：src/asm/backend_enc_dispatch.x；冷启动 full seed rest。
//
// SP：ADD/SUB 0x910003ff/0xd10003ff / STR 0xf90003e0；imm12 占 [21:10]。
// RBP lane：LDUR 0xB8400000 / STUR 0xB8000000 + simm9 + Rn=x29。
// -E 大立即数可能写成有符号同比特，传 append/u32_le 仍正确。
//

export extern "C" function backend_enc_append_u32_le_c_impl(elf_ctx: *u8, word: u32): i32;
export extern "C" function backend_enc_append_u8_c_impl(elf_ctx: *u8, byte: i32): i32;
export extern "C" function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, val: i32): i32;
export extern "C" function backend_enc_arm64_call_c_impl(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_call_impl(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern "C" function arch_riscv64_enc_enc_mov_rax_to_arg_reg_impl(elf_ctx: *u8, k: i32): i32;

// ADD X31, X31, #imm12  （SP+imm）
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

// LDUR w0, [x29, #-offset]（offset>256 钳到 simm9=-256）
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

#[no_mangle]
export function arch_arm64_enc_enc_add_sp_imm12(elf_ctx: *u8, imm: i32): i32 {
  return backend_enc_arm64_add_sp_imm12_c(elf_ctx, imm);
}

#[no_mangle]
export function arch_arm64_enc_enc_sub_sp_imm12(elf_ctx: *u8, imm: i32): i32 {
  return backend_enc_arm64_sub_sp_imm12_c(elf_ctx, imm);
}

#[no_mangle]
export function arch_arm64_enc_enc_str_x0_sp_offset(elf_ctx: *u8, off_bytes: i32): i32 {
  return backend_enc_arm64_str_x0_sp_offset_c(elf_ctx, off_bytes);
}

#[no_mangle]
export function arch_arm64_enc_enc_call(elf_ctx: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    return backend_enc_arm64_call_c_impl(elf_ctx, name, name_len);
  }
  return 0 - 1;
}

#[no_mangle]
export function arch_riscv64_enc_enc_call(elf_ctx: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    return arch_riscv64_enc_enc_call_impl(elf_ctx, name, name_len);
  }
  return 0 - 1;
}

#[no_mangle]
export function arch_riscv64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32 {
  unsafe {
    return arch_riscv64_enc_enc_mov_rax_to_arg_reg_impl(elf_ctx, k);
  }
  return 0 - 1;
}

// ---- G-02f-354：ta 分派壳（push/pop/epilogue/add/sub/imul）----
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

#[no_mangle]
// seed：riscv ta==2 返回 -1（无 arch_riscv64_enc_enc_sub_rax_rbx 符号）
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

// ---- G-02f-355：ta 分派壳 batch2（mov/logic/test/cltd/neg）----
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

// ---- G-02f-356：ta 分派壳 batch3（shift/cmp/idiv）----
export extern "C" function arch_arm64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
export extern "C" function arch_arm64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
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

#[no_mangle]
export function backend_enc_shl_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_shl_cl_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_shl_cl_rax(elf_ctx); }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_shr_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_shr_cl_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_shr_cl_rax(elf_ctx); }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_sar_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_sar_cl_eax(elf_ctx); }
  }
  if (ta == 2) {
    unsafe { return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx); }
  }
  unsafe { return arch_x86_64_enc_enc_sar_cl_rax(elf_ctx); }
  return 0 - 1;
}

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

// ---- G-02f-357：ta 分派壳 batch4（imm/lea/scale/label）----
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

// ---- G-02f-358：ta 分派壳 batch5（rem/load64/store ind/jcc/call-stack）----
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
    if (arch_x86_64_enc_enc_div_rbx(elf_ctx) != 0) {
      return 0 - 1;
    }
    return arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx);
  }
  return 0 - 1;
}

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

#[no_mangle]
export function backend_enc_store_x_reg_to_rbp_arch(elf_ctx: *u8, reg: i32, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, reg, offset); }
  }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_load_qword_from_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx); }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx); }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx, offset); }
  return 0 - 1;
}

// ---- G-02f-359：ta 分派壳 batch6（index secondary / call / x86 arg / scale / lane / jle jl）----
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

#[no_mangle]
export function backend_enc_load_rbp_to_rdx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_load_rbp_to_rdx(elf_ctx, offset); }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_mov_rdx_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_mov_rdx_to_arg_reg(elf_ctx, k); }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_mov_arg_reg_to_rax_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta == 0) {
    unsafe { return arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx, k); }
  }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_load_rbp_pos_to_rax_arch(elf_ctx: *u8, off_pos: i32, ta: i32): i32 {
  if (ta == 0) {
    unsafe { return arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx, off_pos); }
  }
  return 0 - 1;
}

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

// f-359 load_rbp_lane（esz==4 优先 x86 eax32；arm64 暂走 64 路 arch）
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

#[no_mangle]
export function backend_enc_jle_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return backend_enc_x86_jcc_rel32_c_impl(elf_ctx, 142, label, label_len); }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_jl_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return backend_enc_x86_jcc_rel32_c_impl(elf_ctx, 140, label, label_len); }
  return 0 - 1;
}

// ---- G-02f-360：ta 分派壳 batch7（index imm / x29 pos / load_rbp_to_rbx / lane_rbx）----
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

// ---- G-02f-361：f32/xmm + store_eax（无 static 数组；append_u32/u8）----

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

// movd xmmK, eax：66 0F 6E /r ；modrm = C0 | (k<<3)
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

// arm64：STUR w0 内联；x86：movl %eax, -off(%rbp)
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
  // x86 always disp32：89 85 + disp LE（语义同 seed disp32 路，小 offset 也可）
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
#[no_mangle]
export function backend_enc_append_u32_le_c(elf_ctx: *u8, word: u32): i32 {
  unsafe { return backend_enc_append_u32_le_c_impl(elf_ctx, word); }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_append_u8_c(elf_ctx: *u8, byte: i32): i32 {
  unsafe { return backend_enc_append_u8_c_impl(elf_ctx, byte); }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_arm64_call_c(elf_ctx: *u8, name: *u8, name_len: i32): i32 {
  unsafe { return backend_enc_arm64_call_c_impl(elf_ctx, name, name_len); }
  return 0 - 1;
}

#[no_mangle]
export function backend_enc_x86_jcc_rel32_c(elf_ctx: *u8, opcode2: i32, label: *u8, label_len: i32): i32 {
  unsafe { return backend_enc_x86_jcc_rel32_c_impl(elf_ctx, opcode2, label, label_len); }
  return 0 - 1;
}

#[no_mangle]
export function arch_x86_64_enc_enc_cdqe_rax(elf_ctx: *u8): i32 {
  unsafe { return arch_x86_64_enc_enc_cdqe_rax_impl(elf_ctx); }
  return 0 - 1;
}
