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

const heap = import("std.heap");
const heap_libc = import("std.heap.libc");
const hash_mod = import("std.hash");

/* See implementation. */
allow(padding) struct Set_i32 {
  keys: *i32;
  occupied: *u8;
  cap: i32;
  length: i32;
}

/** Exported function `slot`.
 * Implements `slot`.
 * @param s Set_i32
 * @param key i32
 * @return i32
 */
export function slot(s: Set_i32, key: i32): i32 {
  let h: i32 = key % s.cap;
  if (h < 0) { return h + s.cap; }
  return h;
}

/** Exported function `find`.
 * Implements `find`.
 * @param s Set_i32
 * @param key i32
 * @return i32
 */
export function find(s: Set_i32, key: i32): i32 {
  return heap.map_find(s.keys, s.occupied, s.cap, key);
}

/** Exported function `new`.
 * Implements `new`.
 * @param _tag i32
 * @return Set_i32
 */
export function new(_tag: i32): Set_i32 {
  let _: i32 = _tag;
  return Set_i32 { keys: 0, occupied: 0, cap: 0, length: 0 };
}

/** Exported function `with_capacity`.
 * Implements `with_capacity`.
 * @param s *Set_i32
 * @param capacity i32
 * @return i32
 */
export function with_capacity(s: *Set_i32, capacity: i32): i32 {
  if (capacity <= 0) {
    s.keys = 0;
    s.occupied = 0;
    s.cap = 0;
    s.length = 0;
    return 0;
  }
  let k: *i32 = heap_libc.heap_alloc_i32_c(capacity);
  let o: *u8 = heap_libc.heap_alloc_u8_c(capacity);
  if (k == 0 || o == 0) {
    if (k != 0) { heap_libc.heap_free_i32_c(k); }
    if (o != 0) { heap_libc.heap_free_u8_c(o); }
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
  s.length = 0;
  return 0;
}

/** Exported function `grow`.
 * Implements `grow`.
 * @param s *Set_i32
 * @param new_cap i32
 * @return i32
 */
export function grow(s: *Set_i32, new_cap: i32): i32 {
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
  heap_libc.heap_free_i32_c(old_keys);
  heap_libc.heap_free_u8_c(old_occupied);
  return 0;
}

/** Exported function `reserve_one`.
 * Implements `reserve_one`.
 * @param s *Set_i32
 * @return i32
 */
export function reserve_one(s: *Set_i32): i32 {
  if (s.cap <= 0) {
    return with_capacity(s, 8);
  }
  if (s.length + 1 <= s.cap * 3 / 4) { return 0; }
  return grow(s, s.cap * 2);
}

/** Exported function `insert`.
 * Implements `insert`.
 * @param s *Set_i32
 * @param key i32
 * @return i32
 */
export function insert(s: *Set_i32, key: i32): i32 {
  if (reserve_one(s) != 0) { return -1; }
  let start: i32 = 0;
  unsafe { start = slot(*s, key); }
  let i: i32 = start;
  loop {
    if (s.occupied[i] == 0) {
      s.keys[i] = key;
      s.occupied[i] = 1;
      s.length = s.length + 1;
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

/** Exported function `contains_key`.
 * Implements `contains_key`.
 * @param s Set_i32
 * @param key i32
 * @return i32
 */
export function contains_key(s: Set_i32, key: i32): i32 {
  if (find(s, key) >= 0) { return 1; }
  return 0;
}

/** Exported function `remove`.
 * Implements `remove`.
 * @param s *Set_i32
 * @param key i32
 * @return i32
 */
export function remove(s: *Set_i32, key: i32): i32 {
  let idx: i32 = 0;
  unsafe { idx = find(*s, key); }
  if (idx < 0) { return 0; }
  s.occupied[idx] = 0;
  s.length = s.length - 1;
  return 1;
}

/** Exported function `len`.
 * Implements `len`.
 * @param s Set_i32
 * @return i32
 */
export function length(s: Set_i32): i32 { return s.length; }

/** Exported function `is_empty`.
 * Query helper `is_empty`.
 * @param s Set_i32
 * @return i32
 */
export function is_empty(s: Set_i32): i32 {
  if (s.length <= 0) { return 1; }
  return 0;
}

/** Exported function `clear`.
 * Implements `clear`.
 * @param s *Set_i32
 * @return void
 */
export function clear(s: *Set_i32): void {
  let i: i32 = 0;
  while (i < s.cap) {
    s.occupied[i] = 0;
    i = i + 1;
  }
  s.length = 0;
}

/** Exported function `reserve`.
 * Implements `reserve`.
 * @param s *Set_i32
 * @param new_cap i32
 * @return i32
 */
export function reserve(s: *Set_i32, new_cap: i32): i32 {
  if (new_cap <= s.cap) { return 0; }
  return grow(s, new_cap);
}

/** Exported function `deinit`.
 * Implements `deinit`.
 * @param s *Set_i32
 * @return void
 */
export function deinit(s: *Set_i32): void {
  if (s.keys != 0) { heap_libc.heap_free_i32_c(s.keys); s.keys = 0; }
  if (s.occupied != 0) { heap_libc.heap_free_u8_c(s.occupied); s.occupied = 0; }
  s.cap = 0;
  s.length = 0;
}

// See implementation.

/** Exported function `union_into`.
 * Implements `union_into`.
 * @param dst *Set_i32
 * @param a Set_i32
 * @param b Set_i32
 * @return i32
 */
export function union_into(dst: *Set_i32, a: Set_i32, b: Set_i32): i32 {
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

/** Exported function `intersect_into`.
 * Implements `intersect_into`.
 * @param dst *Set_i32
 * @param a Set_i32
 * @param b Set_i32
 * @return i32
 */
export function intersect_into(dst: *Set_i32, a: Set_i32, b: Set_i32): i32 {
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

/** Exported function `difference_into`.
 * Implements `difference_into`.
 * @param dst *Set_i32
 * @param a Set_i32
 * @param b Set_i32
 * @return i32
 */
export function difference_into(dst: *Set_i32, a: Set_i32, b: Set_i32): i32 {
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

/* See implementation. */
allow(padding) struct Set_u64 {
  keys: *u64;
  occupied: *u8;
  cap: i32;
  length: i32;
}

/** Exported function `slot`.
 * Implements `slot`.
 * @param s Set_u64
 * @param key u64
 * @return i32
 */
export function slot(s: Set_u64, key: u64): i32 {
  let cap_u: u64 = s.cap as u64;
  let h: u64 = key % cap_u;
  return h as i32;
}

/** Exported function `find`.
 * Implements `find`.
 * @param s Set_u64
 * @param key u64
 * @return i32
 */
export function find(s: Set_u64, key: u64): i32 {
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

/** Exported function `new`.
 * Implements `new`.
 * @param _tag i32
 * @return Set_u64
 */
export function new(_tag: i32): Set_u64 {
  let _: i32 = _tag;
  return Set_u64 { keys: 0, occupied: 0, cap: 0, length: 0 };
}

/** Exported function `with_capacity`.
 * Implements `with_capacity`.
 * @param s *Set_u64
 * @param capacity i32
 * @return i32
 */
export function with_capacity(s: *Set_u64, capacity: i32): i32 {
  if (capacity <= 0) {
    s.keys = 0;
    s.occupied = 0;
    s.cap = 0;
    s.length = 0;
    return 0;
  }
  let k: *u64 = heap_libc.heap_alloc_u64_c(capacity);
  let o: *u8 = heap_libc.heap_alloc_u8_c(capacity);
  if (k == 0 || o == 0) {
    if (k != 0) { heap_libc.heap_free_u64_c(k); }
    if (o != 0) { heap_libc.heap_free_u8_c(o); }
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
  s.length = 0;
  return 0;
}

/** Exported function `grow`.
 * Implements `grow`.
 * @param s *Set_u64
 * @param new_cap i32
 * @return i32
 */
export function grow(s: *Set_u64, new_cap: i32): i32 {
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
  heap_libc.heap_free_u64_c(old_keys);
  heap_libc.heap_free_u8_c(old_occupied);
  return 0;
}

/** Exported function `reserve_one`.
 * Implements `reserve_one`.
 * @param s *Set_u64
 * @return i32
 */
export function reserve_one(s: *Set_u64): i32 {
  if (s.cap <= 0) {
    return with_capacity(s, 8);
  }
  if (s.length + 1 <= s.cap * 3 / 4) { return 0; }
  return grow(s, s.cap * 2);
}

/** Exported function `insert`.
 * Implements `insert`.
 * @param s *Set_u64
 * @param key u64
 * @return i32
 */
export function insert(s: *Set_u64, key: u64): i32 {
  if (reserve_one(s) != 0) { return -1; }
  let start: i32 = 0;
  unsafe { start = slot(*s, key); }
  let i: i32 = start;
  loop {
    if (s.occupied[i] == 0) {
      s.keys[i] = key;
      s.occupied[i] = 1;
      s.length = s.length + 1;
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

/** Exported function `contains_key`.
 * Implements `contains_key`.
 * @param s Set_u64
 * @param key u64
 * @return i32
 */
export function contains_key(s: Set_u64, key: u64): i32 {
  if (find(s, key) >= 0) { return 1; }
  return 0;
}

/** Exported function `remove`.
 * Implements `remove`.
 * @param s *Set_u64
 * @param key u64
 * @return i32
 */
export function remove(s: *Set_u64, key: u64): i32 {
  let idx: i32 = 0;
  unsafe { idx = find(*s, key); }
  if (idx < 0) { return 0; }
  s.occupied[idx] = 0;
  s.length = s.length - 1;
  return 1;
}

/** Exported function `len`.
 * Implements `len`.
 * @param s Set_u64
 * @return i32
 */
export function length(s: Set_u64): i32 { return s.length; }

/** Exported function `deinit`.
 * Implements `deinit`.
 * @param s *Set_u64
 * @return void
 */
export function deinit(s: *Set_u64): void {
  if (s.keys != 0) { heap_libc.heap_free_u64_c(s.keys); s.keys = 0; }
  if (s.occupied != 0) { heap_libc.heap_free_u8_c(s.occupied); s.occupied = 0; }
  s.cap = 0;
  s.length = 0;
}

// See implementation.

/** Exported function `str_key_cap`.
 * Implements `str_key_cap`.
 * @return i32
 */
export function str_key_cap(): i32 { return 32; }

/** Exported function `hash_bytes`.
 * Implements `hash_bytes`.
 * @param ptr *u8
 * @param len i32
 * @return u64
 */
export function hash_bytes(ptr: *u8, len: i32): u64 {
  return hash_mod.bytes(ptr, len);
}

/* See implementation. */
allow(padding) struct Set_str {
  keys: *u8;
  lens: *i32;
  occupied: *u8;
  cap: i32;
  length: i32;
}

/** Exported function `str_new`.
 * Implements `str_new`.
 * @return Set_str
 */
export function str_new(): Set_str {
  return Set_str { keys: 0, lens: 0, occupied: 0, cap: 0, length: 0 };
}

/** Exported function `str_with_capacity`.
 * Implements `str_with_capacity`.
 * @param s *Set_str
 * @param capacity i32
 * @return i32
 */
export function str_with_capacity(s: *Set_str, capacity: i32): i32 {
  if (capacity <= 0) {
    s.keys = 0;
    s.lens = 0;
    s.occupied = 0;
    s.cap = 0;
    s.length = 0;
    return 0;
  }
  let kcap: i32 = str_key_cap();
  let keys: *u8 = heap_libc.heap_alloc_u8_c(capacity * kcap);
  let lens: *i32 = heap_libc.heap_alloc_i32_c(capacity);
  let occ: *u8 = heap_libc.heap_alloc_u8_c(capacity);
  if (keys == 0 || lens == 0 || occ == 0) {
    if (keys != 0) { heap_libc.heap_free_u8_c(keys); }
    if (lens != 0) { heap_libc.heap_free_i32_c(lens); }
    if (occ != 0) { heap_libc.heap_free_u8_c(occ); }
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
  s.length = 0;
  return 0;
}

/** Exported function `str_slot`.
 * Implements `str_slot`.
 * @param s Set_str
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function str_slot(s: Set_str, ptr: *u8, len: i32): i32 {
  let h: u64 = hash_bytes(ptr, len);
  let cap_u: u64 = s.cap as u64;
  if (cap_u == 0) { return 0; }
  return (h % cap_u) as i32;
}

/** Exported function `str_key_eq`.
 * Implements `str_key_eq`.
 * @param s Set_str
 * @param slot i32
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function str_key_eq(s: Set_str, slot: i32, ptr: *u8, len: i32): i32 {
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

/** Exported function `str_find`.
 * Implements `str_find`.
 * @param s Set_str
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function str_find(s: Set_str, ptr: *u8, len: i32): i32 {
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

/** Exported function `str_grow`.
 * Implements `str_grow`.
 * @param s *Set_str
 * @param new_cap i32
 * @return i32
 */
export function str_grow(s: *Set_str, new_cap: i32): i32 {
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
  heap_libc.heap_free_u8_c(old_keys);
  heap_libc.heap_free_i32_c(old_lens);
  heap_libc.heap_free_u8_c(old_occ);
  return 0;
}

/** Exported function `str_reserve_one`.
 * Implements `str_reserve_one`.
 * @param s *Set_str
 * @return i32
 */
export function str_reserve_one(s: *Set_str): i32 {
  if (s.cap <= 0) { return str_with_capacity(s, 8); }
  if (s.length + 1 <= s.cap * 3 / 4) { return 0; }
  return str_grow(s, s.cap * 2);
}

/** Exported function `str_insert`.
 * Implements `str_insert`.
 * @param s *Set_str
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function str_insert(s: *Set_str, ptr: *u8, len: i32): i32 {
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
      s.length = s.length + 1;
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

/** Exported function `str_contains`.
 * Implements `str_contains`.
 * @param s Set_str
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function str_contains(s: Set_str, ptr: *u8, len: i32): i32 {
  if (str_find(s, ptr, len) >= 0) { return 1; }
  return 0;
}

/** Exported function `str_remove`.
 * Implements `str_remove`.
 * @param s *Set_str
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function str_remove(s: *Set_str, ptr: *u8, len: i32): i32 {
  let idx: i32 = 0;
  unsafe { idx = str_find(*s, ptr, len); }
  if (idx < 0) { return 0; }
  s.occupied[idx] = 0;
  s.lens[idx] = 0;
  s.length = s.length - 1;
  return 1;
}

/** Exported function `str_len`.
 * Query helper `str_len`.
 * @param s Set_str
 * @return i32
 */
export function str_len(s: Set_str): i32 { return s.length; }

/** Exported function `str_deinit`.
 * Implements `str_deinit`.
 * @param s *Set_str
 * @return void
 */
export function str_deinit(s: *Set_str): void {
  if (s.keys != 0) { heap_libc.heap_free_u8_c(s.keys); s.keys = 0; }
  if (s.lens != 0) { heap_libc.heap_free_i32_c(s.lens); s.lens = 0; }
  if (s.occupied != 0) { heap_libc.heap_free_u8_c(s.occupied); s.occupied = 0; }
  s.cap = 0;
  s.length = 0;
}
