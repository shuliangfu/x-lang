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

// std.map — 映射/字典（对标 Zig std.AutoHashMap、Rust HashMap、Go map）
//
// 【文件职责】
// 基于 std.heap 的哈希表 Map_i32_i32：new/with_capacity、get/get_or、insert、remove、contains、len、is_empty、clear、reserve、deinit。
//
// 【对标】
// Zig: get/put/containsKey/remove、fetchPut；
// Rust: insert/get/remove/contains_key/len/is_empty/clear/reserve；
// Go: make、len、delete、取值+ok。
const heap = import("std.heap");
const heap_libc = import("std.heap.libc");
/** 默认初始容量（槽位数）；负载因子超过约 0.7 时扩容。 */
function default_capacity(): i32 { return 8; }
/** 哈希表：keys/vals/occupied 堆分配，cap 槽位，len
* 已用对数；调用方须在不用时 deinit。 */
allow(padding) struct Map_i32_i32 {
  keys: *i32;
  vals: *i32;
  occupied: *u8;
  cap: i32;
  len: i32;
}
/** 取 key 的槽位下标（0..cap-1）；仅用于内部。 */
function slot(m: Map_i32_i32, key: i32): i32 {
  let h: i32 = key % m.cap;
  if (h < 0) { return h + m.cap; }
  return h;
}
/** 查找 key 所在槽位；若存在返回槽位下标，否则返回 -1。F-03 v1：ops.x 线性探测。 */
function find(m: Map_i32_i32, key: i32): i32 {
  return heap.map_find(m.keys, m.occupied, m.cap, key);
}
/** 新建空 Map_i32_i32（cap 0，ptr 均为 null）；tag 仅用于重载消歧。 */
function new(_tag: i32): Map_i32_i32 {
  let _: i32 = _tag;
  return Map_i32_i32 { keys: 0, vals: 0, occupied: 0, cap: 0, len: 0 };
}
/** 预分配 capacity 个槽位；失败返回 -1，成功返回 0。 */
function with_capacity(m: *Map_i32_i32, capacity: i32): i32 {
  if (capacity <= 0) {
    m.keys = 0;
    m.vals = 0;
    m.occupied = 0;
    m.cap = 0;
    m.len = 0;
    return 0;
  }
  let k: *i32 = heap_libc.heap_alloc_i32_c(capacity);
  let v: *i32 = heap_libc.heap_alloc_i32_c(capacity);
  let o: *u8 = heap_libc.heap_alloc_u8_c(capacity);
  if (k == 0 || v == 0 || o == 0) {
    if (k != 0) { heap_libc.heap_free_i32_c(k); }
    if (v != 0) { heap_libc.heap_free_i32_c(v); }
    if (o != 0) { heap_libc.heap_free_u8_c(o); }
    return -1;
  }
  let i: i32 = 0;
  while (i < capacity) {
    o[i] = 0;
    i = i + 1;
  }
  m.keys = k;
  m.vals = v;
  m.occupied = o;
  m.cap = capacity;
  m.len = 0;
  return 0;
}
/** 扩容为 new_cap 并 rehash 所有条目；失败返回 -1，成功返回 0。 */
function grow(m: *Map_i32_i32, new_cap: i32): i32 {
  if (new_cap <= m.cap) { return 0; }
  let old_keys: *i32 = m.keys;
  let old_vals: *i32 = m.vals;
  let old_occupied: *u8 = m.occupied;
  let old_cap: i32 = m.cap;
  let old_len: i32 = m.len;
  if (with_capacity(m, new_cap) != 0) { return -1; }
  let i: i32 = 0;
  while (i < old_cap) {
    if (old_occupied[i] != 0) {
      let _: i32 = insert(m, old_keys[i], old_vals[i]);
      i = i + 1;
    } else {
      i = i + 1;
    }
  }
  heap_libc.heap_free_i32_c(old_keys);
  heap_libc.heap_free_i32_c(old_vals);
  heap_libc.heap_free_u8_c(old_occupied);
  return 0;
}
/** 确保可再放至少 1 条；负载因子 > 0.75 时扩容，减少 rehash
* 频率。失败返回 -1。热路径用字面量 8。 */
function reserve_one(m: *Map_i32_i32): i32 {
  if (m.cap <= 0) {
    return with_capacity(m, 8);
  }
  if (m.len + 1 <= m.cap * 3 / 4) { return 0; }
  return grow(m, m.cap * 2);
}
/** 插入 key -> value；若 key 已存在则覆盖。成功返回 0，失败返回 -1。 */
function insert(m: *Map_i32_i32, key: i32, value: i32): i32 {
  if (reserve_one(m) != 0) { return -1; }
  let start: i32 = 0;
  unsafe { start = slot(*m, key); }
  let i: i32 = start;
  loop {
    if (m.occupied[i] == 0) {
      m.keys[i] = key;
      m.vals[i] = value;
      m.occupied[i] = 1;
      m.len = m.len + 1;
      return 0;
    }
    if (m.keys[i] == key) {
      m.vals[i] = value;
      return 0;
    }
    i = i + 1;
    if (i >= m.cap) { i = 0; }
    if (i == start) {
      if (grow(m, m.cap * 2) != 0) { return -1; }
      return insert(m, key, value);
    }
  }
  return -1;
}
/** 取 key 对应的 value；不存在则返回 default_val。 */
function get(m: Map_i32_i32, key: i32, default_val: i32): i32 {
  let idx: i32 = find(m, key);
  if (idx < 0) { return default_val; }
  return m.vals[idx];
}
/** 是否包含 key。返回 1 是，0 否。 */
function contains_key(m: Map_i32_i32, key: i32): i32 {
  if (find(m, key) >= 0) { return 1; }
  return 0;
}
/** 移除 key；若存在则移除并返回 1，否则返回 0。 */
function remove(m: *Map_i32_i32, key: i32): i32 {
  let idx: i32 = 0;
  unsafe { idx = find(*m, key); }
  if (idx < 0) { return 0; }
  m.occupied[idx] = 0;
  m.len = m.len - 1;
  return 1;
}
/** 条目数。 */
function len(m: Map_i32_i32): i32 { return m.len; }
/** 热路径：指针取 len，避免按值传 Map 结构体。 */
function len_ptr(m: *Map_i32_i32): i32 { return m.len; }
/** 是否为空。返回 1 是，0 否。 */
function is_empty(m: Map_i32_i32): i32 {
  if (m.len <= 0) { return 1; }
  return 0;
}
/** 清空所有条目，不释放内存。 */
function clear(m: *Map_i32_i32): void {
  let i: i32 = 0;
  while (i < m.cap) {
    m.occupied[i] = 0;
    i = i + 1;
  }
  m.len = 0;
}
/** 确保容量至少 new_cap 个槽位；失败返回 -1。 */
function reserve(m: *Map_i32_i32, new_cap: i32): i32 {
  if (new_cap <= m.cap) { return 0; }
  return grow(m, new_cap);
}
/** 释放堆内存并将 ptr 置为 null；调用后不可再使用。 */
function deinit(m: *Map_i32_i32): void {
  if (m.keys != 0) { heap_libc.heap_free_i32_c(m.keys); m.keys = 0; }
  if (m.vals != 0) { heap_libc.heap_free_i32_c(m.vals); m.vals = 0; }
  if (m.occupied != 0) { heap_libc.heap_free_u8_c(m.occupied); m.occupied = 0; }
  m.cap = 0;
  m.len = 0;
}
/** Map 迭代条目：ok=1 表示有效 key/val。 */
struct MapIterItem_i32 {
  ok: i32;
  key: i32;
  val: i32;
}

