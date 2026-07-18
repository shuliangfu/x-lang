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
export const FREESTANDING_AF_INET: i32 = 2;
export const FREESTANDING_SOCK_STREAM: i32 = 1;

/**
 * v1 探测：freestanding 网络 syscall 是否可用（1/0）。
 */
export function freestanding_net_available(): i32 {
  if (linux.linux_syscall_invoke_available() != 1) {
    return 0;
  }
  return 1;
}

/**
 * 创建 IPv4 TCP socket；成功返回 fd，失败 -1。
 */
export function freestanding_socket_tcp(): i32 {
  return linux.linux_syscall_socket(FREESTANDING_AF_INET, FREESTANDING_SOCK_STREAM, 0);
}

/**
 * connect(2) 薄封装。
 */
export function freestanding_connect(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  return linux.linux_syscall_connect(sockfd, addr, addrlen);
}

/**
 * bind(2) 薄封装。
 */
export function freestanding_bind(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  return linux.linux_syscall_bind(sockfd, addr, addrlen);
}

/**
 * listen(2) 薄封装。
 */
export function freestanding_listen(sockfd: i32, backlog: i32): i32 {
  return linux.linux_syscall_listen(sockfd, backlog);
}

/**
 * accept(2) 薄封装。
 */
export function freestanding_accept(sockfd: i32, addr: *u8, addrlen: *i32): i32 {
  return linux.linux_syscall_accept(sockfd, addr, addrlen);
}

/**
 * close(2) 薄封装。
 */
export function freestanding_close(sockfd: i32): i32 {
  return sys.close(sockfd);
}

/** 模块尾占位：transitive import 解析锚点。 */
export function freestanding_net_module_anchor(): i32 {
  return 0;
}
