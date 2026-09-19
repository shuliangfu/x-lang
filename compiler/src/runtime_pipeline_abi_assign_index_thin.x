// Thin pure: assign INDEX arm dispatcher (wave441/460).
// G.7: body MUST match pipeline_asm_emit_assign_elf_c INDEX path (peer-flat).
// wave441b: LINUX product via -E (tip `let rc = call()` drops mid-peers →
//   U-starved: only generic U; L2 假绿 if PREFER).
// wave460: eq-cascade no-local (same class as w458 stores / w459 field /
//   w451 var / w454 to_rax) — Ubuntu tip U=6/6; LINUX product PREFER.
// wave607: leftover PREFER smash (`sub $0xb98`, no endbr64) extra pop+store
//   overwrites u8 `b[2]=7`. LINUX -E of this complete family is the
//   product path. HARD BAN PREFER. MACOS keep overlay. Do not Soft-Cap.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_index_struct_lit_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_index_simd_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_index_named_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_index_array_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_index_bulk_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_index_generic_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * INDEX lvalue assign arm — flat peer dispatch.
 * wave460: no-local eq-cascade (no `let rc = call()`); tip otherwise drops
 *   mid-peer calls and keeps only generic U (U-starved 假绿).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    // struct_lit try
    if (glue_emit_assign_index_struct_lit_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == 0) {
      return 0;
    }
    if (glue_emit_assign_index_struct_lit_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == (0 - 1)) {
      return 0 - 1;
    }
    // simd try
    if (glue_emit_assign_index_simd_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == 0) {
      return 0;
    }
    if (glue_emit_assign_index_simd_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == (0 - 1)) {
      return 0 - 1;
    }
    // named try
    if (glue_emit_assign_index_named_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == 0) {
      return 0;
    }
    if (glue_emit_assign_index_named_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == (0 - 1)) {
      return 0 - 1;
    }
    // array try
    if (glue_emit_assign_index_array_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == 0) {
      return 0;
    }
    if (glue_emit_assign_index_array_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == (0 - 1)) {
      return 0 - 1;
    }
    // bulk try
    if (glue_emit_assign_index_bulk_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == 0) {
      return 0;
    }
    if (glue_emit_assign_index_bulk_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == (0 - 1)) {
      return 0 - 1;
    }
    return glue_emit_assign_index_generic_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
  }
}
