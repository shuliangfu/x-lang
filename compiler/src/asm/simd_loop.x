// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function driver_get_pending_target_cpu_features(): u32;
export extern "C" function shu_target_cpu_detect_host(): u32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;

/** Exported function `simd_loop_x_doc_anchor`.
 * Implements `simd_loop_x_doc_anchor`.
 * @return i32
 */
export function simd_loop_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

// glue_expr_same_var_c: see function docblock below.
/** Exported function `glue_expr_same_var_c`.
 * Implements `glue_expr_same_var_c`.
 * @param arena *u8
 * @param a_ref i32
 * @param b_ref i32
 * @return i32
 */
#[no_mangle]
export function glue_expr_same_var_c(arena: *u8, a_ref: i32, b_ref: i32): i32 {
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
  }
  return 1;
}

// glue_index_uses_var_c: see function docblock below.
/** Exported function `glue_index_uses_var_c`.
 * Implements `glue_index_uses_var_c`.
 * @param arena *u8
 * @param index_expr_ref i32
 * @param i_var_ref i32
 * @return i32
 */
#[no_mangle]
export function glue_index_uses_var_c(arena: *u8, index_expr_ref: i32, i_var_ref: i32): i32 {
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, index_expr_ref) != 47) { return 0; }
    let idx_ref: i32 = pipeline_expr_index_index_ref(arena, index_expr_ref);
    return glue_expr_same_var_c(arena, idx_ref, i_var_ref);
  }
  return 0;
}

// glue_var_array_i32_size_c: see function docblock below.
/** Exported function `glue_var_array_i32_size_c`.
 * Implements `glue_var_array_i32_size_c`.
 * @param arena *u8
 * @param var_ref i32
 * @return i32
 */
