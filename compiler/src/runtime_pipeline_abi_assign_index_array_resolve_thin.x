// Thin pure: INDEX TYPE_ARRAY dest-type resolve (wave441/445).
// wave445: `*out_ltr =` heal Ubuntu pure-asm CG002.
// G.7: peel INDEX chain to element TYPE_ARRAY dest type.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_index_array_walk_elf_c(arena: *u8, left_ref: i32, out_root: *i32): i32;
export extern function glue_emit_assign_index_array_peel_elf_c(arena: *u8, ltr_in: i32, chain_n: i32, out_ltr: *i32): i32;

/**
 * Resolve INDEX-chain element type into out_ltr[0].
 * @return i32 — 0 ok with ltr>0; -3 not resolved
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_array_resolve_elf_c(arena: *u8, left_ref: i32, ctx: *u8, out_ltr: *i32): i32 {
  unsafe {
    let root_s: i32[1] = [];
    let peel_s: i32[1] = [];
    let chain_n: i32 = 0;
    let walk_cur: i32 = 0;
    let base_tk: i32 = 0;
    let ltr_pre: i32 = 0;
    let mod: *u8 = 0 as *u8;
    let rc: i32 = 0;
    chain_n = glue_emit_assign_index_array_walk_elf_c(arena, left_ref, &root_s[0]);
    walk_cur = root_s[0];
    ltr_pre = 0;
    if (walk_cur > 0) {
      base_tk = pipeline_expr_kind_ord_at(arena, walk_cur);
      if (base_tk == 3) {
        ltr_pre = glue_var_decl_type_ref_elf_c(arena, ctx, walk_cur);
      }
      if (ltr_pre <= 0) {
        if (base_tk == 44) {
          mod = pipeline_asm_emit_module_ref_c();
          ltr_pre = glue_field_access_field_type_ref_c(arena, mod, walk_cur);
        }
      }
      if (ltr_pre <= 0) {
        ltr_pre = pipeline_expr_resolved_type_ref(arena, walk_cur);
      }
    }
    if (ltr_pre <= 0) {
      return 0 - 3;
    }
    rc = glue_emit_assign_index_array_peel_elf_c(arena, ltr_pre, chain_n, &peel_s[0]);
    if (rc != 0) {
      return 0 - 3;
    }
    *out_ltr = peel_s[0];
    return 0;
  }
}
