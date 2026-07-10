// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-339：runtime_driver_diagnostic L2 thin — pure _impl 门闩子集（无字符串字面量）。
// 产品 PREFER_X_O：g05_try_x_to_o → thin.o + seeds/runtime_driver_diagnostic.from_x.c rest
//   （-DSHUX_L2_RDD_THIN_FROM_X）ld -r → src/runtime_driver_diagnostic.o
// 完整逻辑源仍见 src/runtime_driver_diagnostic.x（整文件 -E 仍 typeck/字符串阻）。
// 本 TU 门闩数：28

extern "C" function driver_debug_log_impl(step: i32): void;
extern "C" function driver_diagnostic_after_entry_parse_module_impl(module: *u8): void;
extern "C" function driver_diagnostic_asm_fail_at_impl(loc: i32): void;
extern "C" function driver_diagnostic_asm_print_current_func_impl(): void;
extern "C" function driver_diagnostic_asm_var_not_found_impl(name: *u8, len: i32, num_locals: i32, first_slot: *u8, first_len: i32): void;
extern "C" function driver_diagnostic_codegen_emit_func_fail_impl(module: *u8, func_index: i32): void;
extern "C" function driver_diagnostic_codegen_fail_impl(dep_index: i32, is_dep: i32): void;
extern "C" function driver_diagnostic_hint_unused_binding_impl(line: i32, col: i32, name: *u8, name_len: i32): void;
extern "C" function driver_diagnostic_parse_commit_fail_impl(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
extern "C" function driver_diagnostic_parse_commit_shape_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void;
extern "C" function driver_diagnostic_parse_fail_impl(main_idx: i32, num_funcs: i32, arena_num_types: i32): void;
extern "C" function driver_diagnostic_parse_func_generic_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, num_generic_params: i32, is_main: i32): void;
extern "C" function driver_diagnostic_parse_skip_function_impl(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
extern "C" function driver_diagnostic_parser_onefunc_param_ref_impl(func_name: *u8, func_name_len: i32, param_name: *u8, param_name_len: i32, stage: i32, param_idx: i32, type_ref: i32): void;
extern "C" function driver_diagnostic_typeck_binop_operands_impl(expr_ref: i32, left_ref: i32, right_ref: i32, left_kind: i32, right_kind: i32, left_block_ref: i32, right_block_ref: i32, left_ty_ref: i32, right_ty_ref: i32, left_ty: *u8, left_ty_len: i32, right_ty: *u8, right_ty_len: i32): void;
extern "C" function driver_diagnostic_typeck_block_enter_impl(func_idx: i32, block_ref: i32, n_const: i32, n_let: i32, n_loop: i32, n_for: i32, n_expr: i32, final_ref: i32): void;
extern "C" function driver_diagnostic_typeck_fn_enter_impl(func_idx: i32, name: *u8, name_len: i32): void;
extern "C" function driver_diagnostic_typeck_func_fail_impl(func_idx: i32, name: *u8, name_len: i32, kind: i32): void;
extern "C" function driver_diagnostic_typeck_import_const_must_be_qualified_impl(line: i32, col: i32, name: *u8, name_len: i32, binding: *u8, binding_len: i32): void;
extern "C" function driver_diagnostic_typeck_ptr_field_impl(bt_kind: i32, inner_kind: i32, inner_nlen: i32, base_resolved_ref: i32, num_struct_layouts: i32): void;
extern "C" function driver_diagnostic_typeck_ret_fail_impl(stage: i32, op_expr_ref: i32, expect_ty_ref: i32, got_ty_ref: i32): void;
extern "C" function driver_diagnostic_typeck_var_resolution_impl(expr_ref: i32, name: *u8, name_len: i32, func_idx: i32, block_ref: i32, source: i32, type_ref: i32): void;
extern "C" function driver_diagnostic_warn_hot_reorder_field_impl(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void;
extern "C" function driver_diagnostic_warn_pad_fields_same_cache_line_impl(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void;
extern "C" function parser_diag_ident_len_impl(len: i32): void;
extern "C" function parser_diag_scan_fail_impl(step: i32): void;
extern "C" function parser_diag_tok_kind_impl(k: i32): void;
extern "C" function parser_diagnostic_parse_commit_shape_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void;

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
function driver_diagnostic_typeck_import_const_must_be_qualified(line: i32, col: i32, name: *u8, name_len: i32, binding: *u8, binding_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_import_const_must_be_qualified_impl(line, col, name, name_len, binding, binding_len);
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


