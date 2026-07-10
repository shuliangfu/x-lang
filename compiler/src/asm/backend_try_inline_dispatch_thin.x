// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-363/372：backend_try_inline_dispatch L2 thin — pure/forward 门闩（weak）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_TRY_INLINE_THIN_FROM_X）ld -r
//   → backend_try_inline_dispatch.o
//

extern "C" function pipeline_asm_index_elem_byte_sz(arena: *u8, index_expr_ref: i32): i32;
extern "C" function pipeline_expr_struct_lit_num_fields(arena: *u8, er: i32): i32;

#[no_mangle]
function glue_align_up8_c(n: i32): i32 {
  if ((n % 8) != 0) {
    return n + (8 - (n % 8));
  }
  return n;
}

#[no_mangle]
function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32 {
  if (ko == 51) {
    return 1;
  }
  if (ko < 4) {
    return 0;
  }
  if (ko > 13) {
    return 0;
  }
  return 1;
}

#[no_mangle]
function glue_const_scalar_binop_eval_i32(binop_ko: i32, a: i32, b: i32, out: *i32): i32 {
  if (out == 0 as *i32) {
    return 0;
  }
  if (binop_ko == 4) {
    unsafe {
      out[0] = a + b;
    }
    return 1;
  }
  if (binop_ko == 5) {
    unsafe {
      out[0] = a - b;
    }
    return 1;
  }
  if (binop_ko == 6) {
    unsafe {
      out[0] = a * b;
    }
    return 1;
  }
  if (binop_ko == 7) {
    if (b == 0) {
      return 0;
    }
    unsafe {
      out[0] = a / b;
    }
    return 1;
  }
  if (binop_ko == 8) {
    if (b == 0) {
      return 0;
    }
    unsafe {
      out[0] = a % b;
    }
    return 1;
  }
  return 0;
}

#[no_mangle]
function asm_index_elem_byte_sz(arena: *u8, index_expr_ref: i32): i32 {
  unsafe {
    return pipeline_asm_index_elem_byte_sz(arena, index_expr_ref);
  }
  return 0;
}

#[no_mangle]
function asm_struct_lit_reserve_stack_bytes(arena: *u8, init_ref: i32): i32 {
  if (arena == 0 as *u8) {
    return 0;
  }
  if (init_ref <= 0) {
    return 0;
  }
  unsafe {
    return pipeline_expr_struct_lit_num_fields(arena, init_ref) * 8;
  }
  return 0;
}

#[no_mangle]
function pipeline_asm_struct_lit_reserve_stack_bytes_c(arena: *u8, init_ref: i32): i32 {
  if (arena == 0 as *u8) {
    return 0;
  }
  if (init_ref <= 0) {
    return 0;
  }
  unsafe {
    return pipeline_expr_struct_lit_num_fields(arena, init_ref) * 8;
  }
  return 0;
}

// ---- G-02f-365：forward 壳（callee 仍 seed-rest）----
extern "C" function glue_enc_local_slot_ptr_or_addr(arena: *u8, elf_ctx: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32;
extern "C" function glue_arch_emit_local_slot_ptr_or_addr_text(arena: *u8, out: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32;
extern "C" function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, nlen: i32): i32;
extern "C" function asm_ctx_local_find_offset(ctx: *u8, name: *u8, nlen: i32): i32;
extern "C" function backend_fold_func_return_operand_ref(arena: *u8, mod: *u8, func_idx: i32): i32;
extern "C" function glue_fold_func_return_operand_ref_module(arena: *u8, mod: *u8, func_idx: i32): i32;

#[no_mangle]
function pipeline_asm_enc_local_slot_ptr_or_addr_elf_c(arena: *u8, elf_ctx: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  unsafe {
    return glue_enc_local_slot_ptr_or_addr(arena, elf_ctx, arg_ref, slot_off, ta, asm_ctx);
  }
  return 0;
}

#[no_mangle]
function pipeline_asm_arch_emit_local_slot_ptr_or_addr_text_c(arena: *u8, out: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  unsafe {
    return glue_arch_emit_local_slot_ptr_or_addr_text(arena, out, arg_ref, slot_off, ta, asm_ctx);
  }
  return 0;
}

#[no_mangle]
function glue_try_inline_local_slot_off(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    if (asm_ctx_local_find_offset_scoped(ctx, arena, name, name_len) >= 0) {
      return asm_ctx_local_find_offset_scoped(ctx, arena, name, name_len);
    }
    return asm_ctx_local_find_offset(ctx, name, name_len);
  }
  return 0 - 1;
}

