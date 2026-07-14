// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-339～341/409/416 + Cap residual pure 深迁（续 typeck debug/scratch）：runtime_driver_diagnostic R2 thin。
// 产品 PREFER_X_O：g05_try_x_to_o → thin.o + seeds/runtime_driver_diagnostic.from_x.c rest
//   （-DSHUX_L2_RDD_THIN_FROM_X）ld -r → src/runtime_driver_diagnostic.o
// prove IDENTICAL：thin.x ↔ seeds/runtime_driver_diagnostic_thin_surface.from_x.c
// pure 真体：固定措辞 typeck + pipe orch + 拼装 pure（return/assign/call/struct/asm note
//   + fill/build/note）+ append_*/copy_bytes + env_debug_pipe / parse_strict_enabled
//   + report_prefixed + pipe_note + debug_log/parser_diag_* + typeck_block/fn/var debug
//   + scratch expect/found BSS（append+note / 小 BSS 指针，无 va_list reportf）。
// Cap residual：snprintf/va_list 等 *_impl 仍 rest。
// 本 TU：门闩 + pure 真体（f-339～341 + f-387 env pure + f-409 pipe pure + f-416 lsp_diag_get）

export extern "C" function getenv(name: *u8): *u8;

// pure：getenv 非空且首字节非 '0' → 1（与 seed Cap residual 同形）。
// 调用点用字符串字面量（-E → 实参 compound lit；勿用全局 let u8[] → 悬空/NULL SIGSEGV）。
function driver_env_flag_truthy(name: *u8): i32 {
  unsafe {
    let e: *u8 = getenv(name);
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

export extern "C" function driver_diagnostic_after_entry_parse_module_impl(module: *u8): void;
export extern "C" function driver_diagnostic_asm_fail_at_impl(loc: i32): void;
export extern "C" function driver_diagnostic_asm_print_current_func_impl(): void;
export extern "C" function driver_diagnostic_asm_var_not_found_impl(name: *u8, len: i32, num_locals: i32, first_slot: *u8, first_len: i32): void;
export extern "C" function driver_diagnostic_codegen_emit_func_fail_impl(module: *u8, func_index: i32): void;
export extern "C" function driver_diagnostic_codegen_fail_impl(dep_index: i32, is_dep: i32): void;
export extern "C" function driver_diagnostic_hint_unused_binding_impl(line: i32, col: i32, name: *u8, name_len: i32): void;
export extern "C" function driver_diagnostic_parse_commit_fail_impl(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
export extern "C" function driver_diagnostic_parse_commit_shape_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void;
export extern "C" function driver_diagnostic_parse_fail_impl(main_idx: i32, num_funcs: i32, arena_num_types: i32): void;
export extern "C" function driver_diagnostic_parse_func_generic_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, num_generic_params: i32, is_main: i32): void;
export extern "C" function driver_diagnostic_parse_skip_function_impl(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
export extern "C" function driver_diagnostic_parser_onefunc_param_ref_impl(func_name: *u8, func_name_len: i32, param_name: *u8, param_name_len: i32, stage: i32, param_idx: i32, type_ref: i32): void;
export extern "C" function driver_diagnostic_typeck_binop_operands_impl(expr_ref: i32, left_ref: i32, right_ref: i32, left_kind: i32, right_kind: i32, left_block_ref: i32, right_block_ref: i32, left_ty_ref: i32, right_ty_ref: i32, left_ty: *u8, left_ty_len: i32, right_ty: *u8, right_ty_len: i32): void;
export extern "C" function driver_diagnostic_typeck_func_fail_impl(func_idx: i32, name: *u8, name_len: i32, kind: i32): void;
export extern "C" function driver_diagnostic_typeck_import_const_must_be_qualified_impl(line: i32, col: i32, name: *u8, name_len: i32, binding: *u8, binding_len: i32): void;
export extern "C" function driver_diagnostic_typeck_ptr_field_impl(bt_kind: i32, inner_kind: i32, inner_nlen: i32, base_resolved_ref: i32, num_struct_layouts: i32): void;
export extern "C" function driver_diagnostic_typeck_ret_fail_impl(stage: i32, op_expr_ref: i32, expect_ty_ref: i32, got_ty_ref: i32): void;
export extern "C" function driver_diagnostic_warn_hot_reorder_field_impl(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void;
export extern "C" function driver_diagnostic_warn_pad_fields_same_cache_line_impl(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void;
export extern "C" function parser_diagnostic_parse_commit_shape_impl(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void;

#[no_mangle]
export function driver_diagnostic_parse_fail(main_idx: i32, num_funcs: i32, arena_num_types: i32): void {
  unsafe {
    driver_diagnostic_parse_fail_impl(main_idx, num_funcs, arena_num_types);
  }
}


#[no_mangle]
export function driver_diagnostic_parse_skip_function(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void {
  unsafe {
    driver_diagnostic_parse_skip_function_impl(byte_pos, num_funcs_so_far, name_len, name);
  }
}


#[no_mangle]
export function driver_diagnostic_typeck_func_fail(func_idx: i32, name: *u8, name_len: i32, kind: i32): void {
  unsafe {
    driver_diagnostic_typeck_func_fail_impl(func_idx, name, name_len, kind);
  }
}


#[no_mangle]
export function driver_diagnostic_typeck_ptr_field(bt_kind: i32, inner_kind: i32, inner_nlen: i32, base_resolved_ref: i32, num_struct_layouts: i32): void {
  unsafe {
    driver_diagnostic_typeck_ptr_field_impl(bt_kind, inner_kind, inner_nlen, base_resolved_ref, num_struct_layouts);
  }
}


#[no_mangle]
export function driver_diagnostic_typeck_ret_fail(stage: i32, op_expr_ref: i32, expect_ty_ref: i32, got_ty_ref: i32): void {
  unsafe {
    driver_diagnostic_typeck_ret_fail_impl(stage, op_expr_ref, expect_ty_ref, got_ty_ref);
  }
}


#[no_mangle]
export function driver_diagnostic_typeck_binop_operands(expr_ref: i32, left_ref: i32, right_ref: i32, left_kind: i32, right_kind: i32, left_block_ref: i32, right_block_ref: i32, left_ty_ref: i32, right_ty_ref: i32, left_ty: *u8, left_ty_len: i32, right_ty: *u8, right_ty_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_binop_operands_impl(expr_ref, left_ref, right_ref, left_kind, right_kind, left_block_ref, right_block_ref, left_ty_ref, right_ty_ref, left_ty, left_ty_len, right_ty, right_ty_len);
  }
}


#[no_mangle]
export function driver_diagnostic_parser_onefunc_param_ref(func_name: *u8, func_name_len: i32, param_name: *u8, param_name_len: i32, stage: i32, param_idx: i32, type_ref: i32): void {
  unsafe {
    driver_diagnostic_parser_onefunc_param_ref_impl(func_name, func_name_len, param_name, param_name_len, stage, param_idx, type_ref);
  }
}


#[no_mangle]
export function driver_diagnostic_typeck_import_const_must_be_qualified(line: i32, col: i32, name: *u8, name_len: i32, binding: *u8, binding_len: i32): void {
  unsafe {
    driver_diagnostic_typeck_import_const_must_be_qualified_impl(line, col, name, name_len, binding, binding_len);
  }
}


// pure：typeck_block/fn/var debug 见下方（getenv 门闩 + append+note）；门闩已剔除。

#[no_mangle]
export function driver_diagnostic_parse_commit_fail(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void {
  unsafe {
    driver_diagnostic_parse_commit_fail_impl(byte_pos, num_funcs_so_far, name_len, name);
  }
}


#[no_mangle]
export function driver_diagnostic_parse_func_generic(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, num_generic_params: i32, is_main: i32): void {
  unsafe {
    driver_diagnostic_parse_func_generic_impl(byte_pos, num_funcs_so_far, name, name_len, num_generic_params, is_main);
  }
}


#[no_mangle]
export function driver_diagnostic_parse_commit_shape(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void {
  unsafe {
    driver_diagnostic_parse_commit_shape_impl(byte_pos, num_funcs_so_far, name, name_len, phase, block_ref, pool_num_consts, pool_num_lets, pool_num_ifs, pool_num_regions, pool_num_stmt_order, block_num_consts, block_num_lets, block_num_ifs, block_num_regions, block_num_stmt_order, final_expr_ref);
  }
}


#[no_mangle]
export function parser_diagnostic_parse_commit_shape(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32, phase: i32, block_ref: i32, pool_num_consts: i32, pool_num_lets: i32, pool_num_ifs: i32, pool_num_regions: i32, pool_num_stmt_order: i32, block_num_consts: i32, block_num_lets: i32, block_num_ifs: i32, block_num_regions: i32, block_num_stmt_order: i32, final_expr_ref: i32): void {
  unsafe {
    parser_diagnostic_parse_commit_shape_impl(byte_pos, num_funcs_so_far, name, name_len, phase, block_ref, pool_num_consts, pool_num_lets, pool_num_ifs, pool_num_regions, pool_num_stmt_order, block_num_consts, block_num_lets, block_num_ifs, block_num_regions, block_num_stmt_order, final_expr_ref);
  }
}


#[no_mangle]
export function driver_diagnostic_after_entry_parse_module(module: *u8): void {
  unsafe {
    driver_diagnostic_after_entry_parse_module_impl(module);
  }
}


#[no_mangle]
export function driver_diagnostic_codegen_fail(dep_index: i32, is_dep: i32): void {
  unsafe {
    driver_diagnostic_codegen_fail_impl(dep_index, is_dep);
  }
}


#[no_mangle]
export function driver_diagnostic_codegen_emit_func_fail(module: *u8, func_index: i32): void {
  unsafe {
    driver_diagnostic_codegen_emit_func_fail_impl(module, func_index);
  }
}


#[no_mangle]
export function driver_diagnostic_asm_print_current_func(): void {
  unsafe {
    driver_diagnostic_asm_print_current_func_impl();
  }
}


#[no_mangle]
export function driver_diagnostic_asm_var_not_found(name: *u8, len: i32, num_locals: i32, first_slot: *u8, first_len: i32): void {
  unsafe {
    driver_diagnostic_asm_var_not_found_impl(name, len, num_locals, first_slot, first_len);
  }
}


#[no_mangle]
export function driver_diagnostic_asm_fail_at(loc: i32): void {
  unsafe {
    driver_diagnostic_asm_fail_at_impl(loc);
  }
}


// pure：debug_log / parser_diag_* 见下方（parse debug + append+note）；门闩已剔除。

#[no_mangle]
export function driver_diagnostic_warn_pad_fields_same_cache_line(sname: *u8, sname_len: i32, f0: *u8, f0_len: i32, f1: *u8, f1_len: i32): void {
  unsafe {
    driver_diagnostic_warn_pad_fields_same_cache_line_impl(sname, sname_len, f0, f0_len, f1, f1_len);
  }
}


#[no_mangle]
export function driver_diagnostic_warn_hot_reorder_field(sname: *u8, sname_len: i32, hot: *u8, hot_len: i32, cold: *u8, cold_len: i32): void {
  unsafe {
    driver_diagnostic_warn_hot_reorder_field_impl(sname, sname_len, hot, hot_len, cold, cold_len);
  }
}


#[no_mangle]
export function driver_diagnostic_hint_unused_binding(line: i32, col: i32, name: *u8, name_len: i32): void {
  unsafe {
    driver_diagnostic_hint_unused_binding_impl(line, col, name, name_len);
  }
}

// ---- G-02f-340 pure full bodies ----
export extern "C" function driver_check_only_get(): i32;
export extern "C" function driver_check_diag_emitted_get(): i32;
// G-02f-409：storage / pipe shells → seed *_impl
export extern "C" function driver_diagnostic_asm_last_expr_kind_set_impl(k: i32): void;
export extern "C" function driver_diagnostic_asm_current_func_store_impl(name: *u8, len: i32): void;
export extern "C" function driver_diagnostic_asm_current_func_maybe_trace_impl(): void;

#[no_mangle]
export function driver_diagnostic_entry_already(v: i32): void {
}

#[no_mangle]
export function driver_diagnostic_after_dep_codegen(j: i32, out_len: i32): void {
}

#[no_mangle]
export function driver_diagnostic_typeck_fail(): void {
  unsafe {
    let _a: i32 = driver_check_only_get();
    let _b: i32 = driver_check_diag_emitted_get();
  }
}

#[no_mangle]
export function driver_diagnostic_asm_last_expr_kind_set(k: i32): void {
  unsafe {
    driver_diagnostic_asm_last_expr_kind_set_impl(k);
  }
}

#[no_mangle]
export function driver_diagnostic_asm_current_func_store(name: *u8, len: i32): void {
  unsafe {
    driver_diagnostic_asm_current_func_store_impl(name, len);
  }
}

#[no_mangle]
export function driver_diagnostic_asm_current_func_maybe_trace(): void {
  unsafe {
    driver_diagnostic_asm_current_func_maybe_trace_impl();
  }
}

#[no_mangle]
export function driver_diagnostic_asm_set_last_expr_kind(k: i32): void {
  unsafe {
    driver_diagnostic_asm_last_expr_kind_set_impl(k);
  }
}

#[no_mangle]
export function driver_diagnostic_asm_set_current_func(name: *u8, len: i32): void {
  unsafe {
    driver_diagnostic_asm_current_func_store_impl(name, len);
    driver_diagnostic_asm_current_func_maybe_trace_impl();
  }
}

#[no_mangle]
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

#[no_mangle]
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

#[no_mangle]
export function driver_diag_append_i32(dst: *u8, cap: i32, at: i32, val: i32): i32 {
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

// ---- Cap residual pure 深迁：固定措辞 typeck + pipe orch（真体；FROM_X 无 pure-dup _impl）----
export extern "C" function lsp_diag_report_typeck(line: i32, col: i32, msg: *u8): void;
// pure：SHUX_DEBUG_PIPE truthy（getenv 非空且 ≠'0'）；FROM_X 无 pure-dup _impl

#[no_mangle]
export function driver_diag_env_debug_pipe(): i32 {
  return driver_env_flag_truthy("SHUX_DEBUG_PIPE");
}

#[no_mangle]
export function driver_diagnostic_before_codegen(num_funcs: i32, out_len: i32): void {
  unsafe {
    if (driver_diag_env_debug_pipe() != 0) {
      driver_diag_pipe_note(0, num_funcs, out_len);
    }
  }
}

#[no_mangle]
export function driver_diagnostic_source_len(len: i32): void {
  unsafe {
    if (driver_diag_env_debug_pipe() != 0) {
      driver_diag_pipe_note(1, len, 0);
    }
  }
}

#[no_mangle]
export function driver_diagnostic_after_entry_parse(num_funcs: i32): void {
  unsafe {
    if (driver_diag_env_debug_pipe() != 0) {
      driver_diag_pipe_note(2, num_funcs, 0);
    }
  }
}

#[no_mangle]
export function driver_diagnostic_pipe_marker(id: i32): void {
  unsafe {
    if (driver_diag_env_debug_pipe() != 0) {
      driver_diag_pipe_note(3, id, 0);
    }
  }
}

#[no_mangle]
export function driver_diagnostic_typeck_if_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "if condition must be bool (no implicit int-to-bool)");
  }
}

#[no_mangle]
export function driver_diagnostic_typeck_while_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "while condition must be bool (no implicit int-to-bool)");
  }
}

#[no_mangle]
export function driver_diagnostic_typeck_for_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "for condition must be bool (no implicit int-to-bool)");
  }
}

