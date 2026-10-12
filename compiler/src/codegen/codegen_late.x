// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Rest of codegen. The pin egg's patch table fills up in codegen.x
// before codegen_c_ident_is_keyword. These bodies are the rest.
// Externs use the symbol both compilers emit. A source name that already
// starts with codegen_ is not prefixed again, so the pin egg and the
// product compiler agree. This file does not import codegen.
// PLATFORM: SHARED.
const ast = import("ast");
const codegen_outbuf = import("codegen_outbuf");
import codegen_outbuf;

// These block helpers stay in the pipeline runtime. ast.x no longer defines them.
extern function ast_ast_block_num_lets(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_num_consts(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_final_expr_ref(a: *ASTArena, body_ref: i32): i32;
extern function ast_ast_block_num_expr_stmts(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_expr_stmt_ref(a: *ASTArena, br: i32, ei: i32): i32;
extern function ast_ast_block_num_regions(a: *ASTArena, br: i32): i32;
extern function ast_ast_block_region_body_ref(a: *ASTArena, br: i32, ri: i32): i32;

extern function pipeline_dep_ctx_module_at(ctx: *PipelineDepCtx, idx: i32): *Module;
extern function pipeline_dep_ctx_arena_at(ctx: *PipelineDepCtx, idx: i32): *ASTArena;
extern function pipeline_dep_ctx_ndep(ctx: *PipelineDepCtx): i32;
extern function pipeline_type_named_name_into(arena: *ASTArena, ref: i32, out64: *u8): i32;
extern function pipeline_type_kind_ord_at(arena: *ASTArena, ref: i32): i32;
extern function pipeline_type_elem_ref_at(arena: *ASTArena, ref: i32): i32;
extern function pipeline_type_type_arg_ref_at(arena: *ASTArena, type_ref: i32, idx: i32): i32;
extern function pipeline_module_struct_layout_num_type_params_at(module: *Module, li: i32): i32;
extern function pipeline_typeck_resolve_type_alias_ref_c(arena: *ASTArena, type_ref: i32): i32;
extern function pipeline_codegen_c_file_prologue_done_get(): i32;
extern function pipeline_codegen_c_file_prologue_done_set(v: i32): void;
extern function pipeline_codegen_emit_seed_mega_enabled(): i32;
extern function driver_diagnostic_codegen_emit_func_fail(module: *Module, func_index: i32): void;
extern function driver_dep_arena_buf(i: i32): *u8;
extern function driver_dep_module_buf(i: i32): *u8;
extern function driver_get_current_dep_path_for_codegen(): *u8;
extern function pipeline_expr_kind_ord_at(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_expr_is_c_static_const_init(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_expr_resolved_type_ref(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_expr_as_target_type_ref_at(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_expr_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
extern function pipeline_typeck_type_refs_equal_c(arena: *ASTArena, a: i32, b: i32): i32;
extern function typeck_is_cap_va_builtin_name(name: *u8, name_len: i32): i32;
extern function xlang_skip_trait_method_count_c(trait_nm: *u8, trait_nlen: i32): i32;
extern function xlang_skip_trait_method_name_into_c(trait_nm: *u8, trait_nlen: i32, slot: i32, out64: *u8): i32;
extern function xlang_skip_trait_method_ret_kind_c(trait_nm: *u8, trait_nlen: i32, slot: i32): i32;
extern function xlang_skip_impl_seen_count_c(): i32;
extern function xlang_skip_impl_trait_name_into_c(si: i32, out64: *u8): i32;
extern function xlang_skip_impl_for_type_into_c(si: i32, out_kind: *i32, out_is_ptr: *i32, out_name64: *u8, out_nlen_ptr: *i32): i32;
extern function pipeline_type_find_or_alloc_named(arena: *ASTArena, name: *u8, nlen: i32): i32;
extern function pipeline_type_find_or_alloc_compound(arena: *ASTArena, kind_ord: i32, elem_ref: i32, asz: i32): i32;
extern function pipeline_expr_call_type_arg_ref_at(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
extern function pipeline_expr_call_resolved_dep_index_at(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_expr_call_resolved_func_index_at(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_expr_method_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
extern function pipeline_expr_array_lit_elem_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
extern function pipeline_expr_array_lit_num_elems_at(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_module_top_level_let_is_const(module: *Module, idx: i32): i32;
extern function pipeline_module_top_level_let_name_len(module: *Module, idx: i32): i32;
extern function pipeline_module_top_level_let_name_byte_at(module: *Module, idx: i32, off: i32): u8;
extern function pipeline_module_top_level_let_type_ref(module: *Module, idx: i32): i32;
extern function pipeline_module_top_level_let_init_ref(module: *Module, idx: i32): i32;
extern function pipeline_module_func_name_copy64(module: *Module, fi: i32, dst: *u8): void;
extern function pipeline_module_func_param_name_copy32(module: *Module, fi: i32, pi: i32, dst: *u8): void;
extern function pipeline_module_func_num_params_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_param_name_len_at(module: *Module, fi: i32, pi: i32): i32;
extern function pipeline_module_func_param_type_ref_at(module: *Module, fi: i32, pi: i32): i32;
extern function pipeline_module_func_name_len_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_num_generic_params_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_return_type_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_body_ref_at(module: *Module, fi: i32): i32;
extern function pipeline_dep_ctx_empty_param_reset(ctx: *PipelineDepCtx): void;
extern function pipeline_dep_ctx_empty_param_append(ctx: *PipelineDepCtx, pi: i32): i32;
extern function pipeline_dep_ctx_empty_param_backup(ctx: *PipelineDepCtx): void;
extern function pipeline_dep_ctx_empty_param_restore(ctx: *PipelineDepCtx): void;
extern function pipeline_module_func_body_expr_ref_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_extern_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_used_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_naked_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_entry_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_no_mangle_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_interrupt_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_variadic_at(module: *Module, fi: i32): i32;
extern function pipeline_block_const_name_copy64(arena: *ASTArena, br: i32, ci: i32, dst: *u8): void;
extern function pipeline_block_const_name_len(arena: *ASTArena, br: i32, ci: i32): i32;
extern function pipeline_block_let_name_copy64(arena: *ASTArena, br: i32, li: i32, dst: *u8): void;
extern function pipeline_block_let_name_len(arena: *ASTArena, br: i32, li: i32): i32;
extern function codegen_path_is_std_io_core_bytes(path: *u8): i32;
extern function codegen_import_path_to_c_prefix_into(path: *u8, buf: *u8, buf_cap: i32): void;
extern function codegen_dep_import_path_len_at(ctx: *PipelineDepCtx, idx: i32, dst: *u8): i32;
extern function codegen_module_import_path_len_at(module: *Module, import_idx: i32, dst: *u8): i32;
extern function codegen_find_dep_index_by_path(ctx: *PipelineDepCtx, path: *u8, path_len: i32): i32;
extern function codegen_find_seeded_global_dep_slot_by_path(path: *u8, path_len: i32): i32;
extern function codegen_module_num_imports(module: *Module): i32;
extern function codegen_find_module_func_index_by_name(module: *Module, nm: *u8, nm_len: i32): i32;
extern function codegen_find_module_func_index_by_name_overload(arena: *ASTArena, module: *Module, call_expr_ref: i32, nm: *u8, nm_len: i32): i32;
extern function codegen_name_bytes_prefix_eq(name: *u8, name_len: i32, expect: *u8, exp_len: i32): i32;
extern function codegen_should_skip_later_same_name_body(arena: *ASTArena, module: *Module, fi: i32): i32;
extern function codegen_should_skip_emit_func(dep_path: *u8, prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32;
extern function codegen_force_param_size_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32;
extern function codegen_force_param_size_t_std_io_print_str_second(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32;
extern function codegen_force_param_ptrdiff_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32;
extern function codegen_force_param_uint32_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32;
extern function codegen_try_emit_std_io_driver_buf_body(out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32): i32;
extern function codegen_try_emit_raw_syscall_call(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32;
extern function codegen_try_emit_va_cap_call(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32;
extern function codegen_collect_generic_struct_mono_combos(module: *Module, arena: *ASTArena, layout_k: i32, layout_nm: *u8, layout_nl: i32, ntp: i32, combos_out: *i32, max_combos: i32): i32;
extern function codegen_generic_struct_fill_concrete_args(module: *Module, arena: *ASTArena, type_ref: i32, ntp: i32, mono_out: *i32, ctx: *PipelineDepCtx): i32;
extern function codegen_module_struct_layout_index_by_name(module: *Module, layout_nm: *u8, layout_nl: i32): i32;
extern function codegen_type_refs_same_for_mono(arena: *ASTArena, a: i32, b: i32): i32;
extern function codegen_emit_local_fixed_array_elem_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, ctx: *PipelineDepCtx): i32;
extern function codegen_emit_local_fixed_array_suffix(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32): i32;
extern function pipeline_expr_var_name_into(arena: *ASTArena, expr_ref: i32, out: *u8): void;
extern function pipeline_expr_var_name_len(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_module_func_param_type_ref_for_name(module: *Module, func_index: i32, name: *u8, name_len: i32): i32;
extern function codegen_append_byte(out: *CodegenOutBuf, b: i32): i32;
extern function codegen_emit_bytes_4(out: *CodegenOutBuf, buf: *u8, len: i32): i32;
extern function codegen_emit_bytes_7(out: *CodegenOutBuf, buf: *u8, len: i32): i32;
extern function codegen_emit_bytes_8(out: *CodegenOutBuf, buf: *u8, len: i32): i32;
extern function codegen_emit_bytes_9(out: *CodegenOutBuf, buf: *u8, len: i32): i32;
extern function codegen_emit_bytes_32(out: *CodegenOutBuf, buf: *u8, len: i32): i32;
extern function codegen_emit_bytes_64(out: *CodegenOutBuf, ptr: *u8, len: i32): i32;
extern function codegen_emit_bytes_from_ptr(out: *CodegenOutBuf, ptr: *u8, len: i32): i32;
extern function codegen_emit_bytes_3(out: *CodegenOutBuf, buf: *u8, len: i32): i32;
extern function codegen_c_prefix_redundant_with_name(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32;
extern function codegen_emit_expr(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32;
extern function codegen_emit_bytes_2(out: *CodegenOutBuf, buf: *u8, len: i32): i32;
extern function format_uint(out: *CodegenOutBuf, val: i32): i32;
extern function format_int(out: *CodegenOutBuf, val: i64): i32;
extern function codegen_emit_indent(out: *CodegenOutBuf, indent: i32): i32;
extern function codegen_emit_type_kind(out: *CodegenOutBuf, kind_ord: i32): i32;
extern function codegen_emit_dyn_host_c_fn_ptr_suffix(out: *CodegenOutBuf, arena: *ASTArena, ctx: *PipelineDepCtx, expr_ref: i32, base_ref: i32, slot: i32, nargs: i32): i32;
extern function emit_vector_c_type_out(out: *CodegenOutBuf, elem_kind_ord: i32, lanes: i32): i32;
extern function type_to_c_repr(arena: *ASTArena, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
extern function codegen_emit_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32;
extern function codegen_emit_c_ptr_to_fixed_array_decl(arena: *ASTArena, out: *CodegenOutBuf, ptr_type_ref: i32, name: *u8, name_len: i32, ctx: *PipelineDepCtx): i32;
extern function type_uses_named_array_decl(arena: *ASTArena, type_ref: i32): i32;
extern function codegen_emit_c_fnptr_decl(arena: *ASTArena, out: *CodegenOutBuf, fn_ty: i32, name: *u8, name_len: i32, array_ty: i32, ctx: *PipelineDepCtx): i32;
extern function try_emit_slice_init_from_array_var(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, let_idx: i32, let_type_ref: i32, linit_ref: i32, ctx: *PipelineDepCtx): i32;
extern function try_emit_dest_slice_from_module_array_var( arena: *ASTArena, out: *CodegenOutBuf, dest_type_ref: i32, linit_ref: i32, ctx: *PipelineDepCtx ): i32;
extern function codegen_emit_braced_array_lit_init(arena: *ASTArena, out: *CodegenOutBuf, init_ref: i32, ctx: *PipelineDepCtx): i32;
extern function codegen_build_func_param_mono_map(module: *Module, arena: *ASTArena, fi: i32, gen_refs: *i32, conc_refs: *i32, max_entries: i32): i32;
extern function codegen_emit_scalar_slice_nests(out: *CodegenOutBuf, min_nest: i32, max_nest: i32): i32;
extern function codegen_emit_vector_typedefs(out: *CodegenOutBuf): i32;
extern function codegen_array_lit_tree_is_const(arena: *ASTArena, expr_ref: i32): i32;
extern function codegen_emit_file_scope_dest_slice_array_lit( arena: *ASTArena, out: *CodegenOutBuf, dest_ty: i32, lit_ref: i32, ctx: *PipelineDepCtx ): i32;
extern function codegen_emit_slice_of_fixed_array_layouts(arena: *ASTArena, out: *CodegenOutBuf, ctx: *PipelineDepCtx): i32;
extern function codegen_emit_module_struct_definitions(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32;
extern function codegen_emit_module_enum_definitions(module: *Module, out: *CodegenOutBuf, enum_prefix: *u8, enum_prefix_len: i32): i32;
extern function codegen_emit_skipped_dep_type_definitions(ctx: *PipelineDepCtx, out: *CodegenOutBuf): i32;
extern function codegen_emit_dep_struct_forward_declarations(ctx: *PipelineDepCtx, out: *CodegenOutBuf): i32;
extern function codegen_emit_block(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, indent: i32, ctx: *PipelineDepCtx): i32;
extern function codegen_type_ref_to_suffix(arena: *ASTArena, type_ref: i32, buf: *u8, buf_cap: i32): i32;
extern function codegen_module_func_overload_count(module: *Module, name_ptr: *u8, name_len: i32): i32;
extern function codegen_module_overload_param_sig_count(arena: *ASTArena, module: *Module, fi: i32): i32;
extern function codegen_func_c_symbol_prefix_len(module: *Module, fi: i32, prefix_len: i32): i32;

/**
 * True when bare source identifier is a C keyword / type-specifier.
 * Purpose: host-C cannot emit `int32_t double(int32_t)` (type-specifier collision).
 * Parameters: name/name_len — exact bare function name bytes (not module-prefixed).
 * Returns: 1 = keyword (must escape), 0 = safe bare C identifier.
 * Coverage: C11 type-specifiers + common statement keywords that break as function names.
 * PLATFORM: SHARED — host-C backend; used only by codegen_emit_c_func_base_name.
 */
function codegen_c_ident_is_keyword(name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (name == 0 as *u8 || name_len <= 0) {
      return 0;
    }
    /* len 2: do, if */
    if (name_len == 2) {
      if (name[0] == 100 && name[1] == 111) { return 1; }
      if (name[0] == 105 && name[1] == 102) { return 1; }
      return 0;
    }
    /* len 3: for, int */
    if (name_len == 3) {
      if (name[0] == 102 && name[1] == 111 && name[2] == 114) { return 1; }
      if (name[0] == 105 && name[1] == 110 && name[2] == 116) { return 1; }
      return 0;
    }
    /* len 4: case, char, else, enum, goto, long, void */
    if (name_len == 4) {
      if (name[0] == 99 && name[1] == 97 && name[2] == 115 && name[3] == 101) { return 1; }
      if (name[0] == 99 && name[1] == 104 && name[2] == 97 && name[3] == 114) { return 1; }
      if (name[0] == 101 && name[1] == 108 && name[2] == 115 && name[3] == 101) { return 1; }
      if (name[0] == 101 && name[1] == 110 && name[2] == 117 && name[3] == 109) { return 1; }
      if (name[0] == 103 && name[1] == 111 && name[2] == 116 && name[3] == 111) { return 1; }
      if (name[0] == 108 && name[1] == 111 && name[2] == 110 && name[3] == 103) { return 1; }
      if (name[0] == 118 && name[1] == 111 && name[2] == 105 && name[3] == 100) { return 1; }
      return 0;
    }
    /* len 5: break, const, float, short, union, while */
    if (name_len == 5) {
      if (name[0] == 98 && name[1] == 114 && name[2] == 101 && name[3] == 97 && name[4] == 107) { return 1; }
      if (name[0] == 99 && name[1] == 111 && name[2] == 110 && name[3] == 115 && name[4] == 116) { return 1; }
      if (name[0] == 102 && name[1] == 108 && name[2] == 111 && name[3] == 97 && name[4] == 116) { return 1; }
      if (name[0] == 115 && name[1] == 104 && name[2] == 111 && name[3] == 114 && name[4] == 116) { return 1; }
      if (name[0] == 117 && name[1] == 110 && name[2] == 105 && name[3] == 111 && name[4] == 110) { return 1; }
      if (name[0] == 119 && name[1] == 104 && name[2] == 105 && name[3] == 108 && name[4] == 101) { return 1; }
      return 0;
    }
    /* len 6: double, extern, return, signed, sizeof, static, struct, switch */
    if (name_len == 6) {
      if (name[0] == 100 && name[1] == 111 && name[2] == 117 && name[3] == 98 && name[4] == 108 && name[5] == 101) { return 1; }
      if (name[0] == 101 && name[1] == 120 && name[2] == 116 && name[3] == 101 && name[4] == 114 && name[5] == 110) { return 1; }
      if (name[0] == 114 && name[1] == 101 && name[2] == 116 && name[3] == 117 && name[4] == 114 && name[5] == 110) { return 1; }
      if (name[0] == 115 && name[1] == 105 && name[2] == 103 && name[3] == 110 && name[4] == 101 && name[5] == 100) { return 1; }
      if (name[0] == 115 && name[1] == 105 && name[2] == 122 && name[3] == 101 && name[4] == 111 && name[5] == 102) { return 1; }
      if (name[0] == 115 && name[1] == 116 && name[2] == 97 && name[3] == 116 && name[4] == 105 && name[5] == 99) { return 1; }
      if (name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 117 && name[4] == 99 && name[5] == 116) { return 1; }
      if (name[0] == 115 && name[1] == 119 && name[2] == 105 && name[3] == 116 && name[4] == 99 && name[5] == 104) { return 1; }
      return 0;
    }
    /* len 7: default, typedef */
    if (name_len == 7) {
      if (name[0] == 100 && name[1] == 101 && name[2] == 102 && name[3] == 97 && name[4] == 117 && name[5] == 108 && name[6] == 116) { return 1; }
      if (name[0] == 116 && name[1] == 121 && name[2] == 112 && name[3] == 101 && name[4] == 100 && name[5] == 101 && name[6] == 102) { return 1; }
      return 0;
    }
    /* len 8: continue, register, restrict, unsigned, volatile */
    if (name_len == 8) {
      if (name[0] == 99 && name[1] == 111 && name[2] == 110 && name[3] == 116 && name[4] == 105 && name[5] == 110 && name[6] == 117 && name[7] == 101) { return 1; }
      if (name[0] == 114 && name[1] == 101 && name[2] == 103 && name[3] == 105 && name[4] == 115 && name[5] == 116 && name[6] == 101 && name[7] == 114) { return 1; }
      if (name[0] == 114 && name[1] == 101 && name[2] == 115 && name[3] == 116 && name[4] == 114 && name[5] == 105 && name[6] == 99 && name[7] == 116) { return 1; }
      if (name[0] == 117 && name[1] == 110 && name[2] == 115 && name[3] == 105 && name[4] == 103 && name[5] == 110 && name[6] == 101 && name[7] == 100) { return 1; }
      if (name[0] == 118 && name[1] == 111 && name[2] == 108 && name[3] == 97 && name[4] == 116 && name[5] == 105 && name[6] == 108 && name[7] == 101) { return 1; }
      return 0;
    }
    return 0;
  }
}

/**
 * Emit host-C function base identifier (optional keyword escape).
 * Purpose: single path for bare stem used by def / call / extern / mono base.
 * When name is a C keyword, prefix "xlang_" so `int32_t double(...)` becomes
 * `int32_t xlang_double(...)` (trait Double.double / similar).
 * Parameters: out — C text sink; name/name_len — bare source name.
 * Returns: 0 on success, -1 on emit error.
 * PLATFORM: SHARED — host-C only authority for keyword-safe stems.
 */
function codegen_emit_c_func_base_name(out: *CodegenOutBuf, name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (out == 0 as *CodegenOutBuf || name == 0 as *u8 || name_len <= 0) {
      return -1;
    }
    if (codegen_c_ident_is_keyword(name, name_len) != 0) {
      /* "xlang_" */
      let pfx: u8[7] = [120, 108, 97, 110, 103, 95, 0];
      if (codegen_emit_bytes_from_ptr(out, &pfx[0], 6) != 0) {
        return -1;
      }
    }
    return codegen_emit_bytes_64(out, name, name_len);
  }
}

/**
 * Emit the C link symbol for function fi: bare name, or mangled name_t1_t2 when overloaded.
 * Aligns with seed pin / historical codegen.c func_link_name. #[no_mangle] always bare
 * stem (still keyword-escaped via codegen_emit_c_func_base_name).
 *
 * Why zero-init + assign (not let x = f(name)): product pin X→C hoists all `let` inits
 * to the top of the block. `let overload_count = count(fn_local, …)` ran before
 * codegen_copy_func_name64, so overload_count was always 0/1 and extern decls collided
 * (hello: core_fmt_fmt_scalar_to_buf / std_io_print unmangled).
 * Why keyword escape: trait/impl hoist free fns named like C type-specifiers
 * (e.g. double) → BLD001 "two or more data types" without escape; def/call/extern
 * share this helper so symbols stay consistent.
 * PLATFORM: SHARED — definition / extern decl / CALL must all call this helper.
 */
export function codegen_emit_func_link_name(out: *CodegenOutBuf, arena: *ASTArena, module: *Module, fi: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* Hoist-safe: zero locals first; fill via statements after the early-return gate. */
    let fn_local: u8[256] = [];
    let fn_len: i32 = 0;
    let overload_count: i32 = 0;
    let np: i32 = 0;
    let pi: i32 = 0;
    let sig_count: i32 = 0;
    if (module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
      return -1;
    }
    fn_len = pipeline_module_func_name_len_at(module, fi);
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    if (fn_len <= 0) {
      return -1;
    }
    /* See implementation. */
    if (pipeline_module_func_is_no_mangle_at(module, fi) != 0) {
      return codegen_emit_c_func_base_name(out, &fn_local[0], fn_len);
    }
    /* Count overloads only after name is copied (let-hoist safe). */
    overload_count = codegen_module_func_overload_count(module, &fn_local[0], fn_len);
    if (overload_count <= 1) {
      return codegen_emit_c_func_base_name(out, &fn_local[0], fn_len);
    }
    /* See implementation. */
    if (codegen_emit_c_func_base_name(out, &fn_local[0], fn_len) != 0) {
      return -1;
    }
    np = pipeline_module_func_num_params_at(module, fi);
    pi = 0;
    while (pi < np) {
      let suf: u8[256] = [];
      let param_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, pi);
      /*
       * PLATFORM: SHARED — param type_ref is indexed in the function's module arena.
       * Callers must pass that arena; if null/wrong, suffix is empty → bare free
       * (Ubuntu multi-import heap.free). Prefer non-null arena; never silent bare mangle.
       */
      let sl: i32 = 0;
      if (arena != 0 as *ASTArena) {
        sl = codegen_type_ref_to_suffix(arena, param_ty, &suf[0], 64);
      }
      if (sl > 0) {
        if (codegen_append_byte(out, 95) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_from_ptr(out, &suf[0], sl) != 0) {
          return -1;
        }
      }
      pi = pi + 1;
    }
    /* See implementation. */
    sig_count = codegen_module_overload_param_sig_count(arena, module, fi);
    if (sig_count > 1) {
      let ret_ref: i32 = pipeline_module_func_return_type_at(module, fi);
      let rs: u8[256] = [];
      let rsl: i32 = codegen_type_ref_to_suffix(arena, ret_ref, &rs[0], 64);
      if (rsl > 0) {
        /* "_ret_" */
        let ret_kw: u8[5] = [95, 114, 101, 116, 0];
        if (codegen_emit_bytes_from_ptr(out, &ret_kw[0], 4) != 0) {
          return -1;
        }
        if (codegen_emit_bytes_from_ptr(out, &rs[0], rsl) != 0) {
          return -1;
        }
      }
    }
    return 0;
  }
}

/**
 * True when `name` is a local binding that must stay bare in C (param / let / const).
 * Used so EXPR_VAR fn-as-value only mangles real function values, not locals that
 * happen to share a name with a module function.
 * @param arena *ASTArena — active emit arena (block let/const pool)
 * @param ctx *PipelineDepCtx — current_func_index + current_block_ref + module
 * @param name *u8 — identifier bytes
 * @param name_len i32 — byte length; <=0 → not local
 * @return i32 — 1 if param/let/const matches; 0 otherwise
 * PLATFORM: SHARED — scope scan for emit; not a second typeck.
 */
export function codegen_name_is_local_binding(arena: *ASTArena, ctx: *PipelineDepCtx, name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx || name == 0 as *u8 || name_len <= 0) {
      return 0;
    }
    let mod: *Module = ctx.current_codegen_module;
    // Current function params shadow free functions for bare identifiers.
    if (mod != 0 as *Module && ctx.current_func_index >= 0 && ctx.current_func_index < mod.num_funcs) {
      let fi: i32 = ctx.current_func_index;
      let np: i32 = pipeline_module_func_num_params_at(mod, fi);
      let pi: i32 = 0;
      while (pi < np) {
        let pl: i32 = pipeline_module_func_param_name_len_at(mod, fi, pi);
        if (pl == name_len && pl > 0) {
          let pb: u8[256] = [];
          let ok: i32 = 1;
          let j: i32 = 0;
          pipeline_module_func_param_name_copy32(mod, fi, pi, &pb[0]);
          while (j < pl) {
            if (pb[j] != name[j]) {
              ok = 0;
              j = pl;
            } else {
              j = j + 1;
            }
          }
          if (ok != 0) {
            return 1;
          }
        }
        pi = pi + 1;
      }
    }
    // Current block lets / consts (shallow: emit uses current_block_ref).
    if (ctx.current_block_ref > 0 && ctx.current_block_ref <= arena.num_blocks) {
      let br: i32 = ctx.current_block_ref;
      let li: i32 = 0;
      let nlets: i32 = ast_ast_block_num_lets(arena, br);
      while (li < nlets) {
        let nl: i32 = pipeline_block_let_name_len(arena, br, li);
        if (nl == name_len && nl > 0) {
          let nb: u8[256] = [];
          let ok2: i32 = 1;
          let j2: i32 = 0;
          pipeline_block_let_name_copy64(arena, br, li, &nb[0]);
          while (j2 < nl) {
            if (nb[j2] != name[j2]) {
              ok2 = 0;
              j2 = nl;
            } else {
              j2 = j2 + 1;
            }
          }
          if (ok2 != 0) {
            return 1;
          }
        }
        li = li + 1;
      }
      let ci: i32 = 0;
      let nconsts: i32 = ast_ast_block_num_consts(arena, br);
      while (ci < nconsts) {
        let cl: i32 = pipeline_block_const_name_len(arena, br, ci);
        if (cl == name_len && cl > 0) {
          let cb: u8[256] = [];
          let ok3: i32 = 1;
          let j3: i32 = 0;
          pipeline_block_const_name_copy64(arena, br, ci, &cb[0]);
          while (j3 < cl) {
            if (cb[j3] != name[j3]) {
              ok3 = 0;
              j3 = cl;
            } else {
              j3 = j3 + 1;
            }
          }
          if (ok3 != 0) {
            return 1;
          }
        }
        ci = ci + 1;
      }
    }
    return 0;
  }
}

/**
 * Emit C symbol for EXPR_VAR that names a same-module function value (fn-as-value).
 * G.7 single path: same module prefix + codegen_emit_func_link_name as def/call/extern.
 * wave101 soft residual: non-#[no_mangle] `(f as *u8)` must not emit bare source name
 * (def is prefix_f / overload-mangled → undeclared C identifier).
 * @param out *CodegenOutBuf — C text sink
 * @param arena *ASTArena — module arena for overload suffixes
 * @param ctx *PipelineDepCtx — current_codegen_module + prefix mirror
 * @param name *u8 — bare source identifier
 * @param name_len i32 — length
 * @return i32 — 0 emitted function link; 1 not a free function (caller emits bare);
 *               -1 emit error
 * PLATFORM: SHARED — link-name contract; verify mac + Ubuntu.
 */
export function codegen_try_emit_fn_as_value(out: *CodegenOutBuf, arena: *ASTArena, ctx: *PipelineDepCtx, name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (out == 0 as *CodegenOutBuf || name == 0 as *u8 || name_len <= 0) {
      return 1;
    }
    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
      return 1;
    }
    if (codegen_name_is_local_binding(arena, ctx, name, name_len) != 0) {
      return 1;
    }
    let mod: *Module = ctx.current_codegen_module;
    let fi: i32 = codegen_find_module_func_index_by_name(mod, name, name_len);
    if (fi < 0) {
      return 1;
    }
    // Same-module value: emit arena is the function module arena (no forward dep on
    // codegen_arena_for_module — defined later in this TU).
    // Module C prefix (entry stem / import path) unless #[no_mangle].
    let pre_len: i32 = ctx.current_codegen_prefix_len;
    let sym_pre: i32 = codegen_func_c_symbol_prefix_len(mod, fi, pre_len);
    if (sym_pre > 0) {
      if (codegen_c_prefix_redundant_with_name(&ctx.current_codegen_prefix_mirror[0], sym_pre, name, name_len) == 0) {
        if (codegen_emit_bytes_from_ptr(out, &ctx.current_codegen_prefix_mirror[0], sym_pre) != 0) {
          return 0 - 1;
        }
      }
    }
    if (codegen_emit_func_link_name(out, arena, mod, fi) != 0) {
      return 0 - 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_arena_for_module(ctx: *PipelineDepCtx, module: *Module, fallback: *ASTArena): *ASTArena {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || module == 0 as *Module) {
      return fallback;
    }
    let di: i32 = 0;
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    while (di < nd) {
      if (pipeline_dep_ctx_module_at(ctx, di) == module) {
        let da: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di);
        if (da != 0 as *ASTArena) {
          return da;
        }
        return fallback;
      }
      di = di + 1;
    }
    return fallback;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_emit_call_func_name(out: *CodegenOutBuf, arena: *ASTArena, ctx: *PipelineDepCtx, expr_ref: i32, current_module: *Module, fallback_name: *u8, fallback_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx != 0 as *PipelineDepCtx && arena != 0 as *ASTArena) {
      let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
      let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
      let call_e0: Expr = ast.ast_arena_expr_get(arena, expr_ref);
      let is_m0: i32 = 0;
      if ((call_e0.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32)) {
        is_m0 = 1;
      }
      let nargs0: i32 = 0;
      if (is_m0 != 0) {
        nargs0 = call_e0.method_call_num_args;
      } else {
        nargs0 = call_e0.call_num_args;
      }
      /* See implementation. */
      if (func_ix >= 0) {
        let res_mod: *Module = 0 as *Module;
        /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
        let ndep_res: i32 = pipeline_dep_ctx_ndep(ctx);
        if (dep_ix >= 0 && dep_ix < ndep_res) {
          res_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
        } else {
          res_mod = current_module;
        }
        if (res_mod != 0 as *Module && func_ix < res_mod.num_funcs) {
          let ok_res: i32 = 1;
          if (pipeline_module_func_num_params_at(res_mod, func_ix) != nargs0) {
            ok_res = 0;
          }
          if (ok_res != 0 && fallback_len > 0) {
            let rlen: i32 = pipeline_module_func_name_len_at(res_mod, func_ix);
            if (rlen != fallback_len) {
              ok_res = 0;
            } else {
              let rnm: u8[256] = [];
              pipeline_module_func_name_copy64(res_mod, func_ix, &rnm[0]);
              let ri: i32 = 0;
              while (ri < rlen) {
                if (rnm[ri] != fallback_name[ri]) {
                  ok_res = 0;
                  ri = rlen;
                } else {
                  ri = ri + 1;
                }
              }
            }
          }
          /*
           * PLATFORM: SHARED — trust typeck call_resolved_func_index for overloads.
           * Typeck already scores args + expected return (let v: Vec_u8 = new() →
           * new_retVec_u8). Rejecting all overloads here forced re-search that lost
           * the return-type pick and emitted bare std_vec_new() while defs used _ret_.
           * Keep arity/name checks above; only cross-module resolved still rejected below.
           */
          /*
           * PLATFORM: SHARED — when METHOD_CALL fallback passes binding current_module,
           * reject call_resolved that points at a different dep module (e.g. heap.free →
           * libc free after multi-import index confusion). Prefer re-search in binding.
           */
          if (ok_res != 0 && current_module != 0 as *Module && res_mod != current_module) {
            ok_res = 0;
          }
          if (ok_res != 0) {
            let res_arena: *ASTArena = codegen_arena_for_module(ctx, res_mod, arena);
            /* wave444: for generic functions, emit mono-mangled symbol matching the
             * instance emitted by codegen_try_emit_generic_identity_mono. The mangled
             * name is built from the call site's arg types (via codegen_call_mono_
             * type_at, the same extraction used on the emit side) so emit-side combo
             * and consume-side symbol always agree. Non-generic functions keep the
             * bare link name. If type extraction fails (incomplete call site), fall
             * back to the bare link name to preserve prior behavior.
             * wave458: also append uncovered ret type-param concrete (as_t/mk multi). */
            if (pipeline_module_func_num_generic_params_at(res_mod, func_ix) > 0) {
              let np_mono: i32 = pipeline_module_func_num_params_at(res_mod, func_ix);
              let re_mono: i32 = codegen_func_ret_type_param_extra(res_arena, res_mod, func_ix);
              let cw_mono: i32 = np_mono + re_mono;
              if (cw_mono > 0 && cw_mono <= 8) {
                let call_e_mono: Expr = ast.ast_arena_expr_get(arena, expr_ref);
                let nargs_mono: i32 = call_e_mono.call_num_args;
                let mono_tys: i32[8] = [];
                let pi_mono: i32 = 0;
                let valid_mono: i32 = 1;
                while (pi_mono < np_mono) {
                  let ty_mono: i32 = codegen_call_mono_type_at(arena, expr_ref, pi_mono, nargs_mono);
                  if (ty_mono <= 0) {
                    valid_mono = 0;
                    pi_mono = np_mono;
                  } else {
                    mono_tys[pi_mono] = ty_mono;
                  }
                  pi_mono = pi_mono + 1;
                }
                if (valid_mono != 0 && re_mono != 0) {
                  let rty_mono: i32 = codegen_call_ret_type_param_concrete_at(arena, expr_ref);
                  if (rty_mono <= 0) {
                    valid_mono = 0;
                  } else {
                    mono_tys[np_mono] = rty_mono;
                  }
                }
                if (valid_mono != 0) {
                  return codegen_emit_mono_mangled_name(out, arena, res_mod, func_ix, &mono_tys[0], cw_mono);
                }
              }
            }
            return codegen_emit_func_link_name(out, res_arena, res_mod, func_ix);
          }
        }
        func_ix = -1;
      }
      /*
       * Target module for re-search: prefer binding current_module when provided.
       * PLATFORM: SHARED — call_resolved dep_ix may point at a transitive dep after
       * multi-import closure (heap.free → libc free); binding module is the authority.
       */
      let search_mod: *Module = 0 as *Module;
      let search_arena: *ASTArena = arena;
      if (current_module != 0 as *Module) {
        search_mod = current_module;
        search_arena = codegen_arena_for_module(ctx, search_mod, arena);
      } else {
        /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
        let ndep_search: i32 = pipeline_dep_ctx_ndep(ctx);
        if (dep_ix >= 0 && dep_ix < ndep_search) {
          search_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
          search_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
          if (search_arena == 0 as *ASTArena) {
            search_arena = arena;
          }
        } else {
          search_mod = current_module;
          search_arena = codegen_arena_for_module(ctx, search_mod, arena);
        }
      }
      if (search_mod != 0 as *Module && fallback_len > 0) {
        let call_e: Expr = call_e0;
        let is_method: i32 = is_m0;
        let call_nargs: i32 = nargs0;
        let found_fi: i32 = -1;
        let found_count: i32 = 0;
        let fi_s: i32 = 0;
        while (fi_s < search_mod.num_funcs) {
          let fn_len: i32 = pipeline_module_func_name_len_at(search_mod, fi_s);
          if (fn_len == fallback_len && fn_len > 0) {
            let fn_name: u8[256] = [];
            pipeline_module_func_name_copy64(search_mod, fi_s, &fn_name[0]);
            let matched: i32 = 1;
            let bi: i32 = 0;
            while (bi < fn_len) {
              if (fn_name[bi] != fallback_name[bi]) {
                matched = 0;
                bi = fn_len;
              } else {
                bi = bi + 1;
              }
            }
            if (matched != 0) {
              let np: i32 = pipeline_module_func_num_params_at(search_mod, fi_s);
              if (np == call_nargs) {
                let types_match: i32 = 1;
                let pi: i32 = 0;
                while (pi < np && types_match != 0) {
                  let arg_ref: i32 = 0;
                  if (is_method != 0) {
                    arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, pi);
                  } else {
                    arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, pi);
                  }
                  if (ast.ref_is_null(arg_ref)) {
                    types_match = 0;
                  } else {
                    let arg_ty: i32 = pipeline_expr_resolved_type_ref(arena, arg_ref);
                    /*
                     * PLATFORM: SHARED — dep module bodies are not typeck'd, so param VAR
                     * args have resolved_type=0. When the arg is a VAR that names a param of
                     * the CURRENTLY emitted function, use that param's declared type as arg_ty.
                     * Without this, dot(a:Vec4f) { hsum(mul(a,b)); } emits Vec8i mul (first
                     * arity match) instead of Vec4f mul → cc "conflicting types".
                     */
                    if (arg_ty <= 0 && ctx != 0 as *PipelineDepCtx
                        && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0
                        && pipeline_expr_kind_ord_at(arena, arg_ref) == 3) {
                      let av_len: i32 = pipeline_expr_var_name_len(arena, arg_ref);
                      if (av_len > 0 && av_len <= 63) {
                        let av_buf: u8[256] = [];
                        pipeline_expr_var_name_into(arena, arg_ref, &av_buf[0]);
                        let apt: i32 = pipeline_module_func_param_type_ref_for_name(
                            ctx.current_codegen_module, ctx.current_func_index, &av_buf[0], av_len);
                        if (apt > 0) {
                          arg_ty = apt;
                        }
                      }
                    }
                    /* See implementation. */
                    if (arg_ty <= 0 && pipeline_expr_kind_ord_at(arena, arg_ref) == 54) {
                      let as_tgt: i32 = pipeline_expr_as_target_type_ref_at(arena, arg_ref);
                      if (as_tgt > 0) {
                        arg_ty = as_tgt;
                      }
                    }
                    /* See implementation. */
                    let is_str_lit: i32 = 0;
                    if (arg_ty <= 0 && pipeline_expr_kind_ord_at(arena, arg_ref) == 59) {
                      is_str_lit = 1;
                    }
                    let param_ty: i32 = pipeline_module_func_param_type_ref_at(search_mod, fi_s, pi);
                    let sa: u8[256] = [];
                    let sb: u8[256] = [];
                    let na: i32 = 0;
                    let nb: i32 = 0;
                    /* See implementation. */
                    if (is_str_lit == 0 && arg_ty > 0
                        && pipeline_type_kind_ord_at(arena, arg_ty) == 10
                        && pipeline_type_kind_ord_at(search_arena, param_ty) == 9) {
                      let ae: i32 = pipeline_type_elem_ref_at(arena, arg_ty);
                      let pe: i32 = pipeline_type_elem_ref_at(search_arena, param_ty);
                      na = codegen_type_ref_to_suffix(arena, ae, &sa[0], 64);
                      nb = codegen_type_ref_to_suffix(search_arena, pe, &sb[0], 64);
                    } else if (is_str_lit != 0) {
                      sa[0] = 117;
                      sa[1] = 56;
                      sa[2] = 95;
                      sa[3] = 112;
                      sa[4] = 116;
                      sa[5] = 114;
                      na = 6;
                      nb = codegen_type_ref_to_suffix(search_arena, param_ty, &sb[0], 64);
                    } else {
                      na = codegen_type_ref_to_suffix(arena, arg_ty, &sa[0], 64);
                      nb = codegen_type_ref_to_suffix(search_arena, param_ty, &sb[0], 64);
                    }
                    if (na != nb) {
                      types_match = 0;
                    } else {
                      if (na <= 0) {
                        types_match = 0;
                      } else {
                        let k: i32 = 0;
                        while (k < na) {
                          if (sa[k] != sb[k]) {
                            types_match = 0;
                            k = na;
                          } else {
                            k = k + 1;
                          }
                        }
                      }
                    }
                  }
                  pi = pi + 1;
                }
                if (types_match != 0) {
                  found_fi = fi_s;
                  found_count = found_count + 1;
                }
              }
            }
          }
          fi_s = fi_s + 1;
        }
        if (found_count == 1 && found_fi >= 0) {
          if (is_method != 0) {
            let recv_ty_fb: i32 = 0;
            let call_e_fb: Expr = call_e0;
            if (!ast.ref_is_null(call_e_fb.method_call_base_ref)) {
              recv_ty_fb = pipeline_expr_resolved_type_ref(arena, call_e_fb.method_call_base_ref);
            }
            if (recv_ty_fb > 0) {
              let fb_mono_rc: i32 = codegen_try_emit_impl_method_mono_call_name(out, search_arena, ctx, search_mod, found_fi, recv_ty_fb);
              if (fb_mono_rc < 0) {
                return -1;
              }
              if (fb_mono_rc == 1) {
                return 0;
              }
            }
          }
          return codegen_emit_func_link_name(out, search_arena, search_mod, found_fi);
        }
        /*
         * PLATFORM: SHARED — PTR overload (heap.free *u8 vs *i32): suffix compare can
         * fail across arenas; fall back to kind+elem kind match so we never emit bare free.
         */
        if (found_count != 1 && call_nargs == 1 && is_method != 0 && search_mod != 0 as *Module) {
          let arg0: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
          let arg0_ty: i32 = 0;
          if (arg0 > 0) {
            arg0_ty = pipeline_expr_resolved_type_ref(arena, arg0);
          }
          if (arg0_ty > 0 && pipeline_type_kind_ord_at(arena, arg0_ty) == 9) {
            let ae_k: i32 = 0;
            let ae: i32 = pipeline_type_elem_ref_at(arena, arg0_ty);
            if (ae > 0) {
              ae_k = pipeline_type_kind_ord_at(arena, ae);
            }
            let fi_p: i32 = 0;
            let best_p: i32 = -1;
            let n_p: i32 = 0;
            while (fi_p < search_mod.num_funcs) {
              let fl: i32 = pipeline_module_func_name_len_at(search_mod, fi_p);
              if (fl == fallback_len && fl > 0 && pipeline_module_func_num_params_at(search_mod, fi_p) == 1) {
                let fnm_p: u8[256] = [];
                pipeline_module_func_name_copy64(search_mod, fi_p, &fnm_p[0]);
                let me: i32 = 1;
                let bi: i32 = 0;
                while (bi < fl) {
                  if (fnm_p[bi] != fallback_name[bi]) {
                    me = 0;
                    bi = fl;
                  } else {
                    bi = bi + 1;
                  }
                }
                if (me != 0) {
                  let pt: i32 = pipeline_module_func_param_type_ref_at(search_mod, fi_p, 0);
                  if (pt > 0 && pipeline_type_kind_ord_at(search_arena, pt) == 9) {
                    let pe: i32 = pipeline_type_elem_ref_at(search_arena, pt);
                    if (pe > 0 && pipeline_type_kind_ord_at(search_arena, pe) == ae_k) {
                      best_p = fi_p;
                      n_p = n_p + 1;
                    }
                  }
                }
              }
              fi_p = fi_p + 1;
            }
            if (n_p == 1 && best_p >= 0) {
              let recv_ty_p: i32 = 0;
              let call_e_p: Expr = call_e0;
              if (!ast.ref_is_null(call_e_p.method_call_base_ref)) {
                recv_ty_p = pipeline_expr_resolved_type_ref(arena, call_e_p.method_call_base_ref);
              }
              if (recv_ty_p > 0) {
                let p_mono_rc: i32 = codegen_try_emit_impl_method_mono_call_name(out, search_arena, ctx, search_mod, best_p, recv_ty_p);
                if (p_mono_rc < 0) {
                  return -1;
                }
                if (p_mono_rc == 1) {
                  return 0;
                }
              }
              return codegen_emit_func_link_name(out, search_arena, search_mod, best_p);
            }
          }
        }
        /* See implementation. */
        if (found_count != 1 && call_nargs >= 0) {
          let arity_fi: i32 = -1;
          let arity_count: i32 = 0;
          let ext_fi: i32 = -1;
          let ext_count: i32 = 0;
          let fi_a: i32 = 0;
          while (fi_a < search_mod.num_funcs) {
            let fn_len_a: i32 = pipeline_module_func_name_len_at(search_mod, fi_a);
            if (fn_len_a == fallback_len && fn_len_a > 0) {
              let fn_name_a: u8[256] = [];
              pipeline_module_func_name_copy64(search_mod, fi_a, &fn_name_a[0]);
              let matched_a: i32 = 1;
              let bi_a: i32 = 0;
              while (bi_a < fn_len_a) {
                if (fn_name_a[bi_a] != fallback_name[bi_a]) {
                  matched_a = 0;
                  bi_a = fn_len_a;
                } else {
                  bi_a = bi_a + 1;
                }
              }
              if (matched_a != 0) {
                let np_a: i32 = pipeline_module_func_num_params_at(search_mod, fi_a);
                if (np_a == call_nargs) {
                  arity_fi = fi_a;
                  arity_count = arity_count + 1;
                  if (pipeline_module_func_is_extern_at(search_mod, fi_a) != 0 || pipeline_module_func_is_no_mangle_at(search_mod, fi_a) != 0) {
                    ext_fi = fi_a;
                    ext_count = ext_count + 1;
                  }
                }
              }
            }
            fi_a = fi_a + 1;
          }
          if (ext_count == 1 && ext_fi >= 0) {
            return codegen_emit_func_link_name(out, search_arena, search_mod, ext_fi);
          }
          if (arity_count == 1 && arity_fi >= 0) {
            return codegen_emit_func_link_name(out, search_arena, search_mod, arity_fi);
          }
        }
      }
    }
    /* See implementation. */
    if (ctx != 0 as *PipelineDepCtx && fallback_len > 0 && arena != 0 as *ASTArena) {
      let mc_e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
      let mc_nargs: i32 = 0;
      if ((mc_e.kind as i32) == (ExprKind.EXPR_METHOD_CALL as i32)) {
        mc_nargs = mc_e.method_call_num_args;
      } else {
        mc_nargs = mc_e.call_num_args;
      }
      let dep_di: i32 = 0;
      let nd: i32 = pipeline_dep_ctx_ndep(ctx);
      while (dep_di < nd) {
        let dm: *Module = pipeline_dep_ctx_module_at(ctx, dep_di);
        let da: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dep_di);
        if (dm != 0 as *Module && da != 0 as *ASTArena) {
          let fi_x: i32 = 0;
          let found_x: i32 = -1;
          while (fi_x < dm.num_funcs) {
            let fn_x: i32 = pipeline_module_func_name_len_at(dm, fi_x);
            if (fn_x == fallback_len && fn_x > 0) {
              let fnm: u8[256] = [];
              pipeline_module_func_name_copy64(dm, fi_x, &fnm[0]);
              let mx: i32 = 1;
              let bx: i32 = 0;
              while (bx < fn_x) {
                if (fnm[bx] != fallback_name[bx]) {
                  mx = 0;
                  bx = fn_x;
                } else {
                  bx = bx + 1;
                }
              }
              if (mx != 0 && pipeline_module_func_num_params_at(dm, fi_x) == mc_nargs) {
                found_x = fi_x;
                fi_x = dm.num_funcs;
              } else {
                fi_x = fi_x + 1;
              }
            } else {
              fi_x = fi_x + 1;
            }
          }
          if (found_x >= 0) {
            return codegen_emit_func_link_name(out, da, dm, found_x);
          }
        }
        dep_di = dep_di + 1;
      }
    }
    /* See implementation. */
    return codegen_emit_bytes_from_ptr(out, fallback_name, fallback_len);
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_copy_func_name64_from_module(module: *Module, fi: i32, dst: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    pipeline_module_func_name_copy64(module, fi, dst);
  }
}

/**
 * See implementation.
 */
export function codegen_copy_param_name32_from_module(module: *Module, fi: i32, pi: i32, dst: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    pipeline_module_func_param_name_copy32(module, fi, pi, dst);
  }
}

/**
 * Emit one function: return type + name + (params) + { body }.
 * When call_init_globals != 0 and is_entry main, body starts with init_globals();
 *
 * Why name_is_main is assigned after copy (not `let x = name_eq`): pin X→C hoists
 * all let inits to block top, so `let name_is_main = (fn_local[0]=='m'…)` ran on a
 * still-zero buffer → never emitted C `main` (rv matrix: undefined _main).
 * PLATFORM: SHARED — entry main symbol contract.
 */
/**
 * True if this block (or nested region bodies, e.g. Cap-T001 `unsafe { return … }`)
 * contains a return statement or a final expression (treated as the function return path).
 *
 * Purpose: emit_func fallback `return 0` must not fire when the only return lives inside
 * an unsafe/region body — otherwise by-value struct functions get illegal `return 0`.
 * Parameters: arena + block_ref (1-based pool ref); null/invalid → 0.
 * Returns: 1 if a return path is present, 0 otherwise.
 * PLATFORM: SHARED — C TU ordering / host-cc; seed pin same commit.
 */
export function codegen_block_contains_return(arena: *ASTArena, block_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || ast.ref_is_null(block_ref)) {
      return 0;
    }
    /* final_expr on the block is the implicit return path for expression-bodied blocks. */
    if (!ast.ref_is_null(ast_ast_block_final_expr_ref(arena, block_ref))) {
      return 1;
    }
    let ji: i32 = 0;
    let nes: i32 = ast_ast_block_num_expr_stmts(arena, block_ref);
    while (ji < nes) {
      let se: Expr = ast.ast_arena_expr_get(arena, ast_ast_block_expr_stmt_ref(arena, block_ref, ji));
      if ((se.kind as i32) == (ExprKind.EXPR_RETURN as i32)) {
        return 1;
      }
      ji = ji + 1;
    }
    /* Cap-T001: return often sits only inside unsafe / region body blocks. */
    let ri: i32 = 0;
    let nr: i32 = ast_ast_block_num_regions(arena, block_ref);
    while (ri < nr) {
      let rb: i32 = ast_ast_block_region_body_ref(arena, block_ref, ri);
      if (codegen_block_contains_return(arena, rb) != 0) {
        return 1;
      }
      ri = ri + 1;
    }
    return 0;
  }
}

/** Exported function `emit_func`.
 * Implements `emit_func`.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param module *Module
 * @param fi i32
 * @param is_entry bool
 * @param prefix *u8
 * @param prefix_len i32
 * @param ctx *PipelineDepCtx
 * @param call_init_globals i32
 * @return i32
 */
export function emit_func(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, is_entry: bool, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx, call_init_globals: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* Hoist-safe name locals: fill via statements before any name-dependent test. */
    let fn_local: u8[256] = [];
    let fn_len: i32 = 0;
    let name_is_main: bool = false;
    let force_entry_main: bool = false;
    let emit_c_main_symbol: bool = false;
    let main_name: u8[4] = [109, 97, 105, 110];
    /* See implementation. */
    if (fi < 0 || fi >= module.num_funcs) {
      return -1;
    }
    fn_len = pipeline_module_func_name_len_at(module, fi);
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    /* See implementation. */
    if (pipeline_module_func_is_used_at(module, fi) != 0) {
      let used_attr: u8[27] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 115, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0];
      if (codegen_emit_bytes_from_ptr(out, &used_attr[0], 22) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_naked_at(module, fi) != 0) {
      let naked_attr: u8[29] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 97, 107, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0, 0];
      if (codegen_emit_bytes_from_ptr(out, &naked_attr[0], 23) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_entry_at(module, fi) != 0) {
      let entry_attr: u8[30] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 111, 114, 101, 116, 117, 114, 110, 41, 41, 32, 0, 0, 0, 0];
      if (codegen_emit_bytes_from_ptr(out, &entry_attr[0], 26) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_interrupt_at(module, fi) != 0) {
      let int_attr: u8[31] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 105, 110, 116, 101, 114, 114, 117, 112, 116, 41, 41, 32, 0, 0, 0, 0];
      if (codegen_emit_bytes_from_ptr(out, &int_attr[0], 27) != 0) { return -1; }
    }
    /*
     * Emit C symbol "main" only when the function name is the four bytes main.
     * Assign name_is_main after copy (let-hoist safe) — see function docblock.
     * Single-function entry with empty name still forces main (bootstrap path).
     * Do not write (is_entry && a) || b — X→C may drop parens.
     * Must compute emit_c_main_symbol before return-type emit: void main becomes
     * C int32_t main (Zig-like implicit exit 0), not host `void main`.
     */
    if (fn_len == 4 && fn_local[0] == 109 && fn_local[1] == 97 && fn_local[2] == 105 && fn_local[3] == 110) {
      name_is_main = true;
    }
    if (is_entry && module.num_funcs == 1) {
      if (fn_len <= 0) {
        force_entry_main = true;
      }
      if (fn_local[0] == 0) {
        force_entry_main = true;
      }
    }
    if (is_entry) {
      if (name_is_main) {
        emit_c_main_symbol = true;
      }
    }
    if (force_entry_main) {
      emit_c_main_symbol = true;
    }
    /* PLATFORM: SHARED — process entry ABI: void main → int32_t main + exit 0. */
    let ret_ty_ref: i32 = pipeline_module_func_return_type_at(module, fi);
    /*
     * wave495: generic inherent impl method definition codegen monomorphization.
     * Why: hoisted impl methods (num_generic_params == 0, <T> on impl not fn)
     * bypass codegen_try_emit_generic_identity_mono and are emitted here. Their
     * return type T would emit as `struct T` (incomplete BLD001) because
     * mono_active is off; the self param Wrap<T> is rescued by the wave489
     * unique-combo suffix mechanism but the free return type T is not. Build a
     * T→concrete map from the self param's unique mono combo, set mono_active so
     * codegen_emit_type's name-based fallback substitutes T in ret type + body. Mirrors
     * codegen_try_emit_generic_identity_mono save/restore (L16145-L16152).
     * PLATFORM: SHARED — seed codegen_gen.linux.x86_64.c same commit.
     * Guards: only set when w495_n > 0 (unique combo found); non-generic functions
     * and multi-combo cases skip this entirely (no behavior change). Restore on
     * BOTH success return paths (std-io early return + final); error paths abort.
     */
    let w495_mono_set: i32 = 0;
    let w495_saved_active: i32 = 0;
    let w495_saved_num: i32 = 0;
    if (ctx != 0 as *PipelineDepCtx) {
      let w495_gen: i32[8] = [];
      let w495_conc: i32[8] = [];
      let w495_n: i32 = codegen_build_func_param_mono_map(module, arena, fi, &w495_gen[0], &w495_conc[0], 8);
      if (w495_n > 0) {
        w495_saved_active = ctx.mono_active;
        w495_saved_num = ctx.mono_num_types;
        let w495_k: i32 = 0;
        while (w495_k < w495_n && w495_k < 8) {
          ctx.mono_generic_type_refs[w495_k] = w495_gen[w495_k];
          ctx.mono_concrete_type_refs[w495_k] = w495_conc[w495_k];
          w495_k = w495_k + 1;
        }
        ctx.mono_active = 1;
        ctx.mono_num_types = w495_n;
        w495_mono_set = 1;
      }
    }
    let fn_ret_void_pre: bool = pipeline_type_kind_ord_at(arena, ret_ty_ref) == (TypeKind.TYPE_VOID as i32);
    if (emit_c_main_symbol && fn_ret_void_pre) {
      let i32_ty: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
      if (codegen_emit_bytes_8(out, &i32_ty[0], 7) != 0) {
        return -1;
      }
    } else if (codegen_emit_type(arena, out, ret_ty_ref, prefix, prefix_len, ctx) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 32) != 0) {
      return -1;
    }
    if (emit_c_main_symbol) {
      if (codegen_emit_bytes_4(out, &main_name[0], 4) != 0) {
        return -1;
      }
    } else {
      /* See implementation. */
      let sym_pre: i32 = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
      if (sym_pre > 0 && codegen_c_prefix_redundant_with_name(prefix, sym_pre, &fn_local[0], fn_len) == 0 && codegen_emit_bytes_from_ptr(out, prefix, sym_pre) != 0) {
        return -1;
      }
      /* See implementation. */
      if (codegen_emit_func_link_name(out, arena, module, fi) != 0) {
        return -1;
      }
      if (codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, &fn_local[0], fn_len) != 0) {
        let impl_suffix: u8[6] = [95, 105, 109, 112, 108, 0];
        if (codegen_emit_bytes_from_ptr(out, &impl_suffix[0], 5) != 0) {
          return -1;
        }
      }
    }
    let lpar: u8[2] = [40, 0];
    if (codegen_emit_bytes_2(out, &lpar[0], 1) != 0) {
      return -1;
    }
    /* PLATFORM: WINDOWS — the count is a local before the compare.
     * Oct 6 saves the index with push/pop across
     * pipeline_module_func_num_params_at. The callee homes rcx over that
     * push, so the index becomes the module pointer and a negative low
     * half keeps the loop running until the emit buffer fills. */
    let nparams_emit: i32 = pipeline_module_func_num_params_at(module, fi);
    if (nparams_emit == 0) {
      let v: u8[7] = [118, 111, 105, 100, 0, 0, 0];
      if (codegen_emit_bytes_7(out, &v[0], 4) != 0) {
        return -1;
      }
    } else {
      let p: i32 = 0;
      while (p < nparams_emit) {
        if (p > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
        }
        /* See implementation. */
        if (codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let size_t_ps: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (codegen_emit_bytes_32(out, &size_t_ps[0], 7) != 0) {
            return -1;
          }
        } else if (codegen_force_param_size_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let size_t_buf: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (codegen_emit_bytes_32(out, &size_t_buf[0], 7) != 0) {
            return -1;
          }
        } else if (codegen_force_param_ptrdiff_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let ptrdiff_t_buf: u8[32] = [112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (codegen_emit_bytes_32(out, &ptrdiff_t_buf[0], 10) != 0) {
            return -1;
          }
        } else if (codegen_force_param_uint32_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let u32_buf: u8[32] = [117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (codegen_emit_bytes_32(out, &u32_buf[0], 9) != 0) {
            return -1;
          }
        } else if (codegen_force_param_i32(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let i32_str: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
          if (codegen_emit_bytes_8(out, &i32_str[0], 7) != 0) {
            return -1;
          }
        } else if (type_uses_named_array_decl(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) != 0) {
          /*
           * wave636: param `p: *[N]T` → `E (*p)[N]` (name inside C declarator).
           * dest-SLICE INDEX return: `[K][N]T` param is the same form
           * (`int32_t (*a)[2]`), not codegen_emit_type peel `int32_t ** a`.
           * PLATFORM: SHARED host-C.
           */
          let pta_nm: u8[256] = [];
          let pta_nl: i32 = 0;
          if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {
            codegen_copy_param_name32_from_module(module, fi, p, &pta_nm[0]);
            pta_nl = pipeline_module_func_param_name_len_at(module, fi, p);
            if (pta_nm[0] <= 32) {
              pta_nl = 0;
            }
          }
          if (pta_nl <= 0) {
            /* Synthetic `_pN` when param name missing. */
            pta_nm[0] = 95;
            pta_nm[1] = 112;
            pta_nl = 2;
            let v_p: i32 = p;
            let digs_p: u8[12] = [];
            let nd_p: i32 = 0;
            if (v_p == 0) {
              digs_p[0] = 48;
              nd_p = 1;
            } else {
              let tmp_p: i32 = v_p;
              while (tmp_p > 0 && nd_p < 12) {
                digs_p[nd_p] = ((tmp_p % 10) + 48) as u8;
                tmp_p = tmp_p / 10;
                nd_p = nd_p + 1;
              }
              let a_p: i32 = 0;
              let b_p: i32 = nd_p - 1;
              while (a_p < b_p) {
                let sw_p: u8 = digs_p[a_p];
                digs_p[a_p] = digs_p[b_p];
                digs_p[b_p] = sw_p;
                a_p = a_p + 1;
                b_p = b_p - 1;
              }
            }
            let pi_p: i32 = 0;
            while (pi_p < nd_p && pta_nl < 128) {
              pta_nm[pta_nl] = digs_p[pi_p];
              pta_nl = pta_nl + 1;
              pi_p = pi_p + 1;
            }
          }
          if (codegen_emit_c_ptr_to_fixed_array_decl(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), &pta_nm[0], pta_nl, ctx) != 0) {
            return -1;
          }
        } else if (pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p))
            == (TypeKind.TYPE_FN as i32)) {
          /* 10.3.1: param `f: function(T): R` → `R (*f)(T)`. PLATFORM: SHARED. */
          let pfn_nm: u8[256] = [];
          let pfn_nl: i32 = 0;
          if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {
            codegen_copy_param_name32_from_module(module, fi, p, &pfn_nm[0]);
            pfn_nl = pipeline_module_func_param_name_len_at(module, fi, p);
            if (pfn_nm[0] <= 32) {
              pfn_nl = 0;
            }
          }
          if (pfn_nl <= 0) {
            pfn_nm[0] = 95;
            pfn_nm[1] = 112;
            pfn_nl = 2;
            if (p < 10) {
              pfn_nm[2] = ((p + 48) as u8);
              pfn_nl = 3;
            } else {
              pfn_nm[2] = ((p / 10) + 48) as u8;
              pfn_nm[3] = ((p % 10) + 48) as u8;
              pfn_nl = 4;
            }
          }
          if (codegen_emit_c_fnptr_decl(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p),
              &pfn_nm[0], pfn_nl, 0, ctx) != 0) {
            return -1;
          }
        } else if (codegen_emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) != 0) {
          return -1;
        }
        /* PLATFORM: SHARED — lower TYPE_SLICE params as pointers (seed/glue ABI).
         * Why: Cap by-value slice + pointer glue → SIGSEGV (string bytes as ptr).
         * Emit: `struct xlang_slice_T * name` so field access uses -> and calls pass &local. */
        if (type_uses_named_array_decl(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) == 0
            && pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) != (TypeKind.TYPE_FN as i32)
            && pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) == (TypeKind.TYPE_SLICE as i32)) {
          if (codegen_append_byte(out, 32) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 42) != 0) {
            return -1;
          }
        }
        /* wave636 / 10.3.1: named-array / TYPE_FN already emitted name — skip space+name. */
        if (type_uses_named_array_decl(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) == 0
            && pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) != (TypeKind.TYPE_FN as i32)) {
          if (codegen_append_byte(out, 32) != 0) {
            return -1;
          }
          if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {
            let plocal: u8[256] = [];
            codegen_copy_param_name32_from_module(module, fi, p, &plocal[0]);
            if (plocal[0] > 32 && codegen_emit_bytes_from_ptr(out, &plocal[0], pipeline_module_func_param_name_len_at(module, fi, p)) != 0) {
              return -1;
            }
          } else {
            let place: u8[4] = [95, 112, 48, 0];
            if (codegen_emit_bytes_4(out, &place[0], 2) != 0) {
              return -1;
            }
            if (format_int(out, p) != 0) {
              return -1;
            }
          }
        }
        p = p + 1;
      }
    }
    /*
     * Cap 10.7.1 slice6: emit `, ...` on function *definitions* when is_variadic.
     * Declarations already emit via codegen_emit_import_dep / extern proto path;
     * defs closed `)` without ellipsis → prototype/def mismatch (host-cc error).
     * PLATFORM: SHARED host-C.
     */
    if (pipeline_module_func_is_variadic_at(module, fi) != 0 && pipeline_module_func_num_params_at(module, fi) > 0) {
      let ellipsis_def: u8[5] = [44, 32, 46, 46, 46];
      if (codegen_emit_bytes_from_ptr(out, &ellipsis_def[0], 5) != 0) {
        return -1;
      }
    }
    let rpar: u8[3] = [41, 32, 0];
    if (codegen_emit_bytes_3(out, &rpar[0], 2) != 0) {
      return -1;
    }
    let brace: u8[3] = [123, 10, 0];
    if (codegen_emit_bytes_3(out, &brace[0], 2) != 0) {
      return -1;
    }
    /* See implementation. */
    if (codegen_try_emit_std_io_driver_buf_body(out, module, fi, prefix, prefix_len) != 0) {
      /* wave495: restore mono_active on early success return (std-io path). */
      if (w495_mono_set != 0) {
        ctx.mono_active = w495_saved_active;
        ctx.mono_num_types = w495_saved_num;
      }
      return 0;
    }
    /* See implementation. */
    let fn_ret_void: bool = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi)) == (TypeKind.TYPE_VOID as i32);
    /* See implementation. */
    if (call_init_globals != 0) {
      if (is_entry) {
        if (emit_c_main_symbol) {
          if (codegen_emit_indent(out, 2) != 0) {
            return -1;
          }
          let init_globals_call: u8[22] = [105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 41, 59, 10, 0, 0, 0, 0, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &init_globals_call[0], 16) != 0) {
            return -1;
          }
        }
      }
    }
    /* See implementation. */
    let saved_empty: i32 = -1;
    let saved_count: i32 = 0;
    let saved_next: i32 = 0;
    if (ctx != 0 as *PipelineDepCtx) {
      pipeline_dep_ctx_empty_param_backup(ctx);
      saved_empty = ctx.current_func_single_empty_param_index;
      saved_count = ctx.current_func_empty_param_count;
      saved_next = ctx.current_emit_empty_var_next_index;
      let empty_count: i32 = 0;
      let empty_idx: i32 = -1;
      let pi: i32 = 0;
      /* PLATFORM: WINDOWS — one local for both scans below. The index must
         not stay live across pipeline_module_func_num_params_at. */
      let nparams_empty: i32 = pipeline_module_func_num_params_at(module, fi);
      while (pi < nparams_empty) {
        if (pipeline_module_func_param_name_len_at(module, fi, pi) <= 0) {
          empty_count = empty_count + 1;
          empty_idx = pi;
        }
        pi = pi + 1;
      }
      if (empty_count == 1) {
        ctx.current_func_single_empty_param_index = empty_idx;
        ctx.current_func_empty_param_count = 0;
        ctx.current_emit_empty_var_next_index = 0;
      } else if (empty_count >= 2) {
        ctx.current_func_single_empty_param_index = -1;
        pipeline_dep_ctx_empty_param_reset(ctx);
        ctx.current_func_empty_param_count = empty_count;
        let ei: i32 = 0;
        pi = 0;
        while (pi < nparams_empty) {
          if (pipeline_module_func_param_name_len_at(module, fi, pi) <= 0) {
            pipeline_dep_ctx_empty_param_append(ctx, pi);
            ei = ei + 1;
          }
          pi = pi + 1;
        }
        ctx.current_emit_empty_var_next_index = 0;
      } else {
        ctx.current_func_single_empty_param_index = -1;
        ctx.current_func_empty_param_count = 0;
        ctx.current_emit_empty_var_next_index = 0;
      }
    }
    if (!ast.ref_is_null(pipeline_module_func_body_ref_at(module, fi))) {
      let saved_block: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx) {
        saved_block = ctx.current_block_ref;
        ctx.current_block_ref = pipeline_module_func_body_ref_at(module, fi);
      }
      if (codegen_emit_block(arena, out, pipeline_module_func_body_ref_at(module, fi), 2, ctx) != 0) {
        if (ctx != 0 as *PipelineDepCtx) {
          ctx.current_block_ref = saved_block;
        }
        return -1;
      }
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.current_block_ref = saved_block;
      }
    } else if (!ast.ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi))) {
      /* See implementation. */
      if (fn_ret_void) {
        if (codegen_emit_indent(out, 2) != 0) {
          return -1;
        }
        if (codegen_emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 59) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 10) != 0) {
          return -1;
        }
      } else {
        if (codegen_emit_indent(out, 2) != 0) {
          return -1;
        }
        let ret_keyword: u8[9] = [114, 101, 116, 117, 114, 110, 32, 0, 0];
        if (codegen_emit_bytes_9(out, &ret_keyword[0], 7) != 0) {
          return -1;
        }
        /* See implementation. */
        let body_e: Expr = ast.ast_arena_expr_get(arena, pipeline_module_func_body_expr_ref_at(module, fi));
        if ((body_e.kind as i32) == (ExprKind.EXPR_RETURN as i32)) {
          if (!ast.ref_is_null(body_e.unary_operand_ref) && codegen_emit_expr(arena, out, body_e.unary_operand_ref, ctx) != 0) {
            return -1;
          }
        } else {
          if (codegen_emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) != 0) {
            return -1;
          }
        }
        if (codegen_append_byte(out, 59) != 0) {
          return -1;
        }
        if (codegen_append_byte(out, 10) != 0) {
          return -1;
        }
      }
    }
    if (ctx != 0 as *PipelineDepCtx) {
      ctx.current_func_single_empty_param_index = saved_empty;
      ctx.current_func_empty_param_count = saved_count;
      ctx.current_emit_empty_var_next_index = saved_next;
      pipeline_dep_ctx_empty_param_restore(ctx);
    }
    /*
     * Fallback `return 0;` — default OFF when a body block was emitted.
     * Why (parser M1 host-cc): Cap-T001 `unsafe { return glue(...); }` nests return in a
     * region; old top-level-only scan still appended `return 0` → illegal for by-value
     * struct (Lexer / OneFuncResult). Scalar fallback only if no return path found.
     * PLATFORM: SHARED — seed pin same commit; verify parser.x host-cc + product matrix.
     * Authority: codegen_block_contains_return + integer/pointer kind gate.
     */
    let need_fallback_return: bool = false;
    if (fn_ret_void) {
      /* PLATFORM: SHARED — void main (C process entry): fall off body → exit 0. */
      if (emit_c_main_symbol) {
        if (!ast.ref_is_null(pipeline_module_func_body_ref_at(module, fi))) {
          if (codegen_block_contains_return(arena, pipeline_module_func_body_ref_at(module, fi)) == 0) {
            need_fallback_return = true;
          }
        } else {
          need_fallback_return = true;
        }
      } else {
        need_fallback_return = false;
      }
    } else if (!ast.ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi))) {
      need_fallback_return = false;
    } else if (!ast.ref_is_null(pipeline_module_func_body_ref_at(module, fi))) {
      let body_br: i32 = pipeline_module_func_body_ref_at(module, fi);
      if (codegen_block_contains_return(arena, body_br) == 0) {
        let ret_ord: i32 = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi));
        /* Integer-like 0..7 and TYPE_PTR only. */
        if ((ret_ord >= 0 && ret_ord <= 7) || ret_ord == (TypeKind.TYPE_PTR as i32)) {
          need_fallback_return = true;
        }
      }
    } else {
      let ret_ord2: i32 = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi));
      if ((ret_ord2 >= 0 && ret_ord2 <= 7) || ret_ord2 == (TypeKind.TYPE_PTR as i32)) {
        need_fallback_return = true;
      }
    }
    if (need_fallback_return) {
      if (codegen_emit_indent(out, 2) != 0) {
        return -1;
      }
      let ret0: u8[9] = [114, 101, 116, 117, 114, 110, 32, 48, 59];
      if (codegen_emit_bytes_9(out, &ret0[0], 9) != 0) {
        return -1;
      }
      if (codegen_append_byte(out, 10) != 0) {
        return -1;
      }
    }
    let close: u8[3] = [125, 10, 0];
    if (codegen_emit_bytes_3(out, &close[0], 2) != 0) {
      return -1;
    }
    /* wave495: restore mono_active on final success return. */
    if (w495_mono_set != 0) {
      ctx.mono_active = w495_saved_active;
      ctx.mono_num_types = w495_saved_num;
    }
    return 0;
  }
}

