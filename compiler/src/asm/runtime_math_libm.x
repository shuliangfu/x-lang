// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function math_fenv_mask_to_fe_impl(mask: i32): i32;
export extern "C" function math_fenv_fe_to_mask_impl(fe: i32): i32;
export extern "C" function math_fenv_emit_cap_report_impl(avail: i32): void;

/** Exported function `runtime_math_libm_x_doc_anchor`.
 * Implements `runtime_math_libm_x_doc_anchor`.
 * @return i32
 */
export function runtime_math_libm_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */



#[no_mangle]
export function math_fenv_mask_to_fe(mask: i32): i32 {
  unsafe {
    return math_fenv_mask_to_fe_impl(mask);
  }
  return 0;
}

#[no_mangle]
/** Exported function `math_fenv_fe_to_mask`.
 * Implements `math_fenv_fe_to_mask`.
 * @param fe i32
 * @return i32
 */
export function math_fenv_fe_to_mask(fe: i32): i32 {
  unsafe {
    return math_fenv_fe_to_mask_impl(fe);
  }
  return 0;
}

#[no_mangle]
/** Exported function `math_fenv_emit_cap_report`.
 * Implements `math_fenv_emit_cap_report`.
 * @param avail i32
 * @return void
 */
export function math_fenv_emit_cap_report(avail: i32): void {
  unsafe {
    math_fenv_emit_cap_report_impl(avail);
  }
}

// math_special_near: see function docblock below.

#[no_mangle]
/** Exported function `math_special_near`.
 * Implements `math_special_near`.
 * @param a f64
 * @param b f64
 * @param eps f64
 * @return i32
 */
export function math_special_near(a: f64, b: f64, eps: f64): i32 {
  let d: f64 = a - b;
  if (d < 0.0) { d = 0.0 - d; }
  if (d <= eps) { return 1; }
  return 0;
}