#[no_mangle]
export function glue_var_array_i32_size_c(arena: *u8, var_ref: i32): i32 {
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

// glue_simd_loop_cpu_features_c: see function docblock below.
/** Exported function `glue_simd_loop_cpu_features_c`.
 * Implements `glue_simd_loop_cpu_features_c`.
 * @return u32
 */
#[no_mangle]
export function glue_simd_loop_cpu_features_c(): u32 {
  unsafe {
    let feats: u32 = driver_get_pending_target_cpu_features();
    if (feats != 0) { return feats; }
    return shu_target_cpu_detect_host();
  }
  return 0;
}



/* See implementation. */

// GLUE_EXPR_*: VAR=3 ADD=4 SUB=5 MUL=6 LT=16 ASSIGN=28 ADD_ASSIGN=29 INDEX=47 FIELD=44
// GLUE_TYPE_*: I32=0 ARRAY=10 F32=14；LIT kind=0

export extern "C" function pipeline_expr_int_val_at(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_index_base_ref(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_field_access_base_ref(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_field_access_soa_stride(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_field_access_is_enum_variant(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_field_access_offset(arena: *u8, er: i32): i32;
export extern "C" function ast_ast_block_num_lets(arena: *u8, br: i32): i32;
export extern "C" function pipeline_block_let_name_len(arena: *u8, br: i32, li: i32): i32;
export extern "C" function pipeline_block_let_name_copy64(arena: *u8, br: i32, li: i32, dst: *u8): void;
export extern "C" function pipeline_block_let_init_ref(arena: *u8, br: i32, li: i32): i32;
export extern "C" function asm_ctx_local_find_offset(ctx: *u8, name: *u8, name_len: i32): i32;
export extern "C" function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern "C" function simd_enc_try_hw_vector_iadd_rbp(elf: *u8, a: i32, b: i32, d: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;
export extern "C" function simd_enc_try_hw_vector_isub_rbp(elf: *u8, a: i32, b: i32, d: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;
export extern "C" function simd_enc_try_hw_vector_imul_rbp(elf: *u8, a: i32, b: i32, d: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;
export extern "C" function ast_ast_block_while_cond_ref(arena: *u8, block_ref: i32, loop_idx: i32): i32;
export extern "C" function ast_ast_block_while_body_ref(arena: *u8, block_ref: i32, loop_idx: i32): i32;
export extern "C" function ast_ast_block_num_expr_stmts(arena: *u8, body: i32): i32;
export extern "C" function ast_ast_block_expr_stmt_ref(arena: *u8, body: i32, ei: i32): i32;
/* wave229 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — product hybrid full.x path owns peel/env gates. */
export extern "C" function link_abi_getenv(name: *u8): *u8;

// glue_block_let_init_lit_c: see function docblock below.
/** Exported function `glue_block_let_init_lit_c`.
 * Implements `glue_block_let_init_lit_c`.
 * @param arena *u8
 * @param block_ref i32
 * @param var_ref i32
 * @param out_lit *i32
 * @return i32
 */
#[no_mangle]
export function glue_block_let_init_lit_c(arena: *u8, block_ref: i32, var_ref: i32, out_lit: *i32): i32 {
  if (out_lit == 0) { return 0; }
  if (var_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, var_ref) != 3) { return 0; }
    let vlen: i32 = pipeline_expr_var_name_len(arena, var_ref);
    if (vlen <= 0) { return 0; }
    if (vlen > 63) { return 0; }
    let vbuf: u8[64] = [];
    pipeline_expr_var_name_into(arena, var_ref, &vbuf[0]);
    let nlet: i32 = ast_ast_block_num_lets(arena, block_ref);
    let li: i32 = 0;
    while (li < nlet) {
      let llen: i32 = pipeline_block_let_name_len(arena, block_ref, li);
      if (llen == vlen) {
        let lb: u8[64] = [];
        pipeline_block_let_name_copy64(arena, block_ref, li, &lb[0]);
        let matched: i32 = 1;
        let k: i32 = 0;
        while (k < vlen) {
          if (lb[k] != vbuf[k]) { matched = 0; }
          k = k + 1;
        }
        if (matched != 0) {
          let init_ref: i32 = pipeline_block_let_init_ref(arena, block_ref, li);
          if (init_ref <= 0) { return 0; }
          if (pipeline_expr_kind_ord_at(arena, init_ref) != 0) { return 0; }
          out_lit[0] = pipeline_expr_int_val_at(arena, init_ref);
          return 1;
        }
      }
      li = li + 1;
    }
  }
  return 0;
}

// G-02f-214：i = i + 1 / i += 1
/** Exported function `glue_parse_i_plus_one_step_c`.
 * Implements `glue_parse_i_plus_one_step_c`.
 * @param arena *u8
 * @param step_ref i32
 * @param i_var_ref i32
 * @return i32
 */
#[no_mangle]
export function glue_parse_i_plus_one_step_c(arena: *u8, step_ref: i32, i_var_ref: i32): i32 {
  unsafe {
    let ko: i32 = pipeline_expr_kind_ord_at(arena, step_ref);
    if (ko == 29) {
      let left_ref: i32 = pipeline_expr_binop_left_ref_at(arena, step_ref);
      let right_ref: i32 = pipeline_expr_binop_right_ref_at(arena, step_ref);
      if (glue_expr_same_var_c(arena, left_ref, i_var_ref) == 0) { return 0; }
      if (pipeline_expr_kind_ord_at(arena, right_ref) != 0) { return 0; }
      if (pipeline_expr_int_val_at(arena, right_ref) == 1) { return 1; }
      return 0;
    }
    if (ko != 28) { return 0; }
    let left_ref2: i32 = pipeline_expr_binop_left_ref_at(arena, step_ref);
    let right_ref2: i32 = pipeline_expr_binop_right_ref_at(arena, step_ref);
    if (glue_expr_same_var_c(arena, left_ref2, i_var_ref) == 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, right_ref2) != 4) { return 0; }
    let add_l: i32 = pipeline_expr_binop_left_ref_at(arena, right_ref2);
    let add_r: i32 = pipeline_expr_binop_right_ref_at(arena, right_ref2);
    if (glue_expr_same_var_c(arena, add_l, i_var_ref) == 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, add_r) != 0) { return 0; }
    if (pipeline_expr_int_val_at(arena, add_r) != 1) { return 0; }
  }
  return 1;
}

// G-02f-214：d[i] = a[i] ±/* b[i]
/** Exported function `glue_parse_index_binop_assign_c`.
 * Implements `glue_parse_index_binop_assign_c`.
 * @param arena *u8
 * @param assign_ref i32
 * @param i_var_ref i32
 * @param binop_ko *i32
 * @param dst_base_ref *i32
 * @param a_base_ref *i32
 * @param b_base_ref *i32
 * @return i32
 */
#[no_mangle]
export function glue_parse_index_binop_assign_c(arena: *u8, assign_ref: i32, i_var_ref: i32, binop_ko: *i32, dst_base_ref: *i32, a_base_ref: *i32, b_base_ref: *i32): i32 {
  if (binop_ko == 0) { return 0; }
  if (dst_base_ref == 0) { return 0; }
  if (a_base_ref == 0) { return 0; }
  if (b_base_ref == 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, assign_ref) != 28) { return 0; }
    let left_ref: i32 = pipeline_expr_binop_left_ref_at(arena, assign_ref);
    let right_ref: i32 = pipeline_expr_binop_right_ref_at(arena, assign_ref);
    if (glue_index_uses_var_c(arena, left_ref, i_var_ref) == 0) { return 0; }
    let rko: i32 = pipeline_expr_kind_ord_at(arena, right_ref);
    if (rko != 4) {
      if (rko != 5) {
        if (rko != 6) { return 0; }
      }
    }
    let al: i32 = pipeline_expr_binop_left_ref_at(arena, right_ref);
    let ar: i32 = pipeline_expr_binop_right_ref_at(arena, right_ref);
    if (glue_index_uses_var_c(arena, al, i_var_ref) == 0) { return 0; }
    if (glue_index_uses_var_c(arena, ar, i_var_ref) == 0) { return 0; }
    let dst_base: i32 = pipeline_expr_index_base_ref(arena, left_ref);
    let a_base: i32 = pipeline_expr_index_base_ref(arena, al);
    let b_base: i32 = pipeline_expr_index_base_ref(arena, ar);
    if (dst_base <= 0) { return 0; }
    if (a_base <= 0) { return 0; }
    if (b_base <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, dst_base) != 3) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, a_base) != 3) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, b_base) != 3) { return 0; }
    binop_ko[0] = rko;
    dst_base_ref[0] = dst_base;
    a_base_ref[0] = a_base;
    b_base_ref[0] = b_base;
  }
  return 1;
}

