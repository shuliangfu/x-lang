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

// std.set — 集合（对标 Rust std::collections::HashSet、Zig AutoSet/HashSet）
//
// 【文件职责】
// Set_i32：仅存 key，无 value；new/with_capacity、insert、remove、contains、len、is_empty、clear、reserve、deinit。
// 与 std.map 共享哈希实现，复用 std.heap 的 map_find（keys+occupied 线性探测）。
//
// 【依赖】std.heap（alloc/free/realloc 重载、map_find）。

const heap = import("std.heap");
const hash_mod = import("std.hash");

/** 集合：keys/occupied 堆分配，cap 槽位，len 已用；调用方须在不用时 deinit。 */
allow(padding) struct Set_i32 {
  keys: *i32;
  occupied: *u8;
  cap: i32;
  len: i32;
}

/** 取 key 的槽位下标（0..cap-1）；仅用于内部。 */
function slot(s: Set_i32, key: i32): i32 {
  let h: i32 = key % s.cap;
  if (h < 0) { return h + s.cap; }
  return h;
}

/** 查找 key 所在槽位；若存在返回槽位下标，否则返回 -1。复用 heap 的 map_find（仅用 keys/occupied）。 */
function find(s: Set_i32, key: i32): i32 {
  return heap.map_find(s.keys, s.occupied, s.cap, key);
}

/** 新建空 Set_i32（cap 0，ptr 均为 null）。 */
function new(_tag: i32): Set_i32 {
  let _: i32 = _tag;
  return Set_i32 { keys: 0, occupied: 0, cap: 0, len: 0 };
}

/** 预分配 capacity 个槽位；失败返回 -1，成功返回 0。 */
function with_capacity(s: *Set_i32, capacity: i32): i32 {
  if (capacity <= 0) {
    s.keys = 0;
    s.occupied = 0;
    s.cap = 0;
    s.len = 0;
    return 0;
  }
  let k: *i32 = heap.alloc(capacity);
  let o: *u8 = heap.alloc(capacity);
  if (k == 0 || o == 0) {
    if (k != 0) { heap.free(k); }
    if (o != 0) { heap.free(o); }
    return -1;
  }
  let i: i32 = 0;
  while (i < capacity) {
    o[i] = 0;
    i = i + 1;
  }
  s.keys = k;
  s.occupied = o;
  s.cap = capacity;
  s.len = 0;
  return 0;
}

/** 扩容为 new_cap 并 rehash 所有条目；失败返回 -1，成功返回 0。 */
function grow(s: *Set_i32, new_cap: i32): i32 {
  if (new_cap <= s.cap) { return 0; }
  let old_keys: *i32 = s.keys;
  let old_occupied: *u8 = s.occupied;
  let old_cap: i32 = s.cap;
  if (with_capacity(s, new_cap) != 0) { return -1; }
  let i: i32 = 0;
  while (i < old_cap) {
    if (old_occupied[i] != 0) {
      let _: i32 = insert(s, old_keys[i]);
      i = i + 1;
    } else {
      i = i + 1;
    }
  }
  heap.free(old_keys);
  heap.free(old_occupied);
  return 0;
}

/** 确保可再放至少 1 条；负载因子 > 0.75 时扩容。失败返回 -1。 */
function reserve_one(s: *Set_i32): i32 {
  if (s.cap <= 0) {
    return with_capacity(s, 8);
  }
  if (s.len + 1 <= s.cap * 3 / 4) { return 0; }
  return grow(s, s.cap * 2);
}

/** 插入 key；若已存在则无操作。成功返回 0，失败返回 -1。 */
function insert(s: *Set_i32, key: i32): i32 {
  if (reserve_one(s) != 0) { return -1; }
  let start: i32 = 0;
  unsafe { start = slot(*s, key); }
  let i: i32 = start;
  loop {
    if (s.occupied[i] == 0) {
      s.keys[i] = key;
      s.occupied[i] = 1;
      s.len = s.len + 1;
      return 0;
    }
    if (s.keys[i] == key) {
      return 0;
    }
    i = i + 1;
    if (i >= s.cap) { i = 0; }
    if (i == start) {
      if (grow(s, s.cap * 2) != 0) { return -1; }
      return insert(s, key);
    }
  }
  return -1;
}

/** 是否包含 key。返回 1 是，0 否。 */
function contains_key(s: Set_i32, key: i32): i32 {
  if (find(s, key) >= 0) { return 1; }
  return 0;
}

/** 移除 key；若存在则移除并返回 1，否则返回 0。 */
function remove(s: *Set_i32, key: i32): i32 {
  let idx: i32 = 0;
  unsafe { idx = find(*s, key); }
  if (idx < 0) { return 0; }
  s.occupied[idx] = 0;
  s.len = s.len - 1;
  return 1;
}

