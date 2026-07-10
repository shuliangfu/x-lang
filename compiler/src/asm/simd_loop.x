// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-8：simd_loop 产品源迁 seeds/simd_loop.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 入口；循环剥离实现仍在 seed C。
// 产品：cc seeds/simd_loop.from_x.c → src/asm/simd_loop.o
// G-02f-106：+ expr/index/array/cpu/lanes pure glue 薄门闩。
// G-02f-107：+ parse/peel/slot glue 薄门闩。
// G-02f-213：try_simd_peel f32_soa_sum / index_add while 真迁 .x。

extern "C" function glue_simd_loop_pick_lanes_c_impl(feats: u32, binop_ko: i32, lanes_out: *i32): i32;
extern "C" function driver_get_pending_target_cpu_features(): u32;
extern "C" function shu_target_cpu_detect_host(): u32;
extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
extern "C" function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
extern "C" function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
extern "C" function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
extern "C" function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;

function simd_loop_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-106 / G-02f-129：simd_loop pure glue 真迁 ---- */

// G-02f-129：两 EXPR_VAR 是否同名（GLUE_EXPR_VAR=3）
#[no_mangle]
function glue_expr_same_var_c(arena: *u8, a_ref: i32, b_ref: i32): i32 {
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, a_ref) != 3) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, b_ref) != 3) { return 0; }
    let alen: i32 = pipeline_expr_var_name_len(arena, a_ref);
    let blen: i32 = pipeline_expr_var_name_len(arena, b_ref);
    if (alen <= 0) { return 0; }
    if (alen != blen) { return 0; }
    if (alen > 63) { return 0; }
    let an: u8[64] = [];
    let bn: u8[64] = [];
    pipeline_expr_var_name_into(arena, a_ref, &an[0]);
    pipeline_expr_var_name_into(arena, b_ref, &bn[0]);
    let k: i32 = 0;
    while (k < alen) {
      if (an[k] != bn[k]) { return 0; }
      k = k + 1;
    }
    return 1;
  }
  return 0;
}

// G-02f-128：glue_index_uses_var_c 真迁 .x（GLUE_EXPR_INDEX=47）
#[no_mangle]
function glue_index_uses_var_c(arena: *u8, index_expr_ref: i32, i_var_ref: i32): i32 {
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, index_expr_ref) != 47) { return 0; }
    let idx_ref: i32 = pipeline_expr_index_index_ref(arena, index_expr_ref);
    return glue_expr_same_var_c(arena, idx_ref, i_var_ref);
  }
  return 0;
}

// G-02f-129：VAR 的 i32[N] 定长数组元素个数（GLUE_TYPE_ARRAY=10, GLUE_TYPE_I32=0）
#[no_mangle]
function glue_var_array_i32_size_c(arena: *u8, var_ref: i32): i32 {
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, var_ref) != 3) { return 0; }
    let tr: i32 = pipeline_expr_resolved_type_ref(arena, var_ref);
    if (tr <= 0) { return 0; }
    if (pipeline_type_kind_ord_at(arena, tr) != 10) { return 0; }
    let asz: i32 = pipeline_type_array_size_at(arena, tr);
    if (asz <= 0) { return 0; }
    if (asz > 256) { return 0; }
    let elem: i32 = pipeline_type_elem_ref_at(arena, tr);
    if (elem <= 0) { return 0; }
    if (pipeline_type_kind_ord_at(arena, elem) != 0) { return 0; }
    return asz;
  }
  return 0;
}



#[no_mangle]
// G-02f-133：pending features，否则 host detect
#[no_mangle]
function glue_simd_loop_cpu_features_c(): u32 {
  unsafe {
    let feats: u32 = driver_get_pending_target_cpu_features();
    if (feats != 0) { return feats; }
    return shu_target_cpu_detect_host();
  }
  return 0;
}



/* ---- G-02f-213：full-arity seed helpers (product C) + peel true-port ---- */

