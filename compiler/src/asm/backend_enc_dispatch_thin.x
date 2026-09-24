// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Thin enc publics for backend_enc_dispatch.o.
// w854 deleted the C bodies of these functions. w862 also places
// backend_enc_dispatch_slice_marker here. The marker returns 1.
// w877 places arch_arm64_enc_enc_blr here. It forwards to
// backend_enc_arm64_blr_c. w891 places that callee here too.
// Both symbols stay strong.
// w878 places arch_arm64_enc_enc_ldr_xreg_xreg_imm here. It forwards to
// backend_enc_arm64_ldr_xreg_xreg_imm_c. w895 places that callee here too.
// Both symbols stay strong.
// w879 places arch_x86_64_enc_enc_call_reg here. It forwards to
// backend_enc_x86_64_call_reg_c. w893 places that callee here too.
// Both symbols stay strong.
// w880 places arch_x86_64_enc_enc_load_rax_rbx_disp32 here. It forwards to
// backend_enc_x86_64_load_rax_rbx_disp32_c. w896 places that callee here too.
// Both symbols stay strong.
// w881 places arch_riscv64_enc_enc_jalr_reg here. It forwards to
// backend_enc_riscv64_jalr_reg_c. w892 places that callee here too.
// Both symbols stay strong.
// w882 places arch_riscv64_enc_enc_ldr_xreg_xreg_imm here. It forwards to
// backend_enc_riscv64_ldr_xreg_xreg_imm_c. w894 places that callee here too.
// Both symbols stay strong.
// w883 places arch_x86_64_enc_enc_cdqe_rax_impl here. It appends the
// x86_64 cdqe bytes 0x48 0x98. The symbol stays strong.
// w884 places backend_enc_append_u8_c_impl here. It appends the low
// 8 bits of one byte. The symbol stays strong.
// w885 places backend_enc_append_u32_le_c_impl here. It appends four
// little-endian bytes of one word. The symbol stays strong.
// w891 places backend_enc_arm64_blr_c here. It appends one ARM64 blr
// instruction word. The symbol stays strong.
// w892 places backend_enc_riscv64_jalr_reg_c here. It appends one
// RISC-V jalr instruction word. The symbol stays strong.
// w893 places backend_enc_x86_64_call_reg_c here. It appends an
// x86_64 indirect call. The symbol stays strong.
// w894 places backend_enc_riscv64_ldr_xreg_xreg_imm_c here. It appends
// one RISC-V ld instruction word. The symbol stays strong.
// w895 places backend_enc_arm64_ldr_xreg_xreg_imm_c here. It appends
// one ARM64 ldr instruction word. The symbol stays strong.
// w896 places backend_enc_x86_64_load_rax_rbx_disp32_c here. It appends
// one x86_64 mov rDst, [rBase+disp32]. The symbol stays strong.
// w897 places backend_enc_addsd_rax_rbx_arch here. It appends one
// scalar f64 add. The symbol stays strong.
// w898 places backend_enc_subsd_rbx_rax_arch here. It appends one
// scalar f64 subtract of rax from rbx. The symbol stays strong.
// w899 places backend_enc_subsd_rax_rbx_arch here. It appends one
// scalar f64 subtract of rbx from rax. The symbol stays strong.
// w900 places backend_enc_mulsd_rax_rbx_arch here. It appends one
// scalar f64 multiply. The symbol stays strong.
// w901 places backend_enc_divsd_rax_rbx_arch here. It appends one
// scalar f64 divide of rax by rbx. The symbol stays strong.
// w902 places backend_enc_ucomisd_rbx_rax_arch here. It appends one
// scalar f64 compare of rbx against rax. The symbol stays strong.
// w903 places four encoders here. ucomiss compares f32 bits in rbx and rax.
// mov_rax_to_xmm and mov_xmm_to_rax move f64 bits for arg register k.
// fp_cmp_setcc_movzbl turns the compare flags into 0 or 1. All stay strong.
// w904 places two ta dispatchers here. store_arg_sp_offset forwards ARM64
// to backend_enc_arm64_store_arg_sp_offset_c and returns -1 for other ta.
// blr forwards ta 1/2/else to the ARM64, RISC-V, and x86_64 indirect-call
// callees already in this file. Both stay strong.
// w905 places backend_enc_ldr_xreg_xreg_imm_arch here. ta 1/2/else forwards
// to the ARM64, RISC-V, and x86_64 load callees already in this file.
// The symbol stays strong. ta is the fifth formal, the same slot as
// backend_enc_label_arch.
// w906 places 27 ARM64 fixed-word encoders here. Each one appends a single
// instruction word through backend_enc_append_u32_le_c. They stay strong.
// None of them compares elf_ctx with 0 or divides.
// w907 places 68 ARM64 fixed-word encoders here. Each one appends a single
// instruction word through backend_enc_append_u32_le_c. They stay strong.
// None of them compares elf_ctx with 0 or divides.
// w908 places six ARM64 encoder bodies here. mov_rax_to_rbx and
// mov_edx_to_eax each append two fixed words. cltd returns 0.
// store_rax_to_rbx_indirect picks one width word. mov_rax_to_arg_reg and
// mov_arg_reg_to_rax clamp k and append one mov word. They stay strong.
// None of them compares elf_ctx with 0 or divides.
// w909 places four ARM64 immediate encoders here. u32_le appends the
// caller's word. mov_imm32_to_w0 and mov_imm32_to_rbx emit MOVZ plus a
// hw=1 MOVK when the high half is not zero. mov_imm64_to_rax emits MOVZ
// plus up to three MOVK halfwords. They stay strong. None of them
// compares elf_ctx with 0 or divides.
// w910 places 81 x86_64 fixed-byte encoders here. Each one appends its
// bytes through backend_enc_append_u8_c. They stay strong. None of them
// compares elf_ctx with 0 or divides. cmp_setcc stays in the C seed.
// w911 places 13 x86_64 immediate and leftover fixed-byte encoders here.
// Each byte goes through backend_enc_append_u8_c. An immediate is four
// little-endian bytes taken with shifts. They stay strong. None of them
// compares elf_ctx with 0 or divides. Jumps, calls, cmp_setcc, and the
// Win64 argument moves stay in the C seed.
// w912 places 19 x86_64 rbp displacement and register-immediate encoders
// here. A short displacement is the low 8 bits of the u32 cast of
// 0 minus the offset. Add, sub, and imul use the same low 8 bits for
// an immediate in -128..127. They stay strong. None of them compares
// elf_ctx with 0 or divides. Jumps, calls, cmp_setcc, and the Win64
// argument moves stay in the C seed.
// w913 places seven ARM64 frame load and store encoders here. An aligned
// offset through 32760 appends one scaled word. offset*128 is the imm12
// field. A negative load of x0 or x1 forwards to the C lea. A wider
// offset forwards to arm64_enc_add_rd_rn_imm_chunks, which stays in the
// C seed. They stay strong. None of them compares elf_ctx with 0 or
// divides. Jumps, calls, cmp_setcc, prologue, and lea stay in the C seed.
// w914 places two ARM64 add-immediate encoders here. Each one forwards
// to arm64_enc_add_rd_rn_imm_chunks, which stays in the C seed. They stay
// strong. Neither compares elf_ctx with 0 or divides. Jumps, calls,
// cmp_setcc, prologue, and lea stay in the C seed.
// The rest of the f64/Cap tail stays in seeds/backend_enc_dispatch.from_x.c.
// The installer pure-asms this file, then cc's that seed with
// -DXLANG_L2_ENC_DISPATCH_THIN_FROM_X. No gcc -E. No full .x.
// RBP lane: LDUR 0xB8400000 / STUR 0xB8000000 + simm9 + Rn=x29.
// PLATFORM: SHARED.
//

export extern "C" function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, val: i32): i32;
export extern "C" function glue_binop_var_slot_cache_invalidate_rax(): void;
export extern "C" function glue_binop_var_slot_cache_invalidate_rbx(): void;
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
      return backend_enc_append_u32_le_c_impl(elf_ctx, (2432697343 as u32) | (4095 * 1024));
    }
    return 0 - 1;
  }
  unsafe {
    return backend_enc_append_u32_le_c_impl(elf_ctx, (2432697343 as u32) | ((imm as u32) * 1024));
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
      return backend_enc_append_u32_le_c_impl(elf_ctx, (3506439167 as u32) | (4095 * 1024));
    }
    return 0 - 1;
  }
  unsafe {
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3506439167 as u32) | ((imm as u32) * 1024));
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
      return backend_enc_append_u32_le_c_impl(elf_ctx, (4177527776 as u32));
    }
    return 0 - 1;
  }
  if (off_bytes / 8 > 4095) {
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, (4177527776 as u32) | (4095 * 1024));
    }
    return 0 - 1;
  }
  unsafe {
    return backend_enc_append_u32_le_c_impl(elf_ctx, (4177527776 as u32) | (((off_bytes / 8) as u32) * 1024));
  }
  return 0 - 1;
}

/**
 * Width-aware store of an outgoing ARM64 stack extra at [sp+#off_bytes]
 * (wave614 Apple natural packing; see backend_enc_dispatch.x authority
 * docblock). nbytes 1/2/4 select STRB/STRH/STR w0 at their natural
 * immediate scale; anything else routes to the 8-byte str x0 body.
 * @param elf_ctx *u8
 * @param off_bytes i32
 * @param nbytes i32
 * @return i32
 * PLATFORM: MACOS|ARM64 natural stack-arg packing (wave614).
 */
#[no_mangle]
export function backend_enc_arm64_store_arg_sp_offset_c(elf_ctx: *u8, off_bytes: i32, nbytes: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (off_bytes < 0) {
    return 0 - 1;
  }
  if (nbytes == 1) {
    if (off_bytes > 4095) {
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, (956302304 as u32) | ((off_bytes as u32) * 1024));
    }
  }
  if (nbytes == 2) {
    if ((off_bytes & 1) != 0) {
      return 0 - 1;
    }
    if (off_bytes / 2 > 4095) {
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, (2030044128 as u32) | (((off_bytes / 2) as u32) * 1024));
    }
  }
  if (nbytes == 4) {
    if ((off_bytes & 3) != 0) {
      return 0 - 1;
    }
    if (off_bytes / 4 > 4095) {
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, (3103785952 as u32) | (((off_bytes / 4) as u32) * 1024));
    }
  }
  return backend_enc_arm64_str_x0_sp_offset_c(elf_ctx, off_bytes);
}

/**
 * Load one 32-bit product-frame slot into x0 as a signed 64-bit value.
 * @param elf_ctx *u8 — emit context; null rejected
 * @param offset i32 — logical frame bytes; >=0, multiple of 4, /4 <= 4095
 * @return i32 — 0 ok, -1 bad ctx/offset
 * PLATFORM: MACOS|ARM64 — LDRSW x0,[x29,#off]
 *   0xB9800000 | ((off/4)<<10) | (29<<5) | Rt=0
 * Product frame is positive [x29,#off] (wave616). The prior body emitted
 * LDUR w0,[x29,#-off] and the thin 4B lane path never called it (64-bit
 * LDR x0 instead). i32x4 `/` later lanes then sdiv-ed two packed i32s.
 * LDRSW (not LDR w0): seed idiv is 64-bit sdiv x0,x0,x1 (i64 `/` needs
 * that face); zero-extended negatives would not be signed. 32-bit
 * add/mul/rem and fmov s0,w0 still see the original low 32 bits.
 */
#[no_mangle]
export function arm64_enc_load_w0_from_rbp_c(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (offset < 0) {
    return 0 - 1;
  }
  if ((offset % 4) != 0) {
    return 0 - 1;
  }
  if ((offset / 4) > 4095) {
    return 0 - 1;
  }
  unsafe {
    let imm12: i32 = offset / 4;
    let word: i32 = (3112173568 as i32) | (imm12 * 1024) | 928;
    return arch_arm64_enc_enc_u32_le(elf_ctx, word);
  }
  return 0 - 1;
}

/**
 * Load one 32-bit product-frame slot into x1 as a signed 64-bit value.
 * @param elf_ctx *u8 — emit context; null rejected
 * @param offset i32 — logical frame bytes; >=0, multiple of 4, /4 <= 4095
 * @return i32 — 0 ok, -1 bad ctx/offset
 * PLATFORM: MACOS|ARM64 — LDRSW x1,[x29,#off] (Rt=1 twin of w0 helper).
 * G.7: x86 already has eax32/ebx32; arm64 4B lane `/` needs both x0 and x1.
 */
#[no_mangle]
export function arm64_enc_load_w1_from_rbp_c(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (offset < 0) {
    return 0 - 1;
  }
  if ((offset % 4) != 0) {
    return 0 - 1;
  }
  if ((offset / 4) > 4095) {
    return 0 - 1;
  }
  unsafe {
    let imm12: i32 = offset / 4;
    let word: i32 = (3112173568 as i32) | (imm12 * 1024) | 928 | 1;
    return arch_arm64_enc_enc_u32_le(elf_ctx, word);
  }
  return 0 - 1;
}

/**
 * Store w0 (32-bit, f32/i32 bits) to product frame home [x29, #offset].
 * @param elf_ctx *u8 — ELF/Mach-O emit context
 * @param offset i32 — logical frame bytes; must be >=0 and multiple of 4
 * @return i32 — 0 ok, -1 bad ctx/offset
 * PLATFORM: MACOS|ARM64 product pure-asm.
 * wave616 Cap residual: product frame uses **positive** STR/LDR [x29,#off]
 * (wave420 load_rbp_to_rax / store_x_reg_to_rbp). Prior body used STUR
 * [x29,#-off] → freestanding f32 let store/load mismatch → `x as i32` run=0
 * while f64 (64-bit positive STR) stayed green. G.7: fix this single helper
 * (store_eax_to_rbp_arch calls it). Encoding: STR Wt,[Xn,#imm12*4]
 * 0xB9000000 | ((off/4)<<10) | (29<<5) | Rt=0.
 */
#[no_mangle]
export function arm64_enc_store_w0_to_rbp_c(elf_ctx: *u8, offset: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (offset < 0) {
    return 0 - 1;
  }
  /* STR W scaled imm12: byte offset = imm12*4, imm12 <= 4095. */
  if ((offset % 4) != 0) {
    return 0 - 1;
  }
  if ((offset / 4) > 4095) {
    return 0 - 1;
  }
  unsafe {
    /* 0xB9000000 | ((offset/4)<<10) | (29<<5) | 0 = (3103785888 as u32) | imm | 928 */
    let imm12: i32 = offset / 4;
    let word: i32 = (3103785888 as i32) | (imm12 * 1024) | 928;
    return arch_arm64_enc_enc_u32_le(elf_ctx, word);
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
export extern "C" function glue_binop_var_slot_cache_invalidate_rbx(): void;
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
  // P12g BM4 root fix: rbx var-slot cache invalidation — see backend_enc_dispatch.x
  // twin docblock (mov rax->rbx reparks x1/x19 with a NON-var value; stale hit
  // skipped the zi reload in consecutive same-index stores -> pointer+pointer).
  // PLATFORM: SHARED — extern FFI; typeck rejects the call outside unsafe,
  // which made tip pure-asm fail and left the whole seed on host cc.
  unsafe { glue_binop_var_slot_cache_invalidate_rbx(); }
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
export extern "C" function arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx: *u8, offset: i32): i32;
/* G.7 twin of arch_arm64_enc_enc_load_rbp_to_x2 with Rt=3 (x3 = INDEX secondary
 * scratch). Positive-offset LDR X3, [X29, #imm12] — must match primary loader's
 * positive-offset convention; old inline negated offset (LDUR [x29,-off]) loaded
 * garbage from below the frame for arr[i+j] right operand. */
export extern "C" function arch_arm64_enc_enc_load_rbp_to_x3(elf_ctx: *u8, offset: i32): i32;
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
export extern "C" function arch_arm64_enc_enc_mov_arg_reg_to_rax(elf_ctx: *u8, k: i32): i32;
export extern "C" function arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;
export extern "C" function arch_riscv64_enc_enc_add_sp_imm12(elf_ctx: *u8, nbytes: i32): i32;
export extern "C" function arch_x86_64_enc_enc_add_rsp_imm(elf_ctx: *u8, nbytes: i32): i32;
export extern "C" function arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx: *u8, reg: i32, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx: *u8): i32;
export extern "C" function arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx: *u8, offset: i32): i32;
export extern "C" function arch_x86_64_enc_enc_store_r64_to_rbp(elf_ctx: *u8, reg: i32, offset: i32): i32;

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

/**
 * Signed i32 load from [rax/x0] into the full GP (rax/x0).
 * @param elf_ctx *u8 — emit context
 * @param ta i32 — 0=x86_64, 1=arm64, 2=riscv64
 * @return i32 — 0 ok, -1 encoder failure
 * PLATFORM: SHARED — x86 movsxd (CDQE after movl); MACOS|ARM64 LDRSW.
 * emit_index / deref esz==4 call this. `ldr w0,[x0]` zero-extends, so
 * `a[0] != -5` compared a 64-bit literal `-5` as not-equal (RUN=3).
 * G.7: x86 already CDQE; ARM64 uses LDRSW x0,[x0] (0xB9800000) — same
 * family as arm64_enc_load_w0_from_rbp_c. Do not change load_32_from_rax
 * (f32 bits / unsigned 32 stay zero-ext). Do not change 64-bit idiv.
 */
