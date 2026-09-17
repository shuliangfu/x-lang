// Thin pure: arr_return path b0 prep measure+lea (wave439).
// G.7: part of pipeline_asm_emit_return_elf_impl Path B0.
// PRODUCT: LINUX PREFER peer chain for arr_return.
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

/**
 * Path B0 prep: measure [N]T + lea src into rax.
 * @param out_n *i32 — n_arr out
 * @param out_esz *i32 — force_esz out
 * @param out_slice_ty *i32 — dest type ref out
 * @return i32 — 0 skip; 1 rax has src; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_emit_return_path_b0_prep_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, mod: *u8, fi: i32, out_n: *i32, out_esz: *i32, out_slice_ty: *i32): i32 {
  unsafe {
    let rty: i32 = 0;
    let sty: i32 = 0;
    let tk: i32 = 0;
    let slice_ty: i32 = 0;
    let n_arr: i32 = 0;
    let force_esz: i32 = 0;
    let rar_elem: i32 = 0;
    let rar_src: i32 = 0;
    let rar_dst: i32 = 0;
    let rar_noff: i32 = 0;
    let rc: i32 = 0;
    if (out_n == (0 as *i32) || out_esz == (0 as *i32) || out_slice_ty == (0 as *i32)) {
      return 0 - 1;
    }
    *out_n = 0;
    *out_esz = 0;
    *out_slice_ty = 0;
    if (arena == (0 as *u8) || ctx == (0 as *u8) || elf_ctx == (0 as *u8) || mod == (0 as *u8) || fi < 0) {
      return 0;
    }
    if (ta != 0 && ta != 1) {
      return 0;
    }
    if (ko != 3 && ko != 44 && ko != 47) {
      return 0;
    }
    rty = pipeline_module_func_return_type_at(mod, fi);
    sty = pipeline_expr_resolved_type_ref(arena, ret_op);
    slice_ty = 0;
    if (rty > 0) {
      tk = pipeline_type_kind_ord_at(arena, rty);
      if (tk == 11 || tk == 10) {
        slice_ty = rty;
      }
    }
    n_arr = 0;
    force_esz = 0;
    if (slice_ty > 0 && sty > 0) {
      tk = pipeline_type_kind_ord_at(arena, sty);
      if (tk == 10) {
        n_arr = pipeline_type_array_size_at(arena, sty);
        rar_elem = pipeline_type_elem_ref_at(arena, sty);
        if (rar_elem > 0) {
          force_esz = glue_array_lit_force_esz_from_elem_type_c(arena, rar_elem);
        }
        if (force_esz <= 0) {
          force_esz = 4;
        }
        if (force_esz != 1 && force_esz != 2 && force_esz != 4 && force_esz != 8 && force_esz <= 8) {
          force_esz = 4;
        }
      }
    }
    if (n_arr > 0 && n_arr <= 1024 && force_esz > 0) {
      if (force_esz > 8) {
        if (n_arr > (65536 / force_esz)) {
          n_arr = 0;
        }
      } else {
        if (n_arr > (4096 / force_esz)) {
          n_arr = 0;
        }
      }
    } else {
      n_arr = 0;
    }
    if (n_arr <= 0) {
      return 0;
    }
    if (ko == 3) {
      rar_src = glue_var_expr_stack_off_elf_c(arena, ctx, ret_op);
      if (rar_src < 0) {
        return 0;
      }
      rc = glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, ret_op, rar_src, ctx, ta);
      if (rc != 0) {
        return 0 - 1;
      }
    } else {
      if (ko == 47) {
        rar_src = pipeline_expr_index_base_ref(arena, ret_op);
        rar_dst = pipeline_expr_index_index_ref(arena, ret_op);
        rar_noff = glue_fixed_array_total_bytes_c(arena, sty, 0);
        if (rar_src <= 0 || rar_dst <= 0 || rar_noff <= 0) {
          return 0;
        }
        rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, ret_op, rar_src, rar_dst, ctx, ta, rar_noff);
        if (rc != 0) {
          return 0 - 1;
        }
      } else {
        rc = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, ret_op, ctx, ta);
        if (rc == (0 - 1)) {
          return 0 - 1;
        }
        if (rc != 0) {
          return 0;
        }
      }
    }
    *out_n = n_arr;
    *out_esz = force_esz;
    *out_slice_ty = slice_ty;
    return 1;
  }
}
