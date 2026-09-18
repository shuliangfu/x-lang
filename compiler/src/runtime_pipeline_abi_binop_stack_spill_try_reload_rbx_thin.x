// Thin pure: binop stack-spill try_reload rbx arm (wave478).
// G.7: part of glue_binop_stack_spill_try_reload_elf_c (peer-flat).
// wave478: split — monolith rbx arm tip-dropped. Tip U=5/5.
//   PRODUCT inject: LINUX PREFER (stamp w478); MACOS co-path.
// PLATFORM: SHARED freestanding 7.3 · LINUX gold · MACOS|ARM64.

export extern function glue_binop_stack_spill_find_depth(off: i32): i32;
export extern function glue_index_scratch_stack_depth_get(): i32;
export extern function arch_arm64_enc_enc_ldr_sp_slot_to_xreg(elf_ctx: *u8, slot: i32, reg: i32): i32;
export extern function glue_binop_var_slot_cache_set_valid_rbx(v: i32): void;
export extern function glue_binop_var_slot_cache_set_rbx_off(off: i32): void;

/**
 * Spill reload into rbx/x1 — enc LDR then stamp VAR cache.
 * wave478: no-local — re-call find_depth/cap; ban `let x=call()`.
 * @return i32 — 1 hit; 0 miss; -1 enc fail
 * PLATFORM: SHARED freestanding 7.3 / MACOS|ARM64.
 */
#[no_mangle]
export function glue_binop_stack_spill_try_reload_rbx_elf_c(elf_ctx: *u8, off: i32): i32 {
  unsafe {
    if (glue_binop_stack_spill_find_depth(off) < 0) {
      return 0;
    }
    if (glue_index_scratch_stack_depth_get() < glue_binop_stack_spill_find_depth(off)) {
      return 0;
    }
    if (arch_arm64_enc_enc_ldr_sp_slot_to_xreg(elf_ctx, glue_index_scratch_stack_depth_get() - glue_binop_stack_spill_find_depth(off), 1) != 0) {
      return 0 - 1;
    }
    glue_binop_var_slot_cache_set_valid_rbx(1);
    glue_binop_var_slot_cache_set_rbx_off(off);
    return 1;
  }
}
