// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-352/353/354：backend_enc_dispatch L2 thin — arm64 encode + ta 分派壳（5+8=13）。
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