/**
 * Return 1 if `name` is a libc symbol that must NOT be re-declared by
 * `emit_func_extern_declaration`.
 *
 * Why: XLANG maps `*u8` → `uint8_t *` (and integers → `int32_t`), while system
 * headers use `char *` / `void *` / `int` / `size_t`. Re-emitting those externs
 * conflicts with `#include <stdlib.h>` / `<string.h>` / unistd (g05 historically
 * sed-deleted the bad redecls). Authority for "skip emit" is this single
 * predicate; seed must stay in sync.
 *
 * Covered (historical g05 sed + read/write + wave30 mkstemp/rename): libc I/O,
 * alloc (incl. realloc / posix_memalign), string, env, path (unlink/mkstemp/
 * rename/access), sendfile. g05 sed remains a defense layer for harness helpers
 * and #include strip; libc name authority is this predicate only (G.7).
 * PLATFORM: SHARED — product C prologue MUST include stdlib.h + string.h +
 * unistd.h (`codegen_x_ast_emit_header` for bare `-E`, plus rt_preamble
 * io_net for `-o`). Skipping without those headers → implicit int /
 * undeclared getcwd (L0 labi_path_pure.x host-cc).
 * sendfile leftover: LINUX 4-arg prototype via fs_formal `<sys/sendfile.h>`;
 * MACOS 6-arg already in `<sys/socket.h>` (Darwin net Cap).
 * Cap 10.7.1: also skip language va_* faces (typeck_is_cap_va_builtin_name) —
 * call sites rewrite to xlang_va_*; emitting `extern void va_start(...)`
 * redeclares the clang builtin (Darwin host-cc hard-error).
 */
