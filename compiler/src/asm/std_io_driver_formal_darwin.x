// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// std_io_driver_formal_darwin.x — Darwin arm64 body of std/io/driver.o.
//
// Buffer is 24 bytes { ptr, length, handle }. On arm64 a struct larger
// than 16 bytes arrives as a pointer in the next integer register, so the
// by-value Buffer parameters are *u8. Array parameters are already pointers.
// Every face returns 0 and does not call the driver. Linux and Windows
// keep the C face.
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Anchor for this Darwin io-driver object.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_driver_formal_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Keep a pointer parameter live without loading through it.
 * @param p received address
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
function drv_keep(p: *u8): i32 {
  if (p == p) {
    return 0;
  }
  return 0;
}

/**
 * Register one buffer. The 24-byte value arrives as a pointer.
 * @param buf address of the caller's Buffer
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_driver_register(buf: *u8): i32 {
  return drv_keep(buf);
}

/**
 * Submit a read. The buffer arrives as a pointer; the timeout stays in w1.
 * @param buf address of the caller's Buffer
 * @param timeout_ms timeout in milliseconds
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_driver_submit_read(buf: *u8, timeout_ms: u32): i32 {
  let ms: u32 = timeout_ms;
  if (ms == ms) {
    return drv_keep(buf);
  }
  return 0;
}

/**
 * Submit a write. The buffer arrives as a pointer; the timeout stays in w1.
 * @param buf address of the caller's Buffer
 * @param timeout_ms timeout in milliseconds
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_driver_submit_write(buf: *u8, timeout_ms: u32): i32 {
  let ms: u32 = timeout_ms;
  if (ms == ms) {
    return drv_keep(buf);
  }
  return 0;
}

/**
 * Register a caller-owned buffer table.
 * @param bufs table pointer
 * @param nr entry count
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_driver_submit_register_fixed_buffers_buf(bufs: *u8, nr: u32): i32 {
  let n: u32 = nr;
  if (n == n) {
    return drv_keep(bufs);
  }
  return 0;
}

/**
 * Submit a write batch. The array parameter is already a pointer.
 * @param buffers first buffer
 * @param n entry count
 * @param timeout_ms timeout in milliseconds
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_driver_submit_write_batch(buffers: *u8, n: i32, timeout_ms: u32): i32 {
  let count: i32 = n;
  let ms: u32 = timeout_ms;
  if (count == count) {
    if (ms == ms) {
      return drv_keep(buffers);
    }
  }
  return 0;
}

/**
 * Submit a read batch through an explicit pointer.
 * @param handle io handle
 * @param bufs table pointer
 * @param nr entry count
 * @param timeout_ms timeout in milliseconds
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_driver_submit_read_batch_buf(handle: u64, bufs: *u8, nr: i32, timeout_ms: u32): i32 {
  let h: u64 = handle;
  let count: i32 = nr;
  let ms: u32 = timeout_ms;
  if (h == h) {
    if (count == count) {
      if (ms == ms) {
        return drv_keep(bufs);
      }
    }
  }
  return 0;
}

/**
 * Submit a write batch through an explicit pointer.
 * @param handle io handle
 * @param bufs table pointer
 * @param nr entry count
 * @param timeout_ms timeout in milliseconds
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_io_driver_submit_write_batch_buf(handle: u64, bufs: *u8, nr: i32, timeout_ms: u32): i32 {
  let h: u64 = handle;
  let count: i32 = nr;
  let ms: u32 = timeout_ms;
  if (h == h) {
    if (count == count) {
      if (ms == ms) {
        return drv_keep(bufs);
      }
    }
  }
  return 0;
}
