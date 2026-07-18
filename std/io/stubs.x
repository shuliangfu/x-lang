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

// std.io.stubs — F-03 v2/v3：io_uring/provided buffers/async 桩（graceful 回退 sync）
//
// 【文件职责】
// io_uring、IORING_OP_PROVIDE、非阻塞 async slot 等高级特性 v1 全部 stub；
// shux_io_uring_is_available_c 返回 0；调用方应回退 io_read/io_write 同步路径。

/** 注册 provided buffer 池：v1 不支持，返回 0。 */
export function io_register_provided_buffers(nr: u32, bufsz: u32): i32 {
  if (nr > 0 || bufsz > 0) {
    /* 保留参数，避免未使用警告。 */
  }
  return 0;
}

/** 注销 provided 池：v1 no-op。 */
export function io_unregister_provided_buffers(): void {
}

/** 无效 bid 返回 0。 */
export function io_provided_buffer_ptr(bid: u32): *u8 {
  if (bid > 0) {
    return 0 as *u8;
  }
  return 0 as *u8;
}

/** provided 单块容量：v1 返回 0。 */
export function io_provided_buffer_size(): u32 {
  return 0 as u32;
}

/** 单次 provided recv：v1 不支持，返回 -1。 */
export function io_read_provided(fd: i32, timeout_ms: u32, out_bid: *u32, out_len: *u32): isize {
  if (fd >= 0 || timeout_ms >= 0 || out_bid != 0 || out_len != 0) {
    /* ABI 占位。 */
  }
  return -1 as isize;
}

/** 批量 provided recv：v1 不支持。
 * 勿 #[no_mangle]：C 前端 path 前缀 + CALL 多路径尚未全裸名时，裸定义会与
 * std_io_stubs_* 调用点分裂。裸符号由 runtime_asm_io_stubs 弱桩提供给 net C 胶层。 */
export function io_read_batch_provided(fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): isize {
  if (fd >= 0 || n > 0 || timeout_ms >= 0 || out_bids != 0 || out_lens != 0) {
  }
  return -1 as isize;
}

/** 提交非阻塞 read async：v1 不支持，返回 -1。 */
export function shux_io_submit_read_async(ptr: *u8, len: usize, handle: usize): i32 {
  if (ptr != 0 && len > 0 && handle >= 0) {
    return -1;
  }
  return -1;
}

/** 收割 read async（无 slot）：v1 返回 -1。 */
export function shux_io_complete_read_async(): i32 {
  return -1;
}

/** 收割指定 slot read async：v1 返回 -1。 */
export function shux_io_complete_read_async_slot(slot: i32): i32 {
  if (slot >= 0) {
    return -1;
  }
  return -1;
}

/** 提交非阻塞 write async：v1 不支持。 */
export function shux_io_submit_write_async(ptr: *u8, len: usize, handle: usize): i32 {
  if (ptr != 0 && len > 0 && handle >= 0) {
    return -1;
  }
  return -1;
}

export function shux_io_complete_write_async(): i32 {
  return -1;
}

export function shux_io_complete_write_async_slot(slot: i32): i32 {
  if (slot >= 0) {
    return -1;
  }
  return -1;
}

/** poll io_uring async CQE：v1 无 CQE，返回 0。 */
export function shux_io_poll_async_completions(timeout_ms: u32): u32 {
  if (timeout_ms >= 0) {
  }
  return 0 as u32;
}

/** 当前线程 io_uring 是否可用：v1 恒 0。 */
export function shux_io_uring_is_available_c(): i32 {
  return 0;
}