export function codegen_is_libc_conflicting_extern_name(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  /* Cap 10.7.1: va_start/va_end/va_copy/va_arg* are macros, not C functions.
   * PLATFORM: SHARED — LANG-007 S0: this export extern call must sit in unsafe. */
  let va_hit: i32 = 0;
  unsafe {
    va_hit = typeck_is_cap_va_builtin_name(name, name_len);
  }
  if (va_hit != 0) {
    return 1;
  }
  /* read 4 */
  if (name_len == 4 && name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 100) {
    return 1;
  }
  /* write 5 */
  if (name_len == 5 && name[0] == 119 && name[1] == 114 && name[2] == 105 && name[3] == 116 && name[4] == 101) {
    return 1;
  }
  /* open 4 */
  if (name_len == 4 && name[0] == 111 && name[1] == 112 && name[2] == 101 && name[3] == 110) {
    return 1;
  }
  /* close 5 */
  if (name_len == 5 && name[0] == 99 && name[1] == 108 && name[2] == 111 && name[3] == 115 && name[4] == 101) {
    return 1;
  }
  /* fcntl 5 */
  if (name_len == 5 && name[0] == 102 && name[1] == 99 && name[2] == 110 && name[3] == 116 && name[4] == 108) {
    return 1;
  }
  /* free 4 */
  if (name_len == 4 && name[0] == 102 && name[1] == 114 && name[2] == 101 && name[3] == 101) {
    return 1;
  }
  /* malloc 6 */
  if (name_len == 6 && name[0] == 109 && name[1] == 97 && name[2] == 108 && name[3] == 108 && name[4] == 111 && name[5] == 99) {
    return 1;
  }
  /* calloc 6 */
  if (name_len == 6 && name[0] == 99 && name[1] == 97 && name[2] == 108 && name[3] == 108 && name[4] == 111 && name[5] == 99) {
    return 1;
  }
  /* realloc 7 — void* vs uint8_t* clash with stdlib.h */
  if (name_len == 7 && name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 108 && name[4] == 108 && name[5] == 111 && name[6] == 99) {
    return 1;
  }
  /* posix_memalign 14 — stdlib/POSIX prototype; skip XLANG redecl */
  if (name_len == 14 && name[0] == 112 && name[1] == 111 && name[2] == 115 && name[3] == 105 && name[4] == 120 && name[5] == 95 && name[6] == 109 && name[7] == 101 && name[8] == 109 && name[9] == 97 && name[10] == 108 && name[11] == 105 && name[12] == 103 && name[13] == 110) {
    return 1;
  }
  /* strtoul 7 — *u8 vs char* / u32 vs unsigned long (std/test) */
  if (name_len == 7 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 116 && name[4] == 111 && name[5] == 117 && name[6] == 108) {
    return 1;
  }
  /* strtol 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 116 && name[4] == 111 && name[5] == 108) {
    return 1;
  }
  /* strtoull 8 */
  if (name_len == 8 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 116 && name[4] == 111 && name[5] == 117 && name[6] == 108 && name[7] == 108) {
    return 1;
  }
  /* strtoll 7 */
  if (name_len == 7 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 116 && name[4] == 111 && name[5] == 108 && name[6] == 108) {
    return 1;
  }
  /* memcpy 6 */
  if (name_len == 6 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 99 && name[4] == 112 && name[5] == 121) {
    return 1;
  }
  /* memcmp 6 */
  if (name_len == 6 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 99 && name[4] == 109 && name[5] == 112) {
    return 1;
  }
  /* memset 6 */
  if (name_len == 6 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 115 && name[4] == 101 && name[5] == 116) {
    return 1;
  }
  /* memchr 6 — glibc string.h may macro to _Generic; *u8 clash */
  if (name_len == 6 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 99 && name[4] == 104 && name[5] == 114) {
    return 1;
  }
  /* memrchr 7 */
  if (name_len == 7 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 114 && name[4] == 99 && name[5] == 104 && name[6] == 114) {
    return 1;
  }
  /* memmem 6 */
  if (name_len == 6 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 109 && name[4] == 101 && name[5] == 109) {
    return 1;
  }
  /* strchr 6 — string.h macro / char* clash (std/path) */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 99 && name[4] == 104 && name[5] == 114) {
    return 1;
  }
  /* strrchr 7 */
  if (name_len == 7 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 114 && name[4] == 99 && name[5] == 104 && name[6] == 114) {
    return 1;
  }
  /* strcpy 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 99 && name[4] == 112 && name[5] == 121) {
    return 1;
  }
  /* strncpy 7 */
  if (name_len == 7 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 110 && name[4] == 99 && name[5] == 112 && name[6] == 121) {
    return 1;
  }
  /* getenv 6 — *u8 → uint8_t* conflicts with char *getenv(const char *) */
  if (name_len == 6 && name[0] == 103 && name[1] == 101 && name[2] == 116 && name[3] == 101 && name[4] == 110 && name[5] == 118) {
    return 1;
  }
  /* getcwd 6 */
  if (name_len == 6 && name[0] == 103 && name[1] == 101 && name[2] == 116 && name[3] == 99 && name[4] == 119 && name[5] == 100) {
    return 1;
  }
  /* unlink 6 */
  if (name_len == 6 && name[0] == 117 && name[1] == 110 && name[2] == 108 && name[3] == 105 && name[4] == 110 && name[5] == 107) {
    return 1;
  }
  /* strlen 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 108 && name[4] == 101 && name[5] == 110) {
    return 1;
  }
  /* strcmp 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 99 && name[4] == 109 && name[5] == 112) {
    return 1;
  }
  /* strncmp 7 */
  if (name_len == 7 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 110 && name[4] == 99 && name[5] == 109 && name[6] == 112) {
    return 1;
  }
  /* strstr 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 115 && name[4] == 116 && name[5] == 114) {
    return 1;
  }
  /* setenv 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 101 && name[2] == 116 && name[3] == 101 && name[4] == 110 && name[5] == 118) {
    return 1;
  }
  /* system 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 121 && name[2] == 115 && name[3] == 116 && name[4] == 101 && name[5] == 109) {
    return 1;
  }
  /* fputs 5 */
  if (name_len == 5 && name[0] == 102 && name[1] == 112 && name[2] == 117 && name[3] == 116 && name[4] == 115) {
    return 1;
  }
  /* strerror 8 */
  if (name_len == 8 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 101 && name[4] == 114 && name[5] == 114 && name[6] == 111 && name[7] == 114) {
    return 1;
  }
  /* opendir/closedir/readdir: DO NOT skip — std.fs models DIR* as *u8 opaque;
   * system dirent.h DIR* prototypes are incompatible (return/arg type). Emit
   * XLANG extern uint8_t *opendir(...) instead of including dirent.h.
   * PLATFORM: POSIX opaque DIR. */
  /* access 6 */
  if (name_len == 6 && name[0] == 97 && name[1] == 99 && name[2] == 99 && name[3] == 101 && name[4] == 115 && name[5] == 115) {
    return 1;
  }
  /* mkstemp 7 — i32 vs int; *u8 path vs char* (runtime_driver_abi_thin.x).
   * wave30: was g05-sed-only dual-auth; product -E must skip redecl at source. */
  if (name_len == 7 && name[0] == 109 && name[1] == 107 && name[2] == 115 && name[3] == 116 && name[4] == 101 && name[5] == 109 && name[6] == 112) {
    return 1;
  }
  /* rename 6 — i32 vs int; *u8 paths vs char* (open_out close-before-rename). */
  if (name_len == 6 && name[0] == 114 && name[1] == 101 && name[2] == 110 && name[3] == 97 && name[4] == 109 && name[5] == 101) {
    return 1;
  }
  /* sendfile 8 — Darwin <sys/socket.h> 6-arg (off_t *, struct sf_hdtr *) vs
   * XLANG extern i64* / u8* -> "conflicting types for 'sendfile'" in fs_formal
   * KEEP_C, so std/fs/fs.o never lands and product -o UNDEF _std_fs_invalid.
   * Linux 4-arg leftover (fs_libc_sendfile) keeps a prototype via fs_formal
   * #include <sys/sendfile.h>. Darwin 6-arg FFI is unused (fs_libc_sendfile_mac
   * returns -1 without calling sendfile).
   * PLATFORM: SHARED skip; LINUX header in fs_formal; MACOS via socket.h. */
  if (name_len == 8 && name[0] == 115 && name[1] == 101 && name[2] == 110 && name[3] == 100 && name[4] == 102 && name[5] == 105 && name[6] == 108 && name[7] == 101) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_find_mono_type_for_generic_func(arena: *ASTArena, module: *Module, fi: i32, arg_idx: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (arena == 0 as *ASTArena || module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    let fn_local: u8[256] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    if (fn_len <= 0) {
      return 0;
    }
    let ei: i32 = 1;
    while (ei <= arena.num_exprs) {
      let e: Expr = ast.ast_arena_expr_get(arena, ei);
      if ((e.kind as i32) == (ExprKind.EXPR_CALL as i32)) {
        let matched: i32 = 0;
        if (e.call_resolved_func_index == fi) {
          matched = 1;
        } else if (!ast.ref_is_null(e.call_callee_ref) && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs) {
          let cal: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
          if ((cal.kind as i32) == (ExprKind.EXPR_VAR as i32) && cal.var_name_len == fn_len) {
            let eq: i32 = 1;
            let k: i32 = 0;
            while (k < fn_len) {
              if (cal.var_name[k] != fn_local[k]) {
                eq = 0;
                k = fn_len;
              } else {
                k = k + 1;
              }
            }
            matched = eq;
          }
        }
        if (matched != 0) {
          let ty: i32 = 0;
          /* wave443: resolved_type_ref is the call's return type; only valid for
           * param0 (identity shape: ret == param0). For arg_idx>0, must use the
           * specific arg's type to get that param's mono type. */
          if (arg_idx == 0) {
            ty = e.resolved_type_ref;
          }
          if (ty <= 0 && arg_idx >= 0 && arg_idx < e.call_num_args) {
            let a0: i32 = pipeline_expr_call_arg_ref(arena, ei, arg_idx);
            if (a0 > 0) {
              ty = pipeline_expr_resolved_type_ref(arena, a0);
            }
          }
          if (ty > 0) {
            return ty;
          }
        }
      }
      ei = ei + 1;
    }
    return 0;
  }
}

/**
 * Extract the concrete mono type for call site `ei`'s param at `arg_idx`.
 *
 * Why: for identity-shape generics (ret == param0), the call's resolved return
 * type (`e.resolved_type_ref`) is the authoritative mono type for param0 — it is
 * set by typeck and avoids relying on the arg expr having a resolved type. For
 * arg_idx > 0, the arg's own resolved type is used (the call return type only
 * describes param0 by identity shape).
 *
 * Invariant: arg_idx must be < num_args; returns 0 if the type cannot be resolved.
 * PLATFORM: SHARED — single extraction authority shared by mono-combo collector
 * (codegen_collect_mono_combos_for_generic_func) and call-site mangled-name
 * resolver (codegen_emit_call_func_name) so emitted symbol and call-site symbol
 * always agree.
 */
function codegen_call_mono_type_at(arena: *ASTArena, ei: i32, arg_idx: i32, num_args: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || ei <= 0 || arg_idx < 0 || num_args <= 0) {
      return 0;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, ei);
    if ((e.kind as i32) != (ExprKind.EXPR_CALL as i32)) {
      return 0;
    }
    let ty: i32 = 0;
    /*
     * wave447: prefer the value-arg's resolved type for every arg_idx, including 0.
     * wave443 used call e.resolved_type_ref first for arg0 because identity shape
     * has ret == param0; that breaks non-identity generics such as
     * `getv<T>(x: T): i32` where the call resolves to i32 but param0 mono type
     * must be the arg type (A). Identity still works: arg type matches ret type.
     * Fallback: arg0 only may use call resolved_type_ref when the arg type is
     * missing (e.g. some integer literals), preserving prior identity behavior.
     * PLATFORM: SHARED — must agree with combo collector + call-site mangle.
     */
    if (arg_idx < num_args) {
      let a: i32 = pipeline_expr_call_arg_ref(arena, ei, arg_idx);
      if (a > 0) {
        ty = pipeline_expr_resolved_type_ref(arena, a);
      }
    }
    if (ty <= 0 && arg_idx == 0) {
      ty = e.resolved_type_ref;
    }
    return ty;
  }
}

/**
 * wave458: 1 when return TYPE_NAMED is a type-param not named on any value formal.
 *
 * Why: mono combo keys used only value-arg types (wave444). That collapses
 * `as_t<A>(7)` and `as_t<B>(9)` to the same key `[i32]` (value formal is i32),
 * and zero-param `mk<A>()`/`mk<B>()` shared one bare link name. When ret is a
 * type parameter not covered by formals, the mono key must include the call's
 * ret concrete (resolved / turbofish) so distinct T get distinct symbols.
 *
 * Covered: `id<T>(x: T): T` — ret name equals param0 name → extra=0.
 * Uncovered: `as_t<T>(x: i32): T`, `mk<T>(): T` → extra=1.
 *
 * @param arena *ASTArena
 * @param module *Module
 * @param fi i32 — function index
 * @return i32 — 1 if ret type-param needs an extra mono-key slot, else 0
 * PLATFORM: SHARED
 */
/**
 * Mono combo slot equality for generic-function collect.
 * G.7: forwards to codegen_type_refs_same_for_mono (struct-layout authority).
 * TYPE_NAMED-only missed builtin i32/f64 and TYPE_PTR (*u8): distinct type_ref
 * nodes share one mangle (va_arg__VaList_i32 twice → host-C redefinition).
 * @param arena *ASTArena — type_ref table; null → 0 via callee
 * @param a i32 — combo slot type_ref
 * @param b i32 — other slot type_ref
 * @return i32 — 1 equal mono key, 0 unequal
 * PLATFORM: SHARED host-C (one definition per mangled name; MSVC same rule)
 */
function codegen_mono_combo_slot_equal(arena: *ASTArena, a: i32, b: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    return codegen_type_refs_same_for_mono(arena, a, b);
  }
}

function codegen_func_ret_type_param_extra(arena: *ASTArena, module: *Module, fi: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    let ret_ty: i32 = pipeline_module_func_return_type_at(module, fi);
    if (ret_ty <= 0 || pipeline_type_kind_ord_at(arena, ret_ty) != (TypeKind.TYPE_NAMED as i32)) {
      return 0;
    }
    let ret_nm: u8[256] = [];
    let ret_nl: i32 = pipeline_type_named_name_into(arena, ret_ty, &ret_nm[0]);
    if (ret_nl <= 0) {
      return 0;
    }
    let np: i32 = pipeline_module_func_num_params_at(module, fi);
    let pi: i32 = 0;
    while (pi < np) {
      let pty: i32 = pipeline_module_func_param_type_ref_at(module, fi, pi);
      if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == (TypeKind.TYPE_NAMED as i32)) {
        let pnm: u8[256] = [];
        let pnl: i32 = pipeline_type_named_name_into(arena, pty, &pnm[0]);
        if (pnl == ret_nl && pnl > 0) {
          let eq: i32 = 1;
          let bi: i32 = 0;
          while (bi < pnl) {
            if (pnm[bi] != ret_nm[bi]) {
              eq = 0;
              bi = pnl;
            } else {
              bi = bi + 1;
            }
          }
          if (eq != 0) {
            return 0;
          }
        }
      }
      pi = pi + 1;
    }
    return 1;
  }
}

/**
 * wave452: concrete type for a return-position type parameter not present on
 * any value formal (as_t<T>(i32):T / mk_default<T>():T / mk2u<T,U>():U).
 *
 * @param arena *ASTArena
 * @param ei i32 — EXPR_CALL index
 * @return i32 — concrete type_ref, or 0
 * PLATFORM: SHARED
 *
 * wave455: prefer typeck-stamped resolved_type_ref over type_arg[0].
 * wave456: when resolved is unset, only fall back to type_arg[0] for a **sole**
 * type_arg (n_ta==1). Multi turbofish (`<A,B>`) must not use slot 0 — that is
 * always T, while ret may be U (type_arg[1]). Unresolved multi calls return 0
 * so the mono scanner can skip ghost name-only CALL nodes (rfi=-1) and pick the
 * typeck-resolved site. G.7 authority matches pipeline_glue fixup.
 */
function codegen_call_ret_type_param_concrete_at(arena: *ASTArena, ei: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || ei <= 0) {
      return 0;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, ei);
    if ((e.kind as i32) != (ExprKind.EXPR_CALL as i32)) {
      return 0;
    }
    if (e.resolved_type_ref > 0) {
      return e.resolved_type_ref;
    }
    /*
     * Sole type_arg: slot 0 is the only mono type (mk_default<A>() / as_t<A>(…)).
     * Multi type_arg without a typeck stamp: fail closed (return 0) — do not
     * invent type_arg[0] as ret (wave456 mk2u ret-U BLD001 root).
     */
    if (e.call_num_type_args == 1) {
      let ta: i32 = pipeline_expr_call_type_arg_ref_at(arena, ei, 0);
      if (ta > 0) {
        return ta;
      }
    }
    return 0;
  }
}

/**
 * Collect all unique mono combos for generic function fi.
 *
 * Why: identity mono must emit one instance per distinct type-arg combo (not just
 * the first call site) so multiple call sites with different types each get their
 * own mangled symbol. Scans the arena once for EXPR_CALL matching fi, extracts
 * per-value-param concrete types via codegen_call_mono_type_at, and when
 * `ret_extra!=0` (wave458) appends the call ret concrete so ret-only type params
 * (`as_t<T>(i32):T`, `mk<T>():T`) distinguish A vs B.
 *
 * Layout: flat combos_out[c * combo_width + slot]; combo_width = num_params + ret_extra.
 * num_params may be 0 when ret_extra=1 (zero-param ret-only mono).
 *
 * Invariant: combos_out holds at most max_combos*combo_width entries; returns the
 * count of unique combos found (0 if no call sites or all incomplete).
 * PLATFORM: SHARED — single-pass scan; matching logic mirrors find_mono_type
 * (call_resolved_func_index==fi OR callee name==fn_local) but collects all
 * matches instead of returning the first.
 */
function codegen_collect_mono_combos_for_generic_func(arena: *ASTArena, module: *Module, fi: i32, combos_out: *i32, max_combos: i32, num_params: i32, ret_extra: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    let combo_width: i32 = num_params + ret_extra;
    if (combos_out == 0 as *i32 || max_combos <= 0 || combo_width <= 0 || combo_width > 8) {
      return 0;
    }
    if (num_params < 0 || ret_extra < 0 || ret_extra > 1) {
      return 0;
    }
    let fn_local: u8[256] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    if (fn_len <= 0) {
      return 0;
    }
    let combo_count: i32 = 0;
    let ei: i32 = 1;
    while (ei <= arena.num_exprs) {
      let e: Expr = ast.ast_arena_expr_get(arena, ei);
      if ((e.kind as i32) == (ExprKind.EXPR_CALL as i32)) {
        let matched: i32 = 0;
        if (e.call_resolved_func_index == fi) {
          matched = 1;
        } else if (!ast.ref_is_null(e.call_callee_ref) && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs) {
          let cal: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
          if ((cal.kind as i32) == (ExprKind.EXPR_VAR as i32) && cal.var_name_len == fn_len) {
            let eq: i32 = 1;
            let k: i32 = 0;
            while (k < fn_len) {
              if (cal.var_name[k] != fn_local[k]) {
                eq = 0;
                k = fn_len;
              } else {
                k = k + 1;
              }
            }
            matched = eq;
          }
        }
        /* num_params==0: zero-arg calls still match (wave458 ret-only mono). */
        if (matched != 0 && (num_params == 0 || e.call_num_args >= num_params)) {
          /* Build this call site's combo via the shared extraction helper. */
          let combo: i32[8] = [];
          let pi: i32 = 0;
          let valid: i32 = 1;
          while (pi < num_params) {
            let ty: i32 = codegen_call_mono_type_at(arena, ei, pi, e.call_num_args);
            if (ty <= 0) {
              valid = 0;
              pi = num_params;
            } else {
              combo[pi] = ty;
            }
            pi = pi + 1;
          }
          if (valid != 0 && ret_extra != 0) {
            let rty: i32 = codegen_call_ret_type_param_concrete_at(arena, ei);
            if (rty <= 0) {
              valid = 0;
            } else {
              combo[num_params] = rty;
            }
          }
          if (valid != 0) {
            /* Dedup: scan existing combos for an exact match. */
            let found: i32 = 0;
            let ci: i32 = 0;
            while (ci < combo_count) {
              let same: i32 = 1;
              let pi2: i32 = 0;
              while (pi2 < combo_width) {
                if (codegen_mono_combo_slot_equal(arena, combos_out[ci * combo_width + pi2], combo[pi2]) == 0) {
                  same = 0;
                  pi2 = combo_width;
                }
                pi2 = pi2 + 1;
              }
              if (same != 0) {
                found = 1;
                ci = combo_count;
              }
              ci = ci + 1;
            }
            if (found == 0 && combo_count < max_combos) {
              let pi3: i32 = 0;
              while (pi3 < combo_width) {
                combos_out[combo_count * combo_width + pi3] = combo[pi3];
                pi3 = pi3 + 1;
              }
              combo_count = combo_count + 1;
            }
          }
        }
      }
      ei = ei + 1;
    }
    return combo_count;
  }
}

/*
 * wave498: call-side mono mangling for generic inherent impl methods.
 * Why: define-side codegen_try_emit_generic_impl_method_mono emits mangled
 * symbols (get__i32, get__bool) for multi-combo impl methods. Call sites must
 * emit the same mangled name or cc throws "undeclared function". This helper
 * detects whether func_ix is a generic inherent impl method (first param is a
 * generic struct with free type-args → nc>1 combos), extracts concrete type
 * args from the receiver type, and emits the mangled symbol via codegen_emit_
 * mono_mangled_name. Returns 1 if emitted (caller should skip bare link-name),
 * 0 if not applicable (caller falls back to bare link_name), -1 on emit error.
 * PLATFORM: SHARED — seed codegen_gen.linux.x86_64.c same commit.
 * Guards: only activates when receiver_ty is concrete (fill_concrete succeeds),
 * func has >=1 param, first param is a named struct with >0 type params, and
 * the total combo count for that struct layout >1 (nc==1 uses bare link name).
 */
export function codegen_try_emit_impl_method_mono_call_name(out: *CodegenOutBuf, arena: *ASTArena, ctx: *PipelineDepCtx, module: *Module, fi: i32, receiver_ty: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (out == 0 as *CodegenOutBuf || arena == 0 as *ASTArena || module == 0 as *Module) {
      return 0;
    }
    if (fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    if (pipeline_module_func_num_generic_params_at(module, fi) > 0) {
      return 0;
    }
    if (receiver_ty <= 0) {
      return 0;
    }
    let np: i32 = pipeline_module_func_num_params_at(module, fi);
    if (np < 1) {
      return 0;
    }
    let p0_ty_raw: i32 = pipeline_module_func_param_type_ref_at(module, fi, 0);
    if (p0_ty_raw <= 0) {
      return 0;
    }
    let p0_ty: i32 = pipeline_typeck_resolve_type_alias_ref_c(arena, p0_ty_raw);
    if (p0_ty <= 0) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, p0_ty) != (TypeKind.TYPE_NAMED as i32)) {
      return 0;
    }
    let nm: u8[256] = [];
    let nl: i32 = pipeline_type_named_name_into(arena, p0_ty, &nm[0]);
    if (nl <= 0) {
      return 0;
    }
    let bare_off: i32 = 0;
    let bi: i32 = 0;
    while (bi < nl && bi < 64) {
      if (nm[bi] == 46) {
        bare_off = bi + 1;
      }
      bi = bi + 1;
    }
    let bare_len: i32 = nl - bare_off;
    if (bare_len <= 0) {
      return 0;
    }
    let lk: i32 = codegen_module_struct_layout_index_by_name(module, &nm[bare_off], bare_len);
    if (lk < 0) {
      return 0;
    }
    let ntp: i32 = pipeline_module_struct_layout_num_type_params_at(module, lk);
    if (ntp <= 0 || ntp > 8) {
      return 0;
    }
    let mono_chk: i32[8] = [];
    if (codegen_generic_struct_fill_concrete_args(module, arena, p0_ty, ntp, &mono_chk[0], 0 as *PipelineDepCtx) == ntp) {
      return 0;
    }
    let combos: i32[32] = [];
    let nc: i32 = codegen_collect_generic_struct_mono_combos(module, arena, lk, &nm[bare_off], bare_len, ntp, &combos[0], 8);
    if (nc <= 1) {
      return 0;
    }
    let recv_concrete: i32 = receiver_ty;
    if (ctx != 0 as *PipelineDepCtx && ctx.mono_active != 0) {
      recv_concrete = codegen_mono_subst_type(ctx, arena, recv_concrete);
    }
    let recv_mono: i32[8] = [];
    if (codegen_generic_struct_fill_concrete_args(module, arena, recv_concrete, ntp, &recv_mono[0], ctx) != ntp) {
      return 0;
    }
    if (codegen_emit_mono_mangled_name(out, arena, module, fi, &recv_mono[0], ntp) != 0) {
      return -1;
    }
    return 1;
  }
}

/**
 * Emit a mono-mangled symbol `<link_name>__<suffix0>[_<suffix1>...]` for generic
 * function fi with the given mono type-arg combo.
 *
 * Why: multiple mono instances of the same generic function need distinct C link
 * symbols (e.g., `copy__A` vs `copy__i32`) to avoid duplicate-symbol link errors.
 * The `__` separator distinguishes mono mangling from overload mangling (which
 * uses single `_` per param suffix via codegen_emit_func_link_name).
 *
 * Invariant: mono_tys holds num_mono entries; each suffix is rendered via
 * codegen_type_ref_to_suffix (reusing the overload-suffix authority). Returns 0
 * on success, -1 on emit error.
 * PLATFORM: SHARED — mono symbol authority; called by codegen_try_emit_generic_
 * identity_mono (emit side) and must agree with call-site mangling in
 * codegen_emit_call_func_name (consume side).
 */
function codegen_emit_mono_mangled_name(out: *CodegenOutBuf, arena: *ASTArena, module: *Module, fi: i32, mono_tys: *i32, num_mono: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (out == 0 as *CodegenOutBuf || arena == 0 as *ASTArena || module == 0 as *Module || mono_tys == 0 as *i32) {
      return -1;
    }
    if (fi < 0 || fi >= module.num_funcs || num_mono <= 0) {
      return -1;
    }
    /* Emit the base link name (bare for non-overloaded generics; overload-mangled
     * suffix is preserved so mono + overload compose if needed). */
    if (codegen_emit_func_link_name(out, arena, module, fi) != 0) {
      return -1;
    }
    /* `__` marks this as a mono instance and separates from overload `_` mangling. */
    let sep: u8[2] = [95, 95];
    if (codegen_emit_bytes_from_ptr(out, &sep[0], 2) != 0) {
      return -1;
    }
    let mi: i32 = 0;
    while (mi < num_mono) {
      let suf: u8[256] = [];
      let ty: i32 = mono_tys[mi];
      let sl: i32 = codegen_type_ref_to_suffix(arena, ty, &suf[0], 64);
      if (sl <= 0) {
        return -1;
      }
      if (mi > 0) {
        if (codegen_append_byte(out, 95) != 0) {
          return -1;
        }
      }
      if (codegen_emit_bytes_from_ptr(out, &suf[0], sl) != 0) {
        return -1;
      }
      mi = mi + 1;
    }
    return 0;
  }
}

/**
 * Substitute a type_ref via the active mono substitution map (C5/C6 helper).
 *
 * Why: during mono body emit, generic type refs (T, U, ...) must be replaced with
 * concrete type refs (A, B, ...). This helper checks ctx.mono_generic_type_refs[]
 * and returns the matching concrete type_ref, or the original type_ref if no match.
 *
 * Invariant: returns the original type_ref when mono is inactive or no match found.
 * PLATFORM: SHARED — single substitution authority used by codegen_emit_expr method-call
 * re-resolution (C6) and consistent with codegen_emit_type's own C5 hook.
 */
function codegen_mono_subst_type(ctx: *PipelineDepCtx, arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ctx == 0 as *PipelineDepCtx || ctx.mono_active == 0 || ctx.mono_num_types <= 0) {
      return type_ref;
    }
    let mi: i32 = 0;
    while (mi < ctx.mono_num_types && mi < 8) {
      if (type_ref == ctx.mono_generic_type_refs[mi] && ctx.mono_concrete_type_refs[mi] > 0) {
        return ctx.mono_concrete_type_refs[mi];
      }
      mi = mi + 1;
    }
    /*
     * Name-match fallback: typeck does NOT always reuse the param's type_ref node
     * for body occurrences (e.g. `let y: T` allocates a fresh TYPE_NAMED "T").
     * Compare the type's name against each generic param's name; substitute on
     * match. Builtin types have no name (returns 0) and skip this fallback.
     * Single authority: codegen_emit_type C5 and C6 both rely on this name match.
     * PLATFORM: SHARED — mirrors codegen_gen.linux.x86_64.c.
     */
    let fb_nm: u8[256] = [];
    let fb_len: i32 = pipeline_type_named_name_into(arena, type_ref, &fb_nm[0]);
    if (fb_len > 0) {
      let mi2: i32 = 0;
      while (mi2 < ctx.mono_num_types && mi2 < 8) {
        if (ctx.mono_concrete_type_refs[mi2] > 0) {
          let gnm: u8[256] = [];
          let gname_len: i32 = pipeline_type_named_name_into(arena, ctx.mono_generic_type_refs[mi2], &gnm[0]);
          if (gname_len == fb_len && gname_len > 0) {
            let names_eq: i32 = 1;
            let ci: i32 = 0;
            while (ci < gname_len) {
              if (gnm[ci] != fb_nm[ci]) {
                names_eq = 0;
                ci = gname_len;
              } else {
                ci = ci + 1;
              }
            }
            if (names_eq != 0) {
              return ctx.mono_concrete_type_refs[mi2];
            }
          }
        }
        mi2 = mi2 + 1;
      }
    }
    return type_ref;
  }
}

/**
 * Find the impl method for a concrete receiver type + method name (C6 helper).
 *
 * Why: typeck processes a generic function body once with T unresolved, so
 * call_resolved_func_index for `x.clone()` (x: T) points at the trait method
 * (signature-only), not the impl method (A::clone). During mono body emit, the
 * receiver's concrete type is known (A), so this helper scans the module for a
 * function matching method_name whose param0 type equals receiver_type_ref.
 *
 * Invariant: returns the first matching func index, or -1 if no match.
 * PLATFORM: SHARED — mirrors codegen_find_module_func_index_by_name_overload name
 * matching but adds param0 type equality via pipeline_typeck_type_refs_equal_c.
 */
export function codegen_find_impl_method_for_type(module: *Module, arena: *ASTArena, method_name: *u8, method_name_len: i32, receiver_type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || arena == 0 as *ASTArena || method_name == 0 as *u8) {
      return -1;
    }
    if (method_name_len <= 0 || receiver_type_ref <= 0) {
      return -1;
    }
    let fi: i32 = 0;
    while (fi < module.num_funcs) {
      let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
      if (fn_len == method_name_len && fn_len > 0) {
        let fn_name: u8[256] = [];
        pipeline_module_func_name_copy64(module, fi, &fn_name[0]);
        let matched: i32 = 1;
        let bi: i32 = 0;
        while (bi < fn_len) {
          if (fn_name[bi] != method_name[bi]) {
            matched = 0;
            bi = fn_len;
          } else {
            bi = bi + 1;
          }
        }
        if (matched != 0) {
          /*
           * Check param0 type matches the concrete receiver type.
           * Primary: direct type_ref equality (works when impl and call site share
           * the same typeck context / arena). Fallback: name-based comparison —
           * impl method's param0 type_ref and the mono substitution's concrete
           * type_ref can come from different typeck passes (impl processed
           * separately from the generic call site), so direct type_ref equality
           * fails even when both refer to the same named type (e.g., "A").
           * Mirrors C5 codegen_emit_type name-match fallback. Builtin types (i32, etc.)
           * have no name and rely on direct equality, which is stable for builtins.
           * PLATFORM: SHARED — mirrors seed codegen_gen.linux.x86_64.c.
           */
          let np: i32 = pipeline_module_func_num_params_at(module, fi);
          if (np > 0) {
            let p0_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, 0);
            if (p0_ty > 0) {
              if (pipeline_typeck_type_refs_equal_c(arena, p0_ty, receiver_type_ref) != 0) {
                return fi;
              }
              let p0_nm: u8[256] = [];
              let p0_nlen: i32 = pipeline_type_named_name_into(arena, p0_ty, &p0_nm[0]);
              let recv_nm: u8[256] = [];
              let recv_nlen: i32 = pipeline_type_named_name_into(arena, receiver_type_ref, &recv_nm[0]);
              if (p0_nlen > 0 && p0_nlen == recv_nlen) {
                let neq: i32 = 1;
                let ni: i32 = 0;
                while (ni < p0_nlen) {
                  if (p0_nm[ni] != recv_nm[ni]) {
                    neq = 0;
                    ni = p0_nlen;
                  } else {
                    ni = ni + 1;
                  }
                }
                if (neq != 0) {
                  if (pipeline_type_kind_ord_at(arena, p0_ty) == (TypeKind.TYPE_NAMED as i32)
                      && pipeline_type_kind_ord_at(arena, receiver_type_ref) == (TypeKind.TYPE_NAMED as i32)) {
                    if (codegen_type_refs_same_for_mono(arena, p0_ty, receiver_type_ref) != 0) {
                      return fi;
                    }
                  } else {
                    return fi;
                  }
                }
              }
            }
          }
        }
      }
      fi = fi + 1;
    }
    return -1;
  }
}

/**
 * F4: Emit one vtable slot payload — either "(void*)&<prefix><link>" or
 * "(void*)0" — without separator or framing. Shared G.7 authority for slot
 * emission; called by both codegen_emit_module_vtable_statics (static decl
 * wrapping) and the inline fallback path of codegen_emit_dyn_vtable_close
 * (compound-literal wrapping). The NAMED/PTR-to-NAMED fast path of
 * codegen_emit_dyn_vtable_close does NOT call this — it emits a reference
 * to the static, so vtable contents live in exactly one place.
 *
 * Resolves the method name at `slot_i` via `xlang_skip_trait_method_name_into_c`,
 * looks up the impl function via `codegen_find_impl_method_for_type` (single
 * G.7 authority), and emits the cast function pointer or null placeholder.
 *
 * @param out       codegen output buffer.
 * @param arena     AST arena.
 * @param cur_mod   current module (for impl method lookup + link name).
 * @param ctx       pipeline dep ctx (for prefix; may be null → no prefix).
 * @param trait_nm  trait name bytes.
 * @param trait_nlen trait name length.
 * @param slot_i    vtable slot index (0..meth_count-1).
 * @param recv_rt   receiver type_ref (impl lookup target).
 * @return 0 on success, -1 on emit failure.
 * PLATFORM: SHARED — mirrors seeds/codegen_gen.linux.x86_64.c.
 */
export function codegen_emit_vtable_slot_payload(out: *CodegenOutBuf, arena: *ASTArena,
        cur_mod: *Module, ctx: *PipelineDepCtx,
        trait_nm: *u8, trait_nlen: i32, slot_i: i32, recv_rt: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /* Resolve method name at slot_i from the trait registry. */
    let meth_nm: u8[64] = [];
    let meth_nlen: i32 = xlang_skip_trait_method_name_into_c(trait_nm, trait_nlen,
            slot_i, &meth_nm[0]);
    /* "(void*)0" — 8 bytes, null placeholder for unresolved/default methods. */
    let null_slot: u8[8] = [40, 118, 111, 105, 100, 42, 41, 48];
    if (meth_nlen <= 0) {
      return codegen_emit_bytes_from_ptr(out, &null_slot[0], 8);
    }
    /* Look up the impl function for this method on the concrete type. */
    let impl_fi: i32 = codegen_find_impl_method_for_type(cur_mod, arena,
            &meth_nm[0], meth_nlen, recv_rt);
    if (impl_fi < 0) {
      return codegen_emit_bytes_from_ptr(out, &null_slot[0], 8);
    }
    /* Emit "(void*)&" + module prefix + function link name. */
    let addr_cast: u8[8] = [40, 118, 111, 105, 100, 42, 41, 38];
    if (codegen_emit_bytes_from_ptr(out, &addr_cast[0], 8) != 0) {
      return -1;
    }
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_prefix_len > 0) {
      if (codegen_emit_bytes_from_ptr(out, &ctx.current_codegen_prefix_mirror[0],
              ctx.current_codegen_prefix_len) != 0) {
        return -1;
      }
    }
    return codegen_emit_func_link_name(out, arena, cur_mod, impl_fi);
  }
}

/**
 * F4: Emit the canonical vtable static name `xlang_vtable_<Trait>_for_[Ptr_]<Type>`
 * with no prefix or suffix. Shared G.7 single authority for vtable naming,
 * called by:
 *   - codegen_emit_module_vtable_statics (static definition:
 *     `static void* <name>[] = { ... };`)
 *   - codegen_emit_dyn_vtable_close fast path (coerce reference:
 *     `.vtable = <name>`)
 *
 * Both sites must emit identical names so the coerce reference resolves to the
 * module-level static. Trait and for-type names are sanitized to valid C
 * identifiers (non-alnum → '_'); X lexemes are already valid in practice, so
 * sanitize is a safety net.
 *
 * @param out codegen output buffer.
 * @param trait_nm trait name bytes.
 * @param trait_nlen trait name length (must be > 0).
 * @param for_nm for-type name bytes.
 * @param for_nlen for-type name length (must be > 0).
 * @param is_ptr 1 if PTR-to-NAMED (emits "Ptr_" before for-type name), 0 else.
 * @return 0 on success, -1 on emit failure or invalid args.
 * PLATFORM: SHARED — mirrors seeds/codegen_gen.linux.x86_64.c.
 */
export function codegen_emit_vtable_static_name(out: *CodegenOutBuf,
        trait_nm: *u8, trait_nlen: i32,
        for_nm: *u8, for_nlen: i32, is_ptr: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (out == 0 as *CodegenOutBuf || trait_nm == 0 as *u8 || for_nm == 0 as *u8) {
      return -1;
    }
    if (trait_nlen <= 0 || for_nlen <= 0) {
      return -1;
    }
    /* "xlang_vtable_" — 13 bytes. */
    let vt_stem: u8[13] = [120, 108, 97, 110, 103, 95, 118, 116, 97, 98, 108, 101, 95];
    if (codegen_emit_bytes_from_ptr(out, &vt_stem[0], 13) != 0) {
      return -1;
    }
    /* Sanitize + emit trait name (non-[A-Za-z0-9_] -> '_'). */
    let ti: i32 = 0;
    while (ti < trait_nlen && ti < 64) {
      let b: u8 = trait_nm[ti];
      let is_alnum_: i32 = 0;
      if (b == 95) { is_alnum_ = 1; }
      if (b >= 48 && b <= 57) { is_alnum_ = 1; }
      if (b >= 65 && b <= 90) { is_alnum_ = 1; }
      if (b >= 97 && b <= 122) { is_alnum_ = 1; }
      if (is_alnum_ == 0) { b = 95; }
      if (codegen_append_byte(out, b) != 0) { return -1; }
      ti = ti + 1;
    }
    /* "_for_" — 5 bytes. */
    let for_kw: u8[5] = [95, 102, 111, 114, 95];
    if (codegen_emit_bytes_from_ptr(out, &for_kw[0], 5) != 0) { return -1; }
    /* "Ptr_" — 4 bytes, only when PTR-to-NAMED. */
    if (is_ptr != 0) {
      let ptr_kw: u8[4] = [80, 116, 114, 95];
      if (codegen_emit_bytes_from_ptr(out, &ptr_kw[0], 4) != 0) { return -1; }
    }
    /* Sanitize + emit for-type name (same logic as trait name). */
    let fi: i32 = 0;
    while (fi < for_nlen && fi < 64) {
      let b: u8 = for_nm[fi];
      let is_alnum_: i32 = 0;
      if (b == 95) { is_alnum_ = 1; }
      if (b >= 48 && b <= 57) { is_alnum_ = 1; }
      if (b >= 65 && b <= 90) { is_alnum_ = 1; }
      if (b >= 97 && b <= 122) { is_alnum_ = 1; }
      if (is_alnum_ == 0) { b = 95; }
      if (codegen_append_byte(out, b) != 0) { return -1; }
      fi = fi + 1;
    }
    return 0;
  }
}

/**
 * F6: Map a builtin TypeKind ordinal to its X source name bytes (e.g.
 * TYPE_I32 -> "i32", TYPE_F64 -> "f64", TYPE_VOID -> "void"). Returns the
 * name length (>0) for builtin scalar/void kinds; returns 0 for non-builtin
 * kinds (NAMED/PTR/ARRAY/SLICE/LINEAR/VECTOR/DYN).
 *
 * Root cause: the impl registry stores `impl Trait for <builtin>` blocks with
 * an EMPTY for-type name (only the kind ordinal survives — see
 * xlang_skip_impl_for_type_into_c out_name64 docblock). The vtable static +
 * wrapper naming helpers take a for-type name, so a builtin for-type has no
 * name to feed them. This helper synthesizes the canonical X name from the
 * kind ordinal so builtin for-types can share the F4/F5 static-vtable path.
 *
 * Single authority for the builtin kind->name map; called by
 * codegen_emit_module_vtable_statics (synthesize for_nm before emitting the
 * static + wrapper) and usable from coerce sites to reference the same static.
 * Mirrored in seed codegen_gen.linux.x86_64.c.
 * PLATFORM: SHARED.
 */
export function codegen_builtin_type_name_into(kind_ord: i32, out: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (out == 0 as *u8) { return 0; }
    if (kind_ord == (TypeKind.TYPE_I32 as i32)) {
      out[0] = 105; out[1] = 51; out[2] = 50; return 3;
    }
    if (kind_ord == (TypeKind.TYPE_BOOL as i32)) {
      out[0] = 98; out[1] = 111; out[2] = 111; out[3] = 108; return 4;
    }
    if (kind_ord == (TypeKind.TYPE_U8 as i32)) {
      out[0] = 117; out[1] = 56; return 2;
    }
    if (kind_ord == (TypeKind.TYPE_U32 as i32)) {
      out[0] = 117; out[1] = 51; out[2] = 50; return 3;
    }
    if (kind_ord == (TypeKind.TYPE_U64 as i32)) {
      out[0] = 117; out[1] = 54; out[2] = 52; return 3;
    }
    if (kind_ord == (TypeKind.TYPE_I64 as i32)) {
      out[0] = 105; out[1] = 54; out[2] = 52; return 3;
    }
    if (kind_ord == (TypeKind.TYPE_USIZE as i32)) {
      out[0] = 117; out[1] = 115; out[2] = 105; out[3] = 122; out[4] = 101; return 5;
    }
    if (kind_ord == (TypeKind.TYPE_ISIZE as i32)) {
      out[0] = 105; out[1] = 115; out[2] = 105; out[3] = 122; out[4] = 101; return 5;
    }
    if (kind_ord == (TypeKind.TYPE_F32 as i32)) {
      out[0] = 102; out[1] = 51; out[2] = 50; return 3;
    }
    if (kind_ord == (TypeKind.TYPE_F64 as i32)) {
      out[0] = 102; out[1] = 54; out[2] = 52; return 3;
    }
    if (kind_ord == (TypeKind.TYPE_VOID as i32)) {
      out[0] = 118; out[1] = 111; out[2] = 105; out[3] = 100; return 4;
    }
    return 0;
  }
}

