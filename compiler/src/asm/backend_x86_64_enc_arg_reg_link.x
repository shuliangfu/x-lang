// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Link-name adapters for the two x86_64 arg-register moves.
// The real bodies are already linked as x86_64_enc_enc_mov_arg_reg_to_rax
// and x86_64_enc_enc_mov_rax_to_arg_reg. The arch_ names in the seed stub
// object return failure immediately, so param homes stop after the prologue.
// PLATFORM: SHARED.

/**
 * Product body that copies incoming SysV arg register k into rax.
 * elf_ctx is the ELF emit context. k is the argument index.
 * Returns 0 on success, or a negative code from the encoder.
 * PLATFORM: SHARED.
 */
export extern "C" function x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx: *u8, k: i32): i32;

/**
 * Product body that copies rax into outgoing SysV arg register k.
 * elf_ctx is the ELF emit context. k is the argument index.
 * Returns 0 on success, or a negative code from the encoder.
 * PLATFORM: SHARED.
 */
export extern "C" function x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32;

/**
 * arch_ call name for the incoming arg-to-rax move.
 * Forwards to the already-linked unprefixed encoder.
 * elf_ctx null and a bad k are rejected by that encoder.
 * Returns the encoder result.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx: *u8, k: i32): i32 {
  unsafe {
    return x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx, k);
  }
}

/**
 * arch_ call name for the outgoing rax-to-arg move.
 * Forwards to the already-linked unprefixed encoder.
 * elf_ctx null and a bad k are rejected by that encoder.
 * Returns the encoder result.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx: *u8, k: i32): i32 {
  unsafe {
    return x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
  }
}
