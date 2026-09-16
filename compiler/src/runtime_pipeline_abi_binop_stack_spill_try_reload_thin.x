// Thin pure: wave211 binop stack-spill try_reload enc.
// G.7: body MUST match mega runtime_pipeline_abi.x wave211 leave.
// Seed cold twin is freestanding no-op stub (always miss); this thin
// restores real arm64 reload via inject first-wins.
// ensure injects via inject_thin_leaf (PREFER_ASM).
// PLATFORM: SHARED freestanding 7.3 · LINUX gold · MACOS|ARM64.

/** wave208: find spill-table depth for frame off; <0 if missing. */
export extern function glue_binop_stack_spill_find_depth(off: i32): i32;
/** wave207: CAP scratch stack depth. */
export extern function glue_index_scratch_stack_depth_get(): i32;
/** Arch enc: LDR [sp,#slot*16] → xreg (reg 0=x0/rax, 1=x1/rbx). */
export extern function arch_arm64_enc_enc_ldr_sp_slot_to_xreg(elf_ctx: *u8, slot: i32, reg: i32): i32;
/** wave210: stamp VAR slot cache after successful reload. */
export extern function glue_binop_var_slot_cache_set_valid_rax(v: i32): void;
export extern function glue_binop_var_slot_cache_set_rax_off(off: i32): void;
export extern function glue_binop_var_slot_cache_set_valid_rbx(v: i32): void;
export extern function glue_binop_var_slot_cache_set_rbx_off(off: i32): void;

// ===========================================================================
// wave211: binop stack-spill try_reload enc pure leave
// (was Cap residual pipeline_asm_emit_spill.c glue_binop_stack_spill_try_reload_elf_c)
// G.7 product authority for freestanding 7.3 arm64 stack-frame spill reload:
//   glue_binop_stack_spill_try_reload_elf_c
// Dependencies pure-owned already: stack_spill_find_depth (wave208), CAP
// depth_get (wave207), VAR cache setters (wave210). Enc: arch_arm64_enc
// enc_ldr_sp_slot_to_xreg (export extern). Seed cold twin under FROM_X.
// Deferred: live_fwd / color / interf BSS / for_call_args mega / pipeline_x mega.
// PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64.
// ===========================================================================

/**
 * If off is in the binop stack-spill table, load [sp,#slot*16] into rax/x0
 * or rbx/x1 and stamp the pure VAR slot cache.
 *
 * Contract:
 *   - ta must be 1 (arm64); other arches return 0 (miss)
 *   - off < 0 / null elf_ctx → 0
 *   - find_depth(off) < 0 → 0 (not spilled to stack frame)
 *   - CAP depth < at_depth → 0 (stack frame no longer holds that slot)
 *   - slot = CAP_depth - at_depth; enc_ldr_sp_slot_to_xreg(elf, slot, reg)
 *   - on success stamps pure VAR cache valid+off for rax (reg=0) or rbx (reg=1)
 *
 * @param elf_ctx *u8 — ElfCodegenCtx*
 * @param ta i32 — target arch (1 = arm64)
 * @param off i32 — frame slot offset of the spilled local
 * @param to_rbx i32 — non-zero → load into rbx/x1; else rax/x0
 * @return i32 — 1 hit; 0 miss/no-op; -1 enc fail
 *
 * wave211 pure: G.7 authority (was Cap residual spill wave170 thin).
 * PLATFORM: SHARED freestanding 7.3 / MACOS|ARM64 AAPCS64.
 */
#[no_mangle]
export function glue_binop_stack_spill_try_reload_elf_c(elf_ctx: *u8, ta: i32, off: i32, to_rbx: i32): i32 {
  let at_depth: i32 = 0;
  let cap_depth: i32 = 0;
  let slot: i32 = 0;
  let rc: i32 = 0;
  if (ta != 1 || off < 0 || elf_ctx == (0 as *u8)) {
    return 0;
  }
  unsafe {
    at_depth = glue_binop_stack_spill_find_depth(off);
  }
  if (at_depth < 0) {
    return 0;
  }
  unsafe {
    cap_depth = glue_index_scratch_stack_depth_get();
  }
  if (cap_depth < at_depth) {
    return 0;
  }
  slot = cap_depth - at_depth;
  if (to_rbx != 0) {
    unsafe {
      rc = arch_arm64_enc_enc_ldr_sp_slot_to_xreg(elf_ctx, slot, 1);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      glue_binop_var_slot_cache_set_valid_rbx(1);
      glue_binop_var_slot_cache_set_rbx_off(off);
    }
  } else {
    unsafe {
      rc = arch_arm64_enc_enc_ldr_sp_slot_to_xreg(elf_ctx, slot, 0);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      glue_binop_var_slot_cache_set_valid_rax(1);
      glue_binop_var_slot_cache_set_rax_off(off);
    }
  }
  return 1;
}

// end wave211 pure-owned leave
