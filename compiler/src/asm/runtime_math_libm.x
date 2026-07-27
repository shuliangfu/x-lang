// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_math_libm.x — R2 full mode public API
// PLATFORM: SHARED
//
// This module provides libm (math library) glue functions for Xlang.
// All functions use f64 (C double) as the primary floating-point type.
//
// Bridge declarations: libm _impl functions implemented in C seed (seeds/runtime_math_libm.from_x.c)
// Public APIs: #[no_mangle] wrappers that call _impl via unsafe extern blocks
//
// libm functions: floor/ceil/trunc/round/sin/cos/tan/asin/acos/atan/atan2/
//   sqrt/cbrt/pow/exp/log/fabs/signum/fmin/fmax/erf/erfc/log1p/expm1
// fenv functions: mask_to_fe/fe_to_mask/emit_cap_report/available/test/clear/raise/smoke
// special: special_near (full .x impl), special_smoke_c (seed test)

// === libm bridge declarations (extern "C" _impl functions) ===

export extern "C" function math_floor_impl(x: f64): f64;
export extern "C" function math_ceil_impl(x: f64): f64;
export extern "C" function math_trunc_impl(x: f64): f64;
export extern "C" function math_round_impl(x: f64): f64;
export extern "C" function math_sin_impl(x: f64): f64;
export extern "C" function math_cos_impl(x: f64): f64;
export extern "C" function math_tan_impl(x: f64): f64;
export extern "C" function math_asin_impl(x: f64): f64;
export extern "C" function math_acos_impl(x: f64): f64;
export extern "C" function math_atan_impl(x: f64): f64;
export extern "C" function math_atan2_impl(y: f64, x: f64): f64;
export extern "C" function math_sqrt_impl(x: f64): f64;
export extern "C" function math_cbrt_impl(x: f64): f64;
export extern "C" function math_pow_impl(base: f64, exp: f64): f64;
export extern "C" function math_exp_impl(x: f64): f64;
export extern "C" function math_log_impl(x: f64): f64;
export extern "C" function math_fabs_impl(x: f64): f64;
export extern "C" function math_fmin_impl(a: f64, b: f64): f64;
export extern "C" function math_fmax_impl(a: f64, b: f64): f64;
export extern "C" function math_erf_impl(x: f64): f64;
export extern "C" function math_erfc_impl(x: f64): f64;
export extern "C" function math_log1p_impl(x: f64): f64;
export extern "C" function math_expm1_impl(x: f64): f64;

// === fenv bridge declarations ===

export extern "C" function math_fenv_mask_to_fe_impl(mask: i32): i32;
export extern "C" function math_fenv_fe_to_mask_impl(fe: i32): i32;
export extern "C" function math_fenv_emit_cap_report_impl(avail: i32): void;

// === forward declarations for thin functions (called by rest/smoke) ===

export function math_special_near(a: f64, b: f64, eps: f64): i32;
export function math_fenv_mask_to_fe(mask: i32): i32;
export function math_fenv_fe_to_mask(fe: i32): i32;
export function math_fenv_emit_cap_report(avail: i32): void;

// === doc anchor ===

export function runtime_math_libm_x_doc_anchor(): i32 {
  return 0;
}

// === math_signum: full .x implementation (no C bridge needed) ===

/// Returns signum of x: 1 if x > 0, -1 if x < 0, 0 if x == 0.
#[no_mangle]
export function math_signum_c(x: f64): f64 {
  if x > 0.0 {
    return 1.0;
  }
  if x < 0.0 {
    return -1.0;
  }
  return 0.0;
}

// === math_special_near: full .x implementation ===

/// Returns 1 if |a - b| <= eps, 0 otherwise.
#[no_mangle]
export function math_special_near(a: f64, b: f64, eps: f64): i32 {
  let d: f64 = a - b;
  if d < 0.0 { d = 0.0 - d; }
  if d <= eps { return 1; }
  return 0;
}

// === libm public API wrappers (#[no_mangle]) ===

#[no_mangle]
export function math_floor_c(x: f64): f64 {
  unsafe { return math_floor_impl(x); }
}

#[no_mangle]
export function math_ceil_c(x: f64): f64 {
  unsafe { return math_ceil_impl(x); }
}

#[no_mangle]
export function math_trunc_c(x: f64): f64 {
  unsafe { return math_trunc_impl(x); }
}

#[no_mangle]
export function math_round_c(x: f64): f64 {
  unsafe { return math_round_impl(x); }
}

