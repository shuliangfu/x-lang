// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-9：backend_try_inline_dispatch 产品源迁 seeds/backend_try_inline_dispatch.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；分派实现仍在 seed C。
// 产品：cc seeds/backend_try_inline_dispatch.from_x.c → src/asm/backend_try_inline_dispatch.o

function backend_try_inline_dispatch_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-109：+ align/const fold/module lookup/param 薄门闩。

extern "C" function glue_align_up8_c_impl(n: i32): i32;
extern "C" function glue_module_func_index_by_name_impl(mod: *u8, name: *u8, nlen: i32): i32;
extern "C" function glue_try_expr_const_i32_impl(arena: *u8, er: i32, out: *i32): i32;
extern "C" function glue_const_scalar_binop_eval_i32_impl(ko: i32, a: i32, b: i32, out: *i32): i32;
extern "C" function glue_module_named_type_has_struct_layout_impl(mod: *u8, name: *u8, nlen: i32): i32;
extern "C" function glue_type_ref_is_named_struct_layout_impl(arena: *u8, mod: *u8, tr: i32): i32;
extern "C" function glue_local_var_slot_holds_indirect_ptr_impl(arena: *u8, er: i32, ctx: *u8): i32;
extern "C" function glue_expr_is_func_param_at_impl(arena: *u8, mod: *u8, fi: i32, er: i32, pix: i32): i32;
extern "C" function glue_fold_func_return_operand_ref_module_impl(arena: *u8, mod: *u8, fi: i32): i32;
extern "C" function glue_try_fold_func_return_operand_ref_impl(arena: *u8, mod: *u8, fi: i32): i32;
extern "C" function glue_try_inline_local_slot_off_impl(ctx: *u8, arena: *u8, name: *u8, nlen: i32): i32;

/* ---- G-02f-109：try_inline helpers 门闩 ---- */

#[no_mangle]
function glue_align_up8_c(n: i32): i32 { unsafe { return glue_align_up8_c_impl(n); } return 0; }
#[no_mangle]
function glue_module_func_index_by_name(mod: *u8, name: *u8, nlen: i32): i32 { unsafe { return glue_module_func_index_by_name_impl(mod, name, nlen); } return 0; }
#[no_mangle]
function glue_try_expr_const_i32(arena: *u8, er: i32, out: *i32): i32 { unsafe { return glue_try_expr_const_i32_impl(arena, er, out); } return 0; }
#[no_mangle]
function glue_const_scalar_binop_eval_i32(ko: i32, a: i32, b: i32, out: *i32): i32 { unsafe { return glue_const_scalar_binop_eval_i32_impl(ko, a, b, out); } return 0; }
#[no_mangle]
function glue_module_named_type_has_struct_layout(mod: *u8, name: *u8, nlen: i32): i32 { unsafe { return glue_module_named_type_has_struct_layout_impl(mod, name, nlen); } return 0; }
#[no_mangle]
function glue_type_ref_is_named_struct_layout(arena: *u8, mod: *u8, tr: i32): i32 { unsafe { return glue_type_ref_is_named_struct_layout_impl(arena, mod, tr); } return 0; }
#[no_mangle]
function glue_local_var_slot_holds_indirect_ptr(arena: *u8, er: i32, ctx: *u8): i32 { unsafe { return glue_local_var_slot_holds_indirect_ptr_impl(arena, er, ctx); } return 0; }
#[no_mangle]
function glue_expr_is_func_param_at(arena: *u8, mod: *u8, fi: i32, er: i32, pix: i32): i32 { unsafe { return glue_expr_is_func_param_at_impl(arena, mod, fi, er, pix); } return 0; }
#[no_mangle]
function glue_fold_func_return_operand_ref_module(arena: *u8, mod: *u8, fi: i32): i32 { unsafe { return glue_fold_func_return_operand_ref_module_impl(arena, mod, fi); } return 0; }
#[no_mangle]
function glue_try_fold_func_return_operand_ref(arena: *u8, mod: *u8, fi: i32): i32 { unsafe { return glue_try_fold_func_return_operand_ref_impl(arena, mod, fi); } return 0; }
#[no_mangle]
function glue_try_inline_local_slot_off(ctx: *u8, arena: *u8, name: *u8, nlen: i32): i32 { unsafe { return glue_try_inline_local_slot_off_impl(ctx, arena, name, nlen); } return 0; }
