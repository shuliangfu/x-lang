// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function seed_io_syscall_write_impl(fd: i32, buf: *u8, count: usize): i64;
export extern "C" function seed_io_syscall_read_impl(fd: i32, buf: *u8, count: usize): i64;
export extern "C" function seed_io_write_fd1_impl(ptr: *u8, len: usize, timeout_ms: u32): i32;

/** Exported function `runtime_asm_io_stubs_x_doc_anchor`.
 * Implements `runtime_asm_io_stubs_x_doc_anchor`.
 * @return i32
 */
export function runtime_asm_io_stubs_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function seed_io_syscall_write(fd: i32, buf: *u8, count: usize): i64 {
  unsafe {
    return seed_io_syscall_write_impl(fd, buf, count);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `seed_io_syscall_read`.
 * Read path helper `seed_io_syscall_read`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @return i64
 */
export function seed_io_syscall_read(fd: i32, buf: *u8, count: usize): i64 {
  unsafe {
    return seed_io_syscall_read_impl(fd, buf, count);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `seed_io_write_fd1`.
 * Write path helper `seed_io_write_fd1`.
 * @param ptr *u8
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function seed_io_write_fd1(ptr: *u8, len: usize, timeout_ms: u32): i32 {
  unsafe {
    return seed_io_write_fd1_impl(ptr, len, timeout_ms);
  }
  return 0 - 1;
}
