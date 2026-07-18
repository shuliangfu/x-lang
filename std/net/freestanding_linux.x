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
//   const net = import("std.net.freestanding_linux");

const linux = import("std.sys.linux");
const sys = import("std.sys");

/* See implementation. */
export const FREESTANDING_AF_INET: i32 = 2;
export const FREESTANDING_SOCK_STREAM: i32 = 1;

/**
 * See implementation.
 */
export function freestanding_net_available(): i32 {
  if (linux.linux_syscall_invoke_available() != 1) {
    return 0;
  }
  return 1;
}

/**
 * See implementation.
 */
export function freestanding_socket_tcp(): i32 {
  return linux.linux_syscall_socket(FREESTANDING_AF_INET, FREESTANDING_SOCK_STREAM, 0);
}

/**
 * See implementation.
 */
export function freestanding_connect(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  return linux.linux_syscall_connect(sockfd, addr, addrlen);
}

/**
 * See implementation.
 */
export function freestanding_bind(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  return linux.linux_syscall_bind(sockfd, addr, addrlen);
}

/**
 * See implementation.
 */
export function freestanding_listen(sockfd: i32, backlog: i32): i32 {
  return linux.linux_syscall_listen(sockfd, backlog);
}

/**
 * See implementation.
 */
export function freestanding_accept(sockfd: i32, addr: *u8, addrlen: *i32): i32 {
  return linux.linux_syscall_accept(sockfd, addr, addrlen);
}

/**
 * See implementation.
 */
export function freestanding_close(sockfd: i32): i32 {
  return sys.close(sockfd);
}

/** Exported function `freestanding_net_module_anchor`.
 * Memory management helper `freestanding_net_module_anchor`.
 * @return i32
 */
export function freestanding_net_module_anchor(): i32 {
  return 0;
}
