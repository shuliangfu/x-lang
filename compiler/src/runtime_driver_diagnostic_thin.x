// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-339～341/409/416：runtime_driver_diagnostic L2 thin — pure _impl 门闩子集（无字符串字面量）。
// 产品 PREFER_X_O：g05_try_x_to_o → thin.o + seeds/runtime_driver_diagnostic.from_x.c rest
//   （-DSHUX_L2_RDD_THIN_FROM_X）ld -r → src/runtime_driver_diagnostic.o
// 完整逻辑源仍见 src/runtime_driver_diagnostic.x（整文件 -E 仍 typeck/字符串阻）。
// 本 TU 门闩数：77（f-339～341 + f-387 env + f-409 pipe/storage + f-416 lsp_diag_get）

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

// ---- G-02f-340 pure full bodies ----
extern "C" function driver_check_only_get(): i32;
extern "C" function driver_check_diag_emitted_get(): i32;
// G-02f-409：storage / pipe shells → seed *_impl
extern "C" function driver_diagnostic_asm_last_expr_kind_set_impl(k: i32): void;
extern "C" function driver_diagnostic_asm_current_func_store_impl(name: *u8, len: i32): void;
extern "C" function driver_diagnostic_asm_current_func_maybe_trace_impl(): void;
extern "C" function driver_diag_pipe_note_impl(kind: i32, a: i32, b: i32): void;

#[no_mangle]
function driver_diagnostic_entry_already(v: i32): void {
}

#[no_mangle]
function driver_diagnostic_after_dep_codegen(j: i32, out_len: i32): void {
}

#[no_mangle]
function driver_diagnostic_typeck_fail(): void {
  unsafe {
    let _a: i32 = driver_check_only_get();
    let _b: i32 = driver_check_diag_emitted_get();
  }
}

#[no_mangle]
function driver_diagnostic_asm_last_expr_kind_set(k: i32): void {
  unsafe {
    driver_diagnostic_asm_last_expr_kind_set_impl(k);
  }
}

#[no_mangle]
function driver_diagnostic_asm_current_func_store(name: *u8, len: i32): void {
  unsafe {
    driver_diagnostic_asm_current_func_store_impl(name, len);
  }
}

#[no_mangle]
function driver_diagnostic_asm_current_func_maybe_trace(): void {
  unsafe {
    driver_diagnostic_asm_current_func_maybe_trace_impl();
  }
}

#[no_mangle]
function driver_diag_pipe_note(kind: i32, a: i32, b: i32): void {
  unsafe {
    driver_diag_pipe_note_impl(kind, a, b);
  }
}

#[no_mangle]
function driver_diagnostic_asm_set_last_expr_kind(k: i32): void {
  unsafe {
    driver_diagnostic_asm_last_expr_kind_set_impl(k);
  }
}

#[no_mangle]
function driver_diagnostic_asm_set_current_func(name: *u8, len: i32): void {
  unsafe {
    driver_diagnostic_asm_current_func_store_impl(name, len);
    driver_diagnostic_asm_current_func_maybe_trace_impl();
  }
}

