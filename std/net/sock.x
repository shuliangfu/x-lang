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
//
// See implementation.

/* 记230: Darwin O_NONBLOCK=4; Linux=2048 (was hardcoded 2048 on both). */
#[cfg(target_os = "macos")]
export const O_NONBLOCK: i32 = 4;
#[cfg(target_os = "linux")]
export const O_NONBLOCK: i32 = 2048;
#[cfg(target_os = "windows")]
export const O_NONBLOCK: i32 = 2048;

/* See implementation. */
export const F_GETFL: i32 = 3;
export const F_SETFL: i32 = 4;

extern "C" function close(fd: i32): i32;

#[cfg(not(target_os = "windows"))]
/* 记231: Darwin libc fcntl is variadic; Apple ARM64 puts 3rd+ on stack. */
extern "C" function fcntl(fd: i32, cmd: i32, ...): i32;
#[cfg(not(target_os = "windows"))]
/* 记231: Darwin libc ioctl is variadic; tip Apple va spill for 3rd+. */
extern "C" function ioctl(fd: i32, req: u64, ...): i32;

/**
 * FIONBIO request. The body is export function net_fionbio_c in
 * std/net/tcp.x. A second export is another strong _net_fionbio_c,
 * and Darwin ld -dead_strip dies on that duplicate.
 * @return u64 — platform FIONBIO request defined in tcp.x
 * PLATFORM: POSIX — macOS and Linux. Not Windows.
 */
#[cfg(not(target_os = "windows"))]
extern function net_fionbio_c(): u64;



#[cfg(target_os = "windows")]
extern "C" function closesocket(fd: i32): i32;

#[cfg(target_os = "windows")]
extern "C" function ioctlsocket(fd: i32, cmd: i32, arg: *u32): i32;

/**
 * See implementation.
 * See implementation.
 */
#[cfg(not(target_os = "windows"))]
export function net_sock_set_blocking_fd_c(fd: i32, blocking: i32): i32 {
  let on: i32 = 0;
  if (blocking == 0) {
    on = 1;
  }
  unsafe {
    if (ioctl(fd, net_fionbio_c(), &on) == 0) {
      return 0;
    }
  }
  return -1;
}

/**
 * See implementation.
 */
#[cfg(target_os = "windows")]
export function net_sock_set_blocking_fd_c(fd: i32, blocking: i32): i32 {
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
 * See implementation.
 */
export function net_close_socket_c(fd: i32): i32 {
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
 * See implementation.
 */
export function net_set_blocking_c(fd: i32, blocking: i32): i32 {
  if (fd < 0) {
    return -1;
  }
  if (net_sock_set_blocking_fd_c(fd, blocking) == 0) {
    return 0;
  }
  return -1;
}
