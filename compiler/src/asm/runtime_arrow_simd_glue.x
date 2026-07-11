// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_arrow_simd_glue 产品源迁 seeds/runtime_arrow_simd_glue.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-103：+ f32/i32 sum/dot kernels 薄门闩（hsum_ps 仍 C，__m128 ABI）。

extern "C" function arrow_f32_sum_kernel_impl(data: *u8, n: i32): f32;
extern "C" function arrow_f32_dot_kernel_impl(a: *u8, b: *u8, n: i32): f32;
extern "C" function arrow_i32_sum_valid_kernel_impl(data: *u8, bm: *u8, n: i32): i32;
extern "C" function arrow_f32_sum_valid_kernel_impl(data: *u8, bm: *u8, n: i32): f32;

function runtime_arrow_simd_glue_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-103：arrow simd kernels 门闩 ---- */

#[no_mangle]
function arrow_f32_sum_kernel(data: *u8, n: i32): f32 {
  unsafe {
    return arrow_f32_sum_kernel_impl(data, n);
  }
  return 0.0 as f32;
}

#[no_mangle]
function arrow_f32_dot_kernel(a: *u8, b: *u8, n: i32): f32 {
  unsafe {
    return arrow_f32_dot_kernel_impl(a, b, n);
  }
  return 0.0 as f32;
}

#[no_mangle]
function arrow_i32_sum_valid_kernel(data: *u8, bm: *u8, n: i32): i32 {
  unsafe {
    return arrow_i32_sum_valid_kernel_impl(data, bm, n);
  }
  return 0;
}

#[no_mangle]
function arrow_f32_sum_valid_kernel(data: *u8, bm: *u8, n: i32): f32 {
  unsafe {
    return arrow_f32_sum_valid_kernel_impl(data, bm, n);
  }
  return 0.0 as f32;
}