#[no_mangle]
export function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    // LDRSW x0, [x0] — signed 32→64; twin of x86 CDQE. Not ldr w0.
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, 3112173568 as i32); }
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
        return backend_enc_append_u32_le_c_impl(elf_ctx, (2432697343 as u32) | (4095 * 1024));
      }
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, (2432697343 as u32) | ((nbytes as u32) * 1024));
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
        return backend_enc_append_u32_le_c_impl(elf_ctx, (3506439167 as u32) | (4095 * 1024));
      }
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, (3506439167 as u32) | ((nbytes as u32) * 1024));
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
        return backend_enc_append_u32_le_c_impl(elf_ctx, (4177527776 as u32));
      }
      return 0 - 1;
    }
    if (off_bytes / 8 > 4095) {
      unsafe {
        return backend_enc_append_u32_le_c_impl(elf_ctx, (4177527776 as u32) | (4095 * 1024));
      }
      return 0 - 1;
    }
    unsafe {
      return backend_enc_append_u32_le_c_impl(elf_ctx, (4177527776 as u32) | (((off_bytes / 8) as u32) * 1024));
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
/**
 * Store GP `reg` to [rbp - offset] (product frame slot).
 * @param elf_ctx *u8 — ElfCodegenCtx
 * @param reg i32 — hardware register (arm64 xN / x86 0=rax..15=r15)
 * @param offset i32 — positive rbp-down slot
 * @param ta i32 — 0=x86_64, 1=arm64
 * @return i32 — 0 ok, -1 fail
 * PLATFORM: SHARED — LINUX|x86_64 SysV movq %r64,-off(%rbp); MACOS|ARM64 stur.
 */
export function backend_enc_store_x_reg_to_rbp_arch(elf_ctx: *u8, reg: i32, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, reg, offset); }
  }
  if (ta == 0) {
    unsafe { return arch_x86_64_enc_enc_store_r64_to_rbp(elf_ctx, reg, offset); }
  }
  return 0 - 1;
}

/**
 * Load [rbx] → rax (low 8 of 9–16B INTEGER). G.7 twin of full dispatch.
 * @param elf_ctx *u8 — ElfCodegenCtx*
 * @param ta i32 — 0=x86_64; 1=arm64; else -1
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED — LINUX|x86_64; MACOS|ARM64 ldr x0,[x1]
 */
#[no_mangle]
export function backend_enc_load_qword_from_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    // ldr x0, [x1] = 0xF9400020 — low 8; rbx=x1, rax=x0.
    // PLATFORM: MACOS|ARM64 AAPCS64. G.7 twin of full dispatch.
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, (4181721120 as u32) as i32); }
  }
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx); }
  return 0 - 1;
}

/**
 * Load [rbx+8] → rdx (high 8 of 9–16B INTEGER). ARM64 rdx=x1 (wave408).
 * @param elf_ctx *u8 — ElfCodegenCtx*
 * @param ta i32 — 0=x86_64; 1=arm64; else -1
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED — LINUX|x86_64; MACOS|ARM64 ldr x1,[x1,#8]
 */
#[no_mangle]
export function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    // ldr x1, [x1, #8] = 0xF9400421
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, (4181722145 as u32) as i32); }
  }
  if (ta != 0) {
    return 0 - 1;
  }
  unsafe { return arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx); }
  return 0 - 1;
}

/**
 * Store dual-GP second half to frame (wave408: arm64 x1).
 * @param elf_ctx *u8
 * @param offset i32
 * @param ta i32 — 0=x86 rdx, 1=arm64 x1
 * @return i32 — 0 success, -1 fail
 * PLATFORM: SHARED · LINUX|x86_64 · MACOS|ARM64
 */
#[no_mangle]
export function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, 1, offset); }
  }
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
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, (184746050 as i32)); }
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
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, (1258487874 as i32)); }
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
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, (1258422370 as i32)); }
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
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, (1258356833 as i32)); }
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
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, (184746017 as i32)); }
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
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, (1258487841 as i32)); }
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
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, (453213250 as i32)); }
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
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, (453213217 as i32)); }
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
  // P12g DIV root fix: rax+rbx var-slot cache invalidation at the CALL
  // authority — see backend_enc_dispatch.x twin docblock (call clobbers both;
  // stale rax belief dropped peek_ident_len's return value so the turbofish
  // lens recorded 0 -> T001 copy<A>).
  // PLATFORM: SHARED — both invalidators are extern FFI and must sit in unsafe
  // or tip pure-asm stops in this function.
  unsafe {
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
  }
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
  /* Stage10 10.2.2 slice1: ta==1 AAPCS arg → x0 for asm! lateout. */
  if (ta == 0) {
    unsafe { return arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx, k); }
  }
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_mov_arg_reg_to_rax(elf_ctx, k); }
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
  // PLATFORM: MACOS|ARM64 — esz==4 must not LDR x0 (adjacent i32 lane
  // becomes the high 32 of a 64-bit sdiv). G.7 complete x86 eax32 twin.
  if (ta == 1) {
    if (esz == 4) {
      unsafe { return arm64_enc_load_w0_from_rbp_c(elf_ctx, offset); }
    }
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
  // Incoming stack-arg load [x29, #off]. G.7: delegate to
  // arch_arm64_enc_enc_load_rbp_to_rax (unaligned Apple i32 slots).
  // PLATFORM: MACOS|ARM64.
  if (ta != 1) {
    return 0 - 1;
  }
  unsafe {
    return arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx, off_pos);
  }
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
        return arch_arm64_enc_enc_u32_le(elf_ctx, ((285213762 as u32) + ((4095 - 1) * 1024)) as i32);
      }
      return 0 - 1;
    }
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, ((285213762 as u32) + ((imm - 1) * 1024)) as i32);
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
  /* wave617: delegate to arch_arm64_enc_enc_load_rbp_to_x3 (positive-offset LDR
   * X3, [X29, #imm12]) — SAME convention as primary loader load_rbp_to_x2.
   * Root: old inline negated offset (LDUR W3, [x29,-off]) while primary used
   *   positive LDR X2, [x29,+off] → secondary loaded garbage below the frame
   *   for arr[i+j] right operand (i+j computed wrong, e.g. got 10 not 99).
   * Invariant: secondary loader offset convention MUST match primary loader. */
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_load_rbp_to_x3(elf_ctx, offset); }
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
        return arch_arm64_enc_enc_u32_le(elf_ctx, ((1358955586 as u32) + ((4095 - 1) * 1024)) as i32);
      }
      return 0 - 1;
    }
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, ((1358955586 as u32) + ((imm - 1) * 1024)) as i32);
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
      if (arch_arm64_enc_enc_u32_le(elf_ctx, ((1384120320 as u32) | ((lit as u32) * 32) | 3) as i32) != 0) {
        return 0 - 1;
      }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (453213250 as i32));
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
      if (arch_arm64_enc_enc_u32_le(elf_ctx, ((1384120320 as u32) | ((lit as u32) * 32) | 3) as i32) != 0) {
        return 0 - 1;
      }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (453213217 as i32));
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
        return arch_arm64_enc_enc_u32_le(elf_ctx, ((285213729 as u32) + ((4095 - 1) * 1024)) as i32);
      }
      return 0 - 1;
    }
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, ((285213729 as u32) + ((imm - 1) * 1024)) as i32);
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
        return arch_arm64_enc_enc_u32_le(elf_ctx, ((1358955553 as u32) + ((4095 - 1) * 1024)) as i32);
      }
      return 0 - 1;
    }
    unsafe {
      return arch_arm64_enc_enc_u32_le(elf_ctx, ((1358955553 as u32) + ((imm - 1) * 1024)) as i32);
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
  // PLATFORM: MACOS|ARM64 — esz==4 LDRSW x1; see lane-to-rax.
  if (ta == 1) {
    if (esz == 4) {
      unsafe { return arm64_enc_load_w1_from_rbp_c(elf_ctx, offset); }
    }
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
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872384 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872417 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505489408 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (505806848 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3228438374 as u32)) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3412987750 as u32)) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3243773939 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3229486950 as u32));
  }
  return 0 - 1;
}

/**
 * Scalar f32 multiply (mulss); thin u32 LE twin of full seed.
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — 0=x86_64, 1=arm64 (wave616)
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 + MACOS|ARM64 — freestanding f32 `*` (wave294; arm64 wave616).
 * Encoding mirror of addss with mulss opcode F3 0F 59 C1
 * (u32 le 0xc1590ff3 = (3243839475 as u32); addss is 0xc1580ff3 = (3243773939 as u32)).
 */
#[no_mangle]
export function backend_enc_mulss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872384 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872417 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505481216 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (505806848 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movd xmm0,eax: 66 0f 6e c0 → (3228438374 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3228438374 as u32)) != 0) {
      return 0 - 1;
    }
    /* movd xmm1,ebx: 66 0f 6e cb → (3412987750 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3412987750 as u32)) != 0) {
      return 0 - 1;
    }
    /* mulss xmm0,xmm1: f3 0f 59 c1 → (3243839475 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3243839475 as u32)) != 0) {
      return 0 - 1;
    }
    /* movd eax,xmm0: 66 0f 7e c0 → (3229486950 as u32) */
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3229486950 as u32));
  }
  return 0 - 1;
}

/**
 * Scalar f32 sub left=rbx right=rax (subss); thin u32 LE twin.
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `-` (wave298 Cap residual pure).
 * Encoding: movd xmm0,ebx; movd xmm1,eax; subss F3 0F 5C C1 (u32 le (3244036083 as u32)); movd eax,xmm0.
 */
#[no_mangle]
export function backend_enc_subss_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872416 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872385 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505493504 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (505806848 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movd xmm0,ebx: 66 0f 6e c3 → (3278770022 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3278770022 as u32)) != 0) {
      return 0 - 1;
    }
    /* movd xmm1,eax: 66 0f 6e c8 → (3362656102 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3362656102 as u32)) != 0) {
      return 0 - 1;
    }
    /* subss xmm0,xmm1: f3 0f 5c c1 → (3244036083 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3244036083 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3229486950 as u32));
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
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872384 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872417 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505493504 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (505806848 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3228438374 as u32)) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3412987750 as u32)) != 0) {
      return 0 - 1;
    }
    /* subss f3 0f 5c c1 → (3244036083 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3244036083 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3229486950 as u32));
  }
  return 0 - 1;
}

/**
 * Scalar f32 div left=rax right=rbx (divss); thin u32 LE twin.
 * @param elf_ctx *u8 — ELF codegen context
 * @param ta i32 — target arch; 0 = x86_64 only
 * @return i32 — 0 ok, -1 unsupported arch / null ctx
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `/` (wave298 Cap residual pure).
 * Encoding mirror of mulss with divss opcode F3 0F 5E C1 (u32 le (3244167155 as u32)).
 */
#[no_mangle]
export function backend_enc_divss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872384 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872417 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505485312 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (505806848 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3228438374 as u32)) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3412987750 as u32)) != 0) {
      return 0 - 1;
    }
    /* divss xmm0,xmm1: f3 0f 5e c1 → (3244167155 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3244167155 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3229486950 as u32));
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
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872384 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (506986496 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3228438374 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3224113139 as u32));
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
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550336 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (511180800 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movq xmm0,rax: 66 48 0f 6e + c0 (same lead as cvtsd2ss). */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) {
      return 0 - 1;
    }
    /* cvttsd2si eax,xmm0: f2 0f 2c c0 → u32 le 0xc02c0ff2 = (3224113138 as u32) */
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3224113138 as u32));
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
 * thin first4 u32 le of F3 48 0F 2C = 0x2c0f48f3 = (739199219 as u32) (exact; do not miscompute).
 */
#[no_mangle]
export function backend_enc_cvttss2si_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872384 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (2654470144 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movd xmm0,eax: 66 0f 6e c0 → (3228438374 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3228438374 as u32)) != 0) {
      return 0 - 1;
    }
    /* cvttss2si rax,xmm0: f3 48 0f 2c → u32 le 0x2c0f48f3 = (739199219 as u32) ; + c0 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (739199219 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32);
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
 * thin first4 u32 le of F2 48 0F 2C = 0x2c0f48f2 = (739199218 as u32) (exact; do not miscompute).
 */
