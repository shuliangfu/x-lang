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
// const[] u8 + std.mem）
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// string_copy_to。
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
const heap_libc = import("std.heap.libc");
/** Exported function `string_long_threshold`.
 * Implements `string_long_threshold`.
 * @return i32
 */
export function string_long_threshold(): i32 { return 32; }
/** Exported function `string_copy_threshold`.
 * Implements `string_copy_threshold`.
 * @return i32
 */
export function string_copy_threshold(): i32 { return 8; }
extern function shux_string_memcmp_c(a: *u8, b: *u8, n: i32): i32;
extern function shux_string_memmem_c(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32;
extern function shux_string_copy_c(dst: *u8, src: *u8, n: i32): void;
extern function shux_string_memchr_c(ptr: *u8, c: u8, n: i32): i32;
extern function shux_string_memrchr_c(ptr: *u8, c: u8, n: i32): i32;
extern function shux_string_memcmp_at_c(a: *u8, off: i32, b: *u8, n: i32): i32;
/* See implementation. */
extern function shux_string_ptr_at_c(ptr: *u8, off: i32): *u8;
/** Exported function `string_memcmp_c`.
 * Comparison/utility `string_memcmp_c`.
 * @param a *u8
 * @param b *u8
 * @param n i32
 * @return i32
 */
export function string_memcmp_c(a: *u8, b: *u8, n: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = shux_string_memcmp_c(a, b, n); }
  return rc;
}
/** Exported function `string_memmem_c`.
 * Implements `string_memmem_c`.
 * @param hay *u8
 * @param hay_len i32
 * @param needle *u8
 * @param needle_len i32
 * @return i32
 */
export function string_memmem_c(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = shux_string_memmem_c(hay, hay_len, needle, needle_len); }
  return rc;
}
/** Exported function `string_copy_c`.
 * Implements `string_copy_c`.
 * @param dst *u8
 * @param src *u8
 * @param n i32
 * @return void
 */
export function string_copy_c(dst: *u8, src: *u8, n: i32): void {
  unsafe { shux_string_copy_c(dst, src, n); }
}
/** Exported function `string_memchr_c`.
 * Implements `string_memchr_c`.
 * @param ptr *u8
 * @param c u8
 * @param n i32
 * @return i32
 */
export function string_memchr_c(ptr: *u8, c: u8, n: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = shux_string_memchr_c(ptr, c, n); }
  return rc;
}
/** Exported function `string_memcmp_at_c`.
 * Comparison/utility `string_memcmp_at_c`.
 * @param a *u8
 * @param off i32
 * @param b *u8
 * @param n i32
 * @return i32
 */
export function string_memcmp_at_c(a: *u8, off: i32, b: *u8, n: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = shux_string_memcmp_at_c(a, off, b, n); }
  return rc;
}
/** Exported function `string_ptr_at_c`.
 * Implements `string_ptr_at_c`.
 * @param ptr *u8
 * @param off i32
 * @return *u8
 */
export function string_ptr_at_c(ptr: *u8, off: i32): *u8 {
  let p: *u8 = 0 as *u8;
  unsafe { p = shux_string_ptr_at_c(ptr, off); }
  return p;
}
/** Exported function `string_capacity`.
 * Implements `string_capacity`.
 * @return i32
 */
export function string_capacity(): i32 { return 256; }
export struct String {
  data: u8[256];
  len: i32;
}
/** See implementation for details. */
allow(padding) struct StrView {
  ptr: *u8;
  len: i32;
}
/** Exported function `string_empty`.
 * Implements `string_empty`.
 * @return i32
 */
export function string_empty(): i32 { return 0; }
// See implementation.
/** Exported function `view`.
 * Implements `view`.
 * @param ptr *u8
 * @param len i32
 * @return StrView
 */
export function view(ptr: *u8, len: i32): StrView {
  return StrView { ptr: ptr, len: len };
}
/** Exported function `len`.
 * Implements `len`.
 * @param v StrView
 * @return i32
 */
export function len(v: StrView): i32 { return v.len; }
/** Exported function `is_empty`.
 * Query helper `is_empty`.
 * @param v StrView
 * @return i32
 */
export function is_empty(v: StrView): i32 {
  if (v.len <= 0) { return 1; }
  return 0;
}

