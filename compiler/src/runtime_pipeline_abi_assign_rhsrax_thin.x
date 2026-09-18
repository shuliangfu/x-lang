// Thin pure: assign REST rhs_to_rax (wave437 flat helpers).
// G.7: semantics match glue_emit_assign_rhs_to_rax_elf_c in assign_thin / mega.
// wave425: Darwin -c green; LINUX empty .o (nested if / micro-unsafe).
// wave437: LINUX PREFER — flat arm helpers + dispatcher (Ubuntu -c ~12096B).
// wave445: tip pure-asm regen → product si SEGV; reinject via -E.
// wave448: full to_rax tip pure-asm HARD BAN (alone → si SEGV 139); arms overlay
//   via runtime_pipeline_abi_assign_rhsrax_arms_thin.x PREFER_ASM.
// wave454: dispatcher-only no-local PREFER
//   (runtime_pipeline_abi_assign_rhsrax_to_rax_thin.x); this full thin stays -E.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS (full assign covers).

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
export extern function pipeline_asm_emit_assign_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_field_assign_pair_base_ref_c(arena: *u8, er: i32): i32;
export extern function glue_body_expr_stmt_at_c(arena: *u8, body_ref: i32, si: i32, nso: i32, out_er: *i32): i32;

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
/**
 * wave437: load left@rax right@rbx for compound assign (or push/pop fallback).
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — 0 ok / -1 fail (maps try_binop -1/-2 paths)
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_load_lr_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let vr: i32 = 0;
    let rc: i32 = 0;
    vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
    if (vr == -1) {
      return -1;
    }
    if (vr != -2) {
      return 0;
    }
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta);
    if (rc != 0) {
      return -1;
    }
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
    if (rc != 0) {
      return -1;
    }
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
    if (rc != 0) {
      return -1;
    }
    rc = backend_enc_pop_rbx_arch(elf_ctx, ta);
    if (rc != 0) {
      return -1;
    }
    return 0;
  }
}
#[no_mangle]
export function glue_emit_assign_shr_u_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let is_64bit: i32 = 0;
    is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, 0);
    if (is_64bit != 0) {
      return backend_enc_shr_cl_rax_arch(elf_ctx, ta);
    }
    return backend_enc_shr_cl_eax_arch(elf_ctx, ta);
  }
}
/**
 * wave437 helper: assign rhs_to_rax arm `plain`.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param assign_expr_ref i32 — assign expr (unused in some arms)
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — status
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_plain_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return glue_emit_assign_rhs_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
}

/**
 * wave437 helper: assign rhs_to_rax arm `add`.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param assign_expr_ref i32 — assign expr (unused in some arms)
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — status
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_add_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  }
}

/**
 * wave437 helper: assign rhs_to_rax arm `sub`.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param assign_expr_ref i32 — assign expr (unused in some arms)
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — status
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_sub_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return glue_emit_binop_sub_rax_minus_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  }
}

/**
 * wave437 helper: assign rhs_to_rax arm `mul`.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param assign_expr_ref i32 — assign expr (unused in some arms)
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — status
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_mul_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  }
}

/**
 * wave437 helper: assign rhs_to_rax arm `div`.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param assign_expr_ref i32 — assign expr (unused in some arms)
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — status
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_div_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let is_f64_l: i32 = 0;
    let is_f64_r: i32 = 0;
    let is_f32_l: i32 = 0;
    let is_f32_r: i32 = 0;
    let rc: i32 = 0;
    is_f64_l = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref);
    is_f64_r = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref);
    if ((ta == 0 || ta == 1) && is_f64_l != 0 && is_f64_r != 0) {
      return backend_enc_divsd_rax_rbx_arch(elf_ctx, ta);
    }
    is_f32_l = glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref);
    is_f32_r = glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref);
    if ((ta == 0 || ta == 1) && is_f32_l != 0 && is_f32_r != 0) {
      return backend_enc_divss_rax_rbx_arch(elf_ctx, ta);
    }
    rc = pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta);
    if (rc != 0) {
      return -1;
    }
    return backend_enc_idiv_rbx_arch(elf_ctx, ta);
  }
}

/**
 * wave437 helper: assign rhs_to_rax arm `mod`.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param assign_expr_ref i32 — assign expr (unused in some arms)
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — status
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_mod_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let rc: i32 = 0;
    rc = pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta);
    if (rc != 0) {
      return -1;
    }
    return backend_enc_rem_mod_arch(elf_ctx, ta);
  }
}

/**
 * wave437 helper: assign rhs_to_rax arm `and`.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param assign_expr_ref i32 — assign expr (unused in some arms)
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — status
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_and_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return backend_enc_and_rbx_rax_arch(elf_ctx, ta);
  }
}

/**
 * wave437 helper: assign rhs_to_rax arm `or`.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param assign_expr_ref i32 — assign expr (unused in some arms)
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — status
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_or_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return backend_enc_or_rbx_rax_arch(elf_ctx, ta);
  }
}

/**
 * wave437 helper: assign rhs_to_rax arm `xor`.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param assign_expr_ref i32 — assign expr (unused in some arms)
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — status
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_xor_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
  }
}

/**
 * wave437 helper: assign rhs_to_rax arm `shl`.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param assign_expr_ref i32 — assign expr (unused in some arms)
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — status
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_shl_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let rc: i32 = 0;
    let is_64bit: i32 = 0;
    glue_binop_var_slot_cache_clear();
    rc = backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta);
    if (rc != 0) {
      return -1;
    }
    is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, 0);
    if (is_64bit != 0) {
      return backend_enc_shl_cl_rax_arch(elf_ctx, ta);
    }
    return backend_enc_shl_cl_eax_arch(elf_ctx, ta);
  }
}

/**
 * wave437 helper: assign rhs_to_rax arm `shr`.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF ctx
 * @param assign_expr_ref i32 — assign expr (unused in some arms)
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — emit ctx
 * @param ta i32 — arch
 * @return i32 — status
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_shr_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let rc: i32 = 0;
    let is_64bit: i32 = 0;
    let is_unsigned: i32 = 0;
    glue_binop_var_slot_cache_clear();
    rc = backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta);
    if (rc != 0) {
      return -1;
    }
    is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, 0);
    is_unsigned = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, 0);
    if (is_unsigned != 0) {
      return glue_emit_assign_shr_u_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (is_64bit != 0) {
      return backend_enc_sar_cl_rax_arch(elf_ctx, ta);
    }
    return backend_enc_sar_cl_eax_arch(elf_ctx, ta);
  }
}

/**
 * wave149 pure: G.7 assign RHS→rax (wave437 flat peer reshape).
 * @param arena *u8 - parameter
 * @param elf_ctx *u8 - parameter
 * @param assign_expr_ref i32 - parameter
 * @param left_ref i32 - parameter
 * @param right_ref i32 - parameter
 * @param ctx *u8 - parameter
 * @param ta i32 - parameter
 * @return i32 - face-specific status
 * PLATFORM: SHARED freestanding emit.
 */
