// Thin pure: INDEX esz>8 bulk copy dispatcher (wave441/w468).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX path (peer-flat).
// wave441b: monolithic tip `let x=call()` → U-starved 3/12 (L2 假绿 if PREFER).
// wave468: split like simd/named — setup + rko gate + lval/call peers;
//   no `let x = call()`. Tip U=3/3. PRODUCT inject: LINUX PREFER (stamp w468);
//   MACOS skip (g05 mega UNDEF peers).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_index_setup_elf_c(arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, out_esz: *i32, out_base: *i32, out_idx: *i32, out_rko: *i32, out_ako: *i32, out_bk: *i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_index_bulk_lval_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32;
export extern function glue_emit_assign_index_bulk_call_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32;

/**
 * INDEX esz>8 bulk spill-copy dispatcher — setup, rko gate, peer body.
 * wave468: no-local — setup via `if (call()!=0)`; rhs kind via re-call
 *   into lval (3/44/47) or call (48/49) peer. Monolithic tip otherwise
 *   drops mid-peer U.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_bulk_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
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
    if (esz_s[0] <= 8) {
      return 0 - 3;
    }
    if (pipeline_expr_kind_ord_at(arena, right_ref) == 3) {
      return glue_emit_assign_index_bulk_lval_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0]);
    }
    if (pipeline_expr_kind_ord_at(arena, right_ref) == 44) {
      return glue_emit_assign_index_bulk_lval_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0]);
    }
    if (pipeline_expr_kind_ord_at(arena, right_ref) == 47) {
      return glue_emit_assign_index_bulk_lval_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0]);
    }
    if (pipeline_expr_kind_ord_at(arena, right_ref) == 48) {
      return glue_emit_assign_index_bulk_call_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0]);
    }
    if (pipeline_expr_kind_ord_at(arena, right_ref) == 49) {
      return glue_emit_assign_index_bulk_call_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta, base_s[0], idx_s[0], esz_s[0]);
    }
    return 0 - 3;
  }
}
