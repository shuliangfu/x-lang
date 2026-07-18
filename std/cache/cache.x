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

export const CACHE_OK: i32 = 0;
export const CACHE_ERR_NULL: i32 = -1;
export const CACHE_ERR_NOT_FOUND: i32 = -2;
export const CACHE_ERR_FULL: i32 = -3;
export const CACHE_ERR_INVALID: i32 = -4;

export const LRU_MAX_NODES: i32 = 64;
export const POOL_MAX_SLOTS: i32 = 32;
export const LRU_NODE_SIZE: usize = 40;
export const LRU_CACHE_MEM_SIZE: usize = 2600;
export const OBJ_POOL_MEM_SIZE: usize = 544;

/* See implementation. */
allow(padding) struct LruNode {
  key: i64;
  value: i64;
  expire_ns: i64;
  prev: i32;
  next: i32;
  used: i32;
}

/* See implementation. */
allow(padding) struct LruCacheMem {
  nodes: LruNode[64];
  capacity: i32;
  count: i32;
  head: i32;
  tail: i32;
  hits: i64;
  misses: i64;
  evictions: i64;
}

/* See implementation. */
allow(padding) struct PoolSlot {
  resource: i64;
  idle: i32;
  healthy: i32;
}

/* See implementation. */
allow(padding) struct ObjPoolMem {
  slots: PoolSlot[32];
  max_slots: i32;
  idle_count: i32;
  acquire_count: i64;
  release_count: i64;
  health_fail: i64;
}

extern function time_now_monotonic_ns_c(): i64;
extern "C" function memset(s: *u8, c: i32, n: usize): *u8;
extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function free(ptr: *u8): void;

/** Exported function `cache_f_cache_v1_marker_c`.
 * Implements `cache_f_cache_v1_marker_c`.
 * @return i32
 */
export function cache_f_cache_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `cache_f_cache_v2_marker_c`.
 * Implements `cache_f_cache_v2_marker_c`.
 * @return i32
 */
export function cache_f_cache_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `lru_from_handle`.
 * Implements `lru_from_handle`.
 * @param h i64
 * @return *LruCacheMem
 */
export function lru_from_handle(h: i64): *LruCacheMem {
  if (h == 0) { return 0 as *LruCacheMem; }
  return h as *LruCacheMem;
}

/** Exported function `pool_from_handle`.
 * Implements `pool_from_handle`.
 * @param h i64
 * @return *ObjPoolMem
 */
export function pool_from_handle(h: i64): *ObjPoolMem {
  if (h == 0) { return 0 as *ObjPoolMem; }
  return h as *ObjPoolMem;
}

/** Exported function `lru_alloc_node`.
 * Memory management helper `lru_alloc_node`.
 * @param c *LruCacheMem
 * @return i32
 */
export function lru_alloc_node(c: *LruCacheMem): i32 {
  let i: i32 = 0;
  while (i < LRU_MAX_NODES) {
    if (c.nodes[i].used == 0) { return i; }
    i = i + 1;
  }
  return -1;
}

/** Exported function `lru_touch`.
 * Implements `lru_touch`.
 * @param c *LruCacheMem
 * @param idx i32
 * @return void
 */
export function lru_touch(c: *LruCacheMem, idx: i32): void {
  let p: i32 = 0;
  let n: i32 = 0;
  if (idx < 0 || c.nodes[idx].used == 0) { return; }
  if (c.head == idx) { return; }
  p = c.nodes[idx].prev;
  n = c.nodes[idx].next;
  if (p >= 0) { c.nodes[p].next = n; }
  if (n >= 0) { c.nodes[n].prev = p; }
  if (c.tail == idx) { c.tail = p; }
  c.nodes[idx].prev = -1;
  c.nodes[idx].next = c.head;
  if (c.head >= 0) { c.nodes[c.head].prev = idx; }
  c.head = idx;
  if (c.tail < 0) { c.tail = idx; }
}

