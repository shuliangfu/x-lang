// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_dynlib_os_darwin.x — Darwin half of runtime_dynlib_os.o that
// calls dlopen, dlsym, and dlclose. Loops live in
// runtime_dynlib_os_darwin_text.x. This compiler exits 139 when one
// translation unit both contains a while and calls dlopen, so this file
// has no loop. ensure joins the two objects with ld -r.
//
// Linux still host-cc's seeds/runtime_dynlib_os.from_x.c. Windows still
// host-cc's that seed (LoadLibrary). Darwin's cold path does not.
// The shared thin src/asm/runtime_dynlib_os.x is not compiled here.
//
// Open uses dlopen with RTLD_NOW. On this Darwin that flag is 2.
// A null or empty path returns null and does not call dlopen.
// A null handle or a null name returns null from dlsym.
// Close ignores dlclose's result. A null handle is a no-op.
// The Windows path smoke returns 0.
//
// Public _c names call the _impl in this file. Both stay strong.
// A function name is never passed as a pointer.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * libSystem dlopen. mode 2 is RTLD_NOW on Darwin arm64.
 * @param path *u8 — NUL-terminated library path
 * @param mode i32 — dlopen flags
 * @return *u8 — handle, or null
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function dlopen(path: *u8, mode: i32): *u8;

/**
 * libSystem dlsym.
 * @param handle *u8 — handle from dlopen
 * @param name *u8 — NUL-terminated symbol name
 * @return *u8 — symbol address, or null
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function dlsym(handle: *u8, name: *u8): *u8;

/**
 * libSystem dlclose. Callers ignore the result, as the C seed does.
 * @param handle *u8 — handle from dlopen
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function dlclose(handle: *u8): i32;

/**
 * Open a dynamic library. A null or empty path returns null.
 * @param path *u8 — NUL-terminated path
 * @return *u8 — handle, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_os_open_impl(path: *u8): *u8 {
  if (path == 0) { return 0; }
  if (path[0] == (0 as u8)) { return 0; }
  unsafe { return dlopen(path, 2); }
}

/**
 * Public wrapper for dlopen.
 * @param path *u8 — NUL-terminated path
 * @return *u8 — handle, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_os_open_c(path: *u8): *u8 {
  return dynlib_os_open_impl(path);
}

/**
 * Look up a symbol. A null handle or a null name returns null.
 * @param lib *u8 — handle from dynlib_os_open_c
 * @param name *u8 — NUL-terminated symbol name
 * @return *u8 — symbol address, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_os_sym_impl(lib: *u8, name: *u8): *u8 {
  if (lib == 0) { return 0; }
  if (name == 0) { return 0; }
  unsafe { return dlsym(lib, name); }
}

/**
 * Public wrapper for dlsym.
 * @param lib *u8 — library handle
 * @param name *u8 — symbol name
 * @return *u8 — symbol address, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_os_sym_c(lib: *u8, name: *u8): *u8 {
  return dynlib_os_sym_impl(lib, name);
}

/**
 * Close a library handle. Null is a no-op. The dlclose result is dropped.
 * @param lib *u8 — handle, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_os_close_impl(lib: *u8): void {
  if (lib == 0) { return; }
  unsafe {
    let rc: i32 = dlclose(lib);
    if (rc < 0) { return; }
  }
}

/**
 * Public wrapper for dlclose.
 * @param lib *u8 — handle, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_os_close_c(lib: *u8): void {
  dynlib_os_close_impl(lib);
}

/**
 * Windows path smoke. Non-Windows returns 0 without loading a library.
 * @return i32 — 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_os_win_path_smoke_impl(): i32 {
  return 0;
}

/**
 * Public wrapper for the Windows path smoke.
 * @return i32 — 0 on Darwin
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function dynlib_os_win_path_smoke_c(): i32 {
  return dynlib_os_win_path_smoke_impl();
}
