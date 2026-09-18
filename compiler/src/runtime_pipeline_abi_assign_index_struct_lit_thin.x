// Thin pure: INDEX STRUCT_LIT dispatcher (wave441/461).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.
// wave441b: LINUX product via -E (tip `let rc = call()` drops setup/arr →
//   U-starved: only rbx U; L2 假绿 if PREFER).
// wave461: eq-cascade no-local (same class as w458–w460) — Ubuntu tip U=3/3;
//   LINUX product PREFER.

export extern function glue_emit_assign_index_setup_elf_c(arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, out_esz: *i32, out_base: *i32, out_idx: *i32, out_rko: *i32, out_ako: *i32, out_bk: *i32): i32;
export extern function glue_emit_assign_index_struct_lit_arr_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32;
export extern function glue_emit_assign_index_struct_lit_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32;

/**
 * INDEX STRUCT_LIT path dispatcher.
 * wave461: no-local — setup via `if (setup()!=0)`; arr via eq-cascade
 *   (no `let rc = call()`); tip otherwise drops setup/arr U (U-starved 假绿).
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_struct_lit_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let esz_s: i32[1] = [];
    let base_s: i32[1] = [];
    let idx_s: i32[1] = [];
    let rko_s: i32[1] = [];
    let ako_s: i32[1] = [];
    let bk_s: i32[1] = [];
    if (glue_emit_assign_index_setup_elf_c(arena, expr_ref, left_ref, right_ref, &esz_s[0], &base_s[0], &idx_s[0], &rko_s[0], &ako_s[0], &bk_s[0]) != 0) {
      return 0 - 1;
    }
    if (ako_s[0] != 28) {
      return 0 - 3;
    }
    if (rko_s[0] != 45) {
      return 0 - 3;
    }
    if (esz_s[0] <= 0) {
      return 0 - 3;
    }
    if (bk_s[0] != 3) {
      return 0 - 3;
    }
    // arr try — success / hard-fail without let-bound call result
    if (glue_emit_assign_index_struct_lit_arr_elf_c(arena, elf_ctx, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0]) == 0) {
      return 0;
    }
    if (glue_emit_assign_index_struct_lit_arr_elf_c(arena, elf_ctx, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0]) == (0 - 1)) {
      return 0 - 1;
    }
    return glue_emit_assign_index_struct_lit_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0]);
  }
}
