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

// std.io — Read/Write and std streams API (API layer of the io stack; use with std.fs for batch I/O).
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
const driver = import("std.io.driver");
const core = import("std.io.core");
const context = import("std.context");
const err = import("std.error");
// See implementation.
export struct ReadOnlySlice {
  data: u8[]
}
export struct WriteOnlySlice {
  data: u8[]
}
/**
 * See implementation.
 * See implementation.
 */
allow(padding) struct ReadPtrView {
  ptr: *u8;
  len: i32;
  gen: u64;
}
// See implementation.
// See implementation.
export trait Reader {
  /** Internal function `read`.
   * Read path helper `read`.
   * @param self
   * @return i32;
   */
  function read(self): i32;
}
export trait Writer {
  /** Internal function `write`.
   * Write path helper `write`.
   * @param self
   * @return i32;
   */
  function write(self): i32;
}
// See implementation.
// See implementation.
// See implementation.
// stdin: see function docblock below.
/** Exported function `stdin`.
 * Implements `stdin`.
 * @return usize
 */
export function stdin(): usize { return 0 as usize; }
/** Exported function `stdout`.
 * Implements `stdout`.
 * @return usize
 */
export function stdout(): usize { return 1; }
/** Exported function `stderr`.
 * Implements `stderr`.
 * @return usize
 */
export function stderr(): usize { return 2; }
/* See implementation. */
/** Exported function `from_fd`.
 * Implements `from_fd`.
 * @param fd i32
 * @param _unused i32): usize { return (fd as usize
 * @return void
 */
export function from_fd(fd: i32, _unused: i32): usize { return (fd as usize); }
// See implementation.
// read: see function docblock below.
/** Exported function `read`.
 * Read path helper `read`.
 * @param handle usize
 * @param ptr *u8
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function read(handle: usize, ptr: *u8, len: usize, timeout_ms: u32): i32 {
  let buf: Buffer = Buffer { ptr: ptr, len: len, handle: handle };
  return driver.submit_read(buf, timeout_ms);
}
// write: see function docblock below.
/** Exported function `write`.
 * Write path helper `write`.
 * @param handle usize
 * @param ptr *u8
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function write(handle: usize, ptr: *u8, len: usize, timeout_ms: u32): i32 {
  let buf: Buffer = Buffer { ptr: ptr, len: len, handle: handle };
  return driver.submit_write(buf, timeout_ms);
}
// See implementation.
/* See implementation. */
export const IO_CTX_MS_CANCELLED: i32 = -1;
/* See implementation. */
export const IO_CTX_MS_EXPIRED: i32 = -2;
/** Exported function `timeout_from_ctx`.
 * Implements `timeout_from_ctx`.
 * @param ctx Context
 * @return i32
 */
