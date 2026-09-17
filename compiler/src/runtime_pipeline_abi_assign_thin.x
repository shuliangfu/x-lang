// Thin pure: wave142 dest-in-rbx assign cluster (C-extract → .x).
// G.7: bodies MUST match glue_assign_lhs_f32_type_ref_elf_c /
// glue_emit_assign_rhs_* / pipeline_asm_emit_assign_elf_c /
// glue_field_assign_pair_base_ref_c / glue_body_expr_stmt_at_c
// in runtime_pipeline_abi.x. ensure injects via inject_thin_leaf
// (PREFER_ASM; no mega -E; no awk C-extract).
// Local asg_thin_* helpers are TU-private names (asm still emits T;
// unique prefix avoids first-wins replace of product pipe_*/align).
// w157 / glue_asm_sum_block_call_spill_bytes stay leftover (not this leaf).
// wave403: MACOS PREFER / LINUX hard-skip BAN tip reinject.
//   Ubuntu tip -c/-E XT001@asg_thin_store_i32_le MISATTRIBUTED;
//   thru_store-only -c green; root = LINUX typeck/arena full leaf.
// PLATFORM: SHARED freestanding asm emit · LINUX gold · MACOS.

export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_emit_float_lit_to_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32, force_ty_ref: i32, call_abi_widen_f64: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_try_binop_left_rax_right_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_binop_add_rax_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32;
export extern function glue_emit_binop_sub_rax_minus_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32;
export extern function glue_emit_binop_mul_rax_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32;
export extern function glue_binop_operand_is_scalar_f32_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_is_scalar_f64_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_is_unsigned_elf_c(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32;
export extern function glue_binop_operand_is_64bit_elf_c(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32;
export extern function pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx: *u8, ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_divsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_divss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_idiv_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_rem_mod_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_and_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_or_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_xor_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rbx_to_ecx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_shl_cl_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_shl_cl_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_shr_cl_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_shr_cl_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_sar_cl_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_sar_cl_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_binop_var_slot_cache_clear(): void;
export extern function glue_binop_var_slot_cache_invalidate_slot(off: i32): void;
export extern function glue_binop_var_slot_cache_kill_def_at_slot(off: i32): void;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_expr_field_access_load_byte_sz(arena: *u8, mod: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_enc_local_slot_ptr_or_addr_rbx_elf_c(arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx: *u8, elem_sz: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_struct_lit_fields_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_field_layout_offset_for_base_field(a: *u8, m: *u8, base_ref: i32, field_name: *u8, flen: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, slot_off: i32, ta: i32): i32;
export extern function backend_enc_store_eax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx: *u8, src_spill: i32, dst_spill: i32, nbytes: i32, ta: i32): i32;
export extern function glue_expr_emit_may_clobber_rbx_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_index_assign_addr_cache_hit(arena: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;
export extern function glue_index_assign_finish_store_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32, ta: i32): i32;
export extern function glue_try_index_var_lit_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_plus_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_plus_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_mul_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_plus_var_plus_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_var_plus_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_var_minus_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_add3_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_plus_var_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_var_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_add3_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_subadd3_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_subsub3_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_add3_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function asm_ctx_local_find_offset(ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_index_scratch_spill_invalidate_var(arena: *u8, elf_ctx: *u8, ctx: *u8, var_ref: i32, ta: i32): void;
export extern function pipeline_asm_modlet_name_is_shared(name: *u8, name_len: i32): i32;
export extern function pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_slice_dual_gp_bump_past_home_c(ctx: *u8, data_home: i32, ta: i32): void;
export extern function glue_slice_dual_gp_length_off_c(data_home: i32, ta: i32): i32;
export extern function pipeline_asm_emit_array_lit_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_bump_next_offset_for_array_lit(arena: *u8, expr_ref: i32, ctx: *u8): void;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, arr_ty: i32, stack_off: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_off: i32, type_ref: i32): i32;
export extern function glue_float_promote_src_ty_ref_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_maybe_promote_f32_to_f64_rax_elf_c(arena: *u8, elf_ctx: *u8, dest_ty_ref: i32, src_ty_ref: i32, ta: i32): i32;
export extern function glue_maybe_demote_f64_to_f32_eax_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, dest_ty_ref: i32, src_expr_ref: i32, ta: i32): i32;
export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function ast_ast_block_stmt_order_kind(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_stmt_order_idx(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, ei: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_method_call_base_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_arg_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_const_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_let_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_if_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_if_cond_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_if_then_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_if_else_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_while_cond_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_while_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_num_for_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_for_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_for_cond_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_for_step_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_for_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_ast_block_num_regions(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_num_labeled_stmts(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_labeled_is_goto(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_block_labeled_return_expr_ref(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out_imm: *i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_arm64_mov_x19_to_x0_elf_c(elf_ctx: *u8): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_emit_slice_from_array_let_init_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, let_idx: i32, init_ref: i32, let_type_ref: i32, ctx: *u8, ta: i32, slice_slot_off: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_peel_as_array_slice_ascription_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_struct_field_frame_mag_c(base_off: i32, foff: i32, ta: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function glue_x86_store_rdx_to_rbx8_elf_c(elf_ctx: *u8): i32;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_module_func_body_ref_at(module: *u8, fi: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function glue_store_retval_pair_to_rbp_elf_c(m: *u8, arena: *u8, elf_ctx: *u8, ty_ref: i32, slot_off: i32, ta: i32, init_ref: i32, ctx: *u8): i32;


/**
 * Store host LE i32 at base[off..off+3]. Null base or off negative -> no-op.
 * @param base *u8 - object base
 * @param off i32 - byte offset
 * @param v i32 - value
 * @return void
 * G.7 same pattern as driver_abi_store_i32_le (wave19); local copy - not exported.
 * PLATFORM: SHARED LP64 little-endian.
 */
function asg_thin_store_i32_le(base: *u8, off: i32, v: i32): void {
  if (base == 0 as *u8) {
    return;
  }
  if (off < 0) {
    return;
  }
  unsafe {
    let u: u32 = v as u32;
    base[off] = (u & 255) as u8;
    base[off + 1] = ((u / 256) & 255) as u8;
    base[off + 2] = ((u / 65536) & 255) as u8;
    base[off + 3] = ((u / 16777216) & 255) as u8;
  }
}

/**
 * Load host LE i32 from base[off..off+3]. Null base or off negative -> 0.
 * @param base *u8 - object base
 * @param off i32 - byte offset
 * @return i32 - signed value (u32 reconstruct then cast)
 * G.7 pair of asg_thin_store_i32_le; local - not exported.
 * PLATFORM: SHARED LP64 little-endian.
 */
function asg_thin_load_i32_le(base: *u8, off: i32): i32 {
  if (base == 0 as *u8) {
    return 0;
  }
  if (off < 0) {
    return 0;
  }
  let b0: u32 = 0;
  let b1: u32 = 0;
  let b2: u32 = 0;
  let b3: u32 = 0;
  unsafe {
    b0 = base[off] as u32;
    b1 = base[off + 1] as u32;
    b2 = base[off + 2] as u32;
    b3 = base[off + 3] as u32;
  }
  let u: u32 = b0 + b1 * 256 + b2 * 65536 + b3 * 16777216;
  return u as i32;
}

/**
 * LP64 offsetof(AsmFuncCtx, next_offset).
 * @return i32 - 4
 * PLATFORM: SHARED LP64 — matches backend.x layout + call_dispatch comment.
 */
function asg_thin_ctx_off_next_offset(): i32 {
  return 4;
}

function asg_thin_align_next_offset(ctx: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let off: i32 = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
  let m: i32 = off % 8;
  if (m != 0) {
    asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), off + (8 - m));
  }
}



/**
 * Whether assign LHS is an f32 slot (VAR / FIELD_ACCESS / INDEX resolved type).
 * @param arena *u8 - ASTArena*
 * @param ctx *u8 - AsmFuncCtx* (for VAR decl type lookup)
 * @param left_ref i32 - LHS expr ref
 * @return i32 - f32 type_ref when lhs is f32; 0 otherwise
 * wave142 pure: G.7 authority (was static glue_assign_lhs_f32_type_ref_elf_c).
 * Used by assign RHS float-lit imm32 path (avoid f64 movabs trunc).
 * PLATFORM: SHARED freestanding.
 */
export function glue_assign_lhs_f32_type_ref_elf_c(arena: *u8, ctx: *u8, left_ref: i32): i32 {
  let lko: i32 = 0;
  let tr: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let tk: i32 = 0;
  if (arena == (0 as *u8) || left_ref <= 0) {
    return 0;
  }
  unsafe {
    lko = pipeline_expr_kind_ord_at(arena, left_ref);
  }
  if (lko == 3) {
    unsafe {
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
    }
    if (tr > 0) {
      unsafe {
        tk = pipeline_type_kind_ord_at(arena, tr);
      }
      if (tk == 14) {
        return tr;
      }
    }
  }
  if (lko == 44) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
      tr = glue_field_access_field_type_ref_c(arena, mod, left_ref);
    }
    if (tr > 0) {
      unsafe {
        tk = pipeline_type_kind_ord_at(arena, tr);
      }
      if (tk == 14) {
        return tr;
      }
    }
  }
  if (lko == 47) {
    unsafe {
      tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    }
    if (tr > 0) {
      unsafe {
        tk = pipeline_type_kind_ord_at(arena, tr);
      }
      if (tk == 14) {
        return tr;
      }
    }
  }
  return 0;
}

/**
 * Assign RHS emit: lhs f32 + float lit uses imm32 (not CALL f64 widen).
 * @param arena *u8 - ASTArena*
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param left_ref i32 - LHS expr
 * @param right_ref i32 - RHS expr
 * @param ctx *u8 - AsmFuncCtx*
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 failure
 * wave142 pure: G.7 authority (was static glue_emit_assign_rhs_elf_c).
 * Cap residual: float lit pure + public emit_expr_elf_c for general RHS.
 * PLATFORM: SHARED freestanding.
 */
export function glue_emit_assign_rhs_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  let lhs_f32: i32 = 0;
  let rko: i32 = 0;
  let rc: i32 = 0;
  if (arena == (0 as *u8) || right_ref <= 0) {
    return -1;
  }
  unsafe {
    rko = pipeline_expr_kind_ord_at(arena, right_ref);
  }
  // FLOAT_LIT kind_ord == 1
  if (rko == 1) {
    lhs_f32 = glue_assign_lhs_f32_type_ref_elf_c(arena, ctx, left_ref);
    if (lhs_f32 > 0) {
      unsafe {
        rc = glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, right_ref, ta, lhs_f32, 0);
      }
      return rc;
    }
  }
  unsafe {
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
  }
  return rc;
}

/**
 * Plain / compound assign: materialize value to write into lhs in rax.
 * Plain (ako==28) → RHS only; a+= etc → lhs op rhs via nested binop helpers.
 * @param arena *u8 - ASTArena*
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param assign_expr_ref i32 - ASSIGN / compound assign expr
 * @param left_ref i32 - LHS
 * @param right_ref i32 - RHS
 * @param ctx *u8 - AsmFuncCtx*
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 failure
 * wave142 pure: G.7 authority (was static glue_emit_assign_rhs_to_rax_elf_c).
 * Cap residual: try_binop + add/sub/mul + float div + idiv/rem + and/or/xor +
 *   shifts + divisor_zero pure + emit_expr_elf_c + enc push/pop.
 * PLATFORM: SHARED freestanding · f32/f64 compound reuse binop residual.
 */
export function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  let ako: i32 = 0;
  let vr: i32 = 0;
  let rc: i32 = 0;
  let is_64bit: i32 = 0;
  let is_unsigned: i32 = 0;
  let is_f64_l: i32 = 0;
  let is_f64_r: i32 = 0;
  let is_f32_l: i32 = 0;
  let is_f32_r: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || assign_expr_ref <= 0 || left_ref <= 0 || right_ref <= 0) {
    return -1;
  }
  unsafe {
    ako = pipeline_expr_kind_ord_at(arena, assign_expr_ref);
  }
  if (ako == 28) {
    return glue_emit_assign_rhs_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
  unsafe {
    vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
  if (vr == -1) {
    return -1;
  }
  if (vr == -2) {
    unsafe {
      rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = backend_enc_pop_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
  }
  if (ako == 29) {
    unsafe {
      rc = glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
    }
    return rc;
  }
  if (ako == 30) {
    // PLATFORM: SHARED — f64/f32 -= → subsd/subss (same residual as EXPR_SUB).
    unsafe {
      rc = glue_emit_binop_sub_rax_minus_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
    }
    return rc;
  }
  if (ako == 31) {
    unsafe {
      rc = glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
    }
    return rc;
  }
  if (ako == 32) {
    // PLATFORM: SHARED — f64 /= → divsd; f32 /= → divss; else idiv.
    unsafe {
      is_f64_l = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref);
      is_f64_r = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref);
    }
    if ((ta == 0 || ta == 1) && is_f64_l != 0 && is_f64_r != 0) {
      unsafe {
        rc = backend_enc_divsd_rax_rbx_arch(elf_ctx, ta);
      }
      return rc;
    }
    unsafe {
      is_f32_l = glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref);
      is_f32_r = glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref);
    }
    if ((ta == 0 || ta == 1) && is_f32_l != 0 && is_f32_r != 0) {
      unsafe {
        rc = backend_enc_divss_rax_rbx_arch(elf_ctx, ta);
      }
      return rc;
    }
    unsafe {
      rc = pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = backend_enc_idiv_rbx_arch(elf_ctx, ta);
    }
    return rc;
  }
  if (ako == 33) {
    unsafe {
      rc = pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = backend_enc_rem_mod_arch(elf_ctx, ta);
    }
    return rc;
  }
  if (ako == 34) {
    unsafe {
      rc = backend_enc_and_rbx_rax_arch(elf_ctx, ta);
    }
    return rc;
  }
  if (ako == 35) {
    unsafe {
      rc = backend_enc_or_rbx_rax_arch(elf_ctx, ta);
    }
    return rc;
  }
  if (ako == 36) {
    unsafe {
      rc = backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
    }
    return rc;
  }
  if (ako == 37) {
    unsafe {
      glue_binop_var_slot_cache_clear();
      rc = backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    // left only: compound assign shift width follows lhs type.
    unsafe {
      is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, 0);
    }
    if (is_64bit != 0) {
      unsafe {
        rc = backend_enc_shl_cl_rax_arch(elf_ctx, ta);
      }
      return rc;
    }
    unsafe {
      rc = backend_enc_shl_cl_eax_arch(elf_ctx, ta);
    }
    return rc;
  }
  if (ako == 38) {
    // signed >>= must be SAR; u32/u64 keep SHR (wave648).
    unsafe {
      glue_binop_var_slot_cache_clear();
      rc = backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, 0);
      is_unsigned = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, 0);
    }
    if (is_unsigned != 0) {
      if (is_64bit != 0) {
        unsafe {
          rc = backend_enc_shr_cl_rax_arch(elf_ctx, ta);
        }
        return rc;
      }
      unsafe {
        rc = backend_enc_shr_cl_eax_arch(elf_ctx, ta);
      }
      return rc;
    }
    if (is_64bit != 0) {
      unsafe {
        rc = backend_enc_sar_cl_rax_arch(elf_ctx, ta);
      }
      return rc;
    }
    unsafe {
      rc = backend_enc_sar_cl_eax_arch(elf_ctx, ta);
    }
    return rc;
  }
  return -1;
}

