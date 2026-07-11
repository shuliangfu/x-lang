// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-80：cfg_eval_bootstrap_stub 产品源迁 seeds/cfg_eval_bootstrap_stub.from_x.c。
// G-02f-101：+ triple_contains_ci / lit_eq_ci。
// G-02f-103 / G-02f-152：parse_triple_literals 真迁 .x。
// G-02f-112：+ cfg_eval_expr 薄门闩。
// G-02f-151：cfg_triple_contains_ci / cfg_lit_eq_ci 真迁 .x
// G-02f-153：cfg_eval_expr 真迁 .x（effective_os/arch + freestanding 导出）
// G-02f-182：与 cfg_eval.x 语义对齐审计 — 见优先级表 §4.4（冷启动 fallback）。

extern "C" function cfg_host_os_lit(): *u8;
extern "C" function cfg_host_arch_lit(): *u8;

function cfg_eval_bootstrap_stub_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-151：cfg string pure helpers ---- */

function cfg_ascii_tolower(ch: u8): u8 {
  if (ch < 65) { return ch; }
  if (ch > 90) { return ch; }
  return (ch + 32) as u8;
}

function cfg_cstr_copy(dst: *u8, cap: usize, src: *u8): void {
  if (dst == 0) { return; }
  if (cap == 0) { return; }
  if (src == 0) {
    dst[0] = 0;
    return;
  }
  let i: usize = 0;
  let lim: usize = cap - 1;
  while (i < lim) {
    let ch: u8 = src[i as i32];
    if (ch == 0) { break; }
    dst[i as i32] = ch;
    i = i + 1;
  }
  dst[i as i32] = 0;
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

// G-02f-152：-target triple → os/arch；回退 host
#[no_mangle]
function cfg_get_host_os_safe(): *u8 {
  unsafe { return cfg_host_os_lit(); }
  return 0 as *u8;
}

function cfg_get_host_arch_safe(): *u8 {
  unsafe { return cfg_host_arch_lit(); }
  return 0 as *u8;
}

function cfg_parse_triple_literals(triple: *u8, len: i32, os_out: *u8, os_sz: usize, arch_out: *u8,
                                   arch_sz: usize): void {
  if (os_out == 0) { return; }
  if (os_sz == 0) { return; }
  if (arch_out == 0) { return; }
  if (arch_sz == 0) { return; }
  let host_os: *u8 = cfg_get_host_os_safe();
  let host_arch: *u8 = cfg_get_host_arch_safe();
  cfg_cstr_copy(os_out, os_sz, host_os);
  cfg_cstr_copy(arch_out, arch_sz, host_arch);
  if (triple == 0) { return; }
  if (len <= 0) { return; }
    // os needles as local C strings
    let n_linux: u8[8] = [];
    n_linux[0] = 108; n_linux[1] = 105; n_linux[2] = 110; n_linux[3] = 117; n_linux[4] = 120; n_linux[5] = 0;
    let n_darwin: u8[8] = [];
    n_darwin[0] = 100; n_darwin[1] = 97; n_darwin[2] = 114; n_darwin[3] = 119; n_darwin[4] = 105; n_darwin[5] = 110; n_darwin[6] = 0;
    let n_macos: u8[8] = [];
    n_macos[0] = 109; n_macos[1] = 97; n_macos[2] = 99; n_macos[3] = 111; n_macos[4] = 115; n_macos[5] = 0;
    let n_freebsd: u8[8] = [];
    n_freebsd[0] = 102; n_freebsd[1] = 114; n_freebsd[2] = 101; n_freebsd[3] = 101; n_freebsd[4] = 98; n_freebsd[5] = 115; n_freebsd[6] = 100; n_freebsd[7] = 0;
    let n_windows: u8[8] = [];
    n_windows[0] = 119; n_windows[1] = 105; n_windows[2] = 110; n_windows[3] = 100; n_windows[4] = 111; n_windows[5] = 119; n_windows[6] = 115; n_windows[7] = 0;
    let n_win32: u8[8] = [];
    n_win32[0] = 119; n_win32[1] = 105; n_win32[2] = 110; n_win32[3] = 51; n_win32[4] = 50; n_win32[5] = 0;
    let os_found: i32 = 0;
    os_found = cfg_triple_set_os(triple, len, &n_linux[0], os_out, os_sz, &n_linux[0]);
    if (os_found == 0) { os_found = cfg_triple_set_os(triple, len, &n_darwin[0], os_out, os_sz, &n_macos[0]); }
    if (os_found == 0) { os_found = cfg_triple_set_os(triple, len, &n_macos[0], os_out, os_sz, &n_macos[0]); }
    if (os_found == 0) { os_found = cfg_triple_set_os(triple, len, &n_freebsd[0], os_out, os_sz, &n_freebsd[0]); }
    if (os_found == 0) { os_found = cfg_triple_set_os(triple, len, &n_windows[0], os_out, os_sz, &n_windows[0]); }
    if (os_found == 0) { os_found = cfg_triple_set_os(triple, len, &n_win32[0], os_out, os_sz, &n_windows[0]); }
    let n_aarch64: u8[16] = [];
    n_aarch64[0] = 97; n_aarch64[1] = 97; n_aarch64[2] = 114; n_aarch64[3] = 99; n_aarch64[4] = 104;
    n_aarch64[5] = 54; n_aarch64[6] = 52; n_aarch64[7] = 0;
    let n_arm64: u8[8] = [];
    n_arm64[0] = 97; n_arm64[1] = 114; n_arm64[2] = 109; n_arm64[3] = 54; n_arm64[4] = 52; n_arm64[5] = 0;
    let n_x86_64: u8[8] = [];
    n_x86_64[0] = 120; n_x86_64[1] = 56; n_x86_64[2] = 54; n_x86_64[3] = 95; n_x86_64[4] = 54; n_x86_64[5] = 52; n_x86_64[6] = 0;
    let n_amd64: u8[8] = [];
    n_amd64[0] = 97; n_amd64[1] = 109; n_amd64[2] = 100; n_amd64[3] = 54; n_amd64[4] = 52; n_amd64[5] = 0;
    let n_riscv64: u8[16] = [];
    n_riscv64[0] = 114; n_riscv64[1] = 105; n_riscv64[2] = 115; n_riscv64[3] = 99; n_riscv64[4] = 118;
    n_riscv64[5] = 54; n_riscv64[6] = 52; n_riscv64[7] = 0;
    let arch_found: i32 = 0;
    arch_found = cfg_triple_set_arch(triple, len, &n_aarch64[0], arch_out, arch_sz, &n_aarch64[0]);
    if (arch_found == 0) { arch_found = cfg_triple_set_arch(triple, len, &n_arm64[0], arch_out, arch_sz, &n_aarch64[0]); }
    if (arch_found == 0) { arch_found = cfg_triple_set_arch(triple, len, &n_x86_64[0], arch_out, arch_sz, &n_x86_64[0]); }
    if (arch_found == 0) { arch_found = cfg_triple_set_arch(triple, len, &n_amd64[0], arch_out, arch_sz, &n_x86_64[0]); }
    if (arch_found == 0) { arch_found = cfg_triple_set_arch(triple, len, &n_riscv64[0], arch_out, arch_sz, &n_riscv64[0]); }
  }

/* ---- G-02f-112 / G-02f-153：cfg_eval_expr 真迁 ---- */

extern "C" function cfg_effective_os_lit(): *u8;
extern "C" function cfg_effective_arch_lit(): *u8;
extern "C" function cfg_get_freestanding(): i32;

function cfg_skip_ws_range(buf: *u8, b: i32, end: i32): i32 {
  let p: i32 = b;
  while (p < end) {
    let c: u8 = buf[p];
    // space tab nl cr
    if (c == 32) { p = p + 1; continue; }
    if (c == 9) { p = p + 1; continue; }
    if (c == 10) { p = p + 1; continue; }
    if (c == 13) { p = p + 1; continue; }
    break;
  }
  return p;
}

function cfg_prefix4(buf: *u8, p: i32, end: i32, c0: u8, c1: u8, c2: u8, c3: u8): i32 {
  if (p + 4 > end) { return 0; }
  if (buf[p] != c0) { return 0; }
  if (buf[p + 1] != c1) { return 0; }
  if (buf[p + 2] != c2) { return 0; }
  if (buf[p + 3] != c3) { return 0; }
  return 1;
}

// G-02f-153：递归求值 buf[b..end)
/** If needle found in triple, copy result to os_out. Returns 1 if found. */
function cfg_triple_set_os(triple: *u8, len: i32, needle: *u8, os_out: *u8, os_sz: usize, result: *u8): i32 {
  if (cfg_triple_contains_ci(triple, len, needle) != 0) { cfg_cstr_copy(os_out, os_sz, result); return 1; }
  return 0;
}

/** If needle found in triple, copy result to arch_out. Returns 1 if found. */
function cfg_triple_set_arch(triple: *u8, len: i32, needle: *u8, arch_out: *u8, arch_sz: usize, result: *u8): i32 {
  if (cfg_triple_contains_ci(triple, len, needle) != 0) { cfg_cstr_copy(arch_out, arch_sz, result); return 1; }
  return 0;
}

function cfg_get_effective_os_safe(): *u8 {
  unsafe { return cfg_effective_os_lit(); }
  return 0 as *u8;
}

function cfg_get_effective_arch_safe(): *u8 {
  unsafe { return cfg_effective_arch_lit(); }
  return 0 as *u8;
}

function cfg_get_freestanding_safe(): i32 {
  unsafe { return cfg_get_freestanding(); }
  return 0;
}

/** Returns 1 if char is comma at depth 0 (should break). */
function cfg_match_target_os(buf: *u8, p: i32, end: i32): i32 {
  if (p + 9 > end) { return 0; }
  if (buf[p] != 116) { return 0; }
  if (buf[p+1] != 97) { return 0; }
  if (buf[p+2] != 114) { return 0; }
  if (buf[p+3] != 103) { return 0; }
  if (buf[p+4] != 101) { return 0; }
  if (buf[p+5] != 116) { return 0; }
  if (buf[p+6] != 95) { return 0; }
  if (buf[p+7] != 111) { return 0; }
  if (buf[p+8] != 115) { return 0; }
  return 1;
}

function cfg_match_target_arch(buf: *u8, p: i32, end: i32): i32 {
  if (p + 11 > end) { return 0; }
  if (buf[p] != 116) { return 0; }
  if (buf[p+1] != 97) { return 0; }
  if (buf[p+2] != 114) { return 0; }
  if (buf[p+3] != 103) { return 0; }
  if (buf[p+4] != 101) { return 0; }
  if (buf[p+5] != 116) { return 0; }
  if (buf[p+6] != 95) { return 0; }
  if (buf[p+7] != 97) { return 0; }
  if (buf[p+8] != 114) { return 0; }
  if (buf[p+9] != 99) { return 0; }
  if (buf[p+10] != 104) { return 0; }
  return 1;
}

function cfg_comma_at_depth0(c: u8, depth: i32): i32 {
  if (c != 44) { return 0; }
  if (depth != 0) { return 0; }
  return 1;
}

/** Returns: -1=not rparen, 0=rparen depth>0, 1=rparen depth==0 (break). */
function cfg_rparen_check(c: u8, depth: i32): i32 {
  if (c != 41) { return -1; }
  if (depth == 0) { return 1; }
  return 0;
}

function cfg_is_upper(c: u8): i32 {
  if (c < 65) { return 0; }
  if (c > 90) { return 0; }
  return 1;
}

function cfg_is_lower(c: u8): i32 {
  if (c < 97) { return 0; }
  if (c > 122) { return 0; }
  return 1;
}

function cfg_is_digit(c: u8): i32 {
  if (c < 48) { return 0; }
  if (c > 57) { return 0; }
  return 1;
}

function cfg_is_ident_char(c: u8): i32 {
  if (cfg_is_upper(c) != 0) { return 1; }
  if (cfg_is_lower(c) != 0) { return 1; }
  if (cfg_is_digit(c) != 0) { return 1; }
  if (c == 95) { return 1; }
  return 0;
}

/** Check if buf[p] == c with bounds check (no nested if for -E parser). */
function cfg_buf_eq_at(buf: *u8, p: i32, end: i32, c: u8): i32 {
  if (p >= end) { return 0; }
  if (buf[p] == c) { return 1; }
  return 0;
}

/** Parse target_os = "..." value. Returns 1=match, 0=no match. */
function cfg_parse_target_os_value(buf: *u8, p: i32, end: i32): i32 {
  p = p + 9;
  p = cfg_skip_ws_range(buf, p, end);
  if (p >= end) { return 0; }
  if (buf[p] != 61) { return 0; }
  p = p + 1;
  if (cfg_buf_eq_at(buf, p, end, 61) != 0) { p = p + 1; }
  p = cfg_skip_ws_range(buf, p, end);
  if (p >= end) { return 0; }
  if (buf[p] != 34) { return 0; }
  p = p + 1;
  let lit: i32 = p;
  while (p < end) {
    if (buf[p] == 34) { break; }
    p = p + 1;
  }
  let os: *u8 = cfg_get_effective_os_safe();
  let alen: usize = (p - lit) as usize;
  return cfg_lit_eq_ci(&buf[lit], alen, os);
}

/** Parse target_arch = "..." value. Returns 1=match, 0=no match. */
function cfg_parse_target_arch_value(buf: *u8, p: i32, end: i32): i32 {
  p = p + 11;
  p = cfg_skip_ws_range(buf, p, end);
  if (p >= end) { return 0; }
  if (buf[p] != 61) { return 0; }
  p = p + 1;
  if (cfg_buf_eq_at(buf, p, end, 61) != 0) { p = p + 1; }
  p = cfg_skip_ws_range(buf, p, end);
  if (p >= end) { return 0; }
  if (buf[p] != 34) { return 0; }
  p = p + 1;
  let lit: i32 = p;
  while (p < end) {
    if (buf[p] == 34) { break; }
    p = p + 1;
  }
  let arch: *u8 = cfg_get_effective_arch_safe();
  let alen: usize = (p - lit) as usize;
  return cfg_lit_eq_ci(&buf[lit], alen, arch);
}

function cfg_eval_expr_range(buf: *u8, b: i32, end: i32): i32 {
  if (buf == 0) { return 0; }
  let p: i32 = cfg_skip_ws_range(buf, b, end);
  if (p >= end) { return 0; }
  // all(
  if (cfg_prefix4(buf, p, end, 97, 108, 108, 40) != 0) {
    p = p + 4;
    while (p < end) {
      p = cfg_skip_ws_range(buf, p, end);
      // also skip commas
      while (p < end) {
        let c: u8 = buf[p];
        if (c == 32) { p = p + 1; continue; }
        if (c == 9) { p = p + 1; continue; }
        if (c == 44) { p = p + 1; continue; }
        if (c == 10) { p = p + 1; continue; }
        if (c == 13) { p = p + 1; continue; }
        break;
      }
      if (p >= end) { break; }
      if (buf[p] == 41) { return 1; }
      let part: i32 = p;
      let depth: i32 = 0;
      while (p < end) {
        if (buf[p] == 40) { depth = depth + 1; p = p + 1; continue; }
        let rp: i32 = cfg_rparen_check(buf[p], depth);
        if (rp == 1) { break; }
        if (rp == 0) { depth = depth - 1; p = p + 1; continue; }
        if (cfg_comma_at_depth0(buf[p], depth) != 0) { break; }
        if (buf[p] == 44) { p = p + 1; continue; }
        p = p + 1;
      }
      if (cfg_eval_expr_range(buf, part, p) == 0) { return 0; }
      if (cfg_buf_eq_at(buf, p, end, 41) != 0) { return 1; }
    }
    return 1;
  }
  // not(
  if (cfg_prefix4(buf, p, end, 110, 111, 116, 40) != 0) {
    let inner: i32 = p + 4;
    let close: i32 = inner;
    let depth: i32 = 1;
    while (close < end) {
      if (depth <= 0) { break; }
      if (buf[close] == 40) {
        depth = depth + 1;
      }
      if (buf[close] == 41) {
        depth = depth - 1;
      }
      if (depth > 0) {
        close = close + 1;
      }
    }
    if (cfg_eval_expr_range(buf, inner, close) != 0) { return 0; }
    return 1;
  }
  // target_os
  if (cfg_match_target_os(buf, p, end) != 0) {
    return cfg_parse_target_os_value(buf, p, end);
  }
  // target_arch
  if (cfg_match_target_arch(buf, p, end) != 0) {
    return cfg_parse_target_arch_value(buf, p, end);
  }
  // freestanding bare flag
  let q: i32 = p;
    while (q < end) {
      let c: u8 = buf[q];
      if (cfg_is_ident_char(c) != 0) { q = q + 1; continue; }
      break;
    }
    let n_fs: u8[16] = [];
    n_fs[0]=102;n_fs[1]=114;n_fs[2]=101;n_fs[3]=101;n_fs[4]=115;n_fs[5]=116;
    n_fs[6]=97;n_fs[7]=110;n_fs[8]=100;n_fs[9]=105;n_fs[10]=110;n_fs[11]=103;n_fs[12]=0;
    let alen3: usize = (q - p) as usize;
    if (cfg_lit_eq_ci(&buf[p], alen3, &n_fs[0]) != 0) {
      return cfg_get_freestanding_safe();
    }
  return 0;
}

// start/end 指针 API：用下标差求值
#[no_mangle]
function cfg_eval_expr(start: *u8, end: *u8): i32 {
  if (start == 0) { return 0; }
  if (end == 0) { return 0; }
  // compute len via scan (end - start) without pointer sub if needed - use byte walk
  let len: i32 = 0;
  let p: *u8 = start;
  while (1 == 1) {
    if (p == end) { break; }
    if (len > 65536) { break; }
    p = p + 1;
    len = len + 1;
  }
  return cfg_eval_expr_range(start, 0, len);
}

#[no_mangle]
function cfg_eval_expr_c(start: *u8, len: i32): i32 {
  if (start == 0) { return 0; }
  if (len <= 0) { return 0; }
  return cfg_eval_expr_range(start, 0, len);
}
