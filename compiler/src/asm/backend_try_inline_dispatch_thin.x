// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-363/382：backend_try_inline_dispatch R2 thin full — pure/forward 公共门闩（50 公共面）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_TRY_INLINE_THIN_FROM_X）ld -r → backend_try_inline_dispatch.o
// Prove IDENTICAL：seeds/backend_try_inline_dispatch_thin_surface.from_x.c（本 thin 公共面；*_impl 仍 U）
// Cap residual：*_impl / try_inline_* C 尾 in full seed rest。
// 对照：src/asm/backend_try_inline_dispatch.x；冷启动 full seed rest。
//

export extern "C" function pipeline_asm_index_elem_byte_sz(arena: *u8, index_expr_ref: i32): i32;
export extern "C" function pipeline_expr_struct_lit_num_fields(arena: *u8, er: i32): i32;

#[no_mangle]
export function glue_align_up8_c(n: i32): i32 {
  if ((n % 8) != 0) {
    return n + (8 - (n % 8));
  }
  return n;
}

#[no_mangle]
export function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32 {
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
export function glue_const_scalar_binop_eval_i32(binop_ko: i32, a: i32, b: i32, out: *i32): i32 {
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
export function asm_index_elem_byte_sz(arena: *u8, index_expr_ref: i32): i32 {
  unsafe {
    return pipeline_asm_index_elem_byte_sz(arena, index_expr_ref);
  }
  return 0;
}

#[no_mangle]
export function asm_struct_lit_reserve_stack_bytes(arena: *u8, init_ref: i32): i32 {
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
export function pipeline_asm_struct_lit_reserve_stack_bytes_c(arena: *u8, init_ref: i32): i32 {
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
// G-02f-382：6 参 local_slot public thin → seed _impl（pipeline 壳同调 _impl）
export extern "C" function glue_enc_local_slot_ptr_or_addr_impl(arena: *u8, elf_ctx: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32;
export extern "C" function glue_arch_emit_local_slot_ptr_or_addr_text_impl(arena: *u8, out: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32;
export extern "C" function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, nlen: i32): i32;
export extern "C" function asm_ctx_local_find_offset(ctx: *u8, name: *u8, nlen: i32): i32;
export extern "C" function backend_fold_func_return_operand_ref(arena: *u8, mod: *u8, func_idx: i32): i32;
export extern "C" function glue_fold_func_return_operand_ref_module_impl(arena: *u8, mod: *u8, func_idx: i32): i32;

#[no_mangle]
export function glue_enc_local_slot_ptr_or_addr(arena: *u8, elf_ctx: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  unsafe {
    return glue_enc_local_slot_ptr_or_addr_impl(arena, elf_ctx, arg_ref, slot_off, ta, asm_ctx);
  }
  return 0;
}

#[no_mangle]
export function glue_arch_emit_local_slot_ptr_or_addr_text(arena: *u8, out: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  unsafe {
    return glue_arch_emit_local_slot_ptr_or_addr_text_impl(arena, out, arg_ref, slot_off, ta, asm_ctx);
  }
  return 0;
}

#[no_mangle]
export function pipeline_asm_enc_local_slot_ptr_or_addr_elf_c(arena: *u8, elf_ctx: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  unsafe {
    return glue_enc_local_slot_ptr_or_addr_impl(arena, elf_ctx, arg_ref, slot_off, ta, asm_ctx);
  }
  return 0;
}

#[no_mangle]
export function pipeline_asm_arch_emit_local_slot_ptr_or_addr_text_c(arena: *u8, out: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  unsafe {
    return glue_arch_emit_local_slot_ptr_or_addr_text_impl(arena, out, arg_ref, slot_off, ta, asm_ctx);
  }
  return 0;
}

#[no_mangle]
export function glue_try_inline_local_slot_off(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    if (asm_ctx_local_find_offset_scoped(ctx, arena, name, name_len) >= 0) {
      return asm_ctx_local_find_offset_scoped(ctx, arena, name, name_len);
    }
    return asm_ctx_local_find_offset(ctx, name, name_len);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_try_fold_func_return_operand_ref(arena: *u8, mod: *u8, func_idx: i32): i32 {
  unsafe {
    if (backend_fold_func_return_operand_ref(arena, mod, func_idx) > 0) {
      return backend_fold_func_return_operand_ref(arena, mod, func_idx);
    }
    return glue_fold_func_return_operand_ref_module_impl(arena, mod, func_idx);
  }
  return 0;
}

// ---- G-02f-366：array lit forward + try_expr_const ----
export extern "C" function asm_array_lit_elem_byte_sz_impl(arena: *u8, array_lit_ref: i32): i32;
export extern "C" function asm_array_lit_reserve_stack_bytes_impl(arena: *u8, init_ref: i32): i32;

#[no_mangle]
export function asm_array_lit_elem_byte_sz(arena: *u8, array_lit_ref: i32): i32 {
  unsafe {
    return asm_array_lit_elem_byte_sz_impl(arena, array_lit_ref);
  }
  return 4;
}

#[no_mangle]
export function asm_array_lit_reserve_stack_bytes(arena: *u8, init_ref: i32): i32 {
  unsafe {
    return asm_array_lit_reserve_stack_bytes_impl(arena, init_ref);
  }
  return 0;
}

#[no_mangle]
export function pipeline_asm_array_lit_elem_byte_sz_c(arena: *u8, array_lit_ref: i32): i32 {
  unsafe {
    return asm_array_lit_elem_byte_sz_impl(arena, array_lit_ref);
  }
  return 4;
}

#[no_mangle]
export function pipeline_asm_array_lit_reserve_stack_bytes_c(arena: *u8, init_ref: i32): i32 {
  unsafe {
    return asm_array_lit_reserve_stack_bytes_impl(arena, init_ref);
  }
  return 0;
}

// ---- G-02f-368：local_slot 间接指针 + enc/arch 装址（无同文件 no_mangle 互调）----
export extern "C" function glue_asm_ctx_module_ref_c_impl(asm_ctx: *u8): *u8;
export extern "C" function asm_local_var_slot_holds_indirect_ptr_impl(arena: *u8, expr_ref: i32, mod_ref: *u8, asm_ctx: *u8): i32;
export extern "C" function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, slot_off: i32, ta: i32): i32;
export extern "C" function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, slot_off: i32, ta: i32): i32;
export extern "C" function backend_arch_emit_load_rbp_to_rax(out: *u8, slot_off: i32, ta: i32): i32;
export extern "C" function backend_arch_emit_lea_rbp_to_rax(out: *u8, slot_off: i32, ta: i32): i32;

#[no_mangle]
export function glue_asm_ctx_module_ref_c(asm_ctx: *u8): *u8 {
  unsafe {
    return glue_asm_ctx_module_ref_c_impl(asm_ctx);
  }
  return 0 as *u8;
}

#[no_mangle]
export function glue_local_var_slot_holds_indirect_ptr(arena: *u8, expr_ref: i32, asm_ctx: *u8): i32 {
  unsafe {
    return asm_local_var_slot_holds_indirect_ptr_impl(arena, expr_ref, glue_asm_ctx_module_ref_c(asm_ctx), asm_ctx);
  }
  return 0;
}

// ---- G-02f-369：6 参 local_slot + try_expr_const → seed impl ----
export extern "C" function glue_try_expr_const_i32_impl(arena: *u8, expr_ref: i32, out: *i32): i32;



#[no_mangle]
export function glue_try_expr_const_i32(arena: *u8, expr_ref: i32, out: *i32): i32 {
  unsafe {
    return glue_try_expr_const_i32_impl(arena, expr_ref, out);
  }
  return 0;
}

// ---- G-02f-370：module func index / named type layout → seed impl ----
export extern "C" function glue_module_func_index_by_name_impl(mod: *u8, name: *u8, name_len: i32): i32;
export extern "C" function glue_module_named_type_has_struct_layout_impl(mod: *u8, name: *u8, name_len: i32): i32;
export extern "C" function glue_type_ref_is_named_struct_layout_impl(arena: *u8, mod: *u8, ty_ref: i32): i32;

#[no_mangle]
export function glue_module_func_index_by_name(mod: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    return glue_module_func_index_by_name_impl(mod, name, name_len);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_module_named_type_has_struct_layout(mod: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    return glue_module_named_type_has_struct_layout_impl(mod, name, name_len);
  }
  return 0;
}

#[no_mangle]
export function glue_type_ref_is_named_struct_layout(arena: *u8, mod: *u8, ty_ref: i32): i32 {
  unsafe {
    return glue_type_ref_is_named_struct_layout_impl(arena, mod, ty_ref);
  }
  return 0;
}

// ---- G-02f-371：expr_is_func_param / struct_lit field index / array_lit lane → seed impl ----
export extern "C" function glue_expr_is_func_param_at_impl(arena: *u8, mod: *u8, func_idx: i32, expr_ref: i32, param_ix: i32): i32;
export extern "C" function glue_struct_lit_field_index_by_name_impl(arena: *u8, lit_ref: i32, fn: *u8, fnlen: i32): i32;
export extern "C" function glue_try_array_lit_lane_const_i32_impl(arena: *u8, arr_ref: i32, lane: i32, out: *i32): i32;

#[no_mangle]
export function glue_expr_is_func_param_at(arena: *u8, mod: *u8, func_idx: i32, expr_ref: i32, param_ix: i32): i32 {
  unsafe {
    return glue_expr_is_func_param_at_impl(arena, mod, func_idx, expr_ref, param_ix);
  }
  return 0;
}

#[no_mangle]
export function glue_struct_lit_field_index_by_name(arena: *u8, lit_ref: i32, fn: *u8, fnlen: i32): i32 {
  unsafe {
    return glue_struct_lit_field_index_by_name_impl(arena, lit_ref, fn, fnlen);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_try_array_lit_lane_const_i32(arena: *u8, arr_ref: i32, lane: i32, out: *i32): i32 {
  unsafe {
    return glue_try_array_lit_lane_const_i32_impl(arena, arr_ref, lane, out);
  }
  return 0;
}

// ---- G-02f-372：param0 index const / const struct field can_inline / scalar binop → seed impl ----
// G-02f-381: fold_module / array_lit / local_var_slot public via _impl (no same-name extern clash).
export extern "C" function glue_fold_func_returns_param0_index_const_impl(arena: *u8, mod: *u8, func_idx: i32, out_lane: *i32): i32;
export extern "C" function glue_const_struct_lit_field_can_inline_impl(arena: *u8, mod: *u8, func_idx: i32, lit_ref: i32, fj: i32): i32;
export extern "C" function glue_fold_func_returns_param01_scalar_binop_impl(arena: *u8, mod: *u8, func_idx: i32, out_binop_ko: *i32): i32;

#[no_mangle]
export function glue_fold_func_returns_param0_index_const(arena: *u8, mod: *u8, func_idx: i32, out_lane: *i32): i32 {
  unsafe {
    return glue_fold_func_returns_param0_index_const_impl(arena, mod, func_idx, out_lane);
  }
  return 0;
}

#[no_mangle]
export function glue_const_struct_lit_field_can_inline(arena: *u8, mod: *u8, func_idx: i32, lit_ref: i32, fj: i32): i32 {
  unsafe {
    return glue_const_struct_lit_field_can_inline_impl(arena, mod, func_idx, lit_ref, fj);
  }
  return 0;
}

#[no_mangle]
export function glue_fold_func_returns_param01_scalar_binop(arena: *u8, mod: *u8, func_idx: i32, out_binop_ko: *i32): i32 {
  unsafe {
    return glue_fold_func_returns_param01_scalar_binop_impl(arena, mod, func_idx, out_binop_ko);
  }
  return 0;
}

// ---- G-02f-373：param_struct_lit / vector_binop / default_alloc → seed impl ----
export extern "C" function glue_fold_func_returns_param_struct_lit_impl(arena: *u8, mod: *u8, func_idx: i32, out_lit_ref: *i32): i32;
export extern "C" function glue_fold_func_returns_param01_vector_binop_impl(arena: *u8, mod: *u8, func_idx: i32, out_binop_ko: *i32): i32;
export extern "C" function glue_call_is_zero_arg_default_alloc_impl(arena: *u8, call_ref: i32): i32;

#[no_mangle]
export function glue_fold_func_returns_param_struct_lit(arena: *u8, mod: *u8, func_idx: i32, out_lit_ref: *i32): i32 {
  unsafe {
    return glue_fold_func_returns_param_struct_lit_impl(arena, mod, func_idx, out_lit_ref);
  }
  return 0;
}

#[no_mangle]
export function glue_fold_func_returns_param01_vector_binop(arena: *u8, mod: *u8, func_idx: i32, out_binop_ko: *i32): i32 {
  unsafe {
    return glue_fold_func_returns_param01_vector_binop_impl(arena, mod, func_idx, out_binop_ko);
  }
  return 0;
}

#[no_mangle]
export function glue_call_is_zero_arg_default_alloc(arena: *u8, call_ref: i32): i32 {
  unsafe {
    return glue_call_is_zero_arg_default_alloc_impl(arena, call_ref);
  }
  return 0;
}

// ---- G-02f-374：dep field offset / const struct lit fold / default_alloc emit → seed impl ----
export extern "C" function glue_dep_module_field_offset_by_name_impl(pctx: *u8, field_name: *u8, flen: i32): i32;
export extern "C" function glue_fold_func_returns_const_struct_lit_impl(arena: *u8, mod: *u8, func_idx: i32, out_lit_ref: *i32): i32;
export extern "C" function glue_emit_default_alloc_to_rbx_offset_impl(elf_ctx: *u8, foff: i32, fsz: i32, ta: i32): i32;

#[no_mangle]
export function glue_dep_module_field_offset_by_name(pctx: *u8, field_name: *u8, flen: i32): i32 {
  unsafe {
    return glue_dep_module_field_offset_by_name_impl(pctx, field_name, flen);
  }
  return 0 - 1;
}

#[no_mangle]
export function glue_fold_func_returns_const_struct_lit(arena: *u8, mod: *u8, func_idx: i32, out_lit_ref: *i32): i32 {
  unsafe {
    return glue_fold_func_returns_const_struct_lit_impl(arena, mod, func_idx, out_lit_ref);
  }
  return 0;
}

#[no_mangle]
export function glue_emit_default_alloc_to_rbx_offset(elf_ctx: *u8, foff: i32, fsz: i32, ta: i32): i32 {
  unsafe {
    return glue_emit_default_alloc_to_rbx_offset_impl(elf_ctx, foff, fsz, ta);
  }
  return 0 - 1;
}

// ---- G-02f-375：inner_call_arg / wpo scalar binop / x_plus_k → seed impl ----
export extern "C" function glue_inner_call_arg_for_field_access_impl(arena: *u8, ctx: *u8, inner_call_ref: i32, outer_field_ref: i32, out_arg_ref: *i32): i32;
export extern "C" function try_inline_wpo_const_scalar_binop_call_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function try_inline_x_plus_k_call_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;

#[no_mangle]
export function glue_inner_call_arg_for_field_access(arena: *u8, ctx: *u8, inner_call_ref: i32, outer_field_ref: i32, out_arg_ref: *i32): i32 {
  unsafe {
    return glue_inner_call_arg_for_field_access_impl(arena, ctx, inner_call_ref, outer_field_ref, out_arg_ref);
  }
  return 0;
}

#[no_mangle]
export function try_inline_wpo_const_scalar_binop_call_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return try_inline_wpo_const_scalar_binop_call_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return 0;
}

#[no_mangle]
export function try_inline_x_plus_k_call_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return try_inline_x_plus_k_call_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return 0;
}

// ---- G-02f-376：param0_single_field / wpo vector lane / wpo mono symbol → seed impl ----
export extern "C" function try_inline_param0_single_field_call_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function try_inline_wpo_const_vector_lane_of_binop_call_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function try_call_wpo_mono_symbol_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;

#[no_mangle]
export function try_inline_param0_single_field_call_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return try_inline_param0_single_field_call_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return 0;
}

#[no_mangle]
export function try_inline_wpo_const_vector_lane_of_binop_call_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return try_inline_wpo_const_vector_lane_of_binop_call_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return 0;
}

#[no_mangle]
export function try_call_wpo_mono_symbol_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return try_call_wpo_mono_symbol_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return 0;
}

// ---- G-02f-377：var_field_offset / param0_field_sum / mono vector_lane → seed impl ----
export extern "C" function glue_inline_var_field_access_offset_impl(arena: *u8, mod: *u8, pctx: *u8, asm_ctx: *u8, fa_ref: i32): i32;
export extern "C" function try_inline_param0_field_sum_call_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function try_call_wpo_mono_vector_lane_of_binop_call_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;

#[no_mangle]
export function glue_inline_var_field_access_offset(arena: *u8, mod: *u8, pctx: *u8, asm_ctx: *u8, fa_ref: i32): i32 {
  unsafe {
    return glue_inline_var_field_access_offset_impl(arena, mod, pctx, asm_ctx, fa_ref);
  }
  return 0 - 1;
}

#[no_mangle]
export function try_inline_param0_field_sum_call_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return try_inline_param0_field_sum_call_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return 0;
}

