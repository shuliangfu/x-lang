// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// std_debug_formal_darwin.x — Darwin arm64 body of std/debug/debug.o.
//
// The C face writes stderr with write(2). This file calls the same
// libSystem write. The name does not start with an underscore, so the
// Mach-O undefined symbol is _write. A newline is the byte 10 on the
// stack: this compiler cannot store a file-level let. Each function
// makes one extern call. Linux and Windows keep formal_surface.c.
// PLATFORM: MACOS|DARWIN arm64.

extern function write(fd: i32, buf: *u8, n: usize): isize;

/**
 * Write one newline to stderr.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
function debug_write_nl(): i32 {
  let nl: u8 = 10;
  unsafe {
    let p: *u8 = &nl as *u8;
    let n: isize = write(2, p, 1);
  }
  return 0;
}

/**
 * Write caller bytes to stderr when the pointer and length are usable.
 * @param ptr bytes, or null
 * @param len byte count
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
function debug_write_bytes(ptr: *u8, len: i32): i32 {
  if (ptr == 0) {
    return 0;
  }
  if (len <= 0) {
    return 0;
  }
  unsafe {
    let n: isize = write(2, ptr, len as usize);
  }
  return 0;
}

/**
 * Anchor for this Darwin debug object.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_debug_formal_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Soft assert. A true value returns 0. A false value returns -1.
 * This face does not abort.
 * @param b condition, non-zero is true
 * @return i32 — 0 or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_debug_assert(b: i32): i32 {
  if (b != 0) {
    return 0;
  }
  return 0 - 1;
}

/**
 * Write bytes and a newline to stderr.
 * @param ptr bytes, or null
 * @param len byte count
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_debug_println_u8_ptr_i32(ptr: *u8, len: i32): i32 {
  debug_write_bytes(ptr, len);
  return debug_write_nl();
}

/**
 * Write bytes to stderr. Does not add a newline.
 * @param ptr bytes, or null
 * @param len byte count
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_debug_print_u8_ptr_i32(ptr: *u8, len: i32): i32 {
  return debug_write_bytes(ptr, len);
}
