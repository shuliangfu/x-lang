// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-11：pipeline_glue_strict_minimal 产品源迁 seeds/pipeline_glue_strict_minimal.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；B-strict 最小 glue 实现仍在 seed C。
// G-02f-107：+ named_equal / binding / param / field / assign_kind 薄门闩。
// G-02f-108：+ unqual/find/map/slice/ancestor/const_name 薄门闩。

extern "C" function pipeline_typeck_named_equal_strict_minimal_impl(a: *u8, alen: i32, b: *u8, blen: i32): i32;
extern "C" function pipeline_typeck_import_binding_name_equal_strict_minimal_impl(a: *u8, alen: i32, b: *u8, blen: i32): i32;
extern "C" function pipeline_expr_is_func_param_at_strict_minimal_impl(arena: *u8, mod: *u8, fi: i32, er: i32, pix: i32): i32;
extern "C" function field_name_equal_strict_minimal_impl(buf: *u8, len: i32, lit: *u8): i32;
extern "C" function pipeline_typeck_expr_is_any_assign_kind_strict_minimal_impl(kind: i32): i32;

function pipeline_glue_strict_minimal_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-107：strict minimal typeck helpers 门闩 ---- */

#[no_mangle]
function pipeline_typeck_named_equal_strict_minimal(a: *u8, alen: i32, b: *u8, blen: i32): i32 {
  unsafe { return pipeline_typeck_named_equal_strict_minimal_impl(a, alen, b, blen); }
  return 0;
}

#[no_mangle]
function pipeline_typeck_import_binding_name_equal_strict_minimal(a: *u8, alen: i32, b: *u8, blen: i32): i32 {
  unsafe { return pipeline_typeck_import_binding_name_equal_strict_minimal_impl(a, alen, b, blen); }
  return 0;
}

#[no_mangle]
function pipeline_expr_is_func_param_at_strict_minimal(arena: *u8, mod: *u8, fi: i32, er: i32, pix: i32): i32 {
  unsafe { return pipeline_expr_is_func_param_at_strict_minimal_impl(arena, mod, fi, er, pix); }
  return 0;
}

#[no_mangle]
function field_name_equal_strict_minimal(buf: *u8, len: i32, lit: *u8): i32 {
  unsafe { return field_name_equal_strict_minimal_impl(buf, len, lit); }
  return 0;
}

#[no_mangle]
function pipeline_typeck_expr_is_any_assign_kind_strict_minimal(kind: i32): i32 {
  unsafe { return pipeline_typeck_expr_is_any_assign_kind_strict_minimal_impl(kind); }
  return 0;
}

extern "C" function pipeline_typeck_named_unqual_offset_strict_minimal_impl(buf: *u8, len: i32): i32;
extern "C" function pipeline_typeck_find_func_index_in_module_by_name_strict_minimal_impl(mod: *u8, name: *u8, nlen: i32, arity: i32): i32;
extern "C" function pipeline_typeck_find_func_return_type_in_module_by_name_strict_minimal_impl(mod: *u8, arena: *u8, name: *u8, nlen: i32, a: i32, b: i32, c: *u8, d: *u8): i32;
extern "C" function pipeline_typeck_map_import_binding_named_to_caller_strict_minimal_impl(mod: *u8, dep: i32, arena: *u8, nm: *u8, nlen: i32): i32;
extern "C" function pipeline_typeck_linear_name_already_moved_strict_minimal_impl(name: *u8, nlen: i32): i32;
extern "C" function pipeline_typeck_slice_region_conflict_strict_minimal_impl(arena: *u8, a: i32, b: i32): i32;
extern "C" function pipeline_typeck_slice_region_escape_strict_minimal_impl(arena: *u8, a: i32, b: i32): i32;
extern "C" function pipeline_typeck_expr_diag_line_col_strict_minimal_impl(arena: *u8, er: i32, line: *i32, col: *i32): void;
extern "C" function typeck_block_is_strict_ancestor_strict_minimal_impl(arena: *u8, a: i32, b: i32): i32;
extern "C" function typeck_expr_lval_root_var_strict_minimal_impl(arena: *u8, er: i32, out: *u8, olen: *i32): i32;
extern "C" function typeck_name_is_block_local_strict_minimal_impl(mod: *u8, arena: *u8, ctx: *u8, name: *u8): i32;
extern "C" function typeck_expr_is_addr_of_block_local_strict_minimal_impl(mod: *u8, arena: *u8, ctx: *u8, er: i32): i32;
extern "C" function pipeline_typeck_const_name_matches_strict_minimal_impl(name: *u8, nlen: i32, lit: *u8): i32;

