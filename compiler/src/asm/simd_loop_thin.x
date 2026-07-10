// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-349/384/403/404：simd_loop L2 thin — pure glue 子集（13 门闩）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_SIMD_LOOP_THIN_FROM_X）ld -r → simd_loop.o
// 对照：src/asm/simd_loop.x；默认仍整 seed。
//
// FEAT: SSE2=1 SSE41=2 AVX2=8；GLUE_EXPR_MUL=6；VAR=3 ARRAY=10 I32=0
//

extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
extern "C" function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;

#[no_mangle]
function glue_f32_slot_rbp_disp32(off: i32): i32 {
  return 0 - off;
}

#[no_mangle]
function glue_soa_f32_col_rbp_disp32(off_col0: i32, start_idx: i32): i32 {
  return 0 - (off_col0 - start_idx * 4);
}

// 按 binop 与 feats 选 lane 宽；lanes_out 写 4/8
#[no_mangle]
function glue_simd_loop_pick_lanes_c(feats: u32, binop_ko: i32, lanes_out: *i32): i32 {
  if (lanes_out == 0 as *i32) {
    return 0 - 1;
  }
  unsafe {
    if (binop_ko == 6) {
      if ((feats & 8) != 0) {
        lanes_out[0] = 8;
        return 0;
      }
      if ((feats & 2) != 0) {
        lanes_out[0] = 4;
        return 0;
      }
      return 0 - 1;
    }
    if ((feats & 8) != 0) {
      lanes_out[0] = 8;
      return 0;
    }
    if ((feats & 1) != 0) {
      lanes_out[0] = 4;
      return 0;
    }
    return 0 - 1;
  }
  return 0 - 1;
}

// VAR 的 i32[N] 元素个数；失败 0（N∈(0,256]）
#[no_mangle]
function glue_var_array_i32_size_c(arena: *u8, var_ref: i32): i32 {
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, var_ref) != 3) {
      return 0;
    }
    let tr: i32 = pipeline_expr_resolved_type_ref(arena, var_ref);
    if (tr <= 0) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, tr) != 10) {
      return 0;
    }
    let asz: i32 = pipeline_type_array_size_at(arena, tr);
    if (asz <= 0) {
      return 0;
    }
    if (asz > 256) {
      return 0;
    }
    let elem: i32 = pipeline_type_elem_ref_at(arena, tr);
    if (elem <= 0) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, elem) != 0) {
      return 0;
    }
    return asz;
  }
  return 0;
}

#[no_mangle]
function glue_var_is_array_i32_n_c(arena: *u8, var_ref: i32, n: i32): i32 {
  if (n <= 0) {
    return 0;
  }
  unsafe {
    let asz: i32 = glue_var_array_i32_size_c(arena, var_ref);
    if (asz == n) {
      return 1;
    }
    return 0;
  }
  return 0;
}

// ---- G-02f-384：same_var / index_uses_var → seed impl ----
extern "C" function glue_expr_same_var_c_impl(arena: *u8, a_ref: i32, b_ref: i32): i32;
extern "C" function glue_index_uses_var_c_impl(arena: *u8, index_expr_ref: i32, i_var_ref: i32): i32;

#[no_mangle]
function glue_expr_same_var_c(arena: *u8, a_ref: i32, b_ref: i32): i32 {
  unsafe {
    return glue_expr_same_var_c_impl(arena, a_ref, b_ref);
  }
  return 0;
}

#[no_mangle]
function glue_index_uses_var_c(arena: *u8, index_expr_ref: i32, i_var_ref: i32): i32 {
  unsafe {
    return glue_index_uses_var_c_impl(arena, index_expr_ref, i_var_ref);
  }
  return 0;
}

// ---- G-02f-403：cmp / array_size / chunk_binop → seed impl ----
extern "C" function glue_simd_x86_cmp_rax_rbx_c_impl(elf_ctx: *u8): i32;
extern "C" function glue_var_array_size_c_impl(arena: *u8, var_ref: i32): i32;
extern "C" function glue_simd_loop_emit_chunk_binop_c_impl(elf_ctx: *u8, binop_ko: i32, chunk_off_a: i32, chunk_off_b: i32, chunk_off_d: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;

#[no_mangle]
function glue_simd_x86_cmp_rax_rbx_c(elf_ctx: *u8): i32 {
  unsafe {
    return glue_simd_x86_cmp_rax_rbx_c_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function glue_var_array_size_c(arena: *u8, var_ref: i32): i32 {
  unsafe {
    return glue_var_array_size_c_impl(arena, var_ref);
  }
  return 0;
}

#[no_mangle]
function glue_simd_loop_emit_chunk_binop_c(elf_ctx: *u8, binop_ko: i32, chunk_off_a: i32, chunk_off_b: i32, chunk_off_d: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32 {
  unsafe {
    return glue_simd_loop_emit_chunk_binop_c_impl(elf_ctx, binop_ko, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats);
  }
  return 0 - 1;
}

// ---- G-02f-404：local_off / const_peel / runtime_strip → seed impl ----
extern "C" function glue_simd_local_var_stack_off_c_impl(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
extern "C" function glue_emit_full_const_peel_c_impl(elf_ctx: *u8, binop_ko: i32, off_a: i32, off_b: i32, off_d: i32, n_lit: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32;
extern "C" function glue_emit_runtime_strip_loop_c_impl(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, assign_body_ref: i32, binop_ko: i32, off_i: i32, off_n: i32, off_a: i32, off_b: i32, off_d: i32, array_n: i32, lanes: i32, feats: u32): i32;

#[no_mangle]
function glue_simd_local_var_stack_off_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32 {
  unsafe {
    return glue_simd_local_var_stack_off_c_impl(arena, ctx, var_expr_ref);
  }
  return 0 - 1;
}

#[no_mangle]
function glue_emit_full_const_peel_c(elf_ctx: *u8, binop_ko: i32, off_a: i32, off_b: i32, off_d: i32, n_lit: i32, lanes: i32, esz: i32, ta: i32, feats: u32): i32 {
  unsafe {
    return glue_emit_full_const_peel_c_impl(elf_ctx, binop_ko, off_a, off_b, off_d, n_lit, lanes, esz, ta, feats);
  }
  return 0;
}

#[no_mangle]
function glue_emit_runtime_strip_loop_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, assign_body_ref: i32, binop_ko: i32, off_i: i32, off_n: i32, off_a: i32, off_b: i32, off_d: i32, array_n: i32, lanes: i32, feats: u32): i32 {
  unsafe {
    return glue_emit_runtime_strip_loop_c_impl(arena, elf_ctx, ctx, ta, assign_body_ref, binop_ko, off_i, off_n, off_a, off_b, off_d, array_n, lanes, feats);
  }
  return 0;
}
