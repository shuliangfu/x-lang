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

// std.net.sock — F-04 v12：socket 生命周期与阻塞模式
//
// 【文件职责】
// 从 net.c 迁出 net_close_socket_c / net_set_blocking_c（TLS/ws 等共用）。
//
// 【依赖】libc close / fcntl / ioctlsocket

const O_NONBLOCK: i32 = 2048;

/** Unix poll 未使用；保留常量对齐 net.c。 */
const F_GETFL: i32 = 3;
const F_SETFL: i32 = 4;

extern function close(fd: i32): i32;

#[cfg(not(target_os = "windows"))]
extern function fcntl(fd: i32, cmd: i32, arg: i32): i32;

#[cfg(target_os = "windows")]
extern function closesocket(fd: i32): i32;

#[cfg(target_os = "windows")]
extern function ioctlsocket(fd: i32, cmd: i32, arg: *u32): i32;

/**
 * 内部：切换阻塞/非阻塞（Unix）；blocking=1 阻塞。
 * 顶层 cfg 分函数，避免函数体内 #[cfg] 触发 seed emit skip。
 */
#[cfg(not(target_os = "windows"))]
function net_sock_set_blocking_fd_c(fd: i32, blocking: i32): i32 {
  let flags: i32 = 0;
  unsafe { flags = fcntl(fd, F_GETFL, 0); }
  if (flags < 0) {
    return -1;
  }
  if (blocking != 0) {
    flags = flags & (0 - 1 - O_NONBLOCK);
  } else {
    flags = flags | O_NONBLOCK;
  }
  unsafe { if (fcntl(fd, F_SETFL, flags) == 0) {
    return 0;
  } }
  return -1;
}

/**
 * 内部：切换阻塞/非阻塞（Windows）；blocking=1 阻塞。
 */
#[cfg(target_os = "windows")]
function net_sock_set_blocking_fd_c(fd: i32, blocking: i32): i32 {
  let mode: u32 = 0;
  if (blocking == 0) {
    mode = 1;
  }
  unsafe { if (ioctlsocket(fd, (0x80000000 | 0x40000000) as i32, &mode) == 0) {
    return 0;
  } }
  return -1;
}

/**
 * 关闭 socket fd；Windows 用 closesocket。0 成功，-1 失败。
 */
function net_close_socket_c(fd: i32): i32 {
  if (fd < 0) {
    return 0;
  }
  #[cfg(not(target_os = "windows"))]
  {
    unsafe { if (close(fd) == 0) {
      return 0;
    } }
  }
  #[cfg(target_os = "windows")]
  {
    unsafe { if (closesocket(fd) == 0) {
      return 0;
    } }
  }
  return -1;
}

/**
 * 设置 socket 阻塞/非阻塞；blocking：1=阻塞，0=非阻塞。
 */
function net_set_blocking_c(fd: i32, blocking: i32): i32 {
  if (fd < 0) {
    return -1;
  }
  if (net_sock_set_blocking_fd_c(fd, blocking) == 0) {
    return 0;
  }
  return -1;
}