// G-02f-214：i < n / i < lit
/** Exported function `glue_parse_i_lt_bound_c`.
 * Implements `glue_parse_i_lt_bound_c`.
 * @param arena *u8
 * @param block_ref i32
 * @param cond_ref i32
 * @param i_var_ref *i32
 * @param n_lit *i32
 * @param n_is_const *i32
 * @param n_var_ref *i32
 * @return i32
 */
#[no_mangle]
export function glue_parse_i_lt_bound_c(arena: *u8, block_ref: i32, cond_ref: i32, i_var_ref: *i32, n_lit: *i32, n_is_const: *i32, n_var_ref: *i32): i32 {
  if (i_var_ref == 0) { return 0; }
  if (n_lit == 0) { return 0; }
  if (n_is_const == 0) { return 0; }
  if (n_var_ref == 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, cond_ref) != 16) { return 0; }
    let left_ref: i32 = pipeline_expr_binop_left_ref_at(arena, cond_ref);
    let right_ref: i32 = pipeline_expr_binop_right_ref_at(arena, cond_ref);
    if (pipeline_expr_kind_ord_at(arena, left_ref) != 3) { return 0; }
    i_var_ref[0] = left_ref;
    let rko: i32 = pipeline_expr_kind_ord_at(arena, right_ref);
    if (rko == 0) {
      n_lit[0] = pipeline_expr_int_val_at(arena, right_ref);
      if (n_lit[0] <= 0) { return 0; }
      n_is_const[0] = 1;
      n_var_ref[0] = 0;
      return 1;
    }
    if (rko != 3) { return 0; }
    n_var_ref[0] = right_ref;
    let prop: i32 = glue_block_let_init_lit_c(arena, block_ref, right_ref, n_lit);
    if (prop != 0) {
      if (n_lit[0] <= 0) { return 0; }
      n_is_const[0] = 1;
      return 1;
    }
    n_is_const[0] = 0;
  }
  return 1;
}

// glue_simd_local_var_stack_off_c: see function docblock below.
/** Exported function `glue_simd_local_var_stack_off_c`.
 * Implements `glue_simd_local_var_stack_off_c`.
 * @param arena *u8
 * @param ctx *u8
 * @param var_expr_ref i32
 * @return i32
 */
