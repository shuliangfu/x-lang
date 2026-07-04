// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// std.io.backend — F-03 v2/v3：舒 IO C ABI 聚合层（替代 io.c + io.o）
//
// 【文件职责】
// 导出 core.x / driver.x 所需的 io_* 符号；按平台 cfg 转发 sync/win32；
// read_ptr / stubs 子模块；bootstrap 链接符号（原 io.c 弱符号）在此提供常规函数体。
//
// 【链接】
// 无独立 io.o；符号由 codegen 编入用户程序或 std_io*.o；-lc（POSIX）/ kernel32（Windows）。

#[cfg(target_os = "linux")]
const io_platform = import("std.io.sync");
#[cfg(target_os = "macos")]
const io_platform = import("std.io.sync");
#[cfg(target_os = "windows")]
const io_platform = import("std.io.win32");

const io_read_ptr_mod = import("std.io.read_ptr");
const io_stubs_mod = import("std.io.stubs");

/** 与 driver Buffer ABI 一致。 */
allow(padding) struct IoBatchBuf { ptr: *u8; len: usize; handle: usize; }

/** M-5 slice 视图（与 io_read_ptr 模块一致）。 */
allow(padding) struct ShuxSliceU8 { data: *u8; length: usize; }

/* ─── 同步 read/write（转发平台模块）─── */

function io_read(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  return io_platform.io_read(fd, buf, count, timeout_ms);
}

function io_write(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  return io_platform.io_write(fd, buf, count, timeout_ms);
}

function io_read_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  return io_platform.io_read_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

function io_write_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  return io_platform.io_write_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

function io_read_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): isize {
  let batch: *IoBatchBuf = bufs as *IoBatchBuf;
  return io_platform.io_read_batch_buf(fd, batch, n, timeout_ms);
}

function io_write_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): isize {
  let batch: *IoBatchBuf = bufs as *IoBatchBuf;
  return io_platform.io_write_batch_buf(fd, batch, n, timeout_ms);
}

function io_register_buffer(ptr: *u8, len: usize): i32 {
  return io_platform.io_register_buffer(ptr, len);
}

function io_register_buffers_4(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, nr: u32): i32 {
  return io_platform.io_register_buffers_4(p0, l0, p1, l1, p2, l2, p3, l3, nr);
}

function io_register_buffers_buf(bufs: *u8, nr: i32): i32 {
  let batch: *IoBatchBuf = bufs as *IoBatchBuf;
  return io_platform.io_register_buffers_buf(batch, nr);
}

function io_unregister_buffers(): void {
  io_platform.io_unregister_buffers();
}

function io_read_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  return io_platform.io_read_fixed(fd, buf_index, offset, len, timeout_ms);
}

function io_write_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  return io_platform.io_write_fixed(fd, buf_index, offset, len, timeout_ms);
}

function io_wait_readable(fds: *i32, n: i32, timeout_ms: u32): i32 {
  return io_platform.io_wait_readable(fds, n, timeout_ms);
}

/* ─── read_ptr（转发 io_read_ptr 模块）─── */

function io_read_ptr(handle: usize, timeout_ms: u32): *u8 {
  return io_read_ptr_mod.io_read_ptr(handle, timeout_ms);
}

function io_read_ptr_len(): i32 {
  return io_read_ptr_mod.io_read_ptr_len();
}

function io_read_ptr_gen(): u64 {
  return io_read_ptr_mod.io_read_ptr_gen();
}

function io_read_ptr_gen_valid(saved: u64): i32 {
  return io_read_ptr_mod.io_read_ptr_gen_valid(saved);
}

function io_read_ptr_backend(): i32 {
  return io_read_ptr_mod.io_read_ptr_backend();
}

function io_read_ptr_slice(handle: usize, timeout_ms: u32): u8[]<io_read_ptr> {
  let s: ShuxSliceU8 = io_read_ptr_mod.io_read_ptr_slice(handle, timeout_ms);
  let out: u8[]<io_read_ptr>;
  out.data = s.data;
  out.length = s.length;
  return out;
}

/* ─── provided / async / io_uring（转发 stubs）─── */

function io_register_provided_buffers(nr: u32, bufsz: u32): i32 {
  return io_stubs_mod.io_register_provided_buffers(nr, bufsz);
}

function io_unregister_provided_buffers(): void {
  io_stubs_mod.io_unregister_provided_buffers();
}

function io_provided_buffer_ptr(bid: u32): *u8 {
  return io_stubs_mod.io_provided_buffer_ptr(bid);
}

function io_provided_buffer_size(): u32 {
  return io_stubs_mod.io_provided_buffer_size();
}

function io_read_provided(fd: i32, timeout_ms: u32, out_bid: *u32, out_len: *u32): isize {
  return io_stubs_mod.io_read_provided(fd, timeout_ms, out_bid, out_len);
}

function io_read_batch_provided(fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): isize {
  return io_stubs_mod.io_read_batch_provided(fd, n, timeout_ms, out_bids, out_lens);
}

function shux_io_submit_read_async(ptr: *u8, len: usize, handle: usize): i32 {
  return io_stubs_mod.shux_io_submit_read_async(ptr, len, handle);
}