#[no_mangle]
export function backend_enc_cvttsd2si_rax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550336 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (2658664448 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movq xmm0,rax: 66 48 0f 6e + c0 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) {
      return 0 - 1;
    }
    /* cvttsd2si rax,xmm0: f2 48 0f 2c → u32 le 0x2c0f48f2 = (739199218 as u32) ; + c0 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (739199218 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32);
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
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657288192 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (2657484800 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* 43-byte unsigned seq; thin path uses append_u8 (no pipeline_elf_ctx). */
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((133) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((121) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((28) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((137) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((194) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((209) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((234) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((131) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((224) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((1) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((9) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((194) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((242) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((42) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((194) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((242) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((88) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((102) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((126) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((235) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((10) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((242) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((42) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((102) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((126) as i32) as i32) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32);
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
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2653093888 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (505806848 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((133) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((121) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((27) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((137) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((194) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((209) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((234) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((131) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((224) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((1) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((9) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((194) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((243) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((42) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((194) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((243) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((88) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((102) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((126) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((235) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((9) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((243) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((72) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((42) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((102) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((126) as i32) as i32) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32);
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
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550336 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (509755392 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (505806848 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3227127794 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3229486950 as u32));
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
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505544704 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (505806848 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3223982067 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3229486950 as u32));
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
 * thin first4 u32 le of F3 48 0F 2A = 0x2a0f48f3 = (705644787 as u32) (exact; do not miscompute).
 */
#[no_mangle]
export function backend_enc_cvtsi2ss_eax_from_i64_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2653028352 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (505806848 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* cvtsi2ss xmm0,rax: f3 48 0f 2a → u32 le 0x2a0f48f3 = (705644787 as u32) ; + c0 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (705644787 as u32)) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) {
      return 0 - 1;
    }
    /* movd eax,xmm0: 66 0f 7e c0 = 0xc07e0f66 = (3229486950 as u32) */
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3229486950 as u32));
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
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (509739008 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (2657484800 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* cvtsi2sd xmm0,eax: f2 0f 2a c0 → u32 le 0xc02a0ff2 = (3223982066 as u32)
     * (same family as cvtsi2ss F3… = (3223982067 as u32); do not miscompute decimal). */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3223982066 as u32)) != 0) {
      return 0 - 1;
    }
    /* movq rax,xmm0: 66 48 0f 7e + c0 → first4 u32 le 0x7e0f4866 = (2114930790 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (2114930790 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32);
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
 * thin first4 u32 le of F2 48 0F 2A = 0x2a0f48f2 = (705644786 as u32) (exact; do not miscompute).
 */
#[no_mangle]
export function backend_enc_cvtsi2sd_rax_from_i64_arch(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657222656 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (2657484800 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* cvtsi2sd xmm0,rax: f2 48 0f 2a → u32 le 0x2a0f48f2 = (705644786 as u32) ; + c0 */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (705644786 as u32)) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32) != 0) {
      return 0 - 1;
    }
    /* movq rax,xmm0: 66 48 0f 7e + c0 → first4 = (2114930790 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (2114930790 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32);
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
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872384 as i32) as i32) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505593856 as i32) as i32) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (2657484800 as i32) as i32);
    }
    return 0 - 1;
  }
  if (ta != 0) {
    return 0 - 1;
  }
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    /* movd xmm0,eax: 66 0f 6e c0 → u32 le 0xc06e0f66 = (3228438374 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3228438374 as u32)) != 0) {
      return 0 - 1;
    }
    /* cvtss2sd xmm0,xmm0: f3 0f 5a c0 → u32 le 0xc05a0ff3 = (3227127795 as u32)
     * (cvtsd2ss is f2… = (3227127794 as u32); keep exact decimal). */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3227127795 as u32)) != 0) {
      return 0 - 1;
    }
    /* movq rax,xmm0: 66 48 0f 7e + c0 → first4 = (2114930790 as u32) */
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (2114930790 as u32)) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, ((192) as i32) as i32);
  }
  return 0 - 1;
}

// movd xmmK, eax：66 0F 6E /r ；modrm = C0 | (k<<3)
/**
 * Move IEEE f32 bits in eax/w0 into FP arg register k.
 * @param elf_ctx *u8 — ElfCodegenCtx*; null rejected
 * @param k i32 — xmmK (SysV) or sK (AAPCS64); 0..7
 * @param ta i32 — 0=x86_64 SysV movd; 1=AAPCS64 fmov sK,w0
 * @return i32 — 0 ok; -1 null/range/unsupported ta
 * PLATFORM: LINUX+MACOS x86_64 SysV · MACOS|ARM64 AAPCS64
 */
#[no_mangle]
export function backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    if (k < 0) { return 0 - 1; }
    if (k > 7) { return 0 - 1; }
    // AAPCS64 fmov encoding is an extern append; typeck requires unsafe.
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, ((505872384 as u32) | (k as u32)) as i32); }
  }
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
    if (backend_enc_append_u8_c_impl(elf_ctx, ((102) as i32) as i32) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((110) as i32) as i32) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, ((192 + (k * 8) as i32) as i32));
  }
  return 0 - 1;
}

// movd eax, xmmK：66 0F 7E /r
/**
 * Harvest IEEE f32 bits from FP arg/return register k into eax/w0.
 * @param elf_ctx *u8 — ElfCodegenCtx*; null rejected
 * @param k i32 — xmmK (SysV) or sK (AAPCS64); 0..7
 * @param ta i32 — 0=x86_64 SysV movd; 1=AAPCS64 fmov w0,sK
 * @return i32 — 0 ok; -1 null/range/unsupported ta
 * PLATFORM: LINUX+MACOS x86_64 SysV · MACOS|ARM64 AAPCS64
 */
#[no_mangle]
export function backend_enc_mov_xmm_arg_reg_to_eax_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (ta == 1) {
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    if (k < 0) { return 0 - 1; }
    if (k > 7) { return 0 - 1; }
    // AAPCS64 fmov encoding is an extern append; typeck requires unsafe.
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, ((505806848 as u32) | ((k as u32) * 32)) as i32); }
  }
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
    if (backend_enc_append_u8_c_impl(elf_ctx, ((102) as i32) as i32) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((15) as i32) as i32) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((126) as i32) as i32) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, ((192 + (k * 8) as i32) as i32));
  }
  return 0 - 1;
}

/**
 * Store EAX to a frame slot: `movl %eax, -offset(%rbp)` (x86_64).
 * Product path for 32-bit locals (TYPE_F32 let / assign). `offset` is the
 * magnitude below rbp — same convention as `store_rax_to_rbp`.
 * @param elf_ctx *u8 — ElfCodegenCtx*; null rejected
 * @param offset i32 — frame offset magnitude (>=0); encoded as disp = -offset
 * @param ta i32 — 0=x86_64 SysV, 1=arm64 STUR w0 helper, else -1
 * @return i32 — 0 ok, -1 failure
 * Disp32 bytes MUST be taken from `disp as u32`. Signed i32 `/ 256` truncates
 * toward zero and drops the 0xFF bytes (offset 0xE0 became +0x20, not -0xE0).
 * Seed thin C already used `(uint32_t)(-offset)`; this matches that extract.
 * PLATFORM: LINUX+MACOS x86_64 SysV disp32 / MACOS|ARM64 STUR helper
 */
#[no_mangle]
export function backend_enc_store_eax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /* wave616: arm64 f32/i32 32-bit frame store — single authority helper. */
    if (ta == 1) {
      return arm64_enc_store_w0_to_rbp_c(elf_ctx, offset);
    }
    if (ta != 0) {
      return 0 - 1;
    }
    if (elf_ctx == 0 as *u8) {
      return 0 - 1;
    }
    // Two's-complement LE bytes of disp=-offset. Unsigned div keeps 0xFF..20.
    let disp: i32 = 0 - offset;
    let u: u32 = disp as u32;
    if (backend_enc_append_u8_c_impl(elf_ctx, 137) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, 133) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, (u & 255) as i32) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((u / 256) & 255) as i32) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c_impl(elf_ctx, ((u / 65536) & 255) as i32) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c_impl(elf_ctx, ((u / 16777216) & 255) as i32);
  }
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
  unsafe { return backend_enc_append_u8_c_impl(elf_ctx, ((byte) as i32) as i32); }
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

/**
 * Slice presence marker for this translation unit.
 * Returns 1, the same value the former host-cc marker returned.
 * No product caller reads it. The ensure nm gate only checks the symbol exists.
 * @return i32 — always 1
 * PLATFORM: SHARED — pure asm. The f64/Cap tail stays in the C seed.
 */
#[no_mangle]
export function backend_enc_dispatch_slice_marker(): i32 {
  return 1;
}

/**
 * Forward arch_arm64_enc_enc_blr to backend_enc_arm64_blr_c.
 * The callee is defined later in this file. This symbol stays strong.
 * @param elf_ctx *u8 — emit context passed through; the callee rejects null
 * @param reg i32 — ARM64 register number passed through
 * @return i32 — the callee's status, 0 on success and -1 on failure
 * PLATFORM: SHARED — product link name. The callee emits the ARM64 blr.
 */
#[no_mangle]
export function arch_arm64_enc_enc_blr(elf_ctx: *u8, reg: i32): i32 {
  unsafe { return backend_enc_arm64_blr_c(elf_ctx, reg); }
  return 0 - 1;
}

/**
 * Forward arch_arm64_enc_enc_ldr_xreg_xreg_imm to backend_enc_arm64_ldr_xreg_xreg_imm_c.
 * The callee is defined later in this file. This symbol stays strong.
 * @param elf_ctx *u8 — emit context passed through; the callee rejects null
 * @param dst_reg i32 — destination ARM64 register passed through
 * @param base_reg i32 — base ARM64 register passed through
 * @param offset i32 — byte offset passed through
 * @return i32 — the callee's status, 0 on success and -1 on failure
 * PLATFORM: SHARED — product link name. The callee emits the ARM64 ldr.
 */
#[no_mangle]
export function arch_arm64_enc_enc_ldr_xreg_xreg_imm(elf_ctx: *u8, dst_reg: i32, base_reg: i32, offset: i32): i32 {
  unsafe { return backend_enc_arm64_ldr_xreg_xreg_imm_c(elf_ctx, dst_reg, base_reg, offset); }
  return 0 - 1;
}

/**
 * Forward arch_x86_64_enc_enc_call_reg to backend_enc_x86_64_call_reg_c.
 * The callee is defined later in this file. This symbol stays strong.
 * @param elf_ctx *u8 — emit context passed through; the callee rejects null
 * @param reg i32 — x86_64 register number passed through; the callee rejects values outside 0..15
 * @return i32 — the callee's status, 0 on success and -1 on failure
 * PLATFORM: SHARED — product link name. The callee emits the x86_64 indirect call.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_call_reg(elf_ctx: *u8, reg: i32): i32 {
  unsafe { return backend_enc_x86_64_call_reg_c(elf_ctx, reg); }
  return 0 - 1;
}

/**
 * Forward arch_x86_64_enc_enc_load_rax_rbx_disp32 to backend_enc_x86_64_load_rax_rbx_disp32_c.
 * The callee is defined later in this file. This symbol stays strong.
 * @param elf_ctx *u8 — emit context passed through; the callee rejects null
 * @param dst_reg i32 — destination register passed through
 * @param base_reg i32 — base register passed through
 * @param offset i32 — disp32 byte offset passed through
 * @return i32 — the callee's status, 0 on success and -1 on failure
 * PLATFORM: SHARED — product link name. The callee emits the x86_64 load.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rax_rbx_disp32(elf_ctx: *u8, dst_reg: i32, base_reg: i32, offset: i32): i32 {
  unsafe { return backend_enc_x86_64_load_rax_rbx_disp32_c(elf_ctx, dst_reg, base_reg, offset); }
  return 0 - 1;
}

/**
 * Forward arch_riscv64_enc_enc_jalr_reg to backend_enc_riscv64_jalr_reg_c.
 * The callee is defined later in this file. This symbol stays strong.
 * @param elf_ctx *u8 — emit context passed through; the callee rejects null
 * @param reg i32 — RISC-V register number passed through; the callee rejects values outside 0..31
 * @return i32 — the callee's status, 0 on success and -1 on failure
 * PLATFORM: SHARED — product link name. The callee emits the RISC-V jalr.
 */
#[no_mangle]
export function arch_riscv64_enc_enc_jalr_reg(elf_ctx: *u8, reg: i32): i32 {
  unsafe { return backend_enc_riscv64_jalr_reg_c(elf_ctx, reg); }
  return 0 - 1;
}

/**
 * Forward arch_riscv64_enc_enc_ldr_xreg_xreg_imm to backend_enc_riscv64_ldr_xreg_xreg_imm_c.
 * The callee is defined later in this file. This symbol stays strong.
 * @param elf_ctx *u8 — emit context passed through; the callee rejects null
 * @param dst_reg i32 — destination RISC-V register passed through; the callee rejects values outside 0..31
 * @param base_reg i32 — base RISC-V register passed through; the callee rejects values outside 0..31
 * @param offset i32 — byte offset passed through; the callee rejects a negative offset
 * @return i32 — the callee's status, 0 on success and -1 on failure
 * PLATFORM: SHARED — product link name. The callee emits the RISC-V ld.
 */
#[no_mangle]
export function arch_riscv64_enc_enc_ldr_xreg_xreg_imm(elf_ctx: *u8, dst_reg: i32, base_reg: i32, offset: i32): i32 {
  unsafe { return backend_enc_riscv64_ldr_xreg_xreg_imm_c(elf_ctx, dst_reg, base_reg, offset); }
  return 0 - 1;
}

export extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;

/**
 * Emit x86_64 cdqe so a 32-bit load sign-extends eax into rax.
 * The two bytes are 0x48 0x98. A null context returns -1.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when both bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * The null check lives in pipeline_elf_ctx_append_bytes. A compare of
 * elf_ctx against 0 in this body is lowered by the Windows x86_64 host
 * compiler to `cmp rbx, 0` without reloading the pointer. After ta==0,
 * rbx is 0, so that compare returns -1 and the bytes are never stored.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cdqe_rax_impl(elf_ctx: *u8): i32 {
  unsafe {
    // Local pair, same bytes as the former static {0x48, 0x98}.
    let cdqe: u8[2] = [];
    cdqe[0] = 72;
    cdqe[1] = 152;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &cdqe[0], 2);
  }
  return 0 - 1;
}

/**
 * Append one byte to the emit buffer.
 * The stored byte is the low 8 bits of byte. A null context returns -1.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param byte i32 — value whose low 8 bits are appended
 * @return i32 — 0 when the byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * Null is rejected by pipeline_elf_ctx_append_bytes. See cdqe for why
 * this body does not compare elf_ctx to 0 on its own.
 */
#[no_mangle]
export function backend_enc_append_u8_c_impl(elf_ctx: *u8, byte: i32): i32 {
  unsafe {
    // One local byte, same mask as the former C (uint8_t)(byte & 255).
    let b: u8[1] = [];
    b[0] = (byte & 255) as u8;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 1);
  }
  return 0 - 1;
}

/**
 * Append one little-endian 32-bit word to the emit buffer.
 * The four stored bytes are the low 8 bits of word, then the next three.
 * A null context returns -1.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param word u32 — value stored as four little-endian bytes
 * @return i32 — 0 when the four bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * Null is rejected by pipeline_elf_ctx_append_bytes. See cdqe for why
 * this body does not compare elf_ctx to 0 on its own.
 */
#[no_mangle]
export function backend_enc_append_u32_le_c_impl(elf_ctx: *u8, word: u32): i32 {
  unsafe {
    // Four local bytes. Unsigned division matches store_eax in this file
    // and the former C (uint8_t)(word >> n) masks.
    let b: u8[4] = [];
    b[0] = (word & 255) as u8;
    b[1] = ((word / 256) & 255) as u8;
    b[2] = ((word / 65536) & 255) as u8;
    b[3] = ((word / 16777216) & 255) as u8;
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 4);
  }
  return 0 - 1;
}

/**
 * Emit one ARM64 blr xN instruction.
 * The word is 0xD63F0000 with the register number in bits 9:5.
 * Register numbers outside 0..30 return -1. A null context returns -1.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param reg i32 — ARM64 register number, accepted only for 0..30
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * Null is rejected by backend_enc_append_u32_le_c. A compare of elf_ctx
 * against 0 in this body is lowered by the Windows x86_64 host compiler
 * to `cmp rbx, 0` without reloading the pointer.
 */
#[no_mangle]
export function backend_enc_arm64_blr_c(elf_ctx: *u8, reg: i32): i32 {
  // 0xD63F0000 | (reg << 5). Multiply by 32 matches the other ARM64 encoders.
  if (reg < 0) { return 0 - 1; }
  if (reg > 30) { return 0 - 1; }
  return backend_enc_append_u32_le_c(elf_ctx, (3594452992 as u32) | ((reg as u32) * 32));
}

/**
 * Emit one RISC-V jalr x1, 0(xN) instruction.
 * The word is 0xE7 with the register number in bits 19:15.
 * Register numbers outside 0..31 return -1. A null context returns -1.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param reg i32 — RISC-V register number, accepted only for 0..31
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * Null is rejected by backend_enc_append_u32_le_c. A compare of elf_ctx
 * against 0 in this body is lowered by the Windows x86_64 host compiler
 * to `cmp rbx, 0` without reloading the pointer.
 */
#[no_mangle]
export function backend_enc_riscv64_jalr_reg_c(elf_ctx: *u8, reg: i32): i32 {
  // 0xE7 | (reg << 15). 0xE7 is jalr with rd=x1 and opcode 0x67.
  // Multiply by 32768 places the register number in bits 19:15.
  if (reg < 0) { return 0 - 1; }
  if (reg > 31) { return 0 - 1; }
  return backend_enc_append_u32_le_c(elf_ctx, (231 as u32) | ((reg as u32) * 32768));
}

/**
 * Emit one x86_64 indirect call through rN.
 * Registers 8..15 are prefixed with REX.B (0x41). Every call then
 * appends opcode 0xFF and ModRM 0xD0 with the low 3 register bits.
 * Register numbers outside 0..15 return -1. A null context returns -1.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param reg i32 — x86_64 register number, accepted only for 0..15
 * @return i32 — 0 when the bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * Null is rejected by backend_enc_append_u8_c. A compare of elf_ctx
 * against 0 in this body is lowered by the Windows x86_64 host compiler
 * to `cmp rbx, 0` without reloading the pointer.
 */
#[no_mangle]
export function backend_enc_x86_64_call_reg_c(elf_ctx: *u8, reg: i32): i32 {
  // 0x41 is REX.B. 0xFF is the call opcode. 0xD0 is ModRM /2.
  // (reg & 7) selects rax..rdi or r8..r15 inside that ModRM byte.
  if (reg < 0) { return 0 - 1; }
  if (reg > 15) { return 0 - 1; }
  if (reg >= 8) {
    if (backend_enc_append_u8_c(elf_ctx, 65) != 0) { return 0 - 1; }
  }
  if (backend_enc_append_u8_c(elf_ctx, 255) != 0) { return 0 - 1; }
  return backend_enc_append_u8_c(elf_ctx, 208 | (reg & 7));
}

/**
 * Emit one RISC-V ld rd, off(rs1) instruction.
 * The word places imm12 in bits 31:20, the base register in bits 19:15,
 * funct3 3 in bits 14:12, the destination in bits 11:7, and opcode 3.
 * A negative offset returns -1. Register numbers outside 0..31 return -1.
 * A null context returns -1.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param dst_reg i32 — destination register, accepted only for 0..31
 * @param base_reg i32 — base register, accepted only for 0..31
 * @param offset i32 — byte offset; negative is rejected; the low 12 bits are imm12
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * Null is rejected by backend_enc_append_u32_le_c. A compare of elf_ctx
 * against 0 in this body is lowered by the Windows x86_64 host compiler
 * to `cmp rbx, 0` without reloading the pointer.
 */
#[no_mangle]
export function backend_enc_riscv64_ldr_xreg_xreg_imm_c(elf_ctx: *u8, dst_reg: i32, base_reg: i32, offset: i32): i32 {
  // (imm12 << 20) | (base << 15) | (3 << 12) | (dst << 7) | 3.
  // 1048576 is 1<<20. 32768 is 1<<15. 12288 is 3<<12. 128 is 1<<7.
  // 4095 keeps the low 12 bits of a non-negative offset.
  if (dst_reg < 0) { return 0 - 1; }
  if (dst_reg > 31) { return 0 - 1; }
  if (base_reg < 0) { return 0 - 1; }
  if (base_reg > 31) { return 0 - 1; }
  if (offset < 0) { return 0 - 1; }
  return backend_enc_append_u32_le_c(
    elf_ctx,
    (((offset & 4095) as u32) * 1048576) | ((base_reg as u32) * 32768) | (12288 as u32) | ((dst_reg as u32) * 128) | (3 as u32)
  );
}

/**
 * Emit one ARM64 ldr xDst, [xBase, #offset] instruction.
 * The word is 0xF9400000 with the scaled offset in bits 21:10,
 * the base register in bits 9:5, and the destination in bits 4:0.
 * Registers outside 0..30 return -1. x31 is the stack pointer and is rejected.
 * A negative offset returns -1. An offset that is not a multiple of 8 returns -1.
 * The scaled immediate is offset/8. Because offset is a multiple of 8,
 * offset*128 equals (offset/8)<<10. An offset above 32760 uses the
 * same field as scale 4095.
 * A null context returns -1.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param dst_reg i32 — destination register, accepted only for 0..30
 * @param base_reg i32 — base register, accepted only for 0..30
 * @param offset i32 — byte offset; must be non-negative and a multiple of 8
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * Null is rejected by backend_enc_append_u32_le_c. A compare of elf_ctx
 * against 0 in this body is lowered by the Windows x86_64 host compiler
 * to `cmp rbx, 0` without reloading the pointer.
 */
#[no_mangle]
export function backend_enc_arm64_ldr_xreg_xreg_imm_c(elf_ctx: *u8, dst_reg: i32, base_reg: i32, offset: i32): i32 {
  // 0xF9400000 | ((offset / 8) << 10) | (base << 5) | dst.
  // 4181721088 is 0xF9400000. 128 is (1<<10)/8. 32 is 1<<5.
  // 32760 is 4095*8. 4193280 is 4095<<10.
  // Multiply stays on the accepted range so a negative offset returns -1
  // without a trapping divide. The clamp is its own return so the store
  // cannot be dropped.
  if (dst_reg < 0) { return 0 - 1; }
  if (dst_reg > 30) { return 0 - 1; }
  if (base_reg < 0) { return 0 - 1; }
  if (base_reg > 30) { return 0 - 1; }
  if (offset < 0) { return 0 - 1; }
  if ((offset & 7) != 0) { return 0 - 1; }
  if (offset > 32760) {
    return backend_enc_append_u32_le_c(
      elf_ctx,
      (4181721088 as u32) | (4193280 as u32) | ((base_reg as u32) * 32) | (dst_reg as u32)
    );
  }
  return backend_enc_append_u32_le_c(
    elf_ctx,
    (4181721088 as u32) | ((offset as u32) * 128) | ((base_reg as u32) * 32) | (dst_reg as u32)
  );
}

/**
 * Emit one x86_64 mov rDst, [rBase + disp32] instruction.
 * The bytes are REX.W, 0x8B, ModRM with mod=2, an optional SIB when
 * the low 3 bits of the base are 4, then the displacement as four
 * little-endian bytes. Registers outside 0..15 return -1.
 * A null context returns -1.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param dst_reg i32 — destination register, accepted only for 0..15
 * @param base_reg i32 — base register, accepted only for 0..15
 * @param offset i32 — disp32; stored as its two's-complement bytes
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * Null is rejected by backend_enc_append_u8_c. A compare of elf_ctx
 * against 0 in this body is lowered by the Windows x86_64 host compiler
 * to `cmp rbx, 0` without reloading the pointer.
 */
#[no_mangle]
export function backend_enc_x86_64_load_rax_rbx_disp32_c(elf_ctx: *u8, dst_reg: i32, base_reg: i32, offset: i32): i32 {
  // REX.W is 0x48. REX.R (bit 2) is 4 when dst >= 8. REX.B (bit 0) is 1 when base >= 8.
  // 0x8B is the mov r/m, r opcode. ModRM 0x80 is mod=2 (disp32), reg in bits 5:3, r/m in bits 2:0.
  // SIB 0x24 is needed when r/m is 4 (RSP encoding), otherwise that ModRM means SIB follows.
  // Displacement bytes are shifts of the unsigned bit pattern, masked to 8 bits.
  // A divide is not used: the host lowers `/` as a 64-bit idiv that traps on a negative dividend.
  let rex: i32 = 0;
  let modrm: i32 = 0;
  let disp: u32 = 0;
  if (dst_reg < 0) { return 0 - 1; }
  if (dst_reg > 15) { return 0 - 1; }
  if (base_reg < 0) { return 0 - 1; }
  if (base_reg > 15) { return 0 - 1; }
  rex = 72 + (((dst_reg >> 3) & 1) * 4) + ((base_reg >> 3) & 1);
  if (backend_enc_append_u8_c(elf_ctx, rex) != 0) { return 0 - 1; }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) { return 0 - 1; }
  modrm = 128 + ((dst_reg & 7) * 8) + (base_reg & 7);
  if (backend_enc_append_u8_c(elf_ctx, modrm) != 0) { return 0 - 1; }
  if ((base_reg & 7) == 4) {
    if (backend_enc_append_u8_c(elf_ctx, 36) != 0) { return 0 - 1; }
  }
  disp = offset as u32;
  if (backend_enc_append_u8_c(elf_ctx, (disp & 255) as i32) != 0) { return 0 - 1; }
  if (backend_enc_append_u8_c(elf_ctx, ((disp >> 8) & 255) as i32) != 0) { return 0 - 1; }
  if (backend_enc_append_u8_c(elf_ctx, ((disp >> 16) & 255) as i32) != 0) { return 0 - 1; }
  if (backend_enc_append_u8_c(elf_ctx, ((disp >> 24) & 255) as i32) != 0) { return 0 - 1; }
  return 0;
}

/**
 * Emit one scalar f64 add: the IEEE bits in rax plus the bits in rbx, result in rax.
 * x86_64 (ta == 0) appends movq xmm0, rax; movq xmm1, rbx; addsd xmm0, xmm1; movq rax, xmm0.
 * ARM64 (ta == 1) appends fmov d0, x0; fmov d1, x1; fadd d0, d0, d1; fmov x0, d0.
 * Any other ta returns -1.
 * @param elf_ctx *u8 — emit context; a null context is rejected by the append callee
 * @param ta i32 — 0 is x86_64, 1 is ARM64
 * @return i32 — 0 when every instruction byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * A compare of elf_ctx against 0 is not done in this body. The Windows
 * x86_64 host compiler lowers that compare to `cmp rbx, 0` without
 * reloading the pointer. This body does not divide.
 */
#[no_mangle]
export function backend_enc_addsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // ARM64 words: 0x9E670000 fmov d0,x0; 0x9E670021 fmov d1,x1;
  // 0x1E612800 fadd d0,d0,d1; 0x9E660000 fmov x0,d0.
  if (ta == 1) {
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550336 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550369 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (509683712 as i32)) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (2657484800 as i32));
    }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  // movq xmm0, rax is 66 48 0F 6E C0. movq xmm1, rbx is 66 48 0F 6E CB.
  // addsd xmm0, xmm1 is F2 0F 58 C1. movq rax, xmm0 is 66 48 0F 7E C0.
  // Each four-byte group is one little-endian word. The fifth byte is separate.
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 203) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3243773938 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (2114930790 as u32)) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c(elf_ctx, 192);
  }
  return 0 - 1;
}

/**
 * Emit one scalar f64 subtract: the IEEE bits in rbx minus the bits in rax, result in rax.
 * x86_64 (ta == 0) appends movq xmm0, rbx; movq xmm1, rax; subsd xmm0, xmm1; movq rax, xmm0.
 * ARM64 (ta == 1) appends fmov d0, x1; fmov d1, x0; fsub d0, d0, d1; fmov x0, d0.
 * Any other ta returns -1.
 * @param elf_ctx *u8 — emit context; a null context is rejected by the append callee
 * @param ta i32 — 0 is x86_64, 1 is ARM64
 * @return i32 — 0 when every instruction byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * A compare of elf_ctx against 0 is not done in this body. The Windows
 * x86_64 host compiler lowers that compare to `cmp rbx, 0` without
 * reloading the pointer. This body does not divide.
 */
#[no_mangle]
export function backend_enc_subsd_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // ARM64 words: 0x9E670020 fmov d0,x1; 0x9E670001 fmov d1,x0;
  // 0x1E613800 fsub d0,d0,d1; 0x9E660000 fmov x0,d0.
  if (ta == 1) {
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550368 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550337 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (509687808 as i32)) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (2657484800 as i32));
    }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  // movq xmm0, rbx is 66 48 0F 6E C3. movq xmm1, rax is 66 48 0F 6E C8.
  // subsd xmm0, xmm1 is F2 0F 5C C1. movq rax, xmm0 is 66 48 0F 7E C0.
  // Each four-byte group is one little-endian word. The fifth byte is separate.
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 195) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 200) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3244036082 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (2114930790 as u32)) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c(elf_ctx, 192);
  }
  return 0 - 1;
}

/**
 * Emit one scalar f64 subtract: the IEEE bits in rax minus the bits in rbx, result in rax.
 * x86_64 (ta == 0) appends movq xmm0, rax; movq xmm1, rbx; subsd xmm0, xmm1; movq rax, xmm0.
 * ARM64 (ta == 1) appends fmov d0, x0; fmov d1, x1; fsub d0, d0, d1; fmov x0, d0.
 * Any other ta returns -1.
 * @param elf_ctx *u8 — emit context; a null context is rejected by the append callee
 * @param ta i32 — 0 is x86_64, 1 is ARM64
 * @return i32 — 0 when every instruction byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * A compare of elf_ctx against 0 is not done in this body. The Windows
 * x86_64 host compiler lowers that compare to `cmp rbx, 0` without
 * reloading the pointer. This body does not divide.
 */
#[no_mangle]
export function backend_enc_subsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // ARM64 words: 0x9E670000 fmov d0,x0; 0x9E670021 fmov d1,x1;
  // 0x1E613800 fsub d0,d0,d1; 0x9E660000 fmov x0,d0.
  if (ta == 1) {
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550336 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550369 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (509687808 as i32)) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (2657484800 as i32));
    }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  // movq xmm0, rax is 66 48 0F 6E C0. movq xmm1, rbx is 66 48 0F 6E CB.
  // subsd xmm0, xmm1 is F2 0F 5C C1. movq rax, xmm0 is 66 48 0F 7E C0.
  // Each four-byte group is one little-endian word. The fifth byte is separate.
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 203) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3244036082 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (2114930790 as u32)) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c(elf_ctx, 192);
  }
  return 0 - 1;
}

