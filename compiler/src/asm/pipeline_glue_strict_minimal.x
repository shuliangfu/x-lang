// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-11：pipeline_glue_strict_minimal 产品源迁 seeds/pipeline_glue_strict_minimal.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；B-strict 最小 glue 实现仍在 seed C。
// G-02f-107：+ named_equal / binding / param / field / assign_kind 薄门闩。

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
