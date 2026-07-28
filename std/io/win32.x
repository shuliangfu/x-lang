// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.

/* See implementation. */
allow(padding) struct IoBatchBuf { ptr: *u8; length: usize; handle: usize; }

export const IO_FIXED_MAX: u32 = 8 as u32;
export const IO_READV_BUF_MAX: i32 = 16;

let io_fixed_ptr: [8]*u8 = [
  0 as *u8, 0 as *u8, 0 as *u8, 0 as *u8,
  0 as *u8, 0 as *u8, 0 as *u8, 0 as *u8,
];
let io_fixed_len: [8]usize = [
  0, 0, 0, 0,
  0, 0, 0, 0,
];
let io_fixed_nr: u32 = 0 as u32;

let io_wsa_ready: i32 = 0;

extern function _get_osfhandle(fd: i32): i64;
extern function _read(fd: i32, buf: *u8, count: u32): i32;
extern function _write(fd: i32, buf: *u8, count: u32): i32;
extern function ReadFile(hFile: *u8, lpBuffer: *u8, nNumberOfBytesToRead: u32, lpNumberOfBytesRead: *u32, lpOverlapped: *u8): i32;
extern function WriteFile(hFile: *u8, lpBuffer: *u8, nNumberOfBytesToWrite: u32, lpNumberOfBytesWritten: *u32, lpOverlapped: *u8): i32;
extern function WSAStartup(wVersionRequested: i32, lpWSAData: *u8): i32;

/** Exported function `io_win_fd_to_handle`.
 * Implements `io_win_fd_to_handle`.
 * @param fd i32
 * @return *u8
 */
export function io_win_fd_to_handle(fd: i32): *u8 {
  let h: i64 = 0;
  unsafe { h = _get_osfhandle(fd); }
  if (h < 0) {
    return 0 as *u8;
  }
  return h as *u8;
}

/**
 * See implementation.
 */
export function io_read(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  if (timeout_ms > 0) {
    /* See implementation. */
  }
  let h: *u8 = io_win_fd_to_handle(fd);
  if (h != 0) {
    let nr: u32 = 0;
    let want: u32 = count as u32;
    if (want > 2147483647) {
      want = 2147483647;
    }
    unsafe { if (ReadFile(h, buf, want, &nr, 0 as *u8) != 0) {
      return nr as isize;
    } }
  }
  let r: i32 = 0;
  unsafe { r = _read(fd, buf, count as u32); }
  if (r < 0) {
    return -1;
  }
  return r as isize;
}

/** Exported function `io_write`.
 * Write path helper `io_write`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @param timeout_ms u32
 * @return isize
 */
export function io_write(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  if (timeout_ms > 0) {
    /* See implementation. */
  }
  let h: *u8 = io_win_fd_to_handle(fd);
  if (h != 0) {
    let nw: u32 = 0;
    let want: u32 = count as u32;
    if (want > 2147483647) {
      want = 2147483647;
    }
    unsafe { if (WriteFile(h, buf, want, &nw, 0 as *u8) != 0) {
      return nw as isize;
    } }
  }
  let r: i32 = 0;
  unsafe { r = _write(fd, buf, count as u32); }
  if (r < 0) {
    return -1;
  }
  return r as isize;
}

/** Exported function `io_read_batch`.
 * Read path helper `io_read_batch`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @param n i32
 * @param timeout_ms u32
 * @return isize
 */
export function io_read_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  if (n <= 0 || n > 4) { return -1; }
  let total: isize = 0;
  let r0: isize = io_read(fd, p0, l0, timeout_ms);
  if (r0 < 0) { return -1; }
  total = total + r0;
  if (n == 1) { return total; }
  let r1: isize = io_read(fd, p1, l1, timeout_ms);
  if (r1 < 0) { return -1; }
  total = total + r1;
  if (n == 2) { return total; }
  let r2: isize = io_read(fd, p2, l2, timeout_ms);
  if (r2 < 0) { return -1; }
  total = total + r2;
  if (n == 3) { return total; }
  let r3: isize = io_read(fd, p3, l3, timeout_ms);
  if (r3 < 0) { return -1; }
  return total + r3;
}

/** Exported function `io_write_batch`.
 * Write path helper `io_write_batch`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @param n i32
 * @param timeout_ms u32
 * @return isize
 */
export function io_write_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  if (n <= 0 || n > 4) { return -1; }
  let total: isize = 0;
  let r0: isize = io_write(fd, p0, l0, timeout_ms);
  if (r0 < 0) { return -1; }
  total = total + r0;
  if (n == 1) { return total; }
  let r1: isize = io_write(fd, p1, l1, timeout_ms);
  if (r1 < 0) { return -1; }
  total = total + r1;
  if (n == 2) { return total; }
  let r2: isize = io_write(fd, p2, l2, timeout_ms);
  if (r2 < 0) { return -1; }
  total = total + r2;
  if (n == 3) { return total; }
  let r3: isize = io_write(fd, p3, l3, timeout_ms);
  if (r3 < 0) { return -1; }
  return total + r3;
}

