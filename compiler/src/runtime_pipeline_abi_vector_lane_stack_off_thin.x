// note743y.6.9: tip thin — no =[] zero-init (GCC leftover movaps SEGV under tip rsp).
// G.7: body matches runtime_pipeline_abi.x glue_vector_var_lane_stack_off_elf_c.
// PLATFORM: SHARED. First-wins inject over leftover W/T.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_expr_field_access_name_len(arena: *u8, fa_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(arena: *u8, fa_ref: i32, out: *u8): i32;
export extern function glue_field_layout_offset_for_base_field(arena: *u8, mod: *u8, base_ref: i32, name: *u8, nlen: i32): i32;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_struct_field_frame_mag_c(base_off: i32, field_off: i32, ta: i32): i32;

#[no_mangle]
export function glue_vector_var_lane_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32, lane: i32, esz: i32, ta: i32): i32 {
  let off: i32 = 0;
  let ko: i32 = 0;
  let is_enum: i32 = 0;
  let base_ref: i32 = 0;
  let base_ko: i32 = 0;
  let ltr: i32 = 0;
  let ltk: i32 = 0;
  let field_off: i32 = 0;
  let mod: *u8 = 0 as *u8;
  /* note743y.6.9: no =[] — tip-E/GCC emits movaps for zero-init; tip callers
   * may enter with rsp misaligned → SEGV on chain_fa. Slots written before read. */
  let chain_fa: i32[16];
  let chain_n: i32 = 0;
  let walk_cur: i32 = 0;
  let walk_i: i32 = 0;
  let fa_ref: i32 = 0;
  let vname: u8[256];
  let vlen: i32 = 0;
  if (arena == (0 as *u8) || ctx == (0 as *u8) || var_expr_ref <= 0 || lane < 0 || esz <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, var_expr_ref);
  }
  /* FIELD=44 on a value-VAR root (depth-1 `h.v` or chain `w.h.v`).
   * Walk to the VAR, reject pointer / enum / mid-chain *T, fold mag.
   * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
  if (ko == 44) {
    unsafe {
      is_enum = pipeline_expr_field_access_is_enum_variant(arena, var_expr_ref);
    }
    if (is_enum != 0) {
      return 0 - 1;
    }
    walk_cur = var_expr_ref;
    chain_n = 0;
    while (chain_n < 16) {
      unsafe {
        base_ko = pipeline_expr_kind_ord_at(arena, walk_cur);
      }
      if (base_ko != 44) {
        break;
      }
      unsafe {
        is_enum = pipeline_expr_field_access_is_enum_variant(arena, walk_cur);
      }
      if (is_enum != 0) {
        return 0 - 1;
      }
      chain_fa[chain_n] = walk_cur;
      chain_n = chain_n + 1;
      unsafe {
        walk_cur = pipeline_expr_field_access_base_ref(arena, walk_cur);
      }
      if (walk_cur <= 0) {
        break;
      }
    }
    if (walk_cur <= 0 || chain_n <= 0) {
      return 0 - 1;
    }
    unsafe {
      base_ko = pipeline_expr_kind_ord_at(arena, walk_cur);
    }
    if (base_ko != 3) {
      return 0 - 1;
    }
    unsafe {
      ltr = glue_var_decl_type_ref_elf_c(arena, ctx, walk_cur);
    }
    if (ltr <= 0) {
      unsafe {
        ltr = pipeline_expr_resolved_type_ref(arena, walk_cur);
      }
    }
    if (ltr > 0) {
      unsafe {
        ltk = pipeline_type_kind_ord_at(arena, ltr);
      }
      if (ltk == 9) {
        return 0 - 1;
      }
    }
    off = glue_asm_local_var_stack_off_scoped(arena, ctx, walk_cur);
    if (off < 0) {
      return 0 - 1;
    }
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
    }
    if (mod == (0 as *u8)) {
      return 0 - 1;
    }
    /* Mid-chain *T: dest is *p + field, not slot+field. Stay -1. */
    walk_i = 1;
    while (walk_i < chain_n) {
      unsafe {
        ltr = glue_field_access_field_type_ref_c(arena, mod, chain_fa[walk_i]);
      }
      if (ltr > 0) {
        unsafe {
          ltk = pipeline_type_kind_ord_at(arena, ltr);
        }
        if (ltk == 9) {
          return 0 - 1;
        }
      }
      walk_i = walk_i + 1;
    }
    /* Fold mag from VAR root to leaf (same order as emit_assign dest). */
    walk_i = chain_n - 1;
    while (walk_i >= 0) {
      fa_ref = chain_fa[walk_i];
      unsafe {
        base_ref = pipeline_expr_field_access_base_ref(arena, fa_ref);
        vlen = pipeline_expr_field_access_name_len(arena, fa_ref);
      }
      field_off = 0 - 1;
      if (vlen > 0 && vlen <= 255) {
        unsafe {
          pipeline_expr_field_access_name_into(arena, fa_ref, &vname[0]);
          field_off = glue_field_layout_offset_for_base_field(
              arena, mod, base_ref, &vname[0], vlen);
        }
      }
      if (field_off < 0) {
        unsafe {
          field_off = glue_field_access_effective_offset_c(arena, mod, fa_ref);
        }
      }
      if (field_off < 0) {
        return 0 - 1;
      }
      off = glue_struct_field_frame_mag_c(off, field_off, ta);
      if (off < 0) {
        return 0 - 1;
      }
      walk_i = walk_i - 1;
    }
    if (ta == 1) {
      return off + lane * esz;
    }
    return off - lane * esz;
  }
  if (ko != 3) {
    return 0 - 1;
  }
  off = glue_asm_local_var_stack_off_scoped(arena, ctx, var_expr_ref);
  if (off < 0) {
    return 0 - 1;
  }
  if (ta == 1) {
    return off + lane * esz;
  }
  return off - lane * esz;
}