#[no_mangle]
export function driver_diagnostic_typeck_deref_outside_unsafe(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "pointer dereference requires unsafe block");
  }
}

#[no_mangle]
export function driver_diagnostic_typeck_extern_call_outside_unsafe(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "extern call requires unsafe block");
  }
}

#[no_mangle]
export function driver_diagnostic_typeck_linear_addr_of(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "cannot take address of linear value");
  }
}

#[no_mangle]
export function driver_diagnostic_typeck_subscript_base(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "subscript base must be array, slice or pointer");
  }
}

#[no_mangle]
export function driver_diagnostic_typeck_enum_no_variant(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "enum has no variant");
  }
}

#[no_mangle]
export function driver_diagnostic_typeck_try_propagate_bad_enclosing(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col,
                           "`?` requires the enclosing function to return the same Result type");
  }
}

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

// ---- G-02f-341 pure helpers / remaining gates ----

#[no_mangle]
export function parser_is_ident_allow(ident: *u8, len: i32): i32 {
  if (ident == 0) { return 0; }
  if (len != 5) { return 0; }
  if (ident[0] == 97 && ident[1] == 108 && ident[2] == 108 && ident[3] == 111 && ident[4] == 119) {
    return 1;
  }
  return 0;
}

// ---- Cap residual pure 深迁：拼装 pure（return/assign/call/struct/asm note + fill/build）----
// 权威同构 full.x G-02f-175～179；append_* 已 pure；scratch expect/found 小 BSS 亦 pure
// pure：SHUX_PARSE_STRICT truthy + report_prefixed + pipe_note；FROM_X 无 pure-dup _impl
export extern "C" function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void;
export extern "C" function lsp_diag_add(line: i32, col: i32, severity: i32, msg: *u8): void;
export extern "C" function driver_check_diag_emitted_note(): void;

