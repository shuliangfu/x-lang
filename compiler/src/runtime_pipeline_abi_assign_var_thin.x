// Thin pure: VAR assign arm (wave441).
// G.7: body MUST match glue_emit_assign_var_elf_c in assign_thin / mega.
// wave441b: LINUX product via -E (tip pure-asm → si SEGV).
// wave449: tip pure-asm HARD BAN (single T; product si SEGV 139).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

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
export extern function glue_assign_lhs_f32_type_ref_elf_c(arena: *u8, ctx: *u8, left_ref: i32): i32;
export extern function glue_emit_assign_rhs_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_field_assign_pair_base_ref_c(arena: *u8, er: i32): i32;
export extern function glue_body_expr_stmt_at_c(arena: *u8, body_ref: i32, si: i32, nso: i32, out_er: *i32): i32;
export extern function asg_thin_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function asg_thin_load_i32_le(base: *u8, off: i32): i32;
export extern function asg_thin_ctx_off_next_offset(): i32;
export extern function asg_thin_align_next_offset(ctx: *u8): void;

/**
 * VAR lvalue assign arm (slice/array/struct/scalar).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_var_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
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

    return 0 - 1;
  }
}