/** Map_i32_i32 迭代器状态。 */
allow(padding) struct MapIter_i32_i32 {
  map: Map_i32_i32;
  slot: i32;
}

/** 初始化 map 迭代器（从 slot 0 扫描）。 */
function iter_init(m: Map_i32_i32): MapIter_i32_i32 {
  return MapIter_i32_i32 { map: m, slot: 0 };
}

/** 读取下一 occupied 槽；结束 ok=0。 */
function iter_next(it: *MapIter_i32_i32): MapIterItem_i32 {
  while (it.slot < it.map.cap) {
    if (it.map.occupied[it.slot] != 0) {
      let item: MapIterItem_i32 = MapIterItem_i32 {
        ok: 1,
        key: it.map.keys[it.slot],
        val: it.map.vals[it.slot],
      };
      it.slot = it.slot + 1;
      return item;
    }
    it.slot = it.slot + 1;
  }
  return MapIterItem_i32 { ok: 0, key: 0, val: 0 };
}

/** 负载因子百分比（len*100/cap）；空表返回 0。 */
function load_factor_pct(m: Map_i32_i32): i32 {
  if (m.cap <= 0) { return 0; }
  return m.len * 100 / m.cap;
}

/** 空 map 的 size 为 0。 */
function empty_size(): i32 { return 0; }

