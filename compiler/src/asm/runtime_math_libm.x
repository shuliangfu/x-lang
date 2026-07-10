// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-19：runtime_math_libm 产品源迁 seeds/runtime_math_libm.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_math_libm.from_x.c → runtime_math_libm.o
// G-02f-100：+ special_near / fenv mask/report 薄门闩。

extern "C" function math_special_near_impl(a: f64, b: f64, eps: f64): i32;
extern "C" function math_fenv_mask_to_fe_impl(mask: i32): i32;
extern "C" function math_fenv_fe_to_mask_impl(fe: i32): i32;
extern "C" function math_fenv_emit_cap_report_impl(avail: i32): void;

function runtime_math_libm_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-100：math helper 门闩 ---- */

#[no_mangle]
function math_special_near(a: f64, b: f64, eps: f64): i32 {
  unsafe {
    return math_special_near_impl(a, b, eps);
  }
  return 0;
}

#[no_mangle]
function math_fenv_mask_to_fe(mask: i32): i32 {
  unsafe {
    return math_fenv_mask_to_fe_impl(mask);
  }
  return 0;
}

#[no_mangle]
function math_fenv_fe_to_mask(fe: i32): i32 {
  unsafe {
    return math_fenv_fe_to_mask_impl(fe);
  }
  return 0;
}

#[no_mangle]
function math_fenv_emit_cap_report(avail: i32): void {
  unsafe {
    math_fenv_emit_cap_report_impl(avail);
  }
}
