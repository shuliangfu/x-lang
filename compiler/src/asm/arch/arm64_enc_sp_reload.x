// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Link-name adapter for the arm64 stack-slot reload.
// arm64_enc.x owns the encoder as enc_ldr_sp_slot_to_xreg. The product
// object emits that as arm64_enc_enc_ldr_sp_slot_to_xreg. The pipeline
// runtime calls arch_arm64_enc_enc_ldr_sp_slot_to_xreg. This file is only
// that name. Recompiling arm64_enc.x is blocked until its elf method
// calls typecheck again.
// PLATFORM: SHARED.

/**
 * Product link name of arm64_enc.enc_ldr_sp_slot_to_xreg.
 * ctx is the ELF codegen context pointer. slot and reg match that encoder.
 * Returns the encoder result.
 * PLATFORM: SHARED.
 */
export extern "C" function arm64_enc_enc_ldr_sp_slot_to_xreg(ctx: *u8, slot: i32, reg: i32): i32;

/**
 * Reload a stack slot into an x register under the pipeline's call name.
 * Params: ctx — ELF codegen context. slot — stack slot. reg — destination register.
 * Returns: the arm64 encoder result (0, or -1 when the word is rejected).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function arch_arm64_enc_enc_ldr_sp_slot_to_xreg(ctx: *u8, slot: i32, reg: i32): i32 {
  unsafe {
    return arm64_enc_enc_ldr_sp_slot_to_xreg(ctx, slot, reg);
  }
}