extern "C" function glue_block_let_init_lit_c(arena: *u8, block_ref: i32, var_ref: i32, out_lit: *i32): i32;
extern "C" function glue_parse_i_plus_one_step_c(arena: *u8, step_ref: i32, i_var_ref: i32): i32;
extern "C" function glue_parse_index_binop_assign_c(arena: *u8, assign_ref: i32, i_var_ref: i32, binop_ko: *i32, dst_base: *i32, a_base: *i32, b_base: *i32): i32;
extern "C" function glue_parse_i_lt_bound_c(arena: *u8, block_ref: i32, cond_ref: i32, i_var_ref: *i32, n_lit: *i32, n_is_const: *i32, n_var_ref: *i32): i32;
extern "C" function glue_simd_local_var_stack_off_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
extern "C" function glue_emit_full_const_peel_c(elf_ctx: *u8, binop_ko: i32, off_a: i32, off_b: i32, off_d: i32, n_lit: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;
extern "C" function glue_emit_runtime_strip_loop_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, assign_body_ref: i32, binop_ko: i32, off_i: i32, off_n: i32, off_a: i32, off_b: i32, off_d: i32, array_n: i32, lanes: i32, feats: u32): i32;
extern "C" function glue_parse_f32_soa_sum_assign_c(arena: *u8, assign_ref: i32, i_var_ref: i32, sum_ref: *i32, arr_ref: *i32, fa_ref: *i32): i32;
extern "C" function glue_emit_f32_soa_sum_strip_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, assign_body_ref: i32, off_col0: i32, off_s: i32, off_i: i32, off_n: i32, n_lit: i32, lanes: i32, feats: u32): i32;
extern "C" function ast_ast_block_while_cond_ref(arena: *u8, block_ref: i32, loop_idx: i32): i32;
extern "C" function ast_ast_block_while_body_ref(arena: *u8, block_ref: i32, loop_idx: i32): i32;
extern "C" function ast_ast_block_num_expr_stmts(arena: *u8, body: i32): i32;
extern "C" function ast_ast_block_expr_stmt_ref(arena: *u8, body: i32, ei: i32): i32;
extern "C" function pipeline_expr_field_access_offset(arena: *u8, expr_ref: i32): i32;
extern "C" function getenv(name: *u8): *u8;

// getenv SHUX_SIMD_HW disable: name bytes
// S H U X _ S I M D _ H W \0
// 83 72 85 88 95 83 73 77 68 95 72 87

function glue_simd_hw_env_disabled(): i32 {
  unsafe {
    let name: u8[16] = [];
    name[0] = 83; name[1] = 72; name[2] = 85; name[3] = 88;
    name[4] = 95; name[5] = 83; name[6] = 73; name[7] = 77;
    name[8] = 68; name[9] = 95; name[10] = 72; name[11] = 87;
    name[12] = 0;
    let p: *u8 = getenv(&name[0]);
    if (p == 0) { return 0; }
    if (p[0] == 48) { return 1; } // '0'
  }
  return 0;
}

