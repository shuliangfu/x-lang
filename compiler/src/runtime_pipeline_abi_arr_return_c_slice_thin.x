// Thin pure: arr_return path c dest SLICE dual-GP (wave439).
// G.7: part of pipeline_asm_emit_return_elf_impl Path C.
// PRODUCT: LINUX PREFER peer chain for arr_return.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, force_esz: i32, ta: i32, ctx: *u8, dest_elem_ty: i32): i32;
export extern function pipeline_asm_bump_next_offset_for_array_lit(arena: *u8, expr_ref: i32, ctx: *u8): void;
export extern function pipeline_asm_emit_array_lit_force_esz_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, force_esz: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Path C arm: dest TYPE_SLICE fat pack (dual-GP).
 * @return i32 — 0 not taken; 1 handled ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_emit_return_path_c_slice_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let rty: i32 = 0;
    let sty: i32 = 0;
    let tk: i32 = 0;
    let slice_ty: i32 = 0;
    let n_arr: i32 = 0;
    let rar_elem: i32 = 0;
    let force_esz: i32 = 0;
    let durable: i32 = 0;
    let len_arg: i32 = 0;
    let rc: i32 = 0;
    if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || mod == (0 as *u8) || fi < 0) {
      return 0;
    }
    if (ta != 0 && ta != 1) {
      return 0;
    }
    rty = pipeline_module_func_return_type_at(mod, fi);
    sty = pipeline_expr_resolved_type_ref(arena, ret_op);
    slice_ty = 0;
    if (rty > 0) {
      tk = pipeline_type_kind_ord_at(arena, rty);
      if (tk == 11) {
        slice_ty = rty;
      }
    }
    if (slice_ty == 0 && sty > 0) {
      tk = pipeline_type_kind_ord_at(arena, sty);
      if (tk == 11) {
        slice_ty = sty;
      }
    }
    if (slice_ty <= 0) {
      return 0;
    }
    n_arr = pipeline_expr_array_lit_num_elems_at(arena, ret_op);
    rar_elem = pipeline_type_elem_ref_at(arena, slice_ty);
    force_esz = glue_array_lit_force_esz_from_elem_type_c(arena, rar_elem);
    if (n_arr < 0 || n_arr > 1024) {
      return 0 - 1;
    }
    durable = 0;
    rar_elem = pipeline_type_elem_ref_at(arena, slice_ty);
    rc = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, ret_op, force_esz, ta, ctx, rar_elem);
    if (rc == 0) {
      durable = 1;
    } else {
      rc = pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, ret_op, ctx, ta, force_esz);
      if (rc != 0) {
        return 0 - 1;
      }
    }
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (ta == 1) {
      len_arg = 1;
    } else {
      len_arg = 2;
    }
    rc = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_arg, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (durable == 0 && n_arr > 0) {
      pipeline_asm_bump_next_offset_for_array_lit(arena, ret_op, ctx);
    }
    return 1;
  }
}