// pure：赋值诊断双缓冲（96B；与 seed 同宽；单线程流水线）
let g_type_diag_scratch_expect: u8[96] = [];
let g_type_diag_scratch_found: u8[96] = [];

#[no_mangle]
export function driver_parse_strict_enabled(): i32 {
  return driver_env_flag_truthy("SHUX_PARSE_STRICT");
}

// pure：拼装后走 diag_report note（无 va_list reportf）
#[no_mangle]
export function driver_diag_note(msg: *u8): void {
  unsafe {
    let m: *u8 = msg;
    if (m == 0) { m = ""; }
    diag_report(0 as *u8, 0, 0, "note", m, 0 as *u8);
  }
}

// pure：LSP 收集或 check-only 标记后 diag_report（同 full.x G-02f-163；无 snprintf）
#[no_mangle]
export function driver_diag_report_prefixed(line: i32, col: i32, msg: *u8): void {
  unsafe {
    if (lsp_diag_get_enabled() != 0) {
      let ln: i32 = line;
      let cl: i32 = col;
      if (ln <= 0) { ln = 1; }
      if (cl <= 0) { cl = 1; }
      let m: *u8 = msg;
      if (m == 0 as *u8) { m = ""; }
      lsp_diag_add(ln, cl, 1, m);
      return;
    }
    if (driver_check_only_get() != 0) {
      driver_check_diag_emitted_note();
    }
    let m2: *u8 = msg;
    if (m2 == 0 as *u8) { m2 = ""; }
    diag_report(0 as *u8, line, col, 0 as *u8, m2, m2);
  }
}

