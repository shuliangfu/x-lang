// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-270 / P2 link_abi L3: path liveness thin shell → R2 full.
// Product: PREFER_X_O → g05_try_x_to_o; cold-start seeds/labi_path_io.from_x.c.
// Hybrid macro XLANG_LABI_PATH_IO_FROM_X (FROM_X rest business H=0, marker only).
//
// R2 full: .x owns 6 public gates + count:
//   - xlang_path_is_nonempty_regular_file → _impl (stat Cap residual mega rest)
//   - asm_link_obj_skip_missing: composes nonempty check
//   - xlang_runtime_o_realpath_if_exists → _impl (realpath+skip Cap residual)
//   - link_abi_path_readable → _impl (access R_OK Cap residual; wave209)
//   - link_abi_realpath_cap → _impl (POSIX realpath / Windows null; wave218)
//   - link_abi_path_executable → _impl (access X_OK Cap residual; wave221)
// No struct stat layout; no libc realpath/access prototype here (avoids *u8 vs char* clash).

export extern "C" function xlang_path_is_nonempty_regular_file_impl(path: *u8): i32;
export extern "C" function xlang_runtime_o_realpath_if_exists_impl(path: *u8, resolved: *u8): *u8;
/* Cap residual (wave209): host access(path, R_OK) only; pure owns null/empty gates. */
export extern "C" function link_abi_path_readable_impl(path: *u8): i32;
/* Cap residual (wave218): host realpath(path, out) on POSIX; Windows always null. */
export extern "C" function link_abi_realpath_cap_impl(path: *u8, out: *u8): *u8;
/* Cap residual (wave221): host access(path, X_OK) only; pure owns null/empty gates. */
export extern "C" function link_abi_path_executable_impl(path: *u8): i32;

/**
 * Return 1 iff path names a non-empty regular file (stat residual).
 * Params: path — NUL-terminated; null/empty → 0 without calling impl.
 * Returns: 1 if residual reports nonempty regular file, else 0.
 * Contracts: thin null/empty gate only; no struct stat in .x.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: residual does stat (POSIX/host).
 */
#[no_mangle]
export function xlang_path_is_nonempty_regular_file(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (path[0] == 0) {
    return 0;
  }
  unsafe {
    return xlang_path_is_nonempty_regular_file_impl(path);
  }
  return 0;
}

/**
 * Return path if it is a nonempty regular file; else null (skip missing link objs).
 * Params: path — candidate object path.
 * Returns: path on success, null if missing/empty/null.
 * Contracts: composes xlang_path_is_nonempty_regular_file; no realpath.
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
  if (xlang_path_is_nonempty_regular_file(path) == 0) {
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
export function xlang_runtime_o_realpath_if_exists(path: *u8, resolved: *u8): *u8 {
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
    return xlang_runtime_o_realpath_if_exists_impl(path, resolved);
  }
  return 0 as *u8;
}

/**
 * Return 1 iff path is readable (host access R_OK); null/empty → 0 without residual.
 * @param path *u8 — NUL-terminated path; null/empty rejected at pure gate
 * @return i32 — 1 readable, 0 otherwise
 * Pure orch: ≡ mega null/empty gates before Cap residual access (wave209).
 * Cap residual: link_abi_path_readable_impl (host access R_OK; mega always).
 * Why (wave209): hybrid still had path_readable body always mega C (gates+access).
 * Preserves append_user_extra / ensure / freestanding skip-unreadable semantics
 * (not nonempty-regular-file; R_OK only).
 * PLATFORM: SHARED orch; residual access is POSIX/host (Windows hybrid via compat).
 * Track-L: #[no_mangle] keeps surface short name matching Cap residual callers.
 */
#[no_mangle]
export function link_abi_path_readable(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (path[0] == 0) {
    return 0;
  }
  unsafe {
    return link_abi_path_readable_impl(path);
  }
  return 0;
}

/**
 * Resolve path via host realpath into caller out buffer (Cap residual libc).
 * Thin pure public: null/empty path or null out → null without residual.
 * @param path *u8 — NUL-terminated input path; null/empty rejected at pure gate
 * @param out *u8 — caller-owned resolve buffer (PATH_MAX class); null rejected
 * @return *u8 — residual pointer (usually out) on success; null on fail / Windows
 * Pure orch: ≡ mega null/empty/out gates before Cap residual realpath (wave218).
 * Cap residual: link_abi_realpath_cap_impl (POSIX realpath; Windows always null).
 * Why (wave218): hybrid still had realpath_cap body always mega C (gates+realpath).
 * G.7 single public authority; path_pure / invoke_ld / formal_std callers unchanged.
 * PLATFORM: SHARED orch; residual is POSIX realpath (WINDOWS always null ≡ mega).
 * Track-L: #[no_mangle] keeps surface short name matching Cap residual callers.
 */
#[no_mangle]
export function link_abi_realpath_cap(path: *u8, out: *u8): *u8 {
  if (path == 0 as *u8) {
    return 0 as *u8;
  }
  if (path[0] == 0) {
    return 0 as *u8;
  }
  if (out == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return link_abi_realpath_cap_impl(path, out);
  }
  return 0 as *u8;
}

/**
 * Return 1 iff path is executable (host access X_OK); null/empty → 0 without residual.
 * @param path *u8 — NUL-terminated path; null/empty rejected at pure gate
 * @return i32 — 1 executable (X_OK), 0 otherwise
 * Pure orch: ≡ mega null/empty gates before Cap residual access X_OK (wave221).
 * Cap residual: link_abi_path_executable_impl (host access X_OK; mega always).
 * Why (wave221): formal_std ensure still used raw access(path, X_OK) under hybrid;
 * G.7 single public authority under L3 hybrid (sibling of path_readable R_OK).
 * Product host binary probe (XLANG env / compiler/{xlang_asm,xlang,xlang-c}) uses this face.
 * PLATFORM: SHARED orch; residual access is POSIX/host (Windows hybrid via compat).
 * Track-L: #[no_mangle] keeps surface short name matching Cap residual callers.
 */
#[no_mangle]
export function link_abi_path_executable(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (path[0] == 0) {
    return 0;
  }
  unsafe {
    return link_abi_path_executable_impl(path);
  }
  return 0;
}

/**
 * Pure audit: number of L3 thin path-IO gates in this slice.
 * Returns: 6 (nonempty + skip_missing + realpath_if_exists + path_readable
 *   + realpath_cap + path_executable; wave221).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_path_io_count(): i32 {
  return 6;
}
