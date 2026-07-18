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
//   const fs = import("std.fs.freestanding_linux");
// See implementation.

const sys = import("std.sys");
const linux = import("std.sys.linux");

/* See implementation. */
export const FREESTANDING_O_RDONLY: i32 = 0;

/**
 * See implementation.
 */
export function freestanding_fs_available(): i32 {
  if (linux.linux_syscall_invoke_available() != 1) {
    return 0;
  }
  return 1;
}

/**
 * See implementation.
 */
export function freestanding_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  return sys.read_file_into(path, buf, cap);
}

/**
 * See implementation.
 */
export function freestanding_open_read(path: *u8): i32 {
  return linux.linux_syscall_open(path, FREESTANDING_O_RDONLY, 0);
}

/**
 * See implementation.
 */
export function freestanding_read(fd: i32, buf: *u8, len: i32): i32 {
  return sys.read(fd, buf, len);
}

/**
 * See implementation.
 */
export function freestanding_write(fd: i32, buf: *u8, len: i32): i32 {
  return sys.write(fd, buf, len);
}

/**
 * See implementation.
 */
export function freestanding_close(fd: i32): i32 {
  return sys.close(fd);
}

/** Exported function `freestanding_fs_module_anchor`.
 * Memory management helper `freestanding_fs_module_anchor`.
 * @return i32
 */
export function freestanding_fs_module_anchor(): i32 {
  return 0;
}
