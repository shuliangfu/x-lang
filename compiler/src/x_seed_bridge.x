// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function preprocess_x_buf(src: *u8, src_len: isize, out_buf: *u8, out_cap: i32): i32;
export extern "C" function typeck_std_heap_alloc(size: usize): *u8;
export extern "C" function calloc(n: usize, size: usize): *u8;
export extern "C" function free(ptr: *u8): void;

/** Exported function `typeck_preprocess_x_buf`.
 * Implements `typeck_preprocess_x_buf`.
 * @param src *u8
 * @param src_len isize
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
#[no_mangle]
export function typeck_preprocess_x_buf(src: *u8, src_len: isize, out_buf: *u8, out_cap: i32): i32 {
  unsafe {
    let r: i32 = preprocess_x_buf(src, src_len, out_buf, out_cap);
    return r;
  }
  return 0;
}

/** Exported function `std_heap_alloc_zeroed`.
 * Memory management helper `std_heap_alloc_zeroed`.
 * @param size usize
 * @return *u8
 */
#[no_mangle]
export function std_heap_alloc_zeroed(size: usize): *u8 {
  unsafe {
    let r: *u8 = calloc(1, size);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `std_heap_alloc_zero`.
 * Memory management helper `std_heap_alloc_zero`.
 * @param size usize
 * @return *u8
 */
#[no_mangle]
export function std_heap_alloc_zero(size: usize): *u8 {
  return std_heap_alloc_zeroed(size);
}

/** Exported function `std_heap_free`.
 * Memory management helper `std_heap_free`.
 * @param ptr *u8
 * @return void
 */
#[no_mangle]
export function std_heap_free(ptr: *u8): void {
  unsafe {
    free(ptr);
  }
}

/** Exported function `std_heap_alloc`.
 * Memory management helper `std_heap_alloc`.
 * @param size usize
 * @return *u8
 */
#[no_mangle]
export function std_heap_alloc(size: usize): *u8 {
  unsafe {
    let r: *u8 = typeck_std_heap_alloc(size);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `io_read_ptr`.
 * Read path helper `io_read_ptr`.
 * @param handle u32
 * @param timeout_ms u32
 * @return *u8
 */
#[no_mangle]
export function io_read_ptr(handle: u32, timeout_ms: u32): *u8 {
  return 0 as *u8;
}

/** Exported function `io_read_ptr_len`.
 * Read path helper `io_read_ptr_len`.
 * @return i32
 */
#[no_mangle]
export function io_read_ptr_len(): i32 {
  return 0;
}

/** Exported function `io_register_buffer`.
 * Registration helper `io_register_buffer`.
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
#[no_mangle]
export function io_register_buffer(ptr: *u8, len: usize): i32 {
  return 0;
}

/** Exported function `io_unregister_buffers`.
 * Registration helper `io_unregister_buffers`.
 * @return void
 */
#[no_mangle]
export function io_unregister_buffers(): void {
}

/** Exported function `io_wait_readable`.
 * Read path helper `io_wait_readable`.
 * @param fds *i32
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
#[no_mangle]
export function io_wait_readable(fds: *i32, n: i32, timeout_ms: u32): i32 {
  return 0;
}

/** Function `io_register_buffers_4`.
 * Purpose: implements `io_register_buffers_4`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function io_register_buffers_4(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize,
                               p3: *u8, l3: usize, nr: u32): i32 {
  return 0;
}

/** Exported function `io_register_buffers_buf`.
 * Registration helper `io_register_buffers_buf`.
 * @param bufs *u8
 * @param nr i32
 * @return i32
 */
#[no_mangle]
export function io_register_buffers_buf(bufs: *u8, nr: i32): i32 {
  return 0;
}

/** Exported function `io_register_buffers_buf_i32`.
 * Registration helper `io_register_buffers_buf_i32`.
 * @param bufs isize
 * @param nr i32
 * @return i32
 */
#[no_mangle]
export function io_register_buffers_buf_i32(bufs: isize, nr: i32): i32 {
  return io_register_buffers_buf(0 as *u8, nr);
}

/** Exported function `xlang_io_register`.
 * Registration helper `xlang_io_register`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @return i32
 */
#[no_mangle]
export function xlang_io_register(ptr: *u8, len: usize, handle: usize): i32 {
  return io_register_buffer(ptr, len);
}
