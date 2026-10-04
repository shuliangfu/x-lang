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

/* Write the f32 sum through out. The installed product cannot asm-emit an f32 return,
 * and xmm0 is not interchangeable with a general register.
 * PLATFORM: SHARED — link name unchanged.
 */

#[no_mangle]
export function arrow_f32_sum_kernel(out: *f32, data: *u8, n: i32): i32 {
  let v: f32 = 0.0;
  unsafe { v = arrow_f32_sum_kernel_impl(data, n); }
  unsafe { *out = v; }
  return 0;
}

/** Exported function `arrow_f32_dot_kernel`.
 * Implements `arrow_f32_dot_kernel`.
 * @param a *u8
 * @param b *u8
 * @param n i32
 * @param out receives the dot product; must not be null
 * @return i32 — always 0; the value is in out
 * PLATFORM: SHARED — the installed product cannot asm-emit an f32 return.
 */
#[no_mangle]
export function arrow_f32_dot_kernel(out: *f32, a: *u8, b: *u8, n: i32): i32 {
  let v: f32 = 0.0;
  unsafe { v = arrow_f32_dot_kernel_impl(a, b, n); }
  unsafe { *out = v; }
  return 0;
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
 * @param out receives the sum; must not be null
 * @return i32 — always 0; the value is in out
 * PLATFORM: SHARED — the installed product cannot asm-emit an f32 return.
 */
#[no_mangle]
export function arrow_f32_sum_valid_kernel(out: *f32, data: *u8, bm: *u8, n: i32): i32 {
  let v: f32 = 0.0;
  unsafe { v = arrow_f32_sum_valid_kernel_impl(data, bm, n); }
  unsafe { *out = v; }
  return 0;
}