#[no_mangle]
function glue_try_fold_func_return_operand_ref(arena: *u8, mod: *u8, func_idx: i32): i32 {
  unsafe {
    if (backend_fold_func_return_operand_ref(arena, mod, func_idx) > 0) {
      return backend_fold_func_return_operand_ref(arena, mod, func_idx);
    }
    return glue_fold_func_return_operand_ref_module(arena, mod, func_idx);
  }
  return 0;
}

// ---- G-02f-366：array lit forward + try_expr_const ----
extern "C" function asm_array_lit_elem_byte_sz(arena: *u8, array_lit_ref: i32): i32;
extern "C" function asm_array_lit_reserve_stack_bytes(arena: *u8, init_ref: i32): i32;

#[no_mangle]
function pipeline_asm_array_lit_elem_byte_sz_c(arena: *u8, array_lit_ref: i32): i32 {
  unsafe {
    return asm_array_lit_elem_byte_sz(arena, array_lit_ref);
  }
  return 4;
}

#[no_mangle]
function pipeline_asm_array_lit_reserve_stack_bytes_c(arena: *u8, init_ref: i32): i32 {
  unsafe {
    return asm_array_lit_reserve_stack_bytes(arena, init_ref);
  }
  return 0;
}

// ---- G-02f-368：local_slot 间接指针 + enc/arch 装址（无同文件 no_mangle 互调）----
extern "C" function glue_asm_ctx_module_ref_c(asm_ctx: *u8): *u8;
extern "C" function asm_local_var_slot_holds_indirect_ptr(arena: *u8, expr_ref: i32, mod_ref: *u8, asm_ctx: *u8): i32;
extern "C" function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, slot_off: i32, ta: i32): i32;
extern "C" function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, slot_off: i32, ta: i32): i32;
extern "C" function backend_arch_emit_load_rbp_to_rax(out: *u8, slot_off: i32, ta: i32): i32;
extern "C" function backend_arch_emit_lea_rbp_to_rax(out: *u8, slot_off: i32, ta: i32): i32;

#[no_mangle]
function glue_local_var_slot_holds_indirect_ptr(arena: *u8, expr_ref: i32, asm_ctx: *u8): i32 {
  unsafe {
    return asm_local_var_slot_holds_indirect_ptr(arena, expr_ref, glue_asm_ctx_module_ref_c(asm_ctx), asm_ctx);
  }
  return 0;
}

// ---- G-02f-369：6 参 local_slot + try_expr_const → seed impl ----
extern "C" function glue_try_expr_const_i32_impl(arena: *u8, expr_ref: i32, out: *i32): i32;



#[no_mangle]
function glue_try_expr_const_i32(arena: *u8, expr_ref: i32, out: *i32): i32 {
  unsafe {
    return glue_try_expr_const_i32_impl(arena, expr_ref, out);
  }
  return 0;
}

// ---- G-02f-370：module func index / named type layout → seed impl ----
extern "C" function glue_module_func_index_by_name_impl(mod: *u8, name: *u8, name_len: i32): i32;
extern "C" function glue_module_named_type_has_struct_layout_impl(mod: *u8, name: *u8, name_len: i32): i32;
extern "C" function glue_type_ref_is_named_struct_layout_impl(arena: *u8, mod: *u8, ty_ref: i32): i32;

