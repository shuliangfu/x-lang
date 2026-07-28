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
// Zig: get/put/containsKey/remove、fetchPut；
// Rust: insert/get/remove/contains_key/len/is_empty/clear/reserve；
// See implementation.
const heap = import("std.heap");
const heap_libc = import("std.heap.libc");
/** Exported function `default_capacity`.
 * Implements `default_capacity`.
 * @return i32
 */
export function default_capacity(): i32 { return 8; }
/** See implementation for details. */
allow(padding) struct Map_i32_i32 {
  keys: *i32;
  vals: *i32;
  occupied: *u8;
  cap: i32;
  length: i32;
}
/** Exported function `slot`.
 * Implements `slot`.
 * @param m Map_i32_i32
 * @param key i32
 * @return i32
 */
export function slot(m: Map_i32_i32, key: i32): i32 {
  let h: i32 = key % m.cap;
  if (h < 0) { return h + m.cap; }
  return h;
}
/** Exported function `find`.
 * Implements `find`.
 * @param m Map_i32_i32
 * @param key i32
 * @return i32
 */
export function find(m: Map_i32_i32, key: i32): i32 {
  return heap.map_find(m.keys, m.occupied, m.cap, key);
}
/** Exported function `new`.
 * Implements `new`.
 * @param _tag i32
 * @return Map_i32_i32
 */
export function new(_tag: i32): Map_i32_i32 {
  let _: i32 = _tag;
  return Map_i32_i32 { keys: 0, vals: 0, occupied: 0, cap: 0, length: 0 };
}
/** Exported function `with_capacity`.
 * Implements `with_capacity`.
 * @param m *Map_i32_i32
 * @param capacity i32
 * @return i32
 */