// ——— Map_u64_i32（STD-013）：u64 键 / i32 值 ———

/** u64→i32 哈希表。 */
allow(padding) struct Map_u64_i32 {
  keys: *u64;
  vals: *i32;
  occupied: *u8;
  cap: i32;
  len: i32;
}

/** u64 key 槽位下标。 */
function slot(m: Map_u64_i32, key: u64): i32 {
  let cap_u: u64 = m.cap as u64;
  let h: u64 = key % cap_u;
  return h as i32;
}

/** 线性探测查找 u64 key。 */
function find(m: Map_u64_i32, key: u64): i32 {
  if (m.cap <= 0) { return -1; }
  let start: i32 = slot(m, key);
  let i: i32 = start;
  loop {
    if (m.occupied[i] == 0) { return -1; }
    if (m.keys[i] == key) { return i; }
    i = i + 1;
    if (i >= m.cap) { i = 0; }
    if (i == start) { return -1; }
  }
  return -1;
}

/** 新建空 Map_u64_i32；tag 仅用于重载消歧。 */
function new(_tag: u64): Map_u64_i32 {
  let _: u64 = _tag;
  return Map_u64_i32 { keys: 0, vals: 0, occupied: 0, cap: 0, len: 0 };
}

/** 预分配 capacity 槽位；失败 -1。 */
function with_capacity(m: *Map_u64_i32, capacity: i32): i32 {
  if (capacity <= 0) {
    m.keys = 0;
    m.vals = 0;
    m.occupied = 0;
    m.cap = 0;
    m.len = 0;
    return 0;
  }
  let k: *u64 = heap_libc.heap_alloc_u64_c(capacity);
  let v: *i32 = heap_libc.heap_alloc_i32_c(capacity);
  let o: *u8 = heap_libc.heap_alloc_u8_c(capacity);
  if (k == 0 || v == 0 || o == 0) {
    if (k != 0) { heap_libc.heap_free_u64_c(k); }
    if (v != 0) { heap_libc.heap_free_i32_c(v); }
    if (o != 0) { heap_libc.heap_free_u8_c(o); }
    return -1;
  }
  let i: i32 = 0;
  while (i < capacity) {
    o[i] = 0;
    i = i + 1;
  }
  m.keys = k;
  m.vals = v;
  m.occupied = o;
  m.cap = capacity;
  m.len = 0;
  return 0;
}

/** 扩容并 rehash。 */
function grow(m: *Map_u64_i32, new_cap: i32): i32 {
  if (new_cap <= m.cap) { return 0; }
  let old_keys: *u64 = m.keys;
  let old_vals: *i32 = m.vals;
  let old_occupied: *u8 = m.occupied;
  let old_cap: i32 = m.cap;
  if (with_capacity(m, new_cap) != 0) { return -1; }
  let i: i32 = 0;
  while (i < old_cap) {
    if (old_occupied[i] != 0) {
      let _: i32 = insert(m, old_keys[i], old_vals[i]);
      i = i + 1;
    } else {
      i = i + 1;
    }
  }
  heap_libc.heap_free_u64_c(old_keys);
  heap_libc.heap_free_i32_c(old_vals);
  heap_libc.heap_free_u8_c(old_occupied);
  return 0;
}

/** 负载因子超 0.75 时扩容。 */
function reserve_one(m: *Map_u64_i32): i32 {
  if (m.cap <= 0) {
    return with_capacity(m, 8);
  }
  if (m.len + 1 <= m.cap * 3 / 4) { return 0; }
  return grow(m, m.cap * 2);
}

/** 插入 u64→i32；已存在则覆盖。 */
function insert(m: *Map_u64_i32, key: u64, value: i32): i32 {
  if (reserve_one(m) != 0) { return -1; }
  let start: i32 = 0;
  unsafe { start = slot(*m, key); }
  let i: i32 = start;
  loop {
    if (m.occupied[i] == 0) {
      m.keys[i] = key;
      m.vals[i] = value;
      m.occupied[i] = 1;
      m.len = m.len + 1;
      return 0;
    }
    if (m.keys[i] == key) {
      m.vals[i] = value;
      return 0;
    }
    i = i + 1;
    if (i >= m.cap) { i = 0; }
    if (i == start) {
      if (grow(m, m.cap * 2) != 0) { return -1; }
      return insert(m, key, value);
    }
  }
  return -1;
}

/** 取 u64 key 对应 value；不存在返回 default_val。 */
function get(m: Map_u64_i32, key: u64, default_val: i32): i32 {
  let idx: i32 = find(m, key);
  if (idx < 0) { return default_val; }
  return m.vals[idx];
}

