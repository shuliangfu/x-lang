// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// G-02f-73：+ remaining snprintf/asm/parser diag wrappers as gates.
// See implementation.

export extern "C" function lsp_diag_report_typeck(line: i32, col: i32, msg: *u8): void;
export extern "C" function getenv(name: *u8): *u8;
export extern "C" function driver_check_only_get(): i32;
export extern "C" function driver_check_diag_emitted_get(): i32;

export extern "C" function driver_diagnostic_parse_fail_impl(main_idx: i32, num_funcs: i32, arena_num_types: i32): void;
export extern "C" function driver_diagnostic_parse_skip_function_impl(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
export extern "C" function driver_diagnostic_typeck_func_fail_impl(func_idx: i32, name: *u8, name_len: i32, kind: i32): void;
export extern "C" function driver_diagnostic_typeck_ptr_field_impl(bt_kind: i32, inner_kind: i32, inner_nlen: i32, base_resolved_ref: i32, num_struct_layouts: i32): void;
export extern "C" function driver_diagnostic_typeck_ret_fail_impl(stage: i32, op_expr_ref: i32, expect_ty_ref: i32, got_ty_ref: i32): void;
export extern "C" function driver_diagnostic_typeck_binop_operands_impl(expr_ref: i32, left_ref: i32, right_ref: i32, left_kind: i32, right_kind: i32, left_block_ref: i32, right_block_ref: i32, left_ty_ref: i32, right_ty_ref: i32, left_ty: *u8, left_ty_len: i32, right_ty: *u8, right_ty_len: i32): void;
export extern "C" function driver_diagnostic_parser_onefunc_param_ref_impl(func_name: *u8, func_name_len: i32, param_name: *u8, param_name_len: i32, stage: i32, param_idx: i32, type_ref: i32): void;
export extern "C" function driver_diagnostic_typeck_import_const_must_be_qualified_impl(line: i32, col: i32, name: *u8, name_len: i32, binding: *u8, binding_len: i32): void;
export extern "C" function driver_diagnostic_typeck_block_enter_impl(func_idx: i32, block_ref: i32, n_const: i32, n_let: i32, n_loop: i32, n_for: i32, n_expr: i32, final_ref: i32): void;
export extern "C" function driver_diagnostic_typeck_fn_enter_impl(func_idx: i32, name: *u8, name_len: i32): void;
export extern "C" function driver_diagnostic_typeck_var_resolution_impl(expr_ref: i32, name: *u8, name_len: i32, func_idx: i32, block_ref: i32, source: i32, type_ref: i32): void;
export extern "C" function driver_diag_env_debug_pipe(): i32;
export extern "C" function driver_diag_pipe_note(kind: i32, a: i32, b: i32): void;
export extern "C" function driver_diagnostic_parse_commit_fail_impl(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
export extern "C" function driver_diagnostic_parse_func_generic_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, num_generic_params: i32, is_main: i32): void;
export extern "C" function driver_diagnostic_parse_commit_shape_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void;
export extern "C" function parser_diagnostic_parse_commit_shape_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void;
export extern "C" function driver_diagnostic_after_entry_parse_module_impl(module: *u8): void;
export extern "C" function driver_diagnostic_codegen_fail_impl(dep_index: i32, is_dep: i32): void;
export extern "C" function driver_diagnostic_codegen_emit_func_fail_impl(module: *u8, func_index: i32): void;
export extern "C" function driver_diagnostic_asm_last_expr_kind_set(k: i32): void;
export extern "C" function driver_diagnostic_asm_current_func_store(name: *u8, len: i32): void;
export extern "C" function driver_diagnostic_asm_current_func_maybe_trace(): void;
export extern "C" function driver_diagnostic_asm_print_current_func_impl(): void;
export extern "C" function driver_diagnostic_asm_var_not_found_impl(name: *u8, len: i32, num_locals: i32, first_slot: *u8, first_len: i32): void;
export extern "C" function driver_diagnostic_asm_fail_at_impl(loc: i32): void;
export extern "C" function driver_debug_log_impl(step: i32): void;
export extern "C" function parser_diag_tok_kind_impl(k: i32): void;
export extern "C" function parser_diag_ident_len_impl(len: i32): void;
export extern "C" function parser_diag_scan_fail_impl(step: i32): void;
export extern "C" function parser_is_ident_allow_impl(ident: *u8, len: i32): i32;
export extern "C" function driver_diagnostic_warn_pad_fields_same_cache_line_impl(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void;
export extern "C" function driver_diagnostic_warn_hot_reorder_field_impl(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void;
export extern "C" function driver_diagnostic_hint_unused_binding_impl(line: i32, col: i32, name: *u8, name_len: i32): void;


export extern "C" function lsp_diag_get_enabled(): i32;
export extern "C" function lsp_diag_add(line: i32, col: i32, severity: i32, msg: *u8): void;
export extern "C" function driver_check_diag_emitted_note(): void;
export extern "C" function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void;

/** Exported function `driver_diagnostic_typeck_if_condition_not_bool`.
 * Implements `driver_diagnostic_typeck_if_condition_not_bool`.
 * @param line i32
 * @param col i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_if_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "if condition must be bool (no implicit int-to-bool)");
  }
}

/** Exported function `driver_diagnostic_typeck_while_condition_not_bool`.
 * Implements `driver_diagnostic_typeck_while_condition_not_bool`.
 * @param line i32
 * @param col i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_while_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "while condition must be bool (no implicit int-to-bool)");
  }
}

/** Exported function `driver_diagnostic_typeck_for_condition_not_bool`.
 * Implements `driver_diagnostic_typeck_for_condition_not_bool`.
 * @param line i32
 * @param col i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_for_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "for condition must be bool (no implicit int-to-bool)");
  }
}

/** Exported function `driver_diagnostic_typeck_deref_outside_unsafe`.
 * Implements `driver_diagnostic_typeck_deref_outside_unsafe`.
 * @param line i32
 * @param col i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_deref_outside_unsafe(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "pointer dereference requires unsafe block");
  }
}

/** Exported function `driver_diagnostic_typeck_extern_call_outside_unsafe`.
 * Implements `driver_diagnostic_typeck_extern_call_outside_unsafe`.
 * @param line i32
 * @param col i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_extern_call_outside_unsafe(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "extern call requires unsafe block");
  }
}

/** Exported function `driver_diagnostic_typeck_linear_addr_of`.
 * Implements `driver_diagnostic_typeck_linear_addr_of`.
 * @param line i32
 * @param col i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_linear_addr_of(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "cannot take address of linear value");
  }
}

/** Exported function `driver_diagnostic_typeck_break_continue_outside`.
 * Implements `driver_diagnostic_typeck_break_continue_outside`.
 * @param line i32
 * @param col i32
 * @param is_break i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_break_continue_outside(line: i32, col: i32, is_break: i32): void {
  unsafe {
    if (is_break != 0) {
      lsp_diag_report_typeck(line, col, "break only allowed inside a loop");
    } else {
      lsp_diag_report_typeck(line, col, "continue only allowed inside a loop");
    }
  }
}

/** Exported function `driver_diagnostic_typeck_enum_no_variant`.
 * Implements `driver_diagnostic_typeck_enum_no_variant`.
 * @param line i32
 * @param col i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_enum_no_variant(line: i32, col: i32): void {
  unsafe {
    // See implementation.
    lsp_diag_report_typeck(line, col, "enum has no variant");
  }
}

/** Exported function `driver_diagnostic_typeck_subscript_base`.
 * Implements `driver_diagnostic_typeck_subscript_base`.
 * @param line i32
 * @param col i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_subscript_base(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "subscript base must be array, slice or pointer");
  }
}

/** Exported function `driver_diagnostic_typeck_try_propagate_bad_enclosing`.
 * Implements `driver_diagnostic_typeck_try_propagate_bad_enclosing`.
 * @param line i32
 * @param col i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_try_propagate_bad_enclosing(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col,
                           "`?` requires the enclosing function to return the same Result type");
  }
}

/** Exported function `driver_diagnostic_typeck_fail`.
 * Implements `driver_diagnostic_typeck_fail`.
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_fail(): void {
  // See implementation.
  unsafe {
    let _a: i32 = driver_check_only_get();
    let _b: i32 = driver_check_diag_emitted_get();
  }
}

/** Exported function `driver_diagnostic_entry_already`.
 * Read path helper `driver_diagnostic_entry_already`.
 * @param v i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_entry_already(v: i32): void {
}

/** Exported function `driver_diagnostic_after_dep_codegen`.
 * Implements `driver_diagnostic_after_dep_codegen`.
 * @param j i32
 * @param out_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_after_dep_codegen(j: i32, out_len: i32): void {
}

/** Exported function `driver_parse_strict_enabled`.
 * Implements `driver_parse_strict_enabled`.
 * @return i32
 */
#[no_mangle]
export function driver_parse_strict_enabled(): i32 {
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
export function driver_diagnostic_parse_fail(main_idx: i32, num_funcs: i32, arena_num_types: i32): void {
  unsafe {
    driver_diagnostic_parse_fail_impl(main_idx, num_funcs, arena_num_types);
  }
}

/** Exported function `driver_diagnostic_parse_skip_function`.
 * Implements `driver_diagnostic_parse_skip_function`.
 * @param byte_pos i32
 * @param num_funcs_so_far i32
 * @param name_len i32
 * @param name *u8
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_parse_skip_function(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void {
  unsafe {
    driver_diagnostic_parse_skip_function_impl(byte_pos, num_funcs_so_far, name_len, name);
  }
}

/** Exported function `driver_diagnostic_typeck_func_fail`.
 * Implements `driver_diagnostic_typeck_func_fail`.
 * @param func_idx i32
 * @param name *u8
 * @param name_len i32
 * @param kind i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_func_fail(func_idx: i32, name: *u8, name_len: i32, kind: i32): void {
  unsafe {
    driver_diagnostic_typeck_func_fail_impl(func_idx, name, name_len, kind);
  }
}

/** Exported function `driver_diagnostic_typeck_ptr_field`.
 * Implements `driver_diagnostic_typeck_ptr_field`.
 * @param bt_kind i32
 * @param inner_kind i32
 * @param inner_nlen i32
 * @param base_resolved_ref i32
 * @param num_struct_layouts i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_ptr_field(bt_kind: i32, inner_kind: i32, inner_nlen: i32, base_resolved_ref: i32, num_struct_layouts: i32): void {
  unsafe {
    driver_diagnostic_typeck_ptr_field_impl(bt_kind, inner_kind, inner_nlen, base_resolved_ref, num_struct_layouts);
  }
}

/** Exported function `driver_diagnostic_typeck_ret_fail`.
 * Implements `driver_diagnostic_typeck_ret_fail`.
 * @param stage i32
 * @param op_expr_ref i32
 * @param expect_ty_ref i32
 * @param got_ty_ref i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_ret_fail(stage: i32, op_expr_ref: i32, expect_ty_ref: i32, got_ty_ref: i32): void {
  unsafe {
    driver_diagnostic_typeck_ret_fail_impl(stage, op_expr_ref, expect_ty_ref, got_ty_ref);
  }
}

/** Exported function `driver_diagnostic_typeck_binop_operands`.
 * Implements `driver_diagnostic_typeck_binop_operands`.
 * @param expr_ref i32
 * @param left_ref i32
 * @param right_ref i32
 * @param left_kind i32
 * @param right_kind i32
 * @param left_block_ref i32
 * @param right_block_ref i32
 * @param left_ty_ref i32
 * @param right_ty_ref i32
 * @param left_ty *u8
 * @param left_ty_len i32
 * @param right_ty *u8
 * @param right_ty_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_binop_operands(expr_ref: i32, left_ref: i32, right_ref: i32, left_kind: i32, right_kind: i32, left_block_ref: i32, right_block_ref: i32, left_ty_ref: i32, right_ty_ref: i32, left_ty: *u8, left_ty_len: i32, right_ty: *u8, right_ty_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_binop_operands_impl(expr_ref, left_ref, right_ref, left_kind, right_kind, left_block_ref, right_block_ref, left_ty_ref, right_ty_ref, left_ty, left_ty_len, right_ty, right_ty_len);
  }
}

/** Exported function `driver_diagnostic_parser_onefunc_param_ref`.
 * Implements `driver_diagnostic_parser_onefunc_param_ref`.
 * @param func_name *u8
 * @param func_name_len i32
 * @param param_name *u8
 * @param param_name_len i32
 * @param stage i32
 * @param param_idx i32
 * @param type_ref i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_parser_onefunc_param_ref(func_name: *u8, func_name_len: i32, param_name: *u8, param_name_len: i32, stage: i32, param_idx: i32, type_ref: i32): void {
  unsafe {
    driver_diagnostic_parser_onefunc_param_ref_impl(func_name, func_name_len, param_name, param_name_len, stage, param_idx, type_ref);
  }
}

// See implementation.

// driver_diagnostic_typeck_import_const_must_be_qualified: see function docblock below.


/** Exported function `driver_diagnostic_typeck_import_const_must_be_qualified`.
 * Implements `driver_diagnostic_typeck_import_const_must_be_qualified`.
 * @param line i32
 * @param col i32
 * @param name *u8
 * @param name_len i32
 * @param binding *u8
 * @param binding_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_import_const_must_be_qualified(line: i32, col: i32, name: *u8, name_len: i32, binding: *u8, binding_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_import_const_must_be_qualified_impl(line, col, name, name_len, binding, binding_len);
  }
}

// See implementation.


// driver_diagnostic_typeck_block_enter: see function docblock below.

/** Exported function `driver_diagnostic_typeck_block_enter`.
 * Implements `driver_diagnostic_typeck_block_enter`.
 * @param func_idx i32
 * @param block_ref i32
 * @param n_const i32
 * @param n_let i32
 * @param n_loop i32
 * @param n_for i32
 * @param n_expr i32
 * @param final_ref i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_block_enter(func_idx: i32, block_ref: i32, n_const: i32, n_let: i32, n_loop: i32, n_for: i32, n_expr: i32, final_ref: i32): void {
  unsafe {
    driver_diagnostic_typeck_block_enter_impl(func_idx, block_ref, n_const, n_let, n_loop, n_for, n_expr, final_ref);
  }
}

/** Exported function `driver_diagnostic_typeck_fn_enter`.
 * Implements `driver_diagnostic_typeck_fn_enter`.
 * @param func_idx i32
 * @param name *u8
 * @param name_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_fn_enter(func_idx: i32, name: *u8, name_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_fn_enter_impl(func_idx, name, name_len);
  }
}

/** Exported function `driver_diagnostic_typeck_var_resolution`.
 * Implements `driver_diagnostic_typeck_var_resolution`.
 * @param expr_ref i32
 * @param name *u8
 * @param name_len i32
 * @param func_idx i32
 * @param block_ref i32
 * @param source i32
 * @param type_ref i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_var_resolution(expr_ref: i32, name: *u8, name_len: i32, func_idx: i32, block_ref: i32, source: i32, type_ref: i32): void {
  unsafe {
    driver_diagnostic_typeck_var_resolution_impl(expr_ref, name, name_len, func_idx, block_ref, source, type_ref);
  }
}

// driver_diagnostic_before_codegen: see function docblock below.
/** Exported function `driver_diagnostic_before_codegen`.
 * Implements `driver_diagnostic_before_codegen`.
 * @param num_funcs i32
 * @param out_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_before_codegen(num_funcs: i32, out_len: i32): void {
  unsafe {
    if (driver_diag_env_debug_pipe() != 0) {
      driver_diag_pipe_note(0, num_funcs, out_len);
    }
  }
}

/** Exported function `driver_diagnostic_source_len`.
 * Query helper `driver_diagnostic_source_len`.
 * @param len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_source_len(len: i32): void {
  unsafe {
    if (driver_diag_env_debug_pipe() != 0) {
      driver_diag_pipe_note(1, len, 0);
    }
  }
}

/** Exported function `driver_diagnostic_after_entry_parse`.
 * Implements `driver_diagnostic_after_entry_parse`.
 * @param num_funcs i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_after_entry_parse(num_funcs: i32): void {
  unsafe {
    if (driver_diag_env_debug_pipe() != 0) {
      driver_diag_pipe_note(2, num_funcs, 0);
    }
  }
}

/** Exported function `driver_diagnostic_parse_commit_fail`.
 * Implements `driver_diagnostic_parse_commit_fail`.
 * @param byte_pos i32
 * @param num_funcs_so_far i32
 * @param name_len i32
 * @param name *u8
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_parse_commit_fail(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void {
  unsafe {
    driver_diagnostic_parse_commit_fail_impl(byte_pos, num_funcs_so_far, name_len, name);
  }
}

/** Exported function `driver_diagnostic_parse_func_generic`.
 * Implements `driver_diagnostic_parse_func_generic`.
 * @param byte_pos i32
 * @param num_funcs_so_far i32
 * @param name *u8
 * @param name_len i32
 * @param num_generic_params i32
 * @param is_main i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_parse_func_generic(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, num_generic_params: i32, is_main: i32): void {
  unsafe {
    driver_diagnostic_parse_func_generic_impl(byte_pos, num_funcs_so_far, name, name_len, num_generic_params, is_main);
  }
}

/** Exported function `driver_diagnostic_parse_commit_shape`.
 * Implements `driver_diagnostic_parse_commit_shape`.
 * @param byte_pos i32
 * @param num_funcs_so_far i32
 * @param name *u8
 * @param name_len i32
 * @param phase i32
 * @param block_ref i32
 * @param pool_num_consts i32
 * @param pool_num_lets i32
 * @param pool_num_ifs i32
 * @param pool_num_regions i32
 * @param pool_num_stmt_order i32
 * @param block_num_consts i32
 * @param block_num_lets i32
 * @param block_num_ifs i32
 * @param block_num_regions i32
 * @param block_num_stmt_order i32
 * @param final_expr_ref i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_parse_commit_shape(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void {
  unsafe {
    driver_diagnostic_parse_commit_shape_impl(byte_pos, num_funcs_so_far, name, name_len, phase, block_ref, pool_num_consts, pool_num_lets, pool_num_ifs, pool_num_regions, pool_num_stmt_order, block_num_consts, block_num_lets, block_num_ifs, block_num_regions, block_num_stmt_order, final_expr_ref);
  }
}

/** Exported function `parser_diagnostic_parse_commit_shape`.
 * Implements `parser_diagnostic_parse_commit_shape`.
 * @param byte_pos i32
 * @param num_funcs_so_far i32
 * @param name *u8
 * @param name_len i32
 * @param phase i32
 * @param block_ref i32
 * @param pool_num_consts i32
 * @param pool_num_lets i32
 * @param pool_num_ifs i32
 * @param pool_num_regions i32
 * @param pool_num_stmt_order i32
 * @param block_num_consts i32
 * @param block_num_lets i32
 * @param block_num_ifs i32
 * @param block_num_regions i32
 * @param block_num_stmt_order i32
 * @param final_expr_ref i32
 * @return void
 */
#[no_mangle]
export function parser_diagnostic_parse_commit_shape(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void {
  unsafe {
    parser_diagnostic_parse_commit_shape_impl(byte_pos, num_funcs_so_far, name, name_len, phase, block_ref, pool_num_consts, pool_num_lets, pool_num_ifs, pool_num_regions, pool_num_stmt_order, block_num_consts, block_num_lets, block_num_ifs, block_num_regions, block_num_stmt_order, final_expr_ref);
  }
}

/** Exported function `driver_diagnostic_after_entry_parse_module`.
 * Implements `driver_diagnostic_after_entry_parse_module`.
 * @param module *u8
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_after_entry_parse_module(module: *u8): void {
  unsafe {
    driver_diagnostic_after_entry_parse_module_impl(module);
  }
}

/** Exported function `driver_diagnostic_pipe_marker`.
 * Implements `driver_diagnostic_pipe_marker`.
 * @param id i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_pipe_marker(id: i32): void {
  unsafe {
    if (driver_diag_env_debug_pipe() != 0) {
      driver_diag_pipe_note(3, id, 0);
    }
  }
}

/** Exported function `driver_diagnostic_codegen_fail`.
 * Implements `driver_diagnostic_codegen_fail`.
 * @param dep_index i32
 * @param is_dep i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_codegen_fail(dep_index: i32, is_dep: i32): void {
  unsafe {
    driver_diagnostic_codegen_fail_impl(dep_index, is_dep);
  }
}

/** Exported function `driver_diagnostic_codegen_emit_func_fail`.
 * Implements `driver_diagnostic_codegen_emit_func_fail`.
 * @param module *u8
 * @param func_index i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_codegen_emit_func_fail(module: *u8, func_index: i32): void {
  unsafe {
    driver_diagnostic_codegen_emit_func_fail_impl(module, func_index);
  }
}

// See implementation.


// driver_diagnostic_asm_set_last_expr_kind: see function docblock below.
/** Exported function `driver_diagnostic_asm_set_last_expr_kind`.
 * Implements `driver_diagnostic_asm_set_last_expr_kind`.
 * @param k i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_asm_set_last_expr_kind(k: i32): void {
  unsafe {
    driver_diagnostic_asm_last_expr_kind_set(k);
  }
}

/** Exported function `driver_diagnostic_asm_set_current_func`.
 * Implements `driver_diagnostic_asm_set_current_func`.
 * @param name *u8
 * @param len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_asm_set_current_func(name: *u8, len: i32): void {
  unsafe {
    driver_diagnostic_asm_current_func_store(name, len);
    driver_diagnostic_asm_current_func_maybe_trace();
  }
}

/** Exported function `driver_diagnostic_asm_print_current_func`.
 * Implements `driver_diagnostic_asm_print_current_func`.
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_asm_print_current_func(): void {
  unsafe {
    driver_diagnostic_asm_print_current_func_impl();
  }
}

/** Exported function `driver_diagnostic_asm_var_not_found`.
 * Implements `driver_diagnostic_asm_var_not_found`.
 * @param name *u8
 * @param len i32
 * @param num_locals i32
 * @param first_slot *u8
 * @param first_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_asm_var_not_found(name: *u8, len: i32, num_locals: i32, first_slot: *u8, first_len: i32): void {
  unsafe {
    driver_diagnostic_asm_var_not_found_impl(name, len, num_locals, first_slot, first_len);
  }
}

/** Exported function `driver_diagnostic_asm_fail_at`.
 * Implements `driver_diagnostic_asm_fail_at`.
 * @param loc i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_asm_fail_at(loc: i32): void {
  unsafe {
    driver_diagnostic_asm_fail_at_impl(loc);
  }
}

/** Exported function `driver_debug_log`.
 * Implements `driver_debug_log`.
 * @param step i32
 * @return void
 */
#[no_mangle]
export function driver_debug_log(step: i32): void {
  unsafe {
    driver_debug_log_impl(step);
  }
}

/** Exported function `parser_diag_tok_kind`.
 * Implements `parser_diag_tok_kind`.
 * @param k i32
 * @return void
 */
#[no_mangle]
export function parser_diag_tok_kind(k: i32): void {
  unsafe {
    parser_diag_tok_kind_impl(k);
  }
}

/** Exported function `parser_diag_ident_len`.
 * Query helper `parser_diag_ident_len`.
 * @param len i32
 * @return void
 */
#[no_mangle]
export function parser_diag_ident_len(len: i32): void {
  unsafe {
    parser_diag_ident_len_impl(len);
  }
}

/** Exported function `parser_diag_scan_fail`.
 * Implements `parser_diag_scan_fail`.
 * @param step i32
 * @return void
 */
#[no_mangle]
export function parser_diag_scan_fail(step: i32): void {
  unsafe {
    parser_diag_scan_fail_impl(step);
  }
}


/** Exported function `driver_diagnostic_warn_pad_fields_same_cache_line`.
 * Implements `driver_diagnostic_warn_pad_fields_same_cache_line`.
 * @param sname *u8
 * @param sname_len i32
 * @param f0 *u8
 * @param f0_len i32
 * @param f1 *u8
 * @param f1_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_warn_pad_fields_same_cache_line(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void {
  unsafe {
    driver_diagnostic_warn_pad_fields_same_cache_line_impl(sname, sname_len, f0, f0_len, f1, f1_len);
  }
}

/** Exported function `driver_diagnostic_warn_hot_reorder_field`.
 * Implements `driver_diagnostic_warn_hot_reorder_field`.
 * @param sname *u8
 * @param sname_len i32
 * @param hot *u8
 * @param hot_len i32
 * @param cold *u8
 * @param cold_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_warn_hot_reorder_field(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void {
  unsafe {
    driver_diagnostic_warn_hot_reorder_field_impl(sname, sname_len, hot, hot_len, cold, cold_len);
  }
}

/** Exported function `driver_diagnostic_hint_unused_binding`.
 * Implements `driver_diagnostic_hint_unused_binding`.
 * @param line i32
 * @param col i32
 * @param name *u8
 * @param name_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_hint_unused_binding(line: i32, col: i32, name: *u8, name_len: i32): void {
  unsafe {
    driver_diagnostic_hint_unused_binding_impl(line, col, name, name_len);
  }
}


/* ---- G-02f-86 / G-02f-163：diag copy_bytes / report_prefixed ---- */

// driver_diag_report_prefixed: see function docblock below.
/** Exported function `driver_diag_report_prefixed`.
 * Implements `driver_diag_report_prefixed`.
 * @param line i32
 * @param col i32
 * @param msg *u8
 * @return void
 */
#[no_mangle]
export function driver_diag_report_prefixed(line: i32, col: i32, msg: *u8): void {
  unsafe {
    if (lsp_diag_get_enabled() != 0) {
      let ln: i32 = line;
      let cl: i32 = col;
      if (ln <= 0) { ln = 1; }
      if (cl <= 0) { cl = 1; }
      let m: *u8 = msg;
      if (m == 0) { m = ""; }
      lsp_diag_add(ln, cl, 1, m);
      return;
    }
    if (driver_check_only_get() != 0) {
      driver_check_diag_emitted_note();
    }
    let m2: *u8 = msg;
    if (m2 == 0) { m2 = ""; }
    diag_report(0 as *u8, line, col, 0 as *u8, m2, m2);
  }
}

// parser_is_ident_allow: see function docblock below.

/** Exported function `parser_is_ident_allow`.
 * Implements `parser_is_ident_allow`.
 * @param ident *u8
 * @param len i32
 * @return i32
 */
#[no_mangle]
export function parser_is_ident_allow(ident: *u8, len: i32): i32 {
  if (ident == 0) { return 0; }
  if (len != 5) { return 0; }
  // "allow"
  if (ident[0] == 97 && ident[1] == 108 && ident[2] == 108 && ident[3] == 111 && ident[4] == 119) {
    return 1;
  }
  return 0;
}

// driver_diag_copy_bytes: see function docblock below.

/** Exported function `driver_diag_copy_bytes`.
 * Implements `driver_diag_copy_bytes`.
 * @param dst *u8
 * @param dst_size i64
 * @param src *u8
 * @param src_len i32
 * @return i32
 */
#[no_mangle]
export function driver_diag_copy_bytes(dst: *u8, dst_size: i64, src: *u8, src_len: i32): i32 {
  if (dst == 0) { return 0; }
  if (dst_size == 0) { return 0; }
  let n: i32 = 0;
  if (src != 0) {
    if (src_len > 0) {
      while (n < src_len) {
        if ((n as i64) + 1 >= dst_size) { break; }
        dst[n] = src[n];
        n = n + 1;
      }
    }
  }
  dst[n] = 0;
  return n;
}

// driver_diag_fill_expr_part: see function docblock below.
/** Exported function `driver_diag_fill_expr_part`.
 * Implements `driver_diag_fill_expr_part`.
 * @param dst *u8
 * @param cap i32
 * @param expr_buf *u8
 * @param expr_len i32
 * @return void
 */
export function driver_diag_fill_expr_part(dst: *u8, cap: i32, expr_buf: *u8, expr_len: i32): void {
  if (dst == 0) { return; }
  if (cap <= 0) { return; }
  let el: i32 = 0;
  if (expr_buf != 0) {
    if (expr_len > 0) { el = expr_len; }
  }
  if (el > 0) {
    if (el < cap) {
      let n: i32 = driver_diag_copy_bytes(dst, cap as i64, expr_buf, el);
      return;
    }
  }
  dst[0] = 63; // '?'
  if (cap > 1) { dst[1] = 0; }
}

/** Exported function `driver_diag_append_cstr`.
 * Implements `driver_diag_append_cstr`.
 * @param dst *u8
 * @param cap i32
 * @param at i32
 * @param src *u8
 * @return i32
 */
export function driver_diag_append_cstr(dst: *u8, cap: i32, at: i32, src: *u8): i32 {
  if (dst == 0) { return at; }
  if (src == 0) { return at; }
  let j: i32 = at;
  let i: i32 = 0;
  while (j + 1 < cap) {
    let c: u8 = src[i];
    if (c == 0) { break; }
    dst[j] = c;
    j = j + 1;
    i = i + 1;
  }
  dst[j] = 0;
  return j;
}

/** Exported function `driver_diagnostic_typeck_return_unresolved`.
 * Implements `driver_diagnostic_typeck_return_unresolved`.
 * @param line i32
 * @param col i32
 * @param expr_buf *u8
 * @param expr_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_return_unresolved(line: i32, col: i32, expr_buf: *u8, expr_len: i32): void {
  let expr_part: u8[128] = [];
  let msg: u8[240] = [];
  driver_diag_fill_expr_part(&expr_part[0], 128, expr_buf, expr_len);
  let pref: *u8 = "typeck error: cannot resolve return subexpression: ";
  let at: i32 = driver_diag_append_cstr(&msg[0], 240, 0, pref);
  at = driver_diag_append_cstr(&msg[0], 240, at, &expr_part[0]);
  driver_diag_report_prefixed(line, col, &msg[0]);
}

/** Exported function `driver_diagnostic_typeck_return_subexpr`.
 * Implements `driver_diagnostic_typeck_return_subexpr`.
 * @param line i32
 * @param col i32
 * @param expr_buf *u8
 * @param expr_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_return_subexpr(line: i32, col: i32, expr_buf: *u8, expr_len: i32): void {
  let expr_part: u8[128] = [];
  let msg: u8[240] = [];
  driver_diag_fill_expr_part(&expr_part[0], 128, expr_buf, expr_len);
  let pref: *u8 = "typeck note: return subexpression: ";
  let at: i32 = driver_diag_append_cstr(&msg[0], 240, 0, pref);
  at = driver_diag_append_cstr(&msg[0], 240, at, &expr_part[0]);
  driver_diag_report_prefixed(line, col, &msg[0]);
}

// driver_diag_build_expected_found: see function docblock below.
/** Exported function `driver_diag_build_expected_found`.
 * Implements `driver_diag_build_expected_found`.
 * @param msg *u8
 * @param msg_cap i32
 * @param pref *u8
 * @param epart *u8
 * @param fpart *u8
 * @return void
 */
export function driver_diag_build_expected_found(msg: *u8, msg_cap: i32, pref: *u8, epart: *u8, fpart: *u8): void {
  let mid: *u8 = ", found ";
  let at: i32 = driver_diag_append_cstr(msg, msg_cap, 0, pref);
  at = driver_diag_append_cstr(msg, msg_cap, at, epart);
  at = driver_diag_append_cstr(msg, msg_cap, at, mid);
  at = driver_diag_append_cstr(msg, msg_cap, at, fpart);
}

/** Exported function `driver_diagnostic_typeck_return_mismatch`.
 * Implements `driver_diagnostic_typeck_return_mismatch`.
 * @param line i32
 * @param col i32
 * @param expect_buf *u8
 * @param expect_len i32
 * @param found_buf *u8
 * @param found_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_return_mismatch(line: i32, col: i32, expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void {
  let epart: u8[112] = [];
  let fpart: u8[112] = [];
  let msg: u8[240] = [];
  driver_diag_fill_expr_part(&epart[0], 112, expect_buf, expect_len);
  driver_diag_fill_expr_part(&fpart[0], 112, found_buf, found_len);
  let pref: *u8 = "typeck error: return expression type mismatch: expected ";
  driver_diag_build_expected_found(&msg[0], 240, pref, &epart[0], &fpart[0]);
  driver_diag_report_prefixed(line, col, &msg[0]);
}

/** Exported function `driver_diagnostic_typeck_assign_mismatch`.
 * Implements `driver_diagnostic_typeck_assign_mismatch`.
 * @param is_compound i32
 * @param line i32
 * @param col i32
 * @param expect_buf *u8
 * @param expect_len i32
 * @param found_buf *u8
 * @param found_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_assign_mismatch(is_compound: i32, line: i32, col: i32, expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void {
  let epart: u8[112] = [];
  let fpart: u8[112] = [];
  let msg: u8[240] = [];
  driver_diag_fill_expr_part(&epart[0], 112, expect_buf, expect_len);
  driver_diag_fill_expr_part(&fpart[0], 112, found_buf, found_len);
  let pref: *u8 = "typeck error: assignment type mismatch: expected ";
  if (is_compound != 0) {
    pref = "typeck error: compound assignment type mismatch: expected ";
  }
  driver_diag_build_expected_found(&msg[0], 240, pref, &epart[0], &fpart[0]);
  driver_diag_report_prefixed(line, col, &msg[0]);
}

// driver_diag_append_i32: see function docblock below.
/** Exported function `driver_diag_append_i32`.
 * Implements `driver_diag_append_i32`.
 * @param dst *u8
 * @param cap i32
 * @param at i32
 * @param val i32
 * @return i32
 */
export function driver_diag_append_i32(dst: *u8, cap: i32, at: i32, val: i32): i32 {
  if (dst == 0) { return at; }
  if (at + 1 >= cap) { return at; }
  let v: i32 = val;
  if (v < 0) {
    dst[at] = 45; // '-'
    at = at + 1;
    v = 0 - v;
  }
  let digits: i32[12] = [];
  let dn: i32 = 0;
  if (v == 0) {
    digits[0] = 0;
    dn = 1;
  } else {
    let t: i32 = v;
    while (t > 0) {
      if (dn >= 12) { break; }
      digits[dn] = t % 10;
      t = t / 10;
      dn = dn + 1;
    }
  }
  let i: i32 = dn - 1;
  while (i >= 0) {
    if (at + 1 >= cap) { break; }
    dst[at] = (digits[i] + 48) as u8;
    at = at + 1;
    i = i - 1;
  }
  dst[at] = 0;
  return at;
}

/** Exported function `driver_diag_append_name`.
 * Implements `driver_diag_append_name`.
 * @param dst *u8
 * @param cap i32
 * @param at i32
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function driver_diag_append_name(dst: *u8, cap: i32, at: i32, name: *u8, name_len: i32): i32 {
  if (name == 0) { return at; }
  if (name_len <= 0) { return at; }
  let n: i32 = 0;
  while (n < name_len) {
    if (at + 1 >= cap) { break; }
    dst[at] = name[n];
    at = at + 1;
    n = n + 1;
  }
  dst[at] = 0;
  return at;
}

/** Exported function `driver_diagnostic_typeck_call_not_generic`.
 * Implements `driver_diagnostic_typeck_call_not_generic`.
 * @param line i32
 * @param col i32
 * @param name *u8
 * @param name_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_call_not_generic(line: i32, col: i32, name: *u8, name_len: i32): void {
  let msg: u8[240] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 240, 0, "function '");
  at = driver_diag_append_name(&msg[0], 240, at, name, name_len);
  at = driver_diag_append_cstr(&msg[0], 240, at, "' is not generic but type arguments were provided");
  unsafe {
    lsp_diag_report_typeck(line, col, &msg[0]);
  }
}

/** Exported function `driver_diagnostic_typeck_call_wrong_num_type_args`.
 * Implements `driver_diagnostic_typeck_call_wrong_num_type_args`.
 * @param line i32
 * @param col i32
 * @param name *u8
 * @param name_len i32
 * @param expect_n i32
 * @param got_n i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_call_wrong_num_type_args(line: i32, col: i32, name: *u8, name_len: i32, expect_n: i32, got_n: i32): void {
  let msg: u8[240] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 240, 0, "generic function '");
  at = driver_diag_append_name(&msg[0], 240, at, name, name_len);
  at = driver_diag_append_cstr(&msg[0], 240, at, "' expects ");
  at = driver_diag_append_i32(&msg[0], 240, at, expect_n);
  at = driver_diag_append_cstr(&msg[0], 240, at, " type arguments, got ");
  at = driver_diag_append_i32(&msg[0], 240, at, got_n);
  unsafe {
    lsp_diag_report_typeck(line, col, &msg[0]);
  }
}

/** Exported function `driver_diagnostic_typeck_call_requires_type_args`.
 * Implements `driver_diagnostic_typeck_call_requires_type_args`.
 * @param line i32
 * @param col i32
 * @param name *u8
 * @param name_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_call_requires_type_args(line: i32, col: i32, name: *u8, name_len: i32): void {
  let msg: u8[280] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 280, 0, "generic function '");
  at = driver_diag_append_name(&msg[0], 280, at, name, name_len);
  at = driver_diag_append_cstr(&msg[0], 280, at, "' requires type arguments (e.g. ");
  at = driver_diag_append_name(&msg[0], 280, at, name, name_len);
  at = driver_diag_append_cstr(&msg[0], 280, at, "<Type>(...))");
  unsafe {
    lsp_diag_report_typeck(line, col, &msg[0]);
  }
}

// driver_diagnostic_typeck_struct_padding_before: see function docblock below.
/** Exported function `driver_diagnostic_typeck_struct_padding_before`.
 * Implements `driver_diagnostic_typeck_struct_padding_before`.
 * @param sname *u8
 * @param sname_len i32
 * @param gap i32
 * @param fname *u8
 * @param fname_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_struct_padding_before(sname: *u8, sname_len: i32, gap: i32, fname: *u8, fname_len: i32): void {
  let msg: u8[320] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 320, 0, "struct '");
  at = driver_diag_append_name(&msg[0], 320, at, sname, sname_len);
  at = driver_diag_append_cstr(&msg[0], 320, at, "' has ");
  at = driver_diag_append_i32(&msg[0], 320, at, gap);
  at = driver_diag_append_cstr(&msg[0], 320, at, " byte(s) implicit padding before field '");
  at = driver_diag_append_name(&msg[0], 320, at, fname, fname_len);
  at = driver_diag_append_cstr(&msg[0], 320, at, "'; add explicit padding field or allow(padding)");
  unsafe {
    lsp_diag_report_typeck(0, 0, &msg[0]);
  }
}

/** Exported function `driver_diagnostic_typeck_struct_padding_trailing`.
 * Implements `driver_diagnostic_typeck_struct_padding_trailing`.
 * @param sname *u8
 * @param sname_len i32
 * @param gap i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_struct_padding_trailing(sname: *u8, sname_len: i32, gap: i32): void {
  let msg: u8[320] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 320, 0, "struct '");
  at = driver_diag_append_name(&msg[0], 320, at, sname, sname_len);
  at = driver_diag_append_cstr(&msg[0], 320, at, "' has ");
  at = driver_diag_append_i32(&msg[0], 320, at, gap);
  at = driver_diag_append_cstr(&msg[0], 320, at, " byte(s) implicit trailing padding; add explicit padding field or allow(padding)");
  unsafe {
    lsp_diag_report_typeck(0, 0, &msg[0]);
  }
}

/** Exported function `driver_diagnostic_typeck_struct_field_bad_size`.
 * Implements `driver_diagnostic_typeck_struct_field_bad_size`.
 * @param sname *u8
 * @param sname_len i32
 * @param fname *u8
 * @param fname_len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_typeck_struct_field_bad_size(sname: *u8, sname_len: i32, fname: *u8, fname_len: i32): void {
  let msg: u8[280] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 280, 0, "struct '");
  at = driver_diag_append_name(&msg[0], 280, at, sname, sname_len);
  at = driver_diag_append_cstr(&msg[0], 280, at, "' field '");
  at = driver_diag_append_name(&msg[0], 280, at, fname, fname_len);
  at = driver_diag_append_cstr(&msg[0], 280, at, "' has unknown or invalid type size");
  unsafe {
    lsp_diag_report_typeck(0, 0, &msg[0]);
  }
}

// driver_diag_note: see function docblock below.
/** Exported function `driver_diag_note`.
 * Implements `driver_diag_note`.
 * @param msg *u8
 * @return void
 */
export function driver_diag_note(msg: *u8): void {
  unsafe {
    let m: *u8 = msg;
    if (m == 0) { m = ""; }
    diag_report(0 as *u8, 0, 0, "note", m, 0 as *u8);
  }
}

/** Exported function `driver_diagnostic_asm_unsupported_expr`.
 * Implements `driver_diagnostic_asm_unsupported_expr`.
 * @param kind i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_asm_unsupported_expr(kind: i32): void {
  let msg: u8[96] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 96, 0, "asm codegen unsupported ExprKind=");
  at = driver_diag_append_i32(&msg[0], 96, at, kind);
  driver_diag_note(&msg[0]);
}

/** Exported function `driver_diagnostic_asm_elf_unresolved_patch`.
 * Implements `driver_diagnostic_asm_elf_unresolved_patch`.
 * @param name *u8
 * @param len i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_asm_elf_unresolved_patch(name: *u8, len: i32): void {
  let namebuf: u8[65] = [];
  driver_diag_fill_expr_part(&namebuf[0], 65, name, len);
  let msg: u8[160] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 160, 0, "elf unresolved patch label name_len=");
  at = driver_diag_append_i32(&msg[0], 160, at, len);
  at = driver_diag_append_cstr(&msg[0], 160, at, " name='");
  at = driver_diag_append_cstr(&msg[0], 160, at, &namebuf[0]);
  at = driver_diag_append_cstr(&msg[0], 160, at, "'");
  driver_diag_note(&msg[0]);
}

/** Exported function `driver_diagnostic_asm_macho_empty_reloc`.
 * Implements `driver_diagnostic_asm_macho_empty_reloc`.
 * @param reloc_idx i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_asm_macho_empty_reloc(reloc_idx: i32): void {
  let msg: u8[96] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 96, 0, "macho empty reloc symbol at idx=");
  at = driver_diag_append_i32(&msg[0], 96, at, reloc_idx);
  driver_diag_note(&msg[0]);
}

/** Exported function `driver_diagnostic_asm_macho_missing_und_reloc`.
 * Implements `driver_diagnostic_asm_macho_missing_und_reloc`.
 * @param reloc_idx i32
 * @return void
 */
#[no_mangle]
export function driver_diagnostic_asm_macho_missing_und_reloc(reloc_idx: i32): void {
  let msg: u8[96] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 96, 0, "macho undef reloc not in und pool at idx=");
  at = driver_diag_append_i32(&msg[0], 96, at, reloc_idx);
  driver_diag_note(&msg[0]);
}
