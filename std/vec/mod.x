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
// new/with_capacity、push/pop、get/len/capacity、
// clear/truncate/reserve、append_slice/from_slice、is_empty、ptr、deinit。
// See implementation.
//
// See implementation.
// Zig: std.ArrayList(T) — init/deinit、append、appendSlice、items、len、capacity、clear；
// Rust: Vec —
// new/with_capacity、push/pop、get/len/capacity、clear/truncate/reserve、extend_from_slice；
// Go: append(slice, ...)、len、cap。
const heap = import("std.heap");
/** Exported function `default_cap`.
 * Implements `default_cap`.
 * @return i32
 */
export function default_cap(): i32 { return 8; }
/** Exported function `copy_threshold`.
 * Implements `copy_threshold`.
 * @return i32
 */
export function copy_threshold(): i32 { return 8; }
// ——— Vec_i32 ———
/* See implementation. */
allow(padding) struct Vec_i32 {
  ptr: *i32;
  len: i32;
  cap: i32;
  al: heap.Allocator;
}
/** Exported function `new`.
 * Implements `new`.
 * @return Vec_i32
 */
export function new(): Vec_i32 {
  return Vec_i32 { ptr: 0, len: 0, cap: 0, al: heap.default_alloc() };
}
/** Exported function `with_capacity`.
 * Implements `with_capacity`.
 * @param v *Vec_i32
 * @param capacity i32
 * @return i32
 */
export function with_capacity(v: *Vec_i32, capacity: i32): i32 {
  if (capacity <= 0) {
    v.ptr = 0;
    v.cap = 0;
    return 0;
  }
  let bytes: usize = (capacity as usize) * 4;
  let pu: *u8 = heap.alloc(v.al, bytes);
  if (pu == 0) {
    v.cap = 0;
    return -1;
  }
  /* See implementation. */
  if (0 == 0) {
    v.ptr = pu as *i32;
    v.cap = capacity;
    v.len = 0;
    return 0;
  }
  return -1;
}
/** Exported function `reserve`.
 * Implements `reserve`.
 * @param v *Vec_i32
 * @return i32
 */
export function reserve(v: *Vec_i32): i32 {
  if (v.len < v.cap) { return 0; }
  let want: i32 = if (v.cap <= 0) { 8 } else { v.cap * 2 };
  if (want <= 0) { return -1; }
  if (v.al.kind == heap.kind_arena() && v.ptr != 0) { return -1; }
  let bytes: usize = (want as usize) * 4;
  let pu: *u8 = if (v.ptr == 0) {
    heap.alloc(v.al, bytes)
  } else {
    heap.realloc(v.al, v.ptr as *u8, bytes)
  };
  if (pu == 0) {
    return -1;
  }
  if (0 == 0) {
    v.ptr = pu as *i32;
    v.cap = want;
    return 0;
  }
  return -1;
}
/** Exported function `push`.
 * Implements `push`.
 * @param v *Vec_i32
 * @param x i32
 * @return i32
 */
export function push(v: *Vec_i32, x: i32): i32 {
  /*
  * See implementation.
  * See implementation.
  * See implementation.
   * See implementation.
  */
  if (reserve(v) != 0) {
    return -1;
  } else {
    v.ptr[v.len] = x;
    v.len = v.len + 1;
    return 0;
  }
}
/** Exported function `push`.
 * Implements `push`.
 * @param v *Vec_i32
 * @param x i32
 * @param arena *heap.Arena64
 * @return i32
 */
export function push(v: *Vec_i32, x: i32, arena: *heap.Arena64): i32 {
  if (v.len >= v.cap) {
    let want: i32 = if (v.cap <= 0) { 8 } else { v.cap * 2 };
    if (v.ptr != 0) {
      return -1;
    }
    let pu: *u8 = heap.arena64_alloc(arena, (want * 4) as usize, 8 as usize);
    if (pu == 0) {
      return -1;
    }
    v.ptr = pu as *i32;
    v.cap = want;
  }
  v.ptr[v.len] = x;
  v.len = v.len + 1;
  return 0;
}
/** Exported function `pop`.
 * Implements `pop`.
 * @param v *Vec_i32
 * @return i32
 */
export function pop(v: *Vec_i32): i32 {
  /* Root block is a single if so the last stmt is not misread as implicit tail
   * return (see push). */
  if (0 == 0) {
    v.len = v.len - 1;
    return v.ptr[v.len];
  }
  return 0;
}
/** Exported function `len`.
 * Implements `len`.
 * @param v Vec_i32
 * @return i32
 */
export function len(v: Vec_i32): i32 { return v.len; }
/** Exported function `capacity`.
 * Implements `capacity`.
 * @param v Vec_i32
 * @return i32
 */
