// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-352～358：backend_enc_dispatch L2 thin — arm64 encode + ta 分派壳（52+23=75）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_ENC_DISPATCH_THIN_FROM_X）ld -r
//   → backend_enc_dispatch.o
// 对照：src/asm/backend_enc_dispatch.x；默认仍整 seed。
//
// SP：ADD/SUB 0x910003ff/0xd10003ff / STR 0xf90003e0；imm12 占 [21:10]。
// RBP lane：LDUR 0xB8400000 / STUR 0xB8000000 + simm9 + Rn=x29。
// -E 大立即数可能写成有符号同比特，传 append/u32_le 仍正确。
//

extern "C" function backend_enc_append_u32_le_c(elf_ctx: *u8, word: u32): i32;
extern "C" function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, val: i32): i32;

// ADD X31, X31, #imm12  （SP+imm）
#[no_mangle]
function backend_enc_arm64_add_sp_imm12_c(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (imm <= 0) {
    return 0;
  }
  if (imm > 4095) {
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 2432697343 | (4095 * 1024));
    }
    return 0 - 1;
  }
  unsafe {
    return backend_enc_append_u32_le_c(elf_ctx, 2432697343 | ((imm as u32) * 1024));
  }
  return 0 - 1;
}

// SUB X31, X31, #imm12
#[no_mangle]
function backend_enc_arm64_sub_sp_imm12_c(elf_ctx: *u8, imm: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (imm <= 0) {
    return 0;
  }
  if (imm > 4095) {
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 3506439167 | (4095 * 1024));
    }
    return 0 - 1;
  }
  unsafe {
    return backend_enc_append_u32_le_c(elf_ctx, 3506439167 | ((imm as u32) * 1024));
  }
  return 0 - 1;
}

// STR X0, [SP, #imm12*8]
#[no_mangle]
function backend_enc_arm64_str_x0_sp_offset_c(elf_ctx: *u8, off_bytes: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (off_bytes < 0) {
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 4177527776);
    }
    return 0 - 1;
  }
  if (off_bytes / 8 > 4095) {
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 4177527776 | (4095 * 1024));
    }
    return 0 - 1;
  }
  unsafe {
    return backend_enc_append_u32_le_c(elf_ctx, 4177527776 | (((off_bytes / 8) as u32) * 1024));
  }
  return 0 - 1;
}