/** 元素个数。 */
function len(s: Set_i32): i32 { return s.len; }

/** 是否为空。返回 1 是，0 否。 */
function is_empty(s: Set_i32): i32 {
  if (s.len <= 0) { return 1; }
  return 0;
}

/** 清空所有元素，不释放内存。 */
function clear(s: *Set_i32): void {
  let i: i32 = 0;
  while (i < s.cap) {
    s.occupied[i] = 0;
    i = i + 1;
  }
  s.len = 0;
}

/** 确保容量至少 new_cap 个槽位；失败返回 -1。 */
function reserve(s: *Set_i32, new_cap: i32): i32 {
  if (new_cap <= s.cap) { return 0; }
  return grow(s, new_cap);
}

/** 释放堆内存；调用后不可再使用。 */
function deinit(s: *Set_i32): void {
  if (s.keys != 0) { heap.free(s.keys); s.keys = 0; }
  if (s.occupied != 0) { heap.free(s.occupied); s.occupied = 0; }
  s.cap = 0;
  s.len = 0;
}

// ——— STD-129：Set_i32 集合运算（union / intersect / difference） ———

/** 清空 dst 并写入 a∪b（去重）；成功 0，分配失败 -1。 */
function union_into(dst: *Set_i32, a: Set_i32, b: Set_i32): i32 {
  clear(dst);
  let i: i32 = 0;
  while (i < a.cap) {
    if (a.occupied[i] != 0) {
      if (insert(dst, a.keys[i]) != 0) { return -1; }
    }
    i = i + 1;
  }
  i = 0;
  while (i < b.cap) {
    if (b.occupied[i] != 0) {
      if (insert(dst, b.keys[i]) != 0) { return -1; }
    }
    i = i + 1;
  }
  return 0;
}

/** 清空 dst 并写入 a∩b；成功 0，失败 -1。 */
function intersect_into(dst: *Set_i32, a: Set_i32, b: Set_i32): i32 {
  clear(dst);
  let i: i32 = 0;
  while (i < a.cap) {
    if (a.occupied[i] != 0 && contains_key(b, a.keys[i]) != 0) {
      if (insert(dst, a.keys[i]) != 0) { return -1; }
    }
    i = i + 1;
  }
  return 0;
}

/** 清空 dst 并写入 a 减 b（在 a 中但不在 b 中）；成功 0，失败 -1。 */
function difference_into(dst: *Set_i32, a: Set_i32, b: Set_i32): i32 {
  clear(dst);
  let i: i32 = 0;
  while (i < a.cap) {
    if (a.occupied[i] != 0 && contains_key(b, a.keys[i]) == 0) {
      if (insert(dst, a.keys[i]) != 0) { return -1; }
    }
    i = i + 1;
  }
  return 0;
}

// ——— Set_u64（STD-015） ———

/** u64 集合。 */
allow(padding) struct Set_u64 {
  keys: *u64;
  occupied: *u8;
  cap: i32;
  len: i32;
}

/** u64 key 槽位。 */
function slot(s: Set_u64, key: u64): i32 {
  let cap_u: u64 = s.cap as u64;
  let h: u64 = key % cap_u;
  return h as i32;
}

/** 查找 u64 key 槽位。 */
function find(s: Set_u64, key: u64): i32 {
  if (s.cap <= 0) { return -1; }
  let start: i32 = slot(s, key);
  let i: i32 = start;
  loop {
    if (s.occupied[i] == 0) { return -1; }
    if (s.keys[i] == key) { return i; }
    i = i + 1;
    if (i >= s.cap) { i = 0; }
    if (i == start) { return -1; }
  }
  return -1;
}

/** 新建空 Set_u64。 */
function new(_tag: i32): Set_u64 {
  let _: i32 = _tag;
  return Set_u64 { keys: 0, occupied: 0, cap: 0, len: 0 };
}

/** 预分配 capacity 槽位。 */
function with_capacity(s: *Set_u64, capacity: i32): i32 {
  if (capacity <= 0) {
    s.keys = 0;
    s.occupied = 0;
    s.cap = 0;
    s.len = 0;
    return 0;
  }
  let k: *u64 = heap.alloc(capacity);
  let o: *u8 = heap.alloc(capacity);
  if (k == 0 || o == 0) {
    if (k != 0) { heap.free(k); }
    if (o != 0) { heap.free(o); }
    return -1;
  }
  let i: i32 = 0;
  while (i < capacity) {
    o[i] = 0;
    i = i + 1;
  }
  s.keys = k;
  s.occupied = o;
  s.cap = capacity;
  s.len = 0;
  return 0;
}

