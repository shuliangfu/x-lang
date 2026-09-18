// Thin pure: index_addr await-peel arm (wave479).
// G.7: part of glue_binop_operand_index_addr_clobbers_rbx_elf_c (peer-flat).
// wave479: tip U=2/2. PRODUCT inject: LINUX PREFER (stamp w479); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena: *u8, expr_ref: i32): i32;

/**
 * Await peel: recurse on unary operand (caller already gated is_await).
 * wave479: no-local — re-call; ban `let x=call()`.
 * @return i32 — clobber decision
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_binop_index_addr_await_elf_c(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    if (pipeline_expr_unary_operand_ref_at(arena, expr_ref) > 0) {
      return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, pipeline_expr_unary_operand_ref_at(arena, expr_ref));
    }
    return 0;
  }
}
