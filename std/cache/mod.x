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

/* See implementation. */
allow(padding) struct LruCache {
  handle: i64;
}

/* See implementation. */
allow(padding) struct ObjPool {
  handle: i64;
}

/* See implementation. */
allow(padding) struct CacheStats {
  hits: i64;
  misses: i64;
  evictions: i64;
  size: i32;
}

/* See implementation. */
allow(padding) struct PoolStats {
  idle: i32;
  in_use: i32;
  unhealthy: i32;
  acquires: i64;
}

/** Exported function `err_ok`.
 * Implements `err_ok`.
 * @return i32
 */
export function err_ok(): i32 { return 0; }
/** Exported function `err_null`.
 * Implements `err_null`.
 * @return i32
 */
export function err_null(): i32 { return -1; }
/** Exported function `err_not_found`.
 * Implements `err_not_found`.
 * @return i32
 */
export function err_not_found(): i32 { return -2; }
/** Exported function `err_full`.
 * Implements `err_full`.
 * @return i32
 */
export function err_full(): i32 { return -3; }
/** Exported function `err_invalid`.
 * Implements `err_invalid`.
 * @return i32
 */
export function err_invalid(): i32 { return -4; }

extern function cache_lru_create_c(capacity: i32): i64;
extern function cache_lru_free_c(handle: i64): void;
extern function cache_lru_get_c(handle: i64, key: i64, out_value: *i64): i32;
extern function cache_lru_put_c(handle: i64, key: i64, value: i64, ttl_ns: i64): i32;
extern function cache_lru_remove_c(handle: i64, key: i64): i32;
extern function cache_lru_purge_expired_c(handle: i64): i32;
extern function cache_lru_stats_c(handle: i64, hits: *i64, misses: *i64, evictions: *i64, size: *i32): void;

extern function cache_pool_create_c(max_slots: i32): i64;
extern function cache_pool_free_c(handle: i64): void;
extern function cache_pool_add_c(handle: i64, resource: i64): i32;
extern function cache_pool_acquire_c(handle: i64, out_resource: *i64): i32;
extern function cache_pool_release_c(handle: i64, resource: i64): i32;
extern function cache_pool_mark_unhealthy_c(handle: i64, resource: i64): i32;
extern function cache_pool_idle_c(handle: i64): i32;
extern function cache_pool_stats_c(handle: i64, idle: *i32, in_use: *i32, unhealthy: *i32, acquires: *i64): void;

/** Exported function `new_lru`.
 * Implements `new_lru`.
 * @param capacity i32
 * @return LruCache
 */