/** Exported function `lru_find`.
 * Implements `lru_find`.
 * @param c *LruCacheMem
 * @param key i64
 * @return i32
 */
export function lru_find(c: *LruCacheMem, key: i64): i32 {
  let i: i32 = 0;
  while (i < LRU_MAX_NODES) {
    if (c.nodes[i].used != 0 && c.nodes[i].key == key) { return i; }
    i = i + 1;
  }
  return -1;
}

/** Exported function `lru_remove_node`.
 * Implements `lru_remove_node`.
 * @param c *LruCacheMem
 * @param idx i32
 * @return void
 */
export function lru_remove_node(c: *LruCacheMem, idx: i32): void {
  let p: i32 = 0;
  let n: i32 = 0;
  if (idx < 0 || c.nodes[idx].used == 0) { return; }
  p = c.nodes[idx].prev;
  n = c.nodes[idx].next;
  if (p >= 0) { c.nodes[p].next = n; }
  else { c.head = n; }
  if (n >= 0) { c.nodes[n].prev = p; }
  else { c.tail = p; }
  c.nodes[idx].key = 0;
  c.nodes[idx].value = 0;
  c.nodes[idx].expire_ns = 0;
  c.nodes[idx].prev = -1;
  c.nodes[idx].next = -1;
  c.nodes[idx].used = 0;
  c.count = c.count - 1;
}

/** Exported function `lru_evict_lru`.
 * Implements `lru_evict_lru`.
 * @param c *LruCacheMem
 * @return i32
 */
export function lru_evict_lru(c: *LruCacheMem): i32 {
  let idx: i32 = c.tail;
  if (idx < 0) { return -1; }
  lru_remove_node(c, idx);
  c.evictions = c.evictions + 1;
  return 0;
}

/** Exported function `lru_expire_if_needed`.
 * Implements `lru_expire_if_needed`.
 * @param c *LruCacheMem
 * @param idx i32
 * @return i32
 */
export function lru_expire_if_needed(c: *LruCacheMem, idx: i32): i32 {
  let now: i64 = 0;
  if (idx < 0 || c.nodes[idx].used == 0) { return 0; }
  if (c.nodes[idx].expire_ns == 0) { return 0; }
  unsafe { now = time_now_monotonic_ns_c(); }
  if (now >= c.nodes[idx].expire_ns) {
    lru_remove_node(c, idx);
    return 1;
  }
  return 0;
}

/** Exported function `cache_lru_create_c`.
 * Implements `cache_lru_create_c`.
 * @param capacity i32
 * @return i64
 */
export function cache_lru_create_c(capacity: i32): i64 {
  let c: *LruCacheMem = 0;
  if (capacity <= 0 || capacity > LRU_MAX_NODES) { return 0; }
  unsafe { c = calloc(1, LRU_CACHE_MEM_SIZE) as *LruCacheMem; }
  if (c == 0) { return 0; }
  c.capacity = capacity;
  c.head = -1;
  c.tail = -1;
  return c as i64;
}

/** Exported function `cache_lru_free_c`.
 * Memory management helper `cache_lru_free_c`.
 * @param handle i64
 * @return void
 */
export function cache_lru_free_c(handle: i64): void {
  let c: *LruCacheMem = lru_from_handle(handle);
  if (c != 0) { unsafe { free(c as *u8); } }
}

/** Exported function `cache_lru_get_c`.
 * Implements `cache_lru_get_c`.
 * @param handle i64
 * @param key i64
 * @param out_value *i64
 * @return i32
 */
export function cache_lru_get_c(handle: i64, key: i64, out_value: *i64): i32 {
  let c: *LruCacheMem = lru_from_handle(handle);
  let idx: i32 = 0;
  if (c == 0 || out_value == 0) { return CACHE_ERR_NULL; }
  idx = lru_find(c, key);
  if (idx < 0) {
    c.misses = c.misses + 1;
    return CACHE_ERR_NOT_FOUND;
  }
  if (lru_expire_if_needed(c, idx) != 0) {
    c.misses = c.misses + 1;
    return CACHE_ERR_NOT_FOUND;
  }
  out_value[0] = c.nodes[idx].value;
  lru_touch(c, idx);
  c.hits = c.hits + 1;
  return CACHE_OK;
}

