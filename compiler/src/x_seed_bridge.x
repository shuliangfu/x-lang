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
export extern "C" function pipeline_match_module_bytes(): *u8;
export extern "C" function diag_store_ptr_le(p: *u8, val: *u8): void;
export extern "C" function diag_snap_load_ptr(snap: *u8, off: i32): *u8;
export extern "C" function diag_snap_store_i32(snap: *u8, off: i32, val: i32): void;
export extern "C" function pipeline_expr_init_call_resolve_at_ref(arena: *u8, expr_ref: i32): void;
export extern "C" function xlang_sys_read(fd: i32, buf: *u8, count: usize): isize;
export extern "C" function xlang_sys_write(fd: i32, buf: *u8, count: usize): isize;

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

/**
 * Remember the module used while parsing a match.
 * The pointer stays in the seed. Its bytes are written by the existing
 * little-endian pointer store. A null module clears the slot.
 * @param m *u8 — module pointer, or null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parser_set_match_module(m: *u8): void {
  let pad: u8[32] = [];
  pad[0] = 0;
  unsafe {
    diag_store_ptr_le(pipeline_match_module_bytes(), m);
  }
}

/**
 * Return the module used while parsing a match.
 * The pointer stays in the seed. Offset 0 of that slot is the module
 * pointer, loaded in host byte order through diag_snap_load_ptr.
 * @return *u8 — module pointer, or null when none is set
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parser_get_match_module(): *u8 {
  let pad: u8[32] = [];
  let m: *u8 = 0 as *u8;
  pad[0] = 0;
  unsafe {
    m = diag_snap_load_ptr(pipeline_match_module_bytes(), 0);
  }
  return m;
}

/**
 * Clear the match fields of one expression.
 * Offsets in the flat ast_Expr record: matched ref at 320, arm base at
 * 324, arm count at 328. A null expression is left untouched.
 * @param e *u8 — expression record, or null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function ast_expr_init_match_enum(e: *u8): void {
  let pad: u8[32] = [];
  pad[0] = 0;
  if (e == 0 as *u8) {
    return;
  }
  unsafe {
    diag_snap_store_i32(e, 320, 0);
    diag_snap_store_i32(e, 324, 0);
    diag_snap_store_i32(e, 328, 0);
  }
}

/**
 * Reset one call expression to unresolved.
 * Both resolve slots are written as -1 by the existing pipeline writer.
 * A null arena or a non-positive expression index is left unchanged.
 * @param arena *u8 — expression arena, or null
 * @param expr_ref i32 — expression index
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function ast_expr_init_call_resolve(arena: *u8, expr_ref: i32): void {
  let pad: u8[32] = [];
  pad[0] = 0;
  unsafe {
    pipeline_expr_init_call_resolve_at_ref(arena, expr_ref);
  }
}

/**
 * Read up to count bytes from a file descriptor.
 * A null buffer or a zero count returns 0 and does not call the reader.
 * timeout_ms is ignored. A failed read returns -1. Bytes come from the
 * existing xlang_sys_read.
 * @param fd i32 — file descriptor
 * @param buf *u8 — destination, or null
 * @param count usize — maximum number of bytes
 * @param timeout_ms u32 — ignored
 * @return isize — bytes read, 0, or -1
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function io_read(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  let pad: u8[32] = [];
  let n: isize = 0;
  pad[0] = 0;
  pad[1] = timeout_ms as u8;
  if (buf == 0 as *u8) {
    return 0;
  }
  if (count == 0) {
    return 0;
  }
  unsafe {
    n = xlang_sys_read(fd, buf, count);
  }
  if (n < 0) {
    return 0 - 1;
  }
  return n;
}

/**
 * Write up to count bytes from buf to a file descriptor.
 * A null buffer or a zero count returns 0 and does not call the writer.
 * timeout_ms is ignored. A failed write returns -1. Bytes go through the
 * existing xlang_sys_write.
 * @param fd i32 — file descriptor
 * @param buf *u8 — source bytes, or null
 * @param count usize — maximum number of bytes
 * @param timeout_ms u32 — ignored
 * @return isize — bytes written, 0, or -1
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function io_write(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  let pad: u8[32] = [];
  let n: isize = 0;
  pad[0] = 0;
  pad[1] = timeout_ms as u8;
  if (buf == 0 as *u8) {
    return 0;
  }
  if (count == 0) {
    return 0;
  }
  unsafe {
    n = xlang_sys_write(fd, buf, count);
  }
  if (n < 0) {
    return 0 - 1;
  }
  return n;
}

/**
 * Batch read is not implemented on this seed face.
 * Every argument is ignored. The result is always -1.
 * @param fd i32 — file descriptor, ignored
 * @param bufs *u8 — buffer table, ignored
 * @param n i32 — buffer count, ignored
 * @param timeout_ms u32 — ignored
 * @return isize — always -1
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function io_read_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): isize {
  let pad: u8[32] = [];
  pad[0] = 0;
  pad[1] = timeout_ms as u8;
  pad[2] = fd as u8;
  pad[3] = n as u8;
  if (bufs != 0 as *u8) {
    pad[4] = 0;
  }
  return 0 - 1;
}

/**
 * Batch write is not implemented on this seed face.
 * Every argument is ignored. The result is always -1.
 * @param fd i32 — file descriptor, ignored
 * @param bufs *u8 — buffer table, ignored
 * @param n i32 — buffer count, ignored
 * @param timeout_ms u32 — ignored
 * @return isize — always -1
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function io_write_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): isize {
  let pad: u8[32] = [];
  pad[0] = 0;
  pad[1] = timeout_ms as u8;
  pad[2] = fd as u8;
  pad[3] = n as u8;
  if (bufs != 0 as *u8) {
    pad[4] = 0;
  }
  return 0 - 1;
}

/**
 * Read through a registered buffer slot.
 * buf_index and offset are ignored. The call goes to io_read with a null
 * buffer, which returns 0 without reading.
 * @param fd i32 — file descriptor
 * @param buf_index u32 — ignored
 * @param offset usize — ignored
 * @param len usize — length passed to io_read
 * @param timeout_ms u32 — passed through to io_read
 * @return isize — result of io_read on a null buffer
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function io_read_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  let pad: u8[32] = [];
  let n: isize = 0;
  pad[0] = 0;
  pad[1] = buf_index as u8;
  pad[2] = offset as u8;
  n = io_read(fd, 0 as *u8, len, timeout_ms);
  return n;
}

/**
 * Write through a registered buffer slot.
 * buf_index and offset are ignored. The call goes to io_write with a null
 * buffer, which returns 0 without writing.
 * @param fd i32 — file descriptor
 * @param buf_index u32 — ignored
 * @param offset usize — ignored
 * @param len usize — length passed to io_write
 * @param timeout_ms u32 — passed through to io_write
 * @return isize — result of io_write on a null buffer
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function io_write_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  let pad: u8[32] = [];
  let n: isize = 0;
  pad[0] = 0;
  pad[1] = buf_index as u8;
  pad[2] = offset as u8;
  n = io_write(fd, 0 as *u8, len, timeout_ms);
  return n;
}