/**
 * Emit one scalar f64 multiply: the IEEE bits in rax times the bits in rbx, result in rax.
 * x86_64 (ta == 0) appends movq xmm0, rax; movq xmm1, rbx; mulsd xmm0, xmm1; movq rax, xmm0.
 * ARM64 (ta == 1) appends fmov d0, x0; fmov d1, x1; fmul d0, d0, d1; fmov x0, d0.
 * Any other ta returns -1.
 * @param elf_ctx *u8 — emit context; a null context is rejected by the append callee
 * @param ta i32 — 0 is x86_64, 1 is ARM64
 * @return i32 — 0 when every instruction byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * A compare of elf_ctx against 0 is not done in this body. The Windows
 * x86_64 host compiler lowers that compare to `cmp rbx, 0` without
 * reloading the pointer. This body does not divide.
 */
#[no_mangle]
export function backend_enc_mulsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // ARM64 words: 0x9E670000 fmov d0,x0; 0x9E670021 fmov d1,x1;
  // 0x1E610800 fmul d0,d0,d1; 0x9E660000 fmov x0,d0.
  if (ta == 1) {
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550336 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550369 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (509675520 as i32)) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (2657484800 as i32));
    }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  // movq xmm0, rax is 66 48 0F 6E C0. movq xmm1, rbx is 66 48 0F 6E CB.
  // mulsd xmm0, xmm1 is F2 0F 59 C1. movq rax, xmm0 is 66 48 0F 7E C0.
  // Each four-byte group is one little-endian word. The fifth byte is separate.
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 203) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3243839474 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (2114930790 as u32)) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c(elf_ctx, 192);
  }
  return 0 - 1;
}

/**
 * Emit one scalar f64 divide: the IEEE bits in rax divided by the bits in rbx, result in rax.
 * x86_64 (ta == 0) appends movq xmm0, rax; movq xmm1, rbx; divsd xmm0, xmm1; movq rax, xmm0.
 * ARM64 (ta == 1) appends fmov d0, x0; fmov d1, x1; fdiv d0, d0, d1; fmov x0, d0.
 * Any other ta returns -1.
 * @param elf_ctx *u8 — emit context; a null context is rejected by the append callee
 * @param ta i32 — 0 is x86_64, 1 is ARM64
 * @return i32 — 0 when every instruction byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * A compare of elf_ctx against 0 is not done in this body. The Windows
 * x86_64 host compiler lowers that compare to `cmp rbx, 0` without
 * reloading the pointer. This body does not use an integer divide.
 * A zero divisor stays the IEEE result of divsd or fdiv.
 */
#[no_mangle]
export function backend_enc_divsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32 {
  // ARM64 words: 0x9E670000 fmov d0,x0; 0x9E670021 fmov d1,x1;
  // 0x1E611800 fdiv d0,d0,d1; 0x9E660000 fmov x0,d0.
  if (ta == 1) {
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550336 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550369 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (509679616 as i32)) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (2657484800 as i32));
    }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  // movq xmm0, rax is 66 48 0F 6E C0. movq xmm1, rbx is 66 48 0F 6E CB.
  // divsd xmm0, xmm1 is F2 0F 5E C1. movq rax, xmm0 is 66 48 0F 7E C0.
  // Each four-byte group is one little-endian word. The fifth byte is separate.
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 203) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3244167154 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (2114930790 as u32)) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c(elf_ctx, 192);
  }
  return 0 - 1;
}

/**
 * Emit one ordered scalar f64 compare: the IEEE bits in rbx against the bits in rax.
 * The result stays in the condition flags. rax is not updated.
 * x86_64 (ta == 0) appends movq xmm0, rbx; movq xmm1, rax; ucomisd xmm0, xmm1.
 * ARM64 (ta == 1) appends fmov d0, x1; fmov d1, x0; fcmp d0, d1.
 * Any other ta returns -1.
 * @param elf_ctx *u8 — emit context; a null context is rejected by the append callee
 * @param ta i32 — 0 is x86_64, 1 is ARM64
 * @return i32 — 0 when every instruction byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * A compare of elf_ctx against 0 is not done in this body. The Windows
 * x86_64 host compiler lowers that compare to `cmp rbx, 0` without
 * reloading the pointer. This body does not use an integer divide.
 * Operand order is the reverse of divsd: xmm0 and d0 hold rbx, xmm1 and d1 hold rax.
 * ucomisd sets CF, ZF, and PF. It does not write the quotient back into rax.
 */
#[no_mangle]
export function backend_enc_ucomisd_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // ARM64 words: 0x9E670020 fmov d0,x1; 0x9E670001 fmov d1,x0;
  // 0x1E612000 fcmp d0,d1. No fmov of the flags back into x0.
  if (ta == 1) {
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550368 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (2657550337 as i32)) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (509681664 as i32));
    }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  // movq xmm0, rbx is 66 48 0F 6E C3. movq xmm1, rax is 66 48 0F 6E C8.
  // ucomisd xmm0, xmm1 is 66 0F 2E C1. There is no movq back into rax.
  // Each four-byte group is one little-endian word. The fifth byte of each movq is separate.
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 195) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 200) != 0) { return 0 - 1; }
    return backend_enc_append_u32_le_c_impl(elf_ctx, (3241021286 as u32));
  }
  return 0 - 1;
}

/**
 * Emit one ordered scalar f32 compare: the low 32 IEEE bits in rbx against the bits in rax.
 * The result stays in the condition flags. rax is not updated.
 * x86_64 (ta == 0) appends movd xmm0, ebx; movd xmm1, eax; ucomiss xmm0, xmm1.
 * ARM64 (ta == 1) appends fmov s0, w1; fmov s1, w0; fcmp s0, s1.
 * Any other ta returns -1.
 * @param elf_ctx *u8 — emit context; a null context is rejected by the append callee
 * @param ta i32 — 0 is x86_64, 1 is ARM64
 * @return i32 — 0 when every instruction byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * A compare of elf_ctx against 0 is not done in this body. The Windows
 * x86_64 host compiler lowers that compare to `cmp rbx, 0` without
 * reloading the pointer. This body does not use an integer divide.
 * movd is four bytes and has no REX.W. ucomiss is three bytes, so it is
 * not one little-endian word. These immediates are not the f64 ucomisd words.
 */
#[no_mangle]
export function backend_enc_ucomiss_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32 {
  // ARM64 words: 0x1E270020 fmov s0,w1; 0x1E270001 fmov s1,w0;
  // 0x1E212000 fcmp s0,s1. No fmov of the flags back into w0.
  if (ta == 1) {
    unsafe {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872416 as i32)) != 0) { return 0 - 1; }
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (505872385 as i32)) != 0) { return 0 - 1; }
      return arch_arm64_enc_enc_u32_le(elf_ctx, (505487360 as i32));
    }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  // movd xmm0, ebx is 66 0F 6E C3. movd xmm1, eax is 66 0F 6E C8.
  // ucomiss xmm0, xmm1 is 0F 2E C1. There is no 0x48 and no 0x66 on ucomiss.
  // Each movd is one little-endian word. The three ucomiss bytes are separate.
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3278770022 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (3362656102 as u32)) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
    if (backend_enc_append_u8_c(elf_ctx, 46) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c(elf_ctx, 193);
  }
  return 0 - 1;
}

/**
 * Move the f64 bits in rax/x0 into FP argument register k.
 * x86_64 (ta == 0) appends movq xmmK, rax. ARM64 (ta == 1) appends fmov dK, x0.
 * k outside 0..7 returns -1. Any other ta returns -1.
 * @param elf_ctx *u8 — emit context; a null context is rejected by the append callee
 * @param k i32 — xmmK or dK, accepted only for 0..7
 * @param ta i32 — 0 is x86_64, 1 is ARM64
 * @return i32 — 0 when the instruction is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * A compare of elf_ctx against 0 is not done in this body. The Windows
 * x86_64 host compiler lowers that compare to `cmp rbx, 0` without
 * reloading the pointer. This body does not use an integer divide.
 * k is multiplied by 8 for the x86 ModRM register field and is added into
 * the low bits of the ARM64 fmov word.
 */
#[no_mangle]
export function backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (k < 0) { return 0 - 1; }
  if (k > 7) { return 0 - 1; }
  // 0x9E670000 is fmov d0, x0. The low bits select dK.
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, ((2657550336 as u32) | (k as u32)) as i32); }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  // movq xmmK, rax is 66 48 0F 6E, then ModRM 0xC0 with K in bits 5:3.
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (1846495334 as u32)) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c(elf_ctx, 192 + (k * 8));
  }
  return 0 - 1;
}

/**
 * Move the f64 bits in FP argument register k into rax/x0.
 * x86_64 (ta == 0) appends movq rax, xmmK. ARM64 (ta == 1) appends fmov x0, dK.
 * k outside 0..7 returns -1. Any other ta returns -1.
 * @param elf_ctx *u8 — emit context; a null context is rejected by the append callee
 * @param k i32 — xmmK or dK, accepted only for 0..7
 * @param ta i32 — 0 is x86_64, 1 is ARM64
 * @return i32 — 0 when the instruction is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * A compare of elf_ctx against 0 is not done in this body. The Windows
 * x86_64 host compiler lowers that compare to `cmp rbx, 0` without
 * reloading the pointer. This body does not use an integer divide.
 * k is multiplied by 32 for the ARM64 fmov source field and by 8 for the
 * x86 ModRM register field.
 */
#[no_mangle]
export function backend_enc_mov_xmm_arg_reg_to_rax_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  if (k < 0) { return 0 - 1; }
  if (k > 7) { return 0 - 1; }
  // 0x9E660000 is fmov x0, d0. Multiplying k by 32 places it in bits 9:5.
  if (ta == 1) {
    unsafe { return arch_arm64_enc_enc_u32_le(elf_ctx, ((2657484800 as u32) | ((k as u32) * 32)) as i32); }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  // movq rax, xmmK is 66 48 0F 7E, then ModRM 0xC0 with K in bits 5:3.
  unsafe {
    if (backend_enc_append_u32_le_c_impl(elf_ctx, (2114930790 as u32)) != 0) { return 0 - 1; }
    return backend_enc_append_u8_c(elf_ctx, 192 + (k * 8));
  }
  return 0 - 1;
}

/**
 * Turn the flags from ucomisd or ucomiss into 0 or 1 in eax/w0.
 * cc is 0 eq, 1 ne, 2 lt, 3 le, 4 gt, 5 ge. Any other cc returns -1.
 * x86_64 accounts for the unordered NaN case: eq/lt/le also require PF=0,
 * and ne is true when PF=1. ARM64 uses CSET with the inverted FP condition.
 * @param elf_ctx *u8 — emit context; a null context is rejected by the append callee
 * @param cc i32 — relation code 0..5
 * @param ta i32 — 0 is x86_64, 1 is ARM64
 * @return i32 — 0 when every instruction byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * A compare of elf_ctx against 0 is not done in this body. The Windows
 * x86_64 host compiler lowers that compare to `cmp rbx, 0` without
 * reloading the pointer. This body does not use an integer divide.
 * Each cc is its own straight sequence so a host cannot drop a stored opcode.
 */