#[no_mangle]
export function try_call_wpo_mono_vector_lane_of_binop_call_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return try_call_wpo_mono_vector_lane_of_binop_call_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return 0;
}

// ---- G-02f-378：field_init_param_index / struct_lit_return_to_slot / const_struct_lit_to_slot → seed impl ----
export extern "C" function glue_struct_lit_field_init_param_index_impl(arena: *u8, mod: *u8, func_idx: i32, lit_ref: i32, field_j: i32, out_param_ix: *i32): i32;
export extern "C" function try_inline_struct_lit_return_call_to_slot_elf_impl(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern "C" function try_inline_const_struct_lit_return_call_to_slot_elf_impl(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;

#[no_mangle]
export function glue_struct_lit_field_init_param_index(arena: *u8, mod: *u8, func_idx: i32, lit_ref: i32, field_j: i32, out_param_ix: *i32): i32 {
  unsafe {
    return glue_struct_lit_field_init_param_index_impl(arena, mod, func_idx, lit_ref, field_j, out_param_ix);
  }
  return 0 - 1;
}

#[no_mangle]
export function try_inline_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32 {
  unsafe {
    return try_inline_struct_lit_return_call_to_slot_elf_impl(arena, elf_ctx, call_ref, ctx, ta, stack_slot_off);
  }
  return 0;
}

#[no_mangle]
export function try_inline_const_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32 {
  unsafe {
    return try_inline_const_struct_lit_return_call_to_slot_elf_impl(arena, elf_ctx, call_ref, ctx, ta, stack_slot_off);
  }
  return 0;
}

// ---- G-02f-379：lookup_callee + var_field_sum → seed impl（try int32 收口）----
export extern "C" function glue_call_lookup_callee_mod_fi_arena_impl(caller_arena: *u8, call_ref: i32, ctx: *u8, out_ca: *u8, out_cm: *u8, out_fi: *i32): i32;
export extern "C" function try_inline_var_field_sum_binop_elf_impl(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

#[no_mangle]
export function glue_call_lookup_callee_mod_fi_arena(caller_arena: *u8, call_ref: i32, ctx: *u8, out_ca: *u8, out_cm: *u8, out_fi: *i32): i32 {
  unsafe {
    return glue_call_lookup_callee_mod_fi_arena_impl(caller_arena, call_ref, ctx, out_ca, out_cm, out_fi);
  }
  return 0;
}

#[no_mangle]
export function try_inline_var_field_sum_binop_elf(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return try_inline_var_field_sum_binop_elf_impl(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
  return 0;
}

// ---- G-02f-381：fold_module / local_var_slot public thin shells ----
#[no_mangle]
export function glue_fold_func_return_operand_ref_module(arena: *u8, mod: *u8, func_idx: i32): i32 {
  unsafe {
    return glue_fold_func_return_operand_ref_module_impl(arena, mod, func_idx);
  }
  return 0;
}

#[no_mangle]
export function asm_local_var_slot_holds_indirect_ptr(arena: *u8, expr_ref: i32, mod_ref: *u8, asm_ctx: *u8): i32 {
  unsafe {
    return asm_local_var_slot_holds_indirect_ptr_impl(arena, expr_ref, mod_ref, asm_ctx);
  }
  return 0;
}