// LDUR w0, [x29, #-offset]（offset>256 钳到 simm9=-256）
#[no_mangle]
function arm64_enc_load_w0_from_rbp_c(elf_ctx: *u8, offset: i32): i32 {
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
function arm64_enc_store_w0_to_rbp_c(elf_ctx: *u8, offset: i32): i32 {
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

// ---- G-02f-354：ta 分派壳（push/pop/epilogue/add/sub/imul）----
extern "C" function arch_arm64_enc_enc_push_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_push_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_push_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_push_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_push_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_push_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_pop_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_pop_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_pop_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_pop_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_epilogue(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_epilogue(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_epilogue(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_sub_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_sub_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32;

#[no_mangle]
function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_push_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_epilogue_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_add_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_sub_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_imul_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
extern "C" function arch_arm64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_not_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_not_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_not_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_cltd(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_cltd(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_cltd(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_neg_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_neg_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_neg_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_test_eax_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32;

#[no_mangle]
function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_and_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_or_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_xor_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_mov_rbx_to_ecx_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_cltd_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_test_eax_eax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_test_rbx_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
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
extern "C" function arch_arm64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_div_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_idiv_rbx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_sar_cl_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_shl_cl_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_shr_cl_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_xor_edx_edx(elf_ctx: *u8): i32;

#[no_mangle]
function backend_enc_shl_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_shr_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_sar_cl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_mov_edx_to_eax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_setz_movzbl_eax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_cmp_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_shl_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_shr_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_sar_cl_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_cmp_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_idiv_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_div_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
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
extern "C" function arch_arm64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_arm64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_arm64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
extern "C" function arch_arm64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
extern "C" function arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_arm64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_arm64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
extern "C" function arch_arm64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_riscv64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
extern "C" function arch_riscv64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
extern "C" function arch_riscv64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_riscv64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
extern "C" function arch_riscv64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_riscv64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32;
extern "C" function arch_x86_64_enc_enc_cmp_setcc_movzbl(elf_ctx: *u8, cc: i32): i32;
extern "C" function arch_x86_64_enc_enc_label(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32): i32;
extern "C" function arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32;
extern "C" function arch_x86_64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32;
extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32;
extern "C" function arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32;

#[no_mangle]
function backend_enc_prologue_arch(elf_ctx: *u8, frame_sz: i32, ta: i32): i32 {
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
function backend_enc_ret_imm32_arch(elf_ctx: *u8, imm32: i32, ta: i32): i32 {
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
function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm32: i32, ta: i32): i32 {
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
function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32 {
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
function backend_enc_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32 {
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
function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
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
function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
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
function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
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
function backend_enc_lea_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
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
function backend_enc_rax_plus_rbx_scale1_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_rax_plus_rbx_scale4_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_rax_plus_rbx_scale8_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
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
function backend_enc_add_imm_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
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
function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32, ta: i32): i32 {
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
extern "C" function arch_arm64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
extern "C" function arch_riscv64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
extern "C" function arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32;
extern "C" function arch_arm64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_cdqe_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_riscv64_enc_enc_load_rbp_to_a2(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx: *u8, offset: i32): i32;
extern "C" function arch_arm64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
extern "C" function arch_riscv64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
extern "C" function arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32;
extern "C" function arch_arm64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
extern "C" function arch_riscv64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32;
extern "C" function arch_arm64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_enc_enc_jz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_enc_enc_jeq(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_enc_enc_jge(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_enc_enc_jnz(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_jne(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_riscv64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_x86_64_enc_enc_jmp(elf_ctx: *u8, label: *u8, label_len: i32): i32;
extern "C" function arch_arm64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
extern "C" function arch_riscv64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
extern "C" function arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
extern "C" function arch_riscv64_enc_enc_add_sp_imm12(elf_ctx: *u8, nbytes: i32): i32;
extern "C" function arch_x86_64_enc_enc_add_rsp_imm(elf_ctx: *u8, nbytes: i32): i32;
extern "C" function arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx: *u8, reg: i32, offset: i32): i32;
extern "C" function arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx: *u8): i32;
extern "C" function arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx: *u8, offset: i32): i32;

#[no_mangle]
function backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx: *u8, elem_sz: i32, ta: i32): i32 {
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
function backend_enc_load_32_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
    return arch_x86_64_enc_enc_cdqe_rax(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
    return arch_x86_64_enc_enc_cdqe_rax(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_load_rbp_index_scratch_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
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
function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, offset: i32, store_size: i32, ta: i32): i32 {
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
function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_jz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
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
function backend_enc_jeq_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
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
function backend_enc_jge_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
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
function backend_enc_jnz_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
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
function backend_enc_jne_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
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
function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32 {
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
function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
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
function backend_enc_rem_mod_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_rem_mod_unsigned_arch(elf_ctx: *u8, ta: i32): i32 {
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
function backend_enc_call_stack_cleanup_arch(elf_ctx: *u8, nbytes: i32, ta: i32): i32 {
  if (nbytes <= 0) {
    return 0;
  }
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) {
      return 0 - 1;
    }
    if (nbytes > 4095) {
      unsafe {
        return backend_enc_append_u32_le_c(elf_ctx, 2432697343 | (4095 * 1024));
      }
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 2432697343 | ((nbytes as u32) * 1024));
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
function backend_enc_call_stack_reserve_arch(elf_ctx: *u8, nbytes: i32, ta: i32): i32 {
  if (nbytes <= 0) {
    return 0;
  }
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) {
      return 0 - 1;
    }
    if (nbytes > 4095) {
      unsafe {
        return backend_enc_append_u32_le_c(elf_ctx, 3506439167 | (4095 * 1024));
      }
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 3506439167 | ((nbytes as u32) * 1024));
    }
    return 0 - 1;
  }
  return 0;
}

#[no_mangle]
function backend_enc_store_x0_sp_offset_arch(elf_ctx: *u8, off_bytes: i32, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) {
      return 0 - 1;
    }
    if (off_bytes < 0) {
      unsafe {
        return backend_enc_append_u32_le_c(elf_ctx, 4177527776);
      }
      return 0 - 1;
    }
    if (off_bytes / 8 > 4095) {
      unsafe {
        return backend_enc_append_u32_le_c(elf_ctx, 4177527776 | (4095 * 1024));
      }
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 4177527776 | (((off_bytes / 8) as u32) * 1024));
    }
    return 0 - 1;
  }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_store_x_reg_to_rbp_arch(elf_ctx: *u8, reg: i32, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, reg, offset); }
  }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_load_qword_from_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx); }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx); }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx, offset); }
  return 0 - 1;
}