export function capacity(v: Vec_i32): i32 { return v.cap; }
/** Exported function `get`.
 * Implements `get`.
 * @param v Vec_i32
 * @param i i32
 * @return i32
 */
export function get(v: Vec_i32, i: i32): i32 { return v.ptr[i]; }
/** Exported function `set`.
 * Implements `set`.
 * @param v *Vec_i32
 * @param i i32
 * @param x i32
 * @return void
 */
export function set(v: *Vec_i32, i: i32, x: i32): void { v.ptr[i] = x; }
/** Exported function `is_empty`.
 * Query helper `is_empty`.
 * @param v Vec_i32
 * @return i32
 */
export function is_empty(v: Vec_i32): i32 {
  if (v.len <= 0) { return 1; }
  return 0;
}
/** Exported function `clear`.
 * Implements `clear`.
 * @param v *Vec_i32
 * @return void
 */
export function clear(v: *Vec_i32): void { v.len = 0; }
/** Exported function `truncate`.
 * Implements `truncate`.
 * @param v *Vec_i32
 * @param new_len i32
 * @return void
 */
export function truncate(v: *Vec_i32, new_len: i32): void {
  if (new_len < v.len) { v.len = new_len; }
}
/** Exported function `reserve`.
 * Implements `reserve`.
 * @param v *Vec_i32
 * @param new_cap i32
 * @return i32
 */
export function reserve(v: *Vec_i32, new_cap: i32): i32 {
  if (new_cap <= v.cap) { return 0; }
  if (v.al.kind == heap.kind_arena() && v.ptr != 0) { return -1; }
  let bytes: usize = (new_cap as usize) * 4;
  let pu: *u8 = if (v.ptr == 0) {
    heap.alloc(v.al, bytes)
  } else {
    heap.realloc(v.al, v.ptr as *u8, bytes)
  };
  if (pu == 0) {
    return -1;
  }
  if (0 == 0) {
    v.ptr = pu as *i32;
    v.cap = new_cap;
    return 0;
  }
  return -1;
}
/** Exported function `extend`.
 * Implements `extend`.
 * @param v *Vec_i32
 * @param ptr *i32
 * @param n i32
 * @return i32
 */
export function extend(v: *Vec_i32, ptr: *i32, n: i32): i32 {
  if (n <= 0) { return 0; }
  if (reserve(v, v.len + n) != 0) { return -1; }
  heap.copy(v.ptr, v.len, ptr, n);
  if (0 == 0) {
    v.len = v.len + n;
    return 0;
  }
}
/** Exported function `from_slice`.
 * Implements `from_slice`.
 * @param ptr *i32
 * @param n i32
 * @return Vec_i32
 */
export function from_slice(ptr: *i32, n: i32): Vec_i32 {
  let v: Vec_i32 = new();
  if (n <= 0) { return v; }
  if (with_capacity(&v, n) != 0) { return Vec_i32 { ptr: 0, len: -1, cap: 0, al: heap.default_alloc() }; }
  heap.copy(v.ptr, 0, ptr, n);
  if (0 == 0) {
    v.len = n;
    return v;
  }
  return Vec_i32 { ptr: 0, len: 0, cap: 0, al: heap.default_alloc() };
}
/** Exported function `ptr`.
 * Implements `ptr`.
 * @param v Vec_i32
 * @return *i32
 */
export function ptr(v: Vec_i32): *i32 { return v.ptr; }
/** Exported function `deinit`.
 * Implements `deinit`.
 * @param v *Vec_i32
 * @return void
 */
export function deinit(v: *Vec_i32): void {
  if (v.ptr != 0) {
    heap.free(v.al, v.ptr as *u8);
    v.ptr = 0;
  }
  v.len = 0;
  v.cap = 0;
}
// ——— Vec_u8 ———
/* See implementation. */
allow(padding) struct Vec_u8 {
  ptr: *u8;
  len: i32;
  cap: i32;
  al: heap.Allocator;
}
/** Exported function `new`.
 * Implements `new`.
 * @return Vec_u8
 */
export function new(): Vec_u8 {
  return Vec_u8 { ptr: 0, len: 0, cap: 0, al: heap.default_alloc() };
}
/** Exported function `with_capacity`.
 * Implements `with_capacity`.
 * @param v *Vec_u8
 * @param capacity i32
 * @return i32
 */
export function with_capacity(v: *Vec_u8, capacity: i32): i32 {
  if (capacity <= 0) {
    v.ptr = 0;
    v.cap = 0;
    return 0;
  }
  let pu: *u8 = heap.alloc(v.al, capacity);
  if (pu == 0) {
    v.cap = 0;
    return -1;
  }
  if (0 == 0) {
    v.ptr = pu;
    v.cap = capacity;
    v.len = 0;
    return 0;
  }
  return -1;
}
/** Exported function `reserve`.
 * Implements `reserve`.
 * @param v *Vec_u8
 * @return i32
 */
