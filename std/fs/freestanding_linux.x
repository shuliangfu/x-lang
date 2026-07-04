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

// std.fs.freestanding_linux — Linux freestanding 文件 IO（零 libc / 不链 fs.c）
//
// 【文件职责】
// F-no-libc NL-04：经 std.sys syscall 提供最小 read/open/close/write；
// 供 `-freestanding -backend asm` 与编译器自举读源码路径使用。
//
// 【用法】
//   const fs = import("std.fs.freestanding_linux");
// 勿在 freestanding 程序中 import 完整 std.fs（会拉 libc extern）。

const sys = import("std.sys");
const linux = import("std.sys.linux");

/** Linux O_RDONLY（与 linux.x 一致）。 */
const FREESTANDING_O_RDONLY: i32 = 0;

/**
 * v1 探测：freestanding fs 是否在 Linux 可用（1/0）。
 */
function freestanding_fs_available(): i32 {
  if (linux.linux_syscall_invoke_available() != 1) {
    return 0;
  }
  return 1;
}

/**
 * 读整文件到 buf[0..cap)（循环 read 至 EOF 或 cap）；成功返回字节数，失败 -1。
 */
function freestanding_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  return sys.read_file_into(path, buf, cap);
}

/**
 * 只读打开 path（NUL 结尾）；失败返回 -1。
 */
function freestanding_open_read(path: *u8): i32 {
  return linux.linux_syscall_open(path, FREESTANDING_O_RDONLY, 0);
}

/**
 * 从 fd 读最多 len 字节到 buf；返回读入字节数，0=EOF，-1=错误。
 */
function freestanding_read(fd: i32, buf: *u8, len: i32): i32 {
  return sys.read(fd, buf, len);
}

/**
 * 写 fd；返回写入字节数，-1=错误。
 */
function freestanding_write(fd: i32, buf: *u8, len: i32): i32 {
  return sys.write(fd, buf, len);
}

/**
 * 关闭 fd；成功 0，失败 -1。
 */
function freestanding_close(fd: i32): i32 {
  return sys.close(fd);
}

/** 模块尾占位：transitive import 解析锚点。 */
function freestanding_fs_module_anchor(): i32 {
  return 0;
}
