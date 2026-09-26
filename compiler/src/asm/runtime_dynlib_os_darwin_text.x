// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_dynlib_os_darwin_text.x — Darwin half of runtime_dynlib_os.o
// that contains loops. The other half is runtime_dynlib_os_darwin.x.
//
// This compiler exits 139 when one translation unit both contains a while
// and calls dlopen. The loops stay here. dlopen, dlsym, and dlclose stay
// in the other file. ensure joins the two objects with ld -r. Neither
// file is passed to host cc on the Darwin cold path.
//
// src/asm/runtime_dynlib_os.x is the shared thin. Darwin does not compile
// it, so dynlib_win_normalize_path is defined here with the same slash
// rewrite. This is the Darwin definition, not a second live one.
//
// Each function has one loop. Byte compares use `as u8`. A slot past the
// frame stores through the caller's saved return address.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Doc anchor so the merged object keeps a named root.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function runtime_dynlib_os_x_doc_anchor(): i32 {
  return 0;
}

/**
 * libSystem dlerror. One call consumes the pending error string.
 * @return *u8 — NUL-terminated message, or null
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function dlerror(): *u8;

/**
 * Rewrite '/' to '\\'. Same loop as dynlib_win_normalize_path in
 * runtime_dynlib_os.x. Darwin does not compile that thin.
 * @param out *u8 — destination, NUL-terminated on success
 * @param out_cap i32 — byte capacity; must be at least 2
 * @param path *u8 — source path, NUL-terminated
 * @return i32 — bytes written excluding NUL, or 0 when unusable
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_win_normalize_path(out: *u8, out_cap: i32, path: *u8): i32 {
  if (out == 0) { return 0; }
  if (out_cap < 2) { return 0; }
  if (path == 0) { return 0; }
  let i: i32 = 0;
  // One loop. Stop one byte early so the NUL fits.
  while (path[i] != (0 as u8)) {
    if (i + 1 >= out_cap) { break; }
    let c: u8 = path[i];
    if (c == (47 as u8)) { c = 92 as u8; }
    out[i] = c;
    i = i + 1;
  }
  out[i] = 0 as u8;
  return i;
}

/**
 * Windows LoadLibraryW bridge. Darwin has no such loader.
 * @param path *u8 — unused UTF-8 path; a null path also returns null
 * @return *u8 — always null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_win_load_library_w_utf8_impl(path: *u8): *u8 {
  if (path == 0) { return 0; }
  return 0;
}

/**
 * Public wrapper for the Windows loader bridge.
 * @param path *u8 — UTF-8 path
 * @return *u8 — null on Darwin
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_win_load_library_w_utf8(path: *u8): *u8 {
  return dynlib_win_load_library_w_utf8_impl(path);
}

/**
 * Copy dlerror into buf. Empty and missing errors return 0.
 * The copy keeps one byte for NUL and truncates to cap-1.
 * @param buf *u8 — destination
 * @param cap i32 — byte capacity
 * @return i32 — bytes written excluding NUL
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_os_copy_last_error_impl(buf: *u8, cap: i32): i32 {
  if (buf == 0) { return 0; }
  if (cap <= 0) { return 0; }
  buf[0] = 0 as u8;
  let e: *u8 = 0;
  unsafe { e = dlerror(); }
  if (e == 0) { return 0; }
  if (e[0] == (0 as u8)) { return 0; }
  let n: i32 = 0;
  let limit: i32 = cap - 1;
  // One loop. n is both the scan index and the written length.
  while (e[n] != (0 as u8)) {
    if (n >= limit) { break; }
    buf[n] = e[n];
    n = n + 1;
  }
  buf[n] = 0 as u8;
  return n;
}

/**
 * Public wrapper for the last-error copy.
 * @param buf *u8 — destination
 * @param cap i32 — byte capacity
 * @return i32 — bytes written excluding NUL
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_os_copy_last_error_c(buf: *u8, cap: i32): i32 {
  return dynlib_os_copy_last_error_impl(buf, cap);
}