#[no_mangle]
export function backend_enc_fp_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32 {
  // ARM64 CSET W0. 0x1A9F07E0 plus the inverted condition in bits 15:12.
  // Conditions are 1, 0, 5, 8, 13, 11 for cc 0..5.
  if (ta == 1) {
    unsafe {
      if (cc == 0) { return arch_arm64_enc_enc_u32_le(elf_ctx, (446633952 as i32)); }
      if (cc == 1) { return arch_arm64_enc_enc_u32_le(elf_ctx, (446629856 as i32)); }
      if (cc == 2) { return arch_arm64_enc_enc_u32_le(elf_ctx, (446650336 as i32)); }
      if (cc == 3) { return arch_arm64_enc_enc_u32_le(elf_ctx, (446662624 as i32)); }
      if (cc == 4) { return arch_arm64_enc_enc_u32_le(elf_ctx, (446683104 as i32)); }
      if (cc == 5) { return arch_arm64_enc_enc_u32_le(elf_ctx, (446674912 as i32)); }
    }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  // cc 1: setp cl; setne al; or cl, al; movzbl eax, al.
  if (cc == 1) {
    unsafe {
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 154) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 193) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 149) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 0) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 200) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 182) != 0) { return 0 - 1; }
      return backend_enc_append_u8_c(elf_ctx, 192);
    }
    return 0 - 1;
  }
  // cc 2: setnp cl; setb al; and cl, al; movzbl.
  if (cc == 2) {
    unsafe {
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 155) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 193) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 146) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 32) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 200) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 182) != 0) { return 0 - 1; }
      return backend_enc_append_u8_c(elf_ctx, 192);
    }
    return 0 - 1;
  }
  // cc 3: setnp cl; setbe al; and cl, al; movzbl.
  if (cc == 3) {
    unsafe {
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 155) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 193) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 150) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 32) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 200) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 182) != 0) { return 0 - 1; }
      return backend_enc_append_u8_c(elf_ctx, 192);
    }
    return 0 - 1;
  }
  // cc 0: setnp cl; sete al; and cl, al; movzbl.
  if (cc == 0) {
    unsafe {
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 155) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 193) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 148) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 32) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 200) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 182) != 0) { return 0 - 1; }
      return backend_enc_append_u8_c(elf_ctx, 192);
    }
    return 0 - 1;
  }
  // cc 4: seta al; movzbl. Unordered is already false.
  if (cc == 4) {
    unsafe {
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 151) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 182) != 0) { return 0 - 1; }
      return backend_enc_append_u8_c(elf_ctx, 192);
    }
    return 0 - 1;
  }
  // cc 5: setae al; movzbl. Unordered is already false.
  if (cc == 5) {
    unsafe {
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 147) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 192) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 15) != 0) { return 0 - 1; }
      if (backend_enc_append_u8_c(elf_ctx, 182) != 0) { return 0 - 1; }
      return backend_enc_append_u8_c(elf_ctx, 192);
    }
    return 0 - 1;
  }
  return 0 - 1;
}

/**
 * Store one outgoing ARM64 stack argument at [sp + off_bytes].
 * ta == 1 forwards to backend_enc_arm64_store_arg_sp_offset_c, which
 * selects STRB, STRH, STR W, or STR X from nbytes.
 * Any other ta returns -1. x86_64 does not use this helper.
 * @param elf_ctx *u8 — emit context; the callee rejects a null context
 * @param off_bytes i32 — byte offset from sp; the callee rejects a negative offset
 * @param nbytes i32 — 1, 2, or 4 select a narrow store; any other width is 8 bytes
 * @param ta i32 — 1 is ARM64
 * @return i32 — 0 when the store is appended, -1 when ta is not ARM64 or the callee fails
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0. The Windows host compiler
 * lowers that compare to `cmp rbx, 0` without reloading the pointer.
 * This body does not divide. The callee's existing width checks stay there.
 */
#[no_mangle]
export function backend_enc_store_arg_sp_offset_arch(elf_ctx: *u8, off_bytes: i32, nbytes: i32, ta: i32): i32 {
  if (ta == 1) {
    return backend_enc_arm64_store_arg_sp_offset_c(elf_ctx, off_bytes, nbytes);
  }
  return 0 - 1;
}