export function with_capacity(m: *Map_i32_i32, capacity: i32): i32 {
  if (capacity <= 0) {
    m.keys = 0;
    m.vals = 0;
    m.occupied = 0;
    m.cap = 0;
    m.length = 0;
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
  m.length = 0;
  return 0;
}
/** Exported function `grow`.
 * Implements `grow`.
 * @param m *Map_i32_i32
 * @param new_cap i32
 * @return i32
 */
export function grow(m: *Map_i32_i32, new_cap: i32): i32 {
  if (new_cap <= m.cap) { return 0; }
  let old_keys: *i32 = m.keys;
  let old_vals: *i32 = m.vals;
  let old_occupied: *u8 = m.occupied;
  let old_cap: i32 = m.cap;
  let old_len: i32 = m.length;
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
/** Exported function `reserve_one`.
 * Implements `reserve_one`.
 * @param m *Map_i32_i32
 * @return i32
 */
export function reserve_one(m: *Map_i32_i32): i32 {
  if (m.cap <= 0) {
    return with_capacity(m, 8);
  }
  if (m.length + 1 <= m.cap * 3 / 4) { return 0; }
  return grow(m, m.cap * 2);
}
/** Exported function `insert`.
 * Implements `insert`.
 * @param m *Map_i32_i32
 * @param key i32
 * @param value i32
 * @return i32
 */
export function insert(m: *Map_i32_i32, key: i32, value: i32): i32 {
  if (reserve_one(m) != 0) { return -1; }
  let start: i32 = 0;
  unsafe { start = slot(*m, key); }
  let i: i32 = start;
  loop {
    if (m.occupied[i] == 0) {
      m.keys[i] = key;
      m.vals[i] = value;
      m.occupied[i] = 1;
      m.length = m.length + 1;
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
/** Exported function `get`.
 * Implements `get`.
 * @param m Map_i32_i32
 * @param key i32
 * @param default_val i32
 * @return i32
 */
export function get(m: Map_i32_i32, key: i32, default_val: i32): i32 {
  let idx: i32 = find(m, key);
  if (idx < 0) { return default_val; }
  return m.vals[idx];
}
/** Exported function `contains_key`.
 * Implements `contains_key`.
 * @param m Map_i32_i32
 * @param key i32
 * @return i32
 */
export function contains_key(m: Map_i32_i32, key: i32): i32 {
  if (find(m, key) >= 0) { return 1; }
  return 0;
}
/** Exported function `remove`.
 * Implements `remove`.
 * @param m *Map_i32_i32
 * @param key i32
 * @return i32
 */
export function remove(m: *Map_i32_i32, key: i32): i32 {
  let idx: i32 = 0;
  unsafe { idx = find(*m, key); }
  if (idx < 0) { return 0; }
  m.occupied[idx] = 0;
  m.length = m.length - 1;
  return 1;
}
/** Exported function `len`.
 * Implements `len`.
 * @param m Map_i32_i32
 * @return i32
 */
export function length(m: Map_i32_i32): i32 { return m.length; }
/** Exported function `len_ptr`.
 * Implements `len_ptr`.
 * @param m *Map_i32_i32
 * @return i32
 */
export function len_ptr(m: *Map_i32_i32): i32 { return m.length; }
/** Exported function `is_empty`.
 * Query helper `is_empty`.
 * @param m Map_i32_i32
 * @return i32
 */
export function is_empty(m: Map_i32_i32): i32 {
  if (m.length <= 0) { return 1; }
  return 0;
}
/** Exported function `clear`.
 * Implements `clear`.
 * @param m *Map_i32_i32
 * @return void
 */
export function clear(m: *Map_i32_i32): void {
  let i: i32 = 0;
  while (i < m.cap) {
    m.occupied[i] = 0;
    i = i + 1;
  }
  m.length = 0;
}
/** Exported function `reserve`.
 * Implements `reserve`.
 * @param m *Map_i32_i32
 * @param new_cap i32
 * @return i32
 */
export function reserve(m: *Map_i32_i32, new_cap: i32): i32 {
  if (new_cap <= m.cap) { return 0; }
  return grow(m, new_cap);
}
/** Exported function `deinit`.
 * Implements `deinit`.
 * @param m *Map_i32_i32
 * @return void
 */
export function deinit(m: *Map_i32_i32): void {
  if (m.keys != 0) { heap_libc.heap_free_i32_c(m.keys); m.keys = 0; }
  if (m.vals != 0) { heap_libc.heap_free_i32_c(m.vals); m.vals = 0; }
  if (m.occupied != 0) { heap_libc.heap_free_u8_c(m.occupied); m.occupied = 0; }
  m.cap = 0;
  m.length = 0;
}
/* See implementation. */
export struct MapIterItem_i32 {
  ok: i32;
  key: i32;
  val: i32;
}

/* See implementation. */
allow(padding) struct MapIter_i32_i32 {
  map: Map_i32_i32;
  slot: i32;
}

/** Exported function `iter_init`.
 * Implements `iter_init`.
 * @param m Map_i32_i32
 * @return MapIter_i32_i32
 */
export function iter_init(m: Map_i32_i32): MapIter_i32_i32 {
  return MapIter_i32_i32 { map: m, slot: 0 };
}

/** Exported function `iter_next`.
 * Implements `iter_next`.
 * @param it *MapIter_i32_i32
 * @return MapIterItem_i32
 */
export function iter_next(it: *MapIter_i32_i32): MapIterItem_i32 {
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

/** Exported function `load_factor_pct`.
 * Implements `load_factor_pct`.
 * @param m Map_i32_i32
 * @return i32
 */
export function load_factor_pct(m: Map_i32_i32): i32 {
  if (m.cap <= 0) { return 0; }
  return m.length * 100 / m.cap;
}

/** Exported function `empty_size`.
 * Implements `empty_size`.
 * @return i32
 */
export function empty_size(): i32 { return 0; }

// See implementation.

/* See implementation. */
allow(padding) struct Map_u64_i32 {
  keys: *u64;
  vals: *i32;
  occupied: *u8;
  cap: i32;
  length: i32;
}

/** Exported function `slot`.
 * Implements `slot`.
 * @param m Map_u64_i32
 * @param key u64
 * @return i32
 */
export function slot(m: Map_u64_i32, key: u64): i32 {
  let cap_u: u64 = m.cap as u64;
  let h: u64 = key % cap_u;
  return h as i32;
}

/** Exported function `find`.
 * Implements `find`.
 * @param m Map_u64_i32
 * @param key u64
 * @return i32
 */
export function find(m: Map_u64_i32, key: u64): i32 {
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

/** Exported function `new`.
 * Implements `new`.
 * @param _tag u64
 * @return Map_u64_i32
 */
export function new(_tag: u64): Map_u64_i32 {
  let _: u64 = _tag;
  return Map_u64_i32 { keys: 0, vals: 0, occupied: 0, cap: 0, length: 0 };
}

/** Exported function `with_capacity`.
 * Implements `with_capacity`.
 * @param m *Map_u64_i32
 * @param capacity i32
 * @return i32
 */
export function with_capacity(m: *Map_u64_i32, capacity: i32): i32 {
  if (capacity <= 0) {
    m.keys = 0;
    m.vals = 0;
    m.occupied = 0;
    m.cap = 0;
    m.length = 0;
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
  m.length = 0;
  return 0;
}

/** Exported function `grow`.
 * Implements `grow`.
 * @param m *Map_u64_i32
 * @param new_cap i32
 * @return i32
 */
export function grow(m: *Map_u64_i32, new_cap: i32): i32 {
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

/** Exported function `reserve_one`.
 * Implements `reserve_one`.
 * @param m *Map_u64_i32
 * @return i32
 */
export function reserve_one(m: *Map_u64_i32): i32 {
  if (m.cap <= 0) {
    return with_capacity(m, 8);
  }
  if (m.length + 1 <= m.cap * 3 / 4) { return 0; }
  return grow(m, m.cap * 2);
}

/** Exported function `insert`.
 * Implements `insert`.
 * @param m *Map_u64_i32
 * @param key u64
 * @param value i32
 * @return i32
 */
export function insert(m: *Map_u64_i32, key: u64, value: i32): i32 {
  if (reserve_one(m) != 0) { return -1; }
  let start: i32 = 0;
  unsafe { start = slot(*m, key); }
  let i: i32 = start;
  loop {
    if (m.occupied[i] == 0) {
      m.keys[i] = key;
      m.vals[i] = value;
      m.occupied[i] = 1;
      m.length = m.length + 1;
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

/** Exported function `get`.
 * Implements `get`.
 * @param m Map_u64_i32
 * @param key u64
 * @param default_val i32
 * @return i32
 */
export function get(m: Map_u64_i32, key: u64, default_val: i32): i32 {
  let idx: i32 = find(m, key);
  if (idx < 0) { return default_val; }
  return m.vals[idx];
}

/** Exported function `contains_key`.
 * Implements `contains_key`.
 * @param m Map_u64_i32
 * @param key u64
 * @return i32
 */
export function contains_key(m: Map_u64_i32, key: u64): i32 {
  if (find(m, key) >= 0) { return 1; }
  return 0;
}

/** Exported function `remove`.
 * Implements `remove`.
 * @param m *Map_u64_i32
 * @param key u64
 * @return i32
 */
export function remove(m: *Map_u64_i32, key: u64): i32 {
  let idx: i32 = 0;
  unsafe { idx = find(*m, key); }
  if (idx < 0) { return 0; }
  m.occupied[idx] = 0;
  m.length = m.length - 1;
  return 1;
}

/** Exported function `deinit`.
 * Implements `deinit`.
 * @param m *Map_u64_i32
 * @return void
 */
export function deinit(m: *Map_u64_i32): void {
  if (m.keys != 0) { heap_libc.heap_free_u64_c(m.keys); m.keys = 0; }
  if (m.vals != 0) { heap_libc.heap_free_i32_c(m.vals); m.vals = 0; }
  if (m.occupied != 0) { heap_libc.heap_free_u8_c(m.occupied); m.occupied = 0; }
  m.cap = 0;
  m.length = 0;
}

// See implementation.

/** Exported function `str_key_cap`.
 * Implements `str_key_cap`.
 * @return i32
 */
export function str_key_cap(): i32 { return 32; }

/* See implementation. */
allow(padding) struct Map_str_i32 {
  keys: *u8;
  key_lens: *i32;
  vals: *i32;
  occupied: *u8;
  cap: i32;
  length: i32;
}

/** Exported function `str_hash`.
 * Implements `str_hash`.
 * @param key *u8
 * @param key_len i32
 * @return i32
 */
export function str_hash(key: *u8, key_len: i32): i32 {
  let h: i32 = 5381;
  let i: i32 = 0;
  while (i < key_len) {
    h = (h << 5) + h + key[i];
    i = i + 1;
  }
  return h;
}

/** Exported function `str_slot`.
 * Implements `str_slot`.
 * @param m Map_str_i32
 * @param hash i32
 * @return i32
 */
export function str_slot(m: Map_str_i32, hash: i32): i32 {
  let h: i32 = hash % m.cap;
  if (h < 0) { return h + m.cap; }
  return h;
}

/** Exported function `str_key_eq`.
 * Implements `str_key_eq`.
 * @param m Map_str_i32
 * @param slot i32
 * @param key *u8
 * @param key_len i32
 * @return i32
 */
export function str_key_eq(m: Map_str_i32, slot: i32, key: *u8, key_len: i32): i32 {
  if (m.key_lens[slot] != key_len) { return 0; }
  let base: i32 = slot * str_key_cap();
  let i: i32 = 0;
  while (i < key_len) {
    if (m.keys[base + i] != key[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** Exported function `str_find`.
 * Implements `str_find`.
 * @param m Map_str_i32
 * @param key *u8
 * @param key_len i32
 * @return i32
 */
export function str_find(m: Map_str_i32, key: *u8, key_len: i32): i32 {
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

/** Exported function `str_new`.
 * Implements `str_new`.
 * @return Map_str_i32
 */
export function str_new(): Map_str_i32 {
  return Map_str_i32 { keys: 0, key_lens: 0, vals: 0, occupied: 0, cap: 0, length: 0 };
}

/** Exported function `str_with_capacity`.
 * Implements `str_with_capacity`.
 * @param m *Map_str_i32
 * @param capacity i32
 * @return i32
 */
export function str_with_capacity(m: *Map_str_i32, capacity: i32): i32 {
  if (capacity <= 0) {
    m.keys = 0;
    m.key_lens = 0;
    m.vals = 0;
    m.occupied = 0;
    m.cap = 0;
    m.length = 0;
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
  m.length = 0;
  return 0;
}

/** Exported function `str_grow`.
 * Implements `str_grow`.
 * @param m *Map_str_i32
 * @param new_cap i32
 * @return i32
 */
export function str_grow(m: *Map_str_i32, new_cap: i32): i32 {
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

/** Exported function `str_reserve_one`.
 * Implements `str_reserve_one`.
 * @param m *Map_str_i32
 * @return i32
 */
export function str_reserve_one(m: *Map_str_i32): i32 {
  if (m.cap <= 0) {
    return str_with_capacity(m, 8);
  }
  if (m.length + 1 <= m.cap * 3 / 4) { return 0; }
  return str_grow(m, m.cap * 2);
}

/** Exported function `str_insert`.
 * Implements `str_insert`.
 * @param m *Map_str_i32
 * @param key *u8
 * @param key_len i32
 * @param value i32
 * @return i32
 */
export function str_insert(m: *Map_str_i32, key: *u8, key_len: i32, value: i32): i32 {
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
      m.length = m.length + 1;
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

/** Exported function `str_get`.
 * Implements `str_get`.
 * @param m Map_str_i32
 * @param key *u8
 * @param key_len i32
 * @param default_val i32
 * @return i32
 */
export function str_get(m: Map_str_i32, key: *u8, key_len: i32, default_val: i32): i32 {
  let idx: i32 = str_find(m, key, key_len);
  if (idx < 0) { return default_val; }
  return m.vals[idx];
}

/** Exported function `str_contains`.
 * Implements `str_contains`.
 * @param m Map_str_i32
 * @param key *u8
 * @param key_len i32
 * @return i32
 */
export function str_contains(m: Map_str_i32, key: *u8, key_len: i32): i32 {
  if (str_find(m, key, key_len) >= 0) { return 1; }
  return 0;
}

/** Exported function `str_remove`.
 * Implements `str_remove`.
 * @param m *Map_str_i32
 * @param key *u8
 * @param key_len i32
 * @return i32
 */
export function str_remove(m: *Map_str_i32, key: *u8, key_len: i32): i32 {
  let idx: i32 = 0;
  unsafe { idx = str_find(*m, key, key_len); }
  if (idx < 0) { return 0; }
  m.occupied[idx] = 0;
  m.length = m.length - 1;
  return 1;
}

/** Exported function `str_deinit`.
 * Implements `str_deinit`.
 * @param m *Map_str_i32
 * @return void
 */
export function str_deinit(m: *Map_str_i32): void {
  if (m.keys != 0) { heap_libc.heap_free_u8_c(m.keys); m.keys = 0; }
  if (m.key_lens != 0) { heap_libc.heap_free_i32_c(m.key_lens); m.key_lens = 0; }
  if (m.vals != 0) { heap_libc.heap_free_i32_c(m.vals); m.vals = 0; }
  if (m.occupied != 0) { heap_libc.heap_free_u8_c(m.occupied); m.occupied = 0; }
  m.cap = 0;
  m.length = 0;
}