/** Exported function `string_view_case_fold`.
 * Implements `string_view_case_fold`.
 * @param v StrView
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function string_view_case_fold(v: StrView, out: *u8, out_cap: i32): i32 {
  let i: i32 = 0;
  while (i < v.len) {
    if (i >= out_cap) { return -1; }
    let c: u8 = v.ptr[i];
    if (c >= 65 && c <= 90) { c = (c + 32) as u8; }
    out[i] = c;
    i = i + 1;
  }
  return i;
}

/** Exported function `string_view_is_valid_utf8`.
 * Implements `string_view_is_valid_utf8`.
 * @param v StrView
 * @return i32
 */
export function string_view_is_valid_utf8(v: StrView): i32 {
  let i: i32 = 0;
  while (i < v.len) {
    let c: u8 = v.ptr[i];
    if (c <= 127) {
      i = i + 1;
    } else {
      return 0;
    }
  }
  return 1;
}
/** Exported function `string_view_get`.
 * Implements `string_view_get`.
 * @param v StrView
 * @param i i32
 * @return u8
 */
export function string_view_get(v: StrView, i: i32): u8 { return v.ptr[i]; }
/**
 * See implementation.
 * See implementation.
 */
export function string_view_subview(v: StrView, off: i32, len: i32): StrView {
  if (off < 0) { off = 0; }
  if (off >= v.len || len <= 0) {
    return view(string_ptr_at_c(v.ptr, off), 0);
  }
  let remain: i32 = v.len - off;
  let n: i32 = len;
  if (n > remain) { n = remain; }
  return view(string_ptr_at_c(v.ptr, off), n);
}
/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function string_view_concat_arena(arena: *heap_libc.LibcArena64, left: StrView, right: StrView): StrView {
  let n: i32 = left.len + right.len;
  if (n <= 0) {
    return view(left.ptr, 0);
  }
  // See implementation.
  // See implementation.
  let p: *u8 = heap_libc.heap_arena64_alloc_c(arena, n as usize, 1 as usize);
  if (p == 0) {
    return view(0 as *u8, 0);
  }
  if (left.len > 0) {
    string_copy_c(p, left.ptr, left.len);
  }
  if (right.len > 0) {
    let dst2: *u8 = string_ptr_at_c(p, left.len);
    string_copy_c(dst2, right.ptr, right.len);
  }
  return view(p, n);
}
/** Exported function `string_view_eq`.
 * Implements `string_view_eq`.
 * @param a StrView
 * @param b StrView
 * @return i32
 */
