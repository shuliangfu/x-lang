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

/** `iter_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function iter_i32(s: i32[]): SliceIter_i32 {
  return SliceIter_i32 { ptr: s.data, length: s.length, index: 0 as usize };
}

/** `iter_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function iter_u8(s: u8[]): SliceIter_u8 {
  return SliceIter_u8 { ptr: s.data, length: s.length, index: 0 as usize };
}

/** `next_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function next_i32(it: *SliceIter_i32): Option_i32 {
  if (it.index >= it.length) {
    return option.none_i32();
  }
  let v: i32 = it.ptr[it.index];
  it.index = it.index + 1 as usize;
  return option.some_i32(v);
}

/** `next_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function next_u8(it: *SliceIter_u8): Option_u8 {
  if (it.index >= it.length) {
    return option.none_u8();
  }
  let v: u8 = it.ptr[it.index];
  it.index = it.index + 1 as usize;
  return option.some_u8(v);
}

/** `iter_remaining_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function iter_remaining_i32(it: *SliceIter_i32): usize {
  if (it.index >= it.length) { return 0 as usize; }
  return it.length - it.index;
}

/** `iter_remaining_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function iter_remaining_u8(it: *SliceIter_u8): usize {
  if (it.index >= it.length) { return 0 as usize; }
  return it.length - it.index;
}

/* note */
export struct SliceIter_u64 {
  ptr: *u64;
  length: usize;
  index: usize;
}

/** `iterator_protocol_version`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function iterator_protocol_version(): i32 { return 1; }

/** `iter_u64_from_buf`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function iter_u64_from_buf(ptr: *u64, len: usize): SliceIter_u64 {
  return SliceIter_u64 { ptr: ptr, length: len, index: 0 as usize };
}

/** `next_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function next_u64(it: *SliceIter_u64): Option_u64 {
  if (it.index >= it.length) {
    return option.none_u64();
  }
  let v: u64 = it.ptr[it.index];
  it.index = it.index + 1 as usize;
  return option.some_u64(v);
}

/** `iter_remaining_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function iter_remaining_u64(it: *SliceIter_u64): usize {
  if (it.index >= it.length) { return 0 as usize; }
  return it.length - it.index;
}

