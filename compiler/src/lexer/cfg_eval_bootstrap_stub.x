// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-80：cfg_eval_bootstrap_stub 产品源迁 seeds/cfg_eval_bootstrap_stub.from_x.c。
// G-02f-101：+ triple_contains_ci / lit_eq_ci。
// G-02f-103 / G-02f-152：parse_triple_literals 真迁 .x。
// G-02f-112：+ cfg_eval_expr 薄门闩。
// G-02f-151：cfg_triple_contains_ci / cfg_lit_eq_ci 真迁 .x

extern "C" function cfg_eval_expr_impl(s: *u8): i32;
extern "C" function cfg_host_os_lit(): *u8;
extern "C" function cfg_host_arch_lit(): *u8;

function cfg_eval_bootstrap_stub_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-151：cfg string pure helpers ---- */

function cfg_ascii_tolower(ch: u8): u8 {
  if (ch >= 65) {
    if (ch <= 90) {
      return (ch + 32) as u8;
    }
  }
  return ch;
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
function cfg_parse_triple_literals(triple: *u8, len: i32, os_out: *u8, os_sz: usize, arch_out: *u8,
                                   arch_sz: usize): void {
  if (os_out == 0) { return; }
  if (os_sz == 0) { return; }
  if (arch_out == 0) { return; }
  if (arch_sz == 0) { return; }
  unsafe {
    let host_os: *u8 = cfg_host_os_lit();
    let host_arch: *u8 = cfg_host_arch_lit();
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
    if (cfg_triple_contains_ci(triple, len, &n_linux[0]) != 0) {
      cfg_cstr_copy(os_out, os_sz, &n_linux[0]);
    } else {
      if (cfg_triple_contains_ci(triple, len, &n_darwin[0]) != 0) {
        cfg_cstr_copy(os_out, os_sz, &n_macos[0]);
      } else {
        if (cfg_triple_contains_ci(triple, len, &n_macos[0]) != 0) {
          cfg_cstr_copy(os_out, os_sz, &n_macos[0]);
        } else {
          if (cfg_triple_contains_ci(triple, len, &n_freebsd[0]) != 0) {
            cfg_cstr_copy(os_out, os_sz, &n_freebsd[0]);
          } else {
            if (cfg_triple_contains_ci(triple, len, &n_windows[0]) != 0) {
              cfg_cstr_copy(os_out, os_sz, &n_windows[0]);
            } else {
              if (cfg_triple_contains_ci(triple, len, &n_win32[0]) != 0) {
                cfg_cstr_copy(os_out, os_sz, &n_windows[0]);
              }
            }
          }
        }
      }
    }
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
    if (cfg_triple_contains_ci(triple, len, &n_aarch64[0]) != 0) {
      cfg_cstr_copy(arch_out, arch_sz, &n_aarch64[0]);
    } else {
      if (cfg_triple_contains_ci(triple, len, &n_arm64[0]) != 0) {
        cfg_cstr_copy(arch_out, arch_sz, &n_aarch64[0]);
      } else {
        if (cfg_triple_contains_ci(triple, len, &n_x86_64[0]) != 0) {
          cfg_cstr_copy(arch_out, arch_sz, &n_x86_64[0]);
        } else {
          if (cfg_triple_contains_ci(triple, len, &n_amd64[0]) != 0) {
            cfg_cstr_copy(arch_out, arch_sz, &n_x86_64[0]);
          } else {
            if (cfg_triple_contains_ci(triple, len, &n_riscv64[0]) != 0) {
              cfg_cstr_copy(arch_out, arch_sz, &n_riscv64[0]);
            }
          }
        }
      }
    }
  }
}

/* ---- G-02f-112：cfg_eval_expr 门闩 ---- */

#[no_mangle]
function cfg_eval_expr(s: *u8): i32 {
  unsafe { return cfg_eval_expr_impl(s); }
  return 0;
}