#[no_mangle]
export function glue_simd_local_var_stack_off_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32 {
  if (arena == 0) { return 0 - 1; }
  if (ctx == 0) { return 0 - 1; }
  if (var_expr_ref <= 0) { return 0 - 1; }
  unsafe {
    let vlen: i32 = pipeline_expr_var_name_len(arena, var_expr_ref);
    if (vlen <= 0) { return 0 - 1; }
    if (vlen > 63) { return 0 - 1; }
    let vname: u8[64] = [];
    pipeline_expr_var_name_into(arena, var_expr_ref, &vname[0]);
    let off: i32 = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
    if (off < 0) { return asm_ctx_local_find_offset(ctx, &vname[0], vlen);
    }
    return off;
  }
  return 0 - 1;
}

// glue_parse_f32_soa_sum_assign_c: see function docblock below.
/** Exported function `glue_parse_f32_soa_sum_assign_c`.
 * Implements `glue_parse_f32_soa_sum_assign_c`.
 * @param arena *u8
 * @param assign_ref i32
 * @param i_var_ref i32
 * @param sum_ref *i32
 * @param arr_ref *i32
 * @param fa_ref *i32
 * @return i32
 */
#[no_mangle]
export function glue_parse_f32_soa_sum_assign_c(arena: *u8, assign_ref: i32, i_var_ref: i32, sum_ref: *i32, arr_ref: *i32, fa_ref: *i32): i32 {
  if (sum_ref == 0) { return 0; }
  if (arr_ref == 0) { return 0; }
  if (fa_ref == 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, assign_ref) != 28) { return 0; }
    let left_ref: i32 = pipeline_expr_binop_left_ref_at(arena, assign_ref);
    let right_ref: i32 = pipeline_expr_binop_right_ref_at(arena, assign_ref);
    if (pipeline_expr_kind_ord_at(arena, right_ref) != 4) { return 0; }
    let add_l: i32 = pipeline_expr_binop_left_ref_at(arena, right_ref);
    let add_r: i32 = pipeline_expr_binop_right_ref_at(arena, right_ref);
    if (glue_expr_same_var_c(arena, left_ref, add_l) == 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, add_r) != 44) { return 0; }
    if (pipeline_expr_field_access_is_enum_variant(arena, add_r) != 0) { return 0; }
    if (pipeline_expr_field_access_soa_stride(arena, add_r) <= 0) { return 0; }
    let fa_tr: i32 = pipeline_expr_resolved_type_ref(arena, add_r);
    if (fa_tr <= 0) { return 0; }
    if (pipeline_type_kind_ord_at(arena, fa_tr) != 14) { return 0; }
    let sum_tr: i32 = pipeline_expr_resolved_type_ref(arena, left_ref);
    if (sum_tr <= 0) { return 0; }
    if (pipeline_type_kind_ord_at(arena, sum_tr) != 14) { return 0; }
    let idx_base: i32 = pipeline_expr_field_access_base_ref(arena, add_r);
    if (pipeline_expr_kind_ord_at(arena, idx_base) != 47) { return 0; }
    if (glue_index_uses_var_c(arena, idx_base, i_var_ref) == 0) { return 0; }
    idx_base = pipeline_expr_index_base_ref(arena, idx_base);
    if (pipeline_expr_kind_ord_at(arena, idx_base) != 3) { return 0; }
    sum_ref[0] = left_ref;
    arr_ref[0] = idx_base;
    fa_ref[0] = add_r;
  }
  return 1;
}

// G-02f-214：chunk binop → try_hw
/** Exported function `glue_simd_loop_emit_chunk_binop_c`.
 * Implements `glue_simd_loop_emit_chunk_binop_c`.
 * @param elf_ctx *u8
 * @param binop_ko i32
 * @param chunk_off_a i32
 * @param chunk_off_b i32
 * @param chunk_off_d i32
 * @param lanes i32
 * @param esz i32
 * @param ta i32
 * @param feats u32
 * @return i32
 */
