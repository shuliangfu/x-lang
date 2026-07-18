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

// std.io.backend — F-03 v2/v3: IO C ABI aggregation layer (replaces io.c + io.o)
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

/* 【Why 根源治理】IoBatchBuf 和 ShuxSliceU8 不在此模块重定义。
 * IoBatchBuf 由 std.io.sync（io_platform）定义，ShuxSliceU8 由 std.io.read_ptr
 * （io_read_ptr_mod）定义。重定义会导致 codegen 生成不同的 C 类型名
 *（std_io_backend_IoBatchBuf vs std_io_sync_IoBatchBuf），引发跨模块类型冲突。
 * typeck 按名字解析 struct，codegen 的 codegen_emit_struct_type_name_only 会遍历
 * codegen_dep_mods 查找定义模块，自动使用正确的 C 前缀。 */

/* ─── 同步 read/write（转发平台模块）─── */

export function io_read(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  return io_platform.io_read(fd, buf, count, timeout_ms);
}

export function io_write(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  return io_platform.io_write(fd, buf, count, timeout_ms);
}

export function io_read_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  return io_platform.io_read_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

export function io_write_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  return io_platform.io_write_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

export function io_read_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): isize {
  let batch: *IoBatchBuf = bufs as *IoBatchBuf;
  return io_platform.io_read_batch_buf(fd, batch, n, timeout_ms);
}

export function io_write_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): isize {
  let batch: *IoBatchBuf = bufs as *IoBatchBuf;
  return io_platform.io_write_batch_buf(fd, batch, n, timeout_ms);
}

export function io_register_buffer(ptr: *u8, len: usize): i32 {
  return io_platform.io_register_buffer(ptr, len);
}

export function io_register_buffers_4(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, nr: u32): i32 {
  return io_platform.io_register_buffers_4(p0, l0, p1, l1, p2, l2, p3, l3, nr);
}

export function io_register_buffers_buf(bufs: *u8, nr: i32): i32 {
  let batch: *IoBatchBuf = bufs as *IoBatchBuf;
  return io_platform.io_register_buffers_buf(batch, nr);
}

export function io_unregister_buffers(): void {
  io_platform.io_unregister_buffers();
}

export function io_read_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  return io_platform.io_read_fixed(fd, buf_index, offset, len, timeout_ms);
}

export function io_write_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  return io_platform.io_write_fixed(fd, buf_index, offset, len, timeout_ms);
}

export function io_wait_readable(fds: *i32, n: i32, timeout_ms: u32): i32 {
  return io_platform.io_wait_readable(fds, n, timeout_ms);
}

/* ─── read_ptr（转发 io_read_ptr 模块）─── */

export function io_read_ptr(handle: usize, timeout_ms: u32): *u8 {
  return io_read_ptr_mod.io_read_ptr(handle, timeout_ms);
}

export function io_read_ptr_len(): i32 {
  return io_read_ptr_mod.io_read_ptr_len();
}

export function io_read_ptr_gen(): u64 {
  return io_read_ptr_mod.io_read_ptr_gen();
}

export function io_read_ptr_gen_valid(saved: u64): i32 {
  return io_read_ptr_mod.io_read_ptr_gen_valid(saved);
}

export function io_read_ptr_backend(): i32 {
  return io_read_ptr_mod.io_read_ptr_backend();
}

export function io_read_ptr_slice(handle: usize, timeout_ms: u32): u8[]<io_read_ptr> {
  let s: ShuxSliceU8 = io_read_ptr_mod.io_read_ptr_slice(handle, timeout_ms);
  let out: u8[]<io_read_ptr>;
  out.data = s.data;
  out.length = s.length;
  return out;
}

/* ─── provided / async / io_uring（转发 stubs）─── */

export function io_register_provided_buffers(nr: u32, bufsz: u32): i32 {
  return io_stubs_mod.io_register_provided_buffers(nr, bufsz);
}

export function io_unregister_provided_buffers(): void {
  io_stubs_mod.io_unregister_provided_buffers();
}

export function io_provided_buffer_ptr(bid: u32): *u8 {
  return io_stubs_mod.io_provided_buffer_ptr(bid);
}

export function io_provided_buffer_size(): u32 {
  return io_stubs_mod.io_provided_buffer_size();
}

export function io_read_provided(fd: i32, timeout_ms: u32, out_bid: *u32, out_len: *u32): isize {
  return io_stubs_mod.io_read_provided(fd, timeout_ms, out_bid, out_len);
}

export function io_read_batch_provided(fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): isize {
  return io_stubs_mod.io_read_batch_provided(fd, n, timeout_ms, out_bids, out_lens);
}

export function shux_io_submit_read_async(ptr: *u8, len: usize, handle: usize): i32 {
  return io_stubs_mod.shux_io_submit_read_async(ptr, len, handle);
}

export function shux_io_complete_read_async(): i32 {
  return io_stubs_mod.shux_io_complete_read_async();
}

