// Thin pure: assign load L/R into rax/rbx (wave448/w474).
// G.7: part of glue_emit_assign_rhs_to_rax_elf_c compound path.
// wave474: split from rhsrax_arms mega; no-local (ban let-bound call).
//   Tip U=4/4. PRODUCT inject: LINUX PREFER (stamp w474); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_try_binop_left_rax_right_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Load LHS→rax and RHS→rbx for compound assign (try fast path, else emit+push/pop).
 * wave474: no-local — try via 0/-1/-2 eq-cascade re-call; no `let x=call()`.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_load_lr_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) == (0 - 1)) {
      return 0 - 1;
    }
    if (glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) != (0 - 2)) {
      return 0;
    }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    return 0;
  }
}
