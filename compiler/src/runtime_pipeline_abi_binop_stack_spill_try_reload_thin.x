// Thin pure: wave211/w478 binop stack-spill try_reload gate.
// G.7: body MUST match mega runtime_pipeline_abi.x wave211 leave.
// wave478: gate+rax+rbx split (monolith rbx arm tip-drop). Tip U=2/2.
//   PRODUCT inject: LINUX PREFER (stamp w478); MACOS co-path.
// PLATFORM: SHARED freestanding 7.3 · LINUX gold · MACOS|ARM64.

export extern function glue_binop_stack_spill_try_reload_rax_elf_c(elf_ctx: *u8, off: i32): i32;
export extern function glue_binop_stack_spill_try_reload_rbx_elf_c(elf_ctx: *u8, off: i32): i32;

/**
 * If off is in the binop stack-spill table, load [sp,#slot*16] into rax/x0
 * or rbx/x1 and stamp the pure VAR slot cache.
 * wave478: no-local — peer dispatch; ban `let x=call()`.
 * Contract: ta must be 1 (arm64); other arches return 0 (miss).
 * @return i32 — 1 hit; 0 miss/no-op; -1 enc fail
 * PLATFORM: SHARED freestanding 7.3 / MACOS|ARM64 AAPCS64.
 */
#[no_mangle]
export function glue_binop_stack_spill_try_reload_elf_c(elf_ctx: *u8, ta: i32, off: i32, to_rbx: i32): i32 {
  unsafe {
    if (ta != 1) {
      return 0;
    }
    if (off < 0) {
      return 0;
    }
    if (elf_ctx == (0 as *u8)) {
      return 0;
    }
    if (to_rbx != 0) {
      return glue_binop_stack_spill_try_reload_rbx_elf_c(elf_ctx, off);
    }
    return glue_binop_stack_spill_try_reload_rax_elf_c(elf_ctx, off);
  }
}
