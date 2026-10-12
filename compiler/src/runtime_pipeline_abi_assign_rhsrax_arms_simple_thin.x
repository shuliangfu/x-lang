// Thin pure: assign rhs arms plain/add/sub/mul/and/or/xor (wave448/w474).
// G.7: part of glue_emit_assign_rhs_to_rax_elf_c.
// wave474: split from rhsrax_arms mega; one-liner peers. Tip U=7/7.
//   PRODUCT inject: LINUX PREFER (stamp w474); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_rhs_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_binop_add_rax_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32;
export extern function glue_emit_binop_sub_rax_minus_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32;
export extern function glue_emit_binop_mul_rax_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32;
export extern function backend_enc_and_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_or_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_xor_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Plain assign RHS→rax peer.
 * @return i32 — status from glue_emit_assign_rhs_elf_c
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_plain_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return glue_emit_assign_rhs_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
}

/**
 * Compound += arm — add rax,rbx.
 * @return i32 — status
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_add_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  }
}

/**
 * Compound -= arm — sub rax,rbx.
 * @return i32 — status
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_sub_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return glue_emit_binop_sub_rax_minus_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  }
}

/**
 * Compound *= arm — mul rax,rbx.
 * @return i32 — status
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_mul_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  }
}

/**
 * Compound &= arm — and rbx,rax.
 * @return i32 — status
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_and_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return backend_enc_and_rbx_rax_arch(elf_ctx, ta);
  }
}

/**
 * Compound |= arm — or rbx,rax.
 * @return i32 — status
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_or_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return backend_enc_or_rbx_rax_arch(elf_ctx, ta);
  }
}

/**
 * Compound ^= arm — xor rbx,rax.
 * @return i32 — status
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_xor_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
  }
}