/** Exported function `cache_lru_put_c`.
 * Implements `cache_lru_put_c`.
 * @param handle i64
 * @param key i64
 * @param value i64
 * @param ttl_ns i64
 * @return i32
 */
export function cache_lru_put_c(handle: i64, key: i64, value: i64, ttl_ns: i64): i32 {
  let c: *LruCacheMem = lru_from_handle(handle);
  let idx: i32 = 0;
  let expire: i64 = 0;
  if (c == 0) { return CACHE_ERR_NULL; }
  if (ttl_ns > 0) { unsafe { expire = time_now_monotonic_ns_c() + ttl_ns; } }
  idx = lru_find(c, key);
  if (idx >= 0) {
    c.nodes[idx].value = value;
    c.nodes[idx].expire_ns = expire;
    lru_touch(c, idx);
    return CACHE_OK;
  }
  while (c.count >= c.capacity) {
    if (lru_evict_lru(c) != 0) { return CACHE_ERR_FULL; }
  }
  idx = lru_alloc_node(c);
  if (idx < 0) { return CACHE_ERR_FULL; }
  c.nodes[idx].key = key;
  c.nodes[idx].value = value;
  c.nodes[idx].expire_ns = expire;
  c.nodes[idx].used = 1;
  c.nodes[idx].prev = -1;
  c.nodes[idx].next = c.head;
  if (c.head >= 0) { c.nodes[c.head].prev = idx; }
  c.head = idx;
  if (c.tail < 0) { c.tail = idx; }
  c.count = c.count + 1;
  return CACHE_OK;
}

/** Exported function `cache_lru_remove_c`.
 * Implements `cache_lru_remove_c`.
 * @param handle i64
 * @param key i64
 * @return i32
 */
export function cache_lru_remove_c(handle: i64, key: i64): i32 {
  let c: *LruCacheMem = lru_from_handle(handle);
  let idx: i32 = 0;
  if (c == 0) { return CACHE_ERR_NULL; }
  idx = lru_find(c, key);
  if (idx < 0) { return CACHE_ERR_NOT_FOUND; }
  lru_remove_node(c, idx);
  return CACHE_OK;
}

/** Exported function `cache_lru_purge_expired_c`.
 * Implements `cache_lru_purge_expired_c`.
 * @param handle i64
 * @return i32
 */
export function cache_lru_purge_expired_c(handle: i64): i32 {
  let c: *LruCacheMem = lru_from_handle(handle);
  let i: i32 = 0;
  let n: i32 = 0;
  if (c == 0) { return CACHE_ERR_NULL; }
  while (i < LRU_MAX_NODES) {
    if (c.nodes[i].used != 0 && c.nodes[i].expire_ns > 0) {
      if (lru_expire_if_needed(c, i) != 0) { n = n + 1; }
    }
    i = i + 1;
  }
  return n;
}

/** Exported function `cache_lru_stats_c`.
 * Implements `cache_lru_stats_c`.
 * @param handle i64
 * @param hits *i64
 * @param misses *i64
 * @param evictions *i64
 * @param size *i32
 * @return void
 */
export function cache_lru_stats_c(handle: i64, hits: *i64, misses: *i64, evictions: *i64, size: *i32): void {
  let c: *LruCacheMem = lru_from_handle(handle);
  if (c == 0) { return; }
  if (hits != 0) { *hits = c.hits; }
  if (misses != 0) { *misses = c.misses; }
  if (evictions != 0) { *evictions = c.evictions; }
  if (size != 0) { *size = c.count; }
}

/** Exported function `cache_pool_create_c`.
 * Implements `cache_pool_create_c`.
 * @param max_slots i32
 * @return i64
 */