// pure：pipe debug note（append_cstr/i32 + note；无 va_list diag_reportf）
// kind：0=before_codegen 1=source_len 2=after_entry 3=pipe_marker
#[no_mangle]
export function driver_diag_pipe_note(kind: i32, a: i32, b: i32): void {
  let msg: u8[128] = [];
  if (kind == 0) {
    let at: i32 = driver_diag_append_cstr(&msg[0], 128, 0, "pipeline debug: before_codegen num_funcs=");
    at = driver_diag_append_i32(&msg[0], 128, at, a);
    at = driver_diag_append_cstr(&msg[0], 128, at, " out_len=");
    at = driver_diag_append_i32(&msg[0], 128, at, b);
    driver_diag_note(&msg[0]);
    return;
  }
  if (kind == 1) {
    let at1: i32 = driver_diag_append_cstr(&msg[0], 128, 0, "pipeline debug: entry_source_len=");
    at1 = driver_diag_append_i32(&msg[0], 128, at1, a);
    driver_diag_note(&msg[0]);
    return;
  }
  if (kind == 2) {
    let at2: i32 = driver_diag_append_cstr(&msg[0], 128, 0, "pipeline debug: after_entry_parse num_funcs=");
    at2 = driver_diag_append_i32(&msg[0], 128, at2, a);
    driver_diag_note(&msg[0]);
    return;
  }
  if (kind == 3) {
    let at3: i32 = driver_diag_append_cstr(&msg[0], 128, 0, "pipeline debug: pipe_marker=");
    at3 = driver_diag_append_i32(&msg[0], 128, at3, a);
    driver_diag_note(&msg[0]);
    return;
  }
}