function shux_io_complete_read_async(): i32 {
  return io_stubs_mod.shux_io_complete_read_async();
}

function shux_io_complete_read_async_slot(slot: i32): i32 {
  return io_stubs_mod.shux_io_complete_read_async_slot(slot);
}

function shux_io_submit_write_async(ptr: *u8, len: usize, handle: usize): i32 {
  return io_stubs_mod.shux_io_submit_write_async(ptr, len, handle);
}

function shux_io_complete_write_async(): i32 {
  return io_stubs_mod.shux_io_complete_write_async();
}

function shux_io_complete_write_async_slot(slot: i32): i32 {
  return io_stubs_mod.shux_io_complete_write_async_slot(slot);
}

function shux_io_poll_async_completions(timeout_ms: u32): u32 {
  return io_stubs_mod.shux_io_poll_async_completions(timeout_ms);
}

function shux_io_uring_is_available_c(): i32 {
  return io_stubs_mod.shux_io_uring_is_available_c();
}

/* ─── bootstrap / asm 链接符号（原 io.c 弱符号，现常规导出）─── */

function shux_io_register(ptr: *u8, len: usize, handle: usize): i32 {
  if (handle >= 0) {
    /* handle 暂未使用。 */
  }
  return io_register_buffer(ptr, len);
}

function shux_io_submit_read(ptr: *u8, len: usize, handle: usize, timeout_ms: u32): i32 {
  let r: isize = io_read((handle as i32), ptr, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

function shux_io_submit_write(ptr: *u8, len: usize, handle: usize, timeout_ms: u32): i32 {
  let r: isize = io_write((handle as i32), ptr, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

function shux_io_read_ptr(handle: usize, timeout_ms: u32): *u8 {
  return io_read_ptr(handle, timeout_ms);
}

function shux_io_read_ptr_len(): i32 {
  return io_read_ptr_len();
}

function shux_io_read_ptr_gen(): u64 {
  return io_read_ptr_gen();
}

function shux_io_read_ptr_gen_valid(saved: u64): i32 {
  return io_read_ptr_gen_valid(saved);
}

function shux_io_read_ptr_backend(): i32 {
  return io_read_ptr_backend();
}

function shux_io_read_ptr_slice(handle: usize, timeout_ms: u32): ShuxSliceU8 {
  return io_read_ptr_mod.io_read_ptr_slice(handle, timeout_ms);
}

/** std.io(mod)：fd 转 handle。 */
function handle_from_fd(fd: i32, _unused: i32): usize {
  return (fd as usize);
}

function shux_io_read_fixed(handle: usize, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  let r: isize = io_read_fixed((handle as i32), buf_index, offset, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

function shux_io_write_fixed(handle: usize, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  let r: isize = io_write_fixed((handle as i32), buf_index, offset, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

function shux_io_submit_read_batch(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, handle: usize, n: i32, timeout_ms: u32): i32 {
  if (!(handle == 0 || handle >= 2)) {
    return -1;
  }
  let r: isize = io_read_batch((handle as i32), p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

function shux_io_submit_write_batch(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, handle: usize, n: i32, timeout_ms: u32): i32 {
  if (handle < 1) {
    return -1;
  }
  let r: isize = io_write_batch((handle as i32), p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

function submit_read_batch_buf(handle: usize, bufs: *u8, n: i32, timeout_ms: u32): i32 {
  let r: isize = io_read_batch_buf((handle as i32), bufs, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

function submit_write_batch_buf(handle: usize, bufs: *u8, n: i32, timeout_ms: u32): i32 {
  let r: isize = io_write_batch_buf((handle as i32), bufs, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

function submit_register_fixed_buffers_buf(bufs: *u8, nr: u32): i32 {
  let ok: i32 = io_register_buffers_buf(bufs, (nr as i32));
  if (ok != 0) { return ok; }
  return 0;
}

function shux_io_register_provided_buffers(nr: u32, bufsz: u32): i32 {
  return io_register_provided_buffers(nr, bufsz);
}

function shux_io_unregister_provided_buffers(): void {
  io_unregister_provided_buffers();
}

function shux_io_provided_buffer_ptr(bid: u32): *u8 {
  return io_provided_buffer_ptr(bid);
}

function shux_io_provided_buffer_size(): u32 {
  return io_provided_buffer_size();
}

function shux_io_read_batch_provided(handle: usize, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  if (!(handle == 0 || handle >= 2)) {
    return -1;
  }
  let r: isize = io_read_batch_provided((handle as i32), n, timeout_ms, out_bids, out_lens);
  if (r < 0) { return -1; }
  return (r as i32);
}

function shux_io_read_provided(handle: usize, timeout_ms: u32, out_bid: *u32, out_len: *u32): i32 {
  if (!(handle == 0 || handle >= 2)) {
    return -1;
  }
  let r: isize = io_read_provided((handle as i32), timeout_ms, out_bid, out_len);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** 模块尾锚点：transitive import 解析。 */
function io_backend_anchor(): i32 { return 0; }