/** 扩容 rehash。 */
function grow(s: *Set_u64, new_cap: i32): i32 {
  if (new_cap <= s.cap) { return 0; }
  let old_keys: *u64 = s.keys;
  let old_occupied: *u8 = s.occupied;
  let old_cap: i32 = s.cap;
  if (with_capacity(s, new_cap) != 0) { return -1; }
  let i: i32 = 0;
  while (i < old_cap) {
    if (old_occupied[i] != 0) {
      let _: i32 = insert(s, old_keys[i]);
      i = i + 1;
    } else {
      i = i + 1;
    }
  }
  heap.free(old_keys);
  heap.free(old_occupied);
  return 0;
}

/** 确保可再放 1 条。 */
function reserve_one(s: *Set_u64): i32 {
  if (s.cap <= 0) {
    return with_capacity(s, 8);
  }
  if (s.len + 1 <= s.cap * 3 / 4) { return 0; }
  return grow(s, s.cap * 2);
}

/** 插入 u64 key。 */
function insert(s: *Set_u64, key: u64): i32 {
  if (reserve_one(s) != 0) { return -1; }
  let start: i32 = 0;
  unsafe { start = slot(*s, key); }
  let i: i32 = start;
  loop {
    if (s.occupied[i] == 0) {
      s.keys[i] = key;
      s.occupied[i] = 1;
      s.len = s.len + 1;
      return 0;
    }
    if (s.keys[i] == key) {
      return 0;
    }
    i = i + 1;
    if (i >= s.cap) { i = 0; }
    if (i == start) {
      if (grow(s, s.cap * 2) != 0) { return -1; }
      return insert(s, key);
    }
  }
  return -1;
}

/** 是否包含 u64 key。 */
function contains_key(s: Set_u64, key: u64): i32 {
  if (find(s, key) >= 0) { return 1; }
  return 0;
}

/** 移除 u64 key。 */
function remove(s: *Set_u64, key: u64): i32 {
  let idx: i32 = 0;
  unsafe { idx = find(*s, key); }
  if (idx < 0) { return 0; }
  s.occupied[idx] = 0;
  s.len = s.len - 1;
  return 1;
}

/** u64 集合元素个数。 */
function len(s: Set_u64): i32 { return s.len; }

/** 释放 Set_u64。 */
function deinit(s: *Set_u64): void {
  if (s.keys != 0) { heap.free(s.keys); s.keys = 0; }
  if (s.occupied != 0) { heap.free(s.occupied); s.occupied = 0; }
  s.cap = 0;
  s.len = 0;
}

// ——— Set_str（STD-015）：固定槽内联键 + hash_bytes 探测 ———

/** Set_str 单键最大字节数（含不含 NUL 的原始字节）。 */
function str_key_cap(): i32 { return 32; }

/** 字符串集合键哈希；Tier-S 与 std.hash 联动锚点。 */
function hash_bytes(ptr: *u8, len: i32): u64 {
  return hash_mod.bytes(ptr, len);
}

/** 字符串集合：keys 为 cap×key_cap 字节平面，lens 为每槽有效长度。 */
allow(padding) struct Set_str {
  keys: *u8;
  lens: *i32;
  occupied: *u8;
  cap: i32;
  len: i32;
}

/** 新建空 Set_str。 */
function str_new(): Set_str {
  return Set_str { keys: 0, lens: 0, occupied: 0, cap: 0, len: 0 };
}

/** 预分配 capacity 槽；失败 -1，成功 0。 */
function str_with_capacity(s: *Set_str, capacity: i32): i32 {
  if (capacity <= 0) {
    s.keys = 0;
    s.lens = 0;
    s.occupied = 0;
    s.cap = 0;
    s.len = 0;
    return 0;
  }
  let kcap: i32 = str_key_cap();
  let keys: *u8 = heap.alloc(capacity * kcap);
  let lens: *i32 = heap.alloc(capacity);
  let occ: *u8 = heap.alloc(capacity);
  if (keys == 0 || lens == 0 || occ == 0) {
    if (keys != 0) { heap.free(keys); }
    if (lens != 0) { heap.free(lens); }
    if (occ != 0) { heap.free(occ); }
    return -1;
  }
  let i: i32 = 0;
  while (i < capacity) {
    occ[i] = 0;
    lens[i] = 0;
    i = i + 1;
  }
  s.keys = keys;
  s.lens = lens;
  s.occupied = occ;
  s.cap = capacity;
  s.len = 0;
  return 0;
}