// pure：与 seed Cap residual 同形 — getenv("SHUX_DEBUG_PARSE") 非空 或 parse_strict。
// （C：!getenv && !parse_strict → return；故 getenv 任意非 NULL 即启用，含 "0"。）
function driver_diag_parse_debug_enabled(): i32 {
  unsafe {
    if (getenv("SHUX_DEBUG_PARSE") != 0 as *u8) {
      return 1;
    }
  }
  return driver_parse_strict_enabled();
}

// pure：parse debug step note（append+note；无 va_list reportf）
#[no_mangle]
export function driver_debug_log(step: i32): void {
  if (driver_diag_parse_debug_enabled() == 0) {
    return;
  }
  let msg: u8[128] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 128, 0, "parse debug: step=");
  at = driver_diag_append_i32(&msg[0], 128, at, step);
  driver_diag_note(&msg[0]);
}

// pure：tok.kind note
#[no_mangle]
export function parser_diag_tok_kind(k: i32): void {
  if (driver_diag_parse_debug_enabled() == 0) {
    return;
  }
  let msg: u8[128] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 128, 0, "parse debug: r.tok.kind=");
  at = driver_diag_append_i32(&msg[0], 128, at, k);
  driver_diag_note(&msg[0]);
}

// pure：first ident_len note
#[no_mangle]
export function parser_diag_ident_len(len: i32): void {
  if (driver_diag_parse_debug_enabled() == 0) {
    return;
  }
  let msg: u8[128] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 128, 0, "parse debug: first ident_len=");
  at = driver_diag_append_i32(&msg[0], 128, at, len);
  driver_diag_note(&msg[0]);
}

