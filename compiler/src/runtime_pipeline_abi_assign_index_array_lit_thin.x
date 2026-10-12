// Thin pure: INDEX TYPE_ARRAY lit-VAR gate/dispatcher (wave441/w469).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX array lit path.
// wave441b: monolithic tip `let x=call()` → U-starved 1/9 (L2 假绿 if PREFER).
// wave469: 3-leaf split — gate (type/kind/lit) + mid (esz home) + home
//   (lea+mov+init); no `let x=call()`. Tip U=4/4. PRODUCT inject:
//   LINUX PREFER (stamp w469); MACOS skip (g05 mega UNDEF peers).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out: *i32): i32;
export extern function glue_emit_assign_index_array_lit_mid_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, ltr: i32, lit_imm: i32, esz: i32): i32;

/**
 * INDEX TYPE_ARRAY lit-VAR gate — type/kind/lit then mid home+emit.
 * wave469: no-local — gates via `if (call()!=…)`; lit via out-slot into
 *   mid (no mid `let` binds). Co-locating lit*esz with lea/gates otherwise
 *   drops U or empties tip .o.
 * @return i32 — 0 ok; -1 err; -3 not handled; -4 handled-skip
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_array_lit_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32, ltr: i32): i32 {
  unsafe {
    let lit_slot: i32[1] = [];
    if (pipeline_type_kind_ord_at(arena, ltr) != 10) {
      return 0 - 3;
    }
    if (pipeline_expr_kind_ord_at(arena, base_ref) != 3) {
      return 0 - 3;
    }
    if (pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]) == 0) {
      return 0 - 3;
    }
    return glue_emit_assign_index_array_lit_mid_elf_c(arena, elf_ctx, right_ref, ctx, ta, base_ref, ltr, lit_slot[0], esz);
  }
}