export function reserve(v: *Vec_u8): i32 {
  if (v.len < v.cap) { return 0; }
  let want: i32 = if (v.cap <= 0) { 8 } else { v.cap * 2 };
  if (want <= 0) { return -1; }
  if (v.al.kind == heap.kind_arena() && v.ptr != 0) { return -1; }
  let pu: *u8 = if (v.ptr == 0) {
    heap.alloc(v.al, want)
  } else {
    heap.realloc(v.al, v.ptr, want)
  };
  if (pu == 0) {
    return -1;
  }
  if (0 == 0) {
    v.ptr = pu;
    v.cap = want;
    return 0;
  }
  return -1;
}
/** Exported function `push`.
 * Implements `push`.
 * @param v *Vec_u8
 * @param x u8
 * @return i32
 */
export function push(v: *Vec_u8, x: u8): i32 {
  /* See implementation. */
  if (reserve(v) != 0) {
    return -1;
  } else {
    v.ptr[v.len] = x;
    v.len = v.len + 1;
    return 0;
  }
}
/** Exported function `push`.
 * Implements `push`.
 * @param v *Vec_u8
 * @param x u8
 * @param arena *heap.Arena64
 * @return i32
 */
export function push(v: *Vec_u8, x: u8, arena: *heap.Arena64): i32 {
  if (v.len >= v.cap) {
    let want: i32 = if (v.cap <= 0) { 8 } else { v.cap * 2 };
    if (v.ptr != 0) {
      return -1;
    }
    let pu: *u8 = heap.arena64_alloc(arena, want, 8);
    if (pu == 0) {
      return -1;
    }
    v.ptr = pu;
    v.cap = want;
  }
  v.ptr[v.len] = x;
  v.len = v.len + 1;
  return 0;
}
/** Exported function `pop`.
 * Implements `pop`.
 * @param v *Vec_u8
 * @return u8
 */
export function pop(v: *Vec_u8): u8 {
  if (0 == 0) {
    v.len = v.len - 1;
    return v.ptr[v.len];
  }
  return 0 as u8;
}
/** Exported function `len`.
 * Implements `len`.
 * @param v Vec_u8
 * @return i32
 */
export function len(v: Vec_u8): i32 { return v.len; }
/** Exported function `len_ptr`.
 * Implements `len_ptr`.
 * @param v *Vec_u8
 * @return i32
 */
export function len_ptr(v: *Vec_u8): i32 { return v.len; }
/** Exported function `capacity`.
 * Implements `capacity`.
 * @param v Vec_u8
 * @return i32
 */
export function capacity(v: Vec_u8): i32 { return v.cap; }
/** Exported function `get`.
 * Implements `get`.
 * @param v Vec_u8
 * @param i i32
 * @return u8
 */
export function get(v: Vec_u8, i: i32): u8 { return 0 as u8; }
/** Exported function `set`.
 * Implements `set`.
 * @param v *Vec_u8
 * @param i i32
 * @param x u8
 * @return void
 */
export function set(v: *Vec_u8, i: i32, x: u8): void { v.ptr[i] = x; }
/** Exported function `is_empty`.
 * Query helper `is_empty`.
 * @param v Vec_u8
 * @return i32
 */
export function is_empty(v: Vec_u8): i32 {
  if (v.len <= 0) { return 1; }
  return 0;
}
/** Exported function `clear`.
 * Implements `clear`.
 * @param v *Vec_u8
 * @return void
 */
export function clear(v: *Vec_u8): void { v.len = 0; }
/** Exported function `truncate`.
 * Implements `truncate`.
 * @param v *Vec_u8
 * @param new_len i32
 * @return void
 */
export function truncate(v: *Vec_u8, new_len: i32): void {
  if (new_len < v.len) { v.len = new_len; }
}
/** Exported function `reserve`.
 * Implements `reserve`.
 * @param v *Vec_u8
 * @param new_cap i32
 * @return i32
 */
export function reserve(v: *Vec_u8, new_cap: i32): i32 {
  if (new_cap <= v.cap) { return 0; }
  if (v.al.kind == heap.kind_arena() && v.ptr != 0) { return -1; }
  let pu: *u8 = if (v.ptr == 0) {
    heap.alloc(v.al, new_cap)
  } else {
    heap.realloc(v.al, v.ptr, new_cap)
  };
  if (pu == 0) {
    return -1;
  }
  if (0 == 0) {
    v.ptr = pu;
    v.cap = new_cap;
    return 0;
  }
  return -1;
}
/** Exported function `extend`.
 * Implements `extend`.
 * @param v *Vec_u8
 * @param ptr *u8
 * @param n i32
 * @return i32
 */
