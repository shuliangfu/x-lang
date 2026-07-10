// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-80：cfg_eval_bootstrap_stub 产品源迁 seeds/cfg_eval_bootstrap_stub.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-101：+ triple_contains_ci / lit_eq_ci 薄门闩。
// G-02f-103：+ parse_triple_literals 薄门闩。

extern "C" function cfg_triple_contains_ci_impl(triple: *u8, len: i32, needle: *u8): i32;
extern "C" function cfg_lit_eq_ci_impl(a: *u8, alen: usize, b: *u8): i32;
extern "C" function cfg_parse_triple_literals_impl(triple: *u8, len: i32, os_out: *u8, os_sz: usize,
                                                   arch_out: *u8, arch_sz: usize): void;

function cfg_eval_bootstrap_stub_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-101：cfg string helpers 门闩 ---- */

#[no_mangle]
function cfg_triple_contains_ci(triple: *u8, len: i32, needle: *u8): i32 {
  unsafe {
    return cfg_triple_contains_ci_impl(triple, len, needle);
  }
  return 0;
}

#[no_mangle]
function cfg_lit_eq_ci(a: *u8, alen: usize, b: *u8): i32 {
  unsafe {
    return cfg_lit_eq_ci_impl(a, alen, b);
  }
  return 0;
}

/* ---- G-02f-103：triple parse 门闩 ---- */

#[no_mangle]
function cfg_parse_triple_literals(triple: *u8, len: i32, os_out: *u8, os_sz: usize, arch_out: *u8,
                                   arch_sz: usize): void {
  unsafe {
    cfg_parse_triple_literals_impl(triple, len, os_out, os_sz, arch_out, arch_sz);
  }
}

// G-02f-112：+ cfg_eval_expr 薄门闩。

extern "C" function cfg_eval_expr_impl(s: *u8): i32;

/* ---- G-02f-112：cfg_eval_expr 门闩 ---- */

#[no_mangle]
function cfg_eval_expr(s: *u8): i32 {
  unsafe { return cfg_eval_expr_impl(s); }
  return 0;
}
