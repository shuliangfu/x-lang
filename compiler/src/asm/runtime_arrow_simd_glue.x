// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.

export extern "C" function arrow_f32_sum_kernel_impl(data: *u8, n: i32): f32;
export extern "C" function arrow_f32_dot_kernel_impl(a: *u8, b: *u8, n: i32): f32;
export extern "C" function arrow_i32_sum_valid_kernel_impl(data: *u8, bm: *u8, n: i32): i32;
export extern "C" function arrow_f32_sum_valid_kernel_impl(data: *u8, bm: *u8, n: i32): f32;

/** Exported function `runtime_arrow_simd_glue_x_doc_anchor`.
 * Implements `runtime_arrow_simd_glue_x_doc_anchor`.
 * @return i32
 */
export function runtime_arrow_simd_glue_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function arrow_f32_sum_kernel(data: *u8, n: i32): f32 {
  unsafe {
    return arrow_f32_sum_kernel_impl(data, n);
  }
  return 0.0 as f32;
}

/** Exported function `arrow_f32_dot_kernel`.
 * Implements `arrow_f32_dot_kernel`.
 * @param a *u8
 * @param b *u8
 * @param n i32
 * @return f32
 */
#[no_mangle]
export function arrow_f32_dot_kernel(a: *u8, b: *u8, n: i32): f32 {
  unsafe {
    return arrow_f32_dot_kernel_impl(a, b, n);
  }
  return 0.0 as f32;
}

/** Exported function `arrow_i32_sum_valid_kernel`.
 * Implements `arrow_i32_sum_valid_kernel`.
 * @param data *u8
 * @param bm *u8
 * @param n i32
 * @return i32
 */
#[no_mangle]
export function arrow_i32_sum_valid_kernel(data: *u8, bm: *u8, n: i32): i32 {
  unsafe {
    return arrow_i32_sum_valid_kernel_impl(data, bm, n);
  }
  return 0;
}

/** Exported function `arrow_f32_sum_valid_kernel`.
 * Implements `arrow_f32_sum_valid_kernel`.
 * @param data *u8
 * @param bm *u8
 * @param n i32
 * @return f32
 */
#[no_mangle]
export function arrow_f32_sum_valid_kernel(data: *u8, bm: *u8, n: i32): f32 {
  unsafe {
    return arrow_f32_sum_valid_kernel_impl(data, bm, n);
  }
  return 0.0 as f32;
}