// pure：library scan fail note
#[no_mangle]
export function parser_diag_scan_fail(step: i32): void {
  if (driver_diag_parse_debug_enabled() == 0) {
    return;
  }
  let msg: u8[128] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 128, 0, "library scan failed at step=");
  at = driver_diag_append_i32(&msg[0], 128, at, step);
  driver_diag_note(&msg[0]);
}

// pure：SHUX_TYPECK_BLOCK 非空 → block 计数 note（append+note，无 va_list）
#[no_mangle]
export function driver_diagnostic_typeck_block_enter(func_idx: i32, block_ref: i32, n_const: i32, n_let: i32, n_loop: i32, n_for: i32, n_expr: i32, final_ref: i32): void {
  unsafe {
    if (getenv("SHUX_TYPECK_BLOCK") == 0 as *u8) {
      return;
    }
  }
  let msg: u8[240] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 240, 0, "typeck block debug: func_idx=");
  at = driver_diag_append_i32(&msg[0], 240, at, func_idx);
  at = driver_diag_append_cstr(&msg[0], 240, at, " block_ref=");
  at = driver_diag_append_i32(&msg[0], 240, at, block_ref);
  at = driver_diag_append_cstr(&msg[0], 240, at, " const=");
  at = driver_diag_append_i32(&msg[0], 240, at, n_const);
  at = driver_diag_append_cstr(&msg[0], 240, at, " let=");
  at = driver_diag_append_i32(&msg[0], 240, at, n_let);
  at = driver_diag_append_cstr(&msg[0], 240, at, " while=");
  at = driver_diag_append_i32(&msg[0], 240, at, n_loop);
  at = driver_diag_append_cstr(&msg[0], 240, at, " for=");
  at = driver_diag_append_i32(&msg[0], 240, at, n_for);
  at = driver_diag_append_cstr(&msg[0], 240, at, " expr_stmt=");
  at = driver_diag_append_i32(&msg[0], 240, at, n_expr);
  at = driver_diag_append_cstr(&msg[0], 240, at, " final_expr=");
  at = driver_diag_append_i32(&msg[0], 240, at, final_ref);
  driver_diag_note(&msg[0]);
}

// pure：SHUX_TYPECK_FN 非空 → 函数入口 note
#[no_mangle]
export function driver_diagnostic_typeck_fn_enter(func_idx: i32, name: *u8, name_len: i32): void {
  unsafe {
    if (getenv("SHUX_TYPECK_FN") == 0 as *u8) {
      return;
    }
  }
  let msg: u8[160] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 160, 0, "typeck function debug: func_idx=");
  at = driver_diag_append_i32(&msg[0], 160, at, func_idx);
  at = driver_diag_append_cstr(&msg[0], 160, at, " name=");
  if (name != 0 as *u8 && name_len > 0) {
    at = driver_diag_append_name(&msg[0], 160, at, name, name_len);
  } else {
    at = driver_diag_append_cstr(&msg[0], 160, at, "(unknown)");
  }
  driver_diag_note(&msg[0]);
}