/** 是否包含 u64 key。 */
function contains_key(m: Map_u64_i32, key: u64): i32 {
  if (find(m, key) >= 0) { return 1; }
  return 0;
}

/** 移除 u64 key；存在返回 1。 */
function remove(m: *Map_u64_i32, key: u64): i32 {
  let idx: i32 = 0;
  unsafe { idx = find(*m, key); }
  if (idx < 0) { return 0; }
  m.occupied[idx] = 0;
  m.len = m.len - 1;
  return 1;
}

/** 释放 Map_u64_i32 堆内存。 */
function deinit(m: *Map_u64_i32): void {
  if (m.keys != 0) { heap_libc.heap_free_u64_c(m.keys); m.keys = 0; }
  if (m.vals != 0) { heap_libc.heap_free_i32_c(m.vals); m.vals = 0; }
  if (m.occupied != 0) { heap_libc.heap_free_u8_c(m.occupied); m.occupied = 0; }
  m.cap = 0;
  m.len = 0;
}

// ——— Map_str_i32（STD-013）：字符串键（ptr+len）/ i32 值 ———

/** 每槽键字节上限；超长键 insert 返回 -1。 */
function str_key_cap(): i32 { return 32; }

/** 字符串键哈希表：keys 为 cap×str_key_cap() 扁平字节区。 */
allow(padding) struct Map_str_i32 {
  keys: *u8;
  key_lens: *i32;
  vals: *i32;
  occupied: *u8;
  cap: i32;
  len: i32;
}

/** djb2 哈希（key 字节序列）。 */
function str_hash(key: *u8, key_len: i32): i32 {
  let h: i32 = 5381;
  let i: i32 = 0;
  while (i < key_len) {
    h = (h << 5) + h + key[i];
    i = i + 1;
  }
  return h;
}

/** 槽位下标（开放寻址起点）。 */
function str_slot(m: Map_str_i32, hash: i32): i32 {
  let h: i32 = hash % m.cap;
  if (h < 0) { return h + m.cap; }
  return h;
}

