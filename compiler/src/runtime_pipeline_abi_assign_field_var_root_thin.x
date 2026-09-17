// Thin pure: FIELD VAR-root orchestrator (wave441).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD path (peer-flat).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, nlen: i32): i32;
export extern function asm_ctx_local_find_offset(ctx: *u8, name: *u8, nlen: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_expr_field_access_load_byte_sz(arena: *u8, mod: *u8, expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_emit_assign_field_chain_walk_elf_c(arena: *u8, left_ref: i32, out_fa: *i32, out_root: *i32): i32;
export extern function glue_emit_assign_field_ptr_hit_elf_c(arena: *u8, mod: *u8, chain_fa: *i32, chain_n: i32, hit_in: i32): i32;
export extern function glue_emit_assign_field_mag_fold_elf_c(arena: *u8, mod: *u8, chain_fa: *i32, chain_n: i32, off_in: i32, hit_in: i32, ta: i32, out_off: *i32): i32;
export extern function glue_emit_assign_field_var_stores_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32;

/**
 * FIELD VAR-root frame-mag path — flat helper dispatch.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_var_root_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let base_ref: i32 = 0;
    let chain_fa: i32[16] = [];
    let chain_n: i32 = 0;
    let walk_cur: i32 = 0;
    let root_slot: i32[1] = [];
    let off_slot: i32[1] = [];
    let base_kind: i32 = 0;
    let vname: u8[256] = [];
    let vlen: i32 = 0;
    let var_off: i32 = 0;
    let mod: *u8 = 0 as *u8;
    let field_off: i32 = 0;
    let load_sz: i32 = 0;
    let off: i32 = 0;
    let hit: i32 = 0;
    let ltr_pre: i32 = 0;
    let ltk_pre: i32 = 0;
    let rc: i32 = 0;
    base_ref = pipeline_expr_field_access_base_ref(arena, left_ref);
    if (base_ref <= 0) {
      return 0 - 3;
    }
    chain_n = glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]);
    walk_cur = root_slot[0];
    if (walk_cur <= 0) {
      return 0 - 3;
    }
    if (chain_n <= 0) {
      return 0 - 3;
    }
    base_kind = pipeline_expr_kind_ord_at(arena, walk_cur);
    if (base_kind != 3) {
      return 0 - 3;
    }
    vlen = pipeline_expr_var_name_len(arena, walk_cur);
    if (vlen <= 0) {
      return 0 - 1;
    }
    if (vlen > 255) {
      return 0 - 1;
    }
    pipeline_expr_var_name_into(arena, walk_cur, &vname[0]);
    var_off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
    if (var_off < 0) {
      var_off = asm_ctx_local_find_offset(ctx, &vname[0], vlen);
    }
    if (var_off < 0) {
      return 0 - 1;
    }
    mod = pipeline_asm_emit_module_ref_c();
    field_off = glue_field_access_effective_offset_c(arena, mod, left_ref);
    load_sz = pipeline_expr_field_access_load_byte_sz(arena, mod, left_ref);
    if (load_sz <= 0) {
      load_sz = 4;
    }
    off = var_off;
    hit = 1;
    ltr_pre = glue_var_decl_type_ref_elf_c(arena, ctx, walk_cur);
    if (ltr_pre <= 0) {
      ltr_pre = pipeline_expr_resolved_type_ref(arena, walk_cur);
    }
    if (ltr_pre > 0) {
      ltk_pre = pipeline_type_kind_ord_at(arena, ltr_pre);
      if (ltk_pre == 9) {
        hit = 0;
      }
    }
    hit = glue_emit_assign_field_ptr_hit_elf_c(arena, mod, &chain_fa[0], chain_n, hit);
    hit = glue_emit_assign_field_mag_fold_elf_c(arena, mod, &chain_fa[0], chain_n, off, hit, ta, &off_slot[0]);
    off = off_slot[0];
    rc = glue_emit_assign_field_var_stores_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n);
    return rc;
  }
}
