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

extern "C" function memcmp(a: *u8, b: *u8, n: usize): i32;
extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern "C" function memchr(ptr: *u8, c: i32, n: usize): *u8;

/** Exported function `shux_string_ptr_at_c`.
 * Implements `shux_string_ptr_at_c`.
 * @param ptr *u8
 * @param off i32
 * @return *u8
 */
export function shux_string_ptr_at_c(ptr: *u8, off: i32): *u8 {
  return ptr + off;
}

/** Exported function `shux_string_memcmp_c`.
 * Comparison/utility `shux_string_memcmp_c`.
 * @param a *u8
 * @param b *u8
 * @param n i32
 * @return i32
 */
export function shux_string_memcmp_c(a: *u8, b: *u8, n: i32): i32 {
  let r: i32 = 0;
  if (n <= 0) { return 0; }
  unsafe { r = memcmp(a, b, n); }
  if (r < 0) { return -1; }
  if (r > 0) { return 1; }
  return 0;
}

/** Exported function `shux_string_memcmp_at_c`.
 * Comparison/utility `shux_string_memcmp_at_c`.
 * @param a *u8
 * @param off i32
 * @param b *u8
 * @param n i32
 * @return i32
 */
export function shux_string_memcmp_at_c(a: *u8, off: i32, b: *u8, n: i32): i32 {
  let p: *u8 = 0 as *u8;
  if (n <= 0) { return 0; }
  p = a + off;
  unsafe { return memcmp(p, b, n); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `shux_string_copy_c`.
 * Implements `shux_string_copy_c`.
 * @param dst *u8
 * @param src *u8
 * @param n i32
 * @return void
 */
export function shux_string_copy_c(dst: *u8, src: *u8, n: i32): void {
  if (n <= 0) { return; }
  unsafe { memcpy(dst, src, n); }
}

/** Exported function `shux_string_memchr_c`.
 * Implements `shux_string_memchr_c`.
 * @param ptr *u8
 * @param c u8
 * @param n i32
 * @return i32
 */
export function shux_string_memchr_c(ptr: *u8, c: u8, n: i32): i32 {
  let p: *u8 = 0 as *u8;
  if (n <= 0) { return -1; }
  unsafe { p = memchr(ptr, c as i32, n); }
  if (p == 0) { return -1; }
  return (p - ptr) as i32;
}

/** Exported function `shux_string_memrchr_c`.
 * Implements `shux_string_memrchr_c`.
 * @param ptr *u8
 * @param c u8
 * @param n i32
 * @return i32
 */
export function shux_string_memrchr_c(ptr: *u8, c: u8, n: i32): i32 {
  let i: i32 = 0;
  if (n <= 0) { return -1; }
  i = n - 1;
  while (i >= 0) {
    if (ptr[i] == c) { return i; }
    i = i - 1;
  }
  return -1;
}

/** Exported function `shux_string_portable_memmem`.
 * Implements `shux_string_portable_memmem`.
 * @param hay *u8
 * @param hay_len i32
 * @param needle *u8
 * @param needle_len i32
 * @return i32
 */
export function shux_string_portable_memmem(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let ok: i32 = 0;
  if (needle_len <= 0) { return 0; }
  if (hay_len < needle_len) { return -1; }
  if (needle_len == 1) {
    return shux_string_memchr_c(hay, needle[0], hay_len);
  }
  i = 0;
  while (i <= hay_len - needle_len) {
    ok = 1;
    j = 0;
    while (j < needle_len) {
      if (hay[i + j] != needle[j]) { ok = 0; break; }
      j = j + 1;
    }
    if (ok != 0) { return i; }
    i = i + 1;
  }
  return -1;
}

/** Exported function `shux_string_memmem_c`.
 * Implements `shux_string_memmem_c`.
 * @param hay *u8
 * @param hay_len i32
 * @param needle *u8
 * @param needle_len i32
 * @return i32
 */
export function shux_string_memmem_c(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32 {
  if (needle_len <= 0) { return 0; }
  if (hay_len < needle_len) { return -1; }
  if (needle_len == 1) {
    return shux_string_memchr_c(hay, needle[0], hay_len);
  }
  return shux_string_portable_memmem(hay, hay_len, needle, needle_len);
}
