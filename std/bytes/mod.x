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
// See implementation.
// See implementation.
//
// See implementation.

const heap = import("std.heap");
const string = import("std.string");
const mem = import("std.mem");

/** Exported function `default_capacity`.
 * Implements `default_capacity`.
 * @return i32
 */
export function default_capacity(): i32 { return 8; }

/* See implementation. */
export const BYTES_OWN_HEAP: i32 = 1;
/* See implementation. */
export const BYTES_OWN_EXTERNAL: i32 = 0;

/* See implementation. */
allow(padding) struct Bytes {
  ptr: *u8;
  length: i32;
  cap: i32;
  owned: i32;
}

/* See implementation. */
allow(padding) struct BytesReader {
  buf: *Bytes;
  pos: i32;
}

/* See implementation. */
allow(padding) struct BytesWriter {
  buf: *Bytes;
}

/** Exported function `new`.
 * Implements `new`.
 * @return Bytes
 */
export function new(): Bytes {
  return Bytes { ptr: 0, length: 0, cap: 0, owned: BYTES_OWN_HEAP };
}

/**
 * See implementation.
 * See implementation.
 */
export function from_external(ptr: *u8, len: i32, cap: i32): Bytes {
  return Bytes { ptr: ptr, length: len, cap: cap, owned: BYTES_OWN_EXTERNAL };
}

/** Exported function `is_owned`.
 * Query helper `is_owned`.
 * @param b Bytes
 * @return i32
 */
