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

extern "C" function glue_module_func_index_by_name_impl(mod: *u8, name: *u8, nlen: i32): i32;
extern "C" function glue_const_scalar_binop_eval_i32_impl(ko: i32, a: i32, b: i32, out: *i32): i32;
extern "C" function glue_module_named_type_has_struct_layout_impl(mod: *u8, name: *u8, nlen: i32): i32;
extern "C" function glue_type_ref_is_named_struct_layout_impl(arena: *u8, mod: *u8, tr: i32): i32;
extern "C" function glue_local_var_slot_holds_indirect_ptr_impl(arena: *u8, er: i32, ctx: *u8): i32;
extern "C" function glue_expr_is_func_param_at_impl(arena: *u8, mod: *u8, fi: i32, er: i32, pix: i32): i32;
extern "C" function glue_fold_func_return_operand_ref_module_impl(arena: *u8, mod: *u8, fi: i32): i32;
extern "C" function glue_try_fold_func_return_operand_ref_impl(arena: *u8, mod: *u8, fi: i32): i32;

/* ---- G-02f-109：try_inline helpers 门闩 ---- */

#[no_mangle]
function glue_module_func_index_by_name(mod: *u8, name: *u8, nlen: i32): i32 { unsafe { return glue_module_func_index_by_name_impl(mod, name, nlen); } return 0; }

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


// G-02f-110：+ fold/struct lit/field offset/vector binop 薄门闩。

extern "C" function glue_call_lookup_callee_mod_fi_arena_impl(arena: *u8, call: i32, ctx: *u8, out_mod: *u8): i32;
extern "C" function glue_fold_func_returns_param01_scalar_binop_impl(arena: *u8, mod: *u8, fi: i32, out: *i32): i32;
extern "C" function glue_enc_local_slot_ptr_or_addr_impl(arena: *u8, elf: *u8, arg: i32, a: i32, b: i32): i32;
extern "C" function glue_arch_emit_local_slot_ptr_or_addr_text_impl(arena: *u8, out: *u8, arg: i32, a: i32): i32;
extern "C" function glue_struct_lit_field_init_param_index_impl(arena: *u8, mod: *u8, fi: i32, lit: i32, a: i32): i32;
extern "C" function glue_fold_func_returns_param_struct_lit_impl(arena: *u8, mod: *u8, fi: i32, out: *i32): i32;
extern "C" function glue_struct_lit_field_index_by_name_impl(arena: *u8, lit: i32, name: *u8, nlen: i32): i32;
extern "C" function glue_inner_call_arg_for_field_access_impl(arena: *u8, er: i32): i32;
extern "C" function glue_dep_module_field_offset_by_name_impl(mod: *u8, name: *u8, nlen: i32): i32;
extern "C" function glue_inline_var_field_access_offset_impl(arena: *u8, er: i32): i32;
extern "C" function glue_try_array_lit_lane_const_i32_impl(arena: *u8, er: i32, lane: i32, out: *i32): i32;
extern "C" function glue_fold_func_returns_param01_vector_binop_impl(arena: *u8, mod: *u8, fi: i32, out: *i32): i32;
extern "C" function glue_fold_func_returns_param0_index_const_impl(arena: *u8, mod: *u8, fi: i32, out: *i32): i32;

/* ---- G-02f-110：try_inline fold/field 门闩 ---- */

#[no_mangle]
function glue_call_lookup_callee_mod_fi_arena(arena: *u8, call: i32, ctx: *u8, out_mod: *u8): i32 { unsafe { return glue_call_lookup_callee_mod_fi_arena_impl(arena, call, ctx, out_mod); } return 0; }
#[no_mangle]
function glue_fold_func_returns_param01_scalar_binop(arena: *u8, mod: *u8, fi: i32, out: *i32): i32 { unsafe { return glue_fold_func_returns_param01_scalar_binop_impl(arena, mod, fi, out); } return 0; }
#[no_mangle]
function glue_enc_local_slot_ptr_or_addr(arena: *u8, elf: *u8, arg: i32, a: i32, b: i32): i32 { unsafe { return glue_enc_local_slot_ptr_or_addr_impl(arena, elf, arg, a, b); } return 0; }
#[no_mangle]
function glue_arch_emit_local_slot_ptr_or_addr_text(arena: *u8, out: *u8, arg: i32, a: i32): i32 { unsafe { return glue_arch_emit_local_slot_ptr_or_addr_text_impl(arena, out, arg, a); } return 0; }
#[no_mangle]
function glue_struct_lit_field_init_param_index(arena: *u8, mod: *u8, fi: i32, lit: i32, a: i32): i32 { unsafe { return glue_struct_lit_field_init_param_index_impl(arena, mod, fi, lit, a); } return 0; }
#[no_mangle]
function glue_fold_func_returns_param_struct_lit(arena: *u8, mod: *u8, fi: i32, out: *i32): i32 { unsafe { return glue_fold_func_returns_param_struct_lit_impl(arena, mod, fi, out); } return 0; }
#[no_mangle]
function glue_struct_lit_field_index_by_name(arena: *u8, lit: i32, name: *u8, nlen: i32): i32 { unsafe { return glue_struct_lit_field_index_by_name_impl(arena, lit, name, nlen); } return 0; }
#[no_mangle]
function glue_inner_call_arg_for_field_access(arena: *u8, er: i32): i32 { unsafe { return glue_inner_call_arg_for_field_access_impl(arena, er); } return 0; }
#[no_mangle]
function glue_dep_module_field_offset_by_name(mod: *u8, name: *u8, nlen: i32): i32 { unsafe { return glue_dep_module_field_offset_by_name_impl(mod, name, nlen); } return 0; }
#[no_mangle]
function glue_inline_var_field_access_offset(arena: *u8, er: i32): i32 { unsafe { return glue_inline_var_field_access_offset_impl(arena, er); } return 0; }
#[no_mangle]
function glue_try_array_lit_lane_const_i32(arena: *u8, er: i32, lane: i32, out: *i32): i32 { unsafe { return glue_try_array_lit_lane_const_i32_impl(arena, er, lane, out); } return 0; }
#[no_mangle]
function glue_fold_func_returns_param01_vector_binop(arena: *u8, mod: *u8, fi: i32, out: *i32): i32 { unsafe { return glue_fold_func_returns_param01_vector_binop_impl(arena, mod, fi, out); } return 0; }
#[no_mangle]
function glue_fold_func_returns_param0_index_const(arena: *u8, mod: *u8, fi: i32, out: *i32): i32 { unsafe { return glue_fold_func_returns_param0_index_const_impl(arena, mod, fi, out); } return 0; }