/**
 * F5+: Emit the canonical vtable wrapper name
 * `xlang_vtable_wrap_<Trait>_for_[Ptr_]<Type>_<slot>`. Follows the same
 * sanitization as codegen_emit_vtable_static_name (G.7 single naming
 * authority) with the `_wrap_` infix and `_<slot>` suffix appended.
 *
 * The wrapper bridges the type mismatch between the dyn dispatch (which
 * always passes `void* data` = a pointer) and the impl method's self
 * parameter (by-value struct or pointer). Without wrappers, by-value
 * self methods receive a pointer where they expect a value, producing
 * garbage return values (root cause of F3 false-green).
 *
 * @param out codegen output buffer.
 * @param trait_nm trait name bytes.
 * @param trait_nlen trait name length (must be > 0).
 * @param for_nm for-type name bytes.
 * @param for_nlen for-type name length (must be > 0).
 * @param is_ptr 1 if PTR-to-NAMED (emits "Ptr_" before for-type name), 0 else.
 * @param slot_i vtable slot index (0-based).
 * @return 0 on success, -1 on emit failure or invalid args.
 * PLATFORM: SHARED — mirrors seeds/codegen_gen.linux.x86_64.c.
 */
export function codegen_emit_vtable_wrapper_name(out: *CodegenOutBuf,
        trait_nm: *u8, trait_nlen: i32,
        for_nm: *u8, for_nlen: i32, is_ptr: i32, slot_i: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (out == 0 as *CodegenOutBuf || trait_nm == 0 as *u8 || for_nm == 0 as *u8) {
      return -1;
    }
    if (trait_nlen <= 0 || for_nlen <= 0) {
      return -1;
    }
    /* "xlang_vtable_wrap_" — 18 bytes. */
    let wrap_stem: u8[18] = [120, 108, 97, 110, 103, 95, 118, 116, 97, 98, 108, 101, 95, 119, 114, 97, 112, 95];
    if (codegen_emit_bytes_from_ptr(out, &wrap_stem[0], 18) != 0) {
      return -1;
    }
    /* Sanitize + emit trait name (non-[A-Za-z0-9_] -> '_'). */
    let ti: i32 = 0;
    while (ti < trait_nlen && ti < 64) {
      let b: u8 = trait_nm[ti];
      let is_alnum_: i32 = 0;
      if (b == 95) { is_alnum_ = 1; }
      if (b >= 48 && b <= 57) { is_alnum_ = 1; }
      if (b >= 65 && b <= 90) { is_alnum_ = 1; }
      if (b >= 97 && b <= 122) { is_alnum_ = 1; }
      if (is_alnum_ == 0) { b = 95; }
      if (codegen_append_byte(out, b) != 0) { return -1; }
      ti = ti + 1;
    }
    /* "_for_" — 5 bytes. */
    let for_kw: u8[5] = [95, 102, 111, 114, 95];
    if (codegen_emit_bytes_from_ptr(out, &for_kw[0], 5) != 0) { return -1; }
    /* "Ptr_" — 4 bytes, only when PTR-to-NAMED. */
    if (is_ptr != 0) {
      let ptr_kw: u8[4] = [80, 116, 114, 95];
      if (codegen_emit_bytes_from_ptr(out, &ptr_kw[0], 4) != 0) { return -1; }
    }
    /* Sanitize + emit for-type name. */
    let fi: i32 = 0;
    while (fi < for_nlen && fi < 64) {
      let b: u8 = for_nm[fi];
      let is_alnum_: i32 = 0;
      if (b == 95) { is_alnum_ = 1; }
      if (b >= 48 && b <= 57) { is_alnum_ = 1; }
      if (b >= 65 && b <= 90) { is_alnum_ = 1; }
      if (b >= 97 && b <= 122) { is_alnum_ = 1; }
      if (is_alnum_ == 0) { b = 95; }
      if (codegen_append_byte(out, b) != 0) { return -1; }
      fi = fi + 1;
    }
    /* "_" — 1 byte separator before slot number. */
    if (codegen_append_byte(out, 95) != 0) { return -1; }
    return format_uint(out, slot_i);
  }
}

/**
 * F5+: Emit a vtable wrapper function definition that adapts the uniform
 * `void* data` dispatch argument to the impl method's expected self type.
 *
 * Root cause fix for F3 by-value dispatch: the dyn dispatch always passes
 * `recv.data` (a void* pointer) as arg 0, but by-value self methods
 * (e.g. `clone(self: A)`) expect the struct value, not a pointer. The
 * wrapper bridges this:
 *
 *   By-value self (impl Trait for A, self: A):
 *     static <ret> <wrap>(void* data, T1 a1, ...) {
 *       return <func>(*(struct A*)data, a1, ...);
 *     }
 *   Pointer self (impl Trait for *A, self: *A):
 *     static <ret> <wrap>(void* data, T1 a1, ...) {
 *       return <func>((struct A*)data, a1, ...);
 *     }
 *
 * First formal is always `void* data` (rdi/x0 = data ABI; do not change).
 * Extra formals are impl params 1..N. Host-C has no register file — extras
 * beyond SysV GP 1..5 stay named C formals (a6, a7, ...). Safety cap 96
 * matches the asm dyn extras bound. Call site emits `(recv.data, args...)`
 * through a typed `(void*, T1, T2)` cast
 * (codegen_emit_dyn_host_c_fn_ptr_suffix) so host cc does not default-
 * promote f32 extras. `[K][N]T` / `*[N]T` extras use the same
 * codegen_emit_c_ptr_to_fixed_array_decl path as emit_func (`E (*aN)[N]…`).
 *
 * The vtable static then stores `(void*)&<wrap>` instead of
 * `(void*)&<func>`, so the dispatch's void* data arg is always adapted
 * correctly regardless of self passing convention.
 *
 * @param out codegen output buffer.
 * @param arena AST arena.
 * @param cur_mod current module.
 * @param ctx pipeline dep ctx (for module + prefix).
 * @param trait_nm trait name bytes.
 * @param trait_nlen trait name length.
 * @param for_nm for-type name bytes.
 * @param for_nlen for-type name length.
 * @param for_ptr 1 if PTR-to-NAMED, 0 if by-value.
 * @param slot_i vtable slot index.
 * @param recv_rt receiver type_ref (for impl method lookup).
 * @return 1 if wrapper emitted, 0 if no impl method (null slot), -1 on error.
 * PLATFORM: SHARED — mirrors seeds/codegen_gen.linux.x86_64.c.
 */
export function codegen_emit_vtable_wrapper_def(out: *CodegenOutBuf, arena: *ASTArena,
        cur_mod: *Module, ctx: *PipelineDepCtx,
        trait_nm: *u8, trait_nlen: i32,
        for_nm: *u8, for_nlen: i32, for_ptr: i32,
        slot_i: i32, recv_rt: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (out == 0 as *CodegenOutBuf || arena == 0 as *ASTArena) {
      return -1;
    }
    /* Resolve method name at slot_i from the trait registry. */
    let meth_nm: u8[64] = [];
    let meth_nlen: i32 = xlang_skip_trait_method_name_into_c(trait_nm, trait_nlen,
            slot_i, &meth_nm[0]);
    if (meth_nlen <= 0) {
      return 0;
    }
    /* Look up the impl function for this method on the concrete type. */
    let impl_fi: i32 = codegen_find_impl_method_for_type(cur_mod, arena,
            &meth_nm[0], meth_nlen, recv_rt);
    if (impl_fi < 0) {
      return 0;
    }
    /* Get method return kind from the trait registry. */
    let ret_kind: i32 = xlang_skip_trait_method_ret_kind_c(trait_nm, trait_nlen, slot_i);
    if (ret_kind < 0) {
      ret_kind = TypeKind.TYPE_VOID as i32;
    }
    /* "static " — 7 bytes. */
    let static_kw: u8[7] = [115, 116, 97, 116, 105, 99, 32];
    if (codegen_emit_bytes_from_ptr(out, &static_kw[0], 7) != 0) {
      return -1;
    }
    /*
     * Return type: emit_func uses codegen_emit_type(ret_ty_ref). codegen_emit_type_kind
     * only covers scalars + void + dyn — ARRAY/SLICE (10/11) returned -1
     * (dyn_ret_arr / dyn_ret_slice host-C XP003). G.7 complete this
     * wrapper (no second wrapper): prefer impl return type_ref.
     * PLATFORM: SHARED host-C emit; Ubuntu gold.
     */
    let pref: *u8 = 0 as *u8;
    let pref_len: i32 = 0;
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_prefix_len > 0) {
      pref = &ctx.current_codegen_prefix_mirror[0];
      pref_len = ctx.current_codegen_prefix_len;
    }
    let impl_ret: i32 = 0;
    if (cur_mod != 0 as *Module) {
      impl_ret = pipeline_module_func_return_type_at(cur_mod, impl_fi);
    }
    if (impl_ret > 0) {
      if (codegen_emit_type(arena, out, impl_ret, pref, pref_len, ctx) != 0) {
        return -1;
      }
    } else if (codegen_emit_type_kind(out, ret_kind) != 0) {
      return -1;
    }
    /* " " — 1 byte space before wrapper name. */
    if (codegen_append_byte(out, 32) != 0) { return -1; }
    /* Emit wrapper name via codegen_emit_vtable_wrapper_name (G.7 authority). */
    if (codegen_emit_vtable_wrapper_name(out, trait_nm, trait_nlen,
            for_nm, for_nlen, for_ptr, slot_i) != 0) {
      return -1;
    }
    /* "(void* data" — 11 bytes. First arg stays data (rdi/x0 ABI unchanged). */
    let wrap_open: u8[11] = [40, 118, 111, 105, 100, 42, 32, 100, 97, 116, 97];
    if (codegen_emit_bytes_from_ptr(out, &wrap_open[0], 11) != 0) {
      return -1;
    }
    /*
     * Forward impl extras after self. G.7: complete this function (no second
     * wrapper). Loops already emit every extra_i < nparams; the old
     * nparams>6 hard-fail was leftover (dyn_add_stack host-C XP003).
     * Safety cap 96 matches asm dyn extras. First formal stays void* data.
     * PLATFORM: SHARED — host-C emit; Ubuntu gold.
     */
    let nparams: i32 = 0;
    if (cur_mod != 0 as *Module) {
      nparams = pipeline_module_func_num_params_at(cur_mod, impl_fi);
    }
    if (nparams > 96) {
      return -1;
    }
    let extra_i: i32 = 1;
    while (extra_i < nparams) {
      let pty: i32 = pipeline_module_func_param_type_ref_at(cur_mod, impl_fi, extra_i);
      /* ", " */
      if (codegen_append_byte(out, 44) != 0) { return -1; }
      if (codegen_append_byte(out, 32) != 0) { return -1; }
      /*
       * [K][N]T / *[N]T extras: codegen_emit_type peels ARRAY to `E *` twice
       * (`int32_t * * a1`) while emit_func already emits
       * `int32_t (*p)[2]`. Sit-red dyn_add_arr2 host-C run=219.
       * G.7: same named-array path as emit_func (no second wrapper).
       * Synthetic name stays aN. extra_i < 96 so two digits suffice.
       * PLATFORM: SHARED host-C emit; Ubuntu gold.
       */
      if (type_uses_named_array_decl(arena, pty) != 0) {
        let aname: u8[8] = [];
        aname[0] = 97;
        let alen: i32 = 1;
        if (extra_i >= 10) {
          aname[1] = ((extra_i / 10) + 48) as u8;
          aname[2] = ((extra_i % 10) + 48) as u8;
          alen = 3;
        } else {
          aname[1] = (extra_i + 48) as u8;
          alen = 2;
        }
        if (codegen_emit_c_ptr_to_fixed_array_decl(arena, out, pty, &aname[0], alen, ctx) != 0) {
          return -1;
        }
      } else {
        if (codegen_emit_type(arena, out, pty, pref, pref_len, ctx) != 0) {
          return -1;
        }
        /* TYPE_SLICE extras use the same pointer ABI as emit_func. */
        if (pipeline_type_kind_ord_at(arena, pty) == (TypeKind.TYPE_SLICE as i32)) {
          if (codegen_append_byte(out, 32) != 0) { return -1; }
          if (codegen_append_byte(out, 42) != 0) { return -1; }
        }
        /* Synthetic " aN" — self is adapted from data, not forwarded by name. */
        if (codegen_append_byte(out, 32) != 0) { return -1; }
        if (codegen_append_byte(out, 97) != 0) { return -1; }
        if (format_uint(out, extra_i) != 0) { return -1; }
      }
      extra_i = extra_i + 1;
    }
    /* ") { return " — 11 bytes. */
    let wrap_mid: u8[11] = [41, 32, 123, 32, 114, 101, 116, 117, 114, 110, 32];
    if (codegen_emit_bytes_from_ptr(out, &wrap_mid[0], 11) != 0) {
      return -1;
    }
    /* Emit module prefix (if any) before the function link name. */
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_prefix_len > 0) {
      if (codegen_emit_bytes_from_ptr(out, &ctx.current_codegen_prefix_mirror[0],
              ctx.current_codegen_prefix_len) != 0) {
        return -1;
      }
    }
    /* Emit the impl function link name (G.7 single authority for link names). */
    if (codegen_emit_func_link_name(out, arena, cur_mod, impl_fi) != 0) {
      return -1;
    }
    /* "(" — 1 byte, open call args. */
    if (codegen_append_byte(out, 40) != 0) { return -1; }
    /*
     * Adapt void* data to the method's self type:
     * - by-value self (for_ptr=0): dereference
     *   - NAMED: *(struct <Type>*)data
     *   - builtin (F6): *(<C-type>*)data  (no "struct" — i32/f64 are scalars)
     * - pointer self (for_ptr=1): cast
     *   - NAMED: (struct <Type>*)data
     *   - builtin (F6): (<C-type>*)data
     * F6: builtin for-types reach here via codegen_emit_module_vtable_statics
     * (recv_rt is the builtin kind's type_ref). Detect via recv_rt's kind ord;
     * emit the C type (int32_t/f64/...) instead of "struct <name>". The shared
     * close_data below ("*)data") closes the cast; extras are forwarded after.
     */
    let recv_kind: i32 = pipeline_type_kind_ord_at(arena, recv_rt);
    let builtin_nm: u8[16] = [];
    let is_builtin: i32 = codegen_builtin_type_name_into(recv_kind, &builtin_nm[0]);
    if (is_builtin != 0) {
      /* by-value: "*" deref prefix; pointer: omit. Then "(" opens the cast. */
      if (for_ptr == 0) {
        if (codegen_append_byte(out, 42) != 0) { return -1; }
      }
      if (codegen_append_byte(out, 40) != 0) { return -1; }
      /* Emit the builtin C type (int32_t/f64/...). */
      if (codegen_emit_type_kind(out, recv_kind) != 0) { return -1; }
    } else if (for_ptr == 0) {
      /* "*(struct " — 9 bytes (deref + cast open). */
      let deref_cast: u8[9] = [42, 40, 115, 116, 114, 117, 99, 116, 32];
      if (codegen_emit_bytes_from_ptr(out, &deref_cast[0], 9) != 0) {
        return -1;
      }
    } else {
      /* "(struct " — 8 bytes (cast open, no deref). */
      let ptr_cast: u8[8] = [40, 115, 116, 114, 117, 99, 116, 32];
      if (codegen_emit_bytes_from_ptr(out, &ptr_cast[0], 8) != 0) {
        return -1;
      }
    }
    /* Emit the for-type name (sanitized: copy only alnum/_, cap 64).
     * Skipped for builtin: the C type was already emitted above. */
    if (is_builtin == 0) {
      let fi2: i32 = 0;
      while (fi2 < for_nlen && fi2 < 64) {
        let b: u8 = for_nm[fi2];
        let is_alnum_: i32 = 0;
        if (b == 95) { is_alnum_ = 1; }
        if (b >= 48 && b <= 57) { is_alnum_ = 1; }
        if (b >= 65 && b <= 90) { is_alnum_ = 1; }
        if (b >= 97 && b <= 122) { is_alnum_ = 1; }
        if (is_alnum_ == 0) { b = 95; }
        if (codegen_append_byte(out, b) != 0) { return -1; }
        fi2 = fi2 + 1;
      }
    }
    /* "*)data" — 6 bytes (close cast + data). Extras forwarded below. */
    let close_data: u8[6] = [42, 41, 100, 97, 116, 97];
    if (codegen_emit_bytes_from_ptr(out, &close_data[0], 6) != 0) {
      return -1;
    }
    extra_i = 1;
    while (extra_i < nparams) {
      /* ", aN" */
      if (codegen_append_byte(out, 44) != 0) { return -1; }
      if (codegen_append_byte(out, 32) != 0) { return -1; }
      if (codegen_append_byte(out, 97) != 0) { return -1; }
      if (format_uint(out, extra_i) != 0) { return -1; }
      extra_i = extra_i + 1;
    }
    /* "); }\n" — 5 bytes. */
    let close_end: u8[5] = [41, 59, 32, 125, 10];
    if (codegen_emit_bytes_from_ptr(out, &close_end[0], 5) != 0) {
      return -1;
    }
    return 1;
  }
}

/**
 * F3/F4: Build the vtable for a concrete->dyn Trait coerce and emit it as the
 * `.vtable = ...` field of the `(struct xlang_dyn_obj){...}` compound literal.
 *
 * F4 fast path: when rhs_rt is NAMED (or PTR-to-NAMED), the vtable is
 * referenced from the module-level static emitted by
 * `codegen_emit_module_vtable_statics` (`.vtable = xlang_vtable_<T>_for_<U>`)
 * instead of an inline compound literal. This shares the vtable across all
 * coerce sites for the same (Trait, Type) pair and enables multiple impls of
 * the same trait to coexist. F6: builtin for-types also reference the
 * static vtable (codegen_emit_module_vtable_statics now emits builtins).
 *
 * F3 inline fallback: resolves the trait name from `lt_dyn`, enumerates the
 * trait's methods via `xlang_skip_trait_method_count_c` +
 * `xlang_skip_trait_method_name_into_c`, and for each method looks up the impl
 * function via `codegen_find_impl_method_for_type` (single resolution
 * authority, G.7). Emits `((void*[]){ (void*)&<prefix><link>, ... })` when
 * methods exist, or `((void*)0)` when the trait has 0 methods (degenerate).
 * Each slot uses `(void*)0` if no impl is found for that method.
 *
 * Single authority for vtable close emit: the 3 coerce sites (assign, pre-let,
 * stmt-order let) all call this helper to avoid triplicating the build logic
 * (G.7 no duplicate implementation).
 *
 * @param arena AST arena
 * @param out codegen output buffer
 * @param ctx pipeline dep ctx (for module + prefix; if null, falls back to
 *        NULL vtable since impl lookup needs the module)
 * @param lt_dyn TYPE_DYN type_ref (trait name source)
 * @param rhs_rt concrete receiver type_ref (impl lookup target)
 * @return 0 on success, -1 on emit failure
 * PLATFORM: SHARED — mirrors seeds/codegen_gen.linux.x86_64.c.
 */
export function codegen_emit_dyn_vtable_close(arena: *ASTArena, out: *CodegenOutBuf,
        ctx: *PipelineDepCtx, lt_dyn: i32, rhs_rt: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /*
     * Degenerate close: "), .vtable = ((void*)0) }" — 25 bytes. Emitted when
     * trait name is unresolvable, method count is 0, or ctx/module is missing
     * (impl lookup impossible). Preserves the F2 NULL-vtable behavior.
     */
    let dyn_null_close: u8[25] = [41, 44, 32, 46, 118, 116, 97, 98, 108, 101, 32, 61, 32,
            40, 40, 118, 111, 105, 100, 42, 41, 48, 41, 32, 125];
    /* Resolve trait name from the dyn type. */
    let trait_nm: u8[64] = [];
    let trait_nlen: i32 = pipeline_type_named_name_into(arena, lt_dyn, &trait_nm[0]);
    if (trait_nlen <= 0) {
      return codegen_emit_bytes_from_ptr(out, &dyn_null_close[0], 25);
    }
    let meth_count: i32 = xlang_skip_trait_method_count_c(&trait_nm[0], trait_nlen);
    if (meth_count <= 0 || ctx == 0 as *PipelineDepCtx
        || ctx.current_codegen_module == 0 as *Module || rhs_rt <= 0) {
      return codegen_emit_bytes_from_ptr(out, &dyn_null_close[0], 25);
    }
    /*
     * F4 fast path: if rhs_rt is NAMED (or PTR-to-NAMED), reference the
     * module-level static vtable emitted by codegen_emit_module_vtable_statics
     * instead of building an inline compound literal. This shares the vtable
     * across all coerce sites for the same (Trait, Type) pair and enables
     * multiple impls of the same trait to coexist (the static has a stable
     * name). F6: builtin for-types also reference the static vtable.
     * PLATFORM: SHARED — the static is emitted by the same .x/seed pin.
     */
    let NAMED_KIND: i32 = 8;
    let PTR_KIND: i32 = 9;
    let recv_kind: i32 = pipeline_type_kind_ord_at(arena, rhs_rt);
    let name_rt: i32 = rhs_rt;
    let is_ptr: i32 = 0;
    if (recv_kind == PTR_KIND) {
      /* PTR-to-?: unwrap elem and check it is NAMED. */
      let elem_rt: i32 = pipeline_type_elem_ref_at(arena, rhs_rt);
      if (elem_rt > 0 && pipeline_type_kind_ord_at(arena, elem_rt) == NAMED_KIND) {
        is_ptr = 1;
        name_rt = elem_rt;
      } else {
        /* PTR-to-builtin: inline path handles it below. */
        name_rt = 0;
      }
    } else if (recv_kind != NAMED_KIND) {
      /*
       * F6: Builtin receiver — reference the module-level static vtable
       * emitted by codegen_emit_module_vtable_statics (which now handles
       * builtin for-types). The coerce site emits "&((<C-type>){RHS" for
       * by-value builtin RHS (compound literal, since & needs an lvalue);
       * this close must prepend "}" to close the compound literal before
       * the normal "), .vtable = <static> }" close. If name synthesis
       * fails (unrecognized kind), fall through to the F3 inline path.
       * PLATFORM: SHARED — seed codegen_gen.linux.x86_64.c mirrors.
       */
      let bnm: u8[16] = [];
      let blen: i32 = codegen_builtin_type_name_into(recv_kind, &bnm[0]);
      if (blen > 0) {
        /* "}" — 1 byte: close the compound literal "{RHS". */
        if (codegen_append_byte(out, 125) != 0) { return -1; }
        /* "), .vtable = " — 13 bytes (close outer paren + field + assign). */
        let vt_ref_prefix: u8[13] = [41, 44, 32, 46, 118, 116, 97, 98, 108, 101, 32, 61, 32];
        if (codegen_emit_bytes_from_ptr(out, &vt_ref_prefix[0], 13) != 0) {
          return -1;
        }
        /* Emit the canonical static name (G.7 single authority for naming). */
        if (codegen_emit_vtable_static_name(out, &trait_nm[0], trait_nlen,
                &bnm[0], blen, 0) != 0) {
          return -1;
        }
        /* " }" — 2 bytes (compound literal close). */
        let vt_ref_close: u8[2] = [32, 125];
        return codegen_emit_bytes_from_ptr(out, &vt_ref_close[0], 2);
      }
      /* Not a recognized builtin: inline path handles it below. */
      name_rt = 0;
    }
    if (name_rt > 0) {
      /* Resolve for-type name from the NAMED type_ref. */
      let for_nm: u8[64] = [];
      let for_nlen: i32 = pipeline_type_named_name_into(arena, name_rt, &for_nm[0]);
      if (for_nlen > 0) {
        /* Emit "), .vtable = " — 13 bytes (compound literal field + assign). */
        let vt_ref_prefix: u8[13] = [41, 44, 32, 46, 118, 116, 97, 98, 108, 101, 32, 61, 32];
        if (codegen_emit_bytes_from_ptr(out, &vt_ref_prefix[0], 13) != 0) {
          return -1;
        }
        /* Emit the canonical static name (G.7 single authority for naming). */
        if (codegen_emit_vtable_static_name(out, &trait_nm[0], trait_nlen,
                &for_nm[0], for_nlen, is_ptr) != 0) {
          return -1;
        }
        /* Emit " }" — 2 bytes (compound literal close). */
        let vt_ref_close: u8[2] = [32, 125];
        return codegen_emit_bytes_from_ptr(out, &vt_ref_close[0], 2);
      }
    }
    /*
     * F3 inline fallback: emit "), .vtable = ((void*[]){ " — 25 bytes
     * (vtable array open). Reached when name synthesis fails (unrecognized
     * builtin kind) or for-type name is unresolvable.
     */
    let vt_open: u8[25] = [41, 44, 32, 46, 118, 116, 97, 98, 108, 101, 32, 61, 32,
            40, 40, 118, 111, 105, 100, 42, 91, 93, 41, 123, 32];
    if (codegen_emit_bytes_from_ptr(out, &vt_open[0], 25) != 0) {
      return -1;
    }
    let cur_mod: *Module = ctx.current_codegen_module;
    let slot_i: i32 = 0;
    while (slot_i < meth_count) {
      /* Separator: ", " before slot 1..N (slot 0 has no leading separator). */
      if (slot_i > 0) {
        let sep: u8[2] = [44, 32];
        if (codegen_emit_bytes_from_ptr(out, &sep[0], 2) != 0) {
          return -1;
        }
      }
      /*
       * F4: per-slot payload delegated to codegen_emit_vtable_slot_payload
       * (G.7 single authority for slot emission — shared with the static
       * vtable emitter and the inline fallback path).
       */
      if (codegen_emit_vtable_slot_payload(out, arena, cur_mod, ctx,
              &trait_nm[0], trait_nlen, slot_i, rhs_rt) != 0) {
        return -1;
      }
      slot_i = slot_i + 1;
    }
    /* Emit " }) }" — 5 bytes (vtable array close + compound literal close). */
    let vt_close: u8[5] = [32, 125, 41, 32, 125];
    return codegen_emit_bytes_from_ptr(out, &vt_close[0], 5);
  }
}

/**
 * F4: Emit module-level static vtable variables for every `impl Trait for Type`
 * with a NAMED for-type (incl. PTR-to-NAMED). Each static is named
 * `xlang_vtable_<Trait>_for_[Ptr_]<Type>` and contains a function-pointer
 * array indexed by trait method declaration order (slot 0 = first method).
 *
 * Called from the codegen main flow after the forward-prototypes wall and
 * before top_level_lets, so function declarations are visible (link names
 * resolve) and lets that may reference vtables come after. Only emitted for
 * the current module (dep_index < 0); dep modules emit their own statics in
 * their own pass — no cross-module name collision in a co-emitted TU.
 *
 * For each impl block, the for-type name is reconstructed into a type_ref via
 * `pipeline_type_find_or_alloc_named` (+ `pipeline_type_find_or_alloc_compound`
 * for PTR-to-NAMED) so the existing `codegen_find_impl_method_for_type` can be
 * reused (single G.7 authority for impl method lookup). Non-NAMED for-types
 * (builtin) are skipped — coerce sites fall back to the F3 inline path.
 *
 * Trait/type names are sanitized to valid C identifiers (non-alnum → '_').
 *
 * @param arena AST arena.
 * @param out codegen output buffer.
 * @param ctx pipeline dep ctx (for module + prefix).
 * @return 0 on success, -1 on emit failure.
 * PLATFORM: SHARED — mirrors seeds/codegen_gen.linux.x86_64.c.
 */
export function codegen_emit_module_vtable_statics(arena: *ASTArena, out: *CodegenOutBuf,
        ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
      return 0;
    }
    let cur_mod: *Module = ctx.current_codegen_module;
    let n_impl: i32 = xlang_skip_impl_seen_count_c();
    if (n_impl <= 0) {
      return 0;
    }
    /* Kind ordinals (align XLANG_TRAIT_TY_* in parser_asm_skip_tl_slice.inc). */
    let NAMED_KIND: i32 = 8;
    let PTR_KIND: i32 = 9;
    /* Byte literals for static vtable framing (name payload emitted by
     * codegen_emit_vtable_static_name — G.7 single authority). */
    /* "static void* " — 13 bytes. */
    let static_kw: u8[13] = [115, 116, 97, 116, 105, 99, 32, 118, 111, 105, 100, 42, 32];
    /* "[] = { " — 7 bytes. */
    let arr_open: u8[7] = [91, 93, 32, 61, 32, 123, 32];
    /* " };\n" — 4 bytes. */
    let arr_close: u8[4] = [32, 125, 59, 10];
    /* ", " — 2 bytes separator. */
    let sep: u8[2] = [44, 32];
    let si: i32 = 0;
    while (si < n_impl) {
      /* Read impl block's trait name + for-type info. */
      let trait_nm: u8[64] = [];
      let trait_nlen: i32 = xlang_skip_impl_trait_name_into_c(si, &trait_nm[0]);
      if (trait_nlen <= 0) {
        si = si + 1;
        continue;
      }
      let for_k: i32 = 0;
      let for_ptr: i32 = 0;
      let for_nm: u8[64] = [];
      let for_nlen: i32 = 0;
      if (xlang_skip_impl_for_type_into_c(si, &for_k, &for_ptr, &for_nm[0], &for_nlen) == 0) {
        si = si + 1;
        continue;
      }
      /*
       * F6: route builtin for-types through the same static-vtable path as
       * NAMED. The impl registry stores builtin for-types with an EMPTY name
       * (only for_k survives — see xlang_skip_impl_for_type_into_c), so
       * synthesize the canonical X name (i32/f64/...) via the single-authority
       * codegen_builtin_type_name_into before feeding the naming helpers, and
       * construct recv_rt via find_or_alloc_compound (builtins have no name
       * to feed find_or_alloc_named). PTR-to-builtin (`impl T for *i32`) is
       * left to a later wave; only by-value builtin for-types are handled here.
       * NAMED for-types keep the F4 path (name + optional PTR wrap).
       */
      let is_builtin: i32 = 0;
      if (for_nlen <= 0) {
        let blen: i32 = codegen_builtin_type_name_into(for_k, &for_nm[0]);
        if (blen <= 0) {
          si = si + 1;
          continue;
        }
        for_nlen = blen;
        is_builtin = 1;
      }
      let recv_rt: i32 = 0;
      if (is_builtin != 0) {
        recv_rt = pipeline_type_find_or_alloc_compound(arena, for_k, 0, 0);
      } else {
        recv_rt = pipeline_type_find_or_alloc_named(arena, &for_nm[0], for_nlen);
      }
      if (recv_rt <= 0) {
        si = si + 1;
        continue;
      }
      if (for_ptr != 0) {
        recv_rt = pipeline_type_find_or_alloc_compound(arena, PTR_KIND, recv_rt, 0);
        if (recv_rt <= 0) {
          si = si + 1;
          continue;
        }
      }
      let meth_count: i32 = xlang_skip_trait_method_count_c(&trait_nm[0], trait_nlen);
      if (meth_count <= 0) {
        si = si + 1;
        continue;
      }
      /*
       * F5+: Emit wrapper function definitions before the vtable static.
       * Wrappers adapt the uniform void* data dispatch arg to the impl
       * method's self type (deref for by-value, cast for pointer).
       * Without wrappers, by-value self methods receive a pointer where
       * they expect a value (root cause of F3 false-green).
       */
      let has_impl: i32[64] = [];
      let wi: i32 = 0;
      while (wi < meth_count && wi < 64) {
        let rc: i32 = codegen_emit_vtable_wrapper_def(out, arena, cur_mod, ctx,
                &trait_nm[0], trait_nlen, &for_nm[0], for_nlen, for_ptr,
                wi, recv_rt);
        if (rc < 0) { return -1; }
        has_impl[wi] = rc;
        wi = wi + 1;
      }
      /* Emit "static void* ". */
      if (codegen_emit_bytes_from_ptr(out, &static_kw[0], 13) != 0) {
        return -1;
      }
      /*
       * Emit the canonical vtable static name via the shared helper (G.7
       * single authority for vtable naming — coerce sites reference the
       * same name). Sanitize is owned by the helper, not duplicated here.
       */
      if (codegen_emit_vtable_static_name(out, &trait_nm[0], trait_nlen,
              &for_nm[0], for_nlen, for_ptr) != 0) {
        return -1;
      }
      /* Emit "[] = { ". */
      if (codegen_emit_bytes_from_ptr(out, &arr_open[0], 7) != 0) {
        return -1;
      }
      /*
       * F5+: Each slot references the wrapper function (not the direct impl
       * method), so the void* data dispatch arg is adapted to the method's
       * self type. Slots without an impl emit (void*)0 (null placeholder).
       */
      let slot_i: i32 = 0;
      while (slot_i < meth_count && slot_i < 64) {
        if (slot_i > 0) {
          if (codegen_emit_bytes_from_ptr(out, &sep[0], 2) != 0) {
            return -1;
          }
        }
        if (has_impl[slot_i] != 0) {
          /* "(void*)&" — 8 bytes. */
          let addr_cast: u8[8] = [40, 118, 111, 105, 100, 42, 41, 38];
          if (codegen_emit_bytes_from_ptr(out, &addr_cast[0], 8) != 0) {
            return -1;
          }
          if (codegen_emit_vtable_wrapper_name(out, &trait_nm[0], trait_nlen,
                  &for_nm[0], for_nlen, for_ptr, slot_i) != 0) {
            return -1;
          }
        } else {
          /* "(void*)0" — 8 bytes, null placeholder. */
          let null_slot: u8[8] = [40, 118, 111, 105, 100, 42, 41, 48];
          if (codegen_emit_bytes_from_ptr(out, &null_slot[0], 8) != 0) {
            return -1;
          }
        }
        slot_i = slot_i + 1;
      }
      /* Emit " };\n". */
      if (codegen_emit_bytes_from_ptr(out, &arr_close[0], 4) != 0) {
        return -1;
      }
      si = si + 1;
    }
    return 0;
  }
}

/**
 * Emit monomorphized C instances for a generic function (wave443–450).
 *
 * wave443–444: multi-arg + mangled combos for identity shape `fn(x: T): T`.
 * wave445: real body AST walk (method calls / lets) under mono_active.
 * wave447: drop the hard identity gate (ret and param0 both TYPE_NAMED with the
 * same name). Non-identity shapes such as `getv<T>(x: T): i32 { return x.v; }`
 * and `absdiff<T>(x: i32, y: i32): i32 { if ... }` must also emit mono instances
 * because call sites already mangle with `__suffix`; without a definition, host
 * C fails BLD001 undeclared. Signature emit now uses the original ret/param
 * type_refs under mono_active so C5 subst rewrites T→concrete while leaving
 * builtins (i32, …) unchanged — identity used to emit ret type as mono_ty
 * (param0 concrete), which is wrong when ret is not T.
 * wave450: zero value-param generics (`unit_t<T>(): i32`). Parser stores only
 * `call_num_type_args` (count), not type-arg type_refs; call-site C3 mangling
 * therefore falls back to the bare link name when `num_params==0`. Prior mono
 * emit hard-gated `num_params<=0` → no definition → BLD001 undeclared. Root
 * fix: when `num_params==0` and at least one matching CALL exists, emit the
 * body once under the bare link name (phantom T; all type-arg combos share
 * one C function). Leave-off: bare `unit_t()` without turbofish (typeck still
 * requires type args); zero-arg body/return that need T subst without stored
 * type-arg refs (ret `T` / `let x: T` mono map).
 *
 * @param arena *ASTArena — shared AST arena for type_ref / expr walk
 * @param out *CodegenOutBuf — C text buffer
 * @param module *Module — owning module of fi
 * @param fi i32 — function index (generic; value params 0..8)
 * @param prefix *u8 — module C prefix bytes
 * @param prefix_len i32 — prefix length
 * @param ctx *PipelineDepCtx — mono_active / mono_* type maps (SHARED ABI)
 * @return i32 — 1 if at least one mono instance was emitted, 0 skip, -1 emit error
 * PLATFORM: SHARED — seed codegen_gen.linux.x86_64.c must match same commit.
 */
