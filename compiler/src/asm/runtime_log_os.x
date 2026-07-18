// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function log_apply_env_once_impl(): void;
export extern "C" function log_do_rotate_impl(): i32;
export extern "C" function log_write_file_sync_impl(buf: *u8, len: usize): i32;
export extern "C" function log_write_sync_impl(buf: *u8, len: usize): i32;
export extern "C" function log_async_enqueue_impl(buf: *u8, len: usize): i32;
export extern "C" function log_emit_bytes_impl(buf: *u8, len: usize): i32;

/** Exported function `runtime_log_os_x_doc_anchor`.
 * Implements `runtime_log_os_x_doc_anchor`.
 * @return i32
 */
export function runtime_log_os_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function log_apply_env_once(): void {
  unsafe {
    log_apply_env_once_impl();
  }
}

#[no_mangle]
/** Exported function `log_do_rotate`.
 * Implements `log_do_rotate`.
 * @return i32
 */
export function log_do_rotate(): i32 {
  unsafe {
    return log_do_rotate_impl();
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `log_write_file_sync`.
 * Write path helper `log_write_file_sync`.
 * @param buf *u8
 * @param len usize
 * @return i32
 */
export function log_write_file_sync(buf: *u8, len: usize): i32 {
  unsafe {
    return log_write_file_sync_impl(buf, len);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `log_write_sync`.
 * Write path helper `log_write_sync`.
 * @param buf *u8
 * @param len usize
 * @return i32
 */
export function log_write_sync(buf: *u8, len: usize): i32 {
  unsafe {
    return log_write_sync_impl(buf, len);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `log_async_enqueue`.
 * Implements `log_async_enqueue`.
 * @param buf *u8
 * @param len usize
 * @return i32
 */
export function log_async_enqueue(buf: *u8, len: usize): i32 {
  unsafe {
    return log_async_enqueue_impl(buf, len);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `log_emit_bytes`.
 * Implements `log_emit_bytes`.
 * @param buf *u8
 * @param len usize
 * @return i32
 */
export function log_emit_bytes(buf: *u8, len: usize): i32 {
  unsafe {
    return log_emit_bytes_impl(buf, len);
  }
  return 0 - 1;
}

// See implementation.

export extern "C" function log_write_fd_impl(fd: i32, buf: *u8, n: i64): i64;

/* See implementation. */

#[no_mangle]
export function log_write_fd(fd: i32, buf: *u8, n: i64): i64 {
  unsafe { return log_write_fd_impl(fd, buf, n); }
  return 0;
}