#[no_mangle]
export function glue_simd_loop_emit_chunk_binop_c(elf_ctx: *u8, binop_ko: i32, chunk_off_a: i32, chunk_off_b: i32, chunk_off_d: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32 {
  unsafe {
    if (binop_ko == 5) {
      return simd_enc_try_hw_vector_isub_rbp(elf_ctx, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats);
    }
    if (binop_ko == 6) {
      return simd_enc_try_hw_vector_imul_rbp(elf_ctx, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats);
    }
    return simd_enc_try_hw_vector_iadd_rbp(elf_ctx, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats);
  }
  return 0 - 1;
}

// glue_emit_full_const_peel_c: see function docblock below.
/** Exported function `glue_emit_full_const_peel_c`.
 * Implements `glue_emit_full_const_peel_c`.
 * @param elf_ctx *u8
 * @param binop_ko i32
 * @param off_a i32
 * @param off_b i32
 * @param off_d i32
 * @param n_lit i32
 * @param lanes i32
 * @param esz i32
 * @param ta i32
 * @param feats u32
 * @return i32
 */
#[no_mangle]
export function glue_emit_full_const_peel_c(elf_ctx: *u8, binop_ko: i32, off_a: i32, off_b: i32, off_d: i32, n_lit: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32 {
  let chunks: i32 = n_lit / lanes;
  if (chunks <= 0) { return 0; }
  if ((chunks * lanes) != n_lit) { return 0; }
  let chunk: i32 = 0;
  while (chunk < chunks) {
    let start: i32 = chunk * lanes;
    let chunk_off_a: i32 = off_a - start * esz;
    let chunk_off_b: i32 = off_b - start * esz;
    let chunk_off_d: i32 = off_d - start * esz;
    if (glue_simd_loop_emit_chunk_binop_c(elf_ctx, binop_ko, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats) != 0) {
      let name: u8[24] = [];
      // SHUX_SIMD_HW_STRICT name[0] = 83; name[1] = 72; name[2] = 85; name[3] = 88;
      name[4] = 95; name[5] = 83; name[6] = 73; name[7] = 77;
      name[8] = 68; name[9] = 95; name[10] = 72; name[11] = 87;
      name[12] = 95; name[13] = 83; name[14] = 84; name[15] = 82;
      name[16] = 73; name[17] = 67; name[18] = 84; name[19] = 0;
      unsafe {
        // wave229 G.7: SHUX_SIMD_HW_STRICT via link_abi_getenv (not raw getenv).
        let p: *u8 = link_abi_getenv(&name[0]);
        if (p != 0) { if (p[0] != 48) { return 0 - 1; }
        }
      }
      return 0;
    }
    chunk = chunk + 1;
  }
  return 1;
}

/** Return 1 if SIMD hardware peel/emit should be disabled via env.
 * Looks up link_abi_getenv("SHUX_SIMD_HW"); if the value starts with ASCII '0', treat HW SIMD as off.
 * Missing env or other values leave HW SIMD enabled (return 0).
 * Env name is built as byte array (no string-literal dependency in this TU):
 *   S H U X _ S I M D _ H W \0  →  83 72 85 88 95 83 73 77 68 95 72 87 0
 * Track-L: #[no_mangle] keeps surface short name (not simd_loop_glue_simd_hw_env_disabled).
 * wave229 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * PLATFORM: SHARED — link-name contract; dual-host prove. Host residual = link_abi_getenv_impl. */
#[no_mangle]
export function glue_simd_hw_env_disabled(): i32 {
  unsafe {
    let name: u8[16] = [];
    // Build "SHUX_SIMD_HW" without a string lit (stable -E / seed parity).
    name[0] = 83; name[1] = 72; name[2] = 85; name[3] = 88;
    name[4] = 95; name[5] = 83; name[6] = 73; name[7] = 77;
    name[8] = 68; name[9] = 95; name[10] = 72; name[11] = 87;
    name[12] = 0;
    let p: *u8 = link_abi_getenv(&name[0]);
    if (p == 0) { return 0; }
    // First byte '0' (ASCII 48) → explicitly disable HW SIMD.
    if (p[0] == 48) { return 1; }
  }
  return 0;
}

// glue_try_simd_peel_f32_soa_sum_while_elf_c: see function docblock below.
/** Exported function `glue_try_simd_peel_f32_soa_sum_while_elf_c`.
 * Implements `glue_try_simd_peel_f32_soa_sum_while_elf_c`.
 * @param arena *u8
 * @param elf_ctx *u8
 * @param block_ref i32
 * @param loop_idx i32
 * @param ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function glue_try_simd_peel_f32_soa_sum_while_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, loop_idx: i32, ctx: *u8, ta: i32): i32 {
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

// glue_try_simd_peel_index_add_while_elf_c: see function docblock below.
/** Exported function `glue_try_simd_peel_index_add_while_elf_c`.
 * Implements `glue_try_simd_peel_index_add_while_elf_c`.
 * @param arena *u8
 * @param elf_ctx *u8
 * @param block_ref i32
 * @param loop_idx i32
 * @param ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function glue_try_simd_peel_index_add_while_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, loop_idx: i32, ctx: *u8, ta: i32): i32 {
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

// glue_var_array_size_c: see function docblock below.
/** Exported function `glue_var_array_size_c`.
 * Implements `glue_var_array_size_c`.
 * @param arena *u8
 * @param var_ref i32
 * @return i32
 */
#[no_mangle]
export function glue_var_array_size_c(arena: *u8, var_ref: i32): i32 {
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

// glue_soa_f32_col_rbp_disp32: see function docblock below.

/** Exported function `glue_soa_f32_col_rbp_disp32`.
 * Implements `glue_soa_f32_col_rbp_disp32`.
 * @param off_col0 i32
 * @param start_idx i32
 * @return i32
 */
#[no_mangle]
export function glue_soa_f32_col_rbp_disp32(off_col0: i32, start_idx: i32): i32 {
  return 0 - (off_col0 - start_idx * 4);
}

/** Exported function `glue_f32_slot_rbp_disp32`.
 * Implements `glue_f32_slot_rbp_disp32`.
 * @param off i32
 * @return i32
 */
#[no_mangle]
export function glue_f32_slot_rbp_disp32(off: i32): i32 {
  return 0 - off;
}

// GLUE_EXPR_MUL=6; SSE2=1, SSE41=2, AVX2=8
/** Exported function `glue_simd_loop_pick_lanes_c`.
 * Implements `glue_simd_loop_pick_lanes_c`.
 * @param feats u32
 * @param binop_ko i32
 * @param lanes_out *i32
 * @return i32
 */
#[no_mangle]
export function glue_simd_loop_pick_lanes_c(feats: u32, binop_ko: i32, lanes_out: *i32): i32 {
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

// glue_var_is_array_i32_n_c: see function docblock below.

/** Exported function `glue_var_is_array_i32_n_c`.
 * Implements `glue_var_is_array_i32_n_c`.
 * @param arena *u8
 * @param var_ref i32
 * @param n i32
 * @return i32
 */
#[no_mangle]
export function glue_var_is_array_i32_n_c(arena: *u8, var_ref: i32, n: i32): i32 {
  unsafe {
    let sz: i32 = glue_var_array_i32_size_c(arena, var_ref);
    if (sz == n) { return 1; }
  }
  return 0;
}

// See implementation.

export extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;

/** Exported function `glue_simd_x86_cmp_rax_rbx_c`.
 * Comparison/utility `glue_simd_x86_cmp_rax_rbx_c`.
 * @param elf_ctx *u8
 * @return i32
 */
#[no_mangle]
export function glue_simd_x86_cmp_rax_rbx_c(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let b0: u8 = 0x39;
  let b1: u8 = 0xd8;
  let r: i32 = 0;
  unsafe { r = pipeline_elf_ctx_append_bytes(elf_ctx, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = pipeline_elf_ctx_append_bytes(elf_ctx, &b1, 1); }
  return r;
}

/* ---- G-02f-215：runtime strip + f32 soa sum strip ---- */

export extern "C" function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, cap: i32): i32;
export extern "C" function pipeline_asm_emit_assign_elf_c(arena: *u8, elf_ctx: *u8, assign_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32, ta: i32): i32;
export extern "C" function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern "C" function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern "C" function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern "C" function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern "C" function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern "C" function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern "C" function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern "C" function backend_enc_jge_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern "C" function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern "C" function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern "C" function simd_enc_try_hw_vector_binop_rbp_at_idx(elf_ctx: *u8, off_a: i32, off_b: i32, off_d: i32, off_i: i32, array_n: i32, binop_ko: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;
export extern "C" function simd_enc_x86_xorps_xmm0_zero(elf_ctx: *u8): i32;
export extern "C" function simd_enc_f32_soa_col_movups_xmm1_at_idx(elf_ctx: *u8, off_col0: i32, off_i: i32, ta: i32): i32;
export extern "C" function simd_enc_x86_addps_xmm0_xmm1(elf_ctx: *u8): i32;
export extern "C" function simd_enc_x86_horizontal_addps_xmm0(elf_ctx: *u8): i32;
export extern "C" function simd_enc_x86_movss_xmm0_rbp_disp(elf_ctx: *u8, disp: i32): i32;

// glue_emit_runtime_strip_loop_c: see function docblock below.
/** Exported function `glue_emit_runtime_strip_loop_c`.
 * Implements `glue_emit_runtime_strip_loop_c`.
 * @param arena *u8
 * @param elf_ctx *u8
 * @param ctx *u8
 * @param ta i32
 * @param assign_body_ref i32
 * @param binop_ko i32
 * @param off_i i32
 * @param off_n i32
 * @param off_a i32
 * @param off_b i32
 * @param off_d i32
 * @param array_n i32
 * @param lanes i32
 * @param feats u32
 * @return i32
 */
#[no_mangle]
export function glue_emit_runtime_strip_loop_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, assign_body_ref: i32, binop_ko: i32, off_i: i32, off_n: i32, off_a: i32, off_b: i32, off_d: i32, array_n: i32, lanes: i32, feats: u32): i32 {
  if (ta != 0) { return 0; }
  let vec_loop: u8[64] = [];
  let epi_loop: u8[64] = [];
  let epi_done: u8[64] = [];
  let vec_len: i32 = 0;
  let epi_len: i32 = 0;
  let done_len: i32 = 0;
  unsafe { vec_len = pipeline_asm_emit_next_label_c(ctx, &vec_loop[0], 64); }
  unsafe { epi_len = pipeline_asm_emit_next_label_c(ctx, &epi_loop[0], 64); }
  unsafe { done_len = pipeline_asm_emit_next_label_c(ctx, &epi_done[0], 64); }
  if (vec_len <= 0) { return 0 - 1; }
  if (epi_len <= 0) { return 0 - 1; }
  if (done_len <= 0) { return 0 - 1; }
  let r: i32 = 0;
  unsafe { r = backend_enc_label_arch(elf_ctx, &vec_loop[0], vec_len, 0, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_push_rax_arch(elf_ctx, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_n, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_pop_rax_arch(elf_ctx, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = glue_simd_x86_cmp_rax_rbx_c(elf_ctx); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_jge_arch(elf_ctx, &epi_loop[0], epi_len, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_enc_try_hw_vector_binop_rbp_at_idx(elf_ctx, off_a, off_b, off_d, off_i, array_n, binop_ko, lanes, 4, ta, feats); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_jmp_arch(elf_ctx, &vec_loop[0], vec_len, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_label_arch(elf_ctx, &epi_loop[0], epi_len, 0, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_load_rbp_to_rbx_arch(elf_ctx, off_n, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = glue_simd_x86_cmp_rax_rbx_c(elf_ctx); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_jge_arch(elf_ctx, &epi_done[0], done_len, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = pipeline_asm_emit_assign_elf_c(arena, elf_ctx, assign_body_ref, ctx, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_jmp_arch(elf_ctx, &epi_loop[0], epi_len, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_label_arch(elf_ctx, &epi_done[0], done_len, 0, ta); }
  if (r != 0) { return 0 - 1; }
  return 1;
}

// glue_emit_f32_soa_sum_strip_c: see function docblock below.
/** Exported function `glue_emit_f32_soa_sum_strip_c`.
 * Implements `glue_emit_f32_soa_sum_strip_c`.
 * @param arena *u8
 * @param elf_ctx *u8
 * @param ctx *u8
 * @param ta i32
 * @param assign_body_ref i32
 * @param off_col0 i32
 * @param off_s i32
 * @param off_i i32
 * @param off_n i32
 * @param n_lit i32
 * @param lanes i32
 * @param feats u32
 * @return i32
 */
#[no_mangle]
export function glue_emit_f32_soa_sum_strip_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, assign_body_ref: i32, off_col0: i32, off_s: i32, off_i: i32, off_n: i32, n_lit: i32, lanes: i32, feats: u32): i32 {
  if (ta != 0) { return 0; }
  if (lanes != 4) { return 0; }
  // SSE2 = 1
  if ((feats & 1) == 0) { return 0; }
  let vec_loop: u8[64] = [];
  let epi_merge: u8[64] = [];
  let epi_loop: u8[64] = [];
  let epi_done: u8[64] = [];
  let vec_len: i32 = 0;
  let merge_len: i32 = 0;
  let epi_len: i32 = 0;
  let done_len: i32 = 0;
  unsafe { vec_len = pipeline_asm_emit_next_label_c(ctx, &vec_loop[0], 64); }
  unsafe { merge_len = pipeline_asm_emit_next_label_c(ctx, &epi_merge[0], 64); }
  unsafe { epi_len = pipeline_asm_emit_next_label_c(ctx, &epi_loop[0], 64); }
  unsafe { done_len = pipeline_asm_emit_next_label_c(ctx, &epi_done[0], 64); }
  if (vec_len <= 0) { return 0 - 1; }
  if (merge_len <= 0) { return 0 - 1; }
  if (epi_len <= 0) { return 0 - 1; }
  if (done_len <= 0) { return 0 - 1; }
  let r: i32 = 0;
  unsafe { r = simd_enc_x86_xorps_xmm0_zero(elf_ctx); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_label_arch(elf_ctx, &vec_loop[0], vec_len, 0, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_push_rax_arch(elf_ctx, ta); }
  if (r != 0) { return 0 - 1; }
  if (off_n >= 0) {
    unsafe { r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_n, ta); }
    if (r != 0) { return 0 - 1; }
  } else {
    unsafe { r = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_lit, 0, ta); }
    if (r != 0) { return 0 - 1; }
  }
  unsafe { r = backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_pop_rax_arch(elf_ctx, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = glue_simd_x86_cmp_rax_rbx_c(elf_ctx); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_jge_arch(elf_ctx, &epi_merge[0], merge_len, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_enc_f32_soa_col_movups_xmm1_at_idx(elf_ctx, off_col0, off_i, ta); }
  if (r != 0) {
    let name: u8[24] = [];
    name[0] = 83; name[1] = 72; name[2] = 85; name[3] = 88;
    name[4] = 95; name[5] = 83; name[6] = 73; name[7] = 77;
    name[8] = 68; name[9] = 95; name[10] = 72; name[11] = 87;
    name[12] = 95; name[13] = 83; name[14] = 84; name[15] = 82;
    name[16] = 73; name[17] = 67; name[18] = 84; name[19] = 0;
    unsafe {
      // wave229 G.7: SHUX_SIMD_HW_STRICT via link_abi_getenv (not raw getenv).
      let p: *u8 = link_abi_getenv(&name[0]);
      if (p != 0) { if (p[0] != 48) { return 0 - 1; }
      }
    }
    return 0;
  }
  unsafe { r = simd_enc_x86_addps_xmm0_xmm1(elf_ctx); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_jmp_arch(elf_ctx, &vec_loop[0], vec_len, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_label_arch(elf_ctx, &epi_merge[0], merge_len, 0, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_enc_x86_horizontal_addps_xmm0(elf_ctx); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_enc_x86_movss_xmm0_rbp_disp(elf_ctx, glue_f32_slot_rbp_disp32(off_s)); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_label_arch(elf_ctx, &epi_loop[0], epi_len, 0, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  if (off_n >= 0) {
    unsafe { r = backend_enc_load_rbp_to_rbx_arch(elf_ctx, off_n, ta); }
    if (r != 0) { return 0 - 1; }
  } else {
    unsafe { r = backend_enc_push_rax_arch(elf_ctx, ta); }
    if (r != 0) { return 0 - 1; }
    unsafe { r = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_lit, 0, ta); }
    if (r != 0) { return 0 - 1; }
    unsafe { r = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta); }
    if (r != 0) { return 0 - 1; }
    unsafe { r = backend_enc_pop_rax_arch(elf_ctx, ta); }
    if (r != 0) { return 0 - 1; }
  }
  unsafe { r = glue_simd_x86_cmp_rax_rbx_c(elf_ctx); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_jge_arch(elf_ctx, &epi_done[0], done_len, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = pipeline_asm_emit_assign_elf_c(arena, elf_ctx, assign_body_ref, ctx, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_jmp_arch(elf_ctx, &epi_loop[0], epi_len, ta); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = backend_enc_label_arch(elf_ctx, &epi_done[0], done_len, 0, ta); }
  if (r != 0) { return 0 - 1; }
  return 1;
}
