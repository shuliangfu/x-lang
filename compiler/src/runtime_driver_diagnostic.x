// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-30/31/73：真迁 .x — 固定措辞 typeck 诊断薄包装 + parse_strict + 空桩。
// G-02f-86：driver_diag_copy_bytes / report_prefixed 门闩。
// G-02f-96：driver_diag_report_x_pipeline_code 门闩（va_list 本体 C _impl）。
// 产品：./shux-c -E → seeds/runtime_driver_diagnostic.from_x.c（+ C 尾 + 字符串抛光）。
// C 尾：snprintf 诊断、va_list pipeline 码、scratch 缓冲、debug getenv 详细路径。
// 注意：字符串字面量经 -E 成 slice；seed 抛光为 C 字符串传 lsp_diag_report_typeck。
// G-02f-73：+ remaining snprintf/asm/parser diag wrappers as gates.
// G-02f-31：+ fail/break-continue/enum/subscript/try 固定消息。

extern "C" function lsp_diag_report_typeck(line: i32, col: i32, msg: *u8): void;
extern "C" function getenv(name: *u8): *u8;
extern "C" function driver_check_only_get(): i32;
extern "C" function driver_check_diag_emitted_get(): i32;

extern "C" function driver_diagnostic_parse_fail_impl(main_idx: i32, num_funcs: i32, arena_num_types: i32): void;
extern "C" function driver_diagnostic_parse_skip_function_impl(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
extern "C" function driver_diagnostic_typeck_func_fail_impl(func_idx: i32, name: *u8, name_len: i32, kind: i32): void;
extern "C" function driver_diagnostic_typeck_ptr_field_impl(bt_kind: i32, inner_kind: i32, inner_nlen: i32, base_resolved_ref: i32, num_struct_layouts: i32): void;
extern "C" function driver_diagnostic_typeck_ret_fail_impl(stage: i32, op_expr_ref: i32, expect_ty_ref: i32, got_ty_ref: i32): void;
extern "C" function driver_diagnostic_typeck_binop_operands_impl(expr_ref: i32, left_ref: i32, right_ref: i32, left_kind: i32, right_kind: i32, left_block_ref: i32, right_block_ref: i32, left_ty_ref: i32, right_ty_ref: i32, left_ty: *u8, left_ty_len: i32, right_ty: *u8, right_ty_len: i32): void;
extern "C" function driver_diagnostic_parser_onefunc_param_ref_impl(func_name: *u8, func_name_len: i32, param_name: *u8, param_name_len: i32, stage: i32, param_idx: i32, type_ref: i32): void;
extern "C" function driver_diagnostic_typeck_return_mismatch_impl(line: i32, col: i32, expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void;
extern "C" function driver_diagnostic_typeck_return_unresolved_impl(line: i32, col: i32, expr_buf: *u8, expr_len: i32): void;
extern "C" function driver_diagnostic_typeck_return_subexpr_impl(line: i32, col: i32, expr_buf: *u8, expr_len: i32): void;
extern "C" function driver_diagnostic_typeck_call_not_generic_impl(line: i32, col: i32, name: *u8, name_len: i32): void;
extern "C" function driver_diagnostic_typeck_call_wrong_num_type_args_impl(line: i32, col: i32, name: *u8, name_len: i32, expect_n: i32, got_n: i32): void;
extern "C" function driver_diagnostic_typeck_call_requires_type_args_impl(line: i32, col: i32, name: *u8, name_len: i32): void;
extern "C" function driver_diagnostic_typeck_import_const_must_be_qualified_impl(line: i32, col: i32, name: *u8, name_len: i32, binding: *u8, binding_len: i32): void;
extern "C" function driver_diagnostic_typeck_struct_padding_before_impl(sname: *u8, sname_len: i32, gap: i32, fname: *u8, fname_len: i32): void;
extern "C" function driver_diagnostic_typeck_struct_padding_trailing_impl(sname: *u8, sname_len: i32, gap: i32): void;
extern "C" function driver_diagnostic_typeck_struct_field_bad_size_impl(sname: *u8, sname_len: i32, fname: *u8, fname_len: i32): void;
extern "C" function driver_diagnostic_typeck_assign_mismatch_impl(is_compound: i32, line: i32, col: i32, expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void;
extern "C" function driver_diagnostic_typeck_block_enter_impl(func_idx: i32, block_ref: i32, n_const: i32, n_let: i32, n_loop: i32, n_for: i32, n_expr: i32, final_ref: i32): void;
extern "C" function driver_diagnostic_typeck_fn_enter_impl(func_idx: i32, name: *u8, name_len: i32): void;
extern "C" function driver_diagnostic_typeck_var_resolution_impl(expr_ref: i32, name: *u8, name_len: i32, func_idx: i32, block_ref: i32, source: i32, type_ref: i32): void;
extern "C" function driver_diagnostic_before_codegen_impl(num_funcs: i32, out_len: i32): void;
extern "C" function driver_diagnostic_source_len_impl(len: i32): void;
extern "C" function driver_diagnostic_after_entry_parse_impl(num_funcs: i32): void;
extern "C" function driver_diagnostic_parse_commit_fail_impl(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
extern "C" function driver_diagnostic_parse_func_generic_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, num_generic_params: i32, is_main: i32): void;
extern "C" function driver_diagnostic_parse_commit_shape_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void;
extern "C" function parser_diagnostic_parse_commit_shape_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void;
extern "C" function driver_diagnostic_after_entry_parse_module_impl(module: *u8): void;
extern "C" function driver_diagnostic_pipe_marker_impl(id: i32): void;
extern "C" function driver_diagnostic_codegen_fail_impl(dep_index: i32, is_dep: i32): void;
extern "C" function driver_diagnostic_codegen_emit_func_fail_impl(module: *u8, func_index: i32): void;
extern "C" function driver_diagnostic_asm_unsupported_expr_impl(kind: i32): void;
extern "C" function driver_diagnostic_asm_elf_unresolved_patch_impl(name: *u8, len: i32): void;
extern "C" function driver_diagnostic_asm_macho_empty_reloc_impl(reloc_idx: i32): void;
extern "C" function driver_diagnostic_asm_macho_missing_und_reloc_impl(reloc_idx: i32): void;
extern "C" function driver_diagnostic_asm_set_last_expr_kind_impl(k: i32): void;
extern "C" function driver_diagnostic_asm_set_current_func_impl(name: *u8, len: i32): void;
extern "C" function driver_diagnostic_asm_print_current_func_impl(): void;
extern "C" function driver_diagnostic_asm_var_not_found_impl(name: *u8, len: i32, num_locals: i32, first_slot: *u8, first_len: i32): void;
extern "C" function driver_diagnostic_asm_fail_at_impl(loc: i32): void;
extern "C" function driver_debug_log_impl(step: i32): void;
extern "C" function parser_diag_tok_kind_impl(k: i32): void;
extern "C" function parser_diag_ident_len_impl(len: i32): void;
extern "C" function parser_diag_scan_fail_impl(step: i32): void;
extern "C" function parser_is_ident_allow_impl(ident: *u8, len: i32): i32;
extern "C" function driver_diagnostic_warn_pad_fields_same_cache_line_impl(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void;
extern "C" function driver_diagnostic_warn_hot_reorder_field_impl(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void;
extern "C" function driver_diagnostic_hint_unused_binding_impl(line: i32, col: i32, name: *u8, name_len: i32): void;


extern "C" function driver_diag_copy_bytes_impl(dst: *u8, dst_size: i64, src: *u8, src_len: i32): i32;
extern "C" function driver_diag_report_prefixed_impl(line: i32, col: i32, msg: *u8): void;

#[no_mangle]
function driver_diagnostic_typeck_if_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "if condition must be bool (no implicit int-to-bool)");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_while_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "while condition must be bool (no implicit int-to-bool)");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_for_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "for condition must be bool (no implicit int-to-bool)");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_deref_outside_unsafe(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "pointer dereference requires unsafe block");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_extern_call_outside_unsafe(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "extern call requires unsafe block");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_linear_addr_of(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "cannot take address of linear value");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_break_continue_outside(line: i32, col: i32, is_break: i32): void {
  unsafe {
    if (is_break != 0) {
      lsp_diag_report_typeck(line, col, "break only allowed inside a loop");
    } else {
      lsp_diag_report_typeck(line, col, "continue only allowed inside a loop");
    }
  }
}

#[no_mangle]
function driver_diagnostic_typeck_enum_no_variant(line: i32, col: i32): void {
  unsafe {
    // 经 lsp_diag_report_typeck：LSP 模式带 T001，与产品 typeck 码口径一致。
    lsp_diag_report_typeck(line, col, "enum has no variant");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_subscript_base(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "subscript base must be array, slice or pointer");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_try_propagate_bad_enclosing(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col,
                           "`?` requires the enclosing function to return the same Result type");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_fail(): void {
  // 具体 XT001 已由其它路径发出；保留对 check-only 标志的副作用读取（与历史 C 一致）。
  unsafe {
    let _a: i32 = driver_check_only_get();
    let _b: i32 = driver_check_diag_emitted_get();
  }
}

#[no_mangle]
function driver_diagnostic_entry_already(v: i32): void {
}

#[no_mangle]
function driver_diagnostic_after_dep_codegen(j: i32, out_len: i32): void {
}

#[no_mangle]
function driver_parse_strict_enabled(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_PARSE_STRICT");
    if (e == 0 as *u8) {
      return 0;
    }
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}

/* ---- G-02f-73：remaining diagnostic wrappers ---- */

#[no_mangle]
function driver_diagnostic_parse_fail(main_idx: i32, num_funcs: i32, arena_num_types: i32): void {
  unsafe {
    driver_diagnostic_parse_fail_impl(main_idx, num_funcs, arena_num_types);
  }
}

#[no_mangle]
function driver_diagnostic_parse_skip_function(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void {
  unsafe {
    driver_diagnostic_parse_skip_function_impl(byte_pos, num_funcs_so_far, name_len, name);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_func_fail(func_idx: i32, name: *u8, name_len: i32, kind: i32): void {
  unsafe {
    driver_diagnostic_typeck_func_fail_impl(func_idx, name, name_len, kind);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_ptr_field(bt_kind: i32, inner_kind: i32, inner_nlen: i32, base_resolved_ref: i32, num_struct_layouts: i32): void {
  unsafe {
    driver_diagnostic_typeck_ptr_field_impl(bt_kind, inner_kind, inner_nlen, base_resolved_ref, num_struct_layouts);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_ret_fail(stage: i32, op_expr_ref: i32, expect_ty_ref: i32, got_ty_ref: i32): void {
  unsafe {
    driver_diagnostic_typeck_ret_fail_impl(stage, op_expr_ref, expect_ty_ref, got_ty_ref);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_binop_operands(expr_ref: i32, left_ref: i32, right_ref: i32, left_kind: i32, right_kind: i32, left_block_ref: i32, right_block_ref: i32, left_ty_ref: i32, right_ty_ref: i32, left_ty: *u8, left_ty_len: i32, right_ty: *u8, right_ty_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_binop_operands_impl(expr_ref, left_ref, right_ref, left_kind, right_kind, left_block_ref, right_block_ref, left_ty_ref, right_ty_ref, left_ty, left_ty_len, right_ty, right_ty_len);
  }
}

#[no_mangle]
function driver_diagnostic_parser_onefunc_param_ref(func_name: *u8, func_name_len: i32, param_name: *u8, param_name_len: i32, stage: i32, param_idx: i32, type_ref: i32): void {
  unsafe {
    driver_diagnostic_parser_onefunc_param_ref_impl(func_name, func_name_len, param_name, param_name_len, stage, param_idx, type_ref);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_return_mismatch(line: i32, col: i32, expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_return_mismatch_impl(line, col, expect_buf, expect_len, found_buf, found_len);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_return_unresolved(line: i32, col: i32, expr_buf: *u8, expr_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_return_unresolved_impl(line, col, expr_buf, expr_len);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_return_subexpr(line: i32, col: i32, expr_buf: *u8, expr_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_return_subexpr_impl(line, col, expr_buf, expr_len);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_call_not_generic(line: i32, col: i32, name: *u8, name_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_call_not_generic_impl(line, col, name, name_len);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_call_wrong_num_type_args(line: i32, col: i32, name: *u8, name_len: i32, expect_n: i32, got_n: i32): void {
  unsafe {
    driver_diagnostic_typeck_call_wrong_num_type_args_impl(line, col, name, name_len, expect_n, got_n);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_call_requires_type_args(line: i32, col: i32, name: *u8, name_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_call_requires_type_args_impl(line, col, name, name_len);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_import_const_must_be_qualified(line: i32, col: i32, name: *u8, name_len: i32, binding: *u8, binding_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_import_const_must_be_qualified_impl(line, col, name, name_len, binding, binding_len);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_struct_padding_before(sname: *u8, sname_len: i32, gap: i32, fname: *u8, fname_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_struct_padding_before_impl(sname, sname_len, gap, fname, fname_len);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_struct_padding_trailing(sname: *u8, sname_len: i32, gap: i32): void {
  unsafe {
    driver_diagnostic_typeck_struct_padding_trailing_impl(sname, sname_len, gap);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_struct_field_bad_size(sname: *u8, sname_len: i32, fname: *u8, fname_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_struct_field_bad_size_impl(sname, sname_len, fname, fname_len);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_assign_mismatch(is_compound: i32, line: i32, col: i32, expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_assign_mismatch_impl(is_compound, line, col, expect_buf, expect_len, found_buf, found_len);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_block_enter(func_idx: i32, block_ref: i32, n_const: i32, n_let: i32, n_loop: i32, n_for: i32, n_expr: i32, final_ref: i32): void {
  unsafe {
    driver_diagnostic_typeck_block_enter_impl(func_idx, block_ref, n_const, n_let, n_loop, n_for, n_expr, final_ref);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_fn_enter(func_idx: i32, name: *u8, name_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_fn_enter_impl(func_idx, name, name_len);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_var_resolution(expr_ref: i32, name: *u8, name_len: i32, func_idx: i32, block_ref: i32, source: i32, type_ref: i32): void {
  unsafe {
    driver_diagnostic_typeck_var_resolution_impl(expr_ref, name, name_len, func_idx, block_ref, source, type_ref);
  }
}

#[no_mangle]
function driver_diagnostic_before_codegen(num_funcs: i32, out_len: i32): void {
  unsafe {
    driver_diagnostic_before_codegen_impl(num_funcs, out_len);
  }
}

#[no_mangle]
function driver_diagnostic_source_len(len: i32): void {
  unsafe {
    driver_diagnostic_source_len_impl(len);
  }
}

#[no_mangle]
function driver_diagnostic_after_entry_parse(num_funcs: i32): void {
  unsafe {
    driver_diagnostic_after_entry_parse_impl(num_funcs);
  }
}

#[no_mangle]
function driver_diagnostic_parse_commit_fail(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void {
  unsafe {
    driver_diagnostic_parse_commit_fail_impl(byte_pos, num_funcs_so_far, name_len, name);
  }
}

#[no_mangle]
function driver_diagnostic_parse_func_generic(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, num_generic_params: i32, is_main: i32): void {
  unsafe {
    driver_diagnostic_parse_func_generic_impl(byte_pos, num_funcs_so_far, name, name_len, num_generic_params, is_main);
  }
}

#[no_mangle]
function driver_diagnostic_parse_commit_shape(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void {
  unsafe {
    driver_diagnostic_parse_commit_shape_impl(byte_pos, num_funcs_so_far, name, name_len, phase, block_ref, pool_num_consts, pool_num_lets, pool_num_ifs, pool_num_regions, pool_num_stmt_order, block_num_consts, block_num_lets, block_num_ifs, block_num_regions, block_num_stmt_order, final_expr_ref);
  }
}

#[no_mangle]
function parser_diagnostic_parse_commit_shape(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void {
  unsafe {
    parser_diagnostic_parse_commit_shape_impl(byte_pos, num_funcs_so_far, name, name_len, phase, block_ref, pool_num_consts, pool_num_lets, pool_num_ifs, pool_num_regions, pool_num_stmt_order, block_num_consts, block_num_lets, block_num_ifs, block_num_regions, block_num_stmt_order, final_expr_ref);
  }
}

#[no_mangle]
function driver_diagnostic_after_entry_parse_module(module: *u8): void {
  unsafe {
    driver_diagnostic_after_entry_parse_module_impl(module);
  }
}

#[no_mangle]
function driver_diagnostic_pipe_marker(id: i32): void {
  unsafe {
    driver_diagnostic_pipe_marker_impl(id);
  }
}

#[no_mangle]
function driver_diagnostic_codegen_fail(dep_index: i32, is_dep: i32): void {
  unsafe {
    driver_diagnostic_codegen_fail_impl(dep_index, is_dep);
  }
}

#[no_mangle]
function driver_diagnostic_codegen_emit_func_fail(module: *u8, func_index: i32): void {
  unsafe {
    driver_diagnostic_codegen_emit_func_fail_impl(module, func_index);
  }
}

#[no_mangle]
function driver_diagnostic_asm_unsupported_expr(kind: i32): void {
  unsafe {
    driver_diagnostic_asm_unsupported_expr_impl(kind);
  }
}

#[no_mangle]
function driver_diagnostic_asm_elf_unresolved_patch(name: *u8, len: i32): void {
  unsafe {
    driver_diagnostic_asm_elf_unresolved_patch_impl(name, len);
  }
}

#[no_mangle]
function driver_diagnostic_asm_macho_empty_reloc(reloc_idx: i32): void {
  unsafe {
    driver_diagnostic_asm_macho_empty_reloc_impl(reloc_idx);
  }
}

#[no_mangle]
function driver_diagnostic_asm_macho_missing_und_reloc(reloc_idx: i32): void {
  unsafe {
    driver_diagnostic_asm_macho_missing_und_reloc_impl(reloc_idx);
  }
}

#[no_mangle]
function driver_diagnostic_asm_set_last_expr_kind(k: i32): void {
  unsafe {
    driver_diagnostic_asm_set_last_expr_kind_impl(k);
  }
}

#[no_mangle]
function driver_diagnostic_asm_set_current_func(name: *u8, len: i32): void {
  unsafe {
    driver_diagnostic_asm_set_current_func_impl(name, len);
  }
}

#[no_mangle]
function driver_diagnostic_asm_print_current_func(): void {
  unsafe {
    driver_diagnostic_asm_print_current_func_impl();
  }
}

#[no_mangle]
function driver_diagnostic_asm_var_not_found(name: *u8, len: i32, num_locals: i32, first_slot: *u8, first_len: i32): void {
  unsafe {
    driver_diagnostic_asm_var_not_found_impl(name, len, num_locals, first_slot, first_len);
  }
}

#[no_mangle]
function driver_diagnostic_asm_fail_at(loc: i32): void {
  unsafe {
    driver_diagnostic_asm_fail_at_impl(loc);
  }
}

#[no_mangle]
function driver_debug_log(step: i32): void {
  unsafe {
    driver_debug_log_impl(step);
  }
}

#[no_mangle]
function parser_diag_tok_kind(k: i32): void {
  unsafe {
    parser_diag_tok_kind_impl(k);
  }
}

#[no_mangle]
function parser_diag_ident_len(len: i32): void {
  unsafe {
    parser_diag_ident_len_impl(len);
  }
}

#[no_mangle]
function parser_diag_scan_fail(step: i32): void {
  unsafe {
    parser_diag_scan_fail_impl(step);
  }
}

#[no_mangle]
function parser_is_ident_allow(ident: *u8, len: i32): i32 {
  unsafe {
    return parser_is_ident_allow_impl(ident, len);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_diagnostic_warn_pad_fields_same_cache_line(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void {
  unsafe {
    driver_diagnostic_warn_pad_fields_same_cache_line_impl(sname, sname_len, f0, f0_len, f1, f1_len);
  }
}

#[no_mangle]
function driver_diagnostic_warn_hot_reorder_field(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void {
  unsafe {
    driver_diagnostic_warn_hot_reorder_field_impl(sname, sname_len, hot, hot_len, cold, cold_len);
  }
}

#[no_mangle]
function driver_diagnostic_hint_unused_binding(line: i32, col: i32, name: *u8, name_len: i32): void {
  unsafe {
    driver_diagnostic_hint_unused_binding_impl(line, col, name, name_len);
  }
}


/* ---- G-02f-86：diag copy_bytes / report_prefixed 门闩 ---- */

#[no_mangle]
function driver_diag_copy_bytes(dst: *u8, dst_size: i64, src: *u8, src_len: i32): i32 {
  unsafe {
    return driver_diag_copy_bytes_impl(dst, dst_size, src, src_len);
  }
  return 0;
}

#[no_mangle]
function driver_diag_report_prefixed(line: i32, col: i32, msg: *u8): void {
  unsafe {
    driver_diag_report_prefixed_impl(line, col, msg);
  }
}

