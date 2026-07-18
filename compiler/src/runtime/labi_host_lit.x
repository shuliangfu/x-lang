// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-269 / P2 link_abi L2: host-literal probe thin shell → R2 full.
// Product: PREFER_X_O → g05_try_x_to_o; cold-start seeds/labi_host_lit.from_x.c.
// Hybrid macro SHUX_LABI_HOST_LIT_FROM_X (FROM_X rest business H=0, marker only).
//
// R2 full: .x owns 2 public gates + count:
//   - shux_host_is_linux → _impl (#if __linux__ Cap residual mega rest)
//   - shux_host_is_apple_aarch64 → _impl (#if APPLE+aarch64 Cap residual)
// Dual mechanism with cfg host lit (f-182): compile-time #if, not uname.
// No #if inside .x (language has no conditional-compile literals).

export extern "C" function shux_host_is_linux_impl(): i32;
export extern "C" function shux_host_is_apple_aarch64_impl(): i32;

/**
 * Return 1 if host is Linux (delegates to compile-time #if residual).
 * Params: none.
 * Returns: 1 on Linux host, else 0.
 * Contracts: thin shell only; real probe is shux_host_is_linux_impl.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: residual uses #if __linux__ (not uname).
 */
#[no_mangle]
export function shux_host_is_linux(): i32 {
  unsafe {
    return shux_host_is_linux_impl();
  }
  return 0;
}

/**
 * Return 1 if host is Apple aarch64 (delegates to compile-time #if residual).
 * Params: none.
 * Returns: 1 on Apple aarch64, else 0.
 * Contracts: thin shell only; real probe is shux_host_is_apple_aarch64_impl.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: residual uses #if APPLE+aarch64 (not uname).
 */
#[no_mangle]
export function shux_host_is_apple_aarch64(): i32 {
  unsafe {
    return shux_host_is_apple_aarch64_impl();
  }
  return 0;
}

/**
 * Pure audit: number of L2 host-lit thin gates in this slice.
 * Returns: 2 (fixed catalog size for hybrid FROM_X bookkeeping).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_host_lit_count(): i32 {
  return 2;
}