export function string_view_eq(a: StrView, b: StrView): i32 {
  if (a.len != b.len) { return 0; }
  if (a.len == 1) { if (a.ptr[0] != b.ptr[0]) { return 0; } return 1; }
  if (a.len == 2) { if (a.ptr[0] != b.ptr[0] || a.ptr[1] != b.ptr[1]) { return 0; } return 1; }
  if (a.len == 3) { if (a.ptr[0] != b.ptr[0] || a.ptr[1] != b.ptr[1] || a.ptr[2] != b.ptr[2]) {
      return 0; } return 1; }
  if (a.len == 4) { if (a.ptr[0] != b.ptr[0] || a.ptr[1] != b.ptr[1] || a.ptr[2] != b.ptr[2] ||
    a.ptr[3] != b.ptr[3]) { return 0; } return 1; }
  if (a.len >= 32) {
    if (string_memcmp_c(a.ptr, b.ptr, a.len) == 0) { return 1; }
    return 0;
  }
  let i: i32 = 0;
  while (i + 3 < a.len) {
    if (a.ptr[i] != b.ptr[i] || a.ptr[i + 1] != b.ptr[i + 1] || a.ptr[i + 2] != b.ptr[i + 2] ||
    a.ptr[i + 3] != b.ptr[i + 3]) { return 0; }
    i = i + 4;
  }
  while (i < a.len) {
    if (a.ptr[i] != b.ptr[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}
/** Exported function `string_view_eq_slice`.
 * Implements `string_view_eq_slice`.
 * @param v StrView
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function string_view_eq_slice(v: StrView, ptr: *u8, len: i32): i32 {
  if (v.len != len) { return 0; }
  if (v.len == 1) { if (v.ptr[0] != ptr[0]) { return 0; } return 1; }
  if (v.len == 2) { if (v.ptr[0] != ptr[0] || v.ptr[1] != ptr[1]) { return 0; } return 1; }
  if (v.len == 3) { if (v.ptr[0] != ptr[0] || v.ptr[1] != ptr[1] || v.ptr[2] != ptr[2]) { return 0;
    } return 1; }
  if (v.len == 4) { if (v.ptr[0] != ptr[0] || v.ptr[1] != ptr[1] || v.ptr[2] != ptr[2] || v.ptr[3]
    != ptr[3]) { return 0; } return 1; }
  if (v.len >= 32) {
    if (string_memcmp_c(v.ptr, ptr, v.len) == 0) { return 1; }
    return 0;
  }
  let i: i32 = 0;
  while (i + 3 < v.len) {
    if (v.ptr[i] != ptr[i] || v.ptr[i + 1] != ptr[i + 1] || v.ptr[i + 2] != ptr[i + 2] || v.ptr[i +
    3] != ptr[i + 3]) { return 0; }
    i = i + 4;
  }
  while (i < v.len) {
    if (v.ptr[i] != ptr[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}
/** Exported function `string_view_compare`.
 * Implements `string_view_compare`.
 * @param a StrView
 * @param b StrView
 * @return i32
 */
export function string_view_compare(a: StrView, b: StrView): i32 {
  let n: i32 = a.len;
  if (b.len < n) { n = b.len; }
  if (n >= 32) {
    let r: i32 = string_memcmp_c(a.ptr, b.ptr, n);
    if (r != 0) { return r; }
  } else {
    let i: i32 = 0;
    while (i + 3 < n) {
      if (a.ptr[i] != b.ptr[i]) { if (a.ptr[i] < b.ptr[i]) { return -1; } return 1; }
      if (a.ptr[i + 1] != b.ptr[i + 1]) { if (a.ptr[i + 1] < b.ptr[i + 1]) { return -1; } return 1;
      }
      if (a.ptr[i + 2] != b.ptr[i + 2]) { if (a.ptr[i + 2] < b.ptr[i + 2]) { return -1; } return 1;
      }
      if (a.ptr[i + 3] != b.ptr[i + 3]) { if (a.ptr[i + 3] < b.ptr[i + 3]) { return -1; } return 1;
      }
      i = i + 4;
    }
    while (i < n) {
      if (a.ptr[i] != b.ptr[i]) { if (a.ptr[i] < b.ptr[i]) { return -1; } return 1; }
      i = i + 1;
    }
  }
  if (a.len < b.len) { return -1; }
  if (a.len > b.len) { return 1; }
  return 0;
}
/** Exported function `string_view_find_char`.
 * Implements `string_view_find_char`.
 * @param v StrView
 * @param c u8
 * @return i32
 */
export function string_view_find_char(v: StrView, c: u8): i32 {
  return string_memchr_c(v.ptr, c, v.len);
}
/** Exported function `string_view_starts_with`.
 * Implements `string_view_starts_with`.
 * @param v StrView
 * @param prefix *u8
 * @param prefix_len i32
 * @return i32
 */
export function string_view_starts_with(v: StrView, prefix: *u8, prefix_len: i32): i32 {
  if (prefix_len <= 0) { return 1; }
  if (v.len < prefix_len) { return 0; }
  if (prefix_len >= 8) {
    if (string_memcmp_c(v.ptr, prefix, prefix_len) == 0) { return 1; }
    return 0;
  }
  let i: i32 = 0;
  while (i < prefix_len) {
    if (v.ptr[i] != prefix[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}
/** Exported function `string_view_ends_with`.
 * Implements `string_view_ends_with`.
 * @param v StrView
 * @param suffix *u8
 * @param suffix_len i32
 * @return i32
 */
export function string_view_ends_with(v: StrView, suffix: *u8, suffix_len: i32): i32 {
  if (suffix_len <= 0) { return 1; }
  if (v.len < suffix_len) { return 0; }
  let off: i32 = v.len - suffix_len;
  if (string_memcmp_at_c(v.ptr, off, suffix, suffix_len) == 0) { return 1; }
  return 0;
}
/** Exported function `string_view_find_slice_scan`.
 * Implements `string_view_find_slice_scan`.
 * @param v StrView
 * @param sub *u8
 * @param sub_len i32
 * @param start i32
 * @param end i32
 * @return i32
 */
export function string_view_find_slice_scan(v: StrView, sub: *u8, sub_len: i32, start: i32, end: i32): i32 {
  if (start > end) { return 0 - 1; }
  if (string_memcmp_at_c(v.ptr, start, sub, sub_len) == 0) { return start; }
  if (start + 1 <= end && string_memcmp_at_c(v.ptr, start + 1, sub, sub_len) == 0) {
    return start + 1; }
  if (start + 2 <= end && string_memcmp_at_c(v.ptr, start + 2, sub, sub_len) == 0) {
    return start + 2; }
  if (start + 3 <= end && string_memcmp_at_c(v.ptr, start + 3, sub, sub_len) == 0) {
    return start + 3; }
  return string_view_find_slice_scan(v, sub, sub_len, start + 4, end);
}
/** Exported function `string_view_find_slice`.
 * Implements `string_view_find_slice`.
 * @param v StrView
 * @param sub *u8
 * @param sub_len i32
 * @return i32
 */
export function string_view_find_slice(v: StrView, sub: *u8, sub_len: i32): i32 {
  if (sub_len <= 0) { return 0; }
  if (v.len < sub_len) { return 0 - 1; }
  if (sub_len == 1) {
    return string_memchr_c(v.ptr, sub[0], v.len);
  }
  if (v.len >= 32 || sub_len >= 8) {
    return string_memmem_c(v.ptr, v.len, sub, sub_len);
  }
  let end: i32 = v.len - sub_len;
  return string_view_find_slice_scan(v, sub, sub_len, 0, end);
}
/** Exported function `string_view_contains`.
 * Implements `string_view_contains`.
 * @param v StrView
 * @param sub *u8
 * @param sub_len i32
 * @return i32
 */
export function string_view_contains(v: StrView, sub: *u8, sub_len: i32): i32 {
  if (string_view_find_slice(v, sub, sub_len) >= 0) { return 1; }
  return 0;
}
/** Exported function `string_eq_view`.
 * Implements `string_eq_view`.
 * @param s String
 * @param v StrView
 * @return i32
 */
export function string_eq_view(s: String, v: StrView): i32 {
  if (s.len != v.len) { return 0; }
  if (s.len >= 32) {
    if (string_memcmp_c(&s.data[0], v.ptr, s.len) == 0) { return 1; }
    return 0;
  }
  let i: i32 = 0;
  while (i + 3 < s.len) {
    if (s.data[i] != v.ptr[i] || s.data[i + 1] != v.ptr[i + 1] || s.data[i + 2] != v.ptr[i + 2] ||
    s.data[i + 3] != v.ptr[i + 3]) { return 0; }
    i = i + 4;
  }
  while (i < s.len) {
    if (s.data[i] != v.ptr[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}
/** Exported function `string_compare_view`.
 * Implements `string_compare_view`.
 * @param s String
 * @param v StrView
 * @return i32
 */
export function string_compare_view(s: String, v: StrView): i32 {
  let n: i32 = s.len;
  if (v.len < n) { n = v.len; }
  if (n >= 32) {
    let r: i32 = string_memcmp_c(&s.data[0], v.ptr, n);
    if (r != 0) { return r; }
  } else {
    let i: i32 = 0;
    while (i + 3 < n) {
      if (s.data[i] != v.ptr[i]) { if (s.data[i] < v.ptr[i]) { return -1; } return 1; }
      if (s.data[i + 1] != v.ptr[i + 1]) { if (s.data[i + 1] < v.ptr[i + 1]) { return -1; } return
        1; }
      if (s.data[i + 2] != v.ptr[i + 2]) { if (s.data[i + 2] < v.ptr[i + 2]) { return -1; } return
        1; }
      if (s.data[i + 3] != v.ptr[i + 3]) { if (s.data[i + 3] < v.ptr[i + 3]) { return -1; } return
        1; }
      i = i + 4;
    }
    while (i < n) {
      if (s.data[i] != v.ptr[i]) { if (s.data[i] < v.ptr[i]) { return -1; } return 1; }
      i = i + 1;
    }
  }
  if (s.len < v.len) { return -1; }
  if (s.len > v.len) { return 1; }
  return 0;
}
// See implementation.
/** Exported function `stack_str_capacity`.
 * Implements `stack_str_capacity`.
 * @return i32
 */
export function stack_str_capacity(): i32 { return 32; }
/* See implementation. */
export struct StackStr {
  data: u8[32];
  len: i32;
}
/** Exported function `stack_str_new`.
 * Implements `stack_str_new`.
 * @return StackStr
 */
export function stack_str_new(): StackStr {
  return StackStr { data: [], len: 0 };
}
/** Exported function `stack_str_len`.
 * Query helper `stack_str_len`.
 * @param s *StackStr
 * @return i32
 */
export function stack_str_len(s: *StackStr): i32 { return s.len; }
/** Exported function `stack_str_view`.
 * Implements `stack_str_view`.
 * @param s *StackStr
 * @return StrView
 */
export function stack_str_view(s: *StackStr): StrView {
  return view(&s.data[0], s.len);
}
/**
 * See implementation.
 * See implementation.
 */
export function stack_str_from_slice(s: *StackStr, ptr: *u8, len: i32): i32 {
  let cap: i32 = stack_str_capacity();
  if (len > cap) { return -1; }
  if (len <= 0) {
    s.len = 0;
    return 0;
  }
  if (len >= 8) {
    string_copy_c(&s.data[0], ptr, len);
  } else {
    let i: i32 = 0;
    while (i < len) {
      s.data[i] = ptr[i];
      i = i + 1;
    }
  }
  s.len = len;
  return 0;
}
/** Exported function `stack_str_append_char`.
 * Implements `stack_str_append_char`.
 * @param s *StackStr
 * @param c u8
 * @return i32
 */
export function stack_str_append_char(s: *StackStr, c: u8): i32 {
  let cap: i32 = stack_str_capacity();
  if (s.len >= cap) { return -1; }
  s.data[s.len] = c;
  s.len = s.len + 1;
  return 0;
}
// See implementation.
/** Exported function `new`.
 * Implements `new`.
 * @return String
 */
export function new(): String {
  return String {
    data: [],
    len: 0
  }
}
/** Exported function `len`.
 * Implements `len`.
 * @param s String
 * @return i32
 */
export function len(s: String): i32 { return s.len; }
/** Exported function `string_len_ptr`.
 * Implements `string_len_ptr`.
 * @param s *String
 * @return i32
 */
export function string_len_ptr(s: *String): i32 { return s.len; }
/** Exported function `is_empty`.
 * Query helper `is_empty`.
 * @param s String
 * @return i32
 */
export function is_empty(s: String): i32 {
  if (s.len <= 0) { return 1; }
  return 0;
}
/** Exported function `string_is_empty_ptr`.
 * Implements `string_is_empty_ptr`.
 * @param s *String
 * @return i32
 */
export function string_is_empty_ptr(s: *String): i32 {
  if (s.len <= 0) { return 1; }
  return 0;
}
/** Exported function `string_from_char`.
 * Implements `string_from_char`.
 * @param c u8
 * @return String
 */
export function string_from_char(c: u8): String {
  let s: String = new();
  let _discard: i32 = string_append_char(&s, c);
  return s;
}
/** Exported function `string_from_slice`.
 * Implements `string_from_slice`.
 * @param ptr *u8
 * @param len i32
 * @return String
 */
export function string_from_slice(ptr: *u8, len: i32): String {
  let s: String = new();
  let n: i32 = len;
  if (n > 256) { n = 256; }
  if (n > 0) {
    string_copy_c(&s.data[0], ptr, n);
  }
  s.len = n;
  return s;
}
/** Exported function `string_get`.
 * Implements `string_get`.
 * @param s String
 * @param i i32
 * @return u8
 */
export function string_get(s: String, i: i32): u8 { return s.data[i]; }
/** Exported function `string_eq`.
 * Implements `string_eq`.
 * @param a String
 * @param b String
 * @return i32
 */
export function string_eq(a: String, b: String): i32 {
  if (a.len != b.len) { return 0; }
  if (a.len == 1) { if (a.data[0] != b.data[0]) { return 0; } return 1; }
  if (a.len == 2) { if (a.data[0] != b.data[0] || a.data[1] != b.data[1]) { return 0; } return 1; }
  if (a.len == 3) { if (a.data[0] != b.data[0] || a.data[1] != b.data[1] || a.data[2] != b.data[2])
    { return 0; } return 1; }
  if (a.len == 4) { if (a.data[0] != b.data[0] || a.data[1] != b.data[1] || a.data[2] != b.data[2]
    || a.data[3] != b.data[3]) { return 0; } return 1; }
  if (a.len >= 32) {
    if (string_memcmp_c(&a.data[0], &b.data[0], a.len) == 0) { return 1; }
    return 0;
  }
  let i: i32 = 0;
  while (i + 3 < a.len) {
    if (a.data[i] != b.data[i] || a.data[i + 1] != b.data[i + 1] || a.data[i + 2] != b.data[i + 2]
    || a.data[i + 3] != b.data[i + 3]) { return 0; }
    i = i + 4;
  }
  while (i < a.len) {
    if (a.data[i] != b.data[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}
/** Exported function `string_eq_ptr`.
 * Implements `string_eq_ptr`.
 * @param a *String
 * @param b *String
 * @return i32
 */
export function string_eq_ptr(a: *String, b: *String): i32 {
  if (a.len != b.len) { return 0; }
  if (a.len == 1) { if (a.data[0] != b.data[0]) { return 0; } return 1; }
  if (a.len == 2) { if (a.data[0] != b.data[0] || a.data[1] != b.data[1]) { return 0; } return 1; }
  if (a.len == 3) { if (a.data[0] != b.data[0] || a.data[1] != b.data[1] || a.data[2] != b.data[2])
    { return 0; } return 1; }
  if (a.len == 4) { if (a.data[0] != b.data[0] || a.data[1] != b.data[1] || a.data[2] != b.data[2]
    || a.data[3] != b.data[3]) { return 0; } return 1; }
  if (a.len >= 32) {
    if (string_memcmp_c(&a.data[0], &b.data[0], a.len) == 0) { return 1; }
    return 0;
  }
  let i: i32 = 0;
  while (i + 3 < a.len) {
    if (a.data[i] != b.data[i] || a.data[i + 1] != b.data[i + 1] || a.data[i + 2] != b.data[i + 2]
    || a.data[i + 3] != b.data[i + 3]) { return 0; }
    i = i + 4;
  }
  while (i < a.len) {
    if (a.data[i] != b.data[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}
/** Exported function `string_compare`.
 * Implements `string_compare`.
 * @param a String
 * @param b String
 * @return i32
 */
export function string_compare(a: String, b: String): i32 {
  let n: i32 = a.len;
  if (b.len < n) { n = b.len; }
  /* See implementation. */
  if (n >= 1 && string_memcmp_c(&a.data[0], &b.data[0], n) < 0) { return -1; }
  if (n >= 1 && string_memcmp_c(&a.data[0], &b.data[0], n) > 0) { return 1; }
  if (a.len < b.len) { return -1; }
  if (a.len > b.len) { return 1; }
  return 0;
}
/** Exported function `string_compare_ptr`.
 * Implements `string_compare_ptr`.
 * @param a *String
 * @param b *String
 * @return i32
 */
export function string_compare_ptr(a: *String, b: *String): i32 {
  let n: i32 = a.len;
  if (b.len < n) { n = b.len; }
  if (n >= 1 && string_memcmp_c(&a.data[0], &b.data[0], n) < 0) { return -1; }
  if (n >= 1 && string_memcmp_c(&a.data[0], &b.data[0], n) > 0) { return 1; }
  if (a.len < b.len) { return -1; }
  if (a.len > b.len) { return 1; }
  return 0;
}
/** Exported function `string_clear`.
 * Implements `string_clear`.
 * @param s *String
 * @return i32
 */
export function string_clear(s: *String): i32 {
  s.len = 0;
  return 0;
}
/** Exported function `string_append_char`.
 * Implements `string_append_char`.
 * @param s *String
 * @param c u8
 * @return i32
 */
export function string_append_char(s: *String, c: u8): i32 {
  if (s.len >= 256) { return -1; }
  s.data[s.len] = c;
  s.len = s.len + 1;
  return 0;
}
/** Exported function `string_append_slice`.
 * Implements `string_append_slice`.
 * @param s *String
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function string_append_slice(s: *String, ptr: *u8, len: i32): i32 {
  let cap: i32 = 256;
  let remain: i32 = cap - s.len;
  if (remain <= 0) { return -1; }
  if (len > remain) { return -1; }
  let base: i32 = s.len;
  let new_len: i32 = base + len;
  if (len > 0) {
    string_copy_c(&s.data[base], ptr, len);
  }
  s.len = new_len;
  return 0;
}
/** Exported function `string_data_ptr`.
 * Implements `string_data_ptr`.
 * @param s *String
 * @return *u8
 */
export function string_data_ptr(s: *String): *u8 {
  return &s.data[0];
}
/**
 * See implementation.
 * See implementation.
 */
export function string_view_from_string(s: *String): StrView {
  return view(string_data_ptr(s), s.len);
}
/** Exported function `string_copy_to`.
 * Implements `string_copy_to`.
 * @param s String
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function string_copy_to(s: String, out: *u8, out_max: i32): i32 {
  if (s.len > out_max) { return -1; }
  /* See implementation. */
  if (s.len >= 4) {
    string_copy_c(out, &s.data[0], s.len);
  } else {
    if (s.len > 0) { out[0] = s.data[0]; }
    if (s.len > 1) { out[1] = s.data[1]; }
    if (s.len > 2) { out[2] = s.data[2]; }
  }
  return s.len;
}
/** Exported function `string_copy_to_ptr`.
 * Implements `string_copy_to_ptr`.
 * @param s *String
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function string_copy_to_ptr(s: *String, out: *u8, out_max: i32): i32 {
  if (s.len > out_max) { return -1; }
  if (s.len >= 4) {
    string_copy_c(out, &s.data[0], s.len);
  } else {
    if (s.len > 0) { out[0] = s.data[0]; }
    if (s.len > 1) { out[1] = s.data[1]; }
    if (s.len > 2) { out[2] = s.data[2]; }
  }
  return s.len;
}
/* See implementation. */
/** Exported function `string_find_char`.
 * Implements `string_find_char`.
 * @param s String
 * @param c u8
 * @return i32
 */
export function string_find_char(s: String, c: u8): i32 {
  return string_memchr_c(&s.data[0], c, s.len);
}
/** Exported function `string_starts_with`.
 * Implements `string_starts_with`.
 * @param s String
 * @param prefix *u8
 * @param prefix_len i32
 * @return i32
 */
export function string_starts_with(s: String, prefix: *u8, prefix_len: i32): i32 {
  if (prefix_len <= 0) { return 1; }
  if (s.len < prefix_len) { return 0; }
  if (string_memcmp_c(&s.data[0], prefix, prefix_len) == 0) { return 1; }
  return 0;
}
/** Exported function `string_ends_with`.
 * Implements `string_ends_with`.
 * @param s String
 * @param suffix *u8
 * @param suffix_len i32
 * @return i32
 */
export function string_ends_with(s: String, suffix: *u8, suffix_len: i32): i32 {
  if (suffix_len <= 0) { return 1; }
  if (s.len < suffix_len) { return 0; }
  let off: i32 = s.len - suffix_len;
  if (string_memcmp_at_c(&s.data[0], off, suffix, suffix_len) == 0) { return 1; }
  return 0;
}
/** Exported function `string_contains`.
 * Implements `string_contains`.
 * @param s String
 * @param sub *u8
 * @param sub_len i32
 * @return i32
 */
export function string_contains(s: String, sub: *u8, sub_len: i32): i32 {
  if (string_find_slice(s, sub, sub_len) >= 0) { return 1; }
  return 0;
}
/** Exported function `string_find_slice_scan`.
 * Implements `string_find_slice_scan`.
 * @param s *String
 * @param sub *u8
 * @param sub_len i32
 * @param start i32
 * @param end i32
 * @return i32
 */
export function string_find_slice_scan(s: *String, sub: *u8, sub_len: i32, start: i32, end: i32): i32 {
  if (start > end) { return 0 - 1; }
  if (string_memcmp_at_c(&s.data[0], start, sub, sub_len) == 0) { return start; }
  if (start + 1 <= end && string_memcmp_at_c(&s.data[0], start + 1, sub, sub_len) == 0) {
    return start + 1; }
  if (start + 2 <= end && string_memcmp_at_c(&s.data[0], start + 2, sub, sub_len) == 0) {
    return start + 2; }
  if (start + 3 <= end && string_memcmp_at_c(&s.data[0], start + 3, sub, sub_len) == 0) {
    return start + 3; }
  return string_find_slice_scan(s, sub, sub_len, start + 4, end);
}
/** Exported function `string_find_slice`.
 * Implements `string_find_slice`.
 * @param s String
 * @param sub *u8
 * @param sub_len i32
 * @return i32
 */
export function string_find_slice(s: String, sub: *u8, sub_len: i32): i32 {
  if (sub_len <= 0) { return 0; }
  if (s.len < sub_len) { return 0 - 1; }
  if (sub_len == 1) {
    return string_memchr_c(&s.data[0], sub[0], s.len);
  }
  if (s.len >= 32 || sub_len >= 8) {
    return string_memmem_c(&s.data[0], s.len, sub, sub_len);
  }
  let end: i32 = s.len - sub_len;
  return string_find_slice_scan(&s, sub, sub_len, 0, end);
}
/** Exported function `string_rfind_char_scan`.
 * Implements `string_rfind_char_scan`.
 * @param s *String
 * @param c u8
 * @param pos i32
 * @return i32
 */
export function string_rfind_char_scan(s: *String, c: u8, pos: i32): i32 {
  if (pos < 0) { return 0 - 1; }
  if (s.data[pos] == c) { return pos; }
  return string_rfind_char_scan(s, c, pos - 1);
}
/** Exported function `string_rfind_char`.
 * Implements `string_rfind_char`.
 * @param s String
 * @param c u8
 * @return i32
 */
export function string_rfind_char(s: String, c: u8): i32 {
  if (s.len <= 0) { return 0 - 1; }
  return string_rfind_char_scan(&s, c, s.len - 1);
}
/** Exported function `string_trim_skip_start`.
 * Implements `string_trim_skip_start`.
 * @param s *String
 * @param i i32
 * @return i32
 */
export function string_trim_skip_start(s: *String, i: i32): i32 {
  if (i >= s.len) { return i; }
  if (s.data[i] != 32 && s.data[i] != 9) { return i; }
  return string_trim_skip_start(s, i + 1);
}
/** Exported function `string_trim_skip_end`.
 * Implements `string_trim_skip_end`.
 * @param s *String
 * @param start i32
 * @param i i32
 * @return i32
 */
export function string_trim_skip_end(s: *String, start: i32, i: i32): i32 {
  if (i < start) { return start - 1; }
  if (s.data[i] != 32 && s.data[i] != 9) { return i; }
  return string_trim_skip_end(s, start, i - 1);
}
/** Exported function `trim`.
 * Implements `trim`.
 * @param s String
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function trim(s: String, out: *u8, out_max: i32): i32 {
  if (s.len <= 0 || out_max <= 0) { return 0; }
  let start: i32 = string_trim_skip_start(&s, 0);
  let end: i32 = string_trim_skip_end(&s, start, s.len - 1);
  let n: i32 = end - start + 1;
  if (n <= 0) { return 0; }
  if (n > out_max) { return -1; }
  if (n > 0) {
    string_copy_c(out, &s.data[start], n);
  }
  return n;
}
/** Exported function `string_replace_char_scan`.
 * Implements `string_replace_char_scan`.
 * @param s *String
 * @param from u8
 * @param to u8
 * @param i i32
 * @param count i32
 * @return i32
 */
export function string_replace_char_scan(s: *String, from: u8, to: u8, i: i32, count: i32): i32 {
  if (i >= s.len) { return count; }
  if (s.data[i] == from) {
    s.data[i] = to;
    count = count + 1;
  }
  return string_replace_char_scan(s, from, to, i + 1, count);
}
/** Exported function `replace`.
 * Implements `replace`.
 * @param s *String
 * @param from u8
 * @param to u8
 * @return i32
 */
export function replace(s: *String, from: u8, to: u8): i32 {
  return string_replace_char_scan(s, from, to, 0, 0);
}
/** Exported function `string_module_anchor`.
 * Implements `string_module_anchor`.
 * @return i32
 */
export function string_module_anchor(): i32 { return 0; }