export function timeout_from_ctx(ctx: context.Context): i32 {
  if (context.is_cancelled(ctx) != 0) {
    return IO_CTX_MS_CANCELLED;
  }
  let rem: i64 = context.remaining_ns(ctx);
  let dl: i64 = context.deadline_ns(ctx);
  if (dl > 0 && rem <= 0) {
    return IO_CTX_MS_EXPIRED;
  }
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
/** Exported function `read_ctx`.
 * Read path helper `read_ctx`.
 * @param handle usize
 * @param ptr *u8
 * @param len usize
 * @param ctx Context
 * @return i32
 */
export function read_ctx(handle: usize, ptr: *u8, len: usize, ctx: context.Context): i32 {
  let tm: i32 = timeout_from_ctx(ctx);
  if (tm == IO_CTX_MS_CANCELLED) {
    return err.io_err_cancelled();
  }
  if (tm == IO_CTX_MS_EXPIRED) {
    return err.io_err_timeout();
  }
  return read(handle, ptr, len, tm as u32);
}
/** Exported function `write_ctx`.
 * Write path helper `write_ctx`.
 * @param handle usize
 * @param ptr *u8
 * @param len usize
 * @param ctx Context
 * @return i32
 */
export function write_ctx(handle: usize, ptr: *u8, len: usize, ctx: context.Context): i32 {
  let tm: i32 = timeout_from_ctx(ctx);
  if (tm == IO_CTX_MS_CANCELLED) {
    return err.io_err_cancelled();
  }
  if (tm == IO_CTX_MS_EXPIRED) {
    return err.io_err_timeout();
  }
  return write(handle, ptr, len, tm as u32);
}
// read_stdin: see function docblock below.
/** Exported function `read_stdin`.
 * Read path helper `read_stdin`.
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function read_stdin(ptr: *u8, len: usize): i32 {
  return read(stdin(), ptr, len, 0 as u32);
}
/** Exported function `read_ptr`.
 * Read path helper `read_ptr`.
 * @param handle usize
 * @param timeout_ms u32
 * @return *u8
 */
export function read_ptr(handle: usize, timeout_ms: u32): *u8 {
  return driver.driver_read_ptr(handle, timeout_ms);
}
/** Exported function `ptr_len`.
 * Query helper `ptr_len`.
 * @return i32
 */
export function ptr_len(): i32 {
  return driver.driver_read_ptr_len();
}
/**
 * See implementation.
 * See implementation.
 */
export function ptr_gen(): u64 {
  return driver.driver_read_ptr_gen();
}
/** Exported function `ptr_valid`.
 * Implements `ptr_valid`.
 * @param saved u64
 * @return i32
 */
export function ptr_valid(saved: u64): i32 {
  return driver.driver_read_ptr_gen_valid(saved);
}
/** Exported function `ptr_backend`.
 * Implements `ptr_backend`.
 * @return i32
 */
export function ptr_backend(): i32 {
  return driver.driver_read_ptr_backend();
}
/**
 * See implementation.
 * See implementation.
 */
export function ptr_view(handle: usize, timeout_ms: u32): ReadPtrView {
  let p: *u8 = read_ptr(handle, timeout_ms);
  let n: i32 = ptr_len();
  let g: u64 = ptr_gen();
  return ReadPtrView { ptr: p, len: n, gen: g };
}
/** Exported function `ptr_view_valid`.
 * Implements `ptr_view_valid`.
 * @param v ReadPtrView
 * @return i32
 */
export function ptr_view_valid(v: ReadPtrView): i32 {
  if (v.ptr == 0) {
    return 0;
  }
  return ptr_valid(v.gen);
}
/** Exported function `stdin_ptr_view`.
 * Implements `stdin_ptr_view`.
 * @return ReadPtrView
 */
export function stdin_ptr_view(): ReadPtrView {
  return ptr_view(stdin(), 0 as u32);
}
/**
 * See implementation.
 * See implementation.
 */
export function ptr_slice(handle: usize, timeout_ms: u32): u8[]<io_read_ptr> {
  return driver.driver_read_ptr_slice(handle, timeout_ms);
}
/** Exported function `stdin_slice`.
 * Implements `stdin_slice`.
 * @return u8[]<io_read_ptr>
 */
export function stdin_slice(): u8[]<io_read_ptr> {
  return driver.driver_read_ptr_slice(stdin(), 0 as u32);
}
/** Exported function `read_stdin_ptr`.
 * Read path helper `read_stdin_ptr`.
 * @return *u8
 */
export function read_stdin_ptr(): *u8 {
  return read_ptr(stdin(), 0 as u32);
}
/** Exported function `write_stdout`.
 * Write path helper `write_stdout`.
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function write_stdout(ptr: *u8, len: usize): i32 {
  return write(stdout(), ptr, len, 0 as u32);
}
/** Exported function `write_stderr`.
 * Write path helper `write_stderr`.
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function write_stderr(ptr: *u8, len: usize): i32 {
  return write(stderr(), ptr, len, 0 as u32);
}
// See implementation.
/** Exported function `read`.
 * Read path helper `read`.
 * @param ptr *u8
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function read(ptr: *u8, len: usize, timeout_ms: u32): i32 {
  return read(stdin(), ptr, len, timeout_ms);
}
/** Exported function `write`.
 * Write path helper `write`.
 * @param ptr *u8
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function write(ptr: *u8, len: usize, timeout_ms: u32): i32 {
  return write(stdout(), ptr, len, timeout_ms);
}
// See implementation.
/** Exported function `write_stderr`.
 * Write path helper `write_stderr`.
 * @param ptr *u8
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function write_stderr(ptr: *u8, len: usize, timeout_ms: u32): i32 {
  return write(stderr(), ptr, len, timeout_ms);
}
// See implementation.
// See implementation.
/** Exported function `read_fd`.
 * Read path helper `read_fd`.
 * @param fd i32
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function read_fd(fd: i32, ptr: *u8, len: usize): i32 {
  return read(from_fd(fd, 0), ptr, len, 0 as u32);
}
/** Exported function `write_fd`.
 * Write path helper `write_fd`.
 * @param fd i32
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function write_fd(fd: i32, ptr: *u8, len: usize): i32 {
  return write(from_fd(fd, 0), ptr, len, 0 as u32);
}
/** Exported function `read_batch_fd`.
 * Read path helper `read_batch_fd`.
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
 * @return i32
 */
export function read_batch_fd(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32): i32 {
  let h: usize = from_fd(fd, 0);
  let bufs: Buffer[4] = [
    Buffer { ptr: p0, len: l0, handle: h },
    Buffer { ptr: p1, len: l1, handle: h },
    Buffer { ptr: p2, len: l2, handle: h },
    Buffer { ptr: p3, len: l3, handle: h }
  ];
  return driver.submit_read_batch(bufs, n, 0 as u32);
}
/** Exported function `write_batch_fd`.
 * Write path helper `write_batch_fd`.
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
 * @return i32
 */
export function write_batch_fd(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32): i32 {
  let h: usize = from_fd(fd, 0);
  let bufs: Buffer[4] = [
    Buffer { ptr: p0, len: l0, handle: h },
    Buffer { ptr: p1, len: l1, handle: h },
    Buffer { ptr: p2, len: l2, handle: h },
    Buffer { ptr: p3, len: l3, handle: h }
  ];
  return driver.submit_write_batch(bufs, n, 0 as u32);
}
/** Exported function `readv`.
 * Read path helper `readv`.
 * @param fd i32
 * @param buffers *Buffer
 * @param n i32
 * @return i32
 */
export function readv(fd: i32, buffers: *Buffer, n: i32): i32 {
  let h: usize = from_fd(fd, 0);
  return driver.submit_read_batch_buf(h, buffers, n, 0 as u32);
}
/** Exported function `writev`.
 * Write path helper `writev`.
 * @param fd i32
 * @param buffers *Buffer
 * @param n i32
 * @return i32
 */
export function writev(fd: i32, buffers: *Buffer, n: i32): i32 {
  let h: usize = from_fd(fd, 0);
  return driver.submit_write_batch_buf(h, buffers, n, 0 as u32);
}
// See implementation.
// register_buffers: see function docblock below.
/** Exported function `register_buffers`.
 * Registration helper `register_buffers`.
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
export function register_buffers(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, nr: u32): i32 {
  return core.xlang_io_register_buffers(p0, l0, p1, l1, p2, l2, p3, l3, nr);
}
/** Exported function `register_buffers`.
 * Registration helper `register_buffers`.
 * @param bufs *Buffer
 * @param nr u32
 * @return i32
 */
export function register_buffers(bufs: *Buffer, nr: u32): i32 {
  return driver.submit_register_fixed_buffers_buf(bufs, nr);
}
/** Exported function `read_fixed_fd`.
 * Read path helper `read_fixed_fd`.
 * @param fd i32
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function read_fixed_fd(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  return core.xlang_io_read_fixed(from_fd(fd, 0), buf_index, offset, len, timeout_ms);
}
/** Exported function `write_fixed_fd`.
 * Write path helper `write_fixed_fd`.
 * @param fd i32
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function write_fixed_fd(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  return core.xlang_io_write_fixed(from_fd(fd, 0), buf_index, offset, len, timeout_ms);
}
// ─── ZC-1 Provided Buffers：IORING_OP_PROVIDE_BUFFERS + buffer ring（Linux 5.19+）───
// See implementation.
/** Exported function `register_provided`.
 * Registration helper `register_provided`.
 * @param nr u32
 * @param bufsz u32
 * @return i32
 */
export function register_provided(nr: u32, bufsz: u32): i32 {
  return core.xlang_io_register_provided_buffers(nr, bufsz);
}
/** Exported function `unregister_provided`.
 * Registration helper `unregister_provided`.
 * @return void
 */
export function unregister_provided(): void {
  core.xlang_io_unregister_provided_buffers();
}
/** Exported function `provided_buffer_ptr`.
 * Implements `provided_buffer_ptr`.
 * @param bid u32
 * @return *u8
 */
export function provided_buffer_ptr(bid: u32): *u8 {
  return core.xlang_io_provided_buffer_ptr(bid);
}
/** Exported function `provided_buffer_size`.
 * Implements `provided_buffer_size`.
 * @return u32
 */
export function provided_buffer_size(): u32 {
  return core.xlang_io_provided_buffer_size();
}
/** Exported function `read_provided_fd`.
 * Read path helper `read_provided_fd`.
 * @param fd i32
 * @param timeout_ms u32
 * @param out_bid *u32
 * @param out_len *u32
 * @return i32
 */
export function read_provided_fd(fd: i32, timeout_ms: u32, out_bid: *u32, out_len: *u32): i32 {
  return core.xlang_io_read_provided(from_fd(fd, 0), timeout_ms, out_bid, out_len);
}
/** Exported function `read_batch_provided_fd`.
 * Read path helper `read_batch_provided_fd`.
 * @param fd i32
 * @param n i32
 * @param timeout_ms u32
 * @param out_bids *u32
 * @param out_lens *u32
 * @return i32
 */
export function read_batch_provided_fd(fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  return core.xlang_io_read_batch_provided(from_fd(fd, 0), n, timeout_ms, out_bids, out_lens);
}
// wait_readable: see function docblock below.
/** Exported function `wait_readable`.
 * Read path helper `wait_readable`.
 * @param fds *i32
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function wait_readable(fds: *i32, n: i32, timeout_ms: u32): i32 {
  return core.xlang_io_wait_readable(fds, n, timeout_ms);
}
// See implementation.
// See implementation.
export const IO_ASYNC_NOT_READY: i32 = -2;
/** Exported function `read_async`.
 * Read path helper `read_async`.
 * @param handle usize
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function read_async(handle: usize, ptr: *u8, len: usize): i32 {
  return core.xlang_io_submit_read_async(ptr, len, handle);
}
/** Exported function `complete_read`.
 * Read path helper `complete_read`.
 * @return i32
 */
export function complete_read(): i32 {
  return core.xlang_io_complete_read_async();
}
/** Exported function `complete_read`.
 * Read path helper `complete_read`.
 * @param slot i32
 * @return i32
 */
export function complete_read(slot: i32): i32 {
  return core.xlang_io_complete_read_async_slot(slot);
}
/** Exported function `write_async`.
 * Write path helper `write_async`.
 * @param handle usize
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function write_async(handle: usize, ptr: *u8, len: usize): i32 {
  return core.xlang_io_submit_write_async(ptr, len, handle);
}
/** Exported function `complete_write`.
 * Write path helper `complete_write`.
 * @return i32
 */
export function complete_write(): i32 {
  return core.xlang_io_complete_write_async();
}
/** Exported function `complete_write`.
 * Write path helper `complete_write`.
 * @param slot i32
 * @return i32
 */
export function complete_write(slot: i32): i32 {
  return core.xlang_io_complete_write_async_slot(slot);
}
/** Exported function `poll_completions`.
 * Implements `poll_completions`.
 * @param timeout_ms u32
 * @return u32
 */
export function poll_completions(timeout_ms: u32): u32 {
  return core.xlang_io_poll_async_completions(timeout_ms);
}
/** Exported function `uring_ok`.
 * Implements `uring_ok`.
 * @return i32
 */
export function uring_ok(): i32 {
  return core.xlang_io_uring_is_available_c();
}
// read_slice: see function docblock below.
/** Exported function `read_slice`.
 * Read path helper `read_slice`.
 * @param buf u8[]
 * @param timeout_ms u32
 * @return i32
 */
export function read_slice(buf: u8[], timeout_ms: u32): i32 {
  return read(stdin(), buf.data, buf.length, timeout_ms);
}
// write_slice: see function docblock below.
/** Exported function `write_slice`.
 * Write path helper `write_slice`.
 * @param buf u8[]
 * @param timeout_ms u32
 * @return i32
 */
export function write_slice(buf: u8[], timeout_ms: u32): i32 {
  return write(stdout(), buf.data, buf.length, timeout_ms);
}
// See implementation.
/** Internal function `print_i64_nl`.
 * Implements `print_i64_nl`.
 * @param v i64
 * @return i32
 */
function print_i64_nl(v: i64): i32 {
  let buf: u8[24] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let tmp: u8[24] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = 0;
  let pos: i32 = 0;
  let x: i64 = v;
  if (x == 0) {
    buf[0] = 48 as u8;
    buf[1] = 10 as u8;
    let _w0: i32 = write_stdout(&buf[0], 2 as usize);
    return 0;
  }
  if (x < 0) {
    buf[0] = 45 as u8;
    pos = 1;
    /* See implementation. */
    x = 0 as i64 - x;
  }
  while (x > 0) {
    tmp[n] = (48 + (x % (10 as i64))) as u8;
    n = n + 1;
    x = x / (10 as i64);
  }
  while (n > 0) {
    n = n - 1;
    buf[pos] = tmp[n];
    pos = pos + 1;
  }
  buf[pos] = 10 as u8;
  pos = pos + 1;
  let _w: i32 = write_stdout(&buf[0], pos as usize);
  return 0;
}
/** Exported function `io_module_anchor`.
 * Implements `io_module_anchor`.
 * @return i32
 */
export function io_module_anchor(): i32 { return 0; }