// G-02f-213：f32 SoA sum while peel 入口
#[no_mangle]
function glue_try_simd_peel_f32_soa_sum_while_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, loop_idx: i32, ctx: *u8, ta: i32): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (block_ref <= 0) { return 0; }
  if (glue_simd_hw_env_disabled() != 0) { return 0; }
  unsafe {
    let cond_ref: i32 = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
    let body_ref: i32 = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
    if (cond_ref <= 0) { return 0; }
    if (body_ref <= 0) { return 0; }
    let i_var_ref: i32 = 0;
    let n_lit: i32 = 0;
    let n_is_const: i32 = 0;
    let n_var_ref: i32 = 0;
    if (glue_parse_i_lt_bound_c(arena, block_ref, cond_ref, &i_var_ref, &n_lit, &n_is_const, &n_var_ref) == 0) {
      return 0;
    }
    if (ast_ast_block_num_expr_stmts(arena, body_ref) != 2) { return 0; }
    let assign_body_ref: i32 = ast_ast_block_expr_stmt_ref(arena, body_ref, 0);
    let assign_step_ref: i32 = ast_ast_block_expr_stmt_ref(arena, body_ref, 1);
    if (assign_body_ref <= 0) { return 0; }
    if (assign_step_ref <= 0) { return 0; }
    let sum_ref: i32 = 0;
    let arr_ref: i32 = 0;
    let fa_ref: i32 = 0;
    if (glue_parse_f32_soa_sum_assign_c(arena, assign_body_ref, i_var_ref, &sum_ref, &arr_ref, &fa_ref) == 0) {
      return 0;
    }
    if (glue_parse_i_plus_one_step_c(arena, assign_step_ref, i_var_ref) == 0) { return 0; }
    let array_n: i32 = glue_var_array_size_c(arena, arr_ref);
    if (n_is_const != 0) {
      if (n_lit <= 0) { return 0; }
      if (array_n > 0) {
        if (n_lit > array_n) { return 0; }
      }
    } else {
      if (n_var_ref <= 0) { return 0; }
    }
    let off_col0: i32 = glue_simd_local_var_stack_off_c(arena, ctx, arr_ref);
    let col_base: i32 = pipeline_expr_field_access_offset(arena, fa_ref);
    if (col_base > 0) { off_col0 = off_col0 - col_base; }
    let off_s: i32 = glue_simd_local_var_stack_off_c(arena, ctx, sum_ref);
    let off_i: i32 = glue_simd_local_var_stack_off_c(arena, ctx, i_var_ref);
    if (off_col0 < 0) { return 0; }
    if (off_s < 0) { return 0; }
    if (off_i < 0) { return 0; }
    let feats: u32 = glue_simd_loop_cpu_features_c();
    let lanes: i32 = 4;
    // SSE2 = 1
    if ((feats & 1) == 0) { return 0; }
    let off_n: i32 = 0 - 1;
    if (n_var_ref > 0) {
      off_n = glue_simd_local_var_stack_off_c(arena, ctx, n_var_ref);
    }
    if (n_is_const == 0) {
      if (off_n < 0) { return 0; }
    }
    return glue_emit_f32_soa_sum_strip_c(arena, elf_ctx, ctx, ta, assign_body_ref, off_col0, off_s, off_i, off_n, n_lit, lanes, feats);
  }
  return 0;
}

// G-02f-213：index binop while peel 入口
#[no_mangle]
function glue_try_simd_peel_index_add_while_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, loop_idx: i32, ctx: *u8, ta: i32): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (block_ref <= 0) { return 0; }
  if (glue_simd_hw_env_disabled() != 0) { return 0; }
  unsafe {
    let cond_ref: i32 = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
    let body_ref: i32 = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
    if (cond_ref <= 0) { return 0; }
    if (body_ref <= 0) { return 0; }
    let i_var_ref: i32 = 0;
    let n_lit: i32 = 0;
    let n_is_const: i32 = 0;
    let n_var_ref: i32 = 0;
    if (glue_parse_i_lt_bound_c(arena, block_ref, cond_ref, &i_var_ref, &n_lit, &n_is_const, &n_var_ref) == 0) {
      return 0;
    }
    let nes: i32 = ast_ast_block_num_expr_stmts(arena, body_ref);
    if (nes != 2) { return 0; }
    let assign_body_ref: i32 = ast_ast_block_expr_stmt_ref(arena, body_ref, 0);
    let assign_step_ref: i32 = ast_ast_block_expr_stmt_ref(arena, body_ref, 1);
    if (assign_body_ref <= 0) { return 0; }
    if (assign_step_ref <= 0) { return 0; }
    let binop_ko: i32 = 0;
    let dst_base: i32 = 0;
    let a_base: i32 = 0;
    let b_base: i32 = 0;
    if (glue_parse_index_binop_assign_c(arena, assign_body_ref, i_var_ref, &binop_ko, &dst_base, &a_base, &b_base) == 0) {
      return 0;
    }
    if (glue_parse_i_plus_one_step_c(arena, assign_step_ref, i_var_ref) == 0) { return 0; }
    let array_n: i32 = glue_var_array_i32_size_c(arena, dst_base);
    if (array_n <= 0) { return 0; }
    if (glue_var_array_i32_size_c(arena, a_base) != array_n) { return 0; }
    if (glue_var_array_i32_size_c(arena, b_base) != array_n) { return 0; }
    let off_a: i32 = glue_simd_local_var_stack_off_c(arena, ctx, a_base);
    let off_b: i32 = glue_simd_local_var_stack_off_c(arena, ctx, b_base);
    let off_d: i32 = glue_simd_local_var_stack_off_c(arena, ctx, dst_base);
    let off_i: i32 = glue_simd_local_var_stack_off_c(arena, ctx, i_var_ref);
    if (off_a < 0) { return 0; }
    if (off_b < 0) { return 0; }
    if (off_d < 0) { return 0; }
    if (off_i < 0) { return 0; }
    let feats: u32 = glue_simd_loop_cpu_features_c();
    let esz: i32 = 4;
    let lanes: i32 = 0;
    if (glue_simd_loop_pick_lanes_c(feats, binop_ko, &lanes) != 0) { return 0; }
    if (n_is_const != 0) {
      if (n_lit > 0) {
        if ((n_lit % lanes) == 0) {
          if (n_lit <= array_n) {
            if (glue_var_is_array_i32_n_c(arena, dst_base, n_lit) != 0) {
              return glue_emit_full_const_peel_c(elf_ctx, binop_ko, off_a, off_b, off_d, n_lit, lanes, esz, ta, feats);
            }
          }
        }
      }
    }
    if (n_var_ref > 0) {
      let off_n: i32 = glue_simd_local_var_stack_off_c(arena, ctx, n_var_ref);
      if (off_n < 0) { return 0; }
      return glue_emit_runtime_strip_loop_c(arena, elf_ctx, ctx, ta, assign_body_ref, binop_ko, off_i, off_n, off_a, off_b, off_d, array_n, lanes, feats);
    }
  }
  return 0;
}

