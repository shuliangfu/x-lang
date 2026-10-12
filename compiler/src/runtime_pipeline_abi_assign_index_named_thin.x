// Thin pure: INDEX TYPE_NAMED dispatcher (wave441/w467).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX path (peer-flat).
// wave441b: monolithic tip `let x=call()` → U-starved 1/8 (L2 假绿 if PREFER).
// wave467: split like simd/array — setup + type peel + body peer;
//   no `let x = call()`. Tip U=5/5. PRODUCT inject: LINUX PREFER (stamp w467);
//   MACOS skip (g05 mega UNDEF peers).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_index_setup_elf_c(arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, out_esz: *i32, out_base: *i32, out_idx: *i32, out_rko: *i32, out_ako: *i32, out_bk: *i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function glue_emit_assign_index_named_body_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32, ltr: i32): i32;

/**
 * INDEX TYPE_NAMED path dispatcher — setup, peel element type, body init.
 * wave467: no-local — setup via `if (call()!=0)`; left/base type via
 *   re-call into body args (no mid `let` binds). Monolithic tip otherwise
 *   drops mid-peer U.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_named_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
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
    if (ta != 0) {
      if (ta != 1) {
        return 0 - 3;
      }
    }
    if (pipeline_expr_resolved_type_ref(arena, left_ref) > 0) {
      return glue_emit_assign_index_named_body_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0], pipeline_expr_resolved_type_ref(arena, left_ref));
    }
    if (pipeline_expr_resolved_type_ref(arena, base_s[0]) <= 0) {
      return 0 - 3;
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, base_s[0])) != 10) {
      if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, base_s[0])) != 11) {
        if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, base_s[0])) != 9) {
          return 0 - 3;
        }
      }
    }
    if (pipeline_type_elem_ref_at(arena, pipeline_expr_resolved_type_ref(arena, base_s[0])) <= 0) {
      return 0 - 3;
    }
    return glue_emit_assign_index_named_body_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0], pipeline_type_elem_ref_at(arena, pipeline_expr_resolved_type_ref(arena, base_s[0])));
  }
}
