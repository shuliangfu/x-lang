// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-8：simd_loop 产品源迁 seeds/simd_loop.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 入口；循环剥离实现仍在 seed C。
// 产品：cc seeds/simd_loop.from_x.c → src/asm/simd_loop.o
// G-02f-106：+ expr/index/array/cpu/lanes pure glue 薄门闩。
// G-02f-107：+ parse/peel/slot glue 薄门闩。

extern "C" function glue_expr_same_var_c_impl(arena: *u8, a_ref: i32, b_ref: i32): i32;
extern "C" function glue_index_uses_var_c_impl(arena: *u8, index_expr_ref: i32, i_var_ref: i32): i32;
extern "C" function glue_var_array_i32_size_c_impl(arena: *u8, var_ref: i32): i32;
extern "C" function glue_var_is_array_i32_n_c_impl(arena: *u8, var_ref: i32, n: i32): i32;
extern "C" function glue_simd_loop_cpu_features_c_impl(): u32;
extern "C" function glue_simd_loop_pick_lanes_c_impl(feats: u32, binop_ko: i32, lanes_out: *i32): i32;

function simd_loop_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-106：simd_loop pure glue 门闩 ---- */

#[no_mangle]
function glue_expr_same_var_c(arena: *u8, a_ref: i32, b_ref: i32): i32 {
  unsafe { return glue_expr_same_var_c_impl(arena, a_ref, b_ref); }
  return 0;
}

#[no_mangle]
function glue_index_uses_var_c(arena: *u8, index_expr_ref: i32, i_var_ref: i32): i32 {
  unsafe { return glue_index_uses_var_c_impl(arena, index_expr_ref, i_var_ref); }
  return 0;
}

#[no_mangle]
function glue_var_array_i32_size_c(arena: *u8, var_ref: i32): i32 {
  unsafe { return glue_var_array_i32_size_c_impl(arena, var_ref); }
  return 0;
}

#[no_mangle]
function glue_var_is_array_i32_n_c(arena: *u8, var_ref: i32, n: i32): i32 {
  unsafe { return glue_var_is_array_i32_n_c_impl(arena, var_ref, n); }
  return 0;
}

#[no_mangle]
function glue_simd_loop_cpu_features_c(): u32 {
  unsafe { return glue_simd_loop_cpu_features_c_impl(); }
  return 0;
}

#[no_mangle]
function glue_simd_loop_pick_lanes_c(feats: u32, binop_ko: i32, lanes_out: *i32): i32 {
  unsafe { return glue_simd_loop_pick_lanes_c_impl(feats, binop_ko, lanes_out); }
  return 0;
}

extern "C" function glue_block_let_init_lit_c_impl(arena: *u8, block_ref: i32, var_ref: i32, out_lit: *i32): i32;
extern "C" function glue_parse_i_plus_one_step_c_impl(arena: *u8, step_ref: i32, i_var_ref: i32): i32;
extern "C" function glue_parse_index_binop_assign_c_impl(arena: *u8, assign_ref: i32, i_var_ref: i32, out_a: *i32, out_b: *i32, out_op: *i32): i32;
extern "C" function glue_parse_i_lt_bound_c_impl(arena: *u8, block_ref: i32, cond_ref: i32, i_var_ref: i32, out_bound: *i32): i32;
extern "C" function glue_simd_local_var_stack_off_c_impl(arena: *u8, ctx: *u8, var_ref: i32): i32;
extern "C" function glue_simd_x86_cmp_rax_rbx_c_impl(elf_ctx: *u8): i32;
extern "C" function glue_var_array_size_c_impl(arena: *u8, var_ref: i32): i32;
extern "C" function glue_soa_f32_col_rbp_disp32_impl(off_col0: i32, start_idx: i32): i32;
extern "C" function glue_f32_slot_rbp_disp32_impl(slot_off: i32): i32;

/* ---- G-02f-107：simd_loop parse/slot glue 门闩 ---- */

#[no_mangle]
function glue_block_let_init_lit_c(arena: *u8, block_ref: i32, var_ref: i32, out_lit: *i32): i32 {
  unsafe { return glue_block_let_init_lit_c_impl(arena, block_ref, var_ref, out_lit); }
  return 0;
}

#[no_mangle]
function glue_parse_i_plus_one_step_c(arena: *u8, step_ref: i32, i_var_ref: i32): i32 {
  unsafe { return glue_parse_i_plus_one_step_c_impl(arena, step_ref, i_var_ref); }
  return 0;
}

#[no_mangle]
function glue_parse_index_binop_assign_c(arena: *u8, assign_ref: i32, i_var_ref: i32, out_a: *i32, out_b: *i32, out_op: *i32): i32 {
  unsafe { return glue_parse_index_binop_assign_c_impl(arena, assign_ref, i_var_ref, out_a, out_b, out_op); }
  return 0;
}

#[no_mangle]
function glue_parse_i_lt_bound_c(arena: *u8, block_ref: i32, cond_ref: i32, i_var_ref: i32, out_bound: *i32): i32 {
  unsafe { return glue_parse_i_lt_bound_c_impl(arena, block_ref, cond_ref, i_var_ref, out_bound); }
  return 0;
}

#[no_mangle]
function glue_simd_local_var_stack_off_c(arena: *u8, ctx: *u8, var_ref: i32): i32 {
  unsafe { return glue_simd_local_var_stack_off_c_impl(arena, ctx, var_ref); }
  return 0;
}

#[no_mangle]
function glue_simd_x86_cmp_rax_rbx_c(elf_ctx: *u8): i32 {
  unsafe { return glue_simd_x86_cmp_rax_rbx_c_impl(elf_ctx); }
  return 0;
}

#[no_mangle]
function glue_var_array_size_c(arena: *u8, var_ref: i32): i32 {
  unsafe { return glue_var_array_size_c_impl(arena, var_ref); }
  return 0;
}

#[no_mangle]
function glue_soa_f32_col_rbp_disp32(off_col0: i32, start_idx: i32): i32 {
  unsafe { return glue_soa_f32_col_rbp_disp32_impl(off_col0, start_idx); }
  return 0;
}

#[no_mangle]
function glue_f32_slot_rbp_disp32(slot_off: i32): i32 {
  unsafe { return glue_f32_slot_rbp_disp32_impl(slot_off); }
  return 0;
}