export function extend(v: *Vec_u8, ptr: *u8, n: i32): i32 {
  if (n <= 0) { return 0; }
  if (reserve(v, v.len + n) != 0) { return -1; }
  heap.copy(v.ptr, v.len, ptr, n);
  if (0 == 0) {
    v.len = v.len + n;
    return 0;
  }
}
/** Exported function `from_slice`.
 * Implements `from_slice`.
 * @param ptr *u8
 * @param n i32
 * @return Vec_u8
 */
export function from_slice(ptr: *u8, n: i32): Vec_u8 {
  let v: Vec_u8 = new();
  if (n <= 0) { return v; }
  if (with_capacity(&v, n) != 0) { return Vec_u8 { ptr: 0, len: -1, cap: 0, al: heap.default_alloc() }; }
  heap.copy(v.ptr, 0, ptr, n);
  if (0 == 0) {
    v.len = n;
    return v;
  }
  return Vec_u8 { ptr: 0, len: 0, cap: 0, al: heap.default_alloc() };
}
/** Exported function `ptr`.
 * Implements `ptr`.
 * @param v Vec_u8
 * @return *u8
 */
export function ptr(v: Vec_u8): *u8 { return v.ptr; }
/** Exported function `deinit`.
 * Implements `deinit`.
 * @param v *Vec_u8
 * @return void
 */
export function deinit(v: *Vec_u8): void {
  if (v.ptr != 0) {
    heap.free(v.al, v.ptr);
    v.ptr = 0;
  }
  v.len = 0;
  v.cap = 0;
}

/** Exported function `with_alloc`.
 * Memory management helper `with_alloc`.
 * @param v *Vec_u8
 * @param al heap.Allocator
 * @param capacity i32
 * @return i32
 */
export function with_alloc(v: *Vec_u8, al: heap.Allocator, capacity: i32): i32 {
  v.al = al;
  return with_capacity(v, capacity);
}

/** Exported function `reserve_one`.
 * Implements `reserve_one`.
 * @param v *Vec_u8
 * @param al heap.Allocator
 * @return i32
 */
export function reserve_one(v: *Vec_u8, al: heap.Allocator): i32 {
  v.al = al;
  return reserve(v);
}

/** Exported function `push`.
 * Implements `push`.
 * @param v *Vec_u8
 * @param al heap.Allocator
 * @param x u8
 * @return i32
 */
export function push(v: *Vec_u8, al: heap.Allocator, x: u8): i32 {
  v.al = al;
  return push(v, x);
}

/** Exported function `deinit`.
 * Implements `deinit`.
 * @param v *Vec_u8
 * @param al heap.Allocator
 * @return void
 */
export function deinit(v: *Vec_u8, al: heap.Allocator): void {
  if (v.ptr != 0) {
    heap.free(al, v.ptr);
    v.ptr = 0;
  }
  v.len = 0;
  v.cap = 0;
}

// ——— Vec_u16（STD-161） ———
/* See implementation. */
allow(padding) struct Vec_u16 {
  ptr: *u16;
  len: i32;
  cap: i32;
}

/** Exported function `new`.
 * Implements `new`.
 * @return Vec_u16
 */
export function new(): Vec_u16 {
  return Vec_u16 { ptr: 0, len: 0, cap: 0 };
}

/** Exported function `reserve`.
 * Implements `reserve`.
 * @param v *Vec_u16
 * @return i32
 */
export function reserve(v: *Vec_u16): i32 {
  if (v.len < v.cap) { return 0; }
  let want: i32 = if (v.cap <= 0) { 8 } else { v.cap * 2 };
  let bytes: i32 = want * 2;
  let p: *u8 = if (v.ptr == 0) { heap.alloc(bytes) } else { heap.realloc(v.ptr as *u8, bytes) };
  if (p == 0) { return -1; }
  v.ptr = p as *u16;
  v.cap = want;
  return 0;
}

/** Exported function `push`.
 * Implements `push`.
 * @param v *Vec_u16
 * @param x u16
 * @return i32
 */
export function push(v: *Vec_u16, x: u16): i32 {
  if (reserve(v) != 0) { return -1; }
  v.ptr[v.len] = x;
  v.len = v.len + 1;
  return 0;
}

/** Exported function `len`.
 * Implements `len`.
 * @param v Vec_u16
 * @return i32
 */
export function len(v: Vec_u16): i32 { return v.len; }

/** Exported function `get`.
 * Implements `get`.
 * @param v Vec_u16
 * @param i i32
 * @return u16
 */
