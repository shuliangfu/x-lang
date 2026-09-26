// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Lib root pointer usability + default root + from_key; G.9 English; body authoritative.
// w1134: default-root copy is the one while. from_key walks rows by recursion.
// Two whiles in one translation unit do not emit. The slice marker stays in the C rest.

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
  // Copy the parameter before the subscript. A parameter index reads one extra level.
  let q: *u8 = p;
  if (q[0] == 0) {
    return 0;
  }
  return 1;
}

/**
 * Copy a NUL-terminated env value into dst. Cap is 511 bytes plus a NUL.
 * Params: src — source bytes; dst — destination, capacity >= 512.
 * Returns: 1 when a NUL was copied, 0 when the cap NUL was written at index 511.
 * The index is a loop local. A second while in this file does not emit.
 */
function rt_lib_root_copy_env(src: *u8, dst: *u8): i32 {
  let s: *u8 = src;
  let d: *u8 = dst;
  let i: i32 = 0;
  while (i < 511) {
    let k: i32 = i;
    let c: u8 = s[k];
    d[k] = c;
    if (c == 0) {
      return 1;
    }
    i = i + 1;
  }
  d[511] = 0;
  return 0;
}

/**
 * Address of byte n in p.
 * Params: p — base; n — byte offset.
 * Returns: p + n. Split out so the offset is stored before the address is taken.
 */
function rt_u8_at(p: *u8, n: i32): *u8 {
  let q: *u8 = p;
  let k: i32 = n;
  let r: *u8 = &q[k];
  return r;
}

/**
 * Store one byte at p[n].
 * Params: p — base; n — byte offset; v — byte value.
 * Returns: void.
 */
function rt_set_u8(p: *u8, n: i32, v: u8): void {
  let q: *u8 = rt_u8_at(p, n);
  q[0] = v;
}

/**
 * Write "." into a row.
 * Params: row — 512-byte row.
 * Returns: void.
 */
function rt_lib_root_write_dot(row: *u8): void {
  rt_set_u8(row, 0, 46);
  rt_set_u8(row, 1, 0);
}

/**
 * Copy llen bytes into a row and write the trailing NUL.
 * Params: lib_key — emit key; row — destination; i — row index; llen — byte count, already in 1..511.
 * Returns: void.
 */
function rt_lib_root_write_copy(lib_key: *u8, row: *u8, i: i32, llen: i32): void {
  unsafe {
    driver_emit_lib_root_copy(lib_key, i, row, 512);
  }
  rt_set_u8(row, llen, 0);
}

/**
 * Write one lib-root row and store its pointer in out_arr[i].
 * Params: lib_key — emit key; out_arr — pointer slots; bufs — flat row storage; i — row index.
 * Returns: void. A short length becomes ".".
 */
function rt_lib_root_one_row(lib_key: *u8, out_arr: **u8, bufs: *u8, i: i32): void {
  let base: i32 = i * 512;
  let row: *u8 = rt_u8_at(bufs, base);
  let llen: i32 = 0;
  unsafe {
    llen = driver_emit_lib_root_len(lib_key, i);
  }
  if (llen <= 0 || llen >= 512) {
    rt_lib_root_write_dot(row);
  } else {
    rt_lib_root_write_copy(lib_key, row, i, llen);
  }
  let idx: i32 = i;
  out_arr[idx] = row;
}

/**
 * Fill rows i..n-1. Each row is 512 bytes inside bufs.
 * Params: lib_key — emit key; out_arr — pointer slots; bufs — flat row storage;
 *   i — next row; n — row count, already clamped to 16.
 * Returns: n.
 */
function rt_lib_root_fill(lib_key: *u8, out_arr: **u8, bufs: *u8, i: i32, n: i32): i32 {
  if (i >= n) {
    return n;
  }
  rt_lib_root_one_row(lib_key, out_arr, bufs, i);
  let i2: i32 = i + 1;
  return rt_lib_root_fill(lib_key, out_arr, bufs, i2, n);
}

/**
 * Write default lib-root into root_buf: prefer XLANG_LIB when usable, else ".".
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
    def = link_abi_getenv("XLANG_LIB");
  }
  if (driver_lib_root_ptr_usable(def) == 0) {
    return;
  }
  rt_lib_root_copy_env(def, root_buf);
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
  return rt_lib_root_fill(lib_key, out_arr, bufs, 0, n);
}