#[no_mangle]
export function math_sin_c(x: f64): f64 {
  unsafe { return math_sin_impl(x); }
}

#[no_mangle]
export function math_cos_c(x: f64): f64 {
  unsafe { return math_cos_impl(x); }
}

#[no_mangle]
export function math_tan_c(x: f64): f64 {
  unsafe { return math_tan_impl(x); }
}

#[no_mangle]
export function math_asin_c(x: f64): f64 {
  unsafe { return math_asin_impl(x); }
}

#[no_mangle]
export function math_acos_c(x: f64): f64 {
  unsafe { return math_acos_impl(x); }
}

#[no_mangle]
export function math_atan_c(x: f64): f64 {
  unsafe { return math_atan_impl(x); }
}

#[no_mangle]
export function math_atan2_c(y: f64, x: f64): f64 {
  unsafe { return math_atan2_impl(y, x); }
}

#[no_mangle]
export function math_sqrt_c(x: f64): f64 {
  unsafe { return math_sqrt_impl(x); }
}

#[no_mangle]
export function math_cbrt_c(x: f64): f64 {
  unsafe { return math_cbrt_impl(x); }
}

#[no_mangle]
export function math_pow_c(base: f64, exp: f64): f64 {
  unsafe { return math_pow_impl(base, exp); }
}

#[no_mangle]
export function math_exp_c(x: f64): f64 {
  unsafe { return math_exp_impl(x); }
}

#[no_mangle]
export function math_log_c(x: f64): f64 {
  unsafe { return math_log_impl(x); }
}

#[no_mangle]
export function math_fabs_c(x: f64): f64 {
  unsafe { return math_fabs_impl(x); }
}

#[no_mangle]
export function math_fmin_c(a: f64, b: f64): f64 {
  unsafe { return math_fmin_impl(a, b); }
}

#[no_mangle]
export function math_fmax_c(a: f64, b: f64): f64 {
  unsafe { return math_fmax_impl(a, b); }
}

#[no_mangle]
export function math_erf_c(x: f64): f64 {
  unsafe { return math_erf_impl(x); }
}

#[no_mangle]
export function math_erfc_c(x: f64): f64 {
  unsafe { return math_erfc_impl(x); }
}

#[no_mangle]
export function math_log1p_c(x: f64): f64 {
  unsafe { return math_log1p_impl(x); }
}

#[no_mangle]
export function math_expm1_c(x: f64): f64 {
  unsafe { return math_expm1_impl(x); }
}

// === fenv public API wrappers ===

#[no_mangle]
export function math_fenv_mask_to_fe(mask: i32): i32 {
  unsafe { return math_fenv_mask_to_fe_impl(mask); }
}

#[no_mangle]
export function math_fenv_fe_to_mask(fe: i32): i32 {
  unsafe { return math_fenv_fe_to_mask_impl(fe); }
}

#[no_mangle]
export function math_fenv_emit_cap_report(avail: i32): void {
  unsafe { math_fenv_emit_cap_report_impl(avail); }
}

// === fenv public API functions (call rest _impl via C bridge) ===

export extern "C" function math_fenv_available_impl_c(): i32;
export extern "C" function math_fenv_test_impl_c(mask: i32): i32;
export extern "C" function math_fenv_clear_impl_c(mask: i32): i32;
export extern "C" function math_fenv_raise_impl_c(mask: i32): i32;
export extern "C" function math_fenv_smoke_impl_c(): i32;
export extern "C" function math_fenv_capability_smoke_impl_c(): i32;

#[no_mangle]
export function math_fenv_available_c(): i32 {
  unsafe { return math_fenv_available_impl_c(); }
}

#[no_mangle]
export function math_fenv_test_c(mask: i32): i32 {
  unsafe { return math_fenv_test_impl_c(mask); }
}

#[no_mangle]
export function math_fenv_clear_c(mask: i32): i32 {
  unsafe { return math_fenv_clear_impl_c(mask); }
}

#[no_mangle]
export function math_fenv_raise_c(mask: i32): i32 {
  unsafe { return math_fenv_raise_impl_c(mask); }
}

#[no_mangle]
export function math_fenv_smoke_c(): i32 {
  unsafe { return math_fenv_smoke_impl_c(); }
}

#[no_mangle]
export function math_fenv_capability_smoke_c(): i32 {
  unsafe { return math_fenv_capability_smoke_impl_c(); }
}