export function cache_pool_create_c(max_slots: i32): i64 {
  let p: *ObjPoolMem = 0;
  if (max_slots <= 0 || max_slots > POOL_MAX_SLOTS) { return 0; }
  unsafe { p = calloc(1, OBJ_POOL_MEM_SIZE) as *ObjPoolMem; }
  if (p == 0) { return 0; }
  p.max_slots = max_slots;
  return p as i64;
}

/** Exported function `cache_pool_free_c`.
 * Memory management helper `cache_pool_free_c`.
 * @param handle i64
 * @return void
 */
export function cache_pool_free_c(handle: i64): void {
  let p: *ObjPoolMem = pool_from_handle(handle);
  if (p != 0) { unsafe { free(p as *u8); } }
}

/** Exported function `cache_pool_add_c`.
 * Implements `cache_pool_add_c`.
 * @param handle i64
 * @param resource i64
 * @return i32
 */
export function cache_pool_add_c(handle: i64, resource: i64): i32 {
  let p: *ObjPoolMem = pool_from_handle(handle);
  let i: i32 = 0;
  if (p == 0 || resource == 0) { return CACHE_ERR_NULL; }
  if (p.idle_count >= p.max_slots) { return CACHE_ERR_FULL; }
  i = 0;
  while (i < POOL_MAX_SLOTS) {
    if (p.slots[i].resource == resource) { return CACHE_ERR_INVALID; }
    i = i + 1;
  }
  i = 0;
  while (i < POOL_MAX_SLOTS) {
    if (p.slots[i].resource == 0) {
      p.slots[i].resource = resource;
      p.slots[i].idle = 1;
      p.slots[i].healthy = 1;
      p.idle_count = p.idle_count + 1;
      return CACHE_OK;
    }
    i = i + 1;
  }
  return CACHE_ERR_FULL;
}

/** Exported function `cache_pool_acquire_c`.
 * Implements `cache_pool_acquire_c`.
 * @param handle i64
 * @param out_resource *i64
 * @return i32
 */
export function cache_pool_acquire_c(handle: i64, out_resource: *i64): i32 {
  let p: *ObjPoolMem = pool_from_handle(handle);
  let i: i32 = 0;
  if (p == 0 || out_resource == 0) { return CACHE_ERR_NULL; }
  i = 0;
  while (i < POOL_MAX_SLOTS) {
    if (p.slots[i].resource != 0 && p.slots[i].idle != 0 && p.slots[i].healthy != 0) {
      p.slots[i].idle = 0;
      p.idle_count = p.idle_count - 1;
      out_resource[0] = p.slots[i].resource;
      p.acquire_count = p.acquire_count + 1;
      return CACHE_OK;
    }
    i = i + 1;
  }
  return CACHE_ERR_NOT_FOUND;
}

/** Exported function `cache_pool_release_c`.
 * Implements `cache_pool_release_c`.
 * @param handle i64
 * @param resource i64
 * @return i32
 */
export function cache_pool_release_c(handle: i64, resource: i64): i32 {
  let p: *ObjPoolMem = pool_from_handle(handle);
  let i: i32 = 0;
  if (p == 0 || resource == 0) { return CACHE_ERR_NULL; }
  i = 0;
  while (i < POOL_MAX_SLOTS) {
    if (p.slots[i].resource == resource) {
      if (p.slots[i].idle != 0) { return CACHE_ERR_INVALID; }
      if (p.slots[i].healthy == 0) {
        p.slots[i].resource = 0;
        p.health_fail = p.health_fail + 1;
        return CACHE_OK;
      }
      p.slots[i].idle = 1;
      p.idle_count = p.idle_count + 1;
      p.release_count = p.release_count + 1;
      return CACHE_OK;
    }
    i = i + 1;
  }
  return CACHE_ERR_NOT_FOUND;
}

/** Exported function `cache_pool_mark_unhealthy_c`.
 * Implements `cache_pool_mark_unhealthy_c`.
 * @param handle i64
 * @param resource i64
 * @return i32
 */