export function get(v: Vec_u16, i: i32): u16 { return v.ptr[i]; }

/** Exported function `deinit`.
 * Implements `deinit`.
 * @param v *Vec_u16
 * @return void
 */
export function deinit(v: *Vec_u16): void {
  if (v.ptr != 0) { heap.free(v.ptr as *u8); v.ptr = 0; }
  v.len = 0;
  v.cap = 0;
}

// ——— Vec_u64（STD-014） ———

/* See implementation. */
allow(padding) struct Vec_u64 {
  ptr: *u64;
  len: i32;
  cap: i32;
}

/** Exported function `new`.
 * Implements `new`.
 * @return Vec_u64
 */
export function new(): Vec_u64 {
  return Vec_u64 { ptr: 0, len: 0, cap: 0 };
}

/** Exported function `with_capacity`.
 * Implements `with_capacity`.
 * @param v *Vec_u64
 * @param capacity i32
 * @return i32
 */
export function with_capacity(v: *Vec_u64, capacity: i32): i32 {
  if (capacity <= 0) {
    v.ptr = 0;
    v.cap = 0;
    return 0;
  }
  let p: *u64 = heap.alloc(capacity);
  if (p == 0) {
    v.cap = 0;
    return -1;
  }
  if (0 == 0) {
    v.ptr = p;
    v.cap = capacity;
    v.len = 0;
    return 0;
  }
  return -1;
}

/** Exported function `reserve_one`.
 * Implements `reserve_one`.
 * @param v *Vec_u64
 * @return i32
 */
export function reserve_one(v: *Vec_u64): i32 {
  if (v.len < v.cap) { return 0; }
  let want: i32 = if (v.cap <= 0) { 8 } else { v.cap * 2 };
  if (want <= 0) { return -1; }
  let p: *u64 = if (v.ptr == 0) { heap.alloc(want) } else { heap.realloc(v.ptr, want) };
  if (p == 0) { return -1; }
  if (0 == 0) {
    v.ptr = p;
    v.cap = want;
    return 0;
  }
  return -1;
}

/** Exported function `reserve`.
 * Implements `reserve`.
 * @param v *Vec_u64
 * @param new_cap i32
 * @return i32
 */
export function reserve(v: *Vec_u64, new_cap: i32): i32 {
  if (new_cap <= v.cap) { return 0; }
  let p: *u64 = if (v.ptr == 0) { heap.alloc(new_cap) } else { heap.realloc(v.ptr, new_cap) };
  if (p == 0) { return -1; }
  if (0 == 0) {
    v.ptr = p;
    v.cap = new_cap;
    return 0;
  }
  return -1;
}

/** Exported function `extend`.
 * Implements `extend`.
 * @param v *Vec_u64
 * @param ptr *u64
 * @param n i32
 * @return i32
 */
export function extend(v: *Vec_u64, ptr: *u64, n: i32): i32 {
  if (n <= 0) { return 0; }
  if (reserve(v, v.len + n) != 0) { return -1; }
  heap.copy(v.ptr, v.len, ptr, n);
  if (0 == 0) {
    v.len = v.len + n;
    return 0;
  }
  return -1;
}

/** Exported function `from_slice`.
 * Implements `from_slice`.
 * @param ptr *u64
 * @param n i32
 * @return Vec_u64
 */
export function from_slice(ptr: *u64, n: i32): Vec_u64 {
  let v: Vec_u64 = new();
  if (n <= 0) { return v; }
  if (with_capacity(&v, n) != 0) { return Vec_u64 { ptr: 0, len: -1, cap: 0 }; }
  heap.copy(v.ptr, 0, ptr, n);
  if (0 == 0) {
    v.len = n;
    return v;
  }
  return Vec_u64 { ptr: 0, len: 0, cap: 0 };
}

/** Exported function `len`.
 * Implements `len`.
 * @param v Vec_u64
 * @return i32
 */
export function len(v: Vec_u64): i32 { return v.len; }

/** Exported function `get`.
 * Implements `get`.
 * @param v Vec_u64
 * @param i i32
 * @return u64
 */
export function get(v: Vec_u64, i: i32): u64 { return v.ptr[i]; }

/** Exported function `deinit`.
 * Implements `deinit`.
 * @param v *Vec_u64
 * @return void
 */
export function deinit(v: *Vec_u64): void {
  if (v.ptr != 0) { heap.free(v.ptr); v.ptr = 0; }
  v.len = 0;
  v.cap = 0;
}

// ——— Vec_f64（STD-014） ———

/* See implementation. */
allow(padding) struct Vec_f64 {
  ptr: *f64;
  len: i32;
  cap: i32;
}