export function shux_io_complete_read_async_slot(slot: i32): i32 {
  return io_stubs_mod.shux_io_complete_read_async_slot(slot);
}

export function shux_io_submit_write_async(ptr: *u8, len: usize, handle: usize): i32 {
  return io_stubs_mod.shux_io_submit_write_async(ptr, len, handle);
}

export function shux_io_complete_write_async(): i32 {
  return io_stubs_mod.shux_io_complete_write_async();
}

export function shux_io_complete_write_async_slot(slot: i32): i32 {
  return io_stubs_mod.shux_io_complete_write_async_slot(slot);
}

export function shux_io_poll_async_completions(timeout_ms: u32): u32 {
  return io_stubs_mod.shux_io_poll_async_completions(timeout_ms);
}

export function shux_io_uring_is_available_c(): i32 {
  return io_stubs_mod.shux_io_uring_is_available_c();
}

/* ─── bootstrap / asm 链接符号（原 io.c 弱符号，现常规导出）─── */

export function shux_io_register(ptr: *u8, len: usize, handle: usize): i32 {
  if (handle >= 0) {
    /* handle 暂未使用。 */
  }
  return io_register_buffer(ptr, len);
}

export function shux_io_submit_read(ptr: *u8, len: usize, handle: usize, timeout_ms: u32): i32 {
  let r: isize = io_read((handle as i32), ptr, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

export function shux_io_submit_write(ptr: *u8, len: usize, handle: usize, timeout_ms: u32): i32 {
  let r: isize = io_write((handle as i32), ptr, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

export function shux_io_read_ptr(handle: usize, timeout_ms: u32): *u8 {
  return io_read_ptr(handle, timeout_ms);
}

export function shux_io_read_ptr_len(): i32 {
  return io_read_ptr_len();
}

export function shux_io_read_ptr_gen(): u64 {
  return io_read_ptr_gen();
}

export function shux_io_read_ptr_gen_valid(saved: u64): i32 {
  return io_read_ptr_gen_valid(saved);
}

export function shux_io_read_ptr_backend(): i32 {
  return io_read_ptr_backend();
}

export function shux_io_read_ptr_slice(handle: usize, timeout_ms: u32): ShuxSliceU8 {
  return io_read_ptr_mod.io_read_ptr_slice(handle, timeout_ms);
}

/** std.io(mod)：fd 转 handle。 */
export function handle_from_fd(fd: i32, _unused: i32): usize {
  return (fd as usize);
}

export function shux_io_read_fixed(handle: usize, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  let r: isize = io_read_fixed((handle as i32), buf_index, offset, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

export function shux_io_write_fixed(handle: usize, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  let r: isize = io_write_fixed((handle as i32), buf_index, offset, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

export function shux_io_submit_read_batch(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, handle: usize, n: i32, timeout_ms: u32): i32 {
  if (!(handle == 0 || handle >= 2)) {
    return -1;
  }
  let r: isize = io_read_batch((handle as i32), p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

export function shux_io_submit_write_batch(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, handle: usize, n: i32, timeout_ms: u32): i32 {
  if (handle < 1) {
    return -1;
  }
  let r: isize = io_write_batch((handle as i32), p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

export function submit_read_batch_buf(handle: usize, bufs: *u8, n: i32, timeout_ms: u32): i32 {
  let r: isize = io_read_batch_buf((handle as i32), bufs, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

export function submit_write_batch_buf(handle: usize, bufs: *u8, n: i32, timeout_ms: u32): i32 {
  let r: isize = io_write_batch_buf((handle as i32), bufs, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

export function submit_register_fixed_buffers_buf(bufs: *u8, nr: u32): i32 {
  let ok: i32 = io_register_buffers_buf(bufs, (nr as i32));
  if (ok != 0) { return ok; }
  return 0;
}

export function shux_io_register_provided_buffers(nr: u32, bufsz: u32): i32 {
  return io_register_provided_buffers(nr, bufsz);
}

export function shux_io_unregister_provided_buffers(): void {
  io_unregister_provided_buffers();
}

export function shux_io_provided_buffer_ptr(bid: u32): *u8 {
  return io_provided_buffer_ptr(bid);
}

export function shux_io_provided_buffer_size(): u32 {
  return io_provided_buffer_size();
}

export function shux_io_read_batch_provided(handle: usize, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  if (!(handle == 0 || handle >= 2)) {
    return -1;
  }
  let r: isize = io_read_batch_provided((handle as i32), n, timeout_ms, out_bids, out_lens);
  if (r < 0) { return -1; }
  return (r as i32);
}

export function shux_io_read_provided(handle: usize, timeout_ms: u32, out_bid: *u32, out_len: *u32): i32 {
  if (!(handle == 0 || handle >= 2)) {
    return -1;
  }
  let r: isize = io_read_provided((handle as i32), timeout_ms, out_bid, out_len);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** 模块尾锚点：transitive import 解析。 */
export function io_backend_anchor(): i32 { return 0; }
