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

/* note */
allow(padding) struct BytesView {
  ptr: *u8;
  length: i32;
}

/** `bytes_view`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function bytes_view(ptr: *u8, len: i32): BytesView {
  return BytesView { ptr: ptr, length: len };
}

/** `bytes_view_from_slice`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function bytes_view_from_slice(s: u8[]): BytesView {
  return BytesView { ptr: s.data, length: s.length as i32 };
}

/** `bytes_view_len`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function bytes_view_len(v: BytesView): i32 { return v.length; }

/** `bytes_view_is_empty`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function bytes_view_is_empty(v: BytesView): i32 {
  if (v.length <= 0) { return 1; }
  return 0;
}

/** `bytes_view_get`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function bytes_view_get(v: BytesView, i: i32): u8 { return v.ptr[i]; }

/**
 /* note */
 /* note */
 */
export function bytes_view_subview(v: BytesView, off: i32, len: i32): BytesView {
  if (off < 0) { off = 0; }
  if (off >= v.length || len <= 0) {
    return bytes_view(&v.ptr[off], 0);
  }
  let remain: i32 = v.length - off;
  let n: i32 = len;
  if (n > remain) { n = remain; }
  return bytes_view(&v.ptr[off], n);
}

/** `bytes_view_eq`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function bytes_view_eq(a: BytesView, b: BytesView): i32 {
  if (a.length != b.length) { return 0; }
  let i: i32 = 0;
  while (i < a.length) {
    if (a.ptr[i] != b.ptr[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** `bytes_view_eq_bytes`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function bytes_view_eq_bytes(v: BytesView, ptr: *u8, len: i32): i32 {
  if (v.length != len) { return 0; }
  let i: i32 = 0;
  while (i < v.length) {
    if (v.ptr[i] != ptr[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

// --- section ---

/**
 /* note */
 */
export function bytes_view_index_of_byte(v: BytesView, b: u8): i32 {
  let i: i32 = 0;
  while (i < v.length) {
    if (v.ptr[i] == b) { return i; }
    i = i + 1;
  }
  return -1;
}

/**
 /* note */
 /* note */
 */
export function bytes_view_index_of(v: BytesView, needle: *u8, needle_len: i32): i32 {
  if (needle_len <= 0) { return 0; }
  if (needle_len > v.length) { return -1; }
  let i: i32 = 0;
  while (i + needle_len <= v.length) {
    let j: i32 = 0;
    let ok: i32 = 1;
    while (j < needle_len) {
      if (v.ptr[i + j] != needle[j]) {
        ok = 0;
        break;
      }
      j = j + 1;
    }
    if (ok != 0) { return i; }
    i = i + 1;
  }
  return -1;
}

/** `bytes_view_contains_byte`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function bytes_view_contains_byte(v: BytesView, b: u8): i32 {
  if (bytes_view_index_of_byte(v, b) >= 0) { return 1; }
  return 0;
}

/** `bytes_view_starts_with`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function bytes_view_starts_with(v: BytesView, prefix: *u8, prefix_len: i32): i32 {
  if (prefix_len <= 0) { return 1; }
  if (prefix_len > v.length) { return 0; }
  let i: i32 = 0;
  while (i < prefix_len) {
    if (v.ptr[i] != prefix[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