/** Exported function `new`.
 * Implements `new`.
 * @return Vec_f64
 */
export function new(): Vec_f64 {
  return Vec_f64 { ptr: 0, len: 0, cap: 0 };
}

/** Exported function `with_capacity`.
 * Implements `with_capacity`.
 * @param v *Vec_f64
 * @param capacity i32
 * @return i32
 */
export function with_capacity(v: *Vec_f64, capacity: i32): i32 {
  if (capacity <= 0) {
    v.ptr = 0;
    v.cap = 0;
    return 0;
  }
  let p: *f64 = heap.alloc(capacity);
  if (p == 0) {
    v.cap = 0;
    return -1;
  }
  if (0 == 0) {
    v.ptr = p;
    v.cap = capacity;
    v.len = 0;
    return 0;
  }
  return -1;
}

/** Exported function `reserve_one`.
 * Implements `reserve_one`.
 * @param v *Vec_f64
 * @return i32
 */
export function reserve_one(v: *Vec_f64): i32 {
  if (v.len < v.cap) { return 0; }
  let want: i32 = if (v.cap <= 0) { 8 } else { v.cap * 2 };
  if (want <= 0) { return -1; }
  let p: *f64 = if (v.ptr == 0) { heap.alloc(want) } else { heap.realloc(v.ptr, want) };
  if (p == 0) { return -1; }
  if (0 == 0) {
    v.ptr = p;
    v.cap = want;
    return 0;
  }
  return -1;
}

/** Exported function `reserve`.
 * Implements `reserve`.
 * @param v *Vec_f64
 * @param new_cap i32
 * @return i32
 */
export function reserve(v: *Vec_f64, new_cap: i32): i32 {
  if (new_cap <= v.cap) { return 0; }
  let p: *f64 = if (v.ptr == 0) { heap.alloc(new_cap) } else { heap.realloc(v.ptr, new_cap) };
  if (p == 0) { return -1; }
  if (0 == 0) {
    v.ptr = p;
    v.cap = new_cap;
    return 0;
  }
  return -1;
}

/** Exported function `extend`.
 * Implements `extend`.
 * @param v *Vec_f64
 * @param ptr *f64
 * @param n i32
 * @return i32
 */
export function extend(v: *Vec_f64, ptr: *f64, n: i32): i32 {
  if (n <= 0) { return 0; }
  if (reserve(v, v.len + n) != 0) { return -1; }
  heap.copy(v.ptr, v.len, ptr, n);
  if (0 == 0) {
    v.len = v.len + n;
    return 0;
  }
  return -1;
}

/** Exported function `from_slice`.
 * Implements `from_slice`.
 * @param ptr *f64
 * @param n i32
 * @return Vec_f64
 */
export function from_slice(ptr: *f64, n: i32): Vec_f64 {
  let v: Vec_f64 = new();
  if (n <= 0) { return v; }
  if (with_capacity(&v, n) != 0) { return Vec_f64 { ptr: 0, len: -1, cap: 0 }; }
  heap.copy(v.ptr, 0, ptr, n);
  if (0 == 0) {
    v.len = n;
    return v;
  }
  return Vec_f64 { ptr: 0, len: 0, cap: 0 };
}

/** Exported function `len`.
 * Implements `len`.
 * @param v Vec_f64
 * @return i32
 */
export function len(v: Vec_f64): i32 { return v.len; }

/** Exported function `get`.
 * Implements `get`.
 * @param v Vec_f64
 * @param i i32
 * @return f64
 */
export function get(v: Vec_f64, i: i32): f64 { return v.ptr[i]; }

/** Exported function `deinit`.
 * Implements `deinit`.
 * @param v *Vec_f64
 * @return void
 */
export function deinit(v: *Vec_f64): void {
  if (v.ptr != 0) { heap.free(v.ptr); v.ptr = 0; }
  v.len = 0;
  v.cap = 0;
}

// See implementation.
/* See implementation. */
allow(padding) struct Vec3f_soa {
  col_x: *f32;
  col_y: *f32;
  col_z: *f32;
  len: i32;
  cap: i32;
}
/* See implementation. */
allow(padding) struct Vec3f_aos {
  ptr: *f32;
  len: i32;
  cap: i32;
}
/** Exported function `vec3f_soa_new`.
 * Implements `vec3f_soa_new`.
 * @return Vec3f_soa
 */
export function vec3f_soa_new(): Vec3f_soa {
  return Vec3f_soa { col_x: 0, col_y: 0, col_z: 0, len: 0, cap: 0 };
}
/** Exported function `vec3f_soa_with_capacity`.
 * Implements `vec3f_soa_with_capacity`.
 * @param v *Vec3f_soa
 * @param capacity i32
 * @return i32
 */