#[no_mangle]
function driver_diag_append_cstr(dst: *u8, cap: i32, at: i32, src: *u8): i32 {
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

#[no_mangle]
function driver_diag_append_name(dst: *u8, cap: i32, at: i32, name: *u8, name_len: i32): i32 {
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

#[no_mangle]
function driver_diag_append_i32(dst: *u8, cap: i32, at: i32, val: i32): i32 {
  if (dst == 0) { return at; }
  if (at + 1 >= cap) { return at; }
  let v: i32 = val;
  if (v < 0) {
    dst[at] = 45;
    at = at + 1;
    v = 0 - v;
  }
  let d0: i32 = 0;
  let d1: i32 = 0;
  let d2: i32 = 0;
  let d3: i32 = 0;
  let d4: i32 = 0;
  let d5: i32 = 0;
  let d6: i32 = 0;
  let d7: i32 = 0;
  let d8: i32 = 0;
  let d9: i32 = 0;
  let dn: i32 = 0;
  if (v == 0) {
    d0 = 0;
    dn = 1;
  } else {
    let t: i32 = v;
    while (t > 0) {
      if (dn >= 10) { break; }
      let dig: i32 = t % 10;
      if (dn == 0) { d0 = dig; }
      if (dn == 1) { d1 = dig; }
      if (dn == 2) { d2 = dig; }
      if (dn == 3) { d3 = dig; }
      if (dn == 4) { d4 = dig; }
      if (dn == 5) { d5 = dig; }
      if (dn == 6) { d6 = dig; }
      if (dn == 7) { d7 = dig; }
      if (dn == 8) { d8 = dig; }
      if (dn == 9) { d9 = dig; }
      t = t / 10;
      dn = dn + 1;
    }
  }
  let i: i32 = dn - 1;
  while (i >= 0) {
    if (at + 1 >= cap) { break; }
    let dig: i32 = 0;
    if (i == 0) { dig = d0; }
    if (i == 1) { dig = d1; }
    if (i == 2) { dig = d2; }
    if (i == 3) { dig = d3; }
    if (i == 4) { dig = d4; }
    if (i == 5) { dig = d5; }
    if (i == 6) { dig = d6; }
    if (i == 7) { dig = d7; }
    if (i == 8) { dig = d8; }
    if (i == 9) { dig = d9; }
    dst[at] = (dig + 48) as u8;
    at = at + 1;
    i = i - 1;
  }
  dst[at] = 0;
  return at;
}




#[no_mangle]
function driver_diag_copy_bytes(dst: *u8, dst_size: i64, src: *u8, src_len: i32): i32 {
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

// ---- G-02f-340 _impl gates ----
extern "C" function driver_diagnostic_before_codegen_impl(num_funcs: i32, out_len: i32): void;
extern "C" function driver_diagnostic_source_len_impl(len: i32): void;
extern "C" function driver_diagnostic_after_entry_parse_impl(num_funcs: i32): void;
extern "C" function driver_diagnostic_pipe_marker_impl(id: i32): void;
extern "C" function driver_diag_fill_expr_part_impl(dst: *u8, cap: i32, expr_buf: *u8, expr_len: i32): void;
extern "C" function driver_diagnostic_typeck_if_condition_not_bool_impl(line: i32, col: i32): void;
extern "C" function driver_diagnostic_typeck_while_condition_not_bool_impl(line: i32, col: i32): void;
extern "C" function driver_diagnostic_typeck_for_condition_not_bool_impl(line: i32, col: i32): void;
extern "C" function driver_diagnostic_typeck_deref_outside_unsafe_impl(line: i32, col: i32): void;
extern "C" function driver_diagnostic_typeck_extern_call_outside_unsafe_impl(line: i32, col: i32): void;
extern "C" function driver_diagnostic_typeck_linear_addr_of_impl(line: i32, col: i32): void;
extern "C" function driver_diagnostic_typeck_subscript_base_impl(line: i32, col: i32): void;
extern "C" function driver_diagnostic_typeck_enum_no_variant_impl(line: i32, col: i32): void;
extern "C" function driver_diagnostic_typeck_try_propagate_bad_enclosing_impl(line: i32, col: i32): void;
extern "C" function driver_diagnostic_typeck_break_continue_outside_impl(line: i32, col: i32, is_break: i32): void;

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
function driver_diagnostic_pipe_marker(id: i32): void {
  unsafe {
    driver_diagnostic_pipe_marker_impl(id);
  }
}


#[no_mangle]
function driver_diagnostic_typeck_if_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    driver_diagnostic_typeck_if_condition_not_bool_impl(line, col);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_while_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    driver_diagnostic_typeck_while_condition_not_bool_impl(line, col);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_for_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    driver_diagnostic_typeck_for_condition_not_bool_impl(line, col);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_deref_outside_unsafe(line: i32, col: i32): void {
  unsafe {
    driver_diagnostic_typeck_deref_outside_unsafe_impl(line, col);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_extern_call_outside_unsafe(line: i32, col: i32): void {
  unsafe {
    driver_diagnostic_typeck_extern_call_outside_unsafe_impl(line, col);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_linear_addr_of(line: i32, col: i32): void {
  unsafe {
    driver_diagnostic_typeck_linear_addr_of_impl(line, col);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_subscript_base(line: i32, col: i32): void {
  unsafe {
    driver_diagnostic_typeck_subscript_base_impl(line, col);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_enum_no_variant(line: i32, col: i32): void {
  unsafe {
    driver_diagnostic_typeck_enum_no_variant_impl(line, col);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_try_propagate_bad_enclosing(line: i32, col: i32): void {
  unsafe {
    driver_diagnostic_typeck_try_propagate_bad_enclosing_impl(line, col);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_break_continue_outside(line: i32, col: i32, is_break: i32): void {
  unsafe {
    driver_diagnostic_typeck_break_continue_outside_impl(line, col, is_break);
  }
}

// ---- G-02f-341 pure helpers / remaining gates ----

#[no_mangle]
function parser_is_ident_allow(ident: *u8, len: i32): i32 {
  if (ident == 0) { return 0; }
  if (len != 5) { return 0; }
  if (ident[0] == 97 && ident[1] == 108 && ident[2] == 108 && ident[3] == 111 && ident[4] == 119) {
    return 1;
  }
  return 0;
}

// ", found " without string literal


// ---- G-02f-341 remaining string/C-tail gates ----
extern "C" function driver_diag_build_expected_found_impl(msg: *u8, msg_cap: i32, pref: *u8, epart: *u8, fpart: *u8): void;
extern "C" function driver_parse_strict_enabled_impl(): i32;
extern "C" function driver_diag_report_prefixed_impl(line: i32, col: i32, msg: *u8): void;
extern "C" function driver_diag_note_impl(msg: *u8): void;
extern "C" function driver_diagnostic_typeck_return_unresolved_impl(line: i32, col: i32, expr_buf: *u8, expr_len: i32): void;
extern "C" function driver_diagnostic_typeck_return_subexpr_impl(line: i32, col: i32, expr_buf: *u8, expr_len: i32): void;
extern "C" function driver_diagnostic_typeck_return_mismatch_impl(line: i32, col: i32, expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void;
extern "C" function driver_diagnostic_typeck_assign_mismatch_impl(is_compound: i32, line: i32, col: i32, expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void;
extern "C" function driver_diagnostic_typeck_call_not_generic_impl(line: i32, col: i32, name: *u8, name_len: i32): void;
extern "C" function driver_diagnostic_typeck_call_wrong_num_type_args_impl(line: i32, col: i32, name: *u8, name_len: i32, expect_n: i32, got_n: i32): void;
extern "C" function driver_diagnostic_typeck_call_requires_type_args_impl(line: i32, col: i32, name: *u8, name_len: i32): void;
extern "C" function driver_diagnostic_typeck_struct_padding_before_impl(sname: *u8, sname_len: i32, gap: i32, fname: *u8, fname_len: i32): void;
extern "C" function driver_diagnostic_typeck_struct_padding_trailing_impl(sname: *u8, sname_len: i32, gap: i32): void;
extern "C" function driver_diagnostic_typeck_struct_field_bad_size_impl(sname: *u8, sname_len: i32, fname: *u8, fname_len: i32): void;
extern "C" function driver_diagnostic_asm_unsupported_expr_impl(kind: i32): void;
extern "C" function driver_diagnostic_asm_elf_unresolved_patch_impl(name: *u8, len: i32): void;
extern "C" function driver_diagnostic_asm_macho_empty_reloc_impl(reloc_idx: i32): void;
extern "C" function driver_diagnostic_asm_macho_missing_und_reloc_impl(reloc_idx: i32): void;
extern "C" function driver_typeck_diag_scratch_expect_impl(): *u8;
extern "C" function driver_typeck_diag_scratch_found_impl(): *u8;

#[no_mangle]
function driver_parse_strict_enabled(): i32 {
  unsafe {
    return driver_parse_strict_enabled_impl();
  }
  return 0;
}

#[no_mangle]
function driver_diag_report_prefixed(line: i32, col: i32, msg: *u8): void {
  unsafe {
    driver_diag_report_prefixed_impl(line, col, msg);
  }
}

#[no_mangle]
function driver_diag_note(msg: *u8): void {
  unsafe {
    driver_diag_note_impl(msg);
  }
}

#[no_mangle]
function driver_typeck_diag_scratch_expect(): *u8 {
  unsafe {
    return driver_typeck_diag_scratch_expect_impl();
  }
  return 0 as *u8;
}

#[no_mangle]
function driver_typeck_diag_scratch_found(): *u8 {
  unsafe {
    return driver_typeck_diag_scratch_found_impl();
  }
  return 0 as *u8;
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
function driver_diagnostic_typeck_return_mismatch(line: i32, col: i32, expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_return_mismatch_impl(line, col, expect_buf, expect_len, found_buf, found_len);
  }
}

#[no_mangle]
function driver_diagnostic_typeck_assign_mismatch(is_compound: i32, line: i32, col: i32, expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_assign_mismatch_impl(is_compound, line, col, expect_buf, expect_len, found_buf, found_len);
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
function driver_diag_fill_expr_part(dst: *u8, cap: i32, expr_buf: *u8, expr_len: i32): void {
  unsafe {
    driver_diag_fill_expr_part_impl(dst, cap, expr_buf, expr_len);
  }
}

#[no_mangle]
function driver_diag_build_expected_found(msg: *u8, msg_cap: i32, pref: *u8, epart: *u8, fpart: *u8): void {
  unsafe {
    driver_diag_build_expected_found_impl(msg, msg_cap, pref, epart, fpart);
  }
}

// ---- G-02f-387：DEBUG_PIPE env → seed impl ----
extern "C" function driver_diag_env_debug_pipe_impl(): i32;

#[no_mangle]
function driver_diag_env_debug_pipe(): i32 {
  unsafe {
    return driver_diag_env_debug_pipe_impl();
  }
  return 0;
}

// ---- G-02f-416：lsp_diag_enabled getter → seed impl ----
extern "C" function lsp_diag_get_enabled_impl(): i32;

#[no_mangle]
function lsp_diag_get_enabled(): i32 {
  unsafe {
    return lsp_diag_get_enabled_impl();
  }
  return 0;
}