export function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  let ako: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || assign_expr_ref <= 0 || left_ref <= 0 || right_ref <= 0) {
    return -1;
  }
  unsafe {
    ako = pipeline_expr_kind_ord_at(arena, assign_expr_ref);
  }
  if (ako == 28) {
    return glue_emit_assign_rhs_plain_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
  }
  if (ako < 29) {
    return -1;
  }
  if (ako > 38) {
    return -1;
  }
  if (glue_emit_assign_load_lr_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) != 0) {
    return -1;
  }
  if (ako == 29) {
    return glue_emit_assign_rhs_add_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
  }
  if (ako == 30) {
    return glue_emit_assign_rhs_sub_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
  }
  if (ako == 31) {
    return glue_emit_assign_rhs_mul_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
  }
  if (ako == 32) {
    return glue_emit_assign_rhs_div_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
  }
  if (ako == 33) {
    return glue_emit_assign_rhs_mod_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
  }
  if (ako == 34) {
    return glue_emit_assign_rhs_and_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
  }
  if (ako == 35) {
    return glue_emit_assign_rhs_or_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
  }
  if (ako == 36) {
    return glue_emit_assign_rhs_xor_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
  }
  if (ako == 37) {
    return glue_emit_assign_rhs_shl_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
  }
  if (ako == 38) {
    return glue_emit_assign_rhs_shr_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
  }
  return -1;
}
