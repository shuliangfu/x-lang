// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function bootstrap_heap_grow_impl(need: usize): i32;
export extern "C" function bootstrap_syscall3_impl(nr: i64, a0: i64, a1: i64, a2: i64): i64;
export extern "C" function bootstrap_syscall4_impl(nr: i64, a0: i64, a1: i64, a2: i64, a3: i64): i64;
export extern "C" function bootstrap_format_double_impl(x: f64, out: *u8, cap: usize): i32;
export extern "C" function bootstrap_vfprintf_fd_impl(fd: i32, fmt: *u8, ap: *u8): i32;

/** Exported function `bootstrap_nostdlib_stubs_x_doc_anchor`.
 * Implements `bootstrap_nostdlib_stubs_x_doc_anchor`.
 * @return i32
 */
export function bootstrap_nostdlib_stubs_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */


#[no_mangle]
export function bootstrap_heap_grow(need: usize): i32 {
  unsafe {
    return bootstrap_heap_grow_impl(need);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `bootstrap_syscall3`.
 * Implements `bootstrap_syscall3`.
 * @param nr i64
 * @param a0 i64
 * @param a1 i64
 * @param a2 i64
 * @return i64
 */
export function bootstrap_syscall3(nr: i64, a0: i64, a1: i64, a2: i64): i64 {
  unsafe {
    return bootstrap_syscall3_impl(nr, a0, a1, a2);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `bootstrap_syscall4`.
 * Implements `bootstrap_syscall4`.
 * @param nr i64
 * @param a0 i64
 * @param a1 i64
 * @param a2 i64
 * @param a3 i64
 * @return i64
 */
export function bootstrap_syscall4(nr: i64, a0: i64, a1: i64, a2: i64, a3: i64): i64 {
  unsafe {
    return bootstrap_syscall4_impl(nr, a0, a1, a2, a3);
  }
  return 0 - 1;
}

/* See implementation. */

#[no_mangle]
export function bootstrap_format_double(x: f64, out: *u8, cap: usize): i32 {
  unsafe {
    return bootstrap_format_double_impl(x, out, cap);
  }
  return 0;
}

#[no_mangle]
/** Exported function `bootstrap_vfprintf_fd`.
 * Implements `bootstrap_vfprintf_fd`.
 * @param fd i32
 * @param fmt *u8
 * @param ap *u8
 * @return i32
 */
export function bootstrap_vfprintf_fd(fd: i32, fmt: *u8, ap: *u8): i32 {
  unsafe {
    return bootstrap_vfprintf_fd_impl(fd, fmt, ap);
  }
  return 0;
}

// bootstrap_align16: see function docblock below.

#[no_mangle]
/** Exported function `bootstrap_align16`.
 * Implements `bootstrap_align16`.
 * @param n usize
 * @return usize
 */
export function bootstrap_align16(n: usize): usize {
  // (n + 15) & ~15
  return (n + 15) & (0 - 16);
}
