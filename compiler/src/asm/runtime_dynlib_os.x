// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_dynlib_os.x — R2 full mode public API for dynlib OS glue.
// Provides #[no_mangle] wrappers that delegate to C _impl OS bridges.
// Platform-specific logic (#ifdef _WIN32 / POSIX) lives in _impl functions
// in seeds/runtime_dynlib_os.from_x.c.

/** Doc anchor for xlang tooling. */
export function runtime_dynlib_os_x_doc_anchor(): i32 {
  return 0;
}

// OS bridge declarations (implemented in seeds/runtime_dynlib_os.from_x.c).

extern "C" function dynlib_win_load_library_w_utf8_impl(path: *u8): *u8;

extern "C" function dynlib_os_copy_last_error_impl(buf: *u8, cap: i32): i32;

extern "C" function dynlib_os_open_impl(path: *u8): *u8;

extern "C" function dynlib_os_sym_impl(lib: *u8, name: *u8): *u8;

extern "C" function dynlib_os_close_impl(lib: *u8): void;

extern "C" function dynlib_os_win_path_smoke_impl(): i32;

// --- Public API wrappers (#[no_mangle] for C ABI compatibility) ---

/** Normalize path separators: forward slash '/' to backslash '\\'.
 *  Pure computation, no OS call; implemented directly in Xlang.
 *  @param out output buffer (NUL-terminated on return)
 *  @param out_cap capacity in bytes (must be >= 2)
 *  @param path input UTF-8 path
 *  @return number of bytes written (excluding NUL), or 0 on invalid input
 */
#[no_mangle]
export function dynlib_win_normalize_path(out: *u8, out_cap: i32, path: *u8): i32 {
  if (out == 0) { return 0; }
  if (out_cap < 2) { return 0; }
  if (path == 0) { return 0; }
  let i: i32 = 0;
  while (path[i] != 0) {
    if (i + 1 >= out_cap) { break; }
    let c: u8 = path[i];
    if (c == 47) { c = 92; }
    out[i] = c;
    i = i + 1;
  }
  out[i] = 0;
  return i;
}

/** Open dynamic library with UTF-8 path (Windows: LoadLibraryW fallback).
 *  @param path UTF-8 path (NUL-terminated)
 *  @return library handle, or NULL on failure
 */
#[no_mangle]
export function dynlib_win_load_library_w_utf8(path: *u8): *u8 {
  unsafe { return dynlib_win_load_library_w_utf8_impl(path); }
}

/** Copy last OS error message into buffer.
 *  @param out output buffer
 *  @param cap buffer capacity
 *  @return bytes written (excluding NUL), or 0 if no error
 */
#[no_mangle]
export function dynlib_os_copy_last_error_c(out: *u8, cap: i32): i32 {
  unsafe { return dynlib_os_copy_last_error_impl(out, cap); }
}

/** Open dynamic library at path.
 *  @param path NUL-terminated UTF-8 path
 *  @return library handle, or NULL on failure
 */
#[no_mangle]
export function dynlib_os_open_c(path: *u8): *u8 {
  unsafe { return dynlib_os_open_impl(path); }
}

/** Look up symbol in dynamic library.
 *  @param lib library handle
 *  @param name NUL-terminated symbol name
 *  @return symbol address, or NULL on failure
 */
#[no_mangle]
export function dynlib_os_sym_c(lib: *u8, name: *u8): *u8 {
  unsafe { return dynlib_os_sym_impl(lib, name); }
}

/** Close dynamic library handle.
 *  @param lib library handle (NULL is a no-op)
 */
#[no_mangle]
export function dynlib_os_close_c(lib: *u8): void {
  unsafe { dynlib_os_close_impl(lib); }
}

/** Windows-only smoke test: verify LoadLibraryW with forward-slash path.
 *  @return 0 on success, negative on failure
 */
#[no_mangle]
export function dynlib_os_win_path_smoke_c(): i32 {
  unsafe { return dynlib_os_win_path_smoke_impl(); }
}
