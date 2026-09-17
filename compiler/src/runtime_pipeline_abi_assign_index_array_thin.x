// Thin pure: INDEX TYPE_ARRAY dispatcher (wave441).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_index_setup_elf_c(arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, out_esz: *i32, out_base: *i32, out_idx: *i32, out_rko: *i32, out_ako: *i32, out_bk: *i32): i32;
export extern function glue_emit_assign_index_array_resolve_elf_c(arena: *u8, left_ref: i32, ctx: *u8, out_ltr: *i32): i32;
export extern function glue_emit_assign_index_array_lit_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32, ltr: i32): i32;
export extern function glue_emit_assign_index_array_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32, ltr: i32): i32;

/**
 * INDEX TYPE_ARRAY dest dispatcher (resolve → lit → rbx).
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_array_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let esz_s: i32[1] = [];
    let base_s: i32[1] = [];
    let idx_s: i32[1] = [];
    let rko_s: i32[1] = [];
    let ako_s: i32[1] = [];
    let bk_s: i32[1] = [];
    let ltr_s: i32[1] = [];
    let rc: i32 = 0;
    rc = glue_emit_assign_index_setup_elf_c(arena, expr_ref, left_ref, right_ref, &esz_s[0], &base_s[0], &idx_s[0], &rko_s[0], &ako_s[0], &bk_s[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    if (ta != 0) {
      if (ta != 1) {
        return 0 - 3;
      }
    }
    rc = glue_emit_assign_index_array_resolve_elf_c(arena, left_ref, ctx, &ltr_s[0]);
    if (rc != 0) {
      return 0 - 3;
    }
    rc = glue_emit_assign_index_array_lit_elf_c(arena, elf_ctx, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0], ltr_s[0]);
    if (rc == 0 - 4) {
      // lit path claimed hit — do not run rbx twin.
      return 0 - 3;
    }
    if (rc != 0 - 3) {
      return rc;
    }
    return glue_emit_assign_index_array_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0], ltr_s[0]);
  }
}
