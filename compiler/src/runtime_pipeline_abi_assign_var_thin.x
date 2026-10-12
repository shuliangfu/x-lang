// Thin pure: VAR assign gate/dispatcher (wave441/451/473).
// G.7: match glue_emit_assign_var_elf_c in assign_thin / mega (scalar +
//   array/vector/struct let-init arms; modlet/name-path deferred).
// wave451: LINUX PREFER reshape — tip SEGV root is `let x = call()`.
// wave473: gate + try_let + finish + store{,slice,f32,pair} no-local split.
//   Tip U=4/4 (was 10/18). PRODUCT inject: LINUX PREFER (stamp w473); MACOS skip.
// wave600: LINUX -E replace smash leftover PREFER T (`sub $0x898`,
//   no endbr64, cltq on ctx). HARD BAN PREFER. MACOS keep overlay.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_var_try_let_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_var_finish_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * VAR lvalue assign gate — null/stack_off checks; ako==28 → try_let; else finish.
 * wave473: no-local — no `let x=call()`. Deferred vs mega: modlet shared-name,
 *   slice←array_lit / slice←[N]T, name-buffer lookup.
 * wave600: LINUX product path is host-cc -E of this dispatcher (PREFER BAN).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_var_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (arena == (0 as *u8)) {
      return 0 - 1;
    }
    if (elf_ctx == (0 as *u8)) {
      return 0 - 1;
    }
    if (ctx == (0 as *u8)) {
      return 0 - 1;
    }
    if (left_ref <= 0) {
      return 0 - 1;
    }
    if (right_ref <= 0) {
      return 0 - 1;
    }
    if (glue_var_expr_stack_off_elf_c(arena, ctx, left_ref) < 0) {
      return 0 - 1;
    }
    if (pipeline_expr_kind_ord_at(arena, expr_ref) == 28) {
      if (glue_emit_assign_var_try_let_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == 0) {
        return 0;
      }
    }
    return glue_emit_assign_var_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
  }
}