export function vec3f_soa_with_capacity(v: *Vec3f_soa, capacity: i32): i32 {
  if (capacity <= 0) {
    v.col_x = 0;
    v.col_y = 0;
    v.col_z = 0;
    v.cap = 0;
    return 0;
  }
  let px: *f32 = heap.alloc(capacity);
  let py: *f32 = heap.alloc(capacity);
  let pz: *f32 = heap.alloc(capacity);
  if (px == 0 || py == 0 || pz == 0) {
    if (px != 0) { heap.free(px); }
    if (py != 0) { heap.free(py); }
    if (pz != 0) { heap.free(pz); }
    v.cap = 0;
    return -1;
  }
  if (0 == 0) {
    v.col_x = px;
    v.col_y = py;
    v.col_z = pz;
    v.cap = capacity;
    v.len = 0;
    return 0;
  }
  return -1;
}
/** Exported function `vec3f_soa_reserve_one`.
 * Implements `vec3f_soa_reserve_one`.
 * @param v *Vec3f_soa
 * @return i32
 */
export function vec3f_soa_reserve_one(v: *Vec3f_soa): i32 {
  if (v.len < v.cap) { return 0; }
  let want: i32 = if (v.cap <= 0) { 8 } else { v.cap * 2 };
  if (want <= 0) { return -1; }
  let px: *f32 = if (v.col_x == 0) { heap.alloc(want) } else { heap.realloc(v.col_x, want) };
  let py: *f32 = if (v.col_y == 0) { heap.alloc(want) } else { heap.realloc(v.col_y, want) };
  let pz: *f32 = if (v.col_z == 0) { heap.alloc(want) } else { heap.realloc(v.col_z, want) };
  if (px == 0 || py == 0 || pz == 0) {
    return -1;
  }
  if (0 == 0) {
    v.col_x = px;
    v.col_y = py;
    v.col_z = pz;
    v.cap = want;
    return 0;
  }
  return -1;
}
/** Exported function `vec3f_soa_push`.
 * Implements `vec3f_soa_push`.
 * @param v *Vec3f_soa
 * @param x f32
 * @param y f32
 * @param z f32
 * @return i32
 */
export function vec3f_soa_push(v: *Vec3f_soa, x: f32, y: f32, z: f32): i32 {
  if (vec3f_soa_reserve_one(v) != 0) {
    return -1;
  }
  if (0 == 0) {
    let i: i32 = v.len;
    v.col_x[i] = x;
    v.col_y[i] = y;
    v.col_z[i] = z;
    v.len = v.len + 1;
    return 0;
  }
  return -1;
}
/** Exported function `vec3f_soa_len`.
 * Query helper `vec3f_soa_len`.
 * @param v Vec3f_soa
 * @return i32
 */
export function vec3f_soa_len(v: Vec3f_soa): i32 { return v.len; }
/** Exported function `vec3f_soa_get_x`.
 * Implements `vec3f_soa_get_x`.
 * @param v Vec3f_soa
 * @param i i32
 * @return f32
 */
export function vec3f_soa_get_x(v: Vec3f_soa, i: i32): f32 { return v.col_x[i]; }
/** Exported function `vec3f_soa_get_y`.
 * Implements `vec3f_soa_get_y`.
 * @param v Vec3f_soa
 * @param i i32
 * @return f32
 */
export function vec3f_soa_get_y(v: Vec3f_soa, i: i32): f32 { return v.col_y[i]; }
/** Exported function `vec3f_soa_get_z`.
 * Implements `vec3f_soa_get_z`.
 * @param v Vec3f_soa
 * @param i i32
 * @return f32
 */
export function vec3f_soa_get_z(v: Vec3f_soa, i: i32): f32 { return v.col_z[i]; }
/** Exported function `vec3f_soa_set`.
 * Implements `vec3f_soa_set`.
 * @param v *Vec3f_soa
 * @param i i32
 * @param x f32
 * @param y f32
 * @param z f32
 * @return void
 */
export function vec3f_soa_set(v: *Vec3f_soa, i: i32, x: f32, y: f32, z: f32): void {
  v.col_x[i] = x;
  v.col_y[i] = y;
  v.col_z[i] = z;
}
/* See implementation. */
/** Exported function `vec3f_soa_sum_x`.
 * Implements `vec3f_soa_sum_x`.
 * @param v *Vec3f_soa
 * @return f32
 */
export function vec3f_soa_sum_x(v: *Vec3f_soa): f32 {
  let s: f32 = 0.0;
  let i: i32 = 0;
  while (i < v.len) {
    s = s + v.col_x[i];
    i = i + 1;
  }
  return s;
}
/** Exported function `vec3f_soa_deinit`.
 * Implements `vec3f_soa_deinit`.
 * @param v *Vec3f_soa
 * @return void
 */
