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
allow(padding) struct Iovec { base: *u8; length: usize; }

/* See implementation. */
allow(padding) struct PollFd { fd: i32; events: i16; revents: i16; }

/* See implementation. */
allow(padding) struct IoBatchBuf { ptr: *u8; length: usize; handle: usize; }

/* See implementation. */
export const IO_FIXED_MAX: u32 = 8;

/* See implementation. */
export const IO_READV_BUF_MAX: i32 = 16;

/* See implementation. */
let io_fixed_ptr: [8]*u8 = [
  0 as *u8, 0 as *u8, 0 as *u8, 0 as *u8,
  0 as *u8, 0 as *u8, 0 as *u8, 0 as *u8,
];
let io_fixed_len: [8]usize = [
  0, 0, 0, 0,
  0, 0, 0, 0,
];
let io_fixed_nr: u32 = 0;

/**
 * See implementation.
 * See implementation.
 */
extern "C" function xlang_sys_read(fd: i32, buf: *u8, count: usize): isize;
extern "C" function xlang_sys_write(fd: i32, buf: *u8, count: usize): isize;
extern "C" function xlang_sys_readv(fd: i32, iov: *u8, iovcnt: i32): isize;
extern "C" function xlang_sys_writev(fd: i32, iov: *u8, iovcnt: i32): isize;
extern "C" function xlang_sys_poll(fds: *u8, nfds: i32, timeout: i32): i32;

/** Exported function `io_libc_read`.
 * Read path helper `io_libc_read`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @return isize
 */
export function io_libc_read(fd: i32, buf: *u8, count: usize): isize {
  unsafe { return xlang_sys_read(fd, buf, count); }
  return 0 as isize; // unreachable — typeck workaround
}
/** Exported function `io_libc_write`.
 * Write path helper `io_libc_write`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @return isize
 */
export function io_libc_write(fd: i32, buf: *u8, count: usize): isize {
  unsafe { return xlang_sys_write(fd, buf, count); }
  return 0 as isize; // unreachable — typeck workaround
}
/** Exported function `io_libc_readv`.
 * Read path helper `io_libc_readv`.
 * @param fd i32
 * @param iov *Iovec
 * @param iovcnt i32
 * @return isize
 */
export function io_libc_readv(fd: i32, iov: *Iovec, iovcnt: i32): isize {
  unsafe { return xlang_sys_readv(fd, iov as *u8, iovcnt); }
  return 0 as isize; // unreachable — typeck workaround
}
/** Exported function `io_libc_writev`.
 * Write path helper `io_libc_writev`.
 * @param fd i32
 * @param iov *Iovec
 * @param iovcnt i32
 * @return isize
 */
export function io_libc_writev(fd: i32, iov: *Iovec, iovcnt: i32): isize {
  unsafe { return xlang_sys_writev(fd, iov as *u8, iovcnt); }
  return 0 as isize; // unreachable — typeck workaround
}
/** Exported function `io_libc_poll`.
 * Implements `io_libc_poll`.
 * @param fds *PollFd
 * @param nfds i32
 * @param timeout i32
 * @return i32
 */