/**
 * Emit an indirect call through a general register.
 * ta == 1 forwards to arch_arm64_enc_enc_blr.
 * ta == 2 forwards to arch_riscv64_enc_enc_jalr_reg.
 * Any other ta forwards to arch_x86_64_enc_enc_call_reg.
 * @param elf_ctx *u8 — emit context; each callee rejects a null context
 * @param reg i32 — register number; each callee checks its own range
 * @param ta i32 — 1 is ARM64, 2 is RISC-V, anything else is x86_64
 * @return i32 — 0 when the call instruction is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function backend_enc_blr_arch(elf_ctx: *u8, reg: i32, ta: i32): i32 {
  if (ta == 1) {
    return arch_arm64_enc_enc_blr(elf_ctx, reg);
  }
  if (ta == 2) {
    return arch_riscv64_enc_enc_jalr_reg(elf_ctx, reg);
  }
  return arch_x86_64_enc_enc_call_reg(elf_ctx, reg);
}

/**
 * Load a 64-bit value from [base + offset] into dst.
 * ta == 1 forwards to arch_arm64_enc_enc_ldr_xreg_xreg_imm.
 * ta == 2 forwards to arch_riscv64_enc_enc_ldr_xreg_xreg_imm.
 * Any other ta forwards to arch_x86_64_enc_enc_load_rax_rbx_disp32.
 * @param elf_ctx *u8 — emit context; each callee rejects a null context
 * @param dst_reg i32 — destination register; each callee checks its own range
 * @param base_reg i32 — base register; each callee checks its own range
 * @param offset i32 — byte displacement; each callee checks alignment and range
 * @param ta i32 — 1 is ARM64, 2 is RISC-V, anything else is x86_64
 * @return i32 — 0 when the load is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * ta is the fifth formal. backend_enc_label_arch in this file already
 * uses that slot. This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function backend_enc_ldr_xreg_xreg_imm_arch(elf_ctx: *u8, dst_reg: i32, base_reg: i32, offset: i32, ta: i32): i32 {
  if (ta == 1) {
    return arch_arm64_enc_enc_ldr_xreg_xreg_imm(elf_ctx, dst_reg, base_reg, offset);
  }
  if (ta == 2) {
    return arch_riscv64_enc_enc_ldr_xreg_xreg_imm(elf_ctx, dst_reg, base_reg, offset);
  }
  return arch_x86_64_enc_enc_load_rax_rbx_disp32(elf_ctx, dst_reg, base_reg, offset);
}

/**
 * Emit ARM64 `mov x0, x1`.
 * The instruction word is 2852193248. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852193248 as u32);
}


/**
 * Emit ARM64 `add w0, w0, w1`.
 * The instruction word is 184549408. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 184549408 as u32);
}


/**
 * Emit ARM64 `sub w0, w0, w1`.
 * The instruction word is 1258356736. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_sub_rax_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 1258356736 as u32);
}


/**
 * Emit ARM64 `sub x0, x1, x0`.
 * The instruction word is 3405774880. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3405774880 as u32);
}


/**
 * Emit ARM64 `mul w0, w0, w1`.
 * The instruction word is 453082112. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 453082112 as u32);
}


/**
 * Emit ARM64 `sdiv x0, x0, x1`.
 * The instruction word is 2596342784. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_idiv_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2596342784 as u32);
}


/**
 * Emit ARM64 `and x0, x0, x1`.
 * The instruction word is 2315321344. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2315321344 as u32);
}


/**
 * Emit ARM64 `orr x0, x0, x1`.
 * The instruction word is 2852192256. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852192256 as u32);
}


/**
 * Emit ARM64 `eor x0, x0, x1`.
 * The instruction word is 3389063168. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3389063168 as u32);
}


/**
 * Emit ARM64 `cmp x1, x0`.
 * The instruction word is 3942645823. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3942645823 as u32);
}


/**
 * Emit ARM64 `cmp x0, x1`.
 * The instruction word is 3942711327. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3942711327 as u32);
}


/**
 * Emit ARM64 `neg w0, w0`.
 * The instruction word is 1258292192. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_neg_eax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 1258292192 as u32);
}


/**
 * Emit ARM64 `mvn w0, w0`.
 * The instruction word is 706741216. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_not_eax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 706741216 as u32);
}


/**
 * Emit ARM64 `ands wzr, w0, w0`.
 * The instruction word is 1778384927. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_test_eax_eax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 1778384927 as u32);
}


/**
 * Emit ARM64 `ands wzr, w1, w1`.
 * The instruction word is 1778450495. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 1778450495 as u32);
}


/**
 * Emit ARM64 `str x0, [sp, #-16]!`.
 * The instruction word is 4162785248. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_push_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 4162785248 as u32);
}


/**
 * Emit ARM64 `str x1, [sp, #-16]!`.
 * The instruction word is 4162785249. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_push_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 4162785249 as u32);
}


/**
 * Emit ARM64 `ldr x0, [sp], #16`.
 * The instruction word is 4165011424. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_pop_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 4165011424 as u32);
}


/**
 * Emit ARM64 `ldr x1, [sp], #16`.
 * The instruction word is 4165011425. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_pop_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 4165011425 as u32);
}


/**
 * Emit ARM64 `mov x2, x1`.
 * The instruction word is 2852193250. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852193250 as u32);
}


/**
 * Emit ARM64 `cset w0, eq`.
 * The instruction word is 446633952. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 446633952 as u32);
}


/**
 * Emit ARM64 `lsl w0, w0, w2`.
 * The instruction word is 448929792. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 448929792 as u32);
}


/**
 * Emit ARM64 `lsr w0, w0, w2`.
 * The instruction word is 448930816. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 448930816 as u32);
}


/**
 * Emit ARM64 `asr w0, w0, w2`.
 * The instruction word is 448931840. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 448931840 as u32);
}


/**
 * Emit ARM64 `lsl x0, x0, x2`.
 * The instruction word is 2596413440. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_shl_cl_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2596413440 as u32);
}


/**
 * Emit ARM64 `lsr x0, x0, x2`.
 * The instruction word is 2596414464. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_shr_cl_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2596414464 as u32);
}


/**
 * Emit ARM64 `asr x0, x0, x2`.
 * The instruction word is 2596415488. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_sar_cl_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2596415488 as u32);
}

/**
 * Emit ARM64 `ldr w0, [x0]`.
 * The instruction word is 3107979264. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3107979264 as u32);
}


/**
 * Emit ARM64 `ldr x0, [x0]`.
 * The instruction word is 4181721088. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 4181721088 as u32);
}


/**
 * Emit ARM64 `ldrb w0, [x0]`.
 * The instruction word is 960495616. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 960495616 as u32);
}


/**
 * Emit ARM64 `add x0, x0, x1, lsl #0`.
 * The instruction word is 2332098560. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2332098560 as u32);
}


/**
 * Emit ARM64 `add x0, x0, x1, lsl #2`.
 * The instruction word is 2332100608. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2332100608 as u32);
}


/**
 * Emit ARM64 `add x0, x0, x1, lsl #3`.
 * The instruction word is 2332101632. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2332101632 as u32);
}


/**
 * Emit ARM64 `add x1, x1, x2, lsl #0`.
 * The instruction word is 2332164129. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_rbx_plus_x2_scale1(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2332164129 as u32);
}


/**
 * Emit ARM64 `add x1, x1, x2, lsl #2`.
 * The instruction word is 2332166177. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_rbx_plus_x2_scale4(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2332166177 as u32);
}


/**
 * Emit ARM64 `add x1, x1, x2, lsl #3`.
 * The instruction word is 2332167201. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_rbx_plus_x2_scale8(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2332167201 as u32);
}


/**
 * Emit ARM64 `svc #0`.
 * The instruction word is 3556769793. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_svc(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3556769793 as u32);
}


/**
 * Emit ARM64 `dmb ish`.
 * The instruction word is 3573758911. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_dmb_ish(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3573758911 as u32);
}


/**
 * Emit ARM64 `dmb ishld`.
 * The instruction word is 3573758399. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_dmb_ishld(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3573758399 as u32);
}


/**
 * Emit ARM64 `dmb ishst`.
 * The instruction word is 3573758655. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_dmb_ishst(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3573758655 as u32);
}


/**
 * Emit ARM64 `ldar w0, [x0]`.
 * The instruction word is 2296380416. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_ldar_w0_x0(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2296380416 as u32);
}


/**
 * Emit ARM64 `stlr w1, [x0]`.
 * The instruction word is 2292186113. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_stlr_w1_x0(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2292186113 as u32);
}


/**
 * Emit ARM64 `ldr w0, [x3]`.
 * The instruction word is 3107979360. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_ldr_w0_x3(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3107979360 as u32);
}


/**
 * Emit ARM64 `str w0, [x3]`.
 * The instruction word is 3103785056. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_str_w0_x3(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3103785056 as u32);
}


/**
 * Emit ARM64 `mov w4, w0`.
 * The instruction word is 704644068. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_w0_to_w4(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 704644068 as u32);
}


/**
 * Emit ARM64 `casal w0, w1, [x2]`.
 * The instruction word is 2296446017. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_casal_w0_w1_x2(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2296446017 as u32);
}


/**
 * Emit ARM64 `cmp w0, w4`.
 * The instruction word is 1795424287. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_cmp_w0_w4(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 1795424287 as u32);
}


/**
 * Emit ARM64 `cset w0, eq`.
 * The instruction word is 446633952. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_cset_eq_w0(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 446633952 as u32);
}


/**
 * Emit ARM64 `ldar x0, [x0]`.
 * The instruction word is 3370122240. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_ldar_x0_x0(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3370122240 as u32);
}


/**
 * Emit ARM64 `stlr x1, [x0]`.
 * The instruction word is 3365927937. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_stlr_x1_x0(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3365927937 as u32);
}


/**
 * Emit ARM64 `ldr x0, [x3]`.
 * The instruction word is 4181721184. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_ldr_x0_x3(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 4181721184 as u32);
}


/**
 * Emit ARM64 `str x0, [x3]`.
 * The instruction word is 4177526880. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_str_x0_x3(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 4177526880 as u32);
}


/**
 * Emit ARM64 `casal x0, x1, [x2]`.
 * The instruction word is 3370187841. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_casal_x0_x1_x2(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3370187841 as u32);
}


/**
 * Emit ARM64 `cmp x0, x4`.
 * The instruction word is 3942907935. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_cmp_x0_x4(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 3942907935 as u32);
}


/**
 * Emit ARM64 `ldarh w0, [x0]`.
 * The instruction word is 1222638592. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_ldarh_w0_x0(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 1222638592 as u32);
}


/**
 * Emit ARM64 `stlrh w1, [x0]`.
 * The instruction word is 1218444289. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_stlrh_w1_x0(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 1218444289 as u32);
}


/**
 * Emit ARM64 `ldrh w0, [x3]`.
 * The instruction word is 2034237536. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_ldrh_w0_x3(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2034237536 as u32);
}


/**
 * Emit ARM64 `strh w0, [x3]`.
 * The instruction word is 2030043232. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_strh_w0_x3(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2030043232 as u32);
}


/**
 * Emit ARM64 `casalh w0, w1, [x2]`.
 * The instruction word is 1222704193. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_casalh_w0_w1_x2(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 1222704193 as u32);
}


/**
 * Emit ARM64 `mov x2, x1`.
 * The instruction word is 2852193250. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rbx_to_x2(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852193250 as u32);
}


/**
 * Emit ARM64 `mov x1, x2`.
 * The instruction word is 2852258785. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x2_to_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852258785 as u32);
}


/**
 * Emit ARM64 `mov x2, x0`.
 * The instruction word is 2852127714. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rax_to_x2(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127714 as u32);
}


/**
 * Emit ARM64 `mov x0, x2`.
 * The instruction word is 2852258784. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x2_to_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852258784 as u32);
}


/**
 * Emit ARM64 `mov x9, x0`.
 * The instruction word is 2852127721. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rax_to_x9(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127721 as u32);
}


/**
 * Emit ARM64 `mov x8, x0`.
 * The instruction word is 2852127720. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rax_to_x8(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127720 as u32);
}


/**
 * Emit ARM64 `mov x0, x8`.
 * The instruction word is 2852652000. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x8_to_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852652000 as u32);
}


/**
 * Emit ARM64 `mov x1, x0`.
 * The instruction word is 2852127713. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x0_to_x1(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127713 as u32);
}


/**
 * Emit ARM64 `mov x2, x0`.
 * The instruction word is 2852127714. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x0_to_x2(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127714 as u32);
}


/**
 * Emit ARM64 `mov x3, x0`.
 * The instruction word is 2852127715. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x0_to_x3(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127715 as u32);
}


/**
 * Emit ARM64 `mov x4, x0`.
 * The instruction word is 2852127716. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x0_to_x4(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127716 as u32);
}


/**
 * Emit ARM64 `mov x0, x9`.
 * The instruction word is 2852717536. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x9_to_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852717536 as u32);
}


/**
 * Emit ARM64 `mov x10, x0`.
 * The instruction word is 2852127722. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rax_to_x10(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127722 as u32);
}


/**
 * Emit ARM64 `mov x0, x10`.
 * The instruction word is 2852783072. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x10_to_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852783072 as u32);
}


/**
 * Emit ARM64 `mov x10, x1`.
 * The instruction word is 2852193258. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rbx_to_x10(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852193258 as u32);
}


/**
 * Emit ARM64 `mov x1, x10`.
 * The instruction word is 2852783073. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x10_to_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852783073 as u32);
}


/**
 * Emit ARM64 `mov x11, x0`.
 * The instruction word is 2852127723. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rax_to_x11(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127723 as u32);
}


/**
 * Emit ARM64 `mov x0, x11`.
 * The instruction word is 2852848608. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x11_to_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852848608 as u32);
}


/**
 * Emit ARM64 `mov x11, x1`.
 * The instruction word is 2852193259. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rbx_to_x11(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852193259 as u32);
}


/**
 * Emit ARM64 `mov x1, x11`.
 * The instruction word is 2852848609. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x11_to_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852848609 as u32);
}


/**
 * Emit ARM64 `mov x12, x0`.
 * The instruction word is 2852127724. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rax_to_x12(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127724 as u32);
}


/**
 * Emit ARM64 `mov x0, x12`.
 * The instruction word is 2852914144. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x12_to_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852914144 as u32);
}


/**
 * Emit ARM64 `mov x12, x1`.
 * The instruction word is 2852193260. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rbx_to_x12(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852193260 as u32);
}


/**
 * Emit ARM64 `mov x1, x12`.
 * The instruction word is 2852914145. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x12_to_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852914145 as u32);
}


/**
 * Emit ARM64 `mov x13, x0`.
 * The instruction word is 2852127725. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rax_to_x13(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127725 as u32);
}


/**
 * Emit ARM64 `mov x0, x13`.
 * The instruction word is 2852979680. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x13_to_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852979680 as u32);
}


/**
 * Emit ARM64 `mov x13, x1`.
 * The instruction word is 2852193261. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rbx_to_x13(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852193261 as u32);
}


/**
 * Emit ARM64 `mov x1, x13`.
 * The instruction word is 2852979681. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x13_to_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852979681 as u32);
}


/**
 * Emit ARM64 `mov x14, x0`.
 * The instruction word is 2852127726. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rax_to_x14(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127726 as u32);
}


/**
 * Emit ARM64 `mov x0, x14`.
 * The instruction word is 2853045216. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x14_to_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2853045216 as u32);
}


/**
 * Emit ARM64 `mov x14, x1`.
 * The instruction word is 2852193262. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rbx_to_x14(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852193262 as u32);
}


/**
 * Emit ARM64 `mov x1, x14`.
 * The instruction word is 2853045217. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x14_to_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2853045217 as u32);
}


/**
 * Emit ARM64 `mov x15, x0`.
 * The instruction word is 2852127727. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rax_to_x15(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852127727 as u32);
}


/**
 * Emit ARM64 `mov x0, x15`.
 * The instruction word is 2853110752. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x15_to_rax(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2853110752 as u32);
}


/**
 * Emit ARM64 `mov x15, x1`.
 * The instruction word is 2852193263. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rbx_to_x15(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2852193263 as u32);
}


/**
 * Emit ARM64 `mov x1, x15`.
 * The instruction word is 2853110753. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_x15_to_rbx(elf_ctx: *u8): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, 2853110753 as u32);
}

/**
 * Emit ARM64 `mov x1, x0` and then `mov x19, x0`.
 * x1 is the rbx alias. x19 keeps the value when a 16-byte call clobbers x1.
 * The words are 2852127713 and 2852127731. A null context returns -1 from append.
 * The first append is checked directly. Its result is not stored and then compared.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when both words are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32 {
  // 0xaa0003e1 is mov x1, x0. 0xaa0003f3 is mov x19, x0.
  if (backend_enc_append_u32_le_c(elf_ctx, 2852127713 as u32) != 0) { return 0 - 1; }
  return backend_enc_append_u32_le_c(elf_ctx, 2852127731 as u32);
}

/**
 * Emit the ARM64 signed-remainder pair `sdiv w2, w0, w1` then `msub w0, w2, w1, w0`.
 * The words are 448859138 and 453083200. They are instruction data, not a host divide.
 * A null context returns -1 from append.
 * The first append is checked directly. Its result is not stored and then compared.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when both words are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32 {
  // 0x1ac10c02 is sdiv w2, w0, w1. 0x1b018040 is msub w0, w2, w1, w0.
  if (backend_enc_append_u32_le_c(elf_ctx, 448859138 as u32) != 0) { return 0 - 1; }
  return backend_enc_append_u32_le_c(elf_ctx, 453083200 as u32);
}

/**
 * ARM64 has no cdq. Signed remainder uses the sdiv and msub words above.
 * This body appends nothing.
 * @param elf_ctx *u8 — unused; ARM64 does not read the context for cdq
 * @return i32 — always 0
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_cltd(elf_ctx: *u8): i32 {
  return 0;
}

/**
 * Store x0 through x1 at the width named by elem_sz.
 * elem_sz 1 appends `strb w0, [x1]` (956301344).
 * elem_sz 4 appends `str w0, [x1]` (3103784992).
 * Every other size, including 8, appends `str x0, [x1]` (4177526816).
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param elem_sz i32 — element width in bytes; 1 and 4 select the narrow stores
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32 {
  // 0x39000020 strb w0, [x1]. 0xb9000020 str w0, [x1]. 0xf9000020 str x0, [x1].
  if (elem_sz == 1) {
    return backend_enc_append_u32_le_c(elf_ctx, 956301344 as u32);
  }
  if (elem_sz == 4) {
    return backend_enc_append_u32_le_c(elf_ctx, 3103784992 as u32);
  }
  return backend_enc_append_u32_le_c(elf_ctx, 4177526816 as u32);
}

/**
 * Copy x0 into AAPCS64 argument register xk.
 * k below 0 is treated as 0. k above 7 is treated as 7.
 * k 0 is already x0, so this body appends nothing and returns 0.
 * Otherwise the word is 2852127712 with the register number in bits 4:0.
 * A null context returns -1 from append when a word is emitted.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param k i32 — argument register index, clamped to 0..7
 * @return i32 — 0 when no word is needed or the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32 {
  // 0xaa0003e0 is mov x0, x0. The low 5 bits are the destination register.
  let rd: i32 = k;
  if (rd < 0) { rd = 0; }
  if (rd > 7) { rd = 7; }
  if (rd == 0) { return 0; }
  return backend_enc_append_u32_le_c(elf_ctx, (2852127712 as u32) | (rd as u32));
}

/**
 * Copy AAPCS64 argument register xk into x0.
 * k outside 0..7 returns -1. k 0 is already x0, so this body returns 0.
 * Otherwise the word is 2852127712 with the source register in bits 20:16.
 * A null context returns -1 from append when a word is emitted.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param k i32 — argument register index, accepted only for 0..7
 * @return i32 — 0 when no word is needed or the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_arg_reg_to_rax(elf_ctx: *u8, k: i32): i32 {
  // 0xaa0003e0 | (k << 16) is mov x0, xk. 65536 places k in bits 20:16.
  if (k < 0) { return 0 - 1; }
  if (k > 7) { return 0 - 1; }
  if (k == 0) { return 0; }
  return backend_enc_append_u32_le_c(elf_ctx, (2852127712 as u32) | ((k as u32) * 65536));
}

/**
 * Append one ARM64 instruction word.
 * val is the raw 32-bit encoding. A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param val i32 — instruction bits, taken as an unsigned 32-bit word
 * @return i32 — 0 when the word is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_u32_le(elf_ctx: *u8, val: i32): i32 {
  return backend_enc_append_u32_le_c(elf_ctx, val as u32);
}

/**
 * Materialize a 32-bit immediate in w0.
 * Always appends MOVZ w0,#lo. Appends MOVK w0,#hi,lsl#16 only when hi is not zero.
 * The high half uses hw=1 (0x72a00000), not hw=0. A null context returns -1 from append.
 * Each append is checked directly. Its result is not stored and then compared.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm32 i32 — bit pattern of the immediate
 * @return i32 — 0 when the words are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_imm32_to_w0(elf_ctx: *u8, imm32: i32): i32 {
  // 0x52800000 is MOVZ w0. 0x72a00000 is MOVK w0, #hi, lsl #16.
  // 32 places the halfword in bits 20:5. The high half is bits 31:16.
  let u: u32 = imm32 as u32;
  let lo: u32 = u & 65535;
  let hi: u32 = (u >> 16) & 65535;
  if (backend_enc_append_u32_le_c(elf_ctx, (1384120320 as u32) | (lo * 32)) != 0) {
    return 0 - 1;
  }
  if (hi != 0) {
    if (backend_enc_append_u32_le_c(elf_ctx, (1923088384 as u32) | (hi * 32)) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Materialize a 32-bit immediate in w1, the rbx alias.
 * Always appends MOVZ w1,#lo. Appends MOVK w1,#hi,lsl#16 only when hi is not zero.
 * The high half uses hw=1. A null context returns -1 from append.
 * Each append is checked directly. Its result is not stored and then compared.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm32 i32 — bit pattern of the immediate
 * @return i32 — 0 when the words are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32 {
  // 0x52800001 is MOVZ w1. 0x72a00001 is MOVK w1, #hi, lsl #16.
  // 32 places the halfword in bits 20:5. The low bit selects w1.
  let u: u32 = imm32 as u32;
  let lo: u32 = u & 65535;
  let hi: u32 = (u >> 16) & 65535;
  if (backend_enc_append_u32_le_c(elf_ctx, (1384120321 as u32) | (lo * 32)) != 0) {
    return 0 - 1;
  }
  if (hi != 0) {
    if (backend_enc_append_u32_le_c(elf_ctx, (1923088385 as u32) | (hi * 32)) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Materialize a 64-bit immediate in x0 from two 32-bit halves.
 * Always appends MOVZ x0,#lo0. Each later MOVK is appended only when that
 * halfword is not zero: lsl #16, lsl #32, then lsl #48.
 * A null context returns -1 from append.
 * Each append is checked directly. Its result is not stored and then compared.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param lo i32 — low 32 bits of the immediate
 * @param hi i32 — high 32 bits of the immediate
 * @return i32 — 0 when the words are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32 {
  // 0xd2800000 MOVZ x0. 0xf2a00000 MOVK lsl #16.
  // 0xf2c00000 MOVK lsl #32. 0xf2e00000 MOVK lsl #48.
  // 32 places each halfword in bits 20:5.
  let ulo: u32 = lo as u32;
  let uhi: u32 = hi as u32;
  let lo0: u32 = ulo & 65535;
  let lo1: u32 = (ulo >> 16) & 65535;
  let hi0: u32 = uhi & 65535;
  let hi1: u32 = (uhi >> 16) & 65535;
  if (backend_enc_append_u32_le_c(elf_ctx, (3531603968 as u32) | (lo0 * 32)) != 0) {
    return 0 - 1;
  }
  if (lo1 != 0) {
    if (backend_enc_append_u32_le_c(elf_ctx, (4070572032 as u32) | (lo1 * 32)) != 0) {
      return 0 - 1;
    }
  }
  if (hi0 != 0) {
    if (backend_enc_append_u32_le_c(elf_ctx, (4072669184 as u32) | (hi0 * 32)) != 0) {
      return 0 - 1;
    }
  }
  if (hi1 != 0) {
    if (backend_enc_append_u32_le_c(elf_ctx, (4074766336 as u32) | (hi1 * 32)) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Emit the fixed x86_64 bytes for add_rax_rbx.
 * The bytes are 01 d8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_add_rax_rbx(elf_ctx: *u8): i32 {
  // 01 d8
  if (backend_enc_append_u8_c(elf_ctx, 1) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 216);
}

/**
 * Emit the fixed x86_64 bytes for and_rbx_rax.
 * The bytes are 48 21 d8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_and_rbx_rax(elf_ctx: *u8): i32 {
  // 48 21 d8
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 33) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 216);
}

/**
 * Emit the fixed x86_64 bytes for or_rbx_rax.
 * The bytes are 48 09 d8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_or_rbx_rax(elf_ctx: *u8): i32 {
  // 48 09 d8
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 9) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 216);
}

/**
 * Emit the fixed x86_64 bytes for xor_rbx_rax.
 * The bytes are 48 31 d8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx: *u8): i32 {
  // 48 31 d8
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 49) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 216);
}

/**
 * Emit the fixed x86_64 bytes for mov_rax_to_rbx.
 * The bytes are 48 89 c3.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx: *u8): i32 {
  // 48 89 c3
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 195);
}

/**
 * Emit the fixed x86_64 bytes for mov_rbx_to_rax.
 * The bytes are 48 89 d8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx: *u8): i32 {
  // 48 89 d8
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 216);
}

/**
 * Emit the fixed x86_64 bytes for mov_rbx_to_ecx.
 * The bytes are 89 d9.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx: *u8): i32 {
  // 89 d9
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 217);
}

/**
 * Emit the fixed x86_64 bytes for mov_edx_to_eax.
 * The bytes are 89 d0.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx: *u8): i32 {
  // 89 d0
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 208);
}

/**
 * Emit the fixed x86_64 bytes for not_eax.
 * The bytes are f7 d0.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_not_eax(elf_ctx: *u8): i32 {
  // f7 d0
  if (backend_enc_append_u8_c(elf_ctx, 247) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 208);
}

/**
 * Emit the fixed x86_64 bytes for neg_eax.
 * The bytes are f7 d8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_neg_eax(elf_ctx: *u8): i32 {
  // f7 d8
  if (backend_enc_append_u8_c(elf_ctx, 247) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 216);
}

/**
 * Emit the fixed x86_64 bytes for test_eax_eax.
 * The bytes are 85 c0.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_test_eax_eax(elf_ctx: *u8): i32 {
  // 85 c0
  if (backend_enc_append_u8_c(elf_ctx, 133) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 192);
}

/**
 * Emit the fixed x86_64 bytes for test_rbx_rbx.
 * The bytes are 85 db.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx: *u8): i32 {
  // 85 db
  if (backend_enc_append_u8_c(elf_ctx, 133) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 219);
}

/**
 * Emit the fixed x86_64 bytes for test_edx_edx.
 * The bytes are 85 d2.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_test_edx_edx(elf_ctx: *u8): i32 {
  // 85 d2
  if (backend_enc_append_u8_c(elf_ctx, 133) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 210);
}

/**
 * Emit the fixed x86_64 bytes for cmp_rbx_rax.
 * The bytes are 39 c3.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx: *u8): i32 {
  // 39 c3
  if (backend_enc_append_u8_c(elf_ctx, 57) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 195);
}

/**
 * Emit the fixed x86_64 bytes for cmp_rax_rbx.
 * The bytes are 39 d8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cmp_rax_rbx(elf_ctx: *u8): i32 {
  // 39 d8
  if (backend_enc_append_u8_c(elf_ctx, 57) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 216);
}

/**
 * Emit the fixed x86_64 bytes for cltd.
 * The bytes are 99.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cltd(elf_ctx: *u8): i32 {
  // 99
  return backend_enc_append_u8_c(elf_ctx, 153);
}

/**
 * Emit the fixed x86_64 bytes for idiv_rbx.
 * The bytes are 48 f7 fb.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_idiv_rbx(elf_ctx: *u8): i32 {
  // 48 f7 fb
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 247) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 251);
}

/**
 * Emit the fixed x86_64 bytes for imul_rbx_rax.
 * The bytes are 0f af c3.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx: *u8): i32 {
  // 0f af c3
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 175) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 195);
}

/**
 * Emit the fixed x86_64 bytes for push_rax.
 * The bytes are 50.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_push_rax(elf_ctx: *u8): i32 {
  // 50
  return backend_enc_append_u8_c(elf_ctx, 80);
}

/**
 * Emit the fixed x86_64 bytes for push_rbx.
 * The bytes are 53.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_push_rbx(elf_ctx: *u8): i32 {
  // 53
  return backend_enc_append_u8_c(elf_ctx, 83);
}

/**
 * Emit the fixed x86_64 bytes for pop_rbx.
 * The bytes are 5b.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_pop_rbx(elf_ctx: *u8): i32 {
  // 5b
  return backend_enc_append_u8_c(elf_ctx, 91);
}

/**
 * Emit the fixed x86_64 bytes for pop_rax.
 * The bytes are 58.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_pop_rax(elf_ctx: *u8): i32 {
  // 58
  return backend_enc_append_u8_c(elf_ctx, 88);
}

/**
 * Emit the fixed x86_64 bytes for shl_cl_eax.
 * The bytes are d3 e0.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_shl_cl_eax(elf_ctx: *u8): i32 {
  // d3 e0
  if (backend_enc_append_u8_c(elf_ctx, 211) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 224);
}

/**
 * Emit the fixed x86_64 bytes for shr_cl_eax.
 * The bytes are d3 e8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_shr_cl_eax(elf_ctx: *u8): i32 {
  // d3 e8
  if (backend_enc_append_u8_c(elf_ctx, 211) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 232);
}

/**
 * Emit the fixed x86_64 bytes for sar_cl_eax.
 * The bytes are d3 f8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sar_cl_eax(elf_ctx: *u8): i32 {
  // d3 f8
  if (backend_enc_append_u8_c(elf_ctx, 211) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 248);
}

/**
 * Emit the fixed x86_64 bytes for shl_cl_rax.
 * The bytes are 48 d3 e0.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_shl_cl_rax(elf_ctx: *u8): i32 {
  // 48 d3 e0
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 211) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 224);
}

/**
 * Emit the fixed x86_64 bytes for shr_cl_rax.
 * The bytes are 48 d3 e8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_shr_cl_rax(elf_ctx: *u8): i32 {
  // 48 d3 e8
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 211) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 232);
}

/**
 * Emit the fixed x86_64 bytes for sar_cl_rax.
 * The bytes are 48 d3 f8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sar_cl_rax(elf_ctx: *u8): i32 {
  // 48 d3 f8
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 211) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 248);
}

/**
 * Emit the fixed x86_64 bytes for xor_edx_edx.
 * The bytes are 31 d2.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_xor_edx_edx(elf_ctx: *u8): i32 {
  // 31 d2
  if (backend_enc_append_u8_c(elf_ctx, 49) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 210);
}

/**
 * Emit the fixed x86_64 bytes for div_rbx.
 * The bytes are 48 f7 f3.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_div_rbx(elf_ctx: *u8): i32 {
  // 48 f7 f3
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 247) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 243);
}

/**
 * Emit the fixed x86_64 bytes for load_32_from_rax.
 * The bytes are 8b 00.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_32_from_rax(elf_ctx: *u8): i32 {
  // 8b 00
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 0);
}

/**
 * Emit the fixed x86_64 bytes for load_64_from_rax.
 * The bytes are 48 8b 00.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_64_from_rax(elf_ctx: *u8): i32 {
  // 48 8b 00
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 0);
}

/**
 * Emit the fixed x86_64 bytes for load_zext8_from_rax.
 * The bytes are 0f b6 00.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx: *u8): i32 {
  // 0f b6 00
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 182) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 0);
}

/**
 * Emit the fixed x86_64 bytes for rax_plus_rbx_scale1.
 * The bytes are 48 8d 04 18.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx: *u8): i32 {
  // 48 8d 04 18
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 141) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 4) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 24);
}

/**
 * Emit the fixed x86_64 bytes for rax_plus_rbx_scale4.
 * The bytes are 48 8d 04 98.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx: *u8): i32 {
  // 48 8d 04 98
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 141) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 4) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 152);
}

/**
 * Emit the fixed x86_64 bytes for rax_plus_rbx_scale8.
 * The bytes are 48 8d 04 d8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx: *u8): i32 {
  // 48 8d 04 d8
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 141) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 4) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 216);
}

/**
 * Emit the fixed x86_64 bytes for lea_rbx_plus_rcx_scale1.
 * The bytes are 48 8d 1c 0b.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(elf_ctx: *u8): i32 {
  // 48 8d 1c 0b
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 141) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 28) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 11);
}

/**
 * Emit the fixed x86_64 bytes for lea_rbx_plus_rcx_scale4.
 * The bytes are 48 8d 1c 8b.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(elf_ctx: *u8): i32 {
  // 48 8d 1c 8b
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 141) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 28) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 139);
}

/**
 * Emit the fixed x86_64 bytes for lea_rbx_plus_rcx_scale8.
 * The bytes are 48 8d 1c cb.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(elf_ctx: *u8): i32 {
  // 48 8d 1c cb
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 141) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 28) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 203);
}

/**
 * Emit the fixed x86_64 bytes for add_ecx_edx.
 * The bytes are 01 d1.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_add_ecx_edx(elf_ctx: *u8): i32 {
  // 01 d1
  if (backend_enc_append_u8_c(elf_ctx, 1) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 209);
}

/**
 * Emit the fixed x86_64 bytes for sub_ecx_edx.
 * The bytes are 29 d1.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_ecx_edx(elf_ctx: *u8): i32 {
  // 29 d1
  if (backend_enc_append_u8_c(elf_ctx, 41) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 209);
}

/**
 * Emit the fixed x86_64 bytes for add_ebx_edx.
 * The bytes are 01 d3.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_add_ebx_edx(elf_ctx: *u8): i32 {
  // 01 d3
  if (backend_enc_append_u8_c(elf_ctx, 1) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 211);
}

/**
 * Emit the fixed x86_64 bytes for sub_ebx_edx.
 * The bytes are 29 d3.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_ebx_edx(elf_ctx: *u8): i32 {
  // 29 d3
  if (backend_enc_append_u8_c(elf_ctx, 41) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 211);
}

/**
 * Emit the fixed x86_64 bytes for imul_ecx_edx.
 * The bytes are 0f af ca.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_imul_ecx_edx(elf_ctx: *u8): i32 {
  // 0f af ca
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 175) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 202);
}

/**
 * Emit the fixed x86_64 bytes for imul_ebx_edx.
 * The bytes are 0f af da.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_imul_ebx_edx(elf_ctx: *u8): i32 {
  // 0f af da
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 175) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 218);
}

/**
 * Emit the fixed x86_64 bytes for sub_rbx_rax_then_mov.
 * The bytes are 48 29 c3 48 89 d8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx: *u8): i32 {
  // 48 29 c3 48 89 d8
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 41) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 195) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 216);
}

/**
 * Emit the fixed x86_64 bytes for rsub_ecx_edx.
 * The bytes are 29 ca 89 d1.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_rsub_ecx_edx(elf_ctx: *u8): i32 {
  // 29 ca 89 d1
  if (backend_enc_append_u8_c(elf_ctx, 41) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 202) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 209);
}

/**
 * Emit the fixed x86_64 bytes for rsub_ebx_edx.
 * The bytes are 29 da 89 d3.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_rsub_ebx_edx(elf_ctx: *u8): i32 {
  // 29 da 89 d3
  if (backend_enc_append_u8_c(elf_ctx, 41) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 218) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 211);
}

/**
 * Emit the fixed x86_64 bytes for setz_movzbl_eax.
 * The bytes are 0f 94 c0 0f b6 c0.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx: *u8): i32 {
  // 0f 94 c0 0f b6 c0
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 148) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 192) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 182) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 192);
}

/**
 * Emit the fixed x86_64 bytes for syscall.
 * The bytes are 0f 05.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_syscall(elf_ctx: *u8): i32 {
  // 0f 05
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 5);
}

/**
 * Emit the fixed x86_64 bytes for movl_mem_rax_to_eax.
 * The bytes are 8b 00.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_movl_mem_rax_to_eax(elf_ctx: *u8): i32 {
  // 8b 00
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 0);
}

/**
 * Emit the fixed x86_64 bytes for movl_mem_rcx_to_eax.
 * The bytes are 8b 01.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_movl_mem_rcx_to_eax(elf_ctx: *u8): i32 {
  // 8b 01
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 1);
}

/**
 * Emit the fixed x86_64 bytes for xchg_edx_mem_rax.
 * The bytes are 87 10.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_xchg_edx_mem_rax(elf_ctx: *u8): i32 {
  // 87 10
  if (backend_enc_append_u8_c(elf_ctx, 135) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 16);
}

/**
 * Emit the fixed x86_64 bytes for mov_rax_to_rcx.
 * The bytes are 48 89 c1.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rax_to_rcx(elf_ctx: *u8): i32 {
  // 48 89 c1
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 193);
}

/**
 * Emit the fixed x86_64 bytes for movl_eax_to_mem_rcx.
 * The bytes are 89 01.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_movl_eax_to_mem_rcx(elf_ctx: *u8): i32 {
  // 89 01
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 1);
}

/**
 * Emit the fixed x86_64 bytes for lock_cmpxchg_edx_mem_rax.
 * The bytes are f0 0f b1 10.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lock_cmpxchg_edx_mem_rax(elf_ctx: *u8): i32 {
  // f0 0f b1 10
  if (backend_enc_append_u8_c(elf_ctx, 240) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 177) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 16);
}

/**
 * Emit the fixed x86_64 bytes for lock_cmpxchg_edx_mem_rbx.
 * The bytes are f0 0f b1 13.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lock_cmpxchg_edx_mem_rbx(elf_ctx: *u8): i32 {
  // f0 0f b1 13
  if (backend_enc_append_u8_c(elf_ctx, 240) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 177) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 19);
}

/**
 * Emit the fixed x86_64 bytes for sete_al.
 * The bytes are 0f 94 c0.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sete_al(elf_ctx: *u8): i32 {
  // 0f 94 c0
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 148) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 192);
}

/**
 * Emit the fixed x86_64 bytes for movzbl_al_eax.
 * The bytes are 0f b6 c0.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_movzbl_al_eax(elf_ctx: *u8): i32 {
  // 0f b6 c0
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 182) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 192);
}

/**
 * Emit the fixed x86_64 bytes for mov_eax_to_edx.
 * The bytes are 89 c2.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_eax_to_edx(elf_ctx: *u8): i32 {
  // 89 c2
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 194);
}

/**
 * Emit the fixed x86_64 bytes for movq_mem_rax_to_rax.
 * The bytes are 48 8b 00.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_movq_mem_rax_to_rax(elf_ctx: *u8): i32 {
  // 48 8b 00
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 0);
}

/**
 * Emit the fixed x86_64 bytes for xchg_rdx_mem_rax.
 * The bytes are 48 87 10.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_xchg_rdx_mem_rax(elf_ctx: *u8): i32 {
  // 48 87 10
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 135) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 16);
}

/**
 * Emit the fixed x86_64 bytes for mov_rax_to_rdx.
 * The bytes are 48 89 c2.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rax_to_rdx(elf_ctx: *u8): i32 {
  // 48 89 c2
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 194);
}

/**
 * Emit the fixed x86_64 bytes for movq_mem_rcx_to_rax.
 * The bytes are 48 8b 01.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_movq_mem_rcx_to_rax(elf_ctx: *u8): i32 {
  // 48 8b 01
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 1);
}

/**
 * Emit the fixed x86_64 bytes for movq_rax_to_mem_rcx.
 * The bytes are 48 89 01.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_movq_rax_to_mem_rcx(elf_ctx: *u8): i32 {
  // 48 89 01
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 1);
}

/**
 * Emit the fixed x86_64 bytes for lock_cmpxchg_rdx_mem_rbx.
 * The bytes are f0 48 0f b1 13.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lock_cmpxchg_rdx_mem_rbx(elf_ctx: *u8): i32 {
  // f0 48 0f b1 13
  if (backend_enc_append_u8_c(elf_ctx, 240) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 177) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 19);
}

/**
 * Emit the fixed x86_64 bytes for mfence.
 * The bytes are 0f ae f0.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mfence(elf_ctx: *u8): i32 {
  // 0f ae f0
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 174) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 240);
}

/**
 * Emit the fixed x86_64 bytes for lfence.
 * The bytes are 0f ae e8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lfence(elf_ctx: *u8): i32 {
  // 0f ae e8
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 174) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 232);
}

/**
 * Emit the fixed x86_64 bytes for sfence.
 * The bytes are 0f ae f8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sfence(elf_ctx: *u8): i32 {
  // 0f ae f8
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 174) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 248);
}

/**
 * Emit the fixed x86_64 bytes for movzwl_mem_rax_to_eax.
 * The bytes are 0f b7 00.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_movzwl_mem_rax_to_eax(elf_ctx: *u8): i32 {
  // 0f b7 00
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 183) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 0);
}

/**
 * Emit the fixed x86_64 bytes for xchg_dx_mem_rax.
 * The bytes are 66 87 10.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_xchg_dx_mem_rax(elf_ctx: *u8): i32 {
  // 66 87 10
  if (backend_enc_append_u8_c(elf_ctx, 102) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 135) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 16);
}

/**
 * Emit the fixed x86_64 bytes for mov_ax_to_dx.
 * The bytes are 66 89 c2.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_ax_to_dx(elf_ctx: *u8): i32 {
  // 66 89 c2
  if (backend_enc_append_u8_c(elf_ctx, 102) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 194);
}

/**
 * Emit the fixed x86_64 bytes for movzwl_mem_rcx_to_eax.
 * The bytes are 0f b7 01.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_movzwl_mem_rcx_to_eax(elf_ctx: *u8): i32 {
  // 0f b7 01
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 183) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 1);
}

/**
 * Emit the fixed x86_64 bytes for movw_ax_to_mem_rcx.
 * The bytes are 66 89 01.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_movw_ax_to_mem_rcx(elf_ctx: *u8): i32 {
  // 66 89 01
  if (backend_enc_append_u8_c(elf_ctx, 102) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 1);
}

/**
 * Emit the fixed x86_64 bytes for lock_cmpxchg_dx_mem_rbx.
 * The bytes are f0 66 0f b1 13.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lock_cmpxchg_dx_mem_rbx(elf_ctx: *u8): i32 {
  // f0 66 0f b1 13
  if (backend_enc_append_u8_c(elf_ctx, 240) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 102) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 177) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 19);
}

/**
 * Emit the fixed x86_64 bytes for mov_rax_to_r10.
 * The bytes are 49 89 c2.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rax_to_r10(elf_ctx: *u8): i32 {
  // 49 89 c2
  if (backend_enc_append_u8_c(elf_ctx, 73) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 194);
}

/**
 * Emit the fixed x86_64 bytes for mov_r10_to_rax.
 * The bytes are 4c 89 d0.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_r10_to_rax(elf_ctx: *u8): i32 {
  // 4c 89 d0
  if (backend_enc_append_u8_c(elf_ctx, 76) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 208);
}

/**
 * Emit the fixed x86_64 bytes for mov_rax_to_r11.
 * The bytes are 49 89 c3.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rax_to_r11(elf_ctx: *u8): i32 {
  // 49 89 c3
  if (backend_enc_append_u8_c(elf_ctx, 73) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 195);
}

/**
 * Emit the fixed x86_64 bytes for mov_r11_to_rax.
 * The bytes are 4c 89 d8.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_r11_to_rax(elf_ctx: *u8): i32 {
  // 4c 89 d8
  if (backend_enc_append_u8_c(elf_ctx, 76) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 216);
}

/**
 * Emit the fixed x86_64 bytes for pause.
 * The bytes are f3 90.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_pause(elf_ctx: *u8): i32 {
  // f3 90
  if (backend_enc_append_u8_c(elf_ctx, 243) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 144);
}

/**
 * Emit the fixed x86_64 bytes for int3.
 * The bytes are cc.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when every byte is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_int3(elf_ctx: *u8): i32 {
  // cc
  return backend_enc_append_u8_c(elf_ctx, 204);
}

/**
 * Emit mov imm32 to ebx.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm32 i32 — 32-bit immediate bit pattern
 * @return i32 — 0 when the opcode and four immediate bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx: *u8, imm32: i32): i32 {
  // opcode 187, then the immediate little-endian.
  let u: u32 = imm32 as u32;
  if (backend_enc_append_u8_c(elf_ctx, 187) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit mov imm32 to eax.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm32 i32 — 32-bit immediate bit pattern
 * @return i32 — 0 when the opcode and four immediate bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_ret_imm32(elf_ctx: *u8, imm32: i32): i32 {
  // opcode 184 is mov imm32 to eax. The link name is ret_imm32.
  let u: u32 = imm32 as u32;
  if (backend_enc_append_u8_c(elf_ctx, 184) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit movabs imm64 to rax. lo is the low 32 bits and hi is the high 32 bits.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param lo i32 — low 32 bits of the immediate
 * @param hi i32 — high 32 bits of the immediate
 * @return i32 — 0 when both opcode bytes and eight immediate bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx: *u8, lo: i32, hi: i32): i32 {
  // opcodes 72, 184, then lo, then hi, each little-endian.
  let lo_u: u32 = lo as u32;
  let hi_u: u32 = hi as u32;
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 184) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (lo_u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((lo_u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((lo_u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((lo_u >> 24) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (hi_u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((hi_u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((hi_u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((hi_u >> 24) & 255) as i32);
}

/**
 * Emit cmp eax, imm32.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm32 i32 — 32-bit immediate bit pattern
 * @return i32 — 0 when the opcode and four immediate bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cmp_eax_imm32(elf_ctx: *u8, imm32: i32): i32 {
  // opcode 61, then the immediate little-endian.
  let u: u32 = imm32 as u32;
  if (backend_enc_append_u8_c(elf_ctx, 61) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit add imm32 to rax. A zero immediate emits no bytes.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm i32 — signed addend; zero is a no-op
 * @return i32 — 0 when nothing is emitted or the bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32 {
  // A zero immediate emits nothing. Otherwise opcodes 72, 5, then imm32.
  let u: u32 = imm as u32;
  if (imm == 0) {
    return 0;
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 5) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit add imm32 to rbx. A zero immediate emits no bytes.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm i32 — signed addend; zero is a no-op
 * @return i32 — 0 when nothing is emitted or the bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32 {
  // A zero immediate emits nothing. Otherwise opcodes 72, 129, 195, then imm32.
  let u: u32 = imm as u32;
  if (imm == 0) {
    return 0;
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 129) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 195) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit add nbytes to rsp. A non-positive count emits no bytes.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param nbytes i32 — byte count added to rsp; values <= 0 emit nothing
 * @return i32 — 0 when nothing is emitted or the bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_add_rsp_imm(elf_ctx: *u8, nbytes: i32): i32 {
  // nbytes <= 0 emits nothing.
  // 1..127 is opcodes 72, 131, 196 and one imm8 byte.
  // A larger count is opcodes 72, 129, 196 and four little-endian bytes.
  let u: u32 = nbytes as u32;
  if (nbytes <= 0) {
    return 0;
  }
  if (nbytes <= 127) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 131) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 196) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, nbytes);
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 129) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 196) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit a store of rax through rbx. The width follows elem_sz.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param elem_sz i32 — 1 for a byte, 4 for a dword, any other value for a qword
 * @return i32 — 0 when the width's bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx: *u8, elem_sz: i32): i32 {
  // elem_sz 1 is bytes 136, 3. elem_sz 4 is bytes 137, 3.
  // Any other size is bytes 72, 137, 3.
  if (elem_sz == 1) {
  if (backend_enc_append_u8_c(elf_ctx, 136) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 3);
  }
  if (elem_sz == 4) {
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 3);
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 3);
}

/**
 * Emit a store of rax to rbx plus a 32-bit displacement.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — displacement bit pattern, stored little-endian
 * @param store_size i32 — 1 for a byte, 4 for a dword, any other value for a qword
 * @return i32 — 0 when the opcode bytes and the displacement are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32 {
  // store_size 1 is opcodes 136, 131 plus disp32.
  // store_size 4 is opcodes 137, 131 plus disp32.
  // Any other size is opcodes 72, 137, 131 plus disp32.
  let u: u32 = offset as u32;
  if (store_size == 1) {
  if (backend_enc_append_u8_c(elf_ctx, 136) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 131) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
  }
  if (store_size == 4) {
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 131) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 131) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit subl ebx, eax.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when both bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_rax_rbx(elf_ctx: *u8): i32 {
  // bytes 41, 216.
  if (backend_enc_append_u8_c(elf_ctx, 41) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 216);
}

/**
 * Emit movq (rbx), rax.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the three bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx: *u8): i32 {
  // bytes 72, 139, 3.
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 3);
}

/**
 * Emit movq 8(rbx), rdx.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when the four bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx: *u8): i32 {
  // bytes 72, 139, 83, 8.
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 83) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 8);
}

/**
 * Emit mov rdx to SysV argument register k. k outside 0..5 is clamped.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param k i32 — argument index; values outside 0..5 clamp to that range
 * @return i32 — 0 when the three bytes for that register are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rdx_to_arg_reg(elf_ctx: *u8, k: i32): i32 {
  // Clamp k into 0..5. Each arm is one SysV mov from rdx.
  let idx: i32 = k;
  if (idx < 0) { idx = 0; }
  if (idx > 5) { idx = 5; }
  if (idx == 0) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 215);
  }
  if (idx == 1) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 214);
  }
  if (idx == 2) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 210);
  }
  if (idx == 3) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 209);
  }
  if (idx == 4) {
  if (backend_enc_append_u8_c(elf_ctx, 73) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 208);
  }
  // idx 5, and any value the clamps already folded into 5.
  if (backend_enc_append_u8_c(elf_ctx, 73) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, 209);
}

/**
 * Emit movq rax to -offset(rbp). Short form is used for displacements -128..-1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32 {
  // disp is 0 minus offset. -128..-1 uses the short displacement.
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 69) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 133) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit movq rN to -offset(rbp). N outside 0..15 returns -1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param reg i32 — x86_64 register number, accepted only for 0..15
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_store_r64_to_rbp(elf_ctx: *u8, reg: i32, offset: i32): i32 {
  // Registers outside 0..15 emit nothing and return -1.
  // REX.W is 72. Registers 8..15 use 76. The ModRM low 3 bits
  // are reg masked with 7, scaled by 8, then added to 69 or 133.
  if (reg < 0) {
    return 0 - 1;
  }
  if (reg > 15) {
    return 0 - 1;
  }
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (reg >= 8) {
  if (backend_enc_append_u8_c(elf_ctx, 76) != 0) {
    return 0 - 1;
  }
  }
  if (reg < 8) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, (69 + ((reg & 7) * 8))) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, (133 + ((reg & 7) * 8))) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit movq -offset(rbp) to rax. Short form is used for displacements -128..-1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32 {
  // disp is 0 minus offset. -128..-1 uses the short displacement.
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 69) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 133) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit movq -offset(rbp) to rbx. Short form is used for displacements -128..-1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32 {
  // disp is 0 minus offset. -128..-1 uses the short displacement.
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 93) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 157) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit leaq -offset(rbp) to rax. Short form is used for displacements -128..-1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx: *u8, offset: i32): i32 {
  // disp is 0 minus offset. -128..-1 uses the short displacement.
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 141) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 69) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 141) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 133) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit leaq -offset(rbp) to rbx. Short form is used for displacements -128..-1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32 {
  // disp is 0 minus offset. -128..-1 uses the short displacement.
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 141) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 93) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 141) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 157) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit movq off_pos(rbp) to rax. A negative off_pos is encoded as zero.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param off_pos i32 — non-negative displacement; negatives clamp to 0
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx: *u8, off_pos: i32): i32 {
  // A negative off_pos is clamped to 0. 0..127 uses disp8.
  // A larger value uses disp32. The byte is the low 8 bits of the u32 cast.
  let disp: i32 = off_pos;
  if (disp < 0) {
    disp = 0;
  }
  let u: u32 = disp as u32;
  if (disp <= 127) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 69) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 133) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit movl -offset(rbp) to eax. Short form is used for displacements -128..-1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_eax32(elf_ctx: *u8, offset: i32): i32 {
  // disp is 0 minus offset. -128..-1 uses the short displacement.
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 69) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 133) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit movl -offset(rbp) to ebx. Short form is used for displacements -128..-1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_ebx32(elf_ctx: *u8, offset: i32): i32 {
  // disp is 0 minus offset. -128..-1 uses the short displacement.
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 93) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 157) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit movl -offset(rbp) to ecx. Short form is used for displacements -128..-1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx: *u8, offset: i32): i32 {
  // disp is 0 minus offset. -128..-1 uses the short displacement.
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 77) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 141) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit movl -offset(rbp) to edx. Short form is used for displacements -128..-1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_edx(elf_ctx: *u8, offset: i32): i32 {
  // disp is 0 minus offset. -128..-1 uses the short displacement.
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 85) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 149) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit add imm to ecx. A zero immediate emits no bytes.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm i32 — signed immediate; zero emits no bytes for add and sub
 * @return i32 — 0 when nothing is emitted or the bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_add_imm_to_ecx(elf_ctx: *u8, imm: i32): i32 {
  // Zero emits nothing. -128..127 uses opcode 131 and one byte.
  // Every other immediate uses opcode 129 and four little-endian bytes.
  if (imm == 0) {
    return 0;
  }
  let u: u32 = imm as u32;
  if (imm >= (0 - 128)) {
    if (imm <= 127) {
  if (backend_enc_append_u8_c(elf_ctx, 131) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 193) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 129) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 193) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit sub imm from ecx. A zero immediate emits no bytes.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm i32 — signed immediate; zero emits no bytes for add and sub
 * @return i32 — 0 when nothing is emitted or the bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_imm_from_ecx(elf_ctx: *u8, imm: i32): i32 {
  // Zero emits nothing. -128..127 uses opcode 131 and one byte.
  // Every other immediate uses opcode 129 and four little-endian bytes.
  if (imm == 0) {
    return 0;
  }
  let u: u32 = imm as u32;
  if (imm >= (0 - 128)) {
    if (imm <= 127) {
  if (backend_enc_append_u8_c(elf_ctx, 131) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 233) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 129) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 233) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit add imm to ebx. A zero immediate emits no bytes.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm i32 — signed immediate; zero emits no bytes for add and sub
 * @return i32 — 0 when nothing is emitted or the bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_add_imm_to_ebx_index(elf_ctx: *u8, imm: i32): i32 {
  // Zero emits nothing. -128..127 uses opcode 131 and one byte.
  // Every other immediate uses opcode 129 and four little-endian bytes.
  if (imm == 0) {
    return 0;
  }
  let u: u32 = imm as u32;
  if (imm >= (0 - 128)) {
    if (imm <= 127) {
  if (backend_enc_append_u8_c(elf_ctx, 131) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 195) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 129) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 195) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit sub imm from ebx. A zero immediate emits no bytes.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm i32 — signed immediate; zero emits no bytes for add and sub
 * @return i32 — 0 when nothing is emitted or the bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_sub_imm_from_ebx_index(elf_ctx: *u8, imm: i32): i32 {
  // Zero emits nothing. -128..127 uses opcode 131 and one byte.
  // Every other immediate uses opcode 129 and four little-endian bytes.
  if (imm == 0) {
    return 0;
  }
  let u: u32 = imm as u32;
  if (imm >= (0 - 128)) {
    if (imm <= 127) {
  if (backend_enc_append_u8_c(elf_ctx, 131) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 235) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 129) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 235) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit imul ecx, ecx, imm. An immediate of 1 or less emits no bytes.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm i32 — multiplier; 1 and every smaller value emit no bytes
 * @return i32 — 0 when nothing is emitted or the bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_imul_imm_to_ecx(elf_ctx: *u8, imm: i32): i32 {
  // An immediate of 1 or less emits nothing, including every negative.
  // 2..127 uses opcode 107 and one byte. Larger values use opcode 105.
  if (imm <= 1) {
    return 0;
  }
  let u: u32 = imm as u32;
  if (imm >= (0 - 128)) {
    if (imm <= 127) {
  if (backend_enc_append_u8_c(elf_ctx, 107) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 201) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 105) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 201) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit imul ebx, ebx, imm. An immediate of 1 or less emits no bytes.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param imm i32 — multiplier; 1 and every smaller value emit no bytes
 * @return i32 — 0 when nothing is emitted or the bytes are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_imul_imm_to_ebx(elf_ctx: *u8, imm: i32): i32 {
  // An immediate of 1 or less emits nothing, including every negative.
  // 2..127 uses opcode 107 and one byte. Larger values use opcode 105.
  if (imm <= 1) {
    return 0;
  }
  let u: u32 = imm as u32;
  if (imm >= (0 - 128)) {
    if (imm <= 127) {
  if (backend_enc_append_u8_c(elf_ctx, 107) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 219) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 105) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 219) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit movq rdx to -offset(rbp). Short form is used for displacements -128..-1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx: *u8, offset: i32): i32 {
  // disp is 0 minus offset. -128..-1 uses the short displacement.
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 85) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 149) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

/**
 * Emit movq -offset(rbp) to rdx. Short form is used for displacements -128..-1.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — magnitude below rbp; the encoded displacement is 0 minus offset
 * @return i32 — 0 when the disp8 or disp32 form is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_load_rbp_to_rdx(elf_ctx: *u8, offset: i32): i32 {
  // disp is 0 minus offset. -128..-1 uses the short displacement.
  let disp: i32 = 0 - offset;
  let u: u32 = disp as u32;
  if (disp >= (0 - 128)) {
    if (disp <= (0 - 1)) {
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 85) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, (u & 255) as i32);
    }
  }
  if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 139) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, 149) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (backend_enc_append_u8_c(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  return backend_enc_append_u8_c(elf_ctx, ((u >> 24) & 255) as i32);
}

export extern "C" function arm64_enc_add_rd_rn_imm_chunks(elf_ctx: *u8, rd: i32, rn: i32, imm: i32): i32;

/**
 * Load x0 from [x29, #offset].
 * A negative offset forwards to arch_arm64_enc_enc_lea_rbp_to_rax.
 * An aligned offset through 32760 appends one LDR word. offset*128 is
 * (offset/8)<<10. Any other non-negative offset forwards to lea and then
 * appends ldr x0, [x0].
 * A null context returns -1 from append or from lea.
 * @param elf_ctx *u8 — emit context; null is rejected by the callee
 * @param offset i32 — byte offset from x29; negative uses lea
 * @return i32 — 0 when the load is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each call is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx: *u8, offset: i32): i32 {
  // 4181722016 is ldr x0, [x29, #0]. 128 scales a byte offset into imm12.
  // 4181721088 is ldr x0, [x0]. 32760 is 4095*8.
  if (offset < 0) {
    unsafe { return arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx, offset); }
    return 0 - 1;
  }
  if ((offset & 7) == 0) {
    if (offset <= 32760) {
      return backend_enc_append_u32_le_c(elf_ctx, (4181722016 as u32) | ((offset as u32) * 128));
    }
  }
  unsafe {
    if (arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx, offset) != 0) {
      return 0 - 1;
    }
  }
  return backend_enc_append_u32_le_c(elf_ctx, 4181721088 as u32);
}

/**
 * Load x1 from [x29, #offset].
 * A negative offset forwards to arch_arm64_enc_enc_lea_rbp_to_rbx.
 * An aligned offset through 32760 appends one LDR word. Any other
 * non-negative offset forwards to lea and then appends ldr x1, [x1].
 * A null context returns -1 from append or from lea.
 * @param elf_ctx *u8 — emit context; null is rejected by the callee
 * @param offset i32 — byte offset from x29; negative uses lea
 * @return i32 — 0 when the load is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each call is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_arm64_enc_enc_load_rbp_to_rbx(elf_ctx: *u8, offset: i32): i32 {
  // 4181722017 is ldr x1, [x29, #0]. 4181721121 is ldr x1, [x1].
  if (offset < 0) {
    unsafe { return arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset); }
    return 0 - 1;
  }
  if ((offset & 7) == 0) {
    if (offset <= 32760) {
      return backend_enc_append_u32_le_c(elf_ctx, (4181722017 as u32) | ((offset as u32) * 128));
    }
  }
  unsafe {
    if (arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset) != 0) {
      return 0 - 1;
    }
  }
  return backend_enc_append_u32_le_c(elf_ctx, 4181721121 as u32);
}

/**
 * Load x2 from [x29, #offset].
 * A negative offset returns -1. An aligned offset through 32760 appends
 * one LDR word. Any other offset adds that byte count to x29 into x2,
 * then appends ldr x2, [x2].
 * A null context returns -1 from append or from the chunk helper.
 * @param elf_ctx *u8 — emit context; null is rejected by the callee
 * @param offset i32 — byte offset from x29; negative is rejected
 * @return i32 — 0 when the load is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each call is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx: *u8, offset: i32): i32 {
  // 4181722018 is ldr x2, [x29, #0]. 4181721154 is ldr x2, [x2].
  // The chunk helper adds offset to x29 and leaves the address in x2.
  if (offset < 0) {
    return 0 - 1;
  }
  if ((offset & 7) == 0) {
    if (offset <= 32760) {
      return backend_enc_append_u32_le_c(elf_ctx, (4181722018 as u32) | ((offset as u32) * 128));
    }
  }
  unsafe {
    if (arm64_enc_add_rd_rn_imm_chunks(elf_ctx, 2, 29, offset) != 0) {
      return 0 - 1;
    }
  }
  return backend_enc_append_u32_le_c(elf_ctx, 4181721154 as u32);
}

/**
 * Load x3 from [x29, #offset].
 * A negative offset returns -1. An aligned offset through 32760 appends
 * one LDR word. Any other offset adds that byte count to x29 into x3,
 * then appends ldr x3, [x3].
 * A null context returns -1 from append or from the chunk helper.
 * @param elf_ctx *u8 — emit context; null is rejected by the callee
 * @param offset i32 — byte offset from x29; negative is rejected
 * @return i32 — 0 when the load is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each call is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_arm64_enc_enc_load_rbp_to_x3(elf_ctx: *u8, offset: i32): i32 {
  // 4181722019 is ldr x3, [x29, #0]. 4181721187 is ldr x3, [x3].
  if (offset < 0) {
    return 0 - 1;
  }
  if ((offset & 7) == 0) {
    if (offset <= 32760) {
      return backend_enc_append_u32_le_c(elf_ctx, (4181722019 as u32) | ((offset as u32) * 128));
    }
  }
  unsafe {
    if (arm64_enc_add_rd_rn_imm_chunks(elf_ctx, 3, 29, offset) != 0) {
      return 0 - 1;
    }
  }
  return backend_enc_append_u32_le_c(elf_ctx, 4181721187 as u32);
}

/**
 * Store Xt to [x29, #offset].
 * reg outside 0..30 is clamped. A negative offset returns -1.
 * An aligned offset through 32760 appends one STR word. Any other
 * offset adds that byte count to x29 into x16, then stores Xt at [x16].
 * A null context returns -1 from append or from the chunk helper.
 * @param elf_ctx *u8 — emit context; null is rejected by the callee
 * @param reg i32 — AAPCS64 Xt index; clamped to 0..30
 * @param offset i32 — byte offset from x29; negative is rejected
 * @return i32 — 0 when the store is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each call is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx: *u8, reg: i32, offset: i32): i32 {
  // 4177526784 is the STR X base. 928 is x29 in bits 9:5. 512 is x16.
  // offset*128 is the scaled imm12 field. rt occupies bits 4:0.
  let rt: i32 = reg;
  if (rt < 0) {
    rt = 0;
  }
  if (rt > 30) {
    rt = 30;
  }
  if (offset < 0) {
    return 0 - 1;
  }
  if ((offset & 7) == 0) {
    if (offset <= 32760) {
      return backend_enc_append_u32_le_c(elf_ctx, (4177526784 as u32) | ((offset as u32) * 128) | (928 as u32) | (rt as u32));
    }
  }
  unsafe {
    if (arm64_enc_add_rd_rn_imm_chunks(elf_ctx, 16, 29, offset) != 0) {
      return 0 - 1;
    }
  }
  return backend_enc_append_u32_le_c(elf_ctx, (4177526784 as u32) | (512 as u32) | (rt as u32));
}

/**
 * Store x0 to [x29, #offset].
 * Forwards to arch_arm64_enc_enc_store_x_reg_to_rbp with reg 0.
 * A null context returns -1 from that callee.
 * @param elf_ctx *u8 — emit context; null is rejected by the callee
 * @param offset i32 — byte offset from x29; negative is rejected
 * @return i32 — 0 when the store is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx: *u8, offset: i32): i32 {
  // reg 0 is x0. The callee owns the displacement check.
  // The earlier extern declaration makes this call an extern call.
  unsafe { return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, 0, offset); }
  return 0 - 1;
}

/**
 * Store x0 at [x1 + offset], or the 16-byte pair at [x19 + offset].
 * store_size 16 or more writes x0 then x1, eight bytes apart, with x19
 * as the base. store_size 1, 2, and 4 select STRB, STRH, and STR W.
 * Every other size selects STR X. A negative offset is stored as 0.
 * The scaled immediate is a shift of the u32 bit pattern, clamped to 4095.
 * A null context returns -1 from append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @param offset i32 — byte offset; a negative value is stored as 0
 * @param store_size i32 — 1, 2, 4, or 16 select the width; other values are 8
 * @return i32 — 0 when the store is appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * Each append is checked directly. Its result is not stored and then compared.
 */
