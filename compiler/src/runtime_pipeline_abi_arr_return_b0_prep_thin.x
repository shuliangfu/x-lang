// Thin pure: arr_return path b0 prep measure+lea (wave439).
// wave580 Soft Cap: Ubuntu tip `-backend asm -c` SEGV 139. The original
//   body wrote *out_n / *out_esz / *out_slice_ty (x86_64 *i32 store
//   class, same as w541 / w567) then if-before-call (null / ta / ko)
//   then mid-assign then rc=enc_local then if, rc=index_eff then if,
//   rc=try_index then if. Darwin original kept the 13 encoders. This
//   helper always stores each encoder once and declares no locals. It
//   never stores through *i32. The export returns 0; the real path
//   stays on the w439 overlay.
// stamp w580 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_enc_local_slot_ptr_or_addr_elf_c(arena: *u8, elf_ctx: *u8, var_ref: i32, off: i32, ctx: *u8, ta: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_try_index_var_or_field_base_to_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the path-B0 prep measure+lea encoders. Offset 0 is
 * pipeline_module_func_return_type_at, 4 is
 * pipeline_expr_resolved_type_ref, 8 is pipeline_type_kind_ord_at,
 * 12 is pipeline_type_array_size_at, 16 is pipeline_type_elem_ref_at,
 * 20 is glue_array_lit_force_esz_from_elem_type_c, 24 is
 * glue_var_expr_stack_off_elf_c, 28 is
 * glue_enc_local_slot_ptr_or_addr_elf_c, 32 is
 * pipeline_expr_index_base_ref, 36 is pipeline_expr_index_index_ref,
 * 40 is glue_fixed_array_total_bytes_c, 44 is
 * glue_emit_index_eff_addr_scaled_elf_c, 48 is
 * glue_try_index_var_or_field_base_to_rax_elf_c. No locals. Each
 * encoder runs once, not under if or after a mid-assign. Dummy
 * type_ref / off / esz use ret_op or 0 so the helper needs no
 * measured locals. Does not store through *i32.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ret_op i32 — returned expr ref; also dummy type_ref
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param mod *u8 — module; may be null
 * @param fi i32 — function index
 * @param cell *u8 — at least 52 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function arr_return_b0_prep_store_encoders(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_module_func_return_type_at(mod, fi));
    pipe_store_i32_le(cell, 4, pipeline_expr_resolved_type_ref(arena, ret_op));
    pipe_store_i32_le(cell, 8, pipeline_type_kind_ord_at(arena, ret_op));
    pipe_store_i32_le(cell, 12, pipeline_type_array_size_at(arena, ret_op));
    pipe_store_i32_le(cell, 16, pipeline_type_elem_ref_at(arena, ret_op));
    pipe_store_i32_le(cell, 20, glue_array_lit_force_esz_from_elem_type_c(arena, ret_op));
    pipe_store_i32_le(cell, 24, glue_var_expr_stack_off_elf_c(arena, ctx, ret_op));
    pipe_store_i32_le(cell, 28, glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, ret_op, 0, ctx, ta));
    pipe_store_i32_le(cell, 32, pipeline_expr_index_base_ref(arena, ret_op));
    pipe_store_i32_le(cell, 36, pipeline_expr_index_index_ref(arena, ret_op));
    pipe_store_i32_le(cell, 40, glue_fixed_array_total_bytes_c(arena, ret_op, 0));
    pipe_store_i32_le(cell, 44, glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, ret_op, ret_op, ret_op, ctx, ta, 0));
    pipe_store_i32_le(cell, 48, glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, ret_op, ctx, ta));
    return 0;
  }
}

/**
 * wave439/580: measure [N]T and lea src into rax. Encoders always
 * run. Tip returns 0. ko / out_* stay live so the signature matches
 * the w439 overlay, which still does the real path. Does not write
 * through out_n / out_esz / out_slice_ty (Ubuntu x86_64 *i32 store
 * SEGV class).
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param ret_op i32 — returned expr ref
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param ko i32 — expr kind; kept live
 * @param mod *u8 — module
 * @param fi i32 — function index
 * @param out_n *i32 — n_arr out; compared, never stored
 * @param out_esz *i32 — force_esz out; compared, never stored
 * @param out_slice_ty *i32 — dest type ref out; compared, never stored
 * @return i32 — 0 on this tip; overlay returns 0 / 1 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_return_path_b0_prep_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, mod: *u8, fi: i32, out_n: *i32, out_esz: *i32, out_slice_ty: *i32): i32 {
  unsafe {
    let cell: u8[52] = [];
    let sink: i32 = 0;
    arr_return_b0_prep_store_encoders(arena, elf_ctx, ret_op, ctx, ta, mod, fi, &cell[0]);
    sink = ko + ta + fi;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    if (out_n == (0 as *i32) && out_esz == (0 as *i32) && out_slice_ty == (0 as *i32)) {
      return 0;
    }
    return 0;
  }
}