/** 计算 (ptr,len) 的起始槽位（hash mod cap）。 */
function str_slot(s: Set_str, ptr: *u8, len: i32): i32 {
  let h: u64 = hash_bytes(ptr, len);
  let cap_u: u64 = s.cap as u64;
  if (cap_u == 0) { return 0; }
  return (h % cap_u) as i32;
}

/** 槽内键与 (ptr,len) 是否相等。 */
function str_key_eq(s: Set_str, slot: i32, ptr: *u8, len: i32): i32 {
  if (s.lens[slot] != len) { return 0; }
  let kcap: i32 = str_key_cap();
  let base: i32 = slot * kcap;
  let i: i32 = 0;
  while (i < len) {
    if (s.keys[base + i] != ptr[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** 查找 (ptr,len)；存在返回槽位，否则 -1。 */
function str_find(s: Set_str, ptr: *u8, len: i32): i32 {
  if (s.cap <= 0) { return -1; }
  let start: i32 = str_slot(s, ptr, len);
  let i: i32 = start;
  loop {
    if (s.occupied[i] == 0) { return -1; }
    if (str_key_eq(s, i, ptr, len) != 0) { return i; }
    i = i + 1;
    if (i >= s.cap) { i = 0; }
    if (i == start) { return -1; }
  }
  return -1;
}

/** 扩容并 rehash；失败 -1。 */
function str_grow(s: *Set_str, new_cap: i32): i32 {
  if (new_cap <= s.cap) { return 0; }
  let old_keys: *u8 = s.keys;
  let old_lens: *i32 = s.lens;
  let old_occ: *u8 = s.occupied;
  let old_cap: i32 = s.cap;
  let kcap: i32 = str_key_cap();
  if (str_with_capacity(s, new_cap) != 0) { return -1; }
  let i: i32 = 0;
  while (i < old_cap) {
    if (old_occ[i] != 0) {
      let base: i32 = i * kcap;
      let key_ptr: *u8 = &old_keys[base];
      let _: i32 = str_insert(s, key_ptr, old_lens[i]);
    }
    i = i + 1;
  }
  heap.free(old_keys);
  heap.free(old_lens);
  heap.free(old_occ);
  return 0;
}

/** 负载 >0.75 时扩容。 */
function str_reserve_one(s: *Set_str): i32 {
  if (s.cap <= 0) { return str_with_capacity(s, 8); }
  if (s.len + 1 <= s.cap * 3 / 4) { return 0; }
  return str_grow(s, s.cap * 2);
}

/** 插入 (ptr,len)；键过长返回 -1。 */
function str_insert(s: *Set_str, ptr: *u8, len: i32): i32 {
  if (len <= 0 || len > str_key_cap()) { return -1; }
  let found: i32 = 0;
  unsafe { found = str_find(*s, ptr, len); }
  if (found >= 0) { return 0; }
  if (str_reserve_one(s) != 0) { return -1; }
  let start: i32 = 0;
  unsafe { start = str_slot(*s, ptr, len); }
  let i: i32 = start;
  let kcap: i32 = str_key_cap();
  loop {
    if (s.occupied[i] == 0) {
      let base: i32 = i * kcap;
      let j: i32 = 0;
      while (j < len) {
        s.keys[base + j] = ptr[j];
        j = j + 1;
      }
      s.lens[i] = len;
      s.occupied[i] = 1;
      s.len = s.len + 1;
      return 0;
    }
    i = i + 1;
    if (i >= s.cap) { i = 0; }
    if (i == start) {
      if (str_grow(s, s.cap * 2) != 0) { return -1; }
      return str_insert(s, ptr, len);
    }
  }
  return -1;
}

/** 是否包含 (ptr,len)。 */
function str_contains(s: Set_str, ptr: *u8, len: i32): i32 {
  if (str_find(s, ptr, len) >= 0) { return 1; }
  return 0;
}

/** 移除 (ptr,len)；成功 1，不存在 0。 */
function str_remove(s: *Set_str, ptr: *u8, len: i32): i32 {
  let idx: i32 = 0;
  unsafe { idx = str_find(*s, ptr, len); }
  if (idx < 0) { return 0; }
  s.occupied[idx] = 0;
  s.lens[idx] = 0;
  s.len = s.len - 1;
  return 1;
}

/** 元素个数。 */
function str_len(s: Set_str): i32 { return s.len; }

/** 释放堆内存。 */
function str_deinit(s: *Set_str): void {
  if (s.keys != 0) { heap.free(s.keys); s.keys = 0; }
  if (s.lens != 0) { heap.free(s.lens); s.lens = 0; }
  if (s.occupied != 0) { heap.free(s.occupied); s.occupied = 0; }
  s.cap = 0;
  s.len = 0;
}