export function cache_pool_mark_unhealthy_c(handle: i64, resource: i64): i32 {
  let p: *ObjPoolMem = pool_from_handle(handle);
  let i: i32 = 0;
  if (p == 0 || resource == 0) { return CACHE_ERR_NULL; }
  i = 0;
  while (i < POOL_MAX_SLOTS) {
    if (p.slots[i].resource == resource) {
      p.slots[i].healthy = 0;
      return CACHE_OK;
    }
    i = i + 1;
  }
  return CACHE_ERR_NOT_FOUND;
}

/** Exported function `cache_pool_idle_c`.
 * Implements `cache_pool_idle_c`.
 * @param handle i64
 * @return i32
 */
export function cache_pool_idle_c(handle: i64): i32 {
  let p: *ObjPoolMem = pool_from_handle(handle);
  if (p == 0) { return CACHE_ERR_NULL; }
  return p.idle_count;
}

/** Exported function `cache_pool_stats_c`.
 * Implements `cache_pool_stats_c`.
 * @param handle i64
 * @param idle *i32
 * @param in_use *i32
 * @param unhealthy *i32
 * @param acquires *i64
 * @return void
 */
export function cache_pool_stats_c(handle: i64, idle: *i32, in_use: *i32, unhealthy: *i32, acquires: *i64): void {
  let p: *ObjPoolMem = pool_from_handle(handle);
  let i: i32 = 0;
  let used: i32 = 0;
  let bad: i32 = 0;
  if (p == 0) { return; }
  i = 0;
  while (i < POOL_MAX_SLOTS) {
    if (p.slots[i].resource != 0) {
      if (p.slots[i].healthy == 0) { bad = bad + 1; }
      else if (p.slots[i].idle == 0) { used = used + 1; }
    }
    i = i + 1;
  }
  if (idle != 0) { *idle = p.idle_count; }
  if (in_use != 0) { *in_use = used; }
  if (unhealthy != 0) { *unhealthy = bad; }
  if (acquires != 0) { *acquires = p.acquire_count; }
}

/** Exported function `cache_smoke_c`.
 * Implements `cache_smoke_c`.
 * @return i32
 */
export function cache_smoke_c(): i32 {
  let lru: i64 = 0;
  let pool: i64 = 0;
  let v: i64 = 0;
  let r: i64 = 0;
  let purged: i32 = 0;
  lru = cache_lru_create_c(2);
  pool = cache_pool_create_c(2);
  if (lru == 0 || pool == 0) { return 1; }
  if (cache_lru_put_c(lru, 1, 100, 0) != CACHE_OK) { return 2; }
  if (cache_lru_put_c(lru, 2, 200, 0) != CACHE_OK) { return 3; }
  if (cache_lru_put_c(lru, 3, 300, 0) != CACHE_OK) { return 4; }
  if (cache_lru_get_c(lru, 1, &v) != CACHE_ERR_NOT_FOUND) { return 5; }
  if (cache_lru_get_c(lru, 2, &v) != CACHE_OK || v != 200) { return 6; }
  if (cache_lru_put_c(lru, 4, 400, 1000000) != CACHE_OK) { return 7; }
  purged = cache_lru_purge_expired_c(lru);
  purged = purged;
  if (cache_pool_add_c(pool, 101) != CACHE_OK) { return 8; }
  if (cache_pool_add_c(pool, 102) != CACHE_OK) { return 9; }
  if (cache_pool_acquire_c(pool, &r) != CACHE_OK || r == 0) { return 10; }
  if (cache_pool_release_c(pool, r) != CACHE_OK) { return 11; }
  if (cache_pool_acquire_c(pool, &r) != CACHE_OK) { return 12; }
  if (cache_pool_mark_unhealthy_c(pool, r) != CACHE_OK) { return 13; }
  if (cache_pool_release_c(pool, r) != CACHE_OK) { return 14; }
  if (cache_pool_idle_c(pool) != 1) { return 15; }
  cache_lru_free_c(lru);
  cache_pool_free_c(pool);
  return 0;
}
