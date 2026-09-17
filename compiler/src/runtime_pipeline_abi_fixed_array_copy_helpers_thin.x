// Thin pure: fixed_array_copy HELPERS leaf (lea-not-load arg first-export).
// G.7: body MUST match glue_call_arg_var_use_lea_not_load_elf_c in
// runtime_pipeline_abi.x / runtime_pipeline_abi_fixed_array_copy_thin.x.
// ensure: pipeline_abi_inject_fixed_array_copy_thin dispatches this on LINUX.
// wave418: LINUX PREFER first-export-only (full tip -c XT001 misattr;
//   arr_e1 -c green ~5035B). MACOS still full thin PREFER.
//   Remaining arrcopy exports tip reinject still BAN on LINUX.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.

export extern function glue_align_next_offset(ctx: *u8): void;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, force_esz: i32, ta: i32, ctx: *u8, dest_elem_ty: i32): i32;
export extern function glue_asm_lea_rax_common_adrp_arm64(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_asm_lea_rax_common_rip_x86(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_async_cps_emit_phase_reset(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx: *u8, src_spill: i32, dst_spill: i32, esz: i32, ta: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_emit_sret_memcpy_rbx_to_home_elf_c(elf_ctx: *u8, nbytes: i32, ta: i32): i32;
export extern function glue_emit_sret_return_from_var_elf_c(arena: *u8, elf_ctx: *u8, var_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_enc_local_slot_ptr_or_addr_elf_c(arena: *u8, elf_ctx: *u8, var_ref: i32, off: i32, ctx: *u8, ta: i32): i32;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_float_promote_src_ty_ref_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_maybe_promote_f32_to_f64_rax_elf_c(arena: *u8, elf_ctx: *u8, rty: i32, sty: i32, ta: i32): i32;
export extern function glue_peel_as_array_slice_ascription_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_pipeline_asm_al_nc_seq_take_c(): i32;
export extern function glue_struct_field_frame_mag_c(base_off: i32, foff: i32, ta: i32): i32;
export extern function glue_try_index_var_or_field_base_to_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_try_return_slice_escape_from_fixed_array_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_bump_next_offset_for_array_lit(arena: *u8, expr_ref: i32, ctx: *u8): void;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_array_lit_force_esz_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, force_esz: i32): i32;
export extern function pipeline_asm_emit_ctx_sret_active_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_ret_sz_get(): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_vector_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function pipeline_elf_ctx_add_common_sym(ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function pipeline_asm_array_lit_elem_type_ref(arena: *u8, array_lit_expr_ref: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, type_ref: i32, stack_slot_off: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_emit_slice_from_array_let_init_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, let_idx: i32, init_ref: i32, let_type_ref: i32, ctx: *u8, ta: i32, slice_slot_off: i32): i32;
export extern function glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena: *u8, elf_ctx: *u8, array_lit_ref: i32, elem_ref: i32, ctx: *u8, ta: i32, force_esz: i32): i32;
export extern function glue_expr_emit_may_clobber_rbx_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_call_arg_resolve_var_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function asm_local_var_slot_holds_indirect_ptr(arena: *u8, var_ref: i32, mod: *u8, ctx: *u8): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, dst: *u8): void;
export extern function pipeline_module_num_funcs(mod: *u8): i32;
export extern function pipeline_module_func_param_type_ref_for_name(mod: *u8, fi: i32, name: *u8, nlen: i32): i32;
export extern function asm_ctx_scope_block_ref_at(ctx: *u8): i32;
export extern function pipeline_block_resolve_var_type_ref(arena: *u8, br: i32, name: *u8, nlen: i32): i32;
export extern function glue_type_ref_is_named_struct_layout_elf_c(arena: *u8, mod: *u8, ty_ref: i32): i32;
export extern function glue_type_is_fixed_array(arena: *u8, ty_ref: i32): i32;
export extern function glue_emit_func_param_is_indirect_array_slot_c(arena: *u8, mod: *u8, var_ref: i32): i32;

/**
 * CALL-arg VAR: lea stack payload only for MEMORY >16B named structs / T[N].
 * INTEGER-class ≤16B (including unknown size_simple=0 → 8B) must load bits.
 * G.7: first-wins twin of runtime_pipeline_abi.x wave190.
 * PLATFORM: LINUX+MACOS x86_64 SysV INTEGER load; MACOS|ARM64 x0 bits.
 * @param arena *u8 — ASTArena*; null → 0
 * @param expr_ref i32 — EXPR_VAR ref
 * @param ctx *u8 — AsmFuncCtx*
 * @return i32 — 1 use lea; 0 use load / unknown
 */
#[no_mangle]
export function glue_call_arg_var_use_lea_not_load_elf_c(arena: *u8, expr_ref: i32, ctx: *u8): i32 {
  let mod: *u8 = 0 as *u8;
  let holds: i32 = 0;
  let ko: i32 = 0;
  /* Cap 4.2.8: var_name_into memset(out,0,256); align mega runtime_pipeline_abi.x. */
  let vname: u8[256] = [];
  let vlen: i32 = 0;
  let fi: i32 = 0;
  let nf: i32 = 0;
  let pty: i32 = 0;
  let tk: i32 = 0;
  let scope_br: i32 = 0;
  let decl_ty: i32 = 0;
  let sz: i32 = 0;
  if (arena == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0) {
    return 0;
  }
  // M2 class A: export-extern call must sit in unsafe (-backend asm T001).
  // PLATFORM: SHARED — asm typeck contract; mega thin small-file reproduce.
  unsafe {
    mod = pipeline_asm_emit_module_ref_c();
  }
  unsafe {
    holds = asm_local_var_slot_holds_indirect_ptr(arena, expr_ref, mod, ctx);
  }
  if (holds != 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko != 3) {
    return 0;
  }
  unsafe {
    vlen = pipeline_expr_var_name_len(arena, expr_ref);
  }
  if (vlen <= 0 || vlen > 255) {
    return 0;
  }
  unsafe {
    pipeline_expr_var_name_into(arena, expr_ref, &vname[0]);
    fi = pipeline_asm_emit_func_index_c();
  }
  if (mod != (0 as *u8) && fi >= 0) {
    unsafe {
      nf = pipeline_module_num_funcs(mod);
    }
    if (fi < nf) {
      unsafe {
        pty = pipeline_module_func_param_type_ref_for_name(mod, fi, &vname[0], vlen);
      }
      if (pty > 0) {
        unsafe {
          tk = pipeline_type_kind_ord_at(arena, pty);
        }
        if (tk == 9) {
          return 0;
        }
      }
    }
  }
  unsafe {
    scope_br = asm_ctx_scope_block_ref_at(ctx);
  }
  decl_ty = 0;
  if (scope_br > 0) {
    unsafe {
      decl_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, &vname[0], vlen);
    }
  }
  if (decl_ty <= 0) {
    unsafe {
      decl_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
    }
  }
  if (decl_ty <= 0) {
    return 0;
  }
  // M2 class A: remaining export-extern calls in this leaf.
  /* wave347: scalar INTEGER/FP/PTR never lea (see mega twin). PLATFORM: SHARED. */
  unsafe {
    tk = pipeline_type_kind_ord_at(arena, decl_ty);
  }
  if (tk == 0 || tk == 1 || tk == 2 || tk == 3 || tk == 4 || tk == 5
      || tk == 6 || tk == 7 || tk == 9 || tk == 14 || tk == 15) {
    return 0;
  }
  unsafe {
    if (glue_type_ref_is_named_struct_layout_elf_c(arena, mod, decl_ty) != 0) {
      sz = glue_type_size_simple(mod, arena, decl_ty, 0);
      if (sz <= 0) {
        sz = glue_type_named_layout_size_any_module_elf_c(arena, decl_ty);
      }
      if (sz > 16) {
        return 1;
      }
      return 0;
    }
    if (glue_type_is_fixed_array(arena, decl_ty) != 0) {
      if (mod != (0 as *u8) && fi >= 0) {
        if (glue_emit_func_param_is_indirect_array_slot_c(arena, mod, expr_ref) != 0) {
          return 0;
        }
      }
      return 1;
    }
  }
  return 0;
}