export function new_lru(capacity: i32): LruCache {
  unsafe {
    let h: i64 = cache_lru_create_c(capacity);
    return LruCache { handle: h };
  }
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param c *LruCache
 * @return void
 */
export function free(c: *LruCache): void {
  let zero: i64 = 0;
  if (c == 0) { return; }
  if (c.handle != zero) {
    unsafe { cache_lru_free_c(c.handle); }
    c.handle = zero;
  }
}

/** Exported function `get`.
 * Implements `get`.
 * @param c *LruCache
 * @param key i64
 * @param out *i64
 * @return i32
 */
export function get(c: *LruCache, key: i64, out: *i64): i32 {
  let zero: i64 = 0;
  if (c == 0 || c.handle == zero || out == 0) { return err_null(); }
  unsafe {
    return cache_lru_get_c(c.handle, key, out);
  }
}

/** Exported function `put`.
 * Implements `put`.
 * @param c *LruCache
 * @param key i64
 * @param value i64
 * @param ttl_ns i64
 * @return i32
 */
export function put(c: *LruCache, key: i64, value: i64, ttl_ns: i64): i32 {
  let zero: i64 = 0;
  if (c == 0 || c.handle == zero) { return err_null(); }
  unsafe {
    return cache_lru_put_c(c.handle, key, value, ttl_ns);
  }
}

/** Exported function `remove`.
 * Implements `remove`.
 * @param c *LruCache
 * @param key i64
 * @return i32
 */
export function remove(c: *LruCache, key: i64): i32 {
  let zero: i64 = 0;
  if (c == 0 || c.handle == zero) { return err_null(); }
  unsafe {
    return cache_lru_remove_c(c.handle, key);
  }
}

/** Exported function `purge`.
 * Implements `purge`.
 * @param c *LruCache
 * @return i32
 */
export function purge(c: *LruCache): i32 {
  let zero: i64 = 0;
  if (c == 0 || c.handle == zero) { return err_null(); }
  unsafe {
    return cache_lru_purge_expired_c(c.handle);
  }
}

/** Exported function `stats`.
 * Implements `stats`.
 * @param c *LruCache
 * @param out *CacheStats
 * @return void
 */
export function stats(c: *LruCache, out: *CacheStats): void {
  let zero: i64 = 0;
  if (c == 0 || c.handle == zero || out == 0) { return; }
  unsafe {
    cache_lru_stats_c(c.handle, &out.hits, &out.misses, &out.evictions, &out.size);
  }
}

/** Exported function `new`.
 * Implements `new`.
 * @param max_slots i32
 * @return ObjPool
 */
export function new(max_slots: i32): ObjPool {
  unsafe {
    let h: i64 = cache_pool_create_c(max_slots);
    return ObjPool { handle: h };
  }
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param p *ObjPool
 * @return void
 */
export function free(p: *ObjPool): void {
  let zero: i64 = 0;
  if (p == 0) { return; }
  if (p.handle != zero) {
    unsafe { cache_pool_free_c(p.handle); }
    p.handle = zero;
  }
}

/** Exported function `add`.
 * Implements `add`.
 * @param p *ObjPool
 * @param resource i64
 * @return i32
 */
export function add(p: *ObjPool, resource: i64): i32 {
  let zero: i64 = 0;
  if (p == 0 || p.handle == zero || resource == zero) { return err_null(); }
  unsafe {
    return cache_pool_add_c(p.handle, resource);
  }
}

/** Exported function `acquire`.
 * Implements `acquire`.
 * @param p *ObjPool
 * @param out *i64
 * @return i32
 */
export function acquire(p: *ObjPool, out: *i64): i32 {
  let zero: i64 = 0;
  if (p == 0 || p.handle == zero || out == 0) { return err_null(); }
  unsafe {
    return cache_pool_acquire_c(p.handle, out);
  }
}

/** Exported function `release`.
 * Implements `release`.
 * @param p *ObjPool
 * @param resource i64
 * @return i32
 */
export function release(p: *ObjPool, resource: i64): i32 {
  let zero: i64 = 0;
  if (p == 0 || p.handle == zero || resource == zero) { return err_null(); }
  unsafe {
    return cache_pool_release_c(p.handle, resource);
  }
}

/** Exported function `mark_unhealthy`.
 * Implements `mark_unhealthy`.
 * @param p *ObjPool
 * @param resource i64
 * @return i32
 */
export function mark_unhealthy(p: *ObjPool, resource: i64): i32 {
  let zero: i64 = 0;
  if (p == 0 || p.handle == zero || resource == zero) { return err_null(); }
  unsafe {
    return cache_pool_mark_unhealthy_c(p.handle, resource);
  }
}

/** Exported function `idle`.
 * Implements `idle`.
 * @param p *ObjPool
 * @return i32
 */
export function idle(p: *ObjPool): i32 {
  let zero: i64 = 0;
  if (p == 0 || p.handle == zero) { return err_null(); }
  unsafe {
    return cache_pool_idle_c(p.handle);
  }
}

/** Exported function `stats`.
 * Implements `stats`.
 * @param p *ObjPool
 * @param out *PoolStats
 * @return void
 */
export function stats(p: *ObjPool, out: *PoolStats): void {
  let zero: i64 = 0;
  if (p == 0 || p.handle == zero || out == 0) { return; }
  unsafe {
    cache_pool_stats_c(p.handle, &out.idle, &out.in_use, &out.unhealthy, &out.acquires);
  }
}