/** 比较槽 slot 内键与 (key,key_len) 是否相等。 */
function str_key_eq(m: Map_str_i32, slot: i32, key: *u8, key_len: i32): i32 {
  if (m.key_lens[slot] != key_len) { return 0; }
  let base: i32 = slot * str_key_cap();
  let i: i32 = 0;
  while (i < key_len) {
    if (m.keys[base + i] != key[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** 线性探测查找字符串键；存在返回槽位，否则 -1。 */
function str_find(m: Map_str_i32, key: *u8, key_len: i32): i32 {
  if (m.cap <= 0 || key_len <= 0) { return -1; }
  let hash: i32 = str_hash(key, key_len);
  let start: i32 = str_slot(m, hash);
  let i: i32 = start;
  loop {
    if (m.occupied[i] == 0) { return -1; }
    if (str_key_eq(m, i, key, key_len) != 0) { return i; }
    i = i + 1;
    if (i >= m.cap) { i = 0; }
    if (i == start) { return -1; }
  }
  return -1;
}

/** 新建空 Map_str_i32。 */
function str_new(): Map_str_i32 {
  return Map_str_i32 { keys: 0, key_lens: 0, vals: 0, occupied: 0, cap: 0, len: 0 };
}

/** 预分配 capacity 槽位；失败 -1。 */
function str_with_capacity(m: *Map_str_i32, capacity: i32): i32 {
  if (capacity <= 0) {
    m.keys = 0;
    m.key_lens = 0;
    m.vals = 0;
    m.occupied = 0;
    m.cap = 0;
    m.len = 0;
    return 0;
  }
  let key_bytes: i32 = capacity * str_key_cap();
  let k: *u8 = heap_libc.heap_alloc_u8_c(key_bytes);
  let kl: *i32 = heap_libc.heap_alloc_i32_c(capacity);
  let v: *i32 = heap_libc.heap_alloc_i32_c(capacity);
  let o: *u8 = heap_libc.heap_alloc_u8_c(capacity);
  if (k == 0 || kl == 0 || v == 0 || o == 0) {
    if (k != 0) { heap_libc.heap_free_u8_c(k); }
    if (kl != 0) { heap_libc.heap_free_i32_c(kl); }
    if (v != 0) { heap_libc.heap_free_i32_c(v); }
    if (o != 0) { heap_libc.heap_free_u8_c(o); }
    return -1;
  }
  let i: i32 = 0;
  while (i < capacity) {
    o[i] = 0;
    kl[i] = 0;
    i = i + 1;
  }
  m.keys = k;
  m.key_lens = kl;
  m.vals = v;
  m.occupied = o;
  m.cap = capacity;
  m.len = 0;
  return 0;
}

/** 扩容并 rehash 所有字符串键。 */
function str_grow(m: *Map_str_i32, new_cap: i32): i32 {
  if (new_cap <= m.cap) { return 0; }
  let old_keys: *u8 = m.keys;
  let old_key_lens: *i32 = m.key_lens;
  let old_vals: *i32 = m.vals;
  let old_occupied: *u8 = m.occupied;
  let old_cap: i32 = m.cap;
  if (str_with_capacity(m, new_cap) != 0) { return -1; }
  let i: i32 = 0;
  while (i < old_cap) {
    if (old_occupied[i] != 0) {
      let base: i32 = i * str_key_cap();
      let _: i32 = str_insert(m, &old_keys[base], old_key_lens[i], old_vals[i]);
      i = i + 1;
    } else {
      i = i + 1;
    }
  }
  heap_libc.heap_free_u8_c(old_keys);
  heap_libc.heap_free_i32_c(old_key_lens);
  heap_libc.heap_free_i32_c(old_vals);
  heap_libc.heap_free_u8_c(old_occupied);
  return 0;
}

/** 负载因子超 0.75 时扩容。 */
function str_reserve_one(m: *Map_str_i32): i32 {
  if (m.cap <= 0) {
    return str_with_capacity(m, 8);
  }
  if (m.len + 1 <= m.cap * 3 / 4) { return 0; }
  return str_grow(m, m.cap * 2);
}

/** 插入字符串键→i32；key_len>str_key_cap() 或分配失败返回 -1。 */
function str_insert(m: *Map_str_i32, key: *u8, key_len: i32, value: i32): i32 {
  if (key_len <= 0 || key_len > str_key_cap()) { return -1; }
  if (str_reserve_one(m) != 0) { return -1; }
  let hash: i32 = str_hash(key, key_len);
  let start: i32 = 0;
  unsafe { start = str_slot(*m, hash); }
  let i: i32 = start;
  loop {
    if (m.occupied[i] == 0) {
      let base: i32 = i * str_key_cap();
      heap_libc.heap_copy_u8_at_c(m.keys, base, key, key_len);
      m.key_lens[i] = key_len;
      m.vals[i] = value;
      m.occupied[i] = 1;
      m.len = m.len + 1;
      return 0;
    }
    let eq: i32 = 0;
    unsafe { eq = str_key_eq(*m, i, key, key_len); }
    if (eq != 0) {
      m.vals[i] = value;
      return 0;
    }
    i = i + 1;
    if (i >= m.cap) { i = 0; }
    if (i == start) {
      if (str_grow(m, m.cap * 2) != 0) { return -1; }
      return str_insert(m, key, key_len, value);
    }
  }
  return -1;
}

/** 取字符串键对应 value；不存在返回 default_val。 */
function str_get(m: Map_str_i32, key: *u8, key_len: i32, default_val: i32): i32 {
  let idx: i32 = str_find(m, key, key_len);
  if (idx < 0) { return default_val; }
  return m.vals[idx];
}

/** 是否包含字符串键。 */
function str_contains(m: Map_str_i32, key: *u8, key_len: i32): i32 {
  if (str_find(m, key, key_len) >= 0) { return 1; }
  return 0;
}

/** 移除字符串键；存在返回 1。 */
function str_remove(m: *Map_str_i32, key: *u8, key_len: i32): i32 {
  let idx: i32 = 0;
  unsafe { idx = str_find(*m, key, key_len); }
  if (idx < 0) { return 0; }
  m.occupied[idx] = 0;
  m.len = m.len - 1;
  return 1;
}

/** 释放 Map_str_i32 堆内存。 */
function str_deinit(m: *Map_str_i32): void {
  if (m.keys != 0) { heap_libc.heap_free_u8_c(m.keys); m.keys = 0; }
  if (m.key_lens != 0) { heap_libc.heap_free_i32_c(m.key_lens); m.key_lens = 0; }
  if (m.vals != 0) { heap_libc.heap_free_i32_c(m.vals); m.vals = 0; }
  if (m.occupied != 0) { heap_libc.heap_free_u8_c(m.occupied); m.occupied = 0; }
  m.cap = 0;
  m.len = 0;
}