export function io_libc_poll(fds: *PollFd, nfds: i32, timeout: i32): i32 {
  unsafe { return xlang_sys_poll(fds as *u8, nfds, timeout); }
  return 0; // unreachable — typeck workaround
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function io_read(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  if (timeout_ms > 0) {
    /* See implementation. */
  }
  return io_libc_read(fd, buf, count);
}

/**
 * See implementation.
 * See implementation.
 */
export function io_write(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  if (timeout_ms > 0) {
    /* See implementation. */
  }
  return io_libc_write(fd, buf, count);
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function io_read_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  if (n <= 0 || n > 4) {
    return -1 as isize;
  }
  if (n == 1) {
    return io_read(fd, p0, l0, timeout_ms);
  }
  if (timeout_ms == 0) {
    let iov: [4]Iovec;
    iov[0].base = p0;
    iov[0].length = l0;
    iov[1].base = p1;
    iov[1].length = l1;
    if (n >= 3) {
      iov[2].base = p2;
      iov[2].length = l2;
    }
    if (n >= 4) {
      iov[3].base = p3;
      iov[3].length = l3;
    }
    return io_libc_readv(fd, &iov[0], n);
  }
  let total: isize = 0;
  let r0: isize = io_read(fd, p0, l0, timeout_ms);
  if (r0 < 0) { return -1 as isize; }
  total = total + r0;
  if (n == 1) { return total; }
  let r1: isize = io_read(fd, p1, l1, timeout_ms);
  if (r1 < 0) { return -1 as isize; }
  total = total + r1;
  if (n == 2) { return total; }
  let r2: isize = io_read(fd, p2, l2, timeout_ms);
  if (r2 < 0) { return -1 as isize; }
  total = total + r2;
  if (n == 3) { return total; }
  let r3: isize = io_read(fd, p3, l3, timeout_ms);
  if (r3 < 0) { return -1 as isize; }
  return total + r3;
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function io_write_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  if (n <= 0 || n > 4) {
    return -1 as isize;
  }
  if (n == 1) {
    return io_write(fd, p0, l0, timeout_ms);
  }
  if (timeout_ms == 0) {
    let iov: [4]Iovec;
    iov[0].base = p0;
    iov[0].length = l0;
    iov[1].base = p1;
    iov[1].length = l1;
    if (n >= 3) {
      iov[2].base = p2;
      iov[2].length = l2;
    }
    if (n >= 4) {
      iov[3].base = p3;
      iov[3].length = l3;
    }
    return io_libc_writev(fd, &iov[0], n);
  }
  let total: isize = 0;
  let r0: isize = io_write(fd, p0, l0, timeout_ms);
  if (r0 < 0) { return -1 as isize; }
  total = total + r0;
  if (n == 1) { return total; }
  let r1: isize = io_write(fd, p1, l1, timeout_ms);
  if (r1 < 0) { return -1 as isize; }
  total = total + r1;
  if (n == 2) { return total; }
  let r2: isize = io_write(fd, p2, l2, timeout_ms);
  if (r2 < 0) { return -1 as isize; }
  total = total + r2;
  if (n == 3) { return total; }
  let r3: isize = io_write(fd, p3, l3, timeout_ms);
  if (r3 < 0) { return -1 as isize; }
  return total + r3;
}

/**
 * See implementation.
 */
export function io_read_batch_buf(fd: i32, bufs: *IoBatchBuf, n: i32, timeout_ms: u32): isize {
  if (n <= 0 || n > IO_READV_BUF_MAX || bufs == 0) {
    return -1 as isize;
  }
  if (n == 1) {
    return io_read(fd, bufs[0].ptr, bufs[0].length, timeout_ms);
  }
  if (timeout_ms == 0) {
    let iov: [16]Iovec;
    let i: i32 = 0;
    while (i < n) {
      iov[i].base = bufs[i].ptr;
      iov[i].length = bufs[i].length;
      i = i + 1;
    }
    return io_libc_readv(fd, &iov[0], n);
  }
  let total: isize = 0;
  let i2: i32 = 0;
  while (i2 < n) {
    let r: isize = io_read(fd, bufs[i2].ptr, bufs[i2].length, timeout_ms);
    if (r < 0) { return -1 as isize; }
    total = total + r;
    i2 = i2 + 1;
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
  if (n <= 0 || n > IO_READV_BUF_MAX || bufs == 0) {
    return -1 as isize;
  }
  if (n == 1) {
    return io_write(fd, bufs[0].ptr, bufs[0].length, timeout_ms);
  }
  if (timeout_ms == 0) {
    let iov: [16]Iovec;
    let i: i32 = 0;
    while (i < n) {
      iov[i].base = bufs[i].ptr;
      iov[i].length = bufs[i].length;
      i = i + 1;
    }
    return io_libc_writev(fd, &iov[0], n);
  }
  let total: isize = 0;
  let i2: i32 = 0;
  while (i2 < n) {
    let r: isize = io_write(fd, bufs[i2].ptr, bufs[i2].length, timeout_ms);
    if (r < 0) { return -1 as isize; }
    total = total + r;
    i2 = i2 + 1;
  }
  return total;
}

/**
 * See implementation.
 * See implementation.
 */
export function io_register_buffer(ptr: *u8, len: usize): i32 {
  return io_register_buffers_4(ptr, len, 0, 0, 0, 0, 0, 0, 1);
}

/**
 * See implementation.
 */
export function io_register_buffers_4(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, nr: u32): i32 {
  let i: u32 = 0;
  if (nr == 0 || nr > 4) {
    return 0;
  }
  io_fixed_nr = 0;
  if (nr >= 1) {
    if (p0 == 0) { return 0; }
    io_fixed_ptr[0] = p0;
    io_fixed_len[0] = l0;
    i = 1;
  }
  if (nr >= 2) {
    if (p1 == 0) { return 0; }
    io_fixed_ptr[1] = p1;
    io_fixed_len[1] = l1;
    i = 2;
  }
  if (nr >= 3) {
    if (p2 == 0) { return 0; }
    io_fixed_ptr[2] = p2;
    io_fixed_len[2] = l2;
    i = 3;
  }
  if (nr >= 4) {
    if (p3 == 0) { return 0; }
    io_fixed_ptr[3] = p3;
    io_fixed_len[3] = l3;
    i = 4;
  }
  io_fixed_nr = i;
  return 1;
}

/** Exported function `io_register_buffers_buf`.
 * Registration helper `io_register_buffers_buf`.
 * @param bufs *IoBatchBuf
 * @param nr i32
 * @return i32
 */
export function io_register_buffers_buf(bufs: *IoBatchBuf, nr: i32): i32 {
  /* See implementation. */
  let max_n: i32 = 8;
  if (nr <= 0 || nr > max_n || bufs == 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < nr) {
    let p: *u8 = bufs[i].ptr;
    let l: usize = bufs[i].length;
    if (p == 0 as *u8) {
      return 0;
    }
    if (i == 0) { io_fixed_ptr[0] = p; io_fixed_len[0] = l; }
    if (i == 1) { io_fixed_ptr[1] = p; io_fixed_len[1] = l; }
    if (i == 2) { io_fixed_ptr[2] = p; io_fixed_len[2] = l; }
    if (i == 3) { io_fixed_ptr[3] = p; io_fixed_len[3] = l; }
    if (i == 4) { io_fixed_ptr[4] = p; io_fixed_len[4] = l; }
    if (i == 5) { io_fixed_ptr[5] = p; io_fixed_len[5] = l; }
    if (i == 6) { io_fixed_ptr[6] = p; io_fixed_len[6] = l; }
    if (i == 7) { io_fixed_ptr[7] = p; io_fixed_len[7] = l; }
    i = i + 1;
  }
  io_fixed_nr = i as u32;
  return 1;
}

/** Exported function `io_unregister_buffers`.
 * Registration helper `io_unregister_buffers`.
 * @return void
 */
export function io_unregister_buffers(): void {
  io_fixed_nr = 0;
}

/**
 * See implementation.
 */
export function io_read_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  if (buf_index >= io_fixed_nr) {
    return -1 as isize;
  }
  let base: *u8 = io_fixed_ptr[buf_index];
  let cap: usize = io_fixed_len[buf_index];
  if (base == 0 || offset > cap || len > cap - offset) {
    return -1 as isize;
  }
  let addr: *u8 = base + offset;
  return io_read(fd, addr, len, timeout_ms);
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
  if (buf_index >= io_fixed_nr) {
    return -1 as isize;
  }
  let base: *u8 = io_fixed_ptr[buf_index];
  let cap: usize = io_fixed_len[buf_index];
  if (base == 0 || offset > cap || len > cap - offset) {
    return -1 as isize;
  }
  let addr: *u8 = base + offset;
  return io_write(fd, addr, len, timeout_ms);
}

/**
 * See implementation.
 * See implementation.
 */
export function io_wait_readable(fds: *i32, n: i32, timeout_ms: u32): i32 {
  if (fds == 0 || n <= 0 || n > 8) {
    return -1;
  }
  let pfd: [8]PollFd;
  let i: i32 = 0;
  while (i < n) {
    pfd[i].fd = fds[i];
    pfd[i].events = 1 as i16; /* POLLIN */
    pfd[i].revents = 0 as i16;
    i = i + 1;
  }
  let to: i32 = -1;
  if (timeout_ms > 0) {
    to = timeout_ms as i32;
  }
  let r: i32 = io_libc_poll(&pfd[0], n, to);
  if (r <= 0) {
    return -1;
  }
  i = 0;
  while (i < n) {
    if ((pfd[i].revents & 1) != 0 || (pfd[i].revents & 16) != 0) {
      return i;
    }
    i = i + 1;
  }
  return -1;
}