export function codegen_try_emit_generic_identity_mono(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || module == 0 as *Module) {
      return 0;
    }
    if (fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    if (pipeline_module_func_num_generic_params_at(module, fi) <= 0) {
      return 0;
    }
    if (pipeline_module_func_is_extern_at(module, fi) != 0) {
      return 0;
    }
    let num_params: i32 = pipeline_module_func_num_params_at(module, fi);
    if (num_params < 0 || num_params > 8) {
      return 0;
    }
    let ret_ty: i32 = pipeline_module_func_return_type_at(module, fi);
    let p0_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, 0);
    /*
     * wave450 Cap residual: zero value-param generic mono under bare link name
     * when ret is **not** a type-param (phantom T, e.g. unit_t<T>():i32).
     * wave458: when ret IS an uncovered type-param (`mk<T>():T`), do **not**
     * take this bare single-instance path — fall through to multi-combo emit
     * with ret_extra mono key (mk__A / mk__B). Call-site mangle agrees.
     * PLATFORM: SHARED — mirrors seed codegen_gen.linux.x86_64.c.
     */
    let ret_extra_zp: i32 = codegen_func_ret_type_param_extra(arena, module, fi);
    if (num_params == 0 && ret_extra_zp == 0) {
      if (ret_ty <= 0) {
        return 0;
      }
      let fn_local0: u8[256] = [];
      codegen_copy_func_name64_from_module(module, fi, &fn_local0[0]);
      let fn_len0: i32 = pipeline_module_func_name_len_at(module, fi);
      if (fn_len0 <= 0) {
        return 0;
      }
      let has_call: i32 = 0;
      let ei0: i32 = 1;
      while (ei0 <= arena.num_exprs) {
        let e0: Expr = ast.ast_arena_expr_get(arena, ei0);
        if ((e0.kind as i32) == (ExprKind.EXPR_CALL as i32)) {
          let matched0: i32 = 0;
          if (e0.call_resolved_func_index == fi) {
            matched0 = 1;
          } else {
            if (!ast.ref_is_null(e0.call_callee_ref) && e0.call_callee_ref > 0
                && e0.call_callee_ref <= arena.num_exprs) {
              let cal0: Expr = ast.ast_arena_expr_get(arena, e0.call_callee_ref);
              if ((cal0.kind as i32) == (ExprKind.EXPR_VAR as i32) && cal0.var_name_len == fn_len0) {
                let eq0: i32 = 1;
                let k0: i32 = 0;
                while (k0 < fn_len0) {
                  if (cal0.var_name[k0] != fn_local0[k0]) {
                    eq0 = 0;
                    k0 = fn_len0;
                  } else {
                    k0 = k0 + 1;
                  }
                }
                matched0 = eq0;
              }
            }
          }
          if (matched0 != 0) {
            has_call = 1;
            ei0 = arena.num_exprs;
          }
        }
        ei0 = ei0 + 1;
      }
      if (has_call == 0) {
        return 0;
      }
      let mono_sym_pre0: i32 = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
      let saved_func_index0: i32 = -1;
      let saved_block_ref0: i32 = 0;
      let saved_mono_active0: i32 = 0;
      let saved_mono_num0: i32 = 0;
      let ctx_set0: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx) {
        saved_func_index0 = ctx.current_func_index;
        saved_block_ref0 = ctx.current_block_ref;
        saved_mono_active0 = ctx.mono_active;
        saved_mono_num0 = ctx.mono_num_types;
        ctx.current_func_index = fi;
        /*
         * wave452: zero-param ret type-param mono (mk_default<T>():T).
         * Wave450 emitted phantom T without mono_active → host C returns
         * struct T while body builds concrete A. Map T from turbofish /
         * call resolved_type_ref of a matching CALL.
         * wave456: prefer call_resolved_func_index==fi (typeck-resolved site).
         * Name-only matches with rfi=-1 can be earlier arena ghosts that still
         * carry turbofish type_args but never received fixup — using them made
         * `mk2u<T,U>():U` mono map U→type_arg[0] (T) → BLD001. Two-pass scan:
         * (1) rfi==fi only (2) name match only if concrete_at returns >0.
         * PLATFORM: SHARED — one bare link name still shared (leave-off:
         * multi distinct T combos under bare name).
         */
        let ret_ord0: i32 = pipeline_type_kind_ord_at(arena, ret_ty);
        if (ret_ord0 == 8) {
          let ta0: i32 = 0;
          let ei_ta: i32 = 1;
          /* Pass 1: only typeck-resolved call sites (rfi == fi). */
          while (ei_ta <= arena.num_exprs && ta0 <= 0) {
            let e_ta: Expr = ast.ast_arena_expr_get(arena, ei_ta);
            if ((e_ta.kind as i32) == (ExprKind.EXPR_CALL as i32) && e_ta.call_resolved_func_index == fi) {
              ta0 = codegen_call_ret_type_param_concrete_at(arena, ei_ta);
            }
            ei_ta = ei_ta + 1;
          }
          /* Pass 2: name-only fallback when rfi was never stamped. */
          if (ta0 <= 0) {
            ei_ta = 1;
            while (ei_ta <= arena.num_exprs && ta0 <= 0) {
              let e_ta2: Expr = ast.ast_arena_expr_get(arena, ei_ta);
              if ((e_ta2.kind as i32) == (ExprKind.EXPR_CALL as i32) && e_ta2.call_resolved_func_index != fi) {
                if (!ast.ref_is_null(e_ta2.call_callee_ref) && e_ta2.call_callee_ref > 0
                    && e_ta2.call_callee_ref <= arena.num_exprs) {
                  let cal_ta: Expr = ast.ast_arena_expr_get(arena, e_ta2.call_callee_ref);
                  if ((cal_ta.kind as i32) == (ExprKind.EXPR_VAR as i32) && cal_ta.var_name_len == fn_len0) {
                    let eq_ta: i32 = 1;
                    let k_ta: i32 = 0;
                    while (k_ta < fn_len0) {
                      if (cal_ta.var_name[k_ta] != fn_local0[k_ta]) {
                        eq_ta = 0;
                        k_ta = fn_len0;
                      } else {
                        k_ta = k_ta + 1;
                      }
                    }
                    if (eq_ta != 0) {
                      ta0 = codegen_call_ret_type_param_concrete_at(arena, ei_ta);
                    }
                  }
                }
              }
              ei_ta = ei_ta + 1;
            }
          }
          if (ta0 > 0 && ta0 != ret_ty) {
            ctx.mono_active = 1;
            ctx.mono_num_types = 1;
            ctx.mono_generic_type_refs[0] = ret_ty;
            ctx.mono_concrete_type_refs[0] = ta0;
          }
        }
        ctx_set0 = 1;
      }
      /* Signature: <ret> <link_name>(void) { body } — mono_active when ret is type param. */
      if (codegen_emit_type(arena, out, ret_ty, prefix, prefix_len, ctx) != 0) {
        if (ctx_set0 != 0) {
          ctx.current_func_index = saved_func_index0;
          ctx.current_block_ref = saved_block_ref0;
          ctx.mono_active = saved_mono_active0;
          ctx.mono_num_types = saved_mono_num0;
        }
        return -1;
      }
      if (codegen_append_byte(out, 32) != 0) {
        if (ctx_set0 != 0) {
          ctx.current_func_index = saved_func_index0;
          ctx.current_block_ref = saved_block_ref0;
          ctx.mono_active = saved_mono_active0;
          ctx.mono_num_types = saved_mono_num0;
        }
        return -1;
      }
      if (mono_sym_pre0 > 0
          && codegen_c_prefix_redundant_with_name(prefix, mono_sym_pre0, &fn_local0[0], fn_len0) == 0) {
        if (codegen_emit_bytes_from_ptr(out, prefix, mono_sym_pre0) != 0) {
          if (ctx_set0 != 0) {
            ctx.current_func_index = saved_func_index0;
            ctx.current_block_ref = saved_block_ref0;
            ctx.mono_active = saved_mono_active0;
            ctx.mono_num_types = saved_mono_num0;
          }
          return -1;
        }
      }
      if (codegen_emit_func_link_name(out, arena, module, fi) != 0) {
        if (ctx_set0 != 0) {
          ctx.current_func_index = saved_func_index0;
          ctx.current_block_ref = saved_block_ref0;
          ctx.mono_active = saved_mono_active0;
          ctx.mono_num_types = saved_mono_num0;
        }
        return -1;
      }
      /* `() {\n` */
      let open0: u8[4] = [40, 41, 32, 123];
      if (codegen_emit_bytes_from_ptr(out, &open0[0], 4) != 0) {
        if (ctx_set0 != 0) {
          ctx.current_func_index = saved_func_index0;
          ctx.current_block_ref = saved_block_ref0;
          ctx.mono_active = saved_mono_active0;
          ctx.mono_num_types = saved_mono_num0;
        }
        return -1;
      }
      if (codegen_append_byte(out, 10) != 0) {
        if (ctx_set0 != 0) {
          ctx.current_func_index = saved_func_index0;
          ctx.current_block_ref = saved_block_ref0;
          ctx.mono_active = saved_mono_active0;
          ctx.mono_num_types = saved_mono_num0;
        }
        return -1;
      }
      let body_walked0: i32 = 0;
      let body_br0: i32 = pipeline_module_func_body_ref_at(module, fi);
      let body_er0: i32 = pipeline_module_func_body_expr_ref_at(module, fi);
      if (!ast.ref_is_null(body_br0) || !ast.ref_is_null(body_er0)) {
        if (!ast.ref_is_null(body_br0)) {
          if (ctx_set0 != 0) {
            ctx.current_block_ref = body_br0;
          }
          if (codegen_emit_block(arena, out, body_br0, 2, ctx) == 0) {
            body_walked0 = 1;
          }
        } else {
          if (ctx_set0 != 0) {
            ctx.current_block_ref = 0;
          }
          if (codegen_emit_indent(out, 2) == 0) {
            let ret_kw0: u8[8] = [114, 101, 116, 117, 114, 110, 32, 0];
            if (codegen_emit_bytes_from_ptr(out, &ret_kw0[0], 7) == 0) {
              if (codegen_emit_expr(arena, out, body_er0, ctx) == 0) {
                let sc_nl0: u8[2] = [59, 10];
                if (codegen_emit_bytes_from_ptr(out, &sc_nl0[0], 2) == 0) {
                  body_walked0 = 1;
                }
              }
            }
          }
        }
      }
      if (body_walked0 == 0) {
        /* Defensive stub if body walk fails (keeps host C compilable). */
        if (codegen_emit_indent(out, 2) != 0) {
          if (ctx_set0 != 0) {
            ctx.current_func_index = saved_func_index0;
            ctx.current_block_ref = saved_block_ref0;
            ctx.mono_active = saved_mono_active0;
            ctx.mono_num_types = saved_mono_num0;
          }
          return -1;
        }
        let ret0z: u8[10] = [114, 101, 116, 117, 114, 110, 32, 48, 59, 10];
        if (codegen_emit_bytes_from_ptr(out, &ret0z[0], 10) != 0) {
          if (ctx_set0 != 0) {
            ctx.current_func_index = saved_func_index0;
            ctx.current_block_ref = saved_block_ref0;
            ctx.mono_active = saved_mono_active0;
            ctx.mono_num_types = saved_mono_num0;
          }
          return -1;
        }
      }
      if (ctx_set0 != 0) {
        ctx.current_func_index = saved_func_index0;
        ctx.current_block_ref = saved_block_ref0;
        ctx.mono_active = saved_mono_active0;
        ctx.mono_num_types = saved_mono_num0;
      }
      let end0: u8[2] = [125, 10];
      if (codegen_emit_bytes_from_ptr(out, &end0[0], 2) != 0) {
        return -1;
      }
      return 1;
    }
    /* wave458: zero-param ret-only has no p0; only require ret_ty. */
    if (ret_ty <= 0) {
      return 0;
    }
    if (num_params > 0 && p0_ty <= 0) {
      return 0;
    }
    /*
     * wave447: no longer require identity shape (ret and p0 both TYPE_NAMED
     * with equal names). Call-site mono mangling is independent of that shape;
     * skipping emit here leaves undeclared mangled symbols (BLD001).
     * Identity shape is still detected later only to choose body fallback.
     */
    let is_identity_shape: i32 = 0;
    if (num_params > 0
        && pipeline_type_kind_ord_at(arena, ret_ty) == (TypeKind.TYPE_NAMED as i32)
        && pipeline_type_kind_ord_at(arena, p0_ty) == (TypeKind.TYPE_NAMED as i32)) {
      let ret_nm: u8[256] = [];
      let p0_nm: u8[256] = [];
      let ret_nl: i32 = pipeline_type_named_name_into(arena, ret_ty, &ret_nm[0]);
      let p0_nl: i32 = pipeline_type_named_name_into(arena, p0_ty, &p0_nm[0]);
      if (ret_nl > 0 && ret_nl == p0_nl) {
        let bi: i32 = 0;
        let names_eq: i32 = 1;
        while (bi < ret_nl) {
          if (ret_nm[bi] != p0_nm[bi]) {
            names_eq = 0;
            bi = ret_nl;
          } else {
            bi = bi + 1;
          }
        }
        if (names_eq != 0) {
          is_identity_shape = 1;
        }
      }
    }
    /* wave444: collect ALL unique (func, type-args) combos so each call site with
     * a distinct type gets its own mangled mono instance (e.g., copy<A> + copy<i32>
     * emit copy__A and copy__i32). Previously only the first call site's type was
     * emitted with the bare link name, causing duplicate-symbol errors when multiple
     * type-arg combos targeted the same generic function.
     * wave458: ret_extra appends uncovered ret type-param concrete to the key
     * (`as_t__i32_A` vs `as_t__i32_B`; zero-param `mk__A` / `mk__B`). */
    let ret_extra: i32 = ret_extra_zp;
    let combo_width: i32 = num_params + ret_extra;
    if (combo_width <= 0 || combo_width > 8) {
      return 0;
    }
    let combos: i32[128] = [];
    let combo_count: i32 = codegen_collect_mono_combos_for_generic_func(arena, module, fi, &combos[0], 16, num_params, ret_extra);
    if (combo_count <= 0) {
      return 0;
    }
    let pn_len: i32 = 1;
    let pn: u8[256] = [];
    pn[0] = 120;
    if (num_params > 0) {
      pn_len = pipeline_module_func_param_name_len_at(module, fi, 0);
      pipeline_module_func_param_name_copy32(module, fi, 0, &pn[0]);
      if (pn_len <= 0) {
        pn[0] = 120;
        pn_len = 1;
      }
    }
    let fn_local: u8[256] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    let mono_sym_pre: i32 = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
    /* wave444/447: one mono instance per unique combo; mangled symbol agrees with
     * call-site codegen_emit_call_func_name. Signature types use original ret/param
     * type_refs under mono_active (C5), not identity-only mono_ty for return. */
    let ci: i32 = 0;
    while (ci < combo_count) {
      /*
       * Activate mono substitution for this combo before signature emit so
       * codegen_emit_type rewrites TYPE_NAMED generic params (T) to concrete types
       * while leaving i32/bool/… unchanged. Restored after body (or on error
       * paths that return -1 after this point must restore — we restore after
       * each combo's body section below).
       */
      let saved_mono_active: i32 = 0;
      let saved_mono_num: i32 = 0;
      let saved_func_index: i32 = -1;
      let saved_block_ref: i32 = 0;
      let mono_ctx_set: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx) {
        saved_mono_active = ctx.mono_active;
        saved_mono_num = ctx.mono_num_types;
        saved_func_index = ctx.current_func_index;
        saved_block_ref = ctx.current_block_ref;
        ctx.mono_active = 1;
        ctx.mono_num_types = 0;
        /* Value formals: map each formal type_ref → combo slot (identity T→A). */
        let sti0: i32 = 0;
        while (sti0 < num_params && sti0 < 8) {
          ctx.mono_generic_type_refs[sti0] = pipeline_module_func_param_type_ref_at(module, fi, sti0);
          ctx.mono_concrete_type_refs[sti0] = combos[ci * combo_width + sti0];
          sti0 = sti0 + 1;
        }
        ctx.mono_num_types = num_params;
        /*
         * wave688 Cap residual: peel free TYPE_NAMED leaves out of compound
         * formals (*T / **T / []T / T[N]) into the mono map.
         * Top-level formal→combo alone only rewrites type_ref-equal nodes (the
         * param decl hits; a distinct ret *T node does not) → codegen_emit_type falls
         * through to `struct T *` while formals already emit `int32_t *`.
         * Peel walks matching PTR/SLICE/ARRAY/VECTOR pairs and appends
         * free-elem → concrete-elem so codegen_emit_type name-match (wave445 C5) rewrites
         * nested T in ret + body. Depth cap 4; map cap 8.
         * PLATFORM: SHARED — seed codegen_gen same commit (G.7).
         */
        {
          let peel_src: i32 = 0;
          let peel_n0: i32 = ctx.mono_num_types;
          while (peel_src < peel_n0 && ctx.mono_num_types < 8) {
            let gwalk: i32 = ctx.mono_generic_type_refs[peel_src];
            let cwalk: i32 = ctx.mono_concrete_type_refs[peel_src];
            let pdepth: i32 = 0;
            while (gwalk > 0 && cwalk > 0 && pdepth < 4 && ctx.mono_num_types < 8) {
              let gk: i32 = pipeline_type_kind_ord_at(arena, gwalk);
              let ck: i32 = pipeline_type_kind_ord_at(arena, cwalk);
              if (gk != ck) {
                pdepth = 4;
              } else if (gk == TypeKind.TYPE_PTR as i32 || gk == TypeKind.TYPE_SLICE as i32
                  || gk == TypeKind.TYPE_ARRAY as i32 || gk == TypeKind.TYPE_VECTOR as i32) {
                let ge: i32 = pipeline_type_elem_ref_at(arena, gwalk);
                let ce: i32 = pipeline_type_elem_ref_at(arena, cwalk);
                if (ge <= 0 || ce <= 0) {
                  pdepth = 4;
                } else if (pipeline_type_kind_ord_at(arena, ge) == (TypeKind.TYPE_NAMED as i32)) {
                  /* Free or named leaf: append ge→ce if not already mapped. */
                  let dup_p: i32 = 0;
                  let di_p: i32 = 0;
                  while (di_p < ctx.mono_num_types) {
                    if (ctx.mono_generic_type_refs[di_p] == ge) {
                      dup_p = 1;
                      di_p = ctx.mono_num_types;
                    } else {
                      di_p = di_p + 1;
                    }
                  }
                  if (dup_p == 0 && ctx.mono_num_types < 8) {
                    ctx.mono_generic_type_refs[ctx.mono_num_types] = ge;
                    ctx.mono_concrete_type_refs[ctx.mono_num_types] = ce;
                    ctx.mono_num_types = ctx.mono_num_types + 1;
                  }
                  /* Keep peeling for **T (ge may itself be PTR). */
                  gwalk = ge;
                  cwalk = ce;
                  pdepth = pdepth + 1;
                } else {
                  /*
                   * wave689: also map intermediate free compounds ([]T inside *[]T).
                   * Without this, mono only has *[]T→*[]i32 and T→i32; ret *[]T peels
                   * to codegen_emit_type([]T) with a distinct free []T node that never identity-
                   * matches formal's *[]T entry → incomplete `struct xlang_slice_<mod>_T *`.
                   * PLATFORM: SHARED host-C.
                   */
                  let dup_mid: i32 = 0;
                  let di_mid: i32 = 0;
                  while (di_mid < ctx.mono_num_types) {
                    if (ctx.mono_generic_type_refs[di_mid] == ge) {
                      dup_mid = 1;
                      di_mid = ctx.mono_num_types;
                    } else {
                      di_mid = di_mid + 1;
                    }
                  }
                  if (dup_mid == 0 && ctx.mono_num_types < 8) {
                    ctx.mono_generic_type_refs[ctx.mono_num_types] = ge;
                    ctx.mono_concrete_type_refs[ctx.mono_num_types] = ce;
                    ctx.mono_num_types = ctx.mono_num_types + 1;
                  }
                  gwalk = ge;
                  cwalk = ce;
                  pdepth = pdepth + 1;
                }
              } else {
                pdepth = 4;
              }
            }
            peel_src = peel_src + 1;
          }
        }
        /*
         * wave452/458: ret type-param not on any value formal.
         * When ret_extra=1 the combo already ends with ret concrete — stamp map
         * from that slot (authoritative per-combo, not first matching CALL).
         * When ret_extra=0 but ret is still TYPE_NAMED (covered by a formal name),
         * formals already mapped it. Keep legacy scan only if ret_extra and slot set.
         * PLATFORM: SHARED
         */
        if (ret_extra != 0 && ctx.mono_num_types < 8) {
          let ta_conc: i32 = combos[ci * combo_width + num_params];
          if (ta_conc > 0 && ta_conc != ret_ty) {
            ctx.mono_generic_type_refs[ctx.mono_num_types] = ret_ty;
            ctx.mono_concrete_type_refs[ctx.mono_num_types] = ta_conc;
            ctx.mono_num_types = ctx.mono_num_types + 1;
          }
        }
        ctx.current_func_index = fi;
        mono_ctx_set = 1;
      }
      /* Return type: original ret_ty under mono_active (wave447). */
      if (codegen_emit_type(arena, out, ret_ty, prefix, prefix_len, ctx) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      if (codegen_append_byte(out, 32) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      if (mono_sym_pre > 0 && codegen_c_prefix_redundant_with_name(prefix, mono_sym_pre, &fn_local[0], fn_len) == 0) {
        if (codegen_emit_bytes_from_ptr(out, prefix, mono_sym_pre) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
      }
      /* wave444/458: mangled mono symbol (link_name + __ + suffix per combo slot). */
      if (codegen_emit_mono_mangled_name(out, arena, module, fi, &combos[ci * combo_width], combo_width) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      if (codegen_append_byte(out, 40) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      /* wave458: zero-param ret-only → empty param list; open `(` already emitted. */
      if (num_params > 0) {
      /* Param 0 type: original p0_ty under mono_active (T→concrete, i32 stays). */
      if (codegen_emit_type(arena, out, p0_ty, prefix, prefix_len, ctx) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      /*
       * wave687: TYPE_SLICE formals lower as C pointers (`struct xlang_slice_T * name`),
       * matching emit_func / call-arg ABI. Mono previously emitted by-value struct →
       * body `s->data` and call `&(local)` BLD001. PLATFORM: SHARED host-C.
       */
      if (pipeline_type_kind_ord_at(arena, p0_ty) == (TypeKind.TYPE_SLICE as i32)) {
        if (codegen_append_byte(out, 32) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        if (codegen_append_byte(out, 42) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
      }
      if (codegen_append_byte(out, 32) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      if (codegen_emit_bytes_from_ptr(out, &pn[0], pn_len) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      /* Remaining params 1..N-1: original param type_ref under mono_active. */
      let pi: i32 = 1;
      while (pi < num_params) {
        let p_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, pi);
        let comma_space: u8[2] = [44, 32];
        if (codegen_emit_bytes_from_ptr(out, &comma_space[0], 2) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        if (p_ty <= 0 || codegen_emit_type(arena, out, p_ty, prefix, prefix_len, ctx) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        /* wave687: TYPE_SLICE formal → pointer (same as param0). PLATFORM: SHARED. */
        if (p_ty > 0 && pipeline_type_kind_ord_at(arena, p_ty) == (TypeKind.TYPE_SLICE as i32)) {
          if (codegen_append_byte(out, 32) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
          if (codegen_append_byte(out, 42) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
        }
        if (codegen_append_byte(out, 32) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        let pni_len: i32 = pipeline_module_func_param_name_len_at(module, fi, pi);
        let pni: u8[256] = [];
        pipeline_module_func_param_name_copy32(module, fi, pi, &pni[0]);
        if (pni_len <= 0) {
          pni[0] = 120;
          pni_len = 1;
        }
        if (codegen_emit_bytes_from_ptr(out, &pni[0], pni_len) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        pi = pi + 1;
      }
      } /* num_params > 0 */
      /* wave445 C4: emit open body `) {\n` (41=`)` 32=space 123=`{` 10=newline). */
      let open_body: u8[4] = [41, 32, 123, 10];
      if (codegen_emit_bytes_from_ptr(out, &open_body[0], 4) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      /*
       * wave445 C4+C5+C6 + wave447: walk the real body AST under mono_active.
       * Identity-shape fallback `return <param0>;` only when is_identity_shape
       * (ret and param0 are the same TYPE_NAMED generic). Non-identity shapes
       * must succeed at body walk or host C would type-mismatch on fallback.
       * PLATFORM: SHARED — mono context lives in PipelineDepCtx (L4 ABI extension).
       */
      let body_walked: i32 = 0;
      let body_br: i32 = pipeline_module_func_body_ref_at(module, fi);
      let body_er: i32 = pipeline_module_func_body_expr_ref_at(module, fi);
      if (mono_ctx_set != 0 && (!ast.ref_is_null(body_br) || !ast.ref_is_null(body_er))) {
        if (!ast.ref_is_null(body_br)) {
          ctx.current_block_ref = body_br;
          if (codegen_emit_block(arena, out, body_br, 2, ctx) == 0) {
            body_walked = 1;
          }
        } else {
          /* single-expr body: emit `  return <expr>;\n`. */
          ctx.current_block_ref = 0;
          if (codegen_emit_indent(out, 2) == 0) {
            let ret_kw2: u8[8] = [114, 101, 116, 117, 114, 110, 32, 0];
            if (codegen_emit_bytes_from_ptr(out, &ret_kw2[0], 7) == 0) {
              if (codegen_emit_expr(arena, out, body_er, ctx) == 0) {
                let sc_nl: u8[2] = [59, 10];
                if (codegen_emit_bytes_from_ptr(out, &sc_nl[0], 2) == 0) {
                  body_walked = 1;
                }
              }
            }
          }
        }
      }
      if (body_walked == 0) {
        if (is_identity_shape != 0) {
          /* Fallback: identity body `return <param0>;` (wave444 behavior). */
          if (codegen_emit_indent(out, 2) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
          let ret_kw: u8[8] = [114, 101, 116, 117, 114, 110, 32, 0];
          if (codegen_emit_bytes_from_ptr(out, &ret_kw[0], 7) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
          if (codegen_emit_bytes_from_ptr(out, &pn[0], pn_len) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
          let semi_nl: u8[2] = [59, 10];
          if (codegen_emit_bytes_from_ptr(out, &semi_nl[0], 2) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
        } else {
          /*
           * Non-identity body walk failed: still close a stub that returns zero
           * for scalar C types so the mangled symbol exists (avoids BLD001). Prefer
           * real body; this path is defensive when codegen_emit_block fails unexpectedly.
           * PLATFORM: SHARED — host-C only stub; freestanding residual separate.
           */
          if (codegen_emit_indent(out, 2) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
          let ret0: u8[12] = [114, 101, 116, 117, 114, 110, 32, 48, 59, 10, 0, 0];
          if (codegen_emit_bytes_from_ptr(out, &ret0[0], 10) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
        }
      }
      if (mono_ctx_set != 0) {
        ctx.mono_active = saved_mono_active;
        ctx.mono_num_types = saved_mono_num;
        ctx.current_func_index = saved_func_index;
        ctx.current_block_ref = saved_block_ref;
      }
      /* Close function body: `}\n` (125=`}` 10=newline). */
      let end: u8[2] = [125, 10];
      if (codegen_emit_bytes_from_ptr(out, &end[0], 2) != 0) {
        return -1;
      }
      ci = ci + 1;
    }
    return 1;
  }
}

/*
 * wave498: multi-combo generic inherent impl method codegen monomorphization.
 * Why: hoisted impl methods (num_generic_params == 0, <T> on impl not fn) bypass
 * codegen_try_emit_generic_identity_mono. wave495 handled the unique-combo case
 * (nc==1) by setting mono_active in emit_func, but multi-combo (nc>1) still emits
 * a single generic definition with bare `struct T` return type (BLD001). Collect
 * all mono combos from the first free-type-arg param (usually self), then emit
 * one monomorphized definition per combo with a mangled symbol name, matching
 * call-side mangling. Mirrors the loop structure of codegen_try_emit_generic_
 * identity_mono but uses struct-layout combos instead of func-generic combos.
 * PLATFORM: SHARED — seed codegen_gen.linux.x86_64.c same commit.
 * Guards: only activates when num_generic_params==0 AND a param has free type-args
 * AND combo_count>1. All other cases return 0 and fall through to normal emit_func
 * (wave495 unique-combo path or plain emit).
 */
export function codegen_try_emit_generic_impl_method_mono(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || module == 0 as *Module) {
      return 0;
    }
    if (fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    if (pipeline_module_func_num_generic_params_at(module, fi) > 0) {
      return 0;
    }
    if (pipeline_module_func_is_extern_at(module, fi) != 0) {
      return 0;
    }
    let num_params: i32 = pipeline_module_func_num_params_at(module, fi);
    if (num_params < 0 || num_params > 8) {
      return 0;
    }
    let ret_ty: i32 = pipeline_module_func_return_type_at(module, fi);
    if (ret_ty <= 0) {
      return 0;
    }
    /* Find first param with free type-args on a generic struct (usually self). */
    let p: i32 = 0;
    let found_lk: i32 = -1;
    let found_pty: i32 = 0;
    let found_ntp: i32 = 0;
    let found_nm: u8[256] = [];
    let found_bare_off: i32 = 0;
    let found_bare_len: i32 = 0;
    while (p < num_params) {
      let pty_raw: i32 = pipeline_module_func_param_type_ref_at(module, fi, p);
      if (pty_raw <= 0) {
        p = p + 1;
        continue;
      }
      let pty: i32 = pipeline_typeck_resolve_type_alias_ref_c(arena, pty_raw);
      if (pty <= 0) {
        p = p + 1;
        continue;
      }
      if (pipeline_type_kind_ord_at(arena, pty) != (TypeKind.TYPE_NAMED as i32)) {
        p = p + 1;
        continue;
      }
      let nm: u8[256] = [];
      let nl: i32 = pipeline_type_named_name_into(arena, pty, &nm[0]);
      if (nl <= 0) {
        p = p + 1;
        continue;
      }
      let bare_off: i32 = 0;
      let bi: i32 = 0;
      while (bi < nl && bi < 64) {
        if (nm[bi] == 46) {
          bare_off = bi + 1;
        }
        bi = bi + 1;
      }
      let bare_len: i32 = nl - bare_off;
      if (bare_len <= 0) {
        p = p + 1;
        continue;
      }
      let lk: i32 = codegen_module_struct_layout_index_by_name(module, &nm[bare_off], bare_len);
      if (lk < 0) {
        p = p + 1;
        continue;
      }
      let ntp: i32 = pipeline_module_struct_layout_num_type_params_at(module, lk);
      if (ntp <= 0) {
        p = p + 1;
        continue;
      }
      /* Skip if param is already concrete (e.g. Wrap<i32>); fill_concrete succeeds. */
      let mono_chk: i32[4] = [];
      if (codegen_generic_struct_fill_concrete_args(module, arena, pty, ntp, &mono_chk[0], 0 as *PipelineDepCtx) == ntp) {
        p = p + 1;
        continue;
      }
      /* Has free type-args — this is our target param. */
      found_lk = lk;
      found_pty = pty;
      found_ntp = ntp;
      let cp_i: i32 = 0;
      while (cp_i < nl && cp_i < 64) {
        found_nm[cp_i] = nm[cp_i];
        cp_i = cp_i + 1;
      }
      found_bare_off = bare_off;
      found_bare_len = bare_len;
      p = num_params;
    }
    if (found_lk < 0) {
      return 0;
    }
    /* Collect all unique mono combos for this struct layout. */
    let combos: i32[32] = [];
    let nc: i32 = codegen_collect_generic_struct_mono_combos(module, arena, found_lk, &found_nm[found_bare_off], found_bare_len, found_ntp, &combos[0], 8);
    if (nc <= 1) {
      return 0;
    }
    let fn_local: u8[256] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    let mono_sym_pre: i32 = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
    /* One mono instance per unique combo; mangled symbol agrees with call-side. */
    let ci: i32 = 0;
    while (ci < nc) {
      /* Activate mono substitution for this combo. */
      let saved_mono_active: i32 = 0;
      let saved_mono_num: i32 = 0;
      let saved_func_index: i32 = -1;
      let saved_block_ref: i32 = 0;
      let mono_ctx_set: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx) {
        saved_mono_active = ctx.mono_active;
        saved_mono_num = ctx.mono_num_types;
        saved_func_index = ctx.current_func_index;
        saved_block_ref = ctx.current_block_ref;
        ctx.mono_active = 1;
        ctx.mono_num_types = 0;
        /* Map each formal type-arg → combo concrete. */
        let tj: i32 = 0;
        while (tj < found_ntp && tj < 8) {
          let formal_arg: i32 = pipeline_type_type_arg_ref_at(arena, found_pty, tj);
          let concrete_arg: i32 = combos[ci * found_ntp + tj];
          if (formal_arg > 0 && concrete_arg > 0) {
            ctx.mono_generic_type_refs[ctx.mono_num_types] = formal_arg;
            ctx.mono_concrete_type_refs[ctx.mono_num_types] = concrete_arg;
            ctx.mono_num_types = ctx.mono_num_types + 1;
          }
          tj = tj + 1;
        }
        ctx.current_func_index = fi;
        mono_ctx_set = 1;
      }
      /* Return type under mono_active. */
      if (codegen_emit_type(arena, out, ret_ty, prefix, prefix_len, ctx) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      if (codegen_append_byte(out, 32) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      if (mono_sym_pre > 0
          && codegen_c_prefix_redundant_with_name(prefix, mono_sym_pre, &fn_local[0], fn_len) == 0) {
        if (codegen_emit_bytes_from_ptr(out, prefix, mono_sym_pre) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
      }
      /* Mangled mono symbol: link_name + __ + suffix per combo slot. */
      if (codegen_emit_mono_mangled_name(out, arena, module, fi, &combos[ci * found_ntp], found_ntp) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      if (codegen_append_byte(out, 40) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      /* Emit all params under mono_active. */
      let pi: i32 = 0;
      while (pi < num_params) {
        if (pi > 0) {
          let cs: u8[2] = [44, 32];
          if (codegen_emit_bytes_from_ptr(out, &cs[0], 2) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
        }
        let p_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, pi);
        if (codegen_emit_type(arena, out, p_ty, prefix, prefix_len, ctx) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        if (codegen_append_byte(out, 32) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        let pname: u8[256] = [];
        let plen: i32 = pipeline_module_func_param_name_len_at(module, fi, pi);
        pipeline_module_func_param_name_copy32(module, fi, pi, &pname[0]);
        if (plen <= 0) {
          pname[0] = 95;
          plen = 1;
        }
        if (codegen_emit_bytes_from_ptr(out, &pname[0], plen) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        pi = pi + 1;
      }
      /* `) {\n` */
      let open_body: u8[4] = [41, 32, 123, 10];
      if (codegen_emit_bytes_from_ptr(out, &open_body[0], 4) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      /* Emit function body (block or expr). */
      let body_walked: i32 = 0;
      let body_br: i32 = pipeline_module_func_body_ref_at(module, fi);
      let body_er: i32 = pipeline_module_func_body_expr_ref_at(module, fi);
      if (!ast.ref_is_null(body_br) || !ast.ref_is_null(body_er)) {
        if (!ast.ref_is_null(body_br)) {
          if (mono_ctx_set != 0) {
            ctx.current_block_ref = body_br;
          }
          if (codegen_emit_block(arena, out, body_br, 2, ctx) == 0) {
            body_walked = 1;
          }
        } else {
          if (mono_ctx_set != 0) {
            ctx.current_block_ref = 0;
          }
          if (codegen_emit_indent(out, 2) == 0) {
            let ret_kw: u8[8] = [114, 101, 116, 117, 114, 110, 32, 0];
            if (codegen_emit_bytes_from_ptr(out, &ret_kw[0], 7) == 0) {
              if (codegen_emit_expr(arena, out, body_er, ctx) == 0) {
                let sc_nl: u8[2] = [59, 10];
                if (codegen_emit_bytes_from_ptr(out, &sc_nl[0], 2) == 0) {
                  body_walked = 1;
                }
              }
            }
          }
        }
      }
      if (body_walked == 0) {
        if (codegen_emit_indent(out, 2) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        let ret0: u8[10] = [114, 101, 116, 117, 114, 110, 32, 48, 59, 10];
        if (codegen_emit_bytes_from_ptr(out, &ret0[0], 10) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
      }
      if (mono_ctx_set != 0) {
        ctx.mono_active = saved_mono_active;
        ctx.mono_num_types = saved_mono_num;
        ctx.current_func_index = saved_func_index;
        ctx.current_block_ref = saved_block_ref;
      }
      let end: u8[2] = [125, 10];
      if (codegen_emit_bytes_from_ptr(out, &end[0], 2) != 0) {
        return -1;
      }
      ci = ci + 1;
    }
    return 1;
  }
}

/*
 * wave498: multi-combo generic inherent impl method extern declaration monomorphization.
 * Why: hoisted impl methods (num_generic_params == 0, <T> on impl not fn) need
 * forward-declared extern prototypes for each mono combo with mangled symbols,
 * matching the definitions emitted by codegen_try_emit_generic_impl_method_mono.
 * Without this, co-emitted TUs calling later generic impl methods get implicit
 * declaration warnings or wrong types (struct T instead of concrete).
 * PLATFORM: SHARED — seed codegen_gen.linux.x86_64.c same commit.
 * Guards: only activates when num_generic_params==0 AND a param has free type-args
 * AND combo_count>1. All other cases return 0 and fall through to normal
 * emit_func_extern_declaration (wave495 unique-combo path or plain emit).
 * @return i32 — 1 if handled (all combos emitted), 0 skip, -1 emit error
 */
function codegen_try_emit_generic_impl_method_extern_mono(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || module == 0 as *Module) {
      return 0;
    }
    if (fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    if (pipeline_module_func_num_generic_params_at(module, fi) > 0) {
      return 0;
    }
    let num_params: i32 = pipeline_module_func_num_params_at(module, fi);
    if (num_params < 0 || num_params > 8) {
      return 0;
    }
    let ret_ty: i32 = pipeline_module_func_return_type_at(module, fi);
    if (ret_ty <= 0) {
      return 0;
    }
    /* Find first param with free type-args on a generic struct (usually self). */
    let p: i32 = 0;
    let found_lk: i32 = -1;
    let found_pty: i32 = 0;
    let found_ntp: i32 = 0;
    let found_nm: u8[256] = [];
    let found_bare_off: i32 = 0;
    let found_bare_len: i32 = 0;
    while (p < num_params) {
      let pty_raw: i32 = pipeline_module_func_param_type_ref_at(module, fi, p);
      if (pty_raw <= 0) {
        p = p + 1;
        continue;
      }
      let pty: i32 = pipeline_typeck_resolve_type_alias_ref_c(arena, pty_raw);
      if (pty <= 0) {
        p = p + 1;
        continue;
      }
      if (pipeline_type_kind_ord_at(arena, pty) != (TypeKind.TYPE_NAMED as i32)) {
        p = p + 1;
        continue;
      }
      let nm: u8[256] = [];
      let nl: i32 = pipeline_type_named_name_into(arena, pty, &nm[0]);
      if (nl <= 0) {
        p = p + 1;
        continue;
      }
      let bare_off: i32 = 0;
      let bi: i32 = 0;
      while (bi < nl && bi < 64) {
        if (nm[bi] == 46) {
          bare_off = bi + 1;
        }
        bi = bi + 1;
      }
      let bare_len: i32 = nl - bare_off;
      if (bare_len <= 0) {
        p = p + 1;
        continue;
      }
      let lk: i32 = codegen_module_struct_layout_index_by_name(module, &nm[bare_off], bare_len);
      if (lk < 0) {
        p = p + 1;
        continue;
      }
      let ntp: i32 = pipeline_module_struct_layout_num_type_params_at(module, lk);
      if (ntp <= 0) {
        p = p + 1;
        continue;
      }
      /* Skip if param is already concrete (e.g. Wrap<i32>); fill_concrete succeeds. */
      let mono_chk: i32[4] = [];
      if (codegen_generic_struct_fill_concrete_args(module, arena, pty, ntp, &mono_chk[0], 0 as *PipelineDepCtx) == ntp) {
        p = p + 1;
        continue;
      }
      /* Has free type-args — this is our target param. */
      found_lk = lk;
      found_pty = pty;
      found_ntp = ntp;
      let cp_i: i32 = 0;
      while (cp_i < nl && cp_i < 64) {
        found_nm[cp_i] = nm[cp_i];
        cp_i = cp_i + 1;
      }
      found_bare_off = bare_off;
      found_bare_len = bare_len;
      p = num_params;
    }
    if (found_lk < 0) {
      return 0;
    }
    /* Collect all unique mono combos for this struct layout. */
    let combos: i32[32] = [];
    let nc: i32 = codegen_collect_generic_struct_mono_combos(module, arena, found_lk, &found_nm[found_bare_off], found_bare_len, found_ntp, &combos[0], 8);
    if (nc <= 1) {
      return 0;
    }
    let fn_local: u8[256] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    let mono_sym_pre: i32 = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
    /* One extern declaration per unique combo; mangled symbol agrees with definition side. */
    let ci: i32 = 0;
    while (ci < nc) {
      /* Activate mono substitution for this combo. */
      let saved_mono_active: i32 = 0;
      let saved_mono_num: i32 = 0;
      let saved_func_index: i32 = -1;
      let saved_block_ref: i32 = 0;
      let mono_ctx_set: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx) {
        saved_mono_active = ctx.mono_active;
        saved_mono_num = ctx.mono_num_types;
        saved_func_index = ctx.current_func_index;
        saved_block_ref = ctx.current_block_ref;
        ctx.mono_active = 1;
        ctx.mono_num_types = 0;
        /* Map each formal type-arg → combo concrete. */
        let tj: i32 = 0;
        while (tj < found_ntp && tj < 8) {
          let formal_arg: i32 = pipeline_type_type_arg_ref_at(arena, found_pty, tj);
          let concrete_arg: i32 = combos[ci * found_ntp + tj];
          if (formal_arg > 0 && concrete_arg > 0) {
            ctx.mono_generic_type_refs[ctx.mono_num_types] = formal_arg;
            ctx.mono_concrete_type_refs[ctx.mono_num_types] = concrete_arg;
            ctx.mono_num_types = ctx.mono_num_types + 1;
          }
          tj = tj + 1;
        }
        ctx.current_func_index = fi;
        mono_ctx_set = 1;
      }
      /* "extern " */
      let kw: u8[8] = [101, 120, 116, 101, 114, 110, 32, 0];
      if (codegen_emit_bytes_from_ptr(out, &kw[0], 7) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      /* Return type under mono_active. */
      if (codegen_emit_type(arena, out, ret_ty, prefix, prefix_len, ctx) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      if (codegen_append_byte(out, 32) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      if (mono_sym_pre > 0
          && codegen_c_prefix_redundant_with_name(prefix, mono_sym_pre, &fn_local[0], fn_len) == 0) {
        if (codegen_emit_bytes_from_ptr(out, prefix, mono_sym_pre) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
      }
      /* Mangled mono symbol: link_name + __ + suffix per combo slot. */
      if (codegen_emit_mono_mangled_name(out, arena, module, fi, &combos[ci * found_ntp], found_ntp) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      if (codegen_append_byte(out, 40) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      /* Emit all params under mono_active. */
      let pi: i32 = 0;
      while (pi < num_params) {
        if (pi > 0) {
          let cs: u8[2] = [44, 32];
          if (codegen_emit_bytes_from_ptr(out, &cs[0], 2) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
        }
        let p_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, pi);
        if (codegen_emit_type(arena, out, p_ty, prefix, prefix_len, ctx) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        /* PLATFORM: SHARED — TYPE_SLICE params as pointers (mirror emit_func_extern_declaration). */
        if (pipeline_type_kind_ord_at(arena, p_ty) == (TypeKind.TYPE_SLICE as i32)) {
          if (codegen_append_byte(out, 32) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
          if (codegen_append_byte(out, 42) != 0) {
            if (mono_ctx_set != 0) {
              ctx.mono_active = saved_mono_active;
              ctx.mono_num_types = saved_mono_num;
              ctx.current_func_index = saved_func_index;
              ctx.current_block_ref = saved_block_ref;
            }
            return -1;
          }
        }
        if (codegen_append_byte(out, 32) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        let pname: u8[256] = [];
        let plen: i32 = pipeline_module_func_param_name_len_at(module, fi, pi);
        pipeline_module_func_param_name_copy32(module, fi, pi, &pname[0]);
        if (plen <= 0) {
          pname[0] = 95;
          plen = 1;
        }
        if (codegen_emit_bytes_from_ptr(out, &pname[0], plen) != 0) {
          if (mono_ctx_set != 0) {
            ctx.mono_active = saved_mono_active;
            ctx.mono_num_types = saved_mono_num;
            ctx.current_func_index = saved_func_index;
            ctx.current_block_ref = saved_block_ref;
          }
          return -1;
        }
        pi = pi + 1;
      }
      /* ");\n" */
      let end_proto: u8[3] = [41, 59, 10];
      if (codegen_emit_bytes_from_ptr(out, &end_proto[0], 3) != 0) {
        if (mono_ctx_set != 0) {
          ctx.mono_active = saved_mono_active;
          ctx.mono_num_types = saved_mono_num;
          ctx.current_func_index = saved_func_index;
          ctx.current_block_ref = saved_block_ref;
        }
        return -1;
      }
      if (mono_ctx_set != 0) {
        ctx.mono_active = saved_mono_active;
        ctx.mono_num_types = saved_mono_num;
        ctx.current_func_index = saved_func_index;
        ctx.current_block_ref = saved_block_ref;
      }
      ci = ci + 1;
    }
    return 1;
  }
}

/** Exported function `emit_func_extern_declaration`.
 * Implements `emit_func_extern_declaration`.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param module *Module
 * @param fi i32
 * @param prefix *u8
 * @param prefix_len i32
 * @param ctx *PipelineDepCtx
 * @return i32
 */
export function emit_func_extern_declaration(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* See implementation. */
    if (fi < 0 || fi >= module.num_funcs) {
      return -1;
    }
    /* See implementation. */
    if (pipeline_module_func_num_generic_params_at(module, fi) > 0) {
      return 0;
    }
    /*
     * wave498: multi-combo generic inherent impl method extern declaration.
     * Why: hoisted impl methods (num_generic_params == 0, <T> on impl not fn)
     * with multi-combo (nc>1) need one extern declaration per combo with
     * mangled symbol. Return 1 means handled; fall through to normal path
     * for unique-combo / plain functions.
     * PLATFORM: SHARED — seed codegen_gen.linux.x86_64.c same commit.
     */
    let w498_ext_rc: i32 = codegen_try_emit_generic_impl_method_extern_mono(arena, out, module, fi, prefix, prefix_len, ctx);
    if (w498_ext_rc < 0) {
      return -1;
    }
    if (w498_ext_rc > 0) {
      return 0;
    }
    let fn_local: u8[256] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    /* See implementation. */
    if (pipeline_module_func_is_extern_at(module, fi) != 0 && codegen_is_libc_conflicting_extern_name(&fn_local[0], fn_len) != 0) {
      return 0;
    }
    /* "extern " */
    let kw: u8[8] = [101, 120, 116, 101, 114, 110, 32, 0];
    if (codegen_emit_bytes_from_ptr(out, &kw[0], 7) != 0) {
      return -1;
    }
    /* See implementation. */
    if (pipeline_module_func_is_used_at(module, fi) != 0) {
      let used_attr: u8[27] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 115, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0];
      if (codegen_emit_bytes_from_ptr(out, &used_attr[0], 22) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_naked_at(module, fi) != 0) {
      let naked_attr: u8[29] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 97, 107, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0, 0];
      if (codegen_emit_bytes_from_ptr(out, &naked_attr[0], 23) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_entry_at(module, fi) != 0) {
      let entry_attr: u8[30] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 111, 114, 101, 116, 117, 114, 110, 41, 41, 32, 0, 0, 0, 0];
      if (codegen_emit_bytes_from_ptr(out, &entry_attr[0], 26) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_interrupt_at(module, fi) != 0) {
      let int_attr: u8[31] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 105, 110, 116, 101, 114, 114, 117, 112, 116, 41, 41, 32, 0, 0, 0, 0];
      if (codegen_emit_bytes_from_ptr(out, &int_attr[0], 27) != 0) { return -1; }
    }
    /*
     * wave495: generic inherent impl method extern declaration monomorphization.
     * Why: the extern forward declaration `extern <ret> name(<params>);` is emitted
     * separately from the function definition. Without mono_active, the return type T
     * emits as `struct T` (incomplete BLD001) here while the definition (emit_func)
     * correctly emits `int32_t`. Build the same T→concrete map from params and set
     * mono_active so codegen_emit_type substitutes T in the return type. Mirrors emit_func.
     * PLATFORM: SHARED — seed codegen_gen.linux.x86_64.c same commit.
     * Guards: only set when w495_n > 0 (unique combo found); non-generic functions
     * and multi-combo cases skip this entirely (no behavior change). Restore on
     * success return; error paths abort.
     */
    let w495_mono_set: i32 = 0;
    let w495_saved_active: i32 = 0;
    let w495_saved_num: i32 = 0;
    if (ctx != 0 as *PipelineDepCtx) {
      let w495_gen: i32[8] = [];
      let w495_conc: i32[8] = [];
      let w495_n: i32 = codegen_build_func_param_mono_map(module, arena, fi, &w495_gen[0], &w495_conc[0], 8);
      if (w495_n > 0) {
        w495_saved_active = ctx.mono_active;
        w495_saved_num = ctx.mono_num_types;
        let w495_k: i32 = 0;
        while (w495_k < w495_n && w495_k < 8) {
          ctx.mono_generic_type_refs[w495_k] = w495_gen[w495_k];
          ctx.mono_concrete_type_refs[w495_k] = w495_conc[w495_k];
          w495_k = w495_k + 1;
        }
        ctx.mono_active = 1;
        ctx.mono_num_types = w495_n;
        w495_mono_set = 1;
      }
    }
    /* PLATFORM: SHARED — process entry ABI: void main → int32_t main (Zig-like).
     * Mirror emit_func's emit_c_main_symbol logic so the extern forward
     * declaration matches the definition's return type. Without this,
     * `extern void main(void);` conflicts with `int32_t main(void) {`
     * (BLD001 conflicting types for main). is_entry mirrors emit_func's
     * (fi == module.main_func_index) || (module.num_funcs == 1). */
    let ext_ret_ty_ref: i32 = pipeline_module_func_return_type_at(module, fi);
    let ext_name_is_main: bool = (fn_len == 4 && fn_local[0] == 109 && fn_local[1] == 97 && fn_local[2] == 105 && fn_local[3] == 110);
    let ext_is_entry: bool = (fi == module.main_func_index) || (module.num_funcs == 1);
    let ext_emit_c_main: bool = false;
    if (ext_is_entry && ext_name_is_main) {
      ext_emit_c_main = true;
    }
    if (ext_emit_c_main && pipeline_type_kind_ord_at(arena, ext_ret_ty_ref) == (TypeKind.TYPE_VOID as i32)) {
      let i32_ty: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
      if (codegen_emit_bytes_8(out, &i32_ty[0], 7) != 0) {
        return -1;
      }
    } else if (codegen_emit_type(arena, out, ext_ret_ty_ref, prefix, prefix_len, ctx) != 0) {
      return -1;
    }
    if (codegen_append_byte(out, 32) != 0) {
      return -1;
    }
    /* Why extern: external-link symbols need bare names (xlang_sys_mmap), not dep-prefixed
       (std_sys_linux_xlang_sys_mmap fails to link). Type emit still uses prefix_len for dep
       custom type params. Invariant: name_prefix_len only affects function-name emit. */
    let name_prefix_len: i32 = prefix_len;
    if (pipeline_module_func_is_extern_at(module, fi) != 0) {
      /* See implementation. */
      let _starts_with_prefix: bool = false;
      if (prefix_len > 0 && fn_len >= prefix_len) {
        let _k: i32 = 0;
        _starts_with_prefix = true;
        while (_k < prefix_len) {
          if (fn_local[_k] != prefix[_k]) {
            _starts_with_prefix = false;
            break;
          }
          _k = _k + 1;
        }
      }
      if (!_starts_with_prefix) {
        name_prefix_len = 0;
      }
    }
    /* See implementation. */
    name_prefix_len = codegen_func_c_symbol_prefix_len(module, fi, name_prefix_len);
    if (name_prefix_len > 0 && codegen_c_prefix_redundant_with_name(prefix, name_prefix_len, &fn_local[0], fn_len) == 0 && codegen_emit_bytes_from_ptr(out, prefix, name_prefix_len) != 0) {
      return -1;
    }
    /* See implementation. */
    if (codegen_emit_func_link_name(out, arena, module, fi) != 0) {
      return -1;
    }
    if (codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, &fn_local[0], fn_len) != 0) {
      let impl_suffix: u8[6] = [95, 105, 109, 112, 108, 0];
      if (codegen_emit_bytes_from_ptr(out, &impl_suffix[0], 5) != 0) {
        return -1;
      }
    }
    let lpar: u8[2] = [40, 0];
    if (codegen_emit_bytes_2(out, &lpar[0], 1) != 0) {
      return -1;
    }
    /* PLATFORM: WINDOWS — the count is a local before the compare.
     * This is the loop g1 of f44a77b17 smashed: push the param index,
     * call pipeline_module_func_num_params_at, pop the module pointer. */
    let nparams_proto: i32 = pipeline_module_func_num_params_at(module, fi);
    if (nparams_proto == 0) {
      let v: u8[7] = [118, 111, 105, 100, 0, 0, 0];
      if (codegen_emit_bytes_7(out, &v[0], 4) != 0) {
        return -1;
      }
    } else {
      let p: i32 = 0;
      while (p < nparams_proto) {
        if (p > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (codegen_emit_bytes_3(out, &comma[0], 2) != 0) {
            return -1;
          }
        }
        if (codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let size_t_buf2: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (codegen_emit_bytes_32(out, &size_t_buf2[0], 7) != 0) {
            return -1;
          }
        } else if (codegen_force_param_size_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let size_t_buf: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (codegen_emit_bytes_32(out, &size_t_buf[0], 7) != 0) {
            return -1;
          }
        } else if (codegen_force_param_ptrdiff_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let ptrdiff_t_buf: u8[32] = [112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (codegen_emit_bytes_32(out, &ptrdiff_t_buf[0], 10) != 0) {
            return -1;
          }
        } else if (codegen_force_param_uint32_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let u32_buf: u8[32] = [117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (codegen_emit_bytes_32(out, &u32_buf[0], 9) != 0) {
            return -1;
          }
        } else if (codegen_force_param_i32(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let i32_str: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
          if (codegen_emit_bytes_8(out, &i32_str[0], 7) != 0) {
            return -1;
          }
        } else if (type_uses_named_array_decl(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) != 0) {
          /* Proto twin of emit_func: `*[N]T` / `[K][N]T` → `E (*name)[N]`. */
          let pta_nm: u8[256] = [];
          let pta_nl: i32 = 0;
          if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {
            codegen_copy_param_name32_from_module(module, fi, p, &pta_nm[0]);
            pta_nl = pipeline_module_func_param_name_len_at(module, fi, p);
            if (pta_nm[0] <= 32) {
              pta_nl = 0;
            }
          }
          if (pta_nl <= 0) {
            pta_nm[0] = 95;
            pta_nm[1] = 112;
            pta_nl = 2;
            if (p < 10) {
              pta_nm[2] = ((p + 48) as u8);
              pta_nl = 3;
            } else {
              pta_nm[2] = ((p / 10) + 48) as u8;
              pta_nm[3] = ((p % 10) + 48) as u8;
              pta_nl = 4;
            }
          }
          if (codegen_emit_c_ptr_to_fixed_array_decl(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), &pta_nm[0], pta_nl, ctx) != 0) {
            return -1;
          }
        } else if (pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p))
            == (TypeKind.TYPE_FN as i32)) {
          /* Proto twin: `function(T): R` param → `R (*name)(T)`. PLATFORM: SHARED. */
          let pfn_nm: u8[256] = [];
          let pfn_nl: i32 = 0;
          if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {
            codegen_copy_param_name32_from_module(module, fi, p, &pfn_nm[0]);
            pfn_nl = pipeline_module_func_param_name_len_at(module, fi, p);
            if (pfn_nm[0] <= 32) {
              pfn_nl = 0;
            }
          }
          if (pfn_nl <= 0) {
            pfn_nm[0] = 95;
            pfn_nm[1] = 112;
            pfn_nl = 2;
            if (p < 10) {
              pfn_nm[2] = ((p + 48) as u8);
              pfn_nl = 3;
            } else {
              pfn_nm[2] = ((p / 10) + 48) as u8;
              pfn_nm[3] = ((p % 10) + 48) as u8;
              pfn_nl = 4;
            }
          }
          if (codegen_emit_c_fnptr_decl(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p),
              &pfn_nm[0], pfn_nl, 0, ctx) != 0) {
            return -1;
          }
        } else if (codegen_emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) != 0) {
          return -1;
        }
        /* PLATFORM: SHARED — TYPE_SLICE params as pointers (mirror emit_func body; seed/glue ABI). */
        if (type_uses_named_array_decl(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) == 0
            && pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) != (TypeKind.TYPE_FN as i32)
            && pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) == (TypeKind.TYPE_SLICE as i32)) {
          if (codegen_append_byte(out, 32) != 0) {
            return -1;
          }
          if (codegen_append_byte(out, 42) != 0) {
            return -1;
          }
        }
        if (type_uses_named_array_decl(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) == 0
            && pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) != (TypeKind.TYPE_FN as i32)) {
        if (codegen_append_byte(out, 32) != 0) {
          return -1;
        }
        if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {
          let plocal: u8[256] = [];
          codegen_copy_param_name32_from_module(module, fi, p, &plocal[0]);
          if (plocal[0] > 32 && codegen_emit_bytes_from_ptr(out, &plocal[0], pipeline_module_func_param_name_len_at(module, fi, p)) != 0) {
            return -1;
          }
        } else {
          let place: u8[4] = [95, 112, 48, 0];
          if (codegen_emit_bytes_4(out, &place[0], 2) != 0) {
            return -1;
          }
          if (format_int(out, p) != 0) {
            return -1;
          }
        }
        }
        p = p + 1;
      }
    }
    /* See implementation. */
    if (pipeline_module_func_is_variadic_at(module, fi) != 0 && pipeline_module_func_num_params_at(module, fi) > 0) {
      let ellipsis: u8[5] = [44, 32, 46, 46, 46];
      if (codegen_emit_bytes_from_ptr(out, &ellipsis[0], 5) != 0) {
        return -1;
      }
    }
    let end_proto: u8[3] = [41, 59, 10];
    if (codegen_emit_bytes_from_ptr(out, &end_proto[0], 3) != 0) {
      return -1;
    }
    /* wave495: restore mono_active on success return. */
    if (w495_mono_set != 0) {
      ctx.mono_active = w495_saved_active;
      ctx.mono_num_types = w495_saved_num;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_emit_import_dep_function_declarations(module: *Module, out: *CodegenOutBuf, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (module == 0 as *Module || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    let saved_module: *Module = ctx.current_codegen_module;
    let saved_arena: *ASTArena = ctx.current_codegen_arena;
    let saved_dep_index: i32 = ctx.current_codegen_dep_index;
    let saved_prefix_len: i32 = ctx.current_codegen_prefix_len;
    let saved_prefix: u8[256] = [];
    let sp: i32 = 0;
    while (sp < 64) {
      saved_prefix[sp] = ctx.current_codegen_prefix_mirror[sp];
      sp = sp + 1;
    }
    let n_imp: i32 = codegen_module_num_imports(module);
    let imp_i: i32 = 0;
    while (imp_i < n_imp) {
      let dep_path: u8[128] = [];
      let dep_path_len: i32 = codegen_module_import_path_len_at(module, imp_i, &dep_path[0]);
      if (dep_path_len > 0) {
        let seen_before: i32 = 0;
        let prev_i: i32 = 0;
        while (prev_i < imp_i) {
          let prev_path: u8[256] = [];
          let prev_len: i32 = codegen_module_import_path_len_at(module, prev_i, &prev_path[0]);
          if (prev_len == dep_path_len) {
            let eq_prev: bool = true;
            let pk: i32 = 0;
            while (pk < dep_path_len && pk < 64) {
              if (prev_path[pk] != dep_path[pk]) {
                eq_prev = false;
                break;
              }
              pk = pk + 1;
            }
            if (eq_prev) {
              seen_before = 1;
              break;
            }
          }
          prev_i = prev_i + 1;
        }
        if (seen_before == 0) {
          let dep_ix: i32 = codegen_find_dep_index_by_path(ctx, &dep_path[0], dep_path_len);
          let dep_mod: *Module = 0 as *Module;
          let dep_arena: *ASTArena = 0 as *ASTArena;
          let dep_ctx_ix: i32 = dep_ix;
          /* Bound is a local so Win64 does not home rcx over the index. PLATFORM: WINDOWS. */
          let ndep_seen: i32 = pipeline_dep_ctx_ndep(ctx);
          if (dep_ix >= 0 && dep_ix < ndep_seen) {
            dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
            dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
          }
          if ((dep_mod == 0 as *Module || dep_arena == 0 as *ASTArena) && dep_path_len > 0) {
            let global_slot: i32 = codegen_find_seeded_global_dep_slot_by_path(&dep_path[0], dep_path_len);
            if (global_slot >= 0) {
              dep_mod = driver_dep_module_buf(global_slot) as *Module;
              dep_arena = driver_dep_arena_buf(global_slot) as *ASTArena;
              dep_ctx_ix = -1;
            }
          }
          if (dep_mod != 0 as *Module && dep_arena != 0 as *ASTArena && dep_mod.num_funcs > 0) {
              let prefix_buf: u8[256] = [];
              let prefix_len: i32 = 0;
              if (codegen_path_is_std_io_core_bytes(&dep_path[0]) == 0) {
                codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
                while (prefix_len < 128 && prefix_buf[prefix_len] != 0 as u8) {
                  prefix_len = prefix_len + 1;
                }
              }
              ctx.current_codegen_module = dep_mod;
              ctx.current_codegen_arena = dep_arena;
              ctx.current_codegen_dep_index = dep_ctx_ix;
              ctx.current_codegen_prefix_len = 0;
              let px: i32 = 0;
              while (px < prefix_len && px < 63) {
                ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
                px = px + 1;
              }
              ctx.current_codegen_prefix_mirror[px] = 0 as u8;
              ctx.current_codegen_prefix_len = px;
              let fi: i32 = 0;
              while (fi < dep_mod.num_funcs) {
                if (emit_func_extern_declaration(dep_arena, out, dep_mod, fi, &prefix_buf[0], prefix_len, ctx) != 0) {
                  return -1;
                }
                fi = fi + 1;
              }
          }
        }
      }
      imp_i = imp_i + 1;
    }
    ctx.current_codegen_module = saved_module;
    ctx.current_codegen_arena = saved_arena;
    ctx.current_codegen_dep_index = saved_dep_index;
    ctx.current_codegen_prefix_len = saved_prefix_len;
    sp = 0;
    while (sp < 64) {
      ctx.current_codegen_prefix_mirror[sp] = saved_prefix[sp];
      sp = sp + 1;
    }
    return 0;
  }
}

/**
 * Emit minimal host-C TU prologue for bare `-E` / codegen_x_ast body path.
 * Includes stdint/stddef/sys/types plus TYPE_SLICE fat layouts (`struct xlang_slice_*`)
 * matching type_to_c_repr / rt_preamble (wave618–619 scalar set + wave691 one-level
 * nested `[][]T` → `struct xlang_slice_xlang_slice_<elem>` + wave693 two-level
 * nested `[][][]T` → `struct xlang_slice_xlang_slice_xlang_slice_<elem>` + wave694
 * nested `[][][][]T` → `struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_<elem>` + wave695
 * nested `[][][][][]T` → `struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_<elem>` + wave696
 * nested `[][][][][][]T` → `struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_<elem>` + wave697
 * nested `[][][][][][][]T` → `struct xlang_slice×7_<elem>` + wave698 `[][][][][][][][]T` → `struct xlang_slice×8_<elem>`
 * + 4.2.3 loop `[]×9`..`[]×16` under XLANG_SLICE_LAYOUTS_N16
 * + nest>16 soft `[]×17` under XLANG_SLICE_LAYOUTS_N17
 * + nest>17 soft `[]×18` under XLANG_SLICE_LAYOUTS_N18
 * + nest>18 soft `[]×19` under XLANG_SLICE_LAYOUTS_N19
 * + nest>19 soft `[]×20` under XLANG_SLICE_LAYOUTS_N20
 * + nest>20 soft `[]×21` under XLANG_SLICE_LAYOUTS_N21
 * + nest>21 soft `[]×22` under XLANG_SLICE_LAYOUTS_N22
 * + nest>22 soft `[]×23` under XLANG_SLICE_LAYOUTS_N23
 * + nest>23 soft `[]×24` under XLANG_SLICE_LAYOUTS_N24
 * + nest>24 soft `[]×25` under XLANG_SLICE_LAYOUTS_N25
 * + nest>25 soft `[]×26` under XLANG_SLICE_LAYOUTS_N26
 * + nest>26 soft `[]×27` under XLANG_SLICE_LAYOUTS_N27
 * + nest>27 soft `[]×28` under XLANG_SLICE_LAYOUTS_N28
 * + nest>28 soft `[]×29` under XLANG_SLICE_LAYOUTS_N29
 * + nest>29 soft `[]×30` under XLANG_SLICE_LAYOUTS_N30
 * + nest>30 soft `[]×31` under XLANG_SLICE_LAYOUTS_N31
 * + nest>31 soft `[]×32` under XLANG_SLICE_LAYOUTS_N32
 * + nest>32 soft `[]×33` under XLANG_SLICE_LAYOUTS_N33
 * + nest>33 soft `[]×34` under XLANG_SLICE_LAYOUTS_N34
 * + nest>34 soft `[]×35` under XLANG_SLICE_LAYOUTS_N35
 * + nest>35 soft `[]×36` under XLANG_SLICE_LAYOUTS_N36
 * + nest>36 soft `[]×37` under XLANG_SLICE_LAYOUTS_N37
 * + nest>37 soft `[]×38` under XLANG_SLICE_LAYOUTS_N38
 * + nest>38 soft `[]×39` under XLANG_SLICE_LAYOUTS_N39
 * + nest>39 soft `[]×40` under XLANG_SLICE_LAYOUTS_N40
 * + nest>40 soft `[]×41` under XLANG_SLICE_LAYOUTS_N41
 * + nest>41 soft `[]×42` under XLANG_SLICE_LAYOUTS_N42
 * + nest>42 soft `[]×43` under XLANG_SLICE_LAYOUTS_N43
 * + nest>43 soft `[]×44` under XLANG_SLICE_LAYOUTS_N44
 * + nest>44 soft `[]×45` under XLANG_SLICE_LAYOUTS_N45
 * + nest>45 soft `[]×46` under XLANG_SLICE_LAYOUTS_N46
 * + nest>46 soft `[]×47` under XLANG_SLICE_LAYOUTS_N47
 * + nest>47 soft `[]×48` under XLANG_SLICE_LAYOUTS_N48
 * + nest>48 soft `[]×49` under XLANG_SLICE_LAYOUTS_N49
 * + nest>49 soft `[]×50` under XLANG_SLICE_LAYOUTS_N50
 * + nest>50 soft `[]×51` under XLANG_SLICE_LAYOUTS_N51
 * + nest>51 soft `[]×52` under XLANG_SLICE_LAYOUTS_N52
 * + nest>52 jump `[]×53..64` under XLANG_SLICE_LAYOUTS_N64). Without layouts,
 * bare `-E` output fails host-cc with incomplete type; full `-o` already injects
 * rt_preamble — both sites use XLANG_SLICE_LAYOUTS so redefinition is safe.
 * @param out *CodegenOutBuf — destination C text buffer
 * @return i32 — 0 on success, -1 if any emit fails
 * PLATFORM: SHARED — host-C minimal preamble; verify bare `-E` + host-cc and `-backend c -o`.
 * Authority: G.7 expand codegen_emit_scalar_slice_nests / this function.
 * Product chain assembles codegen.x → codegen_x.o. Seed emit_header still
 * holds wave698 1..8 only (cold leftover; do not grow the u8[256] table).
 * Includes: stdint/stddef/sys/types/string + stdlib + unistd so skip-decl
 * libc names (getcwd/malloc/getenv) have a prototype on bare `-E`.
 * SIMD: XLANG_VECTOR_TYPES (i32x4_t / u32x8_t / f32x4_t …) so bare `-E`
 * host-cc matches emit_vector_c_type_out; `-o` already has rt_preamble §10.
 */
/**
 * Stage 10 S3.1 (10.1.1+10.1.2): emit the raw syscall static-inline helpers
 * `__xlang_raw_syscall0..6` into the host-C preamble, behind
 * `#if defined(__linux__) && defined(__x86_64__)` then
 * `#elif defined(__linux__) && defined(__aarch64__)`.
 *
 * x86_64 map: nr→rax; a1→rdi; a2→rsi; a3→rdx; a4→r10; a5→r8; a6→r9;
 * return rax; rcx/r11 clobbered by `syscall`. r10/r8/r9 use register locals.
 * aarch64 map (10.1.2): nr→x8; a1→x0; a2→x1; a3→x2; a4→x3; a5→x4; a6→x5;
 * return x0; `svc #0`. Host cc preprocessor is the platform truth:
 * Darwin (not linux) drops both blocks; Ubuntu x86_64 takes the first;
 * Linux aarch64 takes the elif. `__attribute__((unused))` keeps helper-only
 * TUs warning-free under -Wall -Wextra.
 *
 * Consumed only by codegen_try_emit_raw_syscall_call call-site expansion;
 * emitting here is safe for both bare `-E` and full `-o` because this runs
 * once per C TU via the prologue gate (pipeline_codegen_c_file_prologue_done).
 *
 * @param out *CodegenOutBuf — destination C text buffer
 * @return i32 — 0 on success; -1 if any emit fails
 * PLATFORM: SHARED host-C emit; runtime LINUX x86_64 or LINUX aarch64.
 */
export function codegen_emit_raw_syscall_helpers(out: *CodegenOutBuf): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /* #if defined(__linux__) && defined(__x86_64__)\n */
    let guard_open: u8[46] = [35, 105, 102, 32, 100, 101, 102, 105, 110, 101, 100, 40, 95, 95, 108, 105,
      110, 117, 120, 95, 95, 41, 32, 38, 38, 32, 100, 101, 102, 105, 110, 101,
      100, 40, 95, 95, 120, 56, 54, 95, 54, 52, 95, 95, 41, 10];
    /* static inline __attribute__((unused)) long __xlang_raw_syscall0(long n){long r;__asm__ __volatile__("syscall":"=a"(r):"a"(n):"rcx","r11","memory");return r;}\n */
    let h0: u8[158] = [115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 48, 40,
      108, 111, 110, 103, 32, 110, 41, 123, 108, 111, 110, 103, 32, 114, 59, 95,
      95, 97, 115, 109, 95, 95, 32, 95, 95, 118, 111, 108, 97, 116, 105, 108,
      101, 95, 95, 40, 34, 115, 121, 115, 99, 97, 108, 108, 34, 58, 34, 61,
      97, 34, 40, 114, 41, 58, 34, 97, 34, 40, 110, 41, 58, 34, 114, 99,
      120, 34, 44, 34, 114, 49, 49, 34, 44, 34, 109, 101, 109, 111, 114, 121,
      34, 41, 59, 114, 101, 116, 117, 114, 110, 32, 114, 59, 125, 10];
    /* __xlang_raw_syscall1(long n,long a) — arg1 in rdi ("D"). */
    let h1: u8[172] = [115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 49, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 41, 123, 108,
      111, 110, 103, 32, 114, 59, 95, 95, 97, 115, 109, 95, 95, 32, 95, 95,
      118, 111, 108, 97, 116, 105, 108, 101, 95, 95, 40, 34, 115, 121, 115, 99,
      97, 108, 108, 34, 58, 34, 61, 97, 34, 40, 114, 41, 58, 34, 97, 34,
      40, 110, 41, 44, 34, 68, 34, 40, 97, 41, 58, 34, 114, 99, 120, 34,
      44, 34, 114, 49, 49, 34, 44, 34, 109, 101, 109, 111, 114, 121, 34, 41,
      59, 114, 101, 116, 117, 114, 110, 32, 114, 59, 125, 10];
    /* __xlang_raw_syscall2(long n,long a,long b) — arg2 in rsi ("S"). */
    let h2: u8[186] = [115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 50, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 44, 108, 111,
      110, 103, 32, 98, 41, 123, 108, 111, 110, 103, 32, 114, 59, 95, 95, 97,
      115, 109, 95, 95, 32, 95, 95, 118, 111, 108, 97, 116, 105, 108, 101, 95,
      95, 40, 34, 115, 121, 115, 99, 97, 108, 108, 34, 58, 34, 61, 97, 34,
      40, 114, 41, 58, 34, 97, 34, 40, 110, 41, 44, 34, 68, 34, 40, 97,
      41, 44, 34, 83, 34, 40, 98, 41, 58, 34, 114, 99, 120, 34, 44, 34,
      114, 49, 49, 34, 44, 34, 109, 101, 109, 111, 114, 121, 34, 41, 59, 114,
      101, 116, 117, 114, 110, 32, 114, 59, 125, 10];
    /* __xlang_raw_syscall3(long n,long a,long b,long c) — arg3 in rdx ("d"); write/read shape. */
    let h3: u8[200] = [115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 51, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 44, 108, 111,
      110, 103, 32, 98, 44, 108, 111, 110, 103, 32, 99, 41, 123, 108, 111, 110,
      103, 32, 114, 59, 95, 95, 97, 115, 109, 95, 95, 32, 95, 95, 118, 111,
      108, 97, 116, 105, 108, 101, 95, 95, 40, 34, 115, 121, 115, 99, 97, 108,
      108, 34, 58, 34, 61, 97, 34, 40, 114, 41, 58, 34, 97, 34, 40, 110,
      41, 44, 34, 68, 34, 40, 97, 41, 44, 34, 83, 34, 40, 98, 41, 44,
      34, 100, 34, 40, 99, 41, 58, 34, 114, 99, 120, 34, 44, 34, 114, 49,
      49, 34, 44, 34, 109, 101, 109, 111, 114, 121, 34, 41, 59, 114, 101, 116,
      117, 114, 110, 32, 114, 59, 125, 10];
    /* __xlang_raw_syscall4 — arg4 in r10 (register local var; no single-letter constraint). */
    let h4: u8[251] = [115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 52, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 44, 108, 111,
      110, 103, 32, 98, 44, 108, 111, 110, 103, 32, 99, 44, 108, 111, 110, 103,
      32, 100, 41, 123, 108, 111, 110, 103, 32, 114, 59, 114, 101, 103, 105, 115,
      116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 49, 48, 32, 95, 95, 97,
      115, 109, 95, 95, 40, 34, 114, 49, 48, 34, 41, 61, 100, 59, 95, 95,
      97, 115, 109, 95, 95, 32, 95, 95, 118, 111, 108, 97, 116, 105, 108, 101,
      95, 95, 40, 34, 115, 121, 115, 99, 97, 108, 108, 34, 58, 34, 61, 97,
      34, 40, 114, 41, 58, 34, 97, 34, 40, 110, 41, 44, 34, 68, 34, 40,
      97, 41, 44, 34, 83, 34, 40, 98, 41, 44, 34, 100, 34, 40, 99, 41,
      44, 34, 114, 34, 40, 120, 49, 48, 41, 58, 34, 114, 99, 120, 34, 44,
      34, 114, 49, 49, 34, 44, 34, 109, 101, 109, 111, 114, 121, 34, 41, 59,
      114, 101, 116, 117, 114, 110, 32, 114, 59, 125, 10];
    /* __xlang_raw_syscall5 — arg4 r10 + arg5 r8 (register locals). */
    let h5: u8[299] = [115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 53, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 44, 108, 111,
      110, 103, 32, 98, 44, 108, 111, 110, 103, 32, 99, 44, 108, 111, 110, 103,
      32, 100, 44, 108, 111, 110, 103, 32, 101, 41, 123, 108, 111, 110, 103, 32,
      114, 59, 114, 101, 103, 105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32,
      120, 49, 48, 32, 95, 95, 97, 115, 109, 95, 95, 40, 34, 114, 49, 48,
      34, 41, 61, 100, 59, 114, 101, 103, 105, 115, 116, 101, 114, 32, 108, 111,
      110, 103, 32, 120, 56, 32, 95, 95, 97, 115, 109, 95, 95, 40, 34, 114,
      56, 34, 41, 61, 101, 59, 95, 95, 97, 115, 109, 95, 95, 32, 95, 95,
      118, 111, 108, 97, 116, 105, 108, 101, 95, 95, 40, 34, 115, 121, 115, 99,
      97, 108, 108, 34, 58, 34, 61, 97, 34, 40, 114, 41, 58, 34, 97, 34,
      40, 110, 41, 44, 34, 68, 34, 40, 97, 41, 44, 34, 83, 34, 40, 98,
      41, 44, 34, 100, 34, 40, 99, 41, 44, 34, 114, 34, 40, 120, 49, 48,
      41, 44, 34, 114, 34, 40, 120, 56, 41, 58, 34, 114, 99, 120, 34, 44,
      34, 114, 49, 49, 34, 44, 34, 109, 101, 109, 111, 114, 121, 34, 41, 59,
      114, 101, 116, 117, 114, 110, 32, 114, 59, 125, 10];
    /* __xlang_raw_syscall6 — arg4 r10 + arg5 r8 + arg6 r9 (register locals). */
    let h6: u8[347] = [115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 54, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 44, 108, 111,
      110, 103, 32, 98, 44, 108, 111, 110, 103, 32, 99, 44, 108, 111, 110, 103,
      32, 100, 44, 108, 111, 110, 103, 32, 101, 44, 108, 111, 110, 103, 32, 102,
      41, 123, 108, 111, 110, 103, 32, 114, 59, 114, 101, 103, 105, 115, 116, 101,
      114, 32, 108, 111, 110, 103, 32, 120, 49, 48, 32, 95, 95, 97, 115, 109,
      95, 95, 40, 34, 114, 49, 48, 34, 41, 61, 100, 59, 114, 101, 103, 105,
      115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 56, 32, 95, 95, 97,
      115, 109, 95, 95, 40, 34, 114, 56, 34, 41, 61, 101, 59, 114, 101, 103,
      105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 57, 32, 95, 95,
      97, 115, 109, 95, 95, 40, 34, 114, 57, 34, 41, 61, 102, 59, 95, 95,
      97, 115, 109, 95, 95, 32, 95, 95, 118, 111, 108, 97, 116, 105, 108, 101,
      95, 95, 40, 34, 115, 121, 115, 99, 97, 108, 108, 34, 58, 34, 61, 97,
      34, 40, 114, 41, 58, 34, 97, 34, 40, 110, 41, 44, 34, 68, 34, 40,
      97, 41, 44, 34, 83, 34, 40, 98, 41, 44, 34, 100, 34, 40, 99, 41,
      44, 34, 114, 34, 40, 120, 49, 48, 41, 44, 34, 114, 34, 40, 120, 56,
      41, 44, 34, 114, 34, 40, 120, 57, 41, 58, 34, 114, 99, 120, 34, 44,
      34, 114, 49, 49, 34, 44, 34, 109, 101, 109, 111, 114, 121, 34, 41, 59,
      114, 101, 116, 117, 114, 110, 32, 114, 59, 125, 10];
    /* #endif\n */
    let guard_close: u8[7] = [35, 101, 110, 100, 105, 102, 10];
    /* #elif defined(__linux__) && defined(__aarch64__) */
    let elif_open: u8[49] = [
      35, 101, 108, 105, 102, 32, 100, 101, 102, 105, 110, 101, 100, 40, 95, 95,
      108, 105, 110, 117, 120, 95, 95, 41, 32, 38, 38, 32, 100, 101, 102, 105,
      110, 101, 100, 40, 95, 95, 97, 97, 114, 99, 104, 54, 52, 95, 95, 41,
      10
    ];
    /* aarch64 __xlang_raw_syscall0 svc #0 */
    let a0: u8[205] = [
      115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 48, 40,
      108, 111, 110, 103, 32, 110, 41, 123, 114, 101, 103, 105, 115, 116, 101, 114,
      32, 108, 111, 110, 103, 32, 120, 56, 32, 95, 95, 97, 115, 109, 95, 95,
      40, 34, 120, 56, 34, 41, 61, 110, 59, 114, 101, 103, 105, 115, 116, 101,
      114, 32, 108, 111, 110, 103, 32, 120, 48, 32, 95, 95, 97, 115, 109, 95,
      95, 40, 34, 120, 48, 34, 41, 59, 95, 95, 97, 115, 109, 95, 95, 32,
      95, 95, 118, 111, 108, 97, 116, 105, 108, 101, 95, 95, 40, 34, 115, 118,
      99, 32, 35, 48, 34, 58, 34, 61, 114, 34, 40, 120, 48, 41, 58, 34,
      114, 34, 40, 120, 56, 41, 58, 34, 109, 101, 109, 111, 114, 121, 34, 41,
      59, 114, 101, 116, 117, 114, 110, 32, 120, 48, 59, 125, 10
    ];
    /* aarch64 __xlang_raw_syscall1 svc #0 */
    let a1: u8[214] = [
      115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 49, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 41, 123, 114,
      101, 103, 105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 56, 32,
      95, 95, 97, 115, 109, 95, 95, 40, 34, 120, 56, 34, 41, 61, 110, 59,
      114, 101, 103, 105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 48,
      32, 95, 95, 97, 115, 109, 95, 95, 40, 34, 120, 48, 34, 41, 61, 97,
      59, 95, 95, 97, 115, 109, 95, 95, 32, 95, 95, 118, 111, 108, 97, 116,
      105, 108, 101, 95, 95, 40, 34, 115, 118, 99, 32, 35, 48, 34, 58, 34,
      43, 114, 34, 40, 120, 48, 41, 58, 34, 114, 34, 40, 120, 56, 41, 58,
      34, 109, 101, 109, 111, 114, 121, 34, 41, 59, 114, 101, 116, 117, 114, 110,
      32, 120, 48, 59, 125, 10
    ];
    /* aarch64 __xlang_raw_syscall2 svc #0 */
    let a2: u8[262] = [
      115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 50, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 44, 108, 111,
      110, 103, 32, 98, 41, 123, 114, 101, 103, 105, 115, 116, 101, 114, 32, 108,
      111, 110, 103, 32, 120, 56, 32, 95, 95, 97, 115, 109, 95, 95, 40, 34,
      120, 56, 34, 41, 61, 110, 59, 114, 101, 103, 105, 115, 116, 101, 114, 32,
      108, 111, 110, 103, 32, 120, 48, 32, 95, 95, 97, 115, 109, 95, 95, 40,
      34, 120, 48, 34, 41, 61, 97, 59, 114, 101, 103, 105, 115, 116, 101, 114,
      32, 108, 111, 110, 103, 32, 120, 49, 32, 95, 95, 97, 115, 109, 95, 95,
      40, 34, 120, 49, 34, 41, 61, 98, 59, 95, 95, 97, 115, 109, 95, 95,
      32, 95, 95, 118, 111, 108, 97, 116, 105, 108, 101, 95, 95, 40, 34, 115,
      118, 99, 32, 35, 48, 34, 58, 34, 43, 114, 34, 40, 120, 48, 41, 58,
      34, 114, 34, 40, 120, 56, 41, 44, 34, 114, 34, 40, 120, 49, 41, 58,
      34, 109, 101, 109, 111, 114, 121, 34, 41, 59, 114, 101, 116, 117, 114, 110,
      32, 120, 48, 59, 125, 10
    ];
    /* aarch64 __xlang_raw_syscall3 svc #0 */
    let a3: u8[310] = [
      115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 51, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 44, 108, 111,
      110, 103, 32, 98, 44, 108, 111, 110, 103, 32, 99, 41, 123, 114, 101, 103,
      105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 56, 32, 95, 95,
      97, 115, 109, 95, 95, 40, 34, 120, 56, 34, 41, 61, 110, 59, 114, 101,
      103, 105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 48, 32, 95,
      95, 97, 115, 109, 95, 95, 40, 34, 120, 48, 34, 41, 61, 97, 59, 114,
      101, 103, 105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 49, 32,
      95, 95, 97, 115, 109, 95, 95, 40, 34, 120, 49, 34, 41, 61, 98, 59,
      114, 101, 103, 105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 50,
      32, 95, 95, 97, 115, 109, 95, 95, 40, 34, 120, 50, 34, 41, 61, 99,
      59, 95, 95, 97, 115, 109, 95, 95, 32, 95, 95, 118, 111, 108, 97, 116,
      105, 108, 101, 95, 95, 40, 34, 115, 118, 99, 32, 35, 48, 34, 58, 34,
      43, 114, 34, 40, 120, 48, 41, 58, 34, 114, 34, 40, 120, 56, 41, 44,
      34, 114, 34, 40, 120, 49, 41, 44, 34, 114, 34, 40, 120, 50, 41, 58,
      34, 109, 101, 109, 111, 114, 121, 34, 41, 59, 114, 101, 116, 117, 114, 110,
      32, 120, 48, 59, 125, 10
    ];
    /* aarch64 __xlang_raw_syscall4 svc #0 */
    let a4: u8[358] = [
      115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 52, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 44, 108, 111,
      110, 103, 32, 98, 44, 108, 111, 110, 103, 32, 99, 44, 108, 111, 110, 103,
      32, 100, 41, 123, 114, 101, 103, 105, 115, 116, 101, 114, 32, 108, 111, 110,
      103, 32, 120, 56, 32, 95, 95, 97, 115, 109, 95, 95, 40, 34, 120, 56,
      34, 41, 61, 110, 59, 114, 101, 103, 105, 115, 116, 101, 114, 32, 108, 111,
      110, 103, 32, 120, 48, 32, 95, 95, 97, 115, 109, 95, 95, 40, 34, 120,
      48, 34, 41, 61, 97, 59, 114, 101, 103, 105, 115, 116, 101, 114, 32, 108,
      111, 110, 103, 32, 120, 49, 32, 95, 95, 97, 115, 109, 95, 95, 40, 34,
      120, 49, 34, 41, 61, 98, 59, 114, 101, 103, 105, 115, 116, 101, 114, 32,
      108, 111, 110, 103, 32, 120, 50, 32, 95, 95, 97, 115, 109, 95, 95, 40,
      34, 120, 50, 34, 41, 61, 99, 59, 114, 101, 103, 105, 115, 116, 101, 114,
      32, 108, 111, 110, 103, 32, 120, 51, 32, 95, 95, 97, 115, 109, 95, 95,
      40, 34, 120, 51, 34, 41, 61, 100, 59, 95, 95, 97, 115, 109, 95, 95,
      32, 95, 95, 118, 111, 108, 97, 116, 105, 108, 101, 95, 95, 40, 34, 115,
      118, 99, 32, 35, 48, 34, 58, 34, 43, 114, 34, 40, 120, 48, 41, 58,
      34, 114, 34, 40, 120, 56, 41, 44, 34, 114, 34, 40, 120, 49, 41, 44,
      34, 114, 34, 40, 120, 50, 41, 44, 34, 114, 34, 40, 120, 51, 41, 58,
      34, 109, 101, 109, 111, 114, 121, 34, 41, 59, 114, 101, 116, 117, 114, 110,
      32, 120, 48, 59, 125, 10
    ];
    /* aarch64 __xlang_raw_syscall5 svc #0 */
    let a5: u8[406] = [
      115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 53, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 44, 108, 111,
      110, 103, 32, 98, 44, 108, 111, 110, 103, 32, 99, 44, 108, 111, 110, 103,
      32, 100, 44, 108, 111, 110, 103, 32, 101, 41, 123, 114, 101, 103, 105, 115,
      116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 56, 32, 95, 95, 97, 115,
      109, 95, 95, 40, 34, 120, 56, 34, 41, 61, 110, 59, 114, 101, 103, 105,
      115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 48, 32, 95, 95, 97,
      115, 109, 95, 95, 40, 34, 120, 48, 34, 41, 61, 97, 59, 114, 101, 103,
      105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 49, 32, 95, 95,
      97, 115, 109, 95, 95, 40, 34, 120, 49, 34, 41, 61, 98, 59, 114, 101,
      103, 105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 50, 32, 95,
      95, 97, 115, 109, 95, 95, 40, 34, 120, 50, 34, 41, 61, 99, 59, 114,
      101, 103, 105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 51, 32,
      95, 95, 97, 115, 109, 95, 95, 40, 34, 120, 51, 34, 41, 61, 100, 59,
      114, 101, 103, 105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32, 120, 52,
      32, 95, 95, 97, 115, 109, 95, 95, 40, 34, 120, 52, 34, 41, 61, 101,
      59, 95, 95, 97, 115, 109, 95, 95, 32, 95, 95, 118, 111, 108, 97, 116,
      105, 108, 101, 95, 95, 40, 34, 115, 118, 99, 32, 35, 48, 34, 58, 34,
      43, 114, 34, 40, 120, 48, 41, 58, 34, 114, 34, 40, 120, 56, 41, 44,
      34, 114, 34, 40, 120, 49, 41, 44, 34, 114, 34, 40, 120, 50, 41, 44,
      34, 114, 34, 40, 120, 51, 41, 44, 34, 114, 34, 40, 120, 52, 41, 58,
      34, 109, 101, 109, 111, 114, 121, 34, 41, 59, 114, 101, 116, 117, 114, 110,
      32, 120, 48, 59, 125, 10
    ];
    /* aarch64 __xlang_raw_syscall6 svc #0 */
    let a6: u8[454] = [
      115, 116, 97, 116, 105, 99, 32, 105, 110, 108, 105, 110, 101, 32, 95, 95,
      97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 110, 117,
      115, 101, 100, 41, 41, 32, 108, 111, 110, 103, 32, 95, 95, 120, 108, 97,
      110, 103, 95, 114, 97, 119, 95, 115, 121, 115, 99, 97, 108, 108, 54, 40,
      108, 111, 110, 103, 32, 110, 44, 108, 111, 110, 103, 32, 97, 44, 108, 111,
      110, 103, 32, 98, 44, 108, 111, 110, 103, 32, 99, 44, 108, 111, 110, 103,
      32, 100, 44, 108, 111, 110, 103, 32, 101, 44, 108, 111, 110, 103, 32, 102,
      41, 123, 114, 101, 103, 105, 115, 116, 101, 114, 32, 108, 111, 110, 103, 32,
      120, 56, 32, 95, 95, 97, 115, 109, 95, 95, 40, 34, 120, 56, 34, 41,
      61, 110, 59, 114, 101, 103, 105, 115, 116, 101, 114, 32, 108, 111, 110, 103,
      32, 120, 48, 32, 95, 95, 97, 115, 109, 95, 95, 40, 34, 120, 48, 34,
      41, 61, 97, 59, 114, 101, 103, 105, 115, 116, 101, 114, 32, 108, 111, 110,
      103, 32, 120, 49, 32, 95, 95, 97, 115, 109, 95, 95, 40, 34, 120, 49,
      34, 41, 61, 98, 59, 114, 101, 103, 105, 115, 116, 101, 114, 32, 108, 111,
      110, 103, 32, 120, 50, 32, 95, 95, 97, 115, 109, 95, 95, 40, 34, 120,
      50, 34, 41, 61, 99, 59, 114, 101, 103, 105, 115, 116, 101, 114, 32, 108,
      111, 110, 103, 32, 120, 51, 32, 95, 95, 97, 115, 109, 95, 95, 40, 34,
      120, 51, 34, 41, 61, 100, 59, 114, 101, 103, 105, 115, 116, 101, 114, 32,
      108, 111, 110, 103, 32, 120, 52, 32, 95, 95, 97, 115, 109, 95, 95, 40,
      34, 120, 52, 34, 41, 61, 101, 59, 114, 101, 103, 105, 115, 116, 101, 114,
      32, 108, 111, 110, 103, 32, 120, 53, 32, 95, 95, 97, 115, 109, 95, 95,
      40, 34, 120, 53, 34, 41, 61, 102, 59, 95, 95, 97, 115, 109, 95, 95,
      32, 95, 95, 118, 111, 108, 97, 116, 105, 108, 101, 95, 95, 40, 34, 115,
      118, 99, 32, 35, 48, 34, 58, 34, 43, 114, 34, 40, 120, 48, 41, 58,
      34, 114, 34, 40, 120, 56, 41, 44, 34, 114, 34, 40, 120, 49, 41, 44,
      34, 114, 34, 40, 120, 50, 41, 44, 34, 114, 34, 40, 120, 51, 41, 44,
      34, 114, 34, 40, 120, 52, 41, 44, 34, 114, 34, 40, 120, 53, 41, 58,
      34, 109, 101, 109, 111, 114, 121, 34, 41, 59, 114, 101, 116, 117, 114, 110,
      32, 120, 48, 59, 125, 10
    ];
    if (out == 0 as *CodegenOutBuf) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &guard_open[0], 46) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &h0[0], 158) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &h1[0], 172) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &h2[0], 186) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &h3[0], 200) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &h4[0], 251) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &h5[0], 299) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &h6[0], 347) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &elif_open[0], 49) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &a0[0], 205) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &a1[0], 214) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &a2[0], 262) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &a3[0], 310) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &a4[0], 358) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &a5[0], 406) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &a6[0], 454) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_from_ptr(out, &guard_close[0], 7) != 0) {
      return -1;
    }
    return 0;
  }
}

export function codegen_x_ast_emit_header(out: *CodegenOutBuf): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* #include <stdint.h>\n#include <stddef.h>\n#include <sys/types.h>\n#include <string.h>\n
     * Exact 83 bytes (20+20+23+20). Historic u8[88] + 7 trailing zeros was
     * 90 initializers → Ubuntu gcc "excess elements in array initializer"
     * when assembling codegen.x. Emit length is 83; no pad.
     * PLATFORM: SHARED host-C. G.7: same emit_header authority. */
    let h: u8[83] = [35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 105, 110, 116, 46, 104, 62, 10,
      35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 100, 101, 102, 46, 104, 62, 10,
      35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 121, 115, 47, 116, 121, 112, 101, 115, 46, 104, 62, 10,
      35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 114, 105, 110, 103, 46, 104, 62, 10];
    if (codegen_emit_bytes_from_ptr(out, &h[0], 83) != 0) {
      return -1;
    }
    /* #include <stdlib.h>\n#include <unistd.h>\n
     * Skip-decl assumes these exist (malloc/getenv in stdlib; getcwd/read/
     * write/unlink/access in unistd). Historic -E header omitted them →
     * L0 labi_path_pure.x host-cc: undeclared getcwd + int-to-pointer.
     * -o already injects the same via rt_preamble io_net.
     * PLATFORM: SHARED — POSIX uses system unistd.h; WINDOWS host-cc of
     * -E needs -Iinclude (compiler/include/unistd.h shim). Product L0
     * already passes -Iinclude. */
    let h2: u8[48] = [35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 108, 105, 98, 46, 104, 62, 10,
      35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 117, 110, 105, 115, 116, 100, 46, 104, 62, 10,
      0, 0, 0, 0, 0, 0, 0, 0];
    if (codegen_emit_bytes_64(out, &h2[0], 40) != 0) {
      return -1;
    }
    /*
     * Cap 10.7.1 slice7: Cap va_list face for language builtins.
     * `#include <xlang_va_cap.h>` — xlang_va_list / xlang_va_start/arg/end/copy.
     * Consumed by codegen_try_emit_va_cap_call + VaList codegen_emit_type.
     * Product -o also has -Iinclude; bare -E needs the same include path.
     * PLATFORM: SHARED host-C. G.7: emit_header is the -E authority.
     */
    /* #include <xlang_va_cap.h>\n — 26 bytes exact. */
    let hva: u8[26] = [35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 120, 108, 97, 110, 103, 95, 118, 97, 95, 99, 97, 112, 46, 104, 62, 10];
    if (codegen_emit_bytes_from_ptr(out, &hva[0], 26) != 0) {
      return -1;
    }
    /*
     * Stage 10 S3.1 (10.1.1+10.1.2): raw syscall helpers behind
     * `#if linux && x86_64` / `#elif linux && aarch64` (host cc preprocessor
     * is the platform truth; Darwin drops both). Consumed only by
     * codegen_try_emit_raw_syscall_call call sites; __attribute__((unused))
     * keeps TUs without syscalls warning-free.
     * PLATFORM: SHARED host-C. G.7: emit_header is the -E authority.
     */
    if (codegen_emit_raw_syscall_helpers(out) != 0) {
      return -1;
    }
    /* SIMD typedefs after libc includes (int32_t / float available).
     * dest extra-arm SIMD host-C used to fail: unknown type i32x4_t,
     * then cascade undeclared a/b/z in STRUCT_LIT fields.
     * PLATFORM: SHARED host-C. G.7: emit_header is the -E authority. */
    if (codegen_emit_vector_typedefs(out) != 0) {
      return -1;
    }
    /*
     * TYPE_DYN fat layout (foundation leaf). Host-C formals/locals of
     * `dyn Trait` lower as `struct xlang_dyn_obj` — not incomplete
     * `struct Trait` (empty-struct paint ban). Vtable dispatch later.
     * 103 bytes total (exact). PLATFORM: SHARED host-C.
     * G.7: emit_header + type_to_c_repr.
     */
    /* #ifndef XLANG_DYN_OBJ\n#define XLANG_DYN_OBJ\nstruct xlang_dyn_obj { void *data; void *vtable; };\n#endif\n */
    let gd: u8[103] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 68, 89,
      78, 95, 79, 66, 74, 10, 35, 100, 101, 102, 105, 110, 101, 32, 88, 76,
      65, 78, 71, 95, 68, 89, 78, 95, 79, 66, 74, 10, 115, 116, 114, 117,
      99, 116, 32, 120, 108, 97, 110, 103, 95, 100, 121, 110, 95, 111, 98, 106,
      32, 123, 32, 118, 111, 105, 100, 32, 42, 100, 97, 116, 97, 59, 32, 118,
      111, 105, 100, 32, 42, 118, 116, 97, 98, 108, 101, 59, 32, 125, 59, 10,
      35, 101, 110, 100, 105, 102, 10
    ];
    if (codegen_emit_bytes_from_ptr(out, &gd[0], 103) != 0) {
      return -1;
    }
    /* #ifndef XLANG_SLICE_LAYOUTS\n#define XLANG_SLICE_LAYOUTS\n */
    let g0: u8[64] = [35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76, 73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76, 73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 10, 0];
    if (codegen_emit_bytes_64(out, &g0[0], 56) != 0) {
      return -1;
    }
    /*
     * 4.2.3: loop nest 1..8 (same set as rt_preamble XLANG_SLICE_LAYOUTS).
     * Piecewise helper — wave698 u8[256] whole-line emit cannot grow past 8.
     * PLATFORM: SHARED host-C. G.7: same elem set as rt_preamble.
     */
    if (codegen_emit_scalar_slice_nests(out, 1, 8) != 0) {
      return -1;
    }
    /* #endif\n */
    let ge: u8[8] = [35, 101, 110, 100, 105, 102, 10, 0];
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * 4.2.3 deep nests 9..16 under a second guard so -o (rt_preamble already
     * defined XLANG_SLICE_LAYOUTS for 1..8) still emits the extra layers.
     * -E runs both blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224 skip ranges).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N16\n#define XLANG_SLICE_LAYOUTS_N16\n */
    let g16: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 49, 54, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 49, 54, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g16[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 9, 16) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>16 soft: layer 17 under a third guard so -o (rt_preamble 1..8 +
     * N16 9..16 already defined) still emits the extra layer. -E runs
     * all three blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224 skip ranges). Do not grow seed emit_header u8[256].
     * type_to_c_repr scratch is 384 (nest 21 i32 tag=266).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N17\n#define XLANG_SLICE_LAYOUTS_N17\n */
    let g17: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 49, 55, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 49, 55, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g17[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 17, 17) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>17 soft: layer 18 under a fourth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17) still emits the extra layer. -E runs all four blocks.
     * Do not add rows to driver_preamble_io_net_lines (fixed N=224).
     * Do not grow seed emit_header u8[256]. type_to_c_repr scratch is 384
     * (nest 18 i32 tag=230; nest 21=266).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N18\n#define XLANG_SLICE_LAYOUTS_N18\n */
    let g18: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 49, 56, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 49, 56, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g18[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 18, 18) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>18 soft: layer 19 under a fifth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18) still emits the extra layer. -E runs all five
     * blocks. Do not add rows to driver_preamble_io_net_lines (fixed N=224).
     * Do not grow seed emit_header u8[256]. type_to_c_repr scratch is 384
     * (nest 19 i32 tag=242; nest 20=254; nest 21=266).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N19\n#define XLANG_SLICE_LAYOUTS_N19\n */
    let g19: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 49, 57, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 49, 57, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g19[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 19, 19) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>19 soft: layer 20 under a sixth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19) still emits the extra layer. -E runs
     * all six blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 384 (nest 20 i32 tag=254; nest 21=266).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N20\n#define XLANG_SLICE_LAYOUTS_N20\n */
    let g20: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 48, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 48, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g20[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 20, 20) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>20 soft: layer 21 under a seventh guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20) still emits the extra layer. -E
     * runs all seven blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 384 so nest 21 i32 tag=266 and nest 22=278 fit.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N21\n#define XLANG_SLICE_LAYOUTS_N21\n */
    let g21: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 49, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 49, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g21[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 21, 21) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>21 soft: layer 22 under an eighth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20 + N21) still emits the extra layer.
     * -E runs all eight blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 384 so nest 22 i32 tag=278 and nest 23=290 fit.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N22\n#define XLANG_SLICE_LAYOUTS_N22\n */
    let g22: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 50, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 50, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g22[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 22, 22) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>22 soft: layer 23 under a ninth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20 + N21 + N22) still emits the extra
     * layer. -E runs all nine blocks. Do not add rows to
     * driver_preamble_io_net_lines (fixed N=224). Do not grow seed
     * emit_header u8[256]. type_to_c_repr scratch is 384 so nest 23 i32
     * tag=290 and nest 24=302 fit. Do not raise to 25.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N23\n#define XLANG_SLICE_LAYOUTS_N23\n */
    let g23: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 51, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 51, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g23[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 23, 23) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>23 soft: layer 24 under a tenth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20 + N21 + N22 + N23) still emits the
     * extra layer. -E runs all ten blocks. Do not add rows to
     * driver_preamble_io_net_lines (fixed N=224). Do not grow seed
     * emit_header u8[256]. type_to_c_repr scratch is 384 so nest 24 i32
     * tag=302 and nest 25=314 fit. Do not raise to 26.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N24\n#define XLANG_SLICE_LAYOUTS_N24\n */
    let g24: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 52, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 52, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g24[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 24, 24) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>24 soft: layer 25 under an eleventh guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20 + N21 + N22 + N23 + N24) still emits
     * the extra layer. -E runs all eleven blocks. Do not add rows to
     * driver_preamble_io_net_lines (fixed N=224). Do not grow seed
     * emit_header u8[256]. type_to_c_repr scratch is 384 so nest 25 i32
     * tag=314 and nest 26=326 fit. Do not raise to 27.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N25\n#define XLANG_SLICE_LAYOUTS_N25\n */
    let g25: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 53, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 53, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g25[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 25, 25) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>25 soft: layer 26 under a twelfth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20 + N21 + N22 + N23 + N24 + N25) still
     * emits the extra layer. -E runs all twelve blocks. Do not add rows to
     * driver_preamble_io_net_lines (fixed N=224). Do not grow seed
     * emit_header u8[256]. type_to_c_repr scratch is 384 so nest 26 i32
     * tag=326 and nest 27=338 fit. Do not raise to 28.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N26\n#define XLANG_SLICE_LAYOUTS_N26\n */
    let g26: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 54, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 54, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g26[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 26, 26) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>26 soft: layer 27 under a thirteenth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20 + N21 + N22 + N23 + N24 + N25 + N26) still
     * emits the extra layer. -E runs all thirteen blocks. Do not add rows to
     * driver_preamble_io_net_lines (fixed N=224). Do not grow seed
     * emit_header u8[256]. type_to_c_repr scratch is 384 so nest 27 i32
     * tag=338 and nest 28=350 fit.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N27\n#define XLANG_SLICE_LAYOUTS_N27\n */
    let g27: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 55, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 55, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g27[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 27, 27) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>27 soft: layer 28 under a fourteenth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20 + N21 + N22 + N23 + N24 + N25 + N26 +
     * N27) still emits the extra layer. -E runs all fourteen blocks. Do not
     * add rows to driver_preamble_io_net_lines (fixed N=224). Do not grow
     * seed emit_header u8[256]. type_to_c_repr scratch is 384 so nest 28
     * i32 tag=350 and nest 29=362 fit.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N28\n#define XLANG_SLICE_LAYOUTS_N28\n */
    let g28: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 56, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 56, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g28[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 28, 28) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>28 soft: layer 29 under a fifteenth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20 + N21 + N22 + N23 + N24 + N25 + N26 +
     * N27 + N28) still emits the extra layer. -E runs all fifteen blocks. Do
     * not add rows to driver_preamble_io_net_lines (fixed N=224). Do not grow
     * seed emit_header u8[256]. type_to_c_repr scratch is 384 so nest 29
     * i32 tag=362 and nest 30=374 fit.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N29\n#define XLANG_SLICE_LAYOUTS_N29\n */
    let g29: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 57, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 50, 57, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g29[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 29, 29) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>29 soft: layer 30 under a sixteenth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20 + N21 + N22 + N23 + N24 + N25 + N26 +
     * N27 + N28 + N29) still emits the extra layer. -E runs all sixteen
     * blocks. Do not add rows to driver_preamble_io_net_lines (fixed N=224).
     * Do not grow seed emit_header u8[256]. type_to_c_repr scratch is 512
     * so nest 30 i32 tag=374 and nest 31=386 fit.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N30\n#define XLANG_SLICE_LAYOUTS_N30\n */
    let g30: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 48, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 48, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g30[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 30, 30) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>30 soft: layer 31 under a seventeenth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20 + N21 + N22 + N23 + N24 + N25 + N26 +
     * N27 + N28 + N29 + N30) still emits the extra layer. -E runs all
     * seventeen blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 512 so nest 31 i32 tag=386 and nest 32=398 fit. Do not
     * raise to 33 this leaf (tag=410 still fits 512; one layer at a time).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N31\n#define XLANG_SLICE_LAYOUTS_N31\n */
    let g31: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 49, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 49, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g31[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 31, 31) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>31 soft: layer 32 under an eighteenth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17 + N18 + N19 + N20 + N21 + N22 + N23 + N24 + N25 + N26 +
     * N27 + N28 + N29 + N30 + N31) still emits the extra layer. -E runs all
     * eighteen blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 512 so nest 32 i32 tag=398 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N32\n#define XLANG_SLICE_LAYOUTS_N32\n */
    let g32: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 50, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 50, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g32[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 32, 32) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>32 soft: layer 33 under a nineteenth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N32) still emits the extra layer. -E runs all
     * nineteen blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 512 so nest 33 i32 tag=410 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N33\n#define XLANG_SLICE_LAYOUTS_N33\n */
    let g33: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 51, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 51, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g33[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 33, 33) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>33 soft: layer 34 under a twentieth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N33) still emits the extra layer. -E runs all
     * twenty blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 512 so nest 34 i32 tag=422 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N34\n#define XLANG_SLICE_LAYOUTS_N34\n */
    let g34: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 52, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 52, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g34[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 34, 34) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>34 soft: layer 35 under a twenty-first guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N34) still emits the extra layer. -E runs all
     * twenty-one blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 512 so nest 35 i32 tag=434 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N35\n#define XLANG_SLICE_LAYOUTS_N35\n */
    let g35: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 53, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 53, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g35[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 35, 35) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>35 soft: layer 36 under a twenty-second guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N35) still emits the extra layer. -E runs all
     * twenty-two blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 512 so nest 36 i32 tag=446 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N36\n#define XLANG_SLICE_LAYOUTS_N36\n */
    let g36: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 54, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 54, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g36[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 36, 36) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>36 soft: layer 37 under a twenty-third guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N36) still emits the extra layer. -E runs all
     * twenty-three blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 512 so nest 37 i32 tag=458 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N37\n#define XLANG_SLICE_LAYOUTS_N37\n */
    let g37: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 55, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 55, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g37[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 37, 37) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>37 soft: layer 38 under a twenty-fourth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N37) still emits the extra layer. -E runs all
     * twenty-four blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 512 so nest 38 i32 tag=470 fits. Do not raise to 39 this
     * leaf (tag=482 still fits 512; one layer at a time).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N38\n#define XLANG_SLICE_LAYOUTS_N38\n */
    let g38: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 56, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 56, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g38[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 38, 38) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>38 soft: layer 39 under a twenty-fifth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N38) still emits the extra layer. -E runs all
     * twenty-five blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 512 so nest 39 i32 tag=482 fits. Do not raise to 40 this
     * leaf (tag=494 still fits 512; one layer at a time).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N39\n#define XLANG_SLICE_LAYOUTS_N39\n */
    let g39: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 57, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 51, 57, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g39[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 39, 39) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>39 soft: layer 40 under a twenty-sixth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N39) still emits the extra layer. -E runs all
     * twenty-six blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 512 so nest 40 i32 tag=494 fits. Do not raise to 41 this
     * leaf (tag=506 still fits 512; one layer at a time).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N40\n#define XLANG_SLICE_LAYOUTS_N40\n */
    let g40: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 48, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 48, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g40[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 40, 40) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>40 soft: layer 41 under a twenty-seventh guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N40) still emits the extra layer. -E runs all
     * twenty-seven blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 512 so nest 41 i32 tag=506 fits. Do not raise to 42 this
     * leaf (tag=518 overflows 512; one layer at a time).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N41\n#define XLANG_SLICE_LAYOUTS_N41\n */
    let g41: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 49, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 49, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g41[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 41, 41) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>41 soft: layer 42 under a twenty-eighth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N41) still emits the extra layer. -E runs all
     * twenty-eight blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 640 so nest 42 i32 tag=518 fits. Do not raise to 43 this
     * leaf (tag=530 still fits 640; one layer at a time).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N42\n#define XLANG_SLICE_LAYOUTS_N42\n */
    let g42: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 50, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 50, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g42[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 42, 42) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>42 soft: layer 43 under a twenty-ninth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N42) still emits the extra layer. -E runs all
     * twenty-nine blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 640 so nest 43 i32 tag=530 fits. Do not raise to 44 this
     * leaf (tag=542 still fits 640; one layer at a time).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N43\n#define XLANG_SLICE_LAYOUTS_N43\n */
    let g43: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 51, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 51, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g43[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 43, 43) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>43 soft: layer 44 under a thirtieth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N43) still emits the extra layer. -E runs all
     * thirty blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 640 so nest 44 i32 tag=542 fits. Do not raise to 45 this
     * leaf (tag=554 still fits 640; one layer at a time).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N44\n#define XLANG_SLICE_LAYOUTS_N44\n */
    let g44: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 52, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 52, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g44[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 44, 44) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>44 soft: layer 45 under a thirty-first guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N44) still emits the extra layer. -E runs all
     * thirty-one blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 640 so nest 45 i32 tag=554 fits. Do not raise to 46 this
     * leaf (tag=566 still fits 640; one layer at a time).
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N45\n#define XLANG_SLICE_LAYOUTS_N45\n */
    let g45: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 53, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 53, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g45[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 45, 45) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>45 soft: layer 46 under a thirty-second guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N45) still emits the extra layer. -E runs all
     * thirty-two blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 640 so nest 46 i32 tag=566 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N46\n#define XLANG_SLICE_LAYOUTS_N46\n */
    let g46: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 54, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 54, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g46[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 46, 46) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>46 soft: layer 47 under a thirty-third guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N46) still emits the extra layer. -E runs all
     * thirty-three blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 640 so nest 47 i32 tag=578 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N47\n#define XLANG_SLICE_LAYOUTS_N47\n */
    let g47: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 55, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 55, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g47[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 47, 47) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>47 soft: layer 48 under a thirty-fourth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N47) still emits the extra layer. -E runs all
     * thirty-four blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 640 so nest 48 i32 tag=590 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N48\n#define XLANG_SLICE_LAYOUTS_N48\n */
    let g48: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 56, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 56, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g48[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 48, 48) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>48 soft: layer 49 under a thirty-fifth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N48) still emits the extra layer. -E runs all
     * thirty-five blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 640 so nest 49 i32 tag=602 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N49\n#define XLANG_SLICE_LAYOUTS_N49\n */
    let g49: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 57, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 52, 57, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g49[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 49, 49) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>49 soft: layer 50 under a thirty-sixth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N49) still emits the extra layer. -E runs all
     * thirty-six blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 640 so nest 50 i32 tag=614 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N50\n#define XLANG_SLICE_LAYOUTS_N50\n */
    let g50: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 53, 48, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 53, 48, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g50[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 50, 50) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>50 soft: layer 51 under a thirty-seventh guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N50) still emits the extra layer. -E runs all
     * thirty-seven blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 640 so nest 51 i32 tag=626 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N51\n#define XLANG_SLICE_LAYOUTS_N51\n */
    let g51: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 53, 49, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 53, 49, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g51[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 51, 51) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>51 soft: layer 52 under a thirty-eighth guard so -o (rt_preamble 1..8 +
     * N16 9..16 + N17..N51) still emits the extra layer. -E runs all
     * thirty-eight blocks. Do not add rows to driver_preamble_io_net_lines
     * (fixed N=224). Do not grow seed emit_header u8[256]. type_to_c_repr
     * scratch is 640 so nest 52 i32 tag=638 fits.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N52\n#define XLANG_SLICE_LAYOUTS_N52\n */
    let g52: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 53, 50, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 53, 50, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g52[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 52, 52) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    /*
     * nest>52 jump: layers 53..64 under one thirty-ninth guard so -o
     * (rt_preamble 1..8 + N16 9..16 + N17..N52) still emits the extra
     * layers. -E runs all thirty-nine blocks. Do not add rows to
     * driver_preamble_io_net_lines (fixed N=224). Do not grow seed
     * emit_header u8[256]. type_to_c_repr scratch is 896 so nest 64
     * i32 tag=782 fits. Product freeze at 64; do not raise to 65.
     * PLATFORM: SHARED host-C. G.7: emit_header is the deep-nest authority.
     */
    /* #ifndef XLANG_SLICE_LAYOUTS_N64\n#define XLANG_SLICE_LAYOUTS_N64\n */
    let g64: u8[80] = [
      35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 54, 52, 10,
      35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76,
      73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 95, 78, 54, 52, 10,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    if (codegen_emit_bytes_from_ptr(out, &g64[0], 64) != 0) {
      return -1;
    }
    if (codegen_emit_scalar_slice_nests(out, 53, 64) != 0) {
      return -1;
    }
    if (codegen_emit_bytes_64(out, &ge[0], 7) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export extern function pipeline_codegen_std_dep_link_only(path: *u8): i32;

/** Exported function `codegen_x_ast`.
 * Implements `codegen_x_ast`.
 * @param module *Module
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param ctx *PipelineDepCtx
 * @param dep_index i32
 * @return i32
 */
export function codegen_x_ast(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, ctx: *PipelineDepCtx, dep_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* See implementation. */
    if (ctx != 0 as *PipelineDepCtx) {
      ctx.current_codegen_module = module;
      ctx.current_codegen_arena = arena;
      ctx.current_codegen_dep_index = dep_index;
    }
    /* See implementation. */
    let prefix_buf: u8[256] = [];
    let prefix_len: i32 = 0;
    let dep_path_prefix: u8[256] = [];
    let dep_path_prefix_len: i32 = 0;
    if (dep_index >= 0 && ctx != 0 as *PipelineDepCtx) {
      dep_path_prefix_len = codegen_dep_import_path_len_at(ctx, dep_index, &dep_path_prefix[0]);
      /* See implementation. */
      if (dep_path_prefix_len > 0 && pipeline_codegen_std_dep_link_only(&dep_path_prefix[0]) != 0) {
        return 0;
      }
    }
    if (dep_index >= 0 && ctx != 0 as *PipelineDepCtx && dep_path_prefix_len > 0) {
      /* See implementation. */
      if (codegen_path_is_std_io_core_bytes(&dep_path_prefix[0]) == 0) {
        codegen_import_path_to_c_prefix_into(&dep_path_prefix[0], &prefix_buf[0], 128);
        while (prefix_len < 128 && prefix_buf[prefix_len] != 0) {
          prefix_len = prefix_len + 1;
        }
      }
    }
    /* See implementation. */
    if (prefix_len == 0 && (dep_index < 0 || dep_path_prefix_len == 0 || codegen_path_is_std_io_core_bytes(&dep_path_prefix[0]) == 0)) {
      prefix_len = 0;
      prefix_buf[0] = 0 as u8;
      if (dep_path_prefix_len > 0) {
        codegen_import_path_to_c_prefix_into(&dep_path_prefix[0], &prefix_buf[0], 128);
        while (prefix_len < 128 && prefix_buf[prefix_len] != 0) {
          prefix_len = prefix_len + 1;
        }
      }
    }
    /*
     * See implementation.
     * See implementation.
     * See implementation.
     * See implementation.
     *   incomplete struct String）。
     * See implementation.
     * See implementation.
     */
    if (prefix_len == 0 && dep_index < 0 && ctx != 0 as *PipelineDepCtx) {
      if (ctx.entry_module_import_path_len > 0) {
        let pi: i32 = 0;
        while (pi < ctx.entry_module_import_path_len && pi < 127) {
          prefix_buf[pi] = ctx.entry_module_import_path_mirror[pi];
          pi = pi + 1;
        }
        prefix_buf[pi] = 0 as u8;
        prefix_len = pi;
      }
    }
    if (ctx != 0 as *PipelineDepCtx) {
      ctx.current_codegen_prefix_len = 0;
      let px: i32 = 0;
      while (px < prefix_len && px < 63) {
        ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
        px = px + 1;
      }
      ctx.current_codegen_prefix_mirror[px] = 0 as u8;
      ctx.current_codegen_prefix_len = px;
    }
    /* See implementation. */
    let call_init_globals: i32 = 0;
    if (module.num_top_level_lets > 0) {
      let ti: i32 = 0;
      while (ti < module.num_top_level_lets) {
        if (pipeline_module_top_level_let_is_const(module, ti) == 0) {
          call_init_globals = 1;
          break;
        }
        ti = ti + 1;
      }
    }
    let i: i32 = 0;
    /*
     * Consts-only dep modules have num_funcs==0, so the func loop never
     * ran i==0 and skipped file-static `A` / `K`. Force one i==0 pass
     * to emit top-level lets, then break before func-body (i is not a
     * valid func index). PLATFORM: SHARED host-C co-emit.
     */
    let emit_n: i32 = module.num_funcs;
    if (emit_n == 0 && module.num_top_level_lets > 0) {
      emit_n = 1;
    }
    while (i < emit_n) {
      if (i == 0) {
        /*
         * See implementation.
         * See implementation.
         * See implementation.
         * See implementation.
         * See implementation.
         */
        if (pipeline_codegen_c_file_prologue_done_get() == 0) {
          if (codegen_x_ast_emit_header(out) != 0) {
            return -1;
          }
          if (codegen_emit_skipped_dep_type_definitions(ctx, out) != 0) {
            return -1;
          }
          /*
           * Restore current_codegen_module after dep type walk.
           * Purpose: skipped_dep_type_definitions may leave ctx pointing at the last
           *   dep visited; CALL binding resolution (fmt.fmt_*) and same-module bare
           *   names (unwrap_or) then mangle with the wrong prefix.
           * Authority: seeds/codegen_gen.linux.x86_64.c codegen_x_ast after
           *   codegen_emit_skipped_dep_type_definitions.
           * PLATFORM: SHARED — multi-dep co-emit C TU; verify Cap force hello/si.
           */
          if (ctx != 0 as *PipelineDepCtx) {
            ctx.current_codegen_module = module;
            ctx.current_codegen_arena = arena;
          }
          if (codegen_emit_dep_struct_forward_declarations(ctx, out) != 0) {
            return -1;
          }
          pipeline_codegen_c_file_prologue_done_set(1);
        }
        /* See implementation. */
        if (codegen_emit_import_dep_function_declarations(module, out, ctx) != 0) {
          return -1;
        }
        /* See implementation. */
        if (dep_index < 0) {
          if (codegen_emit_module_enum_definitions(module, out, &prefix_buf[0], prefix_len) != 0) {
            return -1;
          }
          if (codegen_emit_module_struct_definitions(module, arena, out, &prefix_buf[0], prefix_len, ctx) != 0) {
            return -1;
          }
          /*
           * [][N]T / []*T fat layouts (not in rt_preamble N=224). After
           * skipped-dep + entry struct defs so NAMED leaves (`[][2]Pair`)
           * are complete: `struct Pair (*data)[2]` needs sizeof(Pair).
           * Sit-red host-C BLD001: walker ran at prologue (before
           * `struct Pair`). Scalar `[][2]i32` does not need a NAMED tag.
           * G.7: same emitter, later call site (no second layout walker).
           * PLATFORM: SHARED host-C.
           */
          if (codegen_emit_slice_of_fixed_array_layouts(arena, out, ctx) != 0) {
            return -1;
          }
        }
        /*
         * Same-module forward prototypes (body-front extern wall).
         * Purpose: co-emitted TU may call later functions in the same module (e.g.
         *   core_option_map_ptr_u8 → core_option_is_some_ptr_u8). Without prototypes,
         *   host C99 rejects implicit declarations even when the definition follows.
         * Authority: same loop as seeds/codegen_gen.linux.x86_64.c codegen_x_ast
         *   (emit_func_extern_declaration for every non-extern func before bodies).
         * PLATFORM: SHARED — C TU ordering; verify mac + Ubuntu option force-regen.
         * Does not re-pin seed: seed already has this wall; Cap was missing it in .x.
         */
        let fwd_fi: i32 = 0;
        while (fwd_fi < module.num_funcs) {
          if (pipeline_module_func_is_extern_at(module, fwd_fi) == 0) {
            if (emit_func_extern_declaration(arena, out, module, fwd_fi, &prefix_buf[0], prefix_len, ctx) != 0) {
              return -1;
            }
          }
          fwd_fi = fwd_fi + 1;
        }
        /*
         * F4: per-impl vtable statics.
         * Purpose: hoist F3 inline coerce-site vtable to module-level static
         *   `xlang_vtable_<Trait>_for_[Ptr_]<Type>[N]` so multiple impls of the
         *   same trait can coexist (F3 inline had no stable name and could not
         *   be shared across coerce sites). Emitted only for the entry module
         *   pass (dep_index < 0) because the impl registry is global across the
         *   co-emitted TU; emitting per-module pass would duplicate definitions.
         *   Statics are visible to all function bodies that follow (forward
         *   prototypes wall above already declared impl method link names).
         * Authority: codegen_emit_module_vtable_statics (G.7 single path) +
         *   codegen_emit_vtable_slot_payload (shared per-slot payload).
         * PLATFORM: SHARED — mirrors seeds/codegen_gen.linux.x86_64.c; verify
         *   mac + Ubuntu option force-regen.
         * First cut: NAMED for-type only; builtin for-types fall back to F3
         *   inline path. Dep-module impls resolve to null slots here because
         *   codegen_find_impl_method_for_type is module-scoped; multi-module
         *   impls are a follow-up.
         */
        if (dep_index < 0) {
          if (codegen_emit_module_vtable_statics(arena, out, ctx) != 0) {
            return -1;
          }
        }
        /* See implementation. */
        if (module.num_top_level_lets > 0) {
          let ti: i32 = 0;
          while (ti < module.num_top_level_lets) {
            let is_const: i32 = pipeline_module_top_level_let_is_const(module, ti);
            let name_len: i32 = pipeline_module_top_level_let_name_len(module, ti);
            if (name_len <= 0 || name_len > 255) {
              ti = ti + 1;
              continue;
            }
            let tl_name_buf: u8[256] = [];
            let tni: i32 = 0;
            while (tni < name_len && tni < 64) {
              tl_name_buf[tni] = pipeline_module_top_level_let_name_byte_at(module, ti, tni);
              tni = tni + 1;
            }
            let tl_ty: i32 = pipeline_module_top_level_let_type_ref(module, ti);
            let tl_init: i32 = pipeline_module_top_level_let_init_ref(module, ti);
            let is_fixed_arr: i32 = 0;
            if (!ast.ref_is_null(tl_ty) && pipeline_type_kind_ord_at(arena, tl_ty) == (TypeKind.TYPE_ARRAY as i32)) {
              is_fixed_arr = 1;
            }
            /* PLATFORM: SHARED — product preamble may #define O_CREAT/MAP_FAILED/S_IFMT for
             * bare EXPR_VAR use when dep export const was historically not co-emitted. Now
             * that top-level const/let are emitted as C objects, redeclaring the same name
             * under an active macro is illegal (e.g. static const MAP_FAILED expands to
             * static const ((int64_t)-1)). #undef first so the object is the single C
             * authority; values still match std/fs/posix.x + preamble. */
            let undef_kw: u8[8] = [35, 117, 110, 100, 101, 102, 32, 0]; /* "#undef " */
            if (codegen_emit_bytes_from_ptr(out, &undef_kw[0], 7) != 0) {
              return -1;
            }
            if (codegen_emit_bytes_from_ptr(out, &tl_name_buf[0], name_len) != 0) {
              return -1;
            }
            if (codegen_append_byte(out, 10) != 0) {
              return -1;
            }
            if (is_const != 0) {
              let static_const: u8[15] = [115, 116, 97, 116, 105, 99, 32, 99, 111, 110, 115, 116, 32, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &static_const[0], 13) != 0) {
                return -1;
              }
            } else {
              let static_: u8[9] = [115, 116, 97, 116, 105, 99, 32, 0, 0];
              if (codegen_emit_bytes_from_ptr(out, &static_[0], 7) != 0) {
                return -1;
              }
            }
            if (is_fixed_arr != 0) {
              if (codegen_emit_local_fixed_array_elem_type(arena, out, tl_ty, ctx) != 0) {
                return -1;
              }
            } else {
              if (codegen_emit_type(arena, out, tl_ty, &prefix_buf[0], 0, ctx) != 0) {
                return -1;
              }
            }
            if (codegen_append_byte(out, 32) != 0) {
              return -1;
            }
            if (codegen_emit_bytes_from_ptr(out, &tl_name_buf[0], name_len) != 0) {
              return -1;
            }
            if (is_fixed_arr != 0) {
              if (codegen_emit_local_fixed_array_suffix(arena, out, tl_ty) != 0) {
                return -1;
              }
            }
            /* Declaration-site init policy (C static storage):
             * - Fixed arrays: write init at decl (empty [] → BSS zeros; no compound-lit pointer).
             * - Non-array const: keep `= init` at decl.
             * - Non-array mutable let: decl-site ONLY when init is C static-const
             *   (pipeline_expr_is_c_static_const_init: pure lit trees, e.g. -1).
             *   Why: library/dep TUs have no main, so init_globals never runs; BSS zero-init
             *   would wipe sentinels like xlang_heap_trace_on = -1 (heap_trace never enables).
             *   VAR-dependent inits (e.g. let b = a + 2) are illegal as C static initializers
             *   and must remain init_globals-only (two_lets / run-toplevel-let).
             *   init_globals may still re-assign pure lits on entry co-emit (idempotent).
             * PLATFORM: SHARED — C .data vs .bss; non-zero static init must not become BSS 0. */
            let want_decl_init: i32 = 0;
            if (is_fixed_arr != 0 && !ast.ref_is_null(tl_init)) {
              if (pipeline_expr_kind_ord_at(arena, tl_init) == (46 as i32)) {
                if (pipeline_expr_array_lit_num_elems_at(arena, tl_init) > 0) {
                  want_decl_init = 1;
                }
              } else {
                want_decl_init = 1;
              }
            }
            if (is_const != 0 && is_fixed_arr == 0 && !ast.ref_is_null(tl_init)) {
              want_decl_init = 1;
            }
            /* Mutable scalar let: lit/const-expr only (not free-VAR trees). */
            if (is_const == 0 && is_fixed_arr == 0 && !ast.ref_is_null(tl_init)) {
              if (pipeline_expr_is_c_static_const_init(arena, tl_init) != 0) {
                want_decl_init = 1;
              }
            }
            if (want_decl_init != 0) {
              let eq: u8[4] = [32, 61, 32, 0];
              if (codegen_emit_bytes_4(out, &eq[0], 3) != 0) {
                return -1;
              }
              if (is_fixed_arr != 0) {
                /*
                 * Module `[N][]T` ARRAY_LIT: same produce as dest-SLICE
                 * `[][]T` — emit_braced injects statement-expr rows
                 * (illegal C static). File-scope row wrap is an address
                 * constant. Other dest-ARRAY still emit_braced.
                 * PLATFORM: SHARED host-C.
                 */
                let fa_slice_rows: i32 = 0;
                if (!ast.ref_is_null(tl_init)
                    && pipeline_expr_kind_ord_at(arena, tl_init) == 46
                    && codegen_array_lit_tree_is_const(arena, tl_init) != 0) {
                  let fa_elem: i32 = pipeline_type_elem_ref_at(arena, tl_ty);
                  if (!ast.ref_is_null(fa_elem) && fa_elem > 0
                      && pipeline_type_kind_ord_at(arena, fa_elem) == 11) {
                    let fa_n: i32 = pipeline_expr_array_lit_num_elems_at(arena, tl_init);
                    let fa_ok: i32 = 0;
                    if (fa_n > 0) {
                      fa_ok = 1;
                      let fa_i: i32 = 0;
                      while (fa_i < fa_n && fa_ok != 0) {
                        let fa_er: i32 = pipeline_expr_array_lit_elem_ref(arena, tl_init, fa_i);
                        if (ast.ref_is_null(fa_er) || fa_er <= 0
                            || pipeline_expr_kind_ord_at(arena, fa_er) != 46) {
                          fa_ok = 0;
                        }
                        fa_i = fa_i + 1;
                      }
                    }
                    if (fa_ok != 0) {
                      if (codegen_append_byte(out, 123) != 0) {
                        return -1;
                      }
                      let fa_j: i32 = 0;
                      while (fa_j < fa_n) {
                        if (fa_j > 0) {
                          let fa_cm: u8[3] = [44, 32, 0];
                          if (codegen_emit_bytes_3(out, &fa_cm[0], 2) != 0) {
                            return -1;
                          }
                        }
                        let fa_er2: i32 = pipeline_expr_array_lit_elem_ref(arena, tl_init, fa_j);
                        let fa_row: i32 = codegen_emit_file_scope_dest_slice_array_lit(
                          arena, out, fa_elem, fa_er2, ctx);
                        if (fa_row <= 0) {
                          return -1;
                        }
                        fa_j = fa_j + 1;
                      }
                      if (codegen_append_byte(out, 125) != 0) {
                        return -1;
                      }
                      fa_slice_rows = 1;
                    }
                  }
                }
                if (fa_slice_rows == 0) {
                  if (codegen_emit_braced_array_lit_init(arena, out, tl_init, ctx) != 0) {
                    return -1;
                  }
                }
              } else {
                /*
                 * dest-SLICE module const/let: same wrap as codegen_emit_block.
                 * Prior: codegen_emit_expr only → `static const T s = (A)[1]`
                 * (pointer into slice struct) → host-cc BLD001.
                 * G.7: reuse try_emit_slice_init_from_array_var.
                 * block_ref/let_idx = 0; VAR N comes from module scan.
                 * Typed compound is a legal GNU C static initializer when
                 * .data is an address constant. PLATFORM: SHARED host-C.
                 */
                let slice_tl: i32 = 0;
                if (!ast.ref_is_null(tl_ty)
                    && pipeline_type_kind_ord_at(arena, tl_ty) == 11) {
                  if (ctx != 0 as *PipelineDepCtx) {
                    ctx.current_codegen_module = module;
                    ctx.current_codegen_arena = arena;
                  }
                  slice_tl = try_emit_slice_init_from_array_var(
                    arena, out, 0, 0, tl_ty, tl_init, ctx);
                }
                if (slice_tl == 0) {
                  /*
                   * Module VAR dest-SLICE: try_emit cannot walk the module
                   * table (slot cap). G.7: shared caller fallback.
                   * PLATFORM: SHARED host-C.
                   */
                  slice_tl = try_emit_dest_slice_from_module_array_var(
                    arena, out, tl_ty, tl_init, ctx);
                }
                if (slice_tl < 0) {
                  return -1;
                } else if (slice_tl == 0) {
                  /*
                   * Module dest-SLICE ARRAY_LIT: codegen_emit_expr uses
                   * ({ static E al[]={…}; (T){.data=al,.length=N}; })
                   * — illegal as a C static initializer (BLD001).
                   * File-scope (E[]){…} / nested [][]T row wrap is an
                   * address constant. Do not add ARRAY_LIT to try_emit:
                   * init_globals also calls it with block_ref=0 and
                   * would dangle. PLATFORM: SHARED host-C.
                   */
                  let al_got: i32 = codegen_emit_file_scope_dest_slice_array_lit(
                    arena, out, tl_ty, tl_init, ctx);
                  if (al_got < 0) {
                    return -1;
                  } else if (al_got == 0) {
                    if (codegen_emit_expr(arena, out, tl_init, ctx) != 0) {
                      return -1;
                    }
                  }
                }
              }
            }
            let sc: u8[3] = [59, 10, 0];
            if (codegen_emit_bytes_3(out, &sc[0], 2) != 0) {
              return -1;
            }
            ti = ti + 1;
          }
          let any_let: i32 = 0;
          ti = 0;
          while (ti < module.num_top_level_lets) {
            if (pipeline_module_top_level_let_is_const(module, ti) == 0) {
              any_let = 1;
              break;
            }
            ti = ti + 1;
          }
          /*
           * See implementation.
           * See implementation.
           * See implementation.
           * See implementation.
           * See implementation.
           */
          if (dep_index < 0 && any_let == 0 && module.main_func_index >= 0) {
            let dep_scan_i: i32 = 0;
            let dep_ndep: i32 = pipeline_dep_ctx_ndep(ctx);
            while (dep_scan_i < dep_ndep) {
              let scan_path: u8[256] = [];
              let scan_plen: i32 = codegen_dep_import_path_len_at(ctx, dep_scan_i, &scan_path[0]);
              if (scan_plen > 0 && pipeline_codegen_std_dep_link_only(&scan_path[0]) != 0) {
                dep_scan_i = dep_scan_i + 1;
                continue;
              }
              let dep_scan_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_scan_i);
              if (dep_scan_mod != 0 as *Module) {
                let dep_ti: i32 = 0;
                while (dep_ti < dep_scan_mod.num_top_level_lets) {
                  if (pipeline_module_top_level_let_is_const(dep_scan_mod, dep_ti) == 0) {
                    any_let = 1;
                    break;
                  }
                  dep_ti = dep_ti + 1;
                }
              }
              if (any_let != 0) {
                break;
              }
              dep_scan_i = dep_scan_i + 1;
            }
          }
          if (any_let != 0 && dep_index < 0) {
            /* See implementation. */
            let init_globals_def: u8[32] = [115, 116, 97, 116, 105, 99, 32, 118, 111, 105, 100, 32, 105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 118, 111, 105, 100, 41, 32, 0];
            /* See implementation. */
            if (codegen_emit_bytes_from_ptr(out, &init_globals_def[0], 31) != 0) {
              return -1;
            }
            let brace3: u8[3] = [123, 10, 0];
            if (codegen_emit_bytes_3(out, &brace3[0], 2) != 0) {
              return -1;
            }
            ti = 0;
            while (ti < module.num_top_level_lets) {
              if (pipeline_module_top_level_let_is_const(module, ti) != 0) {
                ti = ti + 1;
                continue;
              }
              /* See implementation. */
              let ig_ty: i32 = pipeline_module_top_level_let_type_ref(module, ti);
              if (!ast.ref_is_null(ig_ty) && pipeline_type_kind_ord_at(arena, ig_ty) == (TypeKind.TYPE_ARRAY as i32)) {
                ti = ti + 1;
                continue;
              }
              if (codegen_emit_indent(out, 2) != 0) {
                return -1;
              }
              let nlen: i32 = pipeline_module_top_level_let_name_len(module, ti);
              if (nlen > 0 && nlen <= 63) {
                let tl_init_name: u8[256] = [];
                let tni2: i32 = 0;
                while (tni2 < nlen && tni2 < 64) {
                  tl_init_name[tni2] = pipeline_module_top_level_let_name_byte_at(module, ti, tni2);
                  tni2 = tni2 + 1;
                }
                if (codegen_emit_bytes_from_ptr(out, &tl_init_name[0], nlen) != 0) {
                  return -1;
                }
              }
              let eq2: u8[4] = [32, 61, 32, 0];
              if (codegen_emit_bytes_4(out, &eq2[0], 3) != 0) {
                return -1;
              }
              /*
               * dest-SLICE mutable top-level let: init_globals assign.
               * Same wrap as decl-site (VAR of a const array is not a
               * C static-const tree → this path). G.7 reuse try_emit.
               * PLATFORM: SHARED host-C.
               */
              let ig_init: i32 = pipeline_module_top_level_let_init_ref(module, ti);
              let slice_ig: i32 = 0;
              if (!ast.ref_is_null(ig_ty)
                  && pipeline_type_kind_ord_at(arena, ig_ty) == 11
                  && !ast.ref_is_null(ig_init)) {
                slice_ig = try_emit_slice_init_from_array_var(
                  arena, out, 0, 0, ig_ty, ig_init, ctx);
              }
              if (slice_ig == 0) {
                slice_ig = try_emit_dest_slice_from_module_array_var(
                  arena, out, ig_ty, ig_init, ctx);
              }
              if (slice_ig < 0) {
                return -1;
              } else if (slice_ig == 0) {
                if (!ast.ref_is_null(ig_init) && codegen_emit_expr(arena, out, ig_init, ctx) != 0) {
                  return -1;
                }
              }
              let sc2: u8[3] = [59, 10, 0];
              if (codegen_emit_bytes_3(out, &sc2[0], 2) != 0) {
                return -1;
              }
              ti = ti + 1;
            }
            /* See implementation. */
            let dep_i: i32 = 0;
            let ndep: i32 = 0;
            if (module.main_func_index >= 0) {
              ndep = pipeline_dep_ctx_ndep(ctx);
            }
            while (dep_i < ndep) {
              let lo_path: u8[256] = [];
              let lo_plen: i32 = codegen_dep_import_path_len_at(ctx, dep_i, &lo_path[0]);
              if (lo_plen > 0 && pipeline_codegen_std_dep_link_only(&lo_path[0]) != 0) {
                dep_i = dep_i + 1;
                continue;
              }
              let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_i);
              if (dep_mod != 0 as *Module) {
                let dep_arena: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dep_i);
                let dti: i32 = 0;
                while (dti < dep_mod.num_top_level_lets) {
                  if (pipeline_module_top_level_let_is_const(dep_mod, dti) == 0) {
                    let dig_ty: i32 = pipeline_module_top_level_let_type_ref(dep_mod, dti);
                    if (dep_arena != 0 as *ASTArena && !ast.ref_is_null(dig_ty)
                        && pipeline_type_kind_ord_at(dep_arena, dig_ty) == (TypeKind.TYPE_ARRAY as i32)) {
                      dti = dti + 1;
                      continue;
                    }
                    if (codegen_emit_indent(out, 2) != 0) {
                      return -1;
                    }
                    let dnlen: i32 = pipeline_module_top_level_let_name_len(dep_mod, dti);
                    if (dnlen > 0 && dnlen <= 63) {
                      let dtl_name: u8[256] = [];
                      let dtni: i32 = 0;
                      while (dtni < dnlen && dtni < 64) {
                        dtl_name[dtni] = pipeline_module_top_level_let_name_byte_at(dep_mod, dti, dtni);
                        dtni = dtni + 1;
                      }
                      if (codegen_emit_bytes_from_ptr(out, &dtl_name[0], dnlen) != 0) {
                        return -1;
                      }
                    }
                    let deq: u8[4] = [32, 61, 32, 0];
                    if (codegen_emit_bytes_4(out, &deq[0], 3) != 0) {
                      return -1;
                    }
                    /*
                     * Dep-module dest-SLICE mutable let: same init_globals wrap.
                     * PLATFORM: SHARED host-C.
                     */
                    let dig_init: i32 = pipeline_module_top_level_let_init_ref(dep_mod, dti);
                    let slice_dig: i32 = 0;
                    if (!ast.ref_is_null(dig_ty)
                        && pipeline_type_kind_ord_at(dep_arena, dig_ty) == 11
                        && !ast.ref_is_null(dig_init)) {
                      /*
                       * VAR N scan reads ctx.current_codegen_module. Point it
                       * at the dep so dest-SLICE `= B` finds dep B, not the
                       * caller's lets. Restore after. PLATFORM: SHARED host-C.
                       */
                      let saved_dig: *Module = ctx.current_codegen_module;
                      ctx.current_codegen_module = dep_mod;
                      slice_dig = try_emit_slice_init_from_array_var(
                        dep_arena, out, 0, 0, dig_ty, dig_init, ctx);
                      if (slice_dig == 0) {
                        slice_dig = try_emit_dest_slice_from_module_array_var(
                          dep_arena, out, dig_ty, dig_init, ctx);
                      }
                      ctx.current_codegen_module = saved_dig;
                    }
                    if (slice_dig < 0) {
                      return -1;
                    } else if (slice_dig == 0) {
                      if (!ast.ref_is_null(dig_init) && codegen_emit_expr(dep_arena, out, dig_init, ctx) != 0) {
                        return -1;
                      }
                    }
                    let dsc: u8[3] = [59, 10, 0];
                    if (codegen_emit_bytes_3(out, &dsc[0], 2) != 0) {
                      return -1;
                    }
                  }
                  dti = dti + 1;
                }
              }
              dep_i = dep_i + 1;
            }
            let close_brace: u8[3] = [125, 10, 0];
            if (codegen_emit_bytes_3(out, &close_brace[0], 2) != 0) {
              return -1;
            }
          }
        }
      }
      if (module.num_funcs == 0) {
        break;
      }
      /* See implementation. */
      let skip_name: u8[256] = [];
      codegen_copy_func_name64_from_module(module, i, &skip_name[0]);
      let skip_nl: i32 = pipeline_module_func_name_len_at(module, i);
      /* See implementation. */
      if (pipeline_module_func_num_generic_params_at(module, i) > 0) {
        let mono_rc: i32 = codegen_try_emit_generic_identity_mono(arena, out, module, i, &prefix_buf[0], prefix_len, ctx);
        if (mono_rc < 0) {
          return -1;
        }
        i = i + 1;
        continue;
      }
      /*
       * wave498: multi-combo generic inherent impl method codegen monomorphization.
       * Why: hoisted impl methods (num_generic_params == 0, <T> on impl not fn) bypass
       * codegen_try_emit_generic_identity_mono. For multi-combo (nc>1) cases, emit one
       * monomorphized definition per combo with mangled symbol; return 1 means handled.
       * PLATFORM: SHARED — seed codegen_gen.linux.x86_64.c same commit.
       * Guards: returns 0 for non-qualifying funcs (nc<=1, no free type-args, etc.),
       * so fall through to normal emit_func path for unique-combo / plain funcs.
       */
      let w498_mono_rc: i32 = codegen_try_emit_generic_impl_method_mono(arena, out, module, i, &prefix_buf[0], prefix_len, ctx);
      if (w498_mono_rc < 0) {
        return -1;
      }
      if (w498_mono_rc > 0) {
        i = i + 1;
        continue;
      }
      /* See implementation. */
      if (pipeline_module_func_is_extern_at(module, i) != 0) {
        if (emit_func_extern_declaration(arena, out, module, i, &prefix_buf[0], prefix_len, ctx) != 0) {
          return -1;
        }
        i = i + 1;
        continue;
      }
      /* See implementation. */
      let skip: i32 = 0;
      let asm_backend: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx && ctx.use_asm_backend != 0) {
        asm_backend = 1;
      }
      skip = codegen_should_skip_emit_func_by_name(&skip_name[0], skip_nl);
      /*
       * See implementation.
       * See implementation.
       * See implementation.
       */
      if (skip == 0 && asm_backend == 0) {
        let is_prelinked_dep: i32 = 0;
        if (dep_index >= 0 && dep_path_prefix_len >= 10) {
          /* std.string or std/string */
          if (dep_path_prefix[0] == 115 && dep_path_prefix[1] == 116 && dep_path_prefix[2] == 100
              && (dep_path_prefix[3] == 46 || dep_path_prefix[3] == 47)
              && dep_path_prefix[4] == 115 && dep_path_prefix[5] == 116 && dep_path_prefix[6] == 114
              && dep_path_prefix[7] == 105 && dep_path_prefix[8] == 110 && dep_path_prefix[9] == 103) {
            is_prelinked_dep = 1;
          }
        }
        if (is_prelinked_dep == 0 && dep_index >= 0 && dep_path_prefix_len >= 9) {
          /* std.error or std/error */
          if (dep_path_prefix[0] == 115 && dep_path_prefix[1] == 116 && dep_path_prefix[2] == 100
              && (dep_path_prefix[3] == 46 || dep_path_prefix[3] == 47)
              && dep_path_prefix[4] == 101 && dep_path_prefix[5] == 114 && dep_path_prefix[6] == 114
              && dep_path_prefix[7] == 111 && dep_path_prefix[8] == 114) {
            is_prelinked_dep = 1;
          }
        }
        if (is_prelinked_dep == 0 && dep_index >= 0 && dep_path_prefix_len >= 11) {
          /* std.context or std/context */
          if (dep_path_prefix[0] == 115 && dep_path_prefix[1] == 116 && dep_path_prefix[2] == 100
              && (dep_path_prefix[3] == 46 || dep_path_prefix[3] == 47)
              && dep_path_prefix[4] == 99 && dep_path_prefix[5] == 111 && dep_path_prefix[6] == 110
              && dep_path_prefix[7] == 116 && dep_path_prefix[8] == 101 && dep_path_prefix[9] == 120
              && dep_path_prefix[10] == 116) {
            is_prelinked_dep = 1;
          }
        }
        if (is_prelinked_dep == 0 && prefix_len >= 11
            && prefix_buf[0] == 115 && prefix_buf[1] == 116 && prefix_buf[2] == 100
            && prefix_buf[3] == 95 && prefix_buf[4] == 115 && prefix_buf[5] == 116
            && prefix_buf[6] == 114 && prefix_buf[7] == 105 && prefix_buf[8] == 110
            && prefix_buf[9] == 103 && prefix_buf[10] == 95
            && dep_index >= 0) {
          is_prelinked_dep = 1;
        }
        if (is_prelinked_dep == 0 && prefix_len >= 10
            && prefix_buf[0] == 115 && prefix_buf[1] == 116 && prefix_buf[2] == 100
            && prefix_buf[3] == 95 && prefix_buf[4] == 101 && prefix_buf[5] == 114
            && prefix_buf[6] == 114 && prefix_buf[7] == 111 && prefix_buf[8] == 114
            && prefix_buf[9] == 95
            && dep_index >= 0) {
          is_prelinked_dep = 1;
        }
        if (is_prelinked_dep == 0 && prefix_len >= 12
            && prefix_buf[0] == 115 && prefix_buf[1] == 116 && prefix_buf[2] == 100
            && prefix_buf[3] == 95 && prefix_buf[4] == 99 && prefix_buf[5] == 111
            && prefix_buf[6] == 110 && prefix_buf[7] == 116 && prefix_buf[8] == 101
            && prefix_buf[9] == 120 && prefix_buf[10] == 116 && prefix_buf[11] == 95
            && dep_index >= 0) {
          is_prelinked_dep = 1;
        }
        if (is_prelinked_dep != 0) {
          skip = 1;
        }
      }
      /*
       * Legacy belt: if an older by_name still skipped bare placeholder/string_new,
       * un-skip when this module has a real C prefix (core_mem_ / core_types_ / …).
       * Current by_name no longer skips those names (seed-aligned); this remains a
       * no-op safety net. Product preamble only externs core_types_placeholder —
       * co-emit must produce the strong body or si links UNDEF.
       * PLATFORM: SHARED — Cap force multi-dep co-emit (stdlib-import).
       */
      if (skip != 0 && prefix_len > 0 && (skip_nl == 11 || skip_nl == 10)) {
        skip = 0;
      }
      if (skip == 0 && prefix_len == 0 && asm_backend == 0) {
        skip = codegen_should_skip_emit_func_core_read_ptr(&skip_name[0], skip_nl);
      }
      if (skip == 0 && prefix_len > 0 && asm_backend == 0) {
        skip = codegen_should_skip_emit_func(0 as *u8, &prefix_buf[0], prefix_len, &skip_name[0], skip_nl);
      }
      if (skip == 0 && dep_index >= 0 && ctx != 0 as *PipelineDepCtx && dep_path_prefix_len > 0 && asm_backend == 0) {
        skip = codegen_should_skip_emit_func(&dep_path_prefix[0], 0 as *u8, 0, &skip_name[0], skip_nl);
      }
      if (skip == 0 && asm_backend == 0) {
        let skip_dep: *u8 = 0 as *u8;
        if (dep_index >= 0 && ctx != 0 as *PipelineDepCtx && dep_path_prefix_len > 0) {
          skip_dep = &dep_path_prefix[0];
        }
        if (skip_dep == 0 as *u8) {
          skip_dep = driver_get_current_dep_path_for_codegen();
        }
        skip = codegen_should_skip_emit_func(skip_dep, 0 as *u8, 0, &skip_name[0], skip_nl);
      }
      /* wave377/wave681: same-module redef first-wins (host C dual body → redefinition).
       * Structural param/ret equality so methods and one-param free redefs skip later body. */
      if (skip == 0 && asm_backend == 0) {
        skip = codegen_should_skip_later_same_name_body(arena, module, i);
      }
      if (skip != 0) {
        i = i + 1;
        continue;
      }
      /* See implementation. */
      let is_entry: bool = (i == module.main_func_index) || (module.num_funcs == 1);
      let saved_func_idx: i32 = -1;
      if (ctx != 0 as *PipelineDepCtx) {
        saved_func_idx = ctx.current_func_index;
        ctx.current_func_index = i;
      }
      /*
       * Restore module identity + C prefix before each function body.
       * Purpose: prior emit_func / import-extern walks may leave
       *   current_codegen_module or prefix_mirror on another dep (e.g. core.option
       *   while emitting core.result → bare unwrap_or becomes core_option_unwrap_or;
       *   or entry while emitting std.fmt → fmt.fmt_i32 not core_fmt_fmt_i32).
       * Authority: seeds/codegen_gen.linux.x86_64.c before codegen_emit_func
       *   (module/arena/dep_index); prefix_mirror re-pin matches this module's
       *   prefix_buf computed at codegen_x_ast entry (Cap residual root).
       * PLATFORM: SHARED — Cap force multi-dep co-emit matrix (hello/si).
       */
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.current_codegen_module = module;
        ctx.current_codegen_arena = arena;
        ctx.current_codegen_dep_index = dep_index;
        let px: i32 = 0;
        while (px < prefix_len && px < 63) {
          ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
          px = px + 1;
        }
        ctx.current_codegen_prefix_mirror[px] = 0 as u8;
        ctx.current_codegen_prefix_len = px;
      }
      if (emit_func(arena, out, module, i, is_entry, &prefix_buf[0], prefix_len, ctx, call_init_globals) != 0) {
        driver_diagnostic_codegen_emit_func_fail(module, i);
        if (ctx != 0 as *PipelineDepCtx) {
          ctx.current_func_index = saved_func_idx;
        }
        return -1;
      }
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.current_func_index = saved_func_idx;
      }
      i = i + 1;
    }
    return 0;
  }
  // PLATFORM: SHARED — Cap-T001 whole-body unsafe close. Extra matching `}` required so
  // product parser does not parse-skip this mega function (XLANG_DEBUG_PARSE: skip at
  // codegen_x_ast entry → residual body mis-ingested as top-level lets / fake init_globals).
  }
}

