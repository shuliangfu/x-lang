// Thin pure: DEREF finish — lvalue addr + mov RBX, then after_addr (wave472).
// G.7: part of glue_emit_assign_deref_elf_c gate (peer-flat).
// wave472: no-local addr setup; Tip U=3/3. PRODUCT inject: LINUX PREFER
//   (stamp w472); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_deref_after_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, ltk: i32): i32;

/**
 * DEREF finish — emit left effective address into RAX, mov to RBX, then
 *   after_addr peer cascade (vec/slice/array/let/scalar).
 * wave472: no-local — no `let x=call()`.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_finish_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, ltk: i32): i32 {
  unsafe {
    if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    return glue_emit_assign_deref_after_addr_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, ltr, ltk);
  }
}
