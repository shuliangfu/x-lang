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

// std.net.freestanding_linux — Linux freestanding 网络 syscall 门面（零 libc / 不链 net.c）
//
// 【文件职责】
// F-no-libc NL-02：经 std.sys.linux 提供 socket/connect/bind/listen/accept 最小 API；
// 供 `-freestanding` 烟测与后续 std.net 迁移使用。
//
// 【用法】
//   const net = import("std.net.freestanding_linux");

const linux = import("std.sys.linux");
const sys = import("std.sys");

/** Linux socket 常量（与 std.sys.linux 一致，避免模块 const 字段访问）。 */
const FREESTANDING_AF_INET: i32 = 2;
const FREESTANDING_SOCK_STREAM: i32 = 1;

/**
 * v1 探测：freestanding 网络 syscall 是否可用（1/0）。
 */
function freestanding_net_available(): i32 {
  if (linux.linux_syscall_invoke_available() != 1) {
    return 0;
  }
  return 1;
}

/**
 * 创建 IPv4 TCP socket；成功返回 fd，失败 -1。
 */
function freestanding_socket_tcp(): i32 {
  return linux.linux_syscall_socket(FREESTANDING_AF_INET, FREESTANDING_SOCK_STREAM, 0);
}

/**
 * connect(2) 薄封装。
 */
function freestanding_connect(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  return linux.linux_syscall_connect(sockfd, addr, addrlen);
}

/**
 * bind(2) 薄封装。
 */
function freestanding_bind(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  return linux.linux_syscall_bind(sockfd, addr, addrlen);
}

/**
 * listen(2) 薄封装。
 */
function freestanding_listen(sockfd: i32, backlog: i32): i32 {
  return linux.linux_syscall_listen(sockfd, backlog);
}

/**
 * accept(2) 薄封装。
 */
function freestanding_accept(sockfd: i32, addr: *u8, addrlen: *i32): i32 {
  return linux.linux_syscall_accept(sockfd, addr, addrlen);
}

/**
 * close(2) 薄封装。
 */
function freestanding_close(sockfd: i32): i32 {
  return sys.close(sockfd);
}

/** 模块尾占位：transitive import 解析锚点。 */
function freestanding_net_module_anchor(): i32 {
  return 0;
}
