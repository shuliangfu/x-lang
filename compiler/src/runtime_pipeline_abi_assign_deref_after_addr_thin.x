// Thin pure: DEREF after-addr peer cascade (wave472).
// G.7: part of glue_emit_assign_deref_finish_elf_c (peer-flat).
// wave472: vec_gate 0/-1 eq-cascade then slice/array/let/scalar. Tip U=6/6.
//   PRODUCT inject: LINUX PREFER (stamp w472); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_deref_vec_gate_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltr: i32): i32;
export extern function glue_emit_assign_deref_slice_call_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltk: i32, rko_pre: i32, ltr: i32): i32;
export extern function glue_emit_assign_deref_array_call_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltk: i32, rko_pre: i32, ltr: i32): i32;
export extern function glue_emit_assign_deref_let_init_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltk: i32, ltr: i32): i32;
export extern function glue_emit_assign_deref_scalar_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * DEREF after_addr — vec_gate then slice/array/let/scalar eq-cascade.
 * wave472: no-local — peers via `if (call()==0/-1)`; rko via re-call.
 *   vec_gate returns -3 → fall through (not handled as vector).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_after_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, ltk: i32): i32 {
  unsafe {
    if (glue_emit_assign_deref_vec_gate_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr) == 0) {
      return 0;
    }
    if (glue_emit_assign_deref_vec_gate_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr) == (0 - 1)) {
      return 0 - 1;
    }
    if (glue_emit_assign_deref_slice_call_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltk, pipeline_expr_kind_ord_at(arena, right_ref), ltr) == 0) {
      return 0;
    }
    if (glue_emit_assign_deref_slice_call_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltk, pipeline_expr_kind_ord_at(arena, right_ref), ltr) == (0 - 1)) {
      return 0 - 1;
    }
    if (glue_emit_assign_deref_array_call_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltk, pipeline_expr_kind_ord_at(arena, right_ref), ltr) == 0) {
      return 0;
    }
    if (glue_emit_assign_deref_array_call_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltk, pipeline_expr_kind_ord_at(arena, right_ref), ltr) == (0 - 1)) {
      return 0 - 1;
    }
    if (glue_emit_assign_deref_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltk, ltr) == 0) {
      return 0;
    }
    if (glue_emit_assign_deref_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltk, ltr) == (0 - 1)) {
      return 0 - 1;
    }
    return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
  }
}