/**
 * See implementation.
 */
/**
 * Decide whether to skip emitting a function solely by bare name.
 * Purpose: gate oversized bootstrap mega bodies (and historically bare
 *   placeholder/string_new that collided with preamble #define macros).
 * Parameters: name/name_len — function bare name (not C-mangled).
 * Returns: 1 = skip emit, 0 = emit normally.
 * Authority: seeds/codegen_gen.linux.x86_64.c codegen_should_skip_emit_func_by_name.
 * Why: product preamble no longer #define-aliases placeholder/string_new; those
 *   are real exports (core_types_placeholder, core_mem_placeholder, and peers).
 *   Cap still skipped bare "placeholder" so multi-dep co-emit of core.types
 *   emitted every size_of body but dropped placeholder → si -o UNDEF.
 * Invariant: only asm_codegen_ast_seed_mega / to_elf mega remain name-skips
 *   unless XLANG_EMIT_SEED_MEGA is set; do not re-add placeholder skip.
 * PLATFORM: SHARED — Cap force stdlib-import / core.* co-emit link.
 * Note: never write star-slash inside this block comment (truncates C emit).
 */
function codegen_should_skip_emit_func_by_name(name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let asm_seed_mega: u8[25] = [97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97];
    let asm_to_elf_seed_mega: u8[32] = [97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 116, 111, 95, 101, 108, 102, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97];
    if (name == 0 as *u8) {
      return 0;
    }
    // placeholder and string_new skip removed (seed-aligned; real core/std exports).
    // bootstrap -E: seed_mega bodies are huge; XLANG_EMIT_SEED_MEGA=1 still tries emit.
    if (pipeline_codegen_emit_seed_mega_enabled() == 0) {
      if (name_len == 25 && codegen_name_bytes_prefix_eq(name, name_len, &asm_seed_mega[0], 25) != 0) {
        return 1;
      }
      if (name_len == 32 && codegen_name_bytes_prefix_eq(name, name_len, &asm_to_elf_seed_mega[0], 32) != 0) {
        return 1;
      }
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function codegen_is_submit_batch_buf_call(name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — callee is defined in codegen.x; extern calls stay in unsafe.
  unsafe {
  let rd_batch: u8[21] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  let wr_batch: u8[22] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, &rd_batch[0], 21) != 0) {
    return 1;
  }
  if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &wr_batch[0], 22) != 0) {
    return 1;
  }
  return 0;
  }
}