/* ---- G-02f-108：strict minimal more typeck helpers 门闩 ---- */

#[no_mangle]
function pipeline_typeck_named_unqual_offset_strict_minimal(buf: *u8, len: i32): i32 {
  unsafe { return pipeline_typeck_named_unqual_offset_strict_minimal_impl(buf, len); }
  return 0;
}

#[no_mangle]
function pipeline_typeck_find_func_index_in_module_by_name_strict_minimal(mod: *u8, name: *u8, nlen: i32, arity: i32): i32 {
  unsafe { return pipeline_typeck_find_func_index_in_module_by_name_strict_minimal_impl(mod, name, nlen, arity); }
  return 0;
}

#[no_mangle]
function pipeline_typeck_find_func_return_type_in_module_by_name_strict_minimal(mod: *u8, arena: *u8, name: *u8, nlen: i32, a: i32, b: i32, c: *u8, d: *u8): i32 {
  unsafe { return pipeline_typeck_find_func_return_type_in_module_by_name_strict_minimal_impl(mod, arena, name, nlen, a, b, c, d); }
  return 0;
}

#[no_mangle]
function pipeline_typeck_map_import_binding_named_to_caller_strict_minimal(mod: *u8, dep: i32, arena: *u8, nm: *u8, nlen: i32): i32 {
  unsafe { return pipeline_typeck_map_import_binding_named_to_caller_strict_minimal_impl(mod, dep, arena, nm, nlen); }
  return 0;
}

#[no_mangle]
function pipeline_typeck_linear_name_already_moved_strict_minimal(name: *u8, nlen: i32): i32 {
  unsafe { return pipeline_typeck_linear_name_already_moved_strict_minimal_impl(name, nlen); }
  return 0;
}

#[no_mangle]
function pipeline_typeck_slice_region_conflict_strict_minimal(arena: *u8, a: i32, b: i32): i32 {
  unsafe { return pipeline_typeck_slice_region_conflict_strict_minimal_impl(arena, a, b); }
  return 0;
}

#[no_mangle]
function pipeline_typeck_slice_region_escape_strict_minimal(arena: *u8, a: i32, b: i32): i32 {
  unsafe { return pipeline_typeck_slice_region_escape_strict_minimal_impl(arena, a, b); }
  return 0;
}

#[no_mangle]
function pipeline_typeck_expr_diag_line_col_strict_minimal(arena: *u8, er: i32, line: *i32, col: *i32): void {
  unsafe { pipeline_typeck_expr_diag_line_col_strict_minimal_impl(arena, er, line, col); }
}

#[no_mangle]
function typeck_block_is_strict_ancestor_strict_minimal(arena: *u8, a: i32, b: i32): i32 {
  unsafe { return typeck_block_is_strict_ancestor_strict_minimal_impl(arena, a, b); }
  return 0;
}

#[no_mangle]
function typeck_expr_lval_root_var_strict_minimal(arena: *u8, er: i32, out: *u8, olen: *i32): i32 {
  unsafe { return typeck_expr_lval_root_var_strict_minimal_impl(arena, er, out, olen); }
  return 0;
}

#[no_mangle]
function typeck_name_is_block_local_strict_minimal(mod: *u8, arena: *u8, ctx: *u8, name: *u8): i32 {
  unsafe { return typeck_name_is_block_local_strict_minimal_impl(mod, arena, ctx, name); }
  return 0;
}

#[no_mangle]
function typeck_expr_is_addr_of_block_local_strict_minimal(mod: *u8, arena: *u8, ctx: *u8, er: i32): i32 {
  unsafe { return typeck_expr_is_addr_of_block_local_strict_minimal_impl(mod, arena, ctx, er); }
  return 0;
}

#[no_mangle]
function pipeline_typeck_const_name_matches_strict_minimal(name: *u8, nlen: i32, lit: *u8): i32 {
  unsafe { return pipeline_typeck_const_name_matches_strict_minimal_impl(name, nlen, lit); }
  return 0;
}
