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

// note
// note
// note

const option = import("core.option");

/* note */
export struct SliceIter_i32 {
  ptr: *i32;
  length: usize;
  index: usize;
}

/* note */
export struct SliceIter_u8 {
  ptr: *u8;
  length: usize;
  index: usize;
}

/**
 * Start an i32 slice iterator.
 * @param s i32[] — source slice; data and length are copied into out
 * @param out *SliceIter_i32 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit this struct return.
 */
export function iter_i32(s: i32[], out: *SliceIter_i32): i32 {
  out.ptr = s.data;
  out.length = s.length;
  out.index = 0 as usize;
  return 0;
}

/**
 * Start a u8 slice iterator.
 * @param s u8[] — source slice; data and length are copied into out
 * @param out *SliceIter_u8 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit this struct return.
 */
export function iter_u8(s: u8[], out: *SliceIter_u8): i32 {
  out.ptr = s.data;
  out.length = s.length;
  out.index = 0 as usize;
  return 0;
}

/**
 * Take the next i32, or write a missing option.
 * @param it *SliceIter_i32 — iterator; index advances when a value is taken
 * @param out *Option_i32 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit an Option return.
 */
export function next_i32(it: *SliceIter_i32, out: *Option_i32): i32 {
  if (it.index >= it.length) {
    return option.none_i32(out);
  }
  let v: i32 = it.ptr[it.index];
  it.index = it.index + 1 as usize;
  return option.some_i32(out, v);
}

/**
 * Take the next u8, or write a missing option.
 * @param it *SliceIter_u8 — iterator; index advances when a value is taken
 * @param out *Option_u8 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit an Option return.
 */
export function next_u8(it: *SliceIter_u8, out: *Option_u8): i32 {
  if (it.index >= it.length) {
    return option.none_u8(out);
  }
  let v: u8 = it.ptr[it.index];
  it.index = it.index + 1 as usize;
  return option.some_u8(out, v);
}

/**
 * Count of i32 values not yet taken.
 * @param it *SliceIter_i32 — iterator; not advanced
 * @return i64 — remaining count in rax. Low 64 bits match usize.
 * PLATFORM: SHARED — the installed product cannot asm-emit this usize return.
 */
export function iter_remaining_i32(it: *SliceIter_i32): i64 {
  if (it.index >= it.length) { return 0; }
  let n: usize = it.length - it.index;
  return n as i64;
}

/**
 * Count of u8 values not yet taken.
 * @param it *SliceIter_u8 — iterator; not advanced
 * @return i64 — remaining count in rax. Low 64 bits match usize.
 * PLATFORM: SHARED — the installed product cannot asm-emit this usize return.
 */
export function iter_remaining_u8(it: *SliceIter_u8): i64 {
  if (it.index >= it.length) { return 0; }
  let n: usize = it.length - it.index;
  return n as i64;
}

/* note */
export struct SliceIter_u64 {
  ptr: *u64;
  length: usize;
  index: usize;
}

/** `iterator_protocol_version`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function iterator_protocol_version(): i32 { return 1; }

/**
 * Start a u64 iterator over a raw buffer.
 * @param ptr *u64 — first element; null is stored as-is
 * @param len usize — element count
 * @param out *SliceIter_u64 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit this struct return.
 */
export function iter_u64_from_buf(ptr: *u64, len: usize, out: *SliceIter_u64): i32 {
  out.ptr = ptr;
  out.length = len;
  out.index = 0 as usize;
  return 0;
}

/**
 * Take the next u64, or write a missing option.
 * @param it *SliceIter_u64 — iterator; index advances when a value is taken
 * @param out *Option_u64 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit an Option return.
 */
export function next_u64(it: *SliceIter_u64, out: *Option_u64): i32 {
  if (it.index >= it.length) {
    return option.none_u64(out);
  }
  let v: u64 = it.ptr[it.index];
  it.index = it.index + 1 as usize;
  return option.some_u64(out, v);
}

/**
 * Count of u64 values not yet taken.
 * @param it *SliceIter_u64 — iterator; not advanced
 * @return i64 — remaining count in rax. Low 64 bits match usize.
 * PLATFORM: SHARED — the installed product cannot asm-emit this usize return.
 */
export function iter_remaining_u64(it: *SliceIter_u64): i64 {
  if (it.index >= it.length) { return 0; }
  let n: usize = it.length - it.index;
  return n as i64;
}