#[no_mangle]
export function arch_arm64_enc_enc_store_rax_to_rbx_offset(elf_ctx: *u8, offset: i32, store_size: i32): i32 {
  // 608 is x19 in bits 9:5. 32 is x1. 1024 is the imm12 shift.
  // STRB, STRH, STR W, and STR X bases are the four width words.
  // A shift of the u32 pattern matches a non-negative divide.
  let off: i32 = offset;
  if (off < 0) {
    off = 0;
  }
  let u: u32 = off as u32;
  let imm_lo: i32 = (u >> 3) as i32;
  let imm_hi: i32 = ((u + 8) >> 3) as i32;
  let imm12: i32 = off;
  let base: u32 = 4177526784 as u32;
  if (store_size >= 16) {
    if (imm_lo > 4095) {
      imm_lo = 4095;
    }
    if (backend_enc_append_u32_le_c(elf_ctx, (4177526784 as u32) | ((imm_lo as u32) * 1024) | (608 as u32)) != 0) {
      return 0 - 1;
    }
    if (imm_hi > 4095) {
      imm_hi = 4095;
    }
    return backend_enc_append_u32_le_c(elf_ctx, (4177526784 as u32) | ((imm_hi as u32) * 1024) | (608 as u32) | (1 as u32));
  }
  if (store_size == 1) {
    if (imm12 > 4095) {
      imm12 = 4095;
    }
    base = 956301312 as u32;
  }
  if (store_size == 2) {
    imm12 = (u >> 1) as i32;
    if (imm12 > 4095) {
      imm12 = 4095;
    }
    base = 2030043136 as u32;
  }
  if (store_size == 4) {
    imm12 = (u >> 2) as i32;
    if (imm12 > 4095) {
      imm12 = 4095;
    }
    base = 3103784960 as u32;
  }
  if (store_size != 1) {
    if (store_size != 2) {
      if (store_size != 4) {
        imm12 = (u >> 3) as i32;
        if (imm12 > 4095) {
          imm12 = 4095;
        }
        base = 4177526784 as u32;
      }
    }
  }
  return backend_enc_append_u32_le_c(elf_ctx, base | ((imm12 as u32) * 1024) | (32 as u32));
}