/**
 * See implementation.
 */
function codegen_force_param_i32(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  /* See implementation. */
  return 0;
}

/**
 * Skip std.io.core ABI bridge names supplied by runtime preamble / io backend.
 *
 * Purpose: do not emit C bodies for xlang_io_read_ptr(_len), register*, wait_readable
 * when the C backend already maps them via preamble macros/weak stubs.
 *
 * Parameters:
 *   name / name_len — bare identifier; must use full "xlang_io_*" spelling (with 'x').
 *
 * Returns 1 to skip, 0 to emit.
 * read_ptr_len allows name_len >= 20 (prefix match); others require exact length.
 * PLATFORM: SHARED — Cap force hello co-emit must not redefine preamble bridges.
 */
function codegen_should_skip_emit_func_core_read_ptr(name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — callee is defined in codegen.x; extern calls stay in unsafe.
  unsafe {
  /* xlang_io_read_ptr_len — 20 */
  let xlang_rpl20: u8[21] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  /* xlang_io_read_ptr — 16 */
  let xlang_rp16: u8[17] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  /*
   * See implementation.
   * See implementation.
   * See implementation.
   * See implementation.
   * See implementation.
   * PLATFORM: SHARED.
   */
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len >= 20 && codegen_name_bytes_prefix_eq(name, name_len, &xlang_rpl20[0], 20) != 0) {
    return 1;
  }
  if (name_len == 16 && codegen_name_bytes_prefix_eq(name, name_len, &xlang_rp16[0], 16) != 0) {
    return 1;
  }
  /* xlang_io_read_ptr_backend — 24 (preamble weak stub) */
  let xlang_rpb24: u8[25] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 98, 97, 99, 107, 101, 110, 100];
  if ((name_len == 24 || name_len == 25) && codegen_name_bytes_prefix_eq(name, name_len, &xlang_rpb24[0], 24) != 0) {
    return 1;
  }
  /* xlang_io_submit_read_async — 25 (preamble weak stub) */
  let xlang_sra25: u8[26] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 97, 115, 121, 110, 99];
  if ((name_len == 25 || name_len == 26) && codegen_name_bytes_prefix_eq(name, name_len, &xlang_sra25[0], 25) != 0) {
    return 1;
  }
  return 0;
  }
}

/**
 * See implementation.
 */
function codegen_std_io_fixed_fd_emit_impl(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — callee is defined in codegen.x; extern calls stay in unsafe.
  unsafe {
  let pre7: u8[7] = [115, 116, 100, 95, 105, 111, 95];
  /* See implementation. */
  let rd13: u8[13] = [114, 101, 97, 100, 95, 102, 105, 120, 101, 100, 95, 102, 100];
  let wr14: u8[14] = [119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100, 95, 102, 100];
  if (prefix == 0 as *u8 || name == 0 as *u8 || prefix_len < 7 || name_len <= 0) {
    return 0;
  }
  if (codegen_name_bytes_prefix_eq(prefix, prefix_len, &pre7[0], 7) == 0) {
    return 0;
  }
  if (name_len >= 13 && codegen_name_bytes_prefix_eq(name, name_len, &rd13[0], 13) != 0) {
    return 1;
  }
  if (name_len >= 14 && codegen_name_bytes_prefix_eq(name, name_len, &wr14[0], 14) != 0) {
    return 1;
  }
  return 0;
  }
}