#[no_mangle]
function glue_module_func_index_by_name(mod: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    return glue_module_func_index_by_name_impl(mod, name, name_len);
  }
  return 0 - 1;
}

#[no_mangle]
function glue_module_named_type_has_struct_layout(mod: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    return glue_module_named_type_has_struct_layout_impl(mod, name, name_len);
  }
  return 0;
}

#[no_mangle]
function glue_type_ref_is_named_struct_layout(arena: *u8, mod: *u8, ty_ref: i32): i32 {
  unsafe {
    return glue_type_ref_is_named_struct_layout_impl(arena, mod, ty_ref);
  }
  return 0;
}

// ---- G-02f-371：expr_is_func_param / struct_lit field index / array_lit lane → seed impl ----
extern "C" function glue_expr_is_func_param_at_impl(arena: *u8, mod: *u8, func_idx: i32, expr_ref: i32, param_ix: i32): i32;
extern "C" function glue_struct_lit_field_index_by_name_impl(arena: *u8, lit_ref: i32, fn: *u8, fnlen: i32): i32;
extern "C" function glue_try_array_lit_lane_const_i32_impl(arena: *u8, arr_ref: i32, lane: i32, out: *i32): i32;

#[no_mangle]
function glue_expr_is_func_param_at(arena: *u8, mod: *u8, func_idx: i32, expr_ref: i32, param_ix: i32): i32 {
  unsafe {
    return glue_expr_is_func_param_at_impl(arena, mod, func_idx, expr_ref, param_ix);
  }
  return 0;
}

#[no_mangle]
function glue_struct_lit_field_index_by_name(arena: *u8, lit_ref: i32, fn: *u8, fnlen: i32): i32 {
  unsafe {
    return glue_struct_lit_field_index_by_name_impl(arena, lit_ref, fn, fnlen);
  }
  return 0 - 1;
}

#[no_mangle]
function glue_try_array_lit_lane_const_i32(arena: *u8, arr_ref: i32, lane: i32, out: *i32): i32 {
  unsafe {
    return glue_try_array_lit_lane_const_i32_impl(arena, arr_ref, lane, out);
  }
  return 0;
}

// ---- G-02f-372：param0 index const / const struct field can_inline / scalar binop → seed impl ----
// Note: glue_fold_func_return_operand_ref_module stays seed-only (extern+no_mangle name clash mangles -E).
extern "C" function glue_fold_func_returns_param0_index_const_impl(arena: *u8, mod: *u8, func_idx: i32, out_lane: *i32): i32;
extern "C" function glue_const_struct_lit_field_can_inline_impl(arena: *u8, mod: *u8, func_idx: i32, lit_ref: i32, fj: i32): i32;
extern "C" function glue_fold_func_returns_param01_scalar_binop_impl(arena: *u8, mod: *u8, func_idx: i32, out_binop_ko: *i32): i32;

#[no_mangle]
function glue_fold_func_returns_param0_index_const(arena: *u8, mod: *u8, func_idx: i32, out_lane: *i32): i32 {
  unsafe {
    return glue_fold_func_returns_param0_index_const_impl(arena, mod, func_idx, out_lane);
  }
  return 0;
}

#[no_mangle]
function glue_const_struct_lit_field_can_inline(arena: *u8, mod: *u8, func_idx: i32, lit_ref: i32, fj: i32): i32 {
  unsafe {
    return glue_const_struct_lit_field_can_inline_impl(arena, mod, func_idx, lit_ref, fj);
  }
  return 0;
}

#[no_mangle]
function glue_fold_func_returns_param01_scalar_binop(arena: *u8, mod: *u8, func_idx: i32, out_binop_ko: *i32): i32 {
  unsafe {
    return glue_fold_func_returns_param01_scalar_binop_impl(arena, mod, func_idx, out_binop_ko);
  }
  return 0;
}
