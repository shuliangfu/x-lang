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

#[cfg(target_os = "linux")]
const io_sync = import("std.io.sync");
#[cfg(target_os = "macos")]
const io_sync = import("std.io.sync");
#[cfg(target_os = "windows")]
const io_sync = import("std.io.win32");

/* See implementation. */
export const IO_READ_PTR_BUF_SIZE: usize = 65536;

/* See implementation. */
allow(padding) struct XlangSliceU8 { data: *u8; length: usize; }

/* See implementation. */
let g_io_read_ptr_buf: u8[65536] = [];
let g_io_read_ptr_len: i32 = 0;
let g_io_read_ptr_gen: u64 = 0 as u64;
let g_io_read_ptr_backend: i32 = 0;

/**
 * Read into the module buffer and return its address.
 * The installed product cannot asm-emit this *u8 return.
 * @param handle usize — file descriptor widened to a handle
 * @param timeout_ms u32 — wait budget forwarded to the platform read
 * @return i64 — buffer address in rax, or 0 when the read fails
 * PLATFORM: SHARED
 */
export function io_read_ptr(handle: usize, timeout_ms: u32): i64 {
  g_io_read_ptr_gen = g_io_read_ptr_gen + 1;
  g_io_read_ptr_backend = 0;
  let fd: i32 = (handle as i32);
  let r: isize = io_sync.io_read(fd, &g_io_read_ptr_buf[0], IO_READ_PTR_BUF_SIZE, timeout_ms);
  if (r < 0) {
    g_io_read_ptr_len = 0;
    return 0;
  }
  g_io_read_ptr_len = (r as i32);
  let p: *u8 = &g_io_read_ptr_buf[0];
  return p as i64;
}

/** Exported function `io_read_ptr_len`.
 * Read path helper `io_read_ptr_len`.
 * @return i32
 */
export function io_read_ptr_len(): i32 {
  return g_io_read_ptr_len;
}

/**
 * Return the generation counter for the last read.
 * @return i64 — counter bits in rax. Low 64 bits match the stored u64.
 * PLATFORM: SHARED — the installed product cannot asm-emit this u64 return.
 */
export function io_read_ptr_gen(): i64 {
  return g_io_read_ptr_gen as i64;
}

/** Exported function `io_read_ptr_gen_valid`.
 * Read path helper `io_read_ptr_gen_valid`.
 * @param saved u64
 * @return i32
 */
export function io_read_ptr_gen_valid(saved: u64): i32 {
  if (saved == g_io_read_ptr_gen) {
    return 1;
  }
  return 0;
}

/** Exported function `io_read_ptr_backend`.
 * Read path helper `io_read_ptr_backend`.
 * @return i32
 */
export function io_read_ptr_backend(): i32 {
  return g_io_read_ptr_backend;
}

/**
 * Read into the module buffer and write the slice through out.
 * A 16-byte struct return uses rax and rdx, so the installed product cannot asm-emit it.
 * @param handle usize — file descriptor widened to a handle
 * @param timeout_ms u32 — wait budget forwarded to the platform read
 * @param out *XlangSliceU8 — caller storage for data and length; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function io_read_ptr_slice(handle: usize, timeout_ms: u32, out: *XlangSliceU8): i32 {
  let bits: i64 = io_read_ptr(handle, timeout_ms);
  let p: *u8 = bits as *u8;
  out.data = p;
  if (p != 0) {
    out.length = (g_io_read_ptr_len as usize);
  } else {
    out.length = 0;
  }
  return 0;
}