/**
 * Add a signed immediate to x0, in 4095-sized chunks.
 * The chunk walk stays in arm64_enc_add_rd_rn_imm_chunks. Zero emits
 * nothing. A negative immediate emits SUB chunks. A null context
 * returns -1 from that helper.
 * @param elf_ctx *u8 — emit context; null is rejected by the chunk helper
 * @param imm i32 — signed byte addend
 * @return i32 — 0 when the adds are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * The call is checked by the helper. Its result is returned directly.
 */
#[no_mangle]
export function arch_arm64_enc_enc_add_imm_to_rax(elf_ctx: *u8, imm: i32): i32 {
  // rd 0 and rn 0 are x0. The earlier extern makes this an extern call.
  unsafe { return arm64_enc_add_rd_rn_imm_chunks(elf_ctx, 0, 0, imm); }
  return 0 - 1;
}

/**
 * Add a signed immediate to x1, in 4095-sized chunks.
 * The chunk walk stays in arm64_enc_add_rd_rn_imm_chunks. Zero emits
 * nothing. A negative immediate emits SUB chunks. A null context
 * returns -1 from that helper.
 * @param elf_ctx *u8 — emit context; null is rejected by the chunk helper
 * @param imm i32 — signed byte addend
 * @return i32 — 0 when the adds are appended, -1 on failure
 * PLATFORM: SHARED — product link name. This symbol stays strong.
 * This body does not compare elf_ctx with 0 and does not divide.
 * The call is checked by the helper. Its result is returned directly.
 */
#[no_mangle]
export function arch_arm64_enc_enc_add_imm_to_rbx(elf_ctx: *u8, imm: i32): i32 {
  // rd 1 and rn 1 are x1. The earlier extern makes this an extern call.
  unsafe { return arm64_enc_add_rd_rn_imm_chunks(elf_ctx, 1, 1, imm); }
  return 0 - 1;
}
