// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-270 / P2 link_abi L3: path liveness thin shell → R2 full.
// Product: PREFER_X_O → g05_try_x_to_o; cold-start seeds/labi_path_io.from_x.c.
// Hybrid macro SHUX_LABI_PATH_IO_FROM_X (FROM_X rest business H=0, marker only).
//
// R2 full: .x owns 3 public gates + count:
//   - shux_path_is_nonempty_regular_file → _impl (stat Cap residual mega rest)
//   - asm_link_obj_skip_missing: composes nonempty check
//   - shux_runtime_o_realpath_if_exists → _impl (realpath+skip Cap residual)
// No struct stat layout; no libc realpath prototype here (avoids *u8 vs char* clash).

export extern "C" function shux_path_is_nonempty_regular_file_impl(path: *u8): i32;
export extern "C" function shux_runtime_o_realpath_if_exists_impl(path: *u8, resolved: *u8): *u8;

/**
 * Return 1 iff path names a non-empty regular file (stat residual).
 * Params: path — NUL-terminated; null/empty → 0 without calling impl.
 * Returns: 1 if residual reports nonempty regular file, else 0.
 * Contracts: thin null/empty gate only; no struct stat in .x.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: residual does stat (POSIX/host).
 */
#[no_mangle]
export function shux_path_is_nonempty_regular_file(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (path[0] == 0) {
    return 0;
  }
  unsafe {
    return shux_path_is_nonempty_regular_file_impl(path);
  }
  return 0;
}

/**
 * Return path if it is a nonempty regular file; else null (skip missing link objs).
 * Params: path — candidate object path.
 * Returns: path on success, null if missing/empty/null.
 * Contracts: composes shux_path_is_nonempty_regular_file; no realpath.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function asm_link_obj_skip_missing(path: *u8): *u8 {
  if (path == 0 as *u8) {
    return 0 as *u8;
  }
  if (path[0] == 0) {
    return 0 as *u8;
  }
  if (shux_path_is_nonempty_regular_file(path) == 0) {
    return 0 as *u8;
  }
  return path;
}

/**
 * Resolve path via residual realpath if it exists; write into resolved buffer.
 * Params: path — input; resolved — output buffer (must be non-null).
 * Returns: residual pointer (usually resolved) or null on failure/null args.
 * Contracts: null/empty path or null resolved → null without calling impl.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: residual realpath (host libc).
 */
#[no_mangle]
export function shux_runtime_o_realpath_if_exists(path: *u8, resolved: *u8): *u8 {
  if (path == 0 as *u8) {
    return 0 as *u8;
  }
  if (path[0] == 0) {
    return 0 as *u8;
  }
  if (resolved == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return shux_runtime_o_realpath_if_exists_impl(path, resolved);
  }
  return 0 as *u8;
}

/**
 * Pure audit: number of L3 thin path-IO gates in this slice.
 * Returns: 3 (fixed catalog size for hybrid FROM_X bookkeeping).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_path_io_count(): i32 {
  return 3;
}