/**
 * EXPR_ASSIGN ELF emit (FIELD / INDEX / VAR / DEREF; slice dual-GP, fixed-array
 * whole assign, TYPE_VECTOR let-init reuse, TYPE_NAMED >16B sret let-init reuse,
 * FIELD-chain dest to VAR root, FIELD dest VECTOR CALL let-init,
 * pointer / INDEX FIELD dest-in-rbx let-init,
 * DEREF TYPE_NAMED/SLICE/VECTOR dest-in-rbx let-init, ARRAY E* glue_copy,
 * STRUCT_LIT index in-place,
 * esz>8 bulk copy, VAR 9–16B dual-GP).
 * @param arena *u8 - ASTArena*
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param expr_ref i32 - assign expr ref
 * @param ctx *u8 - AsmFuncCtx*
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 failure
 * wave142 pure: G.7 authority (was pipeline_asm_emit_assign_elf_c).
 * Cap residual: try_index* + finish_store + bulk + slice dual-gp + float promote +
 *   fixed_array + field offset + struct_lit_fields + lvalue_eff_addr + enc stores.
 * next_offset bulk path: pipe_load/store @4 (LP64), not C struct field.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
 */
export function pipeline_asm_emit_assign_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let lko: i32 = 0;
  let load_sz: i32 = 0;
  let esz: i32 = 0;
  let rc: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let base_ref: i32 = 0;
  let field_off: i32 = 0;
  let vname: u8[256] = [];
  let vlen: i32 = 0;
  let var_off: i32 = 0;
  let idx_ref: i32 = 0;
  let rko_idx: i32 = 0;
  let ako_asg: i32 = 0;
  let lit_imm: i32 = 0;
  let lit_slot: i32[1] = [];
  let base_off: i32 = 0;
  let elem_home: i32 = 0;
  let base_tr: i32 = 0;
  let base_tk: i32 = 0;
  let rko_bulk: i32 = 0;
  let src_spill: i32 = 0;
  let dst_spill: i32 = 0;
  let temp_home: i32 = 0;
  let nbytes: i32 = 0;
  let next_off: i32 = 0;
  let off: i32 = 0;
  let is_modlet: i32 = 0;
  let ltr_pre: i32 = 0;
  let ltk_pre: i32 = 0;
  let rko_pre: i32 = 0;
  let n_arr: i32 = 0;
  let arr_st: i32 = 0;
  let ltr: i32 = 0;
  let rty: i32 = 0;
  let ltk: i32 = 0;
  let store_sz: i32 = 0;
  let tr: i32 = 0;
  let may_clobber: i32 = 0;
  let hit: i32 = 0;
  let is_enum: i32 = 0;
  let base_kind: i32 = 0;
  let chain_fa: i32[16] = [];
  let chain_n: i32 = 0;
  let walk_cur: i32 = 0;
  let walk_i: i32 = 0;
  let fa_ref: i32 = 0;
  let cmp_lit: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0) {
    return -1;
  }
  unsafe {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  }
  if (left_ref <= 0 || right_ref <= 0) {
    return -1;
  }
  // Identity ascription: `s = [10,32] as []i32` / `s = a as []T` must see ARRAY_LIT/VAR.
  unsafe {
    right_ref = glue_peel_as_array_slice_ascription_c(arena, right_ref);
  }
  if (right_ref <= 0) {
    return -1;
  }
  unsafe {
    lko = pipeline_expr_kind_ord_at(arena, left_ref);
  }
  if (lko != 47) {
    unsafe {
      glue_index_assign_addr_cache_clear();
    }
  }
  // FIELD assign (non-enum-variant)
  if (lko == 44) {
    unsafe {
      is_enum = pipeline_expr_field_access_is_enum_variant(arena, left_ref);
    }
    if (is_enum == 0) {
      unsafe {
        base_ref = pipeline_expr_field_access_base_ref(arena, left_ref);
      }
      /* FIELD dest whose root is a local VAR (h.s or w.h.s). Walk the
       * FIELD chain, fold glue_struct_field_frame_mag_c from the VAR
       * slot, reuse struct let-init. Pointer VAR / mid-chain *T is not
       * a frame-mag dest (would write into the pointer slot → Darwin 139).
       * Those plus INDEX roots use dest-in-rbx let-init below.
       * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
      if (base_ref > 0) {
        chain_n = 0;
        walk_cur = left_ref;
        while (chain_n < 16) {
          unsafe {
            base_kind = pipeline_expr_kind_ord_at(arena, walk_cur);
          }
          if (base_kind != 44) {
            break;
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
        if (walk_cur > 0 && chain_n > 0) {
          unsafe {
            base_kind = pipeline_expr_kind_ord_at(arena, walk_cur);
          }
          if (base_kind == 3) {
            unsafe {
              vlen = pipeline_expr_var_name_len(arena, walk_cur);
            }
            if (vlen <= 0 || vlen > 255) {
              return -1;
            }
            unsafe {
              pipeline_expr_var_name_into(arena, walk_cur, &vname[0]);
              var_off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
            }
            if (var_off < 0) {
              unsafe {
                var_off = asm_ctx_local_find_offset(ctx, &vname[0], vlen);
              }
            }
            if (var_off < 0) {
              return -1;
            }
            unsafe {
              mod = pipeline_asm_emit_module_ref_c();
              field_off = glue_field_access_effective_offset_c(arena, mod, left_ref);
              load_sz = pipeline_expr_field_access_load_byte_sz(arena, mod, left_ref);
            }
            if (load_sz <= 0) {
              load_sz = 4;
            }
            off = var_off;
            hit = 1;
            /* Pointer VAR / mid-chain *T: dest is *p + field, not slot+field.
             * Mag onto the pointer slot clobbers it (Darwin 139).
             * PLATFORM: SHARED — fall through to dest-in-rbx let-init. */
            unsafe {
              ltr_pre = glue_var_decl_type_ref_elf_c(arena, ctx, walk_cur);
            }
            if (ltr_pre <= 0) {
              unsafe {
                ltr_pre = pipeline_expr_resolved_type_ref(arena, walk_cur);
              }
            }
            if (ltr_pre > 0) {
              unsafe {
                ltk_pre = pipeline_type_kind_ord_at(arena, ltr_pre);
              }
              if (ltk_pre == 9) {
                hit = 0;
              }
            }
            walk_i = 1;
            while (walk_i < chain_n && hit != 0) {
              unsafe {
                ltr = glue_field_access_field_type_ref_c(arena, mod, chain_fa[walk_i]);
              }
              if (ltr > 0) {
                unsafe {
                  ltk = pipeline_type_kind_ord_at(arena, ltr);
                }
                if (ltk == 9) {
                  hit = 0;
                }
              }
              walk_i = walk_i + 1;
            }
            walk_i = chain_n - 1;
            while (walk_i >= 0 && hit != 0) {
              fa_ref = chain_fa[walk_i];
              unsafe {
                base_ref = pipeline_expr_field_access_base_ref(arena, fa_ref);
                vlen = pipeline_expr_field_access_name_len(arena, fa_ref);
              }
              rty = 0 - 1;
              if (vlen > 0 && vlen <= 255) {
                unsafe {
                  pipeline_expr_field_access_name_into(arena, fa_ref, &vname[0]);
                  rty = glue_field_layout_offset_for_base_field(
                      arena, mod, base_ref, &vname[0], vlen);
                }
              }
              if (rty < 0) {
                unsafe {
                  rty = glue_field_access_effective_offset_c(arena, mod, fa_ref);
                }
              }
              if (rty < 0) {
                hit = 0;
              } else {
                unsafe {
                  off = glue_struct_field_frame_mag_c(off, rty, ta);
                }
                if (off < 0) {
                  hit = 0;
                }
              }
              walk_i = walk_i - 1;
            }
            /* TYPE_NAMED / SIMD leaf: dest = nested mag(var_off, each typed_off).
             * SIMD field (`h.v = add4(a,b)`): same vector let-init as VAR
             * assign. Prior path treated i32x4 as TYPE_NAMED 16B dual-GP
             * store of a real CALL; callee only adds lane0 so h.v[1]
             * stayed 0 (Darwin 20). G.7: glue_emit_vector_type_let_init
             * into the frame-mag dest (real slot, not dest-in-rbx).
             * -2 falls through to TYPE_NAMED struct let-init / scalar store.
             * Do not call asm_type_is_simd_vector_spelling here (late
             * extern undeclared in hybrid generated C).
             * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
            if (hit != 0 && (ta == 0 || ta == 1)) {
              unsafe {
                ltr = glue_field_access_field_type_ref_c(arena, mod, left_ref);
              }
              if (ltr > 0) {
                unsafe {
                  ltk = pipeline_type_kind_ord_at(arena, ltr);
                  arr_st = glue_emit_vector_type_let_init_elf_c(
                      arena, elf_ctx, right_ref, ctx, ta, off, ltr);
                }
                if (arr_st == 0) {
                  return 0;
                }
                if (arr_st == 0 - 1) {
                  return 0 - 1;
                }
                if (ltk == 8) {
                  unsafe {
                    arr_st = glue_emit_struct_type_let_init_elf_c(
                        arena, elf_ctx, right_ref, ctx, ta, ltr, off);
                  }
                  if (arr_st == 0) {
                    return 0;
                  }
                  if (arr_st == 0 - 1) {
                    return 0 - 1;
                  }
                  unsafe {
                    mod = glue_emit_module_from_ctx(ctx);
                    store_sz = glue_type_size_simple(mod, arena, ltr, 0);
                    rty = glue_type_named_layout_size_any_module_elf_c(arena, ltr);
                  }
                  if (rty > store_sz) {
                    store_sz = rty;
                  }
                  if (store_sz > 8 && store_sz <= 16) {
                    rc = glue_emit_assign_rhs_to_rax_elf_c(
                        arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
                    if (rc != 0) {
                      return 0 - 1;
                    }
                    unsafe {
                      rc = glue_store_retval_pair_to_rbp_elf_c(
                          mod, arena, elf_ctx, ltr, off, ta, right_ref, ctx);
                    }
                    if (rc != 0) {
                      return 0 - 1;
                    }
                    return 0;
                  }
                }
                /* FIELD dest TYPE_ARRAY (`bag.one = [w]`). Depth-1 scalar
                 * store below is 8B of the ARRAY_LIT payload pointer
                 * (Darwin leftover 10). Frame dest ARRAY_LIT via
                 * store_fixed_array_field → vector_let_init bumps
                 * emit-time next_offset (official 139). G.7: lea dest
                 * then dest-in-rbx ARRAY_LIT (`*p = [w]` twin). Do not
                 * pass dest-in-rbx -3 into vector_let_init. Do not
                 * store_rax 8B. On -2 skip the scalar store.
                 * PLATFORM: SHARED — Darwin leftover 10 / official 139. */
                if (ltk == 10) {
                  unsafe {
                    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta);
                  }
                  if (rc != 0) {
                    return 0 - 1;
                  }
                  unsafe {
                    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
                  }
                  if (rc != 0) {
                    return 0 - 1;
                  }
                  unsafe {
                    arr_st = glue_emit_fixed_array_type_let_init_elf_c(
                        arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
                  }
                  if (arr_st == 0) {
                    return 0;
                  }
                  if (arr_st == 0 - 1) {
                    return 0 - 1;
                  }
                  hit = 0;
                }
              }
            }
            /* Depth-1 scalar on a value VAR: lea slot + store at field_off.
             * Pointer VAR (hit==0) must not store into the pointer slot —
             * dest-in-rbx let-init below writes through *p.
             * Nested scalar stays on the push/pop path. */
            if (chain_n == 1 && hit != 0) {
              rc = glue_emit_assign_rhs_to_rax_elf_c(
                  arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
              if (rc != 0) {
                return -1;
              }
              unsafe {
                rc = glue_enc_local_slot_ptr_or_addr_rbx_elf_c(
                    arena, elf_ctx, walk_cur, var_off, ctx, ta);
              }
              if (rc != 0) {
                return -1;
              }
              unsafe {
                rc = backend_enc_store_rax_to_rbx_offset_arch(
                    elf_ctx, field_off, load_sz, ta);
              }
              return rc;
            }
          }
        }
      }
      /* TYPE_NAMED dest through pointer / INDEX / *T field: dest address
       * first, then the same let-init with DEST_IN_RBX=-3.
       * 16B CALL uses dest-shadow x19; >16B CALL dest→x8/rdi; VAR memcpy dest-in-rbx.
       * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
      if (ta == 0 || ta == 1) {
        unsafe {
          mod = pipeline_asm_emit_module_ref_c();
          ltr = glue_field_access_field_type_ref_c(arena, mod, left_ref);
        }
        if (ltr > 0) {
          unsafe {
            ltk = pipeline_type_kind_ord_at(arena, ltr);
          }
          if (ltk == 8) {
            unsafe {
              rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            unsafe {
              rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            unsafe {
              arr_st = glue_emit_struct_type_let_init_elf_c(
                  arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
            }
            if (arr_st == 0) {
              return 0;
            }
            if (arr_st == 0 - 1) {
              return 0 - 1;
            }
          }
          /* FIELD dest TYPE_ARRAY through pointer / INDEX / *T
           * (`p.one = [w]` / `arr[0].one = [w]`). Same dest-in-rbx
           * ARRAY_LIT as `*p = [w]`. VAR-root `bag.one = [w]` already
           * returned via lea rbp dest above.
           * PLATFORM: SHARED — Darwin leftover 10. */
          if (ltk == 10) {
            unsafe {
              rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            unsafe {
              rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            unsafe {
              arr_st = glue_emit_fixed_array_type_let_init_elf_c(
                  arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
            }
            if (arr_st == 0) {
              return 0;
            }
            if (arr_st == 0 - 1) {
              return 0 - 1;
            }
          }
        }
      }
      rc = glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
      if (rc != 0) {
        return -1;
      }
      unsafe {
        rc = backend_enc_push_rax_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return -1;
      }
      unsafe {
        rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta);
      }
      if (rc != 0) {
        return -1;
      }
      unsafe {
        rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return -1;
      }
      unsafe {
        rc = backend_enc_pop_rax_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return -1;
      }
      unsafe {
        mod = pipeline_asm_emit_module_ref_c();
        load_sz = pipeline_expr_field_access_load_byte_sz(arena, mod, left_ref);
        rc = backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, load_sz, ta);
      }
      return rc;
    }
  }
  // INDEX assign
  if (lko == 47) {
    unsafe {
      esz = pipeline_asm_index_elem_byte_sz_c(arena, left_ref);
      base_ref = pipeline_expr_index_base_ref(arena, left_ref);
      idx_ref = pipeline_expr_index_index_ref(arena, left_ref);
    }
    if (base_ref <= 0 || idx_ref <= 0) {
      return -1;
    }
    // STRUCT_LIT index in-place (wave627/628/629)
    unsafe {
      rko_idx = pipeline_expr_kind_ord_at(arena, right_ref);
      ako_asg = pipeline_expr_kind_ord_at(arena, expr_ref);
      base_kind = pipeline_expr_kind_ord_at(arena, base_ref);
    }
    if (ako_asg == 28 && rko_idx == 45 && esz > 0 && base_kind == 3) {
      unsafe {
        base_tr = glue_var_decl_type_ref_elf_c(arena, ctx, base_ref);
      }
      if (base_tr > 0) {
        unsafe {
          base_tk = pipeline_type_kind_ord_at(arena, base_tr);
        }
      } else {
        base_tk = 0;
      }
      if (base_tk == 10) {
        // TYPE_ARRAY
        unsafe {
          cmp_lit = pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]);
        }
        if (cmp_lit != 0) {
          lit_imm = lit_slot[0];
          unsafe {
            base_off = glue_var_expr_stack_off_elf_c(arena, ctx, base_ref);
          }
          if (base_off >= 0) {
            if (ta == 1) {
              elem_home = base_off + lit_imm * esz;
            } else {
              elem_home = base_off - lit_imm * esz;
            }
            if (elem_home >= 0) {
              unsafe {
                rc = pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta, elem_home);
              }
              if (rc == 0) {
                unsafe {
                  glue_index_assign_addr_cache_clear();
                }
                return 0;
              }
            }
          }
        } else {
          // runtime index — hard-fail once entered
          unsafe {
            rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
          unsafe {
            rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
          // GLUE_STRUCT_LIT_DEST_IN_RBX = -3
          unsafe {
            rc = pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta, -3);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
          unsafe {
            glue_index_assign_addr_cache_clear();
          }
          return 0;
        }
      } else {
        if (base_tk == 11) {
          // TYPE_SLICE STRUCT_LIT
          unsafe {
            rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
          unsafe {
            rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
          unsafe {
            rc = pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta, -3);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
          unsafe {
            glue_index_assign_addr_cache_clear();
          }
          return 0;
        }
      }
    }
    /* SIMD INDEX dest (`arr[0] = add4(a,b)` / `arr[0] = a.add4(b)`).
     * After ARRAY_LIT SIMD VAR the ctor is green; dest CALL is Darwin
     * 2 (lane1 leftover). dest-in-rbx + struct let-init −2 then a
     * real CALL; callee only adds lane0. G.7: VAR+lit frame dest +
     * glue_emit_vector_type_let_init (same as FIELD dest VECTOR CALL).
     * Do not pass dest-in-rbx −3 (would lea rbp-3). Slice dest /
     * nested arr[0][0] leftover. Do not call
     * asm_type_is_simd_vector_spelling (late extern undeclared).
     * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
    if ((ta == 0 || ta == 1) && base_kind == 3) {
      unsafe {
        ltr = pipeline_expr_resolved_type_ref(arena, left_ref);
      }
      if (ltr <= 0) {
        unsafe {
          ltr_pre = pipeline_expr_resolved_type_ref(arena, base_ref);
        }
        if (ltr_pre > 0) {
          unsafe {
            ltk_pre = pipeline_type_kind_ord_at(arena, ltr_pre);
          }
          if (ltk_pre == 10 || ltk_pre == 11 || ltk_pre == 9) {
            unsafe {
              ltr = pipeline_type_elem_ref_at(arena, ltr_pre);
            }
          }
        }
      }
      if (ltr > 0) {
        unsafe {
          arr_st = glue_vector_type_lanes_esz_c(arena, ltr, &n_arr, &store_sz);
        }
        if (arr_st == 0 && n_arr > 0 && store_sz > 0) {
          nbytes = n_arr * store_sz;
          unsafe {
            cmp_lit = pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]);
          }
          if (cmp_lit != 0) {
            lit_imm = lit_slot[0];
            unsafe {
              base_off = glue_var_expr_stack_off_elf_c(arena, ctx, base_ref);
            }
            if (base_off >= 0 && nbytes > 0) {
              if (ta == 1) {
                elem_home = base_off + lit_imm * nbytes;
              } else {
                elem_home = base_off - lit_imm * nbytes;
              }
              if (elem_home >= 0) {
                unsafe {
                  arr_st = glue_emit_vector_type_let_init_elf_c(
                      arena, elf_ctx, right_ref, ctx, ta, elem_home, ltr);
                }
                if (arr_st == 0) {
                  unsafe {
                    glue_index_assign_addr_cache_clear();
                  }
                  return 0;
                }
                if (arr_st == 0 - 1) {
                  unsafe {
                    glue_index_assign_addr_cache_clear();
                  }
                  return 0 - 1;
                }
              }
            }
          }
        }
      }
    }
    /* TYPE_NAMED INDEX dest (`arr[0] = id16(x)` / `xs[0] = id16(x)`).
     * Bulk CALL used let_ty_ref=0 → store_retval_pair wrote rax only
     * (Darwin arr[0].b leftover 0 / dump=1). Authority is dest-in-rbx
     * let-init (same as pointer / INDEX FIELD dest): 16B CALL dual-GP
     * via x19 / rdx; >16B CALL dest→x8/rdi; VAR >16B memcpy dest-in-rbx.
     * 16B VAR still returns -2 and falls through to bulk (already green).
     * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
    if ((ta == 0 || ta == 1) && esz > 8) {
      unsafe {
        ltr = pipeline_expr_resolved_type_ref(arena, left_ref);
      }
      if (ltr <= 0) {
        unsafe {
          ltr_pre = pipeline_expr_resolved_type_ref(arena, base_ref);
        }
        if (ltr_pre > 0) {
          unsafe {
            ltk_pre = pipeline_type_kind_ord_at(arena, ltr_pre);
          }
          if (ltk_pre == 10 || ltk_pre == 11 || ltk_pre == 9) {
            unsafe {
              ltr = pipeline_type_elem_ref_at(arena, ltr_pre);
            }
          }
        }
      }
      if (ltr > 0) {
        unsafe {
          ltk = pipeline_type_kind_ord_at(arena, ltr);
        }
        if (ltk == 8) {
          unsafe {
            rc = glue_emit_index_eff_addr_scaled_elf_c(
                arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return 0 - 1;
          }
          unsafe {
            rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return 0 - 1;
          }
          unsafe {
            arr_st = glue_emit_struct_type_let_init_elf_c(
                arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
          }
          if (arr_st == 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return 0;
          }
          if (arr_st == 0 - 1) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return 0 - 1;
          }
        }
      }
    }
    /* TYPE_ARRAY INDEX dest (`rows[0] = [w]` / `rows[i] = [w]` /
     * `rh.rows[0] = [w]` / `grid[0][i] = [w]`).
     * Prior path emit_expr of ARRAY_LIT is 8B payload pointer then
     * store (Darwin leftover 10). Frame dest ARRAY_LIT goes through
     * vector_let_init and bumps emit-time next_offset (official 139).
     * G.7: dest type = walk INDEX chain to VAR/FIELD/DEREF root, peel
     * one ARRAY/SLICE/PTR layer per INDEX (nested `grid[0][0]` is two
     * peels). Lit VAR: lea rbp dest. Runtime VAR and any non-VAR base:
     * INDEX-lea then dest-in-rbx ARRAY_LIT (STRUCT_LIT runtime twin).
     * dest-in-rbx ARRAY_LIT writes through dest (no emit-time temp).
     * Do not pass dest-in-rbx -3 into vector_let_init.
     * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
    if (ta == 0 || ta == 1) {
      /* Dest type is the INDEX element, not the base. INDEX
       * resolved_type_ref may stamp the outer `[1][1]Wrap` and
       * store_fixed_array_field then treats `[w]` as an array-of-
       * array (etk==10) and bumps emit-time next_offset → official
       * large main() Darwin 139. Walk to the VAR/FIELD/DEREF root
       * and peel one layer per INDEX so `grid[0][0] = [w]` dest is
       * `[1]Wrap`, not `[1][1]Wrap`.
       * PLATFORM: SHARED — Darwin leftover 10 / official 139. */
      ltr = 0;
      ltr_pre = 0;
      walk_cur = left_ref;
      chain_n = 0;
      while (chain_n < 8) {
        if (walk_cur <= 0) {
          break;
        }
        unsafe {
          base_tk = pipeline_expr_kind_ord_at(arena, walk_cur);
        }
        if (base_tk != 47) {
          break;
        }
        chain_n = chain_n + 1;
        unsafe {
          walk_cur = pipeline_expr_index_base_ref(arena, walk_cur);
        }
      }
      if (walk_cur > 0) {
        unsafe {
          base_tk = pipeline_expr_kind_ord_at(arena, walk_cur);
        }
        if (base_tk == 3) {
          unsafe {
            ltr_pre = glue_var_decl_type_ref_elf_c(arena, ctx, walk_cur);
          }
        }
        if (ltr_pre <= 0 && base_tk == 44) {
          unsafe {
            mod = pipeline_asm_emit_module_ref_c();
            ltr_pre = glue_field_access_field_type_ref_c(arena, mod, walk_cur);
          }
        }
        if (ltr_pre <= 0) {
          unsafe {
            ltr_pre = pipeline_expr_resolved_type_ref(arena, walk_cur);
          }
        }
      }
      ltr = ltr_pre;
      walk_i = 0;
      while (walk_i < chain_n && ltr > 0) {
        unsafe {
          ltk_pre = pipeline_type_kind_ord_at(arena, ltr);
        }
        if (ltk_pre == 10 || ltk_pre == 11 || ltk_pre == 9) {
          unsafe {
            ltr = pipeline_type_elem_ref_at(arena, ltr);
          }
        } else {
          ltr = 0;
        }
        walk_i = walk_i + 1;
      }
      unsafe {
        base_kind = pipeline_expr_kind_ord_at(arena, base_ref);
      }
      if (ltr > 0) {
        unsafe {
          ltk = pipeline_type_kind_ord_at(arena, ltr);
        }
        if (ltk == 10) {
          /* Lit index + VAR base: frame-home let-init (same as SIMD
           * INDEX dest). dest-in-rbx after INDEX lea 139'd official
           * large main() (red zone hid it on the tiny isolate).
           * Do not bump emit-time next_offset. Do not lea rbp-3.
           * PLATFORM: SHARED — Darwin leftover 10 / official 139. */
          hit = 0;
          if (base_kind == 3) {
            unsafe {
              cmp_lit = pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]);
            }
            if (cmp_lit != 0) {
              lit_imm = lit_slot[0];
              unsafe {
                base_off = glue_var_expr_stack_off_elf_c(arena, ctx, base_ref);
                nbytes = glue_fixed_array_total_bytes_c(arena, ltr, 0);
              }
              if (nbytes < 8) {
                nbytes = esz;
              }
              if (base_off >= 0 && nbytes > 0) {
                if (ta == 1) {
                  elem_home = base_off + lit_imm * nbytes;
                } else {
                  elem_home = base_off - lit_imm * nbytes;
                }
                if (elem_home >= 0) {
                  /* Frame dest ARRAY_LIT goes through
                   * store_fixed_array_field → vector_let_init and
                   * bumps emit-time next_offset (official 139).
                   * lea dest then dest-in-rbx ARRAY_LIT (`*p = [w]`).
                   * Do not pass dest-in-rbx -3 into vector_let_init.
                   * PLATFORM: SHARED — Darwin leftover 10 / official 139. */
                  unsafe {
                    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, elem_home, ta);
                  }
                  if (rc != 0) {
                    unsafe {
                      glue_index_assign_addr_cache_clear();
                    }
                    return 0 - 1;
                  }
                  unsafe {
                    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
                  }
                  if (rc != 0) {
                    unsafe {
                      glue_index_assign_addr_cache_clear();
                    }
                    return 0 - 1;
                  }
                  unsafe {
                    arr_st = glue_emit_fixed_array_type_let_init_elf_c(
                        arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
                  }
                  if (arr_st == 0) {
                    unsafe {
                      glue_index_assign_addr_cache_clear();
                    }
                    return 0;
                  }
                  if (arr_st == 0 - 1) {
                    unsafe {
                      glue_index_assign_addr_cache_clear();
                    }
                    return 0 - 1;
                  }
                  hit = 1;
                }
              }
            }
          }
          /* Runtime VAR `rows[i] = [w]` or non-VAR base
           * `rh.rows[0] = [w]` / `rh.rows[i] = [w]` /
           * `grid[0][0] = [w]` / `grid[0][i] = [w]`.
           * Lit VAR already returned via lea rbp dest. INDEX-lea
           * then dest-in-rbx ARRAY_LIT (STRUCT_LIT runtime twin).
           * Scale with dest-array total bytes, not the 8B
           * index-elem leftover.
           * PLATFORM: SHARED — Darwin leftover 10. */
          if (hit == 0) {
            unsafe {
              nbytes = glue_fixed_array_total_bytes_c(arena, ltr, 0);
            }
            if (nbytes < 8) {
              nbytes = esz;
            }
            if (nbytes > 0) {
              unsafe {
                rc = glue_emit_index_eff_addr_scaled_elf_c(
                    arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, nbytes);
              }
              if (rc != 0) {
                unsafe {
                  glue_index_assign_addr_cache_clear();
                }
                return 0 - 1;
              }
              unsafe {
                rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
              }
              if (rc != 0) {
                unsafe {
                  glue_index_assign_addr_cache_clear();
                }
                return 0 - 1;
              }
              unsafe {
                arr_st = glue_emit_fixed_array_type_let_init_elf_c(
                    arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
              }
              if (arr_st == 0) {
                unsafe {
                  glue_index_assign_addr_cache_clear();
                }
                return 0;
              }
              if (arr_st == 0 - 1) {
                unsafe {
                  glue_index_assign_addr_cache_clear();
                }
                return 0 - 1;
              }
            }
          }
        }
      }
    }
    // esz>8 bulk copy path (wave630)
    if (esz > 8) {
      unsafe {
        rko_bulk = pipeline_expr_kind_ord_at(arena, right_ref);
      }
      if (rko_bulk == 3 || rko_bulk == 44 || rko_bulk == 47 || rko_bulk == 48 || rko_bulk == 49) {
        next_off = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
        if (next_off + 32 < next_off) {
          unsafe {
            glue_index_assign_addr_cache_clear();
          }
          return -1;
        }
        next_off = next_off + 16;
        src_spill = next_off;
        next_off = next_off + 16;
        dst_spill = next_off;
        asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), next_off);
        temp_home = -1;
        if (rko_bulk == 3 || rko_bulk == 44 || rko_bulk == 47) {
          unsafe {
            rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
          unsafe {
            rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
        } else {
          nbytes = (esz + 7) & (~7);
          next_off = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
          if (next_off + nbytes < next_off) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
          next_off = next_off + nbytes;
          temp_home = next_off;
          asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), next_off);
          unsafe {
            rc = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0, temp_home);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
          unsafe {
            rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
          unsafe {
            rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
          }
          if (rc != 0) {
            unsafe {
              glue_index_assign_addr_cache_clear();
            }
            return -1;
          }
        }
        unsafe {
          rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz);
        }
        if (rc != 0) {
          unsafe {
            glue_index_assign_addr_cache_clear();
          }
          return -1;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta);
        }
        if (rc != 0) {
          unsafe {
            glue_index_assign_addr_cache_clear();
          }
          return -1;
        }
        unsafe {
          rc = glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, esz, ta);
        }
        if (rc != 0) {
          unsafe {
            glue_index_assign_addr_cache_clear();
          }
          return -1;
        }
        unsafe {
          glue_index_assign_addr_cache_clear();
        }
        return 0;
      }
    }
    // generic INDEX: rhs→rax, push, addr→rbx, finish_store
    rc = glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0) {
      unsafe {
        glue_index_assign_addr_cache_clear();
      }
      return -1;
    }
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      unsafe {
        glue_index_assign_addr_cache_clear();
      }
      return -1;
    }
    unsafe {
      may_clobber = glue_expr_emit_may_clobber_rbx_elf_c(arena, right_ref);
    }
    if (may_clobber != 0) {
      unsafe {
        glue_index_assign_addr_cache_clear();
      }
    }
    unsafe {
      hit = glue_index_assign_addr_cache_hit(arena, ctx, base_ref, idx_ref, esz);
    }
    if (hit != 0) {
      unsafe {
        rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      }
      return rc;
    }
    // try_* only for esz in {1,4,8}
    if (esz == 1 || esz == 4 || esz == 8) {
      unsafe {
        rc = glue_try_index_var_lit_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_plus_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_minus_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_minus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_mul_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_plus_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_minus_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_minus_var_minus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_minus_add3_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_plus_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_minus_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_add3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_subadd3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_subsub3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
      unsafe {
        rc = glue_try_index_var_minus_add3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
      }
      if (rc == 0) {
        unsafe {
          rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
        }
        return rc;
      }
    }
    unsafe {
      glue_index_assign_addr_cache_clear();
      rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    return rc;
  }
  // VAR assign
  if (lko == 3) {
    unsafe {
      vlen = pipeline_expr_var_name_len(arena, left_ref);
    }
    if (vlen <= 0 || vlen > 255) {
      return -1;
    }
    unsafe {
      pipeline_expr_var_name_into(arena, left_ref, &vname[0]);
      glue_index_scratch_spill_invalidate_var(arena, elf_ctx, ctx, left_ref, ta);
      is_modlet = pipeline_asm_modlet_name_is_shared(&vname[0], vlen);
      off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
    }
    if (off < 0) {
      unsafe {
        off = asm_ctx_local_find_offset(ctx, &vname[0], vlen);
      }
    }
    if (off < 0 && is_modlet == 0) {
      return -1;
    }
    if (off >= 0) {
      unsafe {
        glue_binop_var_slot_cache_invalidate_slot(off);
      }
    }
    if (off >= 0) {
      unsafe {
        ltr_pre = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
      }
    } else {
      ltr_pre = 0;
    }
    if (ltr_pre > 0) {
      unsafe {
        ltk_pre = pipeline_type_kind_ord_at(arena, ltr_pre);
      }
    } else {
      ltk_pre = 0;
    }
    unsafe {
      rko_pre = pipeline_expr_kind_ord_at(arena, right_ref);
      ako_asg = pipeline_expr_kind_ord_at(arena, expr_ref);
    }
    // TYPE_SLICE + ARRAY_LIT assign (wave331)
    if (is_modlet == 0 && off >= 0 && ltk_pre == 11 && rko_pre == 46 && ako_asg == 28) {
      unsafe {
        n_arr = pipeline_expr_array_lit_num_elems_at(arena, right_ref);
      }
      if (n_arr < 0 || n_arr > 1024) {
        return -1;
      }
      unsafe {
        glue_slice_dual_gp_bump_past_home_c(ctx, off, ta);
        rc = pipeline_asm_emit_array_lit_elf_c(arena, elf_ctx, right_ref, ctx, ta);
      }
      if (rc != 0) {
        return -1;
      }
      unsafe {
        rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta);
      }
      if (rc != 0) {
        return -1;
      }
      unsafe {
        rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta);
      }
      if (rc != 0) {
        return -1;
      }
      unsafe {
        rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta);
      }
      if (rc != 0) {
        return -1;
      }
      if (n_arr > 0) {
        unsafe {
          pipeline_asm_bump_next_offset_for_array_lit(arena, right_ref, ctx);
        }
      }
      unsafe {
        glue_binop_var_slot_cache_kill_def_at_slot(off);
      }
      return 0;
    }
    // TYPE_SLICE + already-typed [N]T VAR/FIELD/INDEX. Stack view (same frame).
    // G.7 reuse glue_emit_slice_from_array_let_init (INDEX row already live).
    // Do not stamp SLICE.
    // PLATFORM: SHARED freestanding · LINUX+MACOS SysV · MACOS|ARM64.
    if (is_modlet == 0 && off >= 0 && ltk_pre == 11 && ako_asg == 28
    && (rko_pre == 3 || rko_pre == 44 || rko_pre == 47)) {
      unsafe {
        rty = pipeline_expr_resolved_type_ref(arena, right_ref);
      }
      if (rty > 0) {
        unsafe {
          ltk = pipeline_type_kind_ord_at(arena, rty);
        }
        if (ltk == 10) {
          unsafe {
            mod = pipeline_asm_emit_module_ref_c();
            tr = pipeline_asm_emit_func_index_c();
          }
          n_arr = 0;
          if (mod != (0 as *u8) && tr >= 0) {
            unsafe {
              n_arr = pipeline_module_func_body_ref_at(mod, tr);
            }
          }
          if (n_arr > 0) {
            unsafe {
              arr_st = ast_ast_block_num_lets(arena, n_arr);
              arr_st = glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, n_arr, arr_st,
              right_ref, ltr_pre, ctx, ta, off);
            }
            if (arr_st == 1) {
              unsafe {
                glue_binop_var_slot_cache_kill_def_at_slot(off);
              }
              return 0;
            }
            if (arr_st < 0) {
              return -1;
            }
          }
        }
      }
    }
    // TYPE_ARRAY whole-array assign (wave334/354)
    if (is_modlet == 0 && off >= 0 && ltk_pre == 10 && ako_asg == 28) {
      unsafe {
        arr_st = glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr_pre, off);
      }
      if (arr_st == 0) {
        unsafe {
          glue_binop_var_slot_cache_kill_def_at_slot(off);
        }
        return 0;
      }
      if (arr_st == -1) {
        return -1;
      }
      // -2: fall through
    }
    /* TYPE_VECTOR VAR assign: reuse let-init (ARRAY_LIT / VAR copy / lane
     * binop / CALL+METHOD splat/select/shuffle/fma3/binop2). Prior path
     * emitted a real CALL then dual-GP store; METHOD `d = a.add4(b)` callee
     * only adds lane0 so d[1] stayed 0 (Darwin 12).
     * G.7: same glue_emit_vector_type_let_init_elf_c as let-init; -2 falls
     * through to CALL emit (import extras=2 stays host-C).
     * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
    if (is_modlet == 0 && off >= 0 && ako_asg == 28 && ltr_pre > 0) {
      unsafe {
        arr_st = glue_emit_vector_type_let_init_elf_c(
            arena, elf_ctx, right_ref, ctx, ta, off, ltr_pre);
      }
      if (arr_st == 0) {
        unsafe {
          glue_binop_var_slot_cache_kill_def_at_slot(off);
        }
        return 0;
      }
      if (arr_st == -1) {
        return -1;
      }
    }
    /* TYPE_NAMED VAR assign: reuse struct let-init (STRUCT_LIT / CALL / METHOD).
     * Prior path emitted CALL then glue_copy_large_struct from *rax.
     * AAPCS64 >16B returns via x8 sret; assign never loaded dest into x8,
     * so callee memcpy(*garbage) and the caller memcpy(y, *rax) SIGBUS.
     * Let-init already lea slot → x8 then CALL (callee writes dest).
     * G.7: same glue_emit_struct_type_let_init_elf_c; -2 falls through
     * (scalar / ≤16B VAR). >16B VAR copy is handled inside let-init.
     * Gate TYPE_NAMED=8 so VECTOR stays on the sibling.
     * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
    if (is_modlet == 0 && off >= 0 && ako_asg == 28 && ltk_pre == 8) {
      unsafe {
        arr_st = glue_emit_struct_type_let_init_elf_c(
            arena, elf_ctx, right_ref, ctx, ta, ltr_pre, off);
      }
      if (arr_st == 0) {
        unsafe {
          glue_binop_var_slot_cache_kill_def_at_slot(off);
        }
        return 0;
      }
      if (arr_st == -1) {
        return -1;
      }
    }
    rc = glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0) {
      return -1;
    }
    if (is_modlet != 0) {
      unsafe {
        rc = pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx, &vname[0], vlen, ta);
      }
      if (rc != 0) {
        return -1;
      }
      if (off >= 0) {
        unsafe {
          glue_binop_var_slot_cache_kill_def_at_slot(off);
        }
      }
      return 0;
    }
    unsafe {
      ltr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
      rty = glue_float_promote_src_ty_ref_c(arena, right_ref);
      rc = glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, ltr, rty, ta);
    }
    if (rc != 0) {
      return -1;
    }
    // f32 dest + f64 rhs: demote to f32 bits before the 4-byte store, else the
    // store keeps only the low 32 bits of the f64 (shared truncation defect).
    unsafe {
      rc = glue_maybe_demote_f64_to_f32_eax_elf_c(arena, elf_ctx, ctx, ltr, right_ref, ta);
    }
    if (rc != 0) {
      return -1;
    }
    if (ltr > 0) {
      unsafe {
        ltk = pipeline_type_kind_ord_at(arena, ltr);
      }
    } else {
      ltk = 0;
    }
    if (ltk == 11) {
      // TYPE_SLICE dual-GP store
      unsafe {
        rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta);
      }
      if (rc != 0) {
        return -1;
      }
      unsafe {
        rc = backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta);
      }
      if (rc != 0) {
        return -1;
      }
    } else {
      if (ltr > 0 && ltk == 14) {
        unsafe {
          rc = backend_enc_store_eax_to_rbp_arch(elf_ctx, off, ta);
        }
        if (rc != 0) {
          return -1;
        }
      } else {
        /* 9–16B named struct / vector: same dual-GP as let-init.
         * Scalar / ≤8B still stores rax only inside the helper.
         * Prior store_rax-only dropped hi (x1/rdx) so `y = id16(x)` left y.b=0.
         * G.7: reuse glue_store_retval_pair_to_rbp_elf_c; do not fork a second store.
         * PLATFORM: SHARED — SysV rdx / AAPCS64 x1; ARM64 low-end home@off+8. */
        unsafe {
          rc = glue_store_retval_pair_to_rbp_elf_c(
              glue_emit_module_from_ctx(ctx), arena, elf_ctx, ltr, off, ta, right_ref, ctx);
        }
        if (rc != 0) {
          return -1;
        }
      }
    }
    unsafe {
      glue_binop_var_slot_cache_kill_def_at_slot(off);
    }
    return 0;
  }
  // DEREF assign (wave324)
  if (lko == 52) {
    /* Aggregate dest (`*p = …` TYPE_NAMED / SLICE / VECTOR / ARRAY).
     * Prior path emitted rhs then store_rax_to_rbx_indirect (rax only).
     * Darwin SLICE length leftover / ARRAY first-elem leftover / VECTOR
     * 16B CALL SIGBUS 138. Authority is dest-in-rbx let-init for
     * register-class aggregates (NAMED / SLICE / VECTOR): 16B dual-GP
     * via x19 / rdx; >16B CALL dest→x8/rdi; VAR ≥8B memcpy dest-in-rbx.
     * TYPE_ARRAY CALL returns E* (8B), not payload — emit then glue_copy
     * *rax → dest. Scalar stays on store_rax_to_rbx_indirect.
     * Deref write is unsafe in source.
     * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
    if (ta == 0 || ta == 1) {
      unsafe {
        ltr = pipeline_expr_resolved_type_ref(arena, left_ref);
      }
      ltk = 0;
      if (ltr > 0) {
        unsafe {
          ltk = pipeline_type_kind_ord_at(arena, ltr);
        }
      }
      if (ltk != 8) {
        unsafe {
          base_ref = pipeline_expr_unary_operand_ref_at(arena, left_ref);
        }
        if (base_ref > 0) {
          unsafe {
            ltr_pre = pipeline_expr_resolved_type_ref(arena, base_ref);
          }
          if (ltr_pre <= 0) {
            unsafe {
              ltr_pre = glue_var_decl_type_ref_elf_c(arena, ctx, base_ref);
            }
          }
          if (ltr_pre > 0) {
            unsafe {
              ltk_pre = pipeline_type_kind_ord_at(arena, ltr_pre);
            }
            if (ltk_pre == 9) {
              unsafe {
                ltr = pipeline_type_elem_ref_at(arena, ltr_pre);
              }
              if (ltr > 0) {
                unsafe {
                  ltk = pipeline_type_kind_ord_at(arena, ltr);
                }
              }
            }
          }
        }
      }
      /* TYPE_NAMED=8 SLICE=11 VECTOR=13 ARRAY=10. i32x4 is often kind 8
       * (named SIMD spelling) — still dest-in-rbx. Scalar / ptr stay below. */
      if (ltr > 0 && (ltk == 8 || ltk == 11 || ltk == 13 || ltk == 10)) {
        unsafe {
          rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rko_pre = pipeline_expr_kind_ord_at(arena, right_ref);
          arr_st = glue_vector_type_lanes_esz_c(arena, ltr, &n_arr, &esz);
        }
        /* SIMD / TYPE_VECTOR: glue_type_size_simple is often 0 for the
         * i32x4 named spelling (no struct layout). VAR memcpy dest-in-rbx
         * with lanes*esz; CALL is 16B dual-GP dest-in-rbx store.
         * Detect via glue_vector_type_lanes_esz (not a late extern).
         * PLATFORM: SHARED — Darwin *p = va leftover lane1. */
        if (arr_st == 0 && n_arr > 0 && esz > 0) {
            nbytes = n_arr * esz;
            if (nbytes >= 8 && rko_pre == 3) {
              unsafe {
                var_off = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
              }
              if (var_off >= 0) {
                unsafe {
                  rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, var_off, ta);
                }
                if (rc != 0) {
                  return 0 - 1;
                }
                unsafe {
                  rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, nbytes, ta);
                }
                if (rc != 0) {
                  return 0 - 1;
                }
                return 0;
              }
            }
            /* CALL/METHOD: real add4 callee only does lane0 (`add w0,w1,w0`).
             * VAR `d = add4(a,b)` already reuses vector let-init (binop2).
             * dest-in-rbx must not emit the CALL — park dest, let-init a
             * temp, memcpy dest-in-rbx. Do not save x19 in the prologue.
             * Frame homes follow asm_local_slot_reg_offset / ARRAY_LIT
             * SIMD formal (home=cur on ARM64, home=cur+sz on x86).
             * Increment-after on x86 overlaps the last local: dest
             * spill lands on `q`, temp lane2 clobbers dest, memcpy(33)
             * SIGSEGV (Ubuntu 139). G.7 same polarity as
             * glue_simd_alloc_vector_temp_slot_c.
             * PLATFORM: SHARED — LINUX|x86_64 high-end; MACOS|ARM64 low-end. */
            if (nbytes >= 8 && (rko_pre == 48 || rko_pre == 49)) {
              asg_thin_align_next_offset(ctx);
              src_spill = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
              if (ta == 1) {
                asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), src_spill + 8);
              } else {
                src_spill = src_spill + 8;
                asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), src_spill);
              }
              unsafe {
                rc = backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
              }
              if (rc != 0) {
                return 0 - 1;
              }
              unsafe {
                rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
              }
              if (rc != 0) {
                return 0 - 1;
              }
              asg_thin_align_next_offset(ctx);
              temp_home = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
              if (ta == 1) {
                asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), temp_home + nbytes);
              } else {
                temp_home = temp_home + nbytes;
                asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), temp_home);
              }
              unsafe {
                arr_st = glue_emit_vector_type_let_init_elf_c(
                    arena, elf_ctx, right_ref, ctx, ta, temp_home, ltr);
              }
              if (arr_st == 0 - 1) {
                return 0 - 1;
              }
              if (arr_st == 0) {
                unsafe {
                  rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, src_spill, ta);
                }
                if (rc != 0) {
                  return 0 - 1;
                }
                unsafe {
                  rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
                }
                if (rc != 0) {
                  return 0 - 1;
                }
                unsafe {
                  rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta);
                }
                if (rc != 0) {
                  return 0 - 1;
                }
                unsafe {
                  rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, nbytes, ta);
                }
                if (rc != 0) {
                  return 0 - 1;
                }
                return 0;
              }
              /* -2: restore dest and fall through to CALL emit. */
              unsafe {
                rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, src_spill, ta);
              }
              if (rc != 0) {
                return 0 - 1;
              }
              unsafe {
                rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
              }
              if (rc != 0) {
                return 0 - 1;
              }
              unsafe {
                rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
              }
              if (rc != 0) {
                return 0 - 1;
              }
              if (ta == 1) {
                unsafe {
                  rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 16, ta);
                }
              } else {
                unsafe {
                  rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 8, ta);
                }
                if (rc == 0) {
                  rc = glue_x86_store_rdx_to_rbx8_elf_c(elf_ctx);
                }
              }
              if (rc != 0) {
                return 0 - 1;
              }
              return 0;
            }
        }
        /* dest-in-rbx TYPE_ARRAY / TYPE_SLICE CALL: park dest before emit.
         * Callee clobbers rbx / AAPCS64 x19 (unsaved in prologue).
         * For TYPE_SLICE (16B): CALL returns dual-GP {data, len} in rax+rdx
         * (x0+x1 on ARM64). Spill to a frame temp, restore dest, then copy 16B.
         * For TYPE_ARRAY: CALL returns payload pointer in rax (x0 on ARM64).
         * Spill payload pointer, restore dest, reload pointer into rax,
         * then copy nbytes via glue_copy_large_struct_from_rax_ptr_elf_c.
         * PLATFORM: SHARED dest-in-rbx CALL · LINUX x86_64 SysV · MACOS|ARM64. */
        if ((ltk == 10 || ltk == 11) && (rko_pre == 48 || rko_pre == 49)) {
          unsafe {
            mod = glue_emit_module_from_ctx(ctx);
            nbytes = glue_type_size_simple(mod, arena, ltr, 0);
          }
          if (ltk == 11) {
            nbytes = 16;
          }
          if (nbytes < 8) {
            unsafe {
              nbytes = glue_fixed_array_total_bytes_c(arena, ltr, 0);
            }
          }
          if (nbytes >= 8) {
            asg_thin_align_next_offset(ctx);
            dst_spill = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
            if (ta == 1) {
              asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), dst_spill + 8);
            } else {
              dst_spill = dst_spill + 8;
              asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), dst_spill);
            }
            if (ta == 1) {
              rc = glue_arm64_mov_x19_to_x0_elf_c(elf_ctx);
            } else {
              unsafe {
                rc = backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
              }
            }
            if (rc != 0) {
              return 0 - 1;
            }
            unsafe {
              rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            unsafe {
              rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            if (ltk == 11) {
              asg_thin_align_next_offset(ctx);
              src_spill = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
              if (ta == 1) {
                asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), src_spill + 16);
              } else {
                src_spill = src_spill + 16;
                asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), src_spill);
              }
              unsafe {
                rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
              }
              if (rc != 0) {
                return 0 - 1;
              }
              unsafe {
                rc = backend_enc_store_rdx_to_rbp_arch(
                    elf_ctx, glue_slice_dual_gp_length_off_c(src_spill, ta), ta);
              }
              if (rc != 0) {
                return 0 - 1;
              }
              unsafe {
                rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, dst_spill, ta);
              }
              if (rc != 0) {
                return 0 - 1;
              }
              unsafe {
                rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
              }
              if (rc != 0) {
                return 0 - 1;
              }
              unsafe {
                rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_spill, ta);
              }
              if (rc != 0) {
                return 0 - 1;
              }
              unsafe {
                rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, 16, ta);
              }
              if (rc != 0) {
                return 0 - 1;
              }
              return 0;
            }
            asg_thin_align_next_offset(ctx);
            src_spill = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
            if (ta == 1) {
              asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), src_spill + 8);
            } else {
              src_spill = src_spill + 8;
              asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), src_spill);
            }
            unsafe {
              rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            unsafe {
              rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, dst_spill, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            unsafe {
              rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            unsafe {
              rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, src_spill, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            unsafe {
              rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, nbytes, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
            return 0;
          }
        }
        /* TYPE_ARRAY dest-in-rbx (`*p = [w]` / `*p = src`). ARRAY_LIT
         * used to miss struct let-init (ko==46 → -2) then store the
         * payload pointer (Darwin leftover 10). G.7: same
         * glue_emit_fixed_array_type_let_init as frame `[w]`. dest-in-rbx
         * parks dest and memcpy; do not pass -3 to vector_let_init.
         * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
        if (ltk == 10) {
          unsafe {
            arr_st = glue_emit_fixed_array_type_let_init_elf_c(
                arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
          }
          if (arr_st == 0) {
            return 0;
          }
          if (arr_st == 0 - 1) {
            return 0 - 1;
          }
        }
        unsafe {
          arr_st = glue_emit_struct_type_let_init_elf_c(
              arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
        }
        if (arr_st == 0) {
          return 0;
        }
        if (arr_st == 0 - 1) {
          return 0 - 1;
        }
      }
    }
    rc = glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return -1;
    }
    unsafe {
      tr = pipeline_expr_resolved_type_ref(arena, left_ref);
      store_sz = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    }
    if (store_sz <= 0) {
      store_sz = 4;
    }
    unsafe {
      rc = backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, store_sz, ta);
    }
    return rc;
  }
  return -1;
}

/**
 * Extract pair base VAR ref from field-assign expression `p.a = ...`.
 * @param arena *u8 - ASTArena*
 * @param er i32 - expr stmt ref (must be ASSIGN)
 * @return i32 - base VAR expr_ref; 0 if non-field-assign / null
 * wave142 pure: G.7 authority (was static glue_field_assign_pair_base_ref_c).
 * Called from fold_count_up_while Cap residual — must export #[no_mangle].
 * PLATFORM: SHARED.
 */
export function glue_field_assign_pair_base_ref_c(arena: *u8, er: i32): i32 {
  let left_ref: i32 = 0;
  let ko: i32 = 0;
  let lko: i32 = 0;
  if (arena == (0 as *u8) || er <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, er);
  }
  if (ko != 28) {
    return 0;
  }
  unsafe {
    left_ref = pipeline_expr_binop_left_ref_at(arena, er);
    lko = pipeline_expr_kind_ord_at(arena, left_ref);
  }
  if (lko != 44) {
    return 0;
  }
  unsafe {
    return pipeline_expr_field_access_base_ref(arena, left_ref);
  }
}

/**
 * Get the si-th expr stmt ref in a block (stmt_order or pure expr_stmts).
 * @param arena *u8 - ASTArena*
 * @param body_ref i32 - block ref
 * @param si i32 - statement index
 * @param nso i32 - num stmt_order entries (>0 uses order path)
 * @param out_er *i32 - out expr_ref
 * @return i32 - 1 on success; 0 otherwise
 * wave142 pure: G.7 authority (was static glue_body_expr_stmt_at_c).
 * Called from fold_count_up_while Cap residual — must export #[no_mangle].
 * PLATFORM: SHARED.
 */
export function glue_body_expr_stmt_at_c(arena: *u8, body_ref: i32, si: i32, nso: i32, out_er: *i32): i32 {
  let er: i32 = 0;
  let kind: i32 = 0;
  let idx: i32 = 0;
  if (arena == (0 as *u8) || body_ref <= 0 || out_er == (0 as *i32)) {
    return 0;
  }
  if (nso > 0) {
    unsafe {
      kind = ast_ast_block_stmt_order_kind(arena, body_ref, si);
    }
    if (kind != 2) {
      return 0;
    }
    unsafe {
      idx = ast_ast_block_stmt_order_idx(arena, body_ref, si);
      er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, idx);
    }
  } else {
    unsafe {
      er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, si);
    }
  }
  if (er <= 0) {
    return 0;
  }
  unsafe {
    out_er[0] = er;
  }
  return 1;
}
