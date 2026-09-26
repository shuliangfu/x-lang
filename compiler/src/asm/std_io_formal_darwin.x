// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// std_io_formal_darwin.x — Darwin arm64 body of std/io/io.o.
//
// std_context_Context is one i64 handle. On arm64 that 8-byte struct
// arrives in the next integer register, so these parameters are i64.
// Cancelled is -1. Expired is -2. A positive remainder becomes
// milliseconds, with a floor of 1 and a cap of 2147483647.
// Live reads and writes forward to std_io_read and std_io_write.
// Each helper makes one extern call. Linux and Windows keep the C face.
// PLATFORM: MACOS|DARWIN arm64.

extern function std_context_is_cancelled(handle: i64): i32;
extern function std_context_remaining_ns(handle: i64): i64;
extern function std_context_deadline_ns(handle: i64): i64;
extern function std_error_io_err_cancelled(): i32;
extern function std_error_io_err_timeout(): i32;
extern function std_io_read(handle: u64, ptr: *u8, len: u64, timeout_ms: u32): i32;
extern function std_io_write(handle: u64, ptr: *u8, len: u64, timeout_ms: u32): i32;

/**
 * Anchor for this Darwin io object.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_formal_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Ask whether the context is cancelled.
 * @param handle context handle
 * @return i32 — non-zero when cancelled
 * PLATFORM: MACOS|DARWIN
 */
function io_ctx_cancelled(handle: i64): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_context_is_cancelled(handle);
  }
  return n;
}

/**
 * Remaining time on the context, in nanoseconds.
 * @param handle context handle
 * @return i64 — remaining nanoseconds
 * PLATFORM: MACOS|DARWIN
 */
function io_ctx_remaining(handle: i64): i64 {
  let n: i64 = 0;
  unsafe {
    n = std_context_remaining_ns(handle);
  }
  return n;
}

/**
 * Deadline on the context, in nanoseconds.
 * @param handle context handle
 * @return i64 — deadline, or 0 when none
 * PLATFORM: MACOS|DARWIN
 */
function io_ctx_deadline(handle: i64): i64 {
  let n: i64 = 0;
  unsafe {
    n = std_context_deadline_ns(handle);
  }
  return n;
}

/**
 * Turn a remaining-nanosecond count into a timeout in milliseconds.
 * Non-positive remaining time is 0. A positive count below 1 ms is 1.
 * Values past i32 max clamp to 2147483647.
 * @param rem remaining nanoseconds
 * @return i32 — timeout in milliseconds
 * PLATFORM: MACOS|DARWIN
 */
function io_ms_from_rem(rem: i64): i32 {
  if (rem <= 0) {
    return 0;
  }
  let ms: i64 = rem / 1000000;
  if (ms <= 0) {
    return 1;
  }
  if (ms > 2147483647) {
    return 2147483647;
  }
  return ms as i32;
}

/**
 * True when the deadline is set and the remaining time is already gone.
 * @param handle context handle
 * @param rem remaining nanoseconds
 * @return i32 — 1 when expired
 * PLATFORM: MACOS|DARWIN
 */
function io_ctx_expired(handle: i64, rem: i64): i32 {
  let dl: i64 = io_ctx_deadline(handle);
  if (dl > 0) {
    if (rem <= 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * Map a context to a timeout in milliseconds.
 * @param handle context handle
 * @return i32 — -1 cancelled, -2 expired, otherwise milliseconds
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_timeout_from_ctx(handle: i64): i32 {
  if (io_ctx_cancelled(handle) != 0) {
    return 0 - 1;
  }
  let rem: i64 = io_ctx_remaining(handle);
  if (io_ctx_expired(handle, rem) != 0) {
    return 0 - 2;
  }
  return io_ms_from_rem(rem);
}

/**
 * Cancelled error code from std.error.
 * @return i32 — std_error_io_err_cancelled
 * PLATFORM: MACOS|DARWIN
 */
function io_err_cancelled(): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_error_io_err_cancelled();
  }
  return n;
}

/**
 * Timeout error code from std.error.
 * @return i32 — std_error_io_err_timeout
 * PLATFORM: MACOS|DARWIN
 */
function io_err_timeout(): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_error_io_err_timeout();
  }
  return n;
}

/**
 * Forward a read once the timeout is known to be usable.
 * @param handle io handle
 * @param ptr buffer
 * @param len byte count
 * @param timeout_ms timeout in milliseconds
 * @return i32 — std_io_read
 * PLATFORM: MACOS|DARWIN
 */
function io_read_go(handle: u64, ptr: *u8, len: u64, timeout_ms: u32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_io_read(handle, ptr, len, timeout_ms);
  }
  return n;
}

/**
 * Forward a write once the timeout is known to be usable.
 * @param handle io handle
 * @param ptr buffer
 * @param len byte count
 * @param timeout_ms timeout in milliseconds
 * @return i32 — std_io_write
 * PLATFORM: MACOS|DARWIN
 */
function io_write_go(handle: u64, ptr: *u8, len: u64, timeout_ms: u32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_io_write(handle, ptr, len, timeout_ms);
  }
  return n;
}

/**
 * Apply a context timeout, then read or return the context error.
 * @param tm timeout from std_io_timeout_from_ctx
 * @param handle io handle
 * @param ptr buffer
 * @param len byte count
 * @return i32 — error code or the forwarded read
 * PLATFORM: MACOS|DARWIN
 */
function io_read_by_tm(tm: i32, handle: u64, ptr: *u8, len: u64): i32 {
  if (tm == (0 - 1)) {
    return io_err_cancelled();
  }
  if (tm == (0 - 2)) {
    return io_err_timeout();
  }
  return io_read_go(handle, ptr, len, tm as u32);
}

/**
 * Apply a context timeout, then write or return the context error.
 * @param tm timeout from std_io_timeout_from_ctx
 * @param handle io handle
 * @param ptr buffer
 * @param len byte count
 * @return i32 — error code or the forwarded write
 * PLATFORM: MACOS|DARWIN
 */
function io_write_by_tm(tm: i32, handle: u64, ptr: *u8, len: u64): i32 {
  if (tm == (0 - 1)) {
    return io_err_cancelled();
  }
  if (tm == (0 - 2)) {
    return io_err_timeout();
  }
  return io_write_go(handle, ptr, len, tm as u32);
}

/**
 * Read with a context timeout.
 * @param handle io handle
 * @param ptr buffer
 * @param len byte count
 * @param ctx context handle
 * @return i32 — error code or std_io_read
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_read_ctx(handle: u64, ptr: *u8, len: u64, ctx: i64): i32 {
  let tm: i32 = std_io_timeout_from_ctx(ctx);
  return io_read_by_tm(tm, handle, ptr, len);
}

/**
 * Write with a context timeout.
 * @param handle io handle
 * @param ptr buffer
 * @param len byte count
 * @param ctx context handle
 * @return i32 — error code or std_io_write
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_write_ctx(handle: u64, ptr: *u8, len: u64, ctx: i64): i32 {
  let tm: i32 = std_io_timeout_from_ctx(ctx);
  return io_write_by_tm(tm, handle, ptr, len);
}