// G-02f-111：+ default_alloc / const struct lit fold 薄门闩。

extern "C" function glue_call_is_zero_arg_default_alloc_impl(arena: *u8, er: i32): i32;
extern "C" function glue_const_struct_lit_field_can_inline_impl(arena: *u8, lit: i32, ix: i32): i32;
extern "C" function glue_emit_default_alloc_to_rbx_offset_impl(elf: *u8, off: i32): i32;
extern "C" function glue_fold_func_returns_const_struct_lit_impl(arena: *u8, mod: *u8, fi: i32, out: *i32): i32;

/* ---- G-02f-111：try_inline alloc/const-lit 门闩 ---- */

#[no_mangle]
function glue_call_is_zero_arg_default_alloc(arena: *u8, er: i32): i32 { unsafe { return glue_call_is_zero_arg_default_alloc_impl(arena, er); } return 0; }
#[no_mangle]
function glue_const_struct_lit_field_can_inline(arena: *u8, lit: i32, ix: i32): i32 { unsafe { return glue_const_struct_lit_field_can_inline_impl(arena, lit, ix); } return 0; }
#[no_mangle]
function glue_emit_default_alloc_to_rbx_offset(elf: *u8, off: i32): i32 { unsafe { return glue_emit_default_alloc_to_rbx_offset_impl(elf, off); } return 0; }
#[no_mangle]
function glue_fold_func_returns_const_struct_lit(arena: *u8, mod: *u8, fi: i32, out: *i32): i32 { unsafe { return glue_fold_func_returns_const_struct_lit_impl(arena, mod, fi, out); } return 0; }

// G-02f-113：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function glue_align_up8_c(n: i32): i32 {
  let m: i32 = n % 8;
  if (m != 0) {
    n = n + (8 - m);
  }
  return n;
}

#[no_mangle]
function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32 {
  if (ko == 51) {
    ko = 4;
  }
  if (ko < 4) {
    return 0;
  }
  if (ko > 13) {
    return 0;
  }
  return 1;
}

// G-02f-126：glue_try_expr_const_i32 真迁 .x

extern "C" function pipeline_expr_kind_ord_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_int_val_at(arena: *u8, er: i32): i32;

#[no_mangle]
function glue_try_expr_const_i32(arena: *u8, er: i32, out: *i32): i32 {
  if (arena == 0) { return 0; }
  if (er <= 0) { return 0; }
  if (out == 0) { return 0; }
  unsafe {
    let ko: i32 = pipeline_expr_kind_ord_at(arena, er);
    // EXPR_INT / related lit kinds 0 or 2 in pipeline ord
    if (ko == 0) {
      out[0] = pipeline_expr_int_val_at(arena, er);
      return 1;
    }
    if (ko == 2) {
      out[0] = pipeline_expr_int_val_at(arena, er);
      return 1;
    }
  }
  return 0;
}

// G-02f-127：glue_try_inline_local_slot_off 真迁 .x

extern "C" function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, nlen: i32): i32;
extern "C" function asm_ctx_local_find_offset(ctx: *u8, name: *u8, nlen: i32): i32;

#[no_mangle]
function glue_try_inline_local_slot_off(ctx: *u8, arena: *u8, name: *u8, nlen: i32): i32 {
  unsafe {
    let off: i32 = asm_ctx_local_find_offset_scoped(ctx, arena, name, nlen);
    if (off < 0) {
      off = asm_ctx_local_find_offset(ctx, name, nlen);
    }
    return off;
  }
  return 0 - 1;
}

