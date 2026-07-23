// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Lib root pointer usability + default root + from_key; G.9 English; body authoritative.
// Lib root pointer usability + default root + from_key; G.9 English; body authoritative.
// Lib root pointer usability + default root + from_key; G.9 English; body authoritative.

/* wave227 G.7: env lookup via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl. */
export extern "C" function link_abi_getenv(name: *u8): *u8;
export extern "C" function driver_emit_lib_root_count(state: *u8): i32;
export extern "C" function driver_emit_lib_root_len(state: *u8, i: i32): i32;
export extern "C" function driver_emit_lib_root_copy(state: *u8, i: i32, dst: *u8, cap: i32): void;

/** Exported function `driver_lib_root_ptr_usable`.
 * Implements `driver_lib_root_ptr_usable`.
 * @param p *u8
 * @return i32
 */
#[no_mangle]
export function driver_lib_root_ptr_usable(p: *u8): i32 {
  if (p == 0 as *u8) {
    return 0;
  }
  if (p[0] == 0) {
    return 0;
  }
  return 1;
}

/**
 * Write default lib-root into root_buf: prefer SHUX_LIB when usable, else ".".
 * @param root_buf *u8 — destination buffer; capacity >= 512; always NUL-terminated
 * @return void
 * wave227 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * PLATFORM: SHARED — process env; host residual only link_abi_getenv_impl.
 */
#[no_mangle]
export function driver_lib_root_default(root_buf: *u8): void {
  root_buf[0] = 46;
  root_buf[1] = 0;
  let def: *u8 = 0 as *u8;
  unsafe {
    def = link_abi_getenv("SHUX_LIB");
  }
  if (driver_lib_root_ptr_usable(def) == 0) {
    return;
  }
  let i: i32 = 0;
  while (i < 511) {
    let c: u8 = def[i];
    root_buf[i] = c;
    if (c == 0) {
      return;
    }
    i = i + 1;
  }
  root_buf[511] = 0;
}

/**
 * See signature and body for params/returns/contracts.
 * See signature and body for params/returns/contracts.
 */
#[no_mangle]
export function driver_lib_roots_from_key(lib_key: *u8, out_arr: **u8, bufs: *u8): i32 {
  let n: i32 = 0;
  unsafe {
    n = driver_emit_lib_root_count(lib_key);
  }
  if (n <= 0) {
    driver_lib_root_default(bufs);
    out_arr[0] = bufs;
    return 1;
  }
  if (n > 16) {
    n = 16;
  }
  let i: i32 = 0;
  while (i < n) {
    let base: i32 = i * 512;
    let row: *u8 = &bufs[base];
    let llen: i32 = 0;
    unsafe {
      llen = driver_emit_lib_root_len(lib_key, i);
    }
    if (llen <= 0 || llen >= 512) {
      row[0] = 46;
      row[1] = 0;
    } else {
      unsafe {
        driver_emit_lib_root_copy(lib_key, i, row, 512);
      }
      row[llen] = 0;
    }
    out_arr[i] = row;
    i = i + 1;
  }
  return n;
}