/** Exported function `io_read_batch_buf`.
 * Read path helper `io_read_batch_buf`.
 * @param fd i32
 * @param bufs *IoBatchBuf
 * @param n i32
 * @param timeout_ms u32
 * @return isize
 */
export function io_read_batch_buf(fd: i32, bufs: *IoBatchBuf, n: i32, timeout_ms: u32): isize {
  if (n <= 0 || n > IO_READV_BUF_MAX || bufs == 0) { return -1; }
  let total: isize = 0;
  let i: i32 = 0;
  while (i < n) {
    let r: isize = io_read(fd, bufs[i].ptr, bufs[i].length, timeout_ms);
    if (r < 0) { return -1; }
    total = total + r;
    i = i + 1;
  }
  return total;
}

/** Exported function `io_write_batch_buf`.
 * Write path helper `io_write_batch_buf`.
 * @param fd i32
 * @param bufs *IoBatchBuf
 * @param n i32
 * @param timeout_ms u32
 * @return isize
 */
export function io_write_batch_buf(fd: i32, bufs: *IoBatchBuf, n: i32, timeout_ms: u32): isize {
  if (n <= 0 || n > IO_READV_BUF_MAX || bufs == 0) { return -1; }
  let total: isize = 0;
  let i: i32 = 0;
  while (i < n) {
    let r: isize = io_write(fd, bufs[i].ptr, bufs[i].length, timeout_ms);
    if (r < 0) { return -1; }
    total = total + r;
    i = i + 1;
  }
  return total;
}

/** Exported function `io_register_buffer`.
 * Registration helper `io_register_buffer`.
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function io_register_buffer(ptr: *u8, len: usize): i32 {
  return io_register_buffers_4(ptr, len, 0 as *u8, 0, 0 as *u8, 0, 0 as *u8, 0, 1 as u32);
}

/** Exported function `io_register_buffers_4`.
 * Registration helper `io_register_buffers_4`.
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @param nr u32
 * @return i32
 */
export function io_register_buffers_4(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, nr: u32): i32 {
  if (nr == 0 || nr > 4) { return 0; }
  io_fixed_nr = 0;
  if (nr >= 1) {
    if (p0 == 0) { return 0; }
    io_fixed_ptr[0] = p0;
    io_fixed_len[0] = l0;
  }
  if (nr >= 2) {
    if (p1 == 0) { return 0; }
    io_fixed_ptr[1] = p1;
    io_fixed_len[1] = l1;
  }
  if (nr >= 3) {
    if (p2 == 0) { return 0; }
    io_fixed_ptr[2] = p2;
    io_fixed_len[2] = l2;
  }
  if (nr >= 4) {
    if (p3 == 0) { return 0; }
    io_fixed_ptr[3] = p3;
    io_fixed_len[3] = l3;
  }
  io_fixed_nr = nr;
  return 1;
}

/** Exported function `io_register_buffers_buf`.
 * Registration helper `io_register_buffers_buf`.
 * @param bufs *IoBatchBuf
 * @param nr i32
 * @return i32
 */
export function io_register_buffers_buf(bufs: *IoBatchBuf, nr: i32): i32 {
  if (nr <= 0 || nr > (IO_FIXED_MAX as i32) || bufs == 0) { return 0; }
  io_fixed_nr = 0;
  let i: i32 = 0;
  while (i < nr) {
    if (bufs[i].ptr == 0) { return 0; }
    io_fixed_ptr[i] = bufs[i].ptr;
    io_fixed_len[i] = bufs[i].length;
    i = i + 1;
  }
  io_fixed_nr = (nr as u32);
  return 1;
}

/** Exported function `io_unregister_buffers`.
 * Registration helper `io_unregister_buffers`.
 * @return void
 */
export function io_unregister_buffers(): void {
  io_fixed_nr = 0;
}

/** Exported function `io_read_fixed`.
 * Read path helper `io_read_fixed`.
 * @param fd i32
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return isize
 */
export function io_read_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  if (buf_index >= io_fixed_nr) { return -1; }
  let base: *u8 = io_fixed_ptr[buf_index];
  let cap: usize = io_fixed_len[buf_index];
  if (base == 0 || offset > cap || len > cap - offset) { return -1; }
  return io_read(fd, base + offset, len, timeout_ms);
}

/** Exported function `io_write_fixed`.
 * Write path helper `io_write_fixed`.
 * @param fd i32
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return isize
 */
export function io_write_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  if (buf_index >= io_fixed_nr) { return -1; }
  let base: *u8 = io_fixed_ptr[buf_index];
  let cap: usize = io_fixed_len[buf_index];
  if (base == 0 || offset > cap || len > cap - offset) { return -1; }
  return io_write(fd, base + offset, len, timeout_ms);
}

/**
 * See implementation.
 * See implementation.
 */
export function io_wait_readable(fds: *i32, n: i32, timeout_ms: u32): i32 {
  if (fds == 0 || n <= 0 || n > 8) { return -1; }
  if (io_wsa_ready == 0) {
    let wsa: [400]u8;
    unsafe { if (WSAStartup(514, &wsa[0]) != 0) {
      return -1;
    } }
    io_wsa_ready = 1;
  }
  /* See implementation. */
  if (timeout_ms > 0) { return -1; }
  return -1;
}