export function is_owned(b: Bytes): i32 {
  if (b.owned != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function recommend_bytes_alloc(): i32 {
  return BYTES_OWN_HEAP;
}

/** Exported function `recommend_bytes_alloc_arena`.
 * Memory management helper `recommend_bytes_alloc_arena`.
 * @return i32
 */
export function recommend_bytes_alloc_arena(): i32 {
  return BYTES_OWN_EXTERNAL;
}

/** Exported function `with_capacity`.
 * Implements `with_capacity`.
 * @param b *Bytes
 * @param capacity i32
 * @return i32
 */
export function with_capacity(b: *Bytes, capacity: i32): i32 {
  if (b.owned == 0) {
    return -1;
  }
  if (capacity <= 0) {
    b.ptr = 0;
    b.cap = 0;
    b.length = 0;
    return 0;
  }
  let p: *u8 = heap.alloc(capacity);
  if (p == 0) {
    b.cap = 0;
    return -1;
  }
  if (0 == 0) {
    b.ptr = p;
    b.cap = capacity;
    b.length = 0;
    return 0;
  }
  return -1;
}

/** Exported function `reserve_one`.
 * Implements `reserve_one`.
 * @param b *Bytes
 * @return i32
 */
export function reserve_one(b: *Bytes): i32 {
  if (b.length < b.cap) { return 0; }
  if (b.owned == 0) {
    return -1;
  }
  let want: i32 = if (b.cap <= 0) { default_capacity() } else { b.cap * 2 };
  if (want <= 0) { return -1; }
  let p: *u8 = if (b.ptr == 0) { heap.alloc(want) } else { heap.realloc(b.ptr, want) };
  if (p == 0) {
    return -1;
  }
  if (0 == 0) {
    b.ptr = p;
    b.cap = want;
    return 0;
  }
  return -1;
}

/** Exported function `reserve`.
 * Implements `reserve`.
 * @param b *Bytes
 * @param new_cap i32
 * @return i32
 */
export function reserve(b: *Bytes, new_cap: i32): i32 {
  if (new_cap <= b.cap) { return 0; }
  if (b.owned == 0) {
    return -1;
  }
  let p: *u8 = if (b.ptr == 0) { heap.alloc(new_cap) } else { heap.realloc(b.ptr, new_cap) };
  if (p == 0) {
    return -1;
  }
  if (0 == 0) {
    b.ptr = p;
    b.cap = new_cap;
    return 0;
  }
  return -1;
}

/** Exported function `grow`.
 * Implements `grow`.
 * @param b *Bytes
 * @param extra i32
 * @return i32
 */
export function grow(b: *Bytes, extra: i32): i32 {
  if (extra <= 0) { return 0; }
  return reserve(b, b.length + extra);
}

/** Exported function `append_byte`.
 * Implements `append_byte`.
 * @param b *Bytes
 * @param x u8
 * @return i32
 */
export function append_byte(b: *Bytes, x: u8): i32 {
  if (reserve_one(b) != 0) {
    return -1;
  } else {
    b.ptr[b.length] = x;
    b.length = b.length + 1;
    return 0;
  }
}

/** Exported function `extend`.
 * Implements `extend`.
 * @param b *Bytes
 * @param ptr *u8
 * @param n i32
 * @return i32
 */
export function extend(b: *Bytes, ptr: *u8, n: i32): i32 {
  if (n <= 0) { return 0; }
  if (grow(b, n) != 0) { return -1; }
  heap.copy(b.ptr, b.length, ptr, n);
  if (0 == 0) {
    b.length = b.length + n;
    return 0;
  }
  return -1;
}

/** Exported function `from_slice`.
 * Implements `from_slice`.
 * @param ptr *u8
 * @param n i32
 * @return Bytes
 */
export function from_slice(ptr: *u8, n: i32): Bytes {
  let b: Bytes = new();
  if (n <= 0) { return b; }
  if (with_capacity(&b, n) != 0) {
    return Bytes { ptr: 0, length: -1, cap: 0, owned: BYTES_OWN_HEAP };
  }
  heap.copy(b.ptr, 0, ptr, n);
  if (0 == 0) {
    b.length = n;
    return b;
  }
  return new();
}

/** Exported function `len`.
 * Implements `len`.
 * @param b Bytes
 * @return i32
 */
export function length(b: Bytes): i32 { return b.length; }

/** Exported function `capacity`.
 * Implements `capacity`.
 * @param b Bytes
 * @return i32
 */
export function capacity(b: Bytes): i32 { return b.cap; }

/** Exported function `clear`.
 * Implements `clear`.
 * @param b *Bytes
 * @return void
 */
export function clear(b: *Bytes): void { b.length = 0; }

/** Exported function `deinit`.
 * Implements `deinit`.
 * @param b *Bytes
 * @return void
 */
export function deinit(b: *Bytes): void {
  if (b.owned != 0 && b.ptr != 0) {
    heap.free(b.ptr);
    b.ptr = 0;
  }
  b.length = 0;
  b.cap = 0;
  b.owned = BYTES_OWN_HEAP;
}

/** Exported function `as_view`.
 * Implements `as_view`.
 * @param b Bytes
 * @return StrView
 */
export function as_view(b: Bytes): StrView {
  return string.view(b.ptr, b.length);
}

/** Exported function `from_view`.
 * Implements `from_view`.
 * @param v StrView
 * @return Bytes
 */
export function from_view(v: StrView): Bytes {
  return from_slice(v.ptr, v.length);
}

/** Exported function `as_buffer`.
 * Implements `as_buffer`.
 * @param b Bytes
 * @return Buffer
 */
export function as_buffer(b: Bytes): Buffer {
  return Buffer { ptr: b.ptr, length: b.length, handle: 0 };
}

/**
 * See implementation.
 */
export function reader(b: *Bytes): BytesReader {
  return BytesReader { buf: b, pos: 0 };
}

/** Exported function `read`.
 * Read path helper `read`.
 * @param r *BytesReader
 * @param out *u8
 * @param n i32
 * @return i32
 */
export function read(r: *BytesReader, out: *u8, n: i32): i32 {
  let buf: *Bytes = r.buf;
  let remain: i32 = 0;
  let take: i32 = 0;
  if (buf == 0 || out == 0 || n <= 0) { return 0; }
  remain = buf.length - r.pos;
  if (remain <= 0) { return 0; }
  if (n < remain) {
    take = n;
  } else {
    take = remain;
  }
  let i: i32 = 0;
  while (i < take) {
    out[i] = buf.ptr[r.pos + i];
    i = i + 1;
  }
  r.pos = r.pos + take;
  return take;
}

/** Exported function `remaining`.
 * Implements `remaining`.
 * @param r BytesReader
 * @return i32
 */
export function remaining(r: BytesReader): i32 {
  let buf: *Bytes = r.buf;
  if (buf == 0) { return 0; }
  if (r.pos >= buf.length) { return 0; }
  return buf.length - r.pos;
}

/** Exported function `seek`.
 * Implements `seek`.
 * @param r *BytesReader
 * @param pos i32
 * @return i32
 */
export function seek(r: *BytesReader, pos: i32): i32 {
  let buf: *Bytes = r.buf;
  if (buf == 0) { return -1; }
  if (pos < 0 || pos > buf.length) { return -1; }
  if (0 == 0) {
    r.pos = pos;
    return 0;
  }
  return -1;
}

/**
 * See implementation.
 */
export function writer(b: *Bytes): BytesWriter {
  return BytesWriter { buf: b };
}

/** Exported function `write`.
 * Write path helper `write`.
 * @param w *BytesWriter
 * @param ptr *u8
 * @param n i32
 * @return i32
 */
export function write(w: *BytesWriter, ptr: *u8, n: i32): i32 {
  if (w.buf == 0) { return -1; }
  return extend(w.buf, ptr, n);
}

/** Exported function `remaining_cap`.
 * Implements `remaining_cap`.
 * @param w BytesWriter
 * @return i32
 */
export function remaining_cap(w: BytesWriter): i32 {
  let buf: *Bytes = w.buf;
  if (buf == 0) { return 0; }
  if (buf.cap <= buf.length) { return 0; }
  return buf.cap - buf.length;
}

/**
 * See implementation.
 * See implementation.
 */
export function eq(a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
  if (a_len != b_len) { return 0; }
  return if (mem.compare(a, b, a_len) == 0) { 1 } else { 0 };
}

/** Exported function `bytes_module_anchor`.
 * Implements `bytes_module_anchor`.
 * @return i32
 */
export function bytes_module_anchor(): i32 { return 0; }
