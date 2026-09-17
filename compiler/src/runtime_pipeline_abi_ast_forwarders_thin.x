// Thin pure: wave322 M2 — ast_forwarders Cap residual C→.x (was wave283 C thin).
// ast_pipeline_* rename shims + pipeline_copy_lib_root_to_buf256.
// G.7: bodies match runtime_pipeline_abi_ast_forwarders_thin.c / seed WAVE283.
// PRODUCT inject: -E+$CC via pipeline_abi_inject_ast_forwarders_thin
// (ALLOW_E_REPLACE + stamp). No file-local BSS.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function ast_pool_onefunc_reset(out: *u8): void;
export extern function pipeline_arena_block_alloc(a: *u8): i32;
export extern function pipeline_arena_block_cap(): i32;
export extern function pipeline_arena_expr_alloc(a: *u8): i32;
export extern function pipeline_arena_expr_cap(): i32;
export extern function pipeline_arena_func_alloc(a: *u8): i32;
export extern function pipeline_arena_func_cap(): i32;
export extern function pipeline_arena_type_alloc(a: *u8): i32;
export extern function pipeline_arena_type_cap(): i32;
export extern function pipeline_block_append_const(a: *u8, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32;
export extern function pipeline_block_append_expr_stmt(a: *u8, br: i32, expr_ref: i32): i32;
export extern function pipeline_block_append_for(a: *u8, br: i32, init_ref: i32, cond_ref: i32, step_ref: i32, body_ref: i32): i32;
export extern function pipeline_block_append_if(a: *u8, br: i32, cond_ref: i32, then_ref: i32, else_ref: i32): i32;
export extern function pipeline_block_append_labeled(a: *u8, br: i32, label_len: i32, is_goto: i32, goto_target_len: i32, return_expr_ref: i32): i32;
export extern function pipeline_block_append_let(a: *u8, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32;
export extern function pipeline_block_append_region(a: *u8, br: i32, label: *u8, label_len: i32, body_ref: i32): i32;
export extern function pipeline_block_append_stmt_order(a: *u8, br: i32, kind: u8, idx: i32): i32;
export extern function pipeline_block_append_unsafe(a: *u8, br: i32, body_ref: i32): i32;
export extern function pipeline_block_append_while(a: *u8, br: i32, cond_ref: i32, body_ref: i32): i32;
export extern function pipeline_block_append_with_arena(a: *u8, br: i32, cap_ref: i32, body_ref: i32): i32;
export extern function pipeline_block_const_init_ref(a: *u8, br: i32, ci: i32): i32;
export extern function pipeline_block_const_name_copy64(a: *u8, br: i32, ci: i32, dst: *u8): void;
export extern function pipeline_block_const_name_len(a: *u8, br: i32, ci: i32): i32;
export extern function pipeline_block_const_type_ref(a: *u8, br: i32, ci: i32): i32;
export extern function pipeline_block_expr_stmt_ref(a: *u8, br: i32, ei: i32): i32;
export extern function pipeline_block_fill_expr_stmts_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_fill_fors_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_fill_ifs_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_fill_stmt_order_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_fill_whiles_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_if_cond_ref(a: *u8, br: i32, ii: i32): i32;
export extern function pipeline_block_if_else_body_ref(a: *u8, br: i32, ii: i32): i32;
export extern function pipeline_block_if_then_body_ref(a: *u8, br: i32, ii: i32): i32;
export extern function pipeline_block_labeled_return_expr_ref(a: *u8, br: i32, li: i32): i32;
export extern function pipeline_block_let_init_ref(a: *u8, br: i32, li: i32): i32;
export extern function pipeline_block_let_name_copy64(a: *u8, br: i32, li: i32, dst: *u8): void;
export extern function pipeline_block_let_name_len(a: *u8, br: i32, li: i32): i32;
export extern function pipeline_block_let_type_ref(a: *u8, br: i32, li: i32): i32;
export extern function pipeline_block_resolve_var_type_ref(a: *u8, block_ref: i32, vname: *u8, vlen: i32): i32;
export extern function pipeline_block_stmt_order_fix_prefix_lets(a: *u8, br: i32, prefix_n: i32): void;
export extern function pipeline_block_stmt_order_idx(a: *u8, br: i32, si: i32): i32;
export extern function pipeline_block_stmt_order_kind(a: *u8, br: i32, si: i32): u8;
export extern function pipeline_block_with_arena_fixup_stmt_order(a: *u8, br: i32): void;
export extern function pipeline_codegen_call_num_args_override(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, num_args: i32): i32;
export extern function pipeline_codegen_call_num_args_override_lookup(buf: *u8, full: i32, num_args: i32): i32;
export extern function pipeline_codegen_entry_is_lsp_io_module(module: *u8): i32;
export extern function pipeline_codegen_entry_is_lsp_main_module(module: *u8): i32;
export extern function pipeline_codegen_force_param_ptrdiff_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32;
export extern function pipeline_codegen_force_param_size_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32;
export extern function pipeline_codegen_force_param_size_t_std_io_print_str_second(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32;
export extern function pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix: *u8, prefix_len: i32): i32;
export extern function pipeline_codegen_force_param_uint32_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32;
export extern function pipeline_codegen_io_driver_buf_call_sym(name: *u8, name_len: i32, num_args: i32, sym_out: *u8, sym_cap: i32): i32;
export extern function pipeline_codegen_is_std_io_driver_bridge_name(name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_is_submit_batch_buf_call(name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_path_is_std_io_core_bytes(path: *u8): i32;
export extern function pipeline_codegen_path_is_std_io_driver_bytes(path: *u8): i32;
export extern function pipeline_codegen_should_skip_emit_func(dep_path: *u8, prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_should_skip_emit_func_by_name(name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_should_skip_emit_func_core_read_ptr(name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_should_skip_emit_std_io_core_io_dup(dep_path: *u8, name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_should_skip_emit_std_io_trivial_handle(dep_path: *u8, name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_skip_emit_extern_io_batch_buf(name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_std_io_fixed_fd_emit_impl(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_type_kind_append(scratch: *u8, cap: i32, w: i32, kind: i32): i32;
export extern function pipeline_codegen_type_kind_copy(dst: *u8, cap: i32, kind: i32): i32;
export extern function pipeline_codegen_use_buf_wrapper(name: *u8, name_len: i32, num_args: i32): i32;
export extern function pipeline_codegen_vector_type_copy(dst: *u8, cap: i32, elem_kind: i32, lanes: i32): i32;
export extern function pipeline_ctx_append_lib_root(ctx: *u8, path: *u8, len: i32): i32;
export extern function pipeline_ctx_lib_root_byte_at(ctx: *u8, i: i32, off: i32): u8;
export extern function pipeline_ctx_lib_root_copy(ctx: *u8, i: i32, dst: *u8, cap: i32): void;
export extern function pipeline_ctx_lib_root_count(ctx: *u8): i32;
export extern function pipeline_ctx_lib_root_len(ctx: *u8, i: i32): i32;
export extern function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_dep_ctx_asm_entry_module_only(ctx: *u8): i32;
export extern function pipeline_dep_ctx_check_only_mode(ctx: *u8): i32;
export extern function pipeline_dep_ctx_codegen_prefix_byte_at(ctx: *u8, off: i32): u8;
export extern function pipeline_dep_ctx_codegen_prefix_copy(ctx: *u8, dst: *u8, cap: i32): void;
export extern function pipeline_dep_ctx_codegen_prefix_len(ctx: *u8): i32;
export extern function pipeline_dep_ctx_current_codegen_arena(ctx: *u8): *u8;
export extern function pipeline_dep_ctx_current_codegen_dep_index(ctx: *u8): i32;
export extern function pipeline_dep_ctx_current_codegen_module(ctx: *u8): *u8;
export extern function pipeline_dep_ctx_current_func_index(ctx: *u8): i32;
export extern function pipeline_dep_ctx_ensure_source_buffers(ctx: *u8): i32;
export extern function pipeline_dep_ctx_entry_already_parsed(ctx: *u8): i32;
export extern function pipeline_dep_ctx_entry_dir_byte_at(ctx: *u8, off: i32): u8;
export extern function pipeline_dep_ctx_entry_dir_len(ctx: *u8): i32;
export extern function pipeline_dep_ctx_free_source_buffers(ctx: *u8): void;
export extern function pipeline_dep_ctx_heap_destroy(ctx: *u8): void;
export extern function pipeline_dep_ctx_import_path_copy64(ctx: *u8, idx: i32, dst: *u8): void;
export extern function pipeline_dep_ctx_import_path_len(ctx: *u8, idx: i32): i32;
export extern function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern function pipeline_dep_ctx_reset(ctx: *u8): void;
export extern function pipeline_dep_ctx_set_arena(ctx: *u8, idx: i32, a: *u8): void;
export extern function pipeline_dep_ctx_set_codegen_prefix_mirror(ctx: *u8, bytes: *u8, len: i32): void;
export extern function pipeline_dep_ctx_set_current_codegen_arena(ctx: *u8, a: *u8): void;
export extern function pipeline_dep_ctx_set_current_codegen_dep_index(ctx: *u8, ix: i32): void;
export extern function pipeline_dep_ctx_set_current_codegen_module(ctx: *u8, m: *u8): void;
export extern function pipeline_dep_ctx_set_current_func_index(ctx: *u8, ix: i32): void;
export extern function pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_dep_ctx_set_loaded_len(ctx: *u8, n: isize): void;
export extern function pipeline_dep_ctx_set_module(ctx: *u8, idx: i32, m: *u8): void;
export extern function pipeline_dep_ctx_set_ndep(ctx: *u8, n: i32): void;
export extern function pipeline_dep_ctx_set_path_buf_byte(ctx: *u8, off: i32, b: u8): void;
export extern function pipeline_dep_ctx_use_asm_backend(ctx: *u8): i32;
export extern function pipeline_elf_ctx_append_patch(ctx_bytes: *u8, rel32_offset: i32, name: *u8, name_len: i32, imm_bits: i32): i32;
export extern function pipeline_elf_ctx_append_reloc(ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_expr_try_mark_enum_field_access(m: *u8, a: *u8, expr_ref: i32): void;
export extern function pipeline_module_enum_alloc(m: *u8): i32;
export extern function pipeline_module_enum_append_variant(m: *u8, idx: i32, bytes: *u8, len: i32): i32;
export extern function pipeline_module_enum_name_byte_at(m: *u8, idx: i32, off: i32): u8;
export extern function pipeline_module_enum_name_len(m: *u8, idx: i32): i32;
export extern function pipeline_module_enum_set_name(m: *u8, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_enum_variant_tag_for_names(m: *u8, enum_name: *u8, enum_len: i32, variant_name: *u8, variant_len: i32): i32;
export extern function pipeline_module_func_alloc_slot(m: *u8): i32;
export extern function pipeline_module_func_body_expr_ref_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_name_byte_at(m: *u8, fi: i32, i: i32): u8;
export extern function pipeline_module_func_name_equal_at(m: *u8, fi: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_module_func_num_generic_params_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_ref_at(m: *u8, func_index: i32): i32;
export extern function pipeline_module_func_ref_set(m: *u8, fi: i32, func_ref: i32): void;
export extern function pipeline_module_func_return_type_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_set_body_expr_ref(m: *u8, fi: i32, body_expr_ref: i32): void;
export extern function pipeline_module_func_set_body_ref(m: *u8, fi: i32, body_ref: i32): void;
export extern function pipeline_module_func_set_is_async(m: *u8, fi: i32, is_async: i32): void;
export extern function pipeline_module_func_set_is_extern(m: *u8, fi: i32, is_extern: i32): void;
export extern function pipeline_module_func_set_num_params(m: *u8, fi: i32, n: i32): void;
export extern function pipeline_module_func_set_return_type(m: *u8, fi: i32, type_ref: i32): void;
export extern function pipeline_module_hoist_top_level_lets_into_main(m: *u8, a: *u8): void;
export extern function pipeline_module_import_alloc(m: *u8): i32;
export extern function pipeline_module_import_binding_name_byte_at(m: *u8, idx: i32, off: i32): u8;
export extern function pipeline_module_import_binding_name_len(m: *u8, idx: i32): i32;
export extern function pipeline_module_import_kind_at(m: *u8, idx: i32): i32;
export extern function pipeline_module_import_path_byte_at(m: *u8, idx: i32, off: i32): u8;
export extern function pipeline_module_import_path_copy(m: *u8, idx: i32, dst: *u8, dst_cap: i32): void;
export extern function pipeline_module_import_path_len(m: *u8, idx: i32): i32;
export extern function pipeline_module_import_select_count_at(m: *u8, idx: i32): i32;
export extern function pipeline_module_import_select_name_byte_at(m: *u8, idx: i32, sel: i32, off: i32): u8;
export extern function pipeline_module_import_select_name_len(m: *u8, idx: i32, sel: i32): i32;
export extern function pipeline_module_import_set_binding_name(m: *u8, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_import_set_kind(m: *u8, idx: i32, kind: i32): void;
export extern function pipeline_module_import_set_path(m: *u8, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_import_set_select_count(m: *u8, idx: i32, n: i32): void;
export extern function pipeline_module_struct_layout_alloc(m: *u8): i32;
export extern function pipeline_module_struct_layout_allow_padding_at(m: *u8, idx: i32): i32;
export extern function pipeline_module_struct_layout_field_name_into(m: *u8, li: i32, j: i32, out64: *u8): void;
export extern function pipeline_module_struct_layout_field_name_len(m: *u8, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_offset_at(m: *u8, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_type_ref(m: *u8, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_name_byte_at(m: *u8, idx: i32, off: i32): u8;
export extern function pipeline_module_struct_layout_name_into(m: *u8, idx: i32, out64: *u8): void;
export extern function pipeline_module_struct_layout_name_len(m: *u8, idx: i32): i32;
export extern function pipeline_module_struct_layout_num_fields(m: *u8, idx: i32): i32;
export extern function pipeline_module_struct_layout_reset_slot(m: *u8, idx: i32): void;
export extern function pipeline_module_struct_layout_set_allow_padding(m: *u8, idx: i32, v: i32): void;
export extern function pipeline_module_struct_layout_set_field(m: *u8, li: i32, j: i32, fname_bytes: *u8, fname_len: i32, ftype_ref: i32, foff: i32): void;
export extern function pipeline_module_struct_layout_set_name(m: *u8, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_struct_layout_set_num_fields(m: *u8, idx: i32, nf: i32): void;
export extern function pipeline_module_top_level_let_alloc(m: *u8): i32;
export extern function pipeline_module_top_level_let_init_ref(m: *u8, idx: i32): i32;
export extern function pipeline_module_top_level_let_is_const(m: *u8, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(m: *u8, idx: i32, off: i32): u8;
export extern function pipeline_module_top_level_let_name_len(m: *u8, idx: i32): i32;
export extern function pipeline_module_top_level_let_set(m: *u8, idx: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32, is_const: i32): void;
export extern function pipeline_module_top_level_let_type_ref(m: *u8, idx: i32): i32;
export extern function pipeline_onefunc_append_const(out: *u8, name: *u8, name_len: i32, init_val: i32, init_ref: i32, type_ref: i32): i32;
export extern function pipeline_onefunc_append_for(out: *u8, init_ref: i32, cond_ref: i32, step_ref: i32, body_ref: i32): i32;
export extern function pipeline_onefunc_append_let(out: *u8, name: *u8, name_len: i32, init_val: i32, init_ref: i32, type_ref: i32): i32;
export extern function pipeline_onefunc_append_while(out: *u8, cond_ref: i32, body_ref: i32): i32;
export extern function pipeline_onefunc_const_init_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_const_init_val(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_const_name_copy64(out: *u8, i: i32, dst: *u8): void;
export extern function pipeline_onefunc_const_name_len(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_const_type_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_copy_sidecar(dst: *u8, src: *u8): void;
export extern function pipeline_onefunc_let_init_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_let_init_val(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_let_name_copy64(out: *u8, i: i32, dst: *u8): void;
export extern function pipeline_onefunc_let_name_len(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_let_type_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_num_consts(out: *u8): i32;
export extern function pipeline_onefunc_num_fors(out: *u8): i32;
export extern function pipeline_onefunc_num_lets(out: *u8): i32;
export extern function pipeline_onefunc_num_whiles(out: *u8): i32;

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_alloc_slot.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_alloc_slot(m: *u8): i32 {
  return pipeline_module_func_alloc_slot(m);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_ref_set.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_ref_set(m: *u8, fi: i32, func_ref: i32): void {
  pipeline_module_func_ref_set(m, fi, func_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_set_return_type.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_set_return_type(m: *u8, fi: i32, type_ref: i32): void {
  pipeline_module_func_set_return_type(m, fi, type_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_set_body_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_set_body_ref(m: *u8, fi: i32, body_ref: i32): void {
  pipeline_module_func_set_body_ref(m, fi, body_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_set_body_expr_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_set_body_expr_ref(m: *u8, fi: i32, body_expr_ref: i32): void {
  pipeline_module_func_set_body_expr_ref(m, fi, body_expr_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_set_is_extern.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_set_is_extern(m: *u8, fi: i32, is_extern: i32): void {
  pipeline_module_func_set_is_extern(m, fi, is_extern);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_set_is_async.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_set_is_async(m: *u8, fi: i32, is_async: i32): void {
  pipeline_module_func_set_is_async(m, fi, is_async);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_set_num_params.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_set_num_params(m: *u8, fi: i32, n: i32): void {
  pipeline_module_func_set_num_params(m, fi, n);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_num_generic_params_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_num_generic_params_at(m: *u8, fi: i32): i32 {
  return pipeline_module_func_num_generic_params_at(m, fi);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_return_type_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_return_type_at(m: *u8, fi: i32): i32 {
  return pipeline_module_func_return_type_at(m, fi);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_name_equal_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_name_equal_at(m: *u8, fi: i32, name: *u8, name_len: i32): i32 {
  return pipeline_module_func_name_equal_at(m, fi, name, name_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_name_byte_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_name_byte_at(m: *u8, fi: i32, i: i32): u8 {
  return pipeline_module_func_name_byte_at(m, fi, i);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_body_expr_ref_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_body_expr_ref_at(m: *u8, fi: i32): i32 {
  return pipeline_module_func_body_expr_ref_at(m, fi);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_ctx_append_lib_root.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_ctx_append_lib_root(ctx: *u8, path: *u8, len: i32): i32 {
  return pipeline_ctx_append_lib_root(ctx, path, len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_reset.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_reset(ctx: *u8): void {
  pipeline_dep_ctx_reset(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_ndep.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_ndep(ctx: *u8): i32 {
  return pipeline_dep_ctx_ndep(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_module_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8 {
  return pipeline_dep_ctx_module_at(ctx, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_arena_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8 {
  return pipeline_dep_ctx_arena_at(ctx, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_set_module.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_module(ctx: *u8, idx: i32, m: *u8): void {
  pipeline_dep_ctx_set_module(ctx, idx, m);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_set_arena.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_arena(ctx: *u8, idx: i32, a: *u8): void {
  pipeline_dep_ctx_set_arena(ctx, idx, a);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_set_ndep.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_ndep(ctx: *u8, n: i32): void {
  pipeline_dep_ctx_set_ndep(ctx, n);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_set_codegen_prefix_mirror.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_codegen_prefix_mirror(ctx: *u8, bytes: *u8, len: i32): void {
  pipeline_dep_ctx_set_codegen_prefix_mirror(ctx, bytes, len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_codegen_prefix_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_codegen_prefix_len(ctx: *u8): i32 {
  return pipeline_dep_ctx_codegen_prefix_len(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_codegen_prefix_byte_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_codegen_prefix_byte_at(ctx: *u8, off: i32): u8 {
  return pipeline_dep_ctx_codegen_prefix_byte_at(ctx, off);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_codegen_prefix_copy.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_codegen_prefix_copy(ctx: *u8, dst: *u8, cap: i32): void {
  pipeline_dep_ctx_codegen_prefix_copy(ctx, dst, cap);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_current_codegen_dep_index.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_current_codegen_dep_index(ctx: *u8): i32 {
  return pipeline_dep_ctx_current_codegen_dep_index(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_current_codegen_module.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_current_codegen_module(ctx: *u8): *u8 {
  return pipeline_dep_ctx_current_codegen_module(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_current_codegen_arena.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_current_codegen_arena(ctx: *u8): *u8 {
  return pipeline_dep_ctx_current_codegen_arena(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_current_func_index.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_current_func_index(ctx: *u8): i32 {
  return pipeline_dep_ctx_current_func_index(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_set_current_codegen_module.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_current_codegen_module(ctx: *u8, m: *u8): void {
  pipeline_dep_ctx_set_current_codegen_module(ctx, m);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_set_current_codegen_arena.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_current_codegen_arena(ctx: *u8, a: *u8): void {
  pipeline_dep_ctx_set_current_codegen_arena(ctx, a);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_set_current_codegen_dep_index.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_current_codegen_dep_index(ctx: *u8, ix: i32): void {
  pipeline_dep_ctx_set_current_codegen_dep_index(ctx, ix);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_set_current_func_index.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_current_func_index(ctx: *u8, ix: i32): void {
  pipeline_dep_ctx_set_current_func_index(ctx, ix);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_entry_already_parsed.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_entry_already_parsed(ctx: *u8): i32 {
  return pipeline_dep_ctx_entry_already_parsed(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_asm_entry_module_only.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_asm_entry_module_only(ctx: *u8): i32 {
  return pipeline_dep_ctx_asm_entry_module_only(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_check_only_mode.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_check_only_mode(ctx: *u8): i32 {
  return pipeline_dep_ctx_check_only_mode(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_use_asm_backend.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_use_asm_backend(ctx: *u8): i32 {
  return pipeline_dep_ctx_use_asm_backend(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_entry_dir_byte_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_entry_dir_byte_at(ctx: *u8, off: i32): u8 {
  return pipeline_dep_ctx_entry_dir_byte_at(ctx, off);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_type_kind_copy.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_type_kind_copy(dst: *u8, cap: i32, kind: i32): i32 {
  return pipeline_codegen_type_kind_copy(dst, cap, kind);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_type_kind_append.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_type_kind_append(scratch: *u8, cap: i32, w: i32, kind: i32): i32 {
  return pipeline_codegen_type_kind_append(scratch, cap, w, kind);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_vector_type_copy.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_vector_type_copy(dst: *u8, cap: i32, elem_kind: i32, lanes: i32): i32 {
  return pipeline_codegen_vector_type_copy(dst, cap, elem_kind, lanes);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_call_num_args_override_lookup.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_call_num_args_override_lookup(buf: *u8, full: i32, num_args: i32): i32 {
  return pipeline_codegen_call_num_args_override_lookup(buf, full, num_args);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_call_num_args_override.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_call_num_args_override(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, num_args: i32): i32 {
  return pipeline_codegen_call_num_args_override(prefix, prefix_len, name, name_len, num_args);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_is_std_io_driver_bridge_name.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_is_std_io_driver_bridge_name(name: *u8, name_len: i32): i32 {
  return pipeline_codegen_is_std_io_driver_bridge_name(name, name_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_path_is_std_io_driver_bytes.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_path_is_std_io_driver_bytes(path: *u8): i32 {
  return pipeline_codegen_path_is_std_io_driver_bytes(path);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_path_is_std_io_core_bytes.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_path_is_std_io_core_bytes(path: *u8): i32 {
  return pipeline_codegen_path_is_std_io_core_bytes(path);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_should_skip_emit_std_io_core_io_dup.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_should_skip_emit_std_io_core_io_dup(dep_path: *u8, name: *u8, name_len: i32): i32 {
  return pipeline_codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_should_skip_emit_std_io_trivial_handle.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_should_skip_emit_std_io_trivial_handle(dep_path: *u8, name: *u8, name_len: i32): i32 {
  return pipeline_codegen_should_skip_emit_std_io_trivial_handle(dep_path, name, name_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_should_skip_emit_func.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_should_skip_emit_func(dep_path: *u8, prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  return pipeline_codegen_should_skip_emit_func(dep_path, prefix, prefix_len, name, name_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_skip_emit_extern_io_batch_buf.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_skip_emit_extern_io_batch_buf(name: *u8, name_len: i32): i32 {
  return pipeline_codegen_skip_emit_extern_io_batch_buf(name, name_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_entry_is_lsp_io_module.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_entry_is_lsp_io_module(module: *u8): i32 {
  return pipeline_codegen_entry_is_lsp_io_module(module);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_entry_is_lsp_main_module.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_entry_is_lsp_main_module(module: *u8): i32 {
  return pipeline_codegen_entry_is_lsp_main_module(module);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_force_param_std_io_driver_prefix_ok.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix: *u8, prefix_len: i32): i32 {
  return pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_force_param_size_t.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_force_param_size_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  return pipeline_codegen_force_param_size_t(prefix, prefix_len, name, name_len, param_index);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_force_param_size_t_std_io_print_str_second.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_force_param_size_t_std_io_print_str_second(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  return pipeline_codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, name, name_len, param_index);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_force_param_ptrdiff_t.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_force_param_ptrdiff_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  return pipeline_codegen_force_param_ptrdiff_t(prefix, prefix_len, name, name_len, param_index);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_force_param_uint32_t.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_force_param_uint32_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  return pipeline_codegen_force_param_uint32_t(prefix, prefix_len, name, name_len, param_index);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_use_buf_wrapper.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_use_buf_wrapper(name: *u8, name_len: i32, num_args: i32): i32 {
  return pipeline_codegen_use_buf_wrapper(name, name_len, num_args);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_should_skip_emit_func_by_name.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_should_skip_emit_func_by_name(name: *u8, name_len: i32): i32 {
  return pipeline_codegen_should_skip_emit_func_by_name(name, name_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_is_submit_batch_buf_call.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_is_submit_batch_buf_call(name: *u8, name_len: i32): i32 {
  return pipeline_codegen_is_submit_batch_buf_call(name, name_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_should_skip_emit_func_core_read_ptr.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_should_skip_emit_func_core_read_ptr(name: *u8, name_len: i32): i32 {
  return pipeline_codegen_should_skip_emit_func_core_read_ptr(name, name_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_io_driver_buf_call_sym.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_io_driver_buf_call_sym(name: *u8, name_len: i32, num_args: i32, sym_out: *u8, sym_cap: i32): i32 {
  return pipeline_codegen_io_driver_buf_call_sym(name, name_len, num_args, sym_out, sym_cap);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_codegen_std_io_fixed_fd_emit_impl.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_codegen_std_io_fixed_fd_emit_impl(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  return pipeline_codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, name, name_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_elf_ctx_append_patch.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_elf_ctx_append_patch(ctx_bytes: *u8, rel32_offset: i32, name: *u8, name_len: i32, imm_bits: i32): i32 {
  return pipeline_elf_ctx_append_patch(ctx_bytes, rel32_offset, name, name_len, imm_bits);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_elf_ctx_append_reloc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_elf_ctx_append_reloc(ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32): i32 {
  return pipeline_elf_ctx_append_reloc(ctx_bytes, offset, name, name_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_set_import_path.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, bytes: *u8, len: i32): void {
  pipeline_dep_ctx_set_import_path(ctx, idx, bytes, len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_import_path_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_import_path_len(ctx: *u8, idx: i32): i32 {
  return pipeline_dep_ctx_import_path_len(ctx, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_import_path_copy64.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_import_path_copy64(ctx: *u8, idx: i32, dst: *u8): void {
  pipeline_dep_ctx_import_path_copy64(ctx, idx, dst);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_set_path_buf_byte.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_path_buf_byte(ctx: *u8, off: i32, b: u8): void {
  pipeline_dep_ctx_set_path_buf_byte(ctx, off, b);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_entry_dir_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_entry_dir_len(ctx: *u8): i32 {
  return pipeline_dep_ctx_entry_dir_len(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_ensure_source_buffers.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_ensure_source_buffers(ctx: *u8): i32 {
  return pipeline_dep_ctx_ensure_source_buffers(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_free_source_buffers.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_free_source_buffers(ctx: *u8): void {
  pipeline_dep_ctx_free_source_buffers(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_heap_destroy.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_heap_destroy(ctx: *u8): void {
  pipeline_dep_ctx_heap_destroy(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_dep_ctx_set_loaded_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_loaded_len(ctx: *u8, n: isize): void {
  pipeline_dep_ctx_set_loaded_len(ctx, n);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_ctx_lib_root_count.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_ctx_lib_root_count(ctx: *u8): i32 {
  return pipeline_ctx_lib_root_count(ctx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_ctx_lib_root_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_ctx_lib_root_len(ctx: *u8, i: i32): i32 {
  return pipeline_ctx_lib_root_len(ctx, i);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_ctx_lib_root_copy.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_ctx_lib_root_copy(ctx: *u8, i: i32, dst: *u8, cap: i32): void {
  pipeline_ctx_lib_root_copy(ctx, i, dst, cap);
}

/**
 * Cap residual rename shim / leave: pipeline_copy_lib_root_to_buf256.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function pipeline_copy_lib_root_to_buf256(ctx: *u8, lib_idx: i32, dst: *u8): i32 {
  if (dst == (0 as *u8)) { return 0; }
  let i: i32 = 0;
  while (i < 256) {
    unsafe { dst[i] = 0 as u8; }
    i = i + 1;
  }
  if (ctx == (0 as *u8) || lib_idx < 0) { return 0; }
  let lr_len: i32 = pipeline_ctx_lib_root_len(ctx, lib_idx);
  if (lr_len > 0) {
    pipeline_ctx_lib_root_copy(ctx, lib_idx, dst, 256);
  }
  return lr_len;
}

/**
 * Cap residual rename shim / leave: ast_pipeline_ctx_lib_root_byte_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_ctx_lib_root_byte_at(ctx: *u8, i: i32, off: i32): u8 {
  return pipeline_ctx_lib_root_byte_at(ctx, i, off);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_append_const.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_append_const(a: *u8, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32 {
  return pipeline_block_append_const(a, br, name, name_len, type_ref, init_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_append_let.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_append_let(a: *u8, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32 {
  return pipeline_block_append_let(a, br, name, name_len, type_ref, init_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_append_if.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_append_if(a: *u8, br: i32, cond_ref: i32, then_ref: i32, else_ref: i32): i32 {
  return pipeline_block_append_if(a, br, cond_ref, then_ref, else_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_append_region.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_append_region(a: *u8, br: i32, label: *u8, label_len: i32, body_ref: i32): i32 {
  return pipeline_block_append_region(a, br, label, label_len, body_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_append_unsafe.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_append_unsafe(a: *u8, br: i32, body_ref: i32): i32 {
  return pipeline_block_append_unsafe(a, br, body_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_append_with_arena.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_append_with_arena(a: *u8, br: i32, cap_ref: i32, body_ref: i32): i32 {
  return pipeline_block_append_with_arena(a, br, cap_ref, body_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_append_while.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_append_while(a: *u8, br: i32, cond_ref: i32, body_ref: i32): i32 {
  return pipeline_block_append_while(a, br, cond_ref, body_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_append_for.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_append_for(a: *u8, br: i32, init_ref: i32, cond_ref: i32, step_ref: i32, body_ref: i32): i32 {
  return pipeline_block_append_for(a, br, init_ref, cond_ref, step_ref, body_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_alloc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_alloc(m: *u8): i32 {
  return pipeline_module_import_alloc(m);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_set_path.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_set_path(m: *u8, idx: i32, bytes: *u8, len: i32): void {
  pipeline_module_import_set_path(m, idx, bytes, len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_set_kind.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_set_kind(m: *u8, idx: i32, kind: i32): void {
  pipeline_module_import_set_kind(m, idx, kind);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_set_binding_name.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_set_binding_name(m: *u8, idx: i32, bytes: *u8, len: i32): void {
  pipeline_module_import_set_binding_name(m, idx, bytes, len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_set_select_count.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_set_select_count(m: *u8, idx: i32, n: i32): void {
  pipeline_module_import_set_select_count(m, idx, n);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_path_copy.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_path_copy(m: *u8, idx: i32, dst: *u8, dst_cap: i32): void {
  pipeline_module_import_path_copy(m, idx, dst, dst_cap);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_enum_alloc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_enum_alloc(m: *u8): i32 {
  return pipeline_module_enum_alloc(m);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_enum_set_name.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_enum_set_name(m: *u8, idx: i32, bytes: *u8, len: i32): void {
  pipeline_module_enum_set_name(m, idx, bytes, len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_top_level_let_alloc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_top_level_let_alloc(m: *u8): i32 {
  return pipeline_module_top_level_let_alloc(m);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_top_level_let_set.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_top_level_let_set(m: *u8, idx: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32, is_const: i32): void {
  pipeline_module_top_level_let_set(m, idx, name, name_len, type_ref, init_ref, is_const);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_hoist_top_level_lets_into_main.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_hoist_top_level_lets_into_main(m: *u8, a: *u8): void {
  pipeline_module_hoist_top_level_lets_into_main(m, a);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_path_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_path_len(m: *u8, idx: i32): i32 {
  return pipeline_module_import_path_len(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_path_byte_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_path_byte_at(m: *u8, idx: i32, off: i32): u8 {
  return pipeline_module_import_path_byte_at(m, idx, off);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_kind_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_kind_at(m: *u8, idx: i32): i32 {
  return pipeline_module_import_kind_at(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_binding_name_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_binding_name_len(m: *u8, idx: i32): i32 {
  return pipeline_module_import_binding_name_len(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_binding_name_byte_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_binding_name_byte_at(m: *u8, idx: i32, off: i32): u8 {
  return pipeline_module_import_binding_name_byte_at(m, idx, off);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_select_count_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_select_count_at(m: *u8, idx: i32): i32 {
  return pipeline_module_import_select_count_at(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_select_name_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_select_name_len(m: *u8, idx: i32, sel: i32): i32 {
  return pipeline_module_import_select_name_len(m, idx, sel);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_import_select_name_byte_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_import_select_name_byte_at(m: *u8, idx: i32, sel: i32, off: i32): u8 {
  return pipeline_module_import_select_name_byte_at(m, idx, sel, off);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_alloc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_alloc(m: *u8): i32 {
  return pipeline_module_struct_layout_alloc(m);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_reset_slot.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_reset_slot(m: *u8, idx: i32): void {
  pipeline_module_struct_layout_reset_slot(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_set_name.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_set_name(m: *u8, idx: i32, bytes: *u8, len: i32): void {
  pipeline_module_struct_layout_set_name(m, idx, bytes, len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_set_field.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_set_field(m: *u8, li: i32, j: i32, fname_bytes: *u8, fname_len: i32, ftype_ref: i32, foff: i32): void {
  pipeline_module_struct_layout_set_field(m, li, j, fname_bytes, fname_len, ftype_ref, foff);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_set_num_fields.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_set_num_fields(m: *u8, idx: i32, nf: i32): void {
  pipeline_module_struct_layout_set_num_fields(m, idx, nf);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_name_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_name_len(m: *u8, idx: i32): i32 {
  return pipeline_module_struct_layout_name_len(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_name_into.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_name_into(m: *u8, idx: i32, out64: *u8): void {
  pipeline_module_struct_layout_name_into(m, idx, out64);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_name_byte_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_name_byte_at(m: *u8, idx: i32, off: i32): u8 {
  return pipeline_module_struct_layout_name_byte_at(m, idx, off);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_num_fields.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_num_fields(m: *u8, idx: i32): i32 {
  return pipeline_module_struct_layout_num_fields(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_field_name_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_field_name_len(m: *u8, li: i32, j: i32): i32 {
  return pipeline_module_struct_layout_field_name_len(m, li, j);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_field_name_into.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_field_name_into(m: *u8, li: i32, j: i32, out64: *u8): void {
  pipeline_module_struct_layout_field_name_into(m, li, j, out64);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_field_type_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_field_type_ref(m: *u8, li: i32, j: i32): i32 {
  return pipeline_module_struct_layout_field_type_ref(m, li, j);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_field_offset_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_field_offset_at(m: *u8, li: i32, j: i32): i32 {
  return pipeline_module_struct_layout_field_offset_at(m, li, j);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_set_allow_padding.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_set_allow_padding(m: *u8, idx: i32, v: i32): void {
  pipeline_module_struct_layout_set_allow_padding(m, idx, v);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_struct_layout_allow_padding_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_allow_padding_at(m: *u8, idx: i32): i32 {
  return pipeline_module_struct_layout_allow_padding_at(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_top_level_let_name_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_top_level_let_name_len(m: *u8, idx: i32): i32 {
  return pipeline_module_top_level_let_name_len(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_top_level_let_name_byte_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_top_level_let_name_byte_at(m: *u8, idx: i32, off: i32): u8 {
  return pipeline_module_top_level_let_name_byte_at(m, idx, off);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_top_level_let_type_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_top_level_let_type_ref(m: *u8, idx: i32): i32 {
  return pipeline_module_top_level_let_type_ref(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_top_level_let_init_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_top_level_let_init_ref(m: *u8, idx: i32): i32 {
  return pipeline_module_top_level_let_init_ref(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_top_level_let_is_const.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_top_level_let_is_const(m: *u8, idx: i32): i32 {
  return pipeline_module_top_level_let_is_const(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_enum_name_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_enum_name_len(m: *u8, idx: i32): i32 {
  return pipeline_module_enum_name_len(m, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_enum_name_byte_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_enum_name_byte_at(m: *u8, idx: i32, off: i32): u8 {
  return pipeline_module_enum_name_byte_at(m, idx, off);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_enum_append_variant.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_enum_append_variant(m: *u8, idx: i32, bytes: *u8, len: i32): i32 {
  return pipeline_module_enum_append_variant(m, idx, bytes, len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_enum_variant_tag_for_names.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_enum_variant_tag_for_names(m: *u8, enum_name: *u8, enum_len: i32, variant_name: *u8, variant_len: i32): i32 {
  return pipeline_module_enum_variant_tag_for_names(m, enum_name, enum_len, variant_name, variant_len);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_expr_try_mark_enum_field_access.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_expr_try_mark_enum_field_access(m: *u8, a: *u8, expr_ref: i32): void {
  pipeline_expr_try_mark_enum_field_access(m, a, expr_ref);
}

/**
 * Cap residual rename shim / leave: ast_ast_pool_onefunc_reset.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_ast_pool_onefunc_reset(out: *u8): void {
  ast_pool_onefunc_reset(out);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_num_consts.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_num_consts(out: *u8): i32 {
  return pipeline_onefunc_num_consts(out);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_num_lets.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_num_lets(out: *u8): i32 {
  return pipeline_onefunc_num_lets(out);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_num_whiles.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_num_whiles(out: *u8): i32 {
  return pipeline_onefunc_num_whiles(out);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_num_fors.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_num_fors(out: *u8): i32 {
  return pipeline_onefunc_num_fors(out);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_const_name_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_const_name_len(out: *u8, i: i32): i32 {
  return pipeline_onefunc_const_name_len(out, i);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_const_name_copy64.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_const_name_copy64(out: *u8, i: i32, dst: *u8): void {
  pipeline_onefunc_const_name_copy64(out, i, dst);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_const_init_val.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_const_init_val(out: *u8, i: i32): i32 {
  return pipeline_onefunc_const_init_val(out, i);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_let_name_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_let_name_len(out: *u8, i: i32): i32 {
  return pipeline_onefunc_let_name_len(out, i);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_let_name_copy64.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_let_name_copy64(out: *u8, i: i32, dst: *u8): void {
  pipeline_onefunc_let_name_copy64(out, i, dst);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_let_init_val.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_let_init_val(out: *u8, i: i32): i32 {
  return pipeline_onefunc_let_init_val(out, i);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_let_init_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_let_init_ref(out: *u8, i: i32): i32 {
  return pipeline_onefunc_let_init_ref(out, i);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_let_type_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_let_type_ref(out: *u8, i: i32): i32 {
  return pipeline_onefunc_let_type_ref(out, i);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_append_let.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_append_let(out: *u8, name: *u8, name_len: i32, init_val: i32, init_ref: i32, type_ref: i32): i32 {
  return pipeline_onefunc_append_let(out, name, name_len, init_val, init_ref, type_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_append_const.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_append_const(out: *u8, name: *u8, name_len: i32, init_val: i32, init_ref: i32, type_ref: i32): i32 {
  return pipeline_onefunc_append_const(out, name, name_len, init_val, init_ref, type_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_const_init_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_const_init_ref(out: *u8, i: i32): i32 {
  return pipeline_onefunc_const_init_ref(out, i);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_const_type_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_const_type_ref(out: *u8, i: i32): i32 {
  return pipeline_onefunc_const_type_ref(out, i);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_append_while.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_append_while(out: *u8, cond_ref: i32, body_ref: i32): i32 {
  return pipeline_onefunc_append_while(out, cond_ref, body_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_append_for.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_append_for(out: *u8, init_ref: i32, cond_ref: i32, step_ref: i32, body_ref: i32): i32 {
  return pipeline_onefunc_append_for(out, init_ref, cond_ref, step_ref, body_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_onefunc_copy_sidecar.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_onefunc_copy_sidecar(dst: *u8, src: *u8): void {
  pipeline_onefunc_copy_sidecar(dst, src);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_append_expr_stmt.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_append_expr_stmt(a: *u8, br: i32, expr_ref: i32): i32 {
  return pipeline_block_append_expr_stmt(a, br, expr_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_append_stmt_order.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_append_stmt_order(a: *u8, br: i32, kind: u8, idx: i32): i32 {
  return pipeline_block_append_stmt_order(a, br, kind, idx);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_stmt_order_fix_prefix_lets.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_stmt_order_fix_prefix_lets(a: *u8, br: i32, prefix_n: i32): void {
  pipeline_block_stmt_order_fix_prefix_lets(a, br, prefix_n);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_with_arena_fixup_stmt_order.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_with_arena_fixup_stmt_order(a: *u8, br: i32): void {
  pipeline_block_with_arena_fixup_stmt_order(a, br);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_append_labeled.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_append_labeled(a: *u8, br: i32, label_len: i32, is_goto: i32, goto_target_len: i32, return_expr_ref: i32): i32 {
  return pipeline_block_append_labeled(a, br, label_len, is_goto, goto_target_len, return_expr_ref);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_labeled_return_expr_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_labeled_return_expr_ref(a: *u8, br: i32, li: i32): i32 {
  return pipeline_block_labeled_return_expr_ref(a, br, li);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_fill_ifs_from_onefunc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_fill_ifs_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  pipeline_block_fill_ifs_from_onefunc(a, br, out, count);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_fill_whiles_from_onefunc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_fill_whiles_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  pipeline_block_fill_whiles_from_onefunc(a, br, out, count);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_fill_fors_from_onefunc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_fill_fors_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  pipeline_block_fill_fors_from_onefunc(a, br, out, count);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_fill_stmt_order_from_onefunc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_fill_stmt_order_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  pipeline_block_fill_stmt_order_from_onefunc(a, br, out, count);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_fill_expr_stmts_from_onefunc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_fill_expr_stmts_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  pipeline_block_fill_expr_stmts_from_onefunc(a, br, out, count);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_const_init_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_const_init_ref(a: *u8, br: i32, ci: i32): i32 {
  return pipeline_block_const_init_ref(a, br, ci);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_const_type_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_const_type_ref(a: *u8, br: i32, ci: i32): i32 {
  return pipeline_block_const_type_ref(a, br, ci);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_let_init_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_let_init_ref(a: *u8, br: i32, li: i32): i32 {
  return pipeline_block_let_init_ref(a, br, li);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_let_type_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_let_type_ref(a: *u8, br: i32, li: i32): i32 {
  return pipeline_block_let_type_ref(a, br, li);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_expr_stmt_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_expr_stmt_ref(a: *u8, br: i32, ei: i32): i32 {
  return pipeline_block_expr_stmt_ref(a, br, ei);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_stmt_order_kind.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_stmt_order_kind(a: *u8, br: i32, si: i32): u8 {
  return pipeline_block_stmt_order_kind(a, br, si);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_stmt_order_idx.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_stmt_order_idx(a: *u8, br: i32, si: i32): i32 {
  return pipeline_block_stmt_order_idx(a, br, si);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_if_cond_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_if_cond_ref(a: *u8, br: i32, ii: i32): i32 {
  return pipeline_block_if_cond_ref(a, br, ii);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_if_then_body_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_if_then_body_ref(a: *u8, br: i32, ii: i32): i32 {
  return pipeline_block_if_then_body_ref(a, br, ii);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_if_else_body_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_if_else_body_ref(a: *u8, br: i32, ii: i32): i32 {
  return pipeline_block_if_else_body_ref(a, br, ii);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_const_name_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_const_name_len(a: *u8, br: i32, ci: i32): i32 {
  return pipeline_block_const_name_len(a, br, ci);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_const_name_copy64.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_const_name_copy64(a: *u8, br: i32, ci: i32, dst: *u8): void {
  pipeline_block_const_name_copy64(a, br, ci, dst);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_let_name_len.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_let_name_len(a: *u8, br: i32, li: i32): i32 {
  return pipeline_block_let_name_len(a, br, li);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_let_name_copy64.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_let_name_copy64(a: *u8, br: i32, li: i32, dst: *u8): void {
  pipeline_block_let_name_copy64(a, br, li, dst);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_block_resolve_var_type_ref.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_block_resolve_var_type_ref(a: *u8, block_ref: i32, vname: *u8, vlen: i32): i32 {
  return pipeline_block_resolve_var_type_ref(a, block_ref, vname, vlen);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_module_func_ref_at.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_module_func_ref_at(m: *u8, func_index: i32): i32 {
  return pipeline_module_func_ref_at(m, func_index);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_arena_type_cap.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_arena_type_cap(): i32 {
  return pipeline_arena_type_cap();
}

/**
 * Cap residual rename shim / leave: ast_pipeline_arena_expr_cap.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_arena_expr_cap(): i32 {
  return pipeline_arena_expr_cap();
}

/**
 * Cap residual rename shim / leave: ast_pipeline_arena_block_cap.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_arena_block_cap(): i32 {
  return pipeline_arena_block_cap();
}

/**
 * Cap residual rename shim / leave: ast_pipeline_arena_func_cap.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_arena_func_cap(): i32 {
  return pipeline_arena_func_cap();
}

/**
 * Cap residual rename shim / leave: ast_pipeline_arena_type_alloc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_arena_type_alloc(a: *u8): i32 {
  return pipeline_arena_type_alloc(a);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_arena_expr_alloc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_arena_expr_alloc(a: *u8): i32 {
  return pipeline_arena_expr_alloc(a);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_arena_block_alloc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_arena_block_alloc(a: *u8): i32 {
  return pipeline_arena_block_alloc(a);
}

/**
 * Cap residual rename shim / leave: ast_pipeline_arena_func_alloc.
 * wave322 pure: G.7 authority (was wave283 C thin).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pipeline_arena_func_alloc(a: *u8): i32 {
  return pipeline_arena_func_alloc(a);
}