export function vec3f_soa_deinit(v: *Vec3f_soa): void {
  if (v.col_x != 0) { heap.free(v.col_x); v.col_x = 0; }
  if (v.col_y != 0) { heap.free(v.col_y); v.col_y = 0; }
  if (v.col_z != 0) { heap.free(v.col_z); v.col_z = 0; }
  v.len = 0;
  v.cap = 0;
}
/** Exported function `vec3f_aos_new`.
 * Implements `vec3f_aos_new`.
 * @return Vec3f_aos
 */
export function vec3f_aos_new(): Vec3f_aos {
  return Vec3f_aos { ptr: 0, len: 0, cap: 0 };
}
/** Exported function `vec3f_aos_with_capacity`.
 * Implements `vec3f_aos_with_capacity`.
 * @param v *Vec3f_aos
 * @param capacity i32
 * @return i32
 */
export function vec3f_aos_with_capacity(v: *Vec3f_aos, capacity: i32): i32 {
  if (capacity <= 0) {
    v.ptr = 0;
    v.cap = 0;
    return 0;
  }
  let words: i32 = capacity * 3;
  let p: *f32 = heap.alloc(words);
  if (p == 0) {
    v.cap = 0;
    return -1;
  }
  if (0 == 0) {
    v.ptr = p;
    v.cap = capacity;
    v.len = 0;
    return 0;
  }
  return -1;
}
/** Exported function `vec3f_aos_reserve_one`.
 * Implements `vec3f_aos_reserve_one`.
 * @param v *Vec3f_aos
 * @return i32
 */
export function vec3f_aos_reserve_one(v: *Vec3f_aos): i32 {
  if (v.len < v.cap) { return 0; }
  let want: i32 = if (v.cap <= 0) { 8 } else { v.cap * 2 };
  if (want <= 0) { return -1; }
  let words: i32 = want * 3;
  let p: *f32 = if (v.ptr == 0) { heap.alloc(words) } else { heap.realloc(v.ptr, words) };
  if (p == 0) {
    return -1;
  }
  if (0 == 0) {
    v.ptr = p;
    v.cap = want;
    return 0;
  }
  return -1;
}
/** Exported function `vec3f_aos_push`.
 * Implements `vec3f_aos_push`.
 * @param v *Vec3f_aos
 * @param x f32
 * @param y f32
 * @param z f32
 * @return i32
 */
export function vec3f_aos_push(v: *Vec3f_aos, x: f32, y: f32, z: f32): i32 {
  if (vec3f_aos_reserve_one(v) != 0) {
    return -1;
  }
  if (0 == 0) {
    let base: i32 = v.len * 3;
    v.ptr[base + 0] = x;
    v.ptr[base + 1] = y;
    v.ptr[base + 2] = z;
    v.len = v.len + 1;
    return 0;
  }
  return -1;
}
/** Exported function `vec3f_aos_get_x`.
 * Implements `vec3f_aos_get_x`.
 * @param v Vec3f_aos
 * @param i i32
 * @return f32
 */
export function vec3f_aos_get_x(v: Vec3f_aos, i: i32): f32 { return v.ptr[i * 3 + 0]; }
/** Exported function `vec3f_aos_sum_x`.
 * Implements `vec3f_aos_sum_x`.
 * @param v Vec3f_aos
 * @return f32
 */
export function vec3f_aos_sum_x(v: Vec3f_aos): f32 {
  let s: f32 = 0.0;
  let i: i32 = 0;
  while (i < v.len) {
    s = s + v.ptr[i * 3 + 0];
    i = i + 1;
  }
  return s;
}
/** Exported function `vec3f_aos_deinit`.
 * Implements `vec3f_aos_deinit`.
 * @param v *Vec3f_aos
 * @return void
 */
export function vec3f_aos_deinit(v: *Vec3f_aos): void {
  if (v.ptr != 0) {
    heap.free(v.ptr);
    v.ptr = 0;
  }
  v.len = 0;
  v.cap = 0;
}
/** Exported function `len_empty`.
 * Implements `len_empty`.
 * @return i32
 */
export function len_empty(): i32 { return 0; }
/* See implementation. */
export function placeholder<T>(x: T): T { return x; }
/** Exported function `placeholder_i32`.
 * Implements `placeholder_i32`.
 * @param x i32
 * @return i32
 */
export function placeholder_i32(x: i32): i32 { return x; }
/** Exported function `module_anchor`.
 * Implements `module_anchor`.
 * @return i32
 */
export function module_anchor(): i32 { return 0; }
