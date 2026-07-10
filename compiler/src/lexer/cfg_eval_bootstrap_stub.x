// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-80：cfg_eval_bootstrap_stub 产品源迁 seeds/cfg_eval_bootstrap_stub.from_x.c。
// G-02f-101：+ triple_contains_ci / lit_eq_ci。
// G-02f-103：+ parse_triple_literals 薄门闩。
// G-02f-112：+ cfg_eval_expr 薄门闩。
// G-02f-151：cfg_triple_contains_ci / cfg_lit_eq_ci 真迁 .x

extern "C" function cfg_parse_triple_literals_impl(triple: *u8, len: i32, os_out: *u8, os_sz: usize,
                                                   arch_out: *u8, arch_sz: usize): void;
extern "C" function cfg_eval_expr_impl(s: *u8): i32;

function cfg_eval_bootstrap_stub_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-151：cfg string pure helpers ---- */

function cfg_ascii_tolower(ch: u8): u8 {
  // 'A'=65 .. 'Z'=90 → +32
  if (ch >= 65) {
    if (ch <= 90) {
      return (ch + 32) as u8;
    }
  }
  return ch;
}

// G-02f-151：triple 子串忽略大小写匹配
#[no_mangle]
function cfg_triple_contains_ci(triple: *u8, len: i32, needle: *u8): i32 {
  if (triple == 0) { return 0; }
  if (len <= 0) { return 0; }
  if (needle == 0) { return 0; }
  let nlen: i32 = 0;
  while (nlen < 256) {
    if (needle[nlen] == 0) { break; }
    nlen = nlen + 1;
  }
  if (nlen == 0) { return 0; }
  if (len < nlen) { return 0; }
  let i: i32 = 0;
  while (i + nlen <= len) {
    let j: i32 = 0;
    let ok: i32 = 1;
    while (j < nlen) {
      let a: u8 = cfg_ascii_tolower(triple[i + j]);
      let b: u8 = cfg_ascii_tolower(needle[j]);
      if (a != b) {
        ok = 0;
        break;
      }
      j = j + 1;
    }
    if (ok != 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

// G-02f-151：忽略大小写比较 [a, a+alen) 与 C 字符串 b
#[no_mangle]
function cfg_lit_eq_ci(a: *u8, alen: usize, b: *u8): i32 {
  if (a == 0) { return 0; }
  if (b == 0) { return 0; }
  let blen: usize = 0;
  while (blen < 256) {
    if (b[blen as i32] == 0) { break; }
    blen = blen + 1;
  }
  if (alen != blen) { return 0; }
  let i: usize = 0;
  while (i < alen) {
    let ca: u8 = cfg_ascii_tolower(a[i as i32]);
    let cb: u8 = cfg_ascii_tolower(b[i as i32]);
    if (ca != cb) { return 0; }
    i = i + 1;
  }
  return 1;
}

/* ---- G-02f-103：triple parse 门闩 ---- */

#[no_mangle]
function cfg_parse_triple_literals(triple: *u8, len: i32, os_out: *u8, os_sz: usize, arch_out: *u8,
                                   arch_sz: usize): void {
  unsafe {
    cfg_parse_triple_literals_impl(triple, len, os_out, os_sz, arch_out, arch_sz);
  }
}

/* ---- G-02f-112：cfg_eval_expr 门闩 ---- */

#[no_mangle]
function cfg_eval_expr(s: *u8): i32 {
  unsafe { return cfg_eval_expr_impl(s); }
  return 0;
}