// pure：SHUX_TYPECK_VAR 非空 → VAR 解析来源 note
#[no_mangle]
export function driver_diagnostic_typeck_var_resolution(expr_ref: i32, name: *u8, name_len: i32, func_idx: i32, block_ref: i32, source: i32, type_ref: i32): void {
  unsafe {
    if (getenv("SHUX_TYPECK_VAR") == 0 as *u8) {
      return;
    }
  }
  let msg: u8[200] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 200, 0, "typeck var debug: expr=");
  at = driver_diag_append_i32(&msg[0], 200, at, expr_ref);
  at = driver_diag_append_cstr(&msg[0], 200, at, " name=");
  if (name != 0 as *u8 && name_len > 0) {
    at = driver_diag_append_name(&msg[0], 200, at, name, name_len);
  } else {
    at = driver_diag_append_cstr(&msg[0], 200, at, "?");
  }
  at = driver_diag_append_cstr(&msg[0], 200, at, " func=");
  at = driver_diag_append_i32(&msg[0], 200, at, func_idx);
  at = driver_diag_append_cstr(&msg[0], 200, at, " block=");
  at = driver_diag_append_i32(&msg[0], 200, at, block_ref);
  at = driver_diag_append_cstr(&msg[0], 200, at, " source=");
  at = driver_diag_append_i32(&msg[0], 200, at, source);
  at = driver_diag_append_cstr(&msg[0], 200, at, " type_ref=");
  at = driver_diag_append_i32(&msg[0], 200, at, type_ref);
  driver_diag_note(&msg[0]);
}

// pure：scratch BSS 指针（expect/found 各 96B）
#[no_mangle]
export function driver_typeck_diag_scratch_expect(): *u8 {
  return &g_type_diag_scratch_expect[0];
}

#[no_mangle]
export function driver_typeck_diag_scratch_found(): *u8 {
  return &g_type_diag_scratch_found[0];
}

// pure：fill expr 片段（? 回退；无 memcpy/snprintf）
#[no_mangle]
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
  dst[0] = 63;
  if (cap > 1) { dst[1] = 0; }
}

// pure：pref + epart + ", found " + fpart
#[no_mangle]
export function driver_diag_build_expected_found(msg: *u8, msg_cap: i32, pref: *u8, epart: *u8, fpart: *u8): void {
  let mid: *u8 = ", found ";
  let at: i32 = driver_diag_append_cstr(msg, msg_cap, 0, pref);
  at = driver_diag_append_cstr(msg, msg_cap, at, epart);
  at = driver_diag_append_cstr(msg, msg_cap, at, mid);
  at = driver_diag_append_cstr(msg, msg_cap, at, fpart);
}

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

#[no_mangle]
export function driver_diagnostic_asm_unsupported_expr(kind: i32): void {
  let msg: u8[96] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 96, 0, "asm codegen unsupported ExprKind=");
  at = driver_diag_append_i32(&msg[0], 96, at, kind);
  driver_diag_note(&msg[0]);
}

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

#[no_mangle]
export function driver_diagnostic_asm_macho_empty_reloc(reloc_idx: i32): void {
  let msg: u8[96] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 96, 0, "macho empty reloc symbol at idx=");
  at = driver_diag_append_i32(&msg[0], 96, at, reloc_idx);
  driver_diag_note(&msg[0]);
}

#[no_mangle]
export function driver_diagnostic_asm_macho_missing_und_reloc(reloc_idx: i32): void {
  let msg: u8[96] = [];
  let at: i32 = driver_diag_append_cstr(&msg[0], 96, 0, "macho undef reloc not in und pool at idx=");
  at = driver_diag_append_i32(&msg[0], 96, at, reloc_idx);
  driver_diag_note(&msg[0]);
}

// ---- G-02f-416：lsp_diag_enabled getter → seed impl ----
export extern "C" function lsp_diag_get_enabled_impl(): i32;

#[no_mangle]
export function lsp_diag_get_enabled(): i32 {
  unsafe {
    return lsp_diag_get_enabled_impl();
  }
  return 0;
}
