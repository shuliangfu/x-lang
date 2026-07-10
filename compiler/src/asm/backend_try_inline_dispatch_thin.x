// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-363/366：backend_try_inline_dispatch L2 thin — pure/forward 门闩（weak）。
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