// G-02f-130：VAR 定长数组元素个数（任意 elem；上限 65536）
#[no_mangle]
function glue_var_array_size_c(arena: *u8, var_ref: i32): i32 {
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, var_ref) != 3) { return 0; }
    let tr: i32 = pipeline_expr_resolved_type_ref(arena, var_ref);
    if (tr <= 0) { return 0; }
    if (pipeline_type_kind_ord_at(arena, tr) != 10) { return 0; }
    let asz: i32 = pipeline_type_array_size_at(arena, tr);
    if (asz <= 0) { return 0; }
    if (asz > 65536) { return 0; }
    return asz;
  }
  return 0;
}

// G-02f-115：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function glue_soa_f32_col_rbp_disp32(off_col0: i32, start_idx: i32): i32 {
  return 0 - (off_col0 - start_idx * 4);
}

#[no_mangle]
function glue_f32_slot_rbp_disp32(off: i32): i32 {
  return 0 - off;
}

// GLUE_EXPR_MUL=6; SSE2=1, SSE41=2, AVX2=8
#[no_mangle]
function glue_simd_loop_pick_lanes_c(feats: u32, binop_ko: i32, lanes_out: *i32): i32 {
  if (lanes_out == 0) { return -1; }
  if (binop_ko == 6) {
    if ((feats & 8) != 0) { lanes_out[0] = 8; return 0; }
    if ((feats & 2) != 0) { lanes_out[0] = 4; return 0; }
    return -1;
  }
  if ((feats & 8) != 0) { lanes_out[0] = 8; return 0; }
  if ((feats & 1) != 0) { lanes_out[0] = 4; return 0; }
  return -1;
}

// G-02f-121：glue_var_is_array_i32_n_c 真迁 .x

#[no_mangle]
function glue_var_is_array_i32_n_c(arena: *u8, var_ref: i32, n: i32): i32 {
  unsafe {
    let sz: i32 = glue_var_array_i32_size_c(arena, var_ref);
    if (sz == n) { return 1; }
  }
  return 0;
}

// G-02f-124：glue_simd_x86_cmp_rax_rbx_c 真迁 .x

extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;

#[no_mangle]
function glue_simd_x86_cmp_rax_rbx_c(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let b0: u8 = 0x39;
  let b1: u8 = 0xd8;
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b0, 1) != 0) { return 0 - 1; }
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b1, 1);
  }
  return 0 - 1;
}

