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
// net_tcp.x：net_tcp_connect_blocking_c、net_close_socket_c；libc：calloc/free。

/* See implementation. */
export const NET_TCP_POOL_MAX_IDLE: i32 = 8;

/* See implementation. */
allow(padding) struct NetTcpPool {
  addr_u32: u32;
  port_u32: u32;
  max_idle: i32;
  n_idle: i32;
  connect_count: i32;
  idle_fds: *i32;
}

extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function free(ptr: *u8): void;
/* See implementation. */
extern function net_tcp_connect_blocking_c(addr_u32: u32, port_u32: u32, timeout_ms: u32): i32;
/* See implementation. */
extern function net_close_socket_c(fd: i32): i32;

/** Exported function `pool_heap_alloc_c`.
 * Memory management helper `pool_heap_alloc_c`.
 * @param nmemb usize
 * @param size usize
 * @return *u8
 */
export function pool_heap_alloc_c(nmemb: usize, size: usize): *u8 {
  let p: *u8 = 0 as *u8;
  unsafe { p = calloc(nmemb, size); }
  return p;
}
/** Exported function `pool_heap_free_c`.
 * Memory management helper `pool_heap_free_c`.
 * @param ptr *u8
 * @return void
 */
export function pool_heap_free_c(ptr: *u8): void {
  unsafe { free(ptr); }
}
/** Exported function `pool_tcp_connect_c`.
 * Implements `pool_tcp_connect_c`.
 * @param addr_u32 u32
 * @param port_u32 u32
 * @param timeout_ms u32
 * @return i32
 */
export function pool_tcp_connect_c(addr_u32: u32, port_u32: u32, timeout_ms: u32): i32 {
  let fd: i32 = -1;
  unsafe { fd = net_tcp_connect_blocking_c(addr_u32, port_u32, timeout_ms); }
  return fd;
}
/** Exported function `pool_tcp_close_c`.
 * Implements `pool_tcp_close_c`.
 * @param fd i32
 * @return i32
 */
export function pool_tcp_close_c(fd: i32): i32 {
  let rc: i32 = -1;
  unsafe { rc = net_close_socket_c(fd); }
  return rc;
}

/**
 * See implementation.
 */
export function tcp_pool_ptr(pool_h: i64): *NetTcpPool {
  if (pool_h == 0) {
    return 0 as *NetTcpPool;
  }
  return pool_h as *NetTcpPool;
}

/**
 * See implementation.
 * See implementation.
 */
export function net_tcp_pool_create_c(addr_u32: u32, port_u32: u32, max_idle: i32): i64 {
  let mi: i32 = max_idle;
  if (mi <= 0) {
    mi = 1;
  }
  if (mi > NET_TCP_POOL_MAX_IDLE) {
    mi = NET_TCP_POOL_MAX_IDLE;
  }
  let pool_raw: *u8 = pool_heap_alloc_c(1, 32);
  if (pool_raw == 0) {
    return 0 as i64;
  }
  let idle_raw: *u8 = pool_heap_alloc_c(NET_TCP_POOL_MAX_IDLE as usize, 4);
  if (idle_raw == 0) {
    pool_heap_free_c(pool_raw);
    return 0 as i64;
  }
  let pool: *NetTcpPool = pool_raw as *NetTcpPool;
  pool.addr_u32 = addr_u32;
  pool.port_u32 = port_u32;
  pool.max_idle = mi;
  pool.n_idle = 0;
  pool.connect_count = 0;
  pool.idle_fds = idle_raw as *i32;
  let i: i32 = 0;
  while (i < NET_TCP_POOL_MAX_IDLE) {
    pool.idle_fds[i] = -1;
    i = i + 1;
  }
  return pool_raw as i64;
}

/**
 * See implementation.
 */
export function net_tcp_pool_drain_c(pool_h: i64): void {
  let pool: *NetTcpPool = tcp_pool_ptr(pool_h);
  if (pool == 0) {
    return;
  }
  let i: i32 = 0;
  while (i < pool.n_idle) {
    if (pool.idle_fds[i] >= 0) {
      pool_tcp_close_c(pool.idle_fds[i]);
    }
    pool.idle_fds[i] = -1;
    i = i + 1;
  }
  pool.n_idle = 0;
}

/**
 * See implementation.
 */
export function net_tcp_pool_destroy_c(pool_h: i64): void {
  let pool: *NetTcpPool = tcp_pool_ptr(pool_h);
  if (pool == 0) {
    return;
  }
  net_tcp_pool_drain_c(pool_h);
  if (pool.idle_fds != 0) {
    pool_heap_free_c(pool.idle_fds as *u8);
  }
  pool_heap_free_c(pool as *u8);
}

/**
 * See implementation.
 * See implementation.
 */
export function net_tcp_pool_acquire_c(pool_h: i64, timeout_ms: u32): i32 {
  let pool: *NetTcpPool = tcp_pool_ptr(pool_h);
  if (pool == 0) {
    return -1;
  }
  if (pool.n_idle > 0) {
    pool.n_idle = pool.n_idle - 1;
    let fd: i32 = pool.idle_fds[pool.n_idle];
    pool.idle_fds[pool.n_idle] = -1;
    return fd;
  }
  let fd: i32 = pool_tcp_connect_c(pool.addr_u32, pool.port_u32, timeout_ms);
  if (fd >= 0) {
    pool.connect_count = pool.connect_count + 1;
  }
  return fd;
}

/**
 * See implementation.
 * See implementation.
 */
export function net_tcp_pool_release_c(pool_h: i64, fd: i32): i32 {
  let pool: *NetTcpPool = tcp_pool_ptr(pool_h);
  if (pool == 0 || fd < 0) {
    return -1;
  }
  if (pool.n_idle >= pool.max_idle) {
    pool_tcp_close_c(fd);
    return 0;
  }
  pool.idle_fds[pool.n_idle] = fd;
  pool.n_idle = pool.n_idle + 1;
  return 0;
}

/**
 * See implementation.
 */
export function net_tcp_pool_connect_count_c(pool_h: i64): i32 {
  let pool: *NetTcpPool = tcp_pool_ptr(pool_h);
  if (pool == 0) {
    return -1;
  }
  return pool.connect_count;
}

/**
 * See implementation.
 */
export function net_tcp_pool_idle_count_c(pool_h: i64): i32 {
  let pool: *NetTcpPool = tcp_pool_ptr(pool_h);
  if (pool == 0) {
    return -1;
  }
  return pool.n_idle;
}

/**
 * See implementation.
 * See implementation.
 */
export function net_tcp_pool_smoke_c(): i32 {
  let pool_h: i64 = net_tcp_pool_create_c(0x7f000001, 9, 2);
  if (pool_h == 0) {
    return 1;
  }
  if (net_tcp_pool_connect_count_c(pool_h) != 0) {
    net_tcp_pool_destroy_c(pool_h);
    return 2;
  }
  if (net_tcp_pool_idle_count_c(pool_h) != 0) {
    net_tcp_pool_destroy_c(pool_h);
    return 3;
  }
  net_tcp_pool_destroy_c(pool_h);
  return 0;
}
