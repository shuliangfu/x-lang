// Thin pure: load_operand VAR (ko==3) dispatcher (wave436).
// wave547 Soft Cap: 54 unused extern decls were tipU misses. The only
//   live call was `off = glue_var_expr_stack_off_elf_c(...)` (mid-assign
//   dropped by Ubuntu tip) plus three return-calls inside `if (local)`.
//   Store the offset through a byte cell, then always call w547_ko3_arm
//   with that offset as a parameter so each arm stays a defined UND.
// stamp w547 HARD BAN tip PRODUCT reinject.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function glue_try_binop_load_var_const_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_try_binop_load_var_rbx_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_try_binop_load_var_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;

/**
 * Dispatch VAR load once the stack offset is known.
 * off and to_rbx are parameters. Each arm is a direct return of one
 * extern so Ubuntu tip keeps all three symbols; a local `if (off < 0)`
 * after mid-assign drops the const arm.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param expr_ref i32 — VAR expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param to_rbx i32 — 1 = result in rbx, else rax
 * @param off i32 — stack slot; <0 means try the const-lit loader
 * @return i32 — 0 ok / -1 emit fail / -2 not handled
 * PLATFORM: SHARED freestanding emit.
 */
function w547_ko3_arm(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32, off: i32): i32 {
  unsafe {
    if (off < 0) {
      return glue_try_binop_load_var_const_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx);
    }
    if (to_rbx != 0) {
      return glue_try_binop_load_var_rbx_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx);
    }
    return glue_try_binop_load_var_rax_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx);
  }
}

/**
 * wave436/547: VAR (ko==3) arm.
 * Stack offset is stored in a byte cell (call-as-arg, not mid-assign)
 * then passed into w547_ko3_arm. The export always calls the helper.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — 1=result in rbx
 * @return i32 — 0 ok / -1 emit fail / -2 not handled
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_var_ko3_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    pipe_store_i32_le(&cell[0], 0, glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref));
    return w547_ko3_arm(arena, elf_ctx, expr_ref, ctx, ta, to_rbx, pipe_load_i32_le(&cell[0], 0));
  }
}
