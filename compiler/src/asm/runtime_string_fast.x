// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// G-02f-99：+ portable memmem。
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function memcmp(a: *u8, b: *u8, n: i32): i32;
export extern "C" function memcpy(dst: *u8, src: *u8, n: i32): *u8;

/** Exported function `runtime_string_fast_x_doc_anchor`.
 * Implements `runtime_string_fast_x_doc_anchor`.
 * @return i32
 */
export function runtime_string_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-151：string fast pure helpers ---- */

// shux_string_memrchr_c: see function docblock below.
/** Exported function `shux_string_memrchr_c`.
 * Implements `shux_string_memrchr_c`.
 * @param ptr *u8
 * @param c u8
 * @param n i32
 * @return i32
 */
#[no_mangle]
export function shux_string_memrchr_c(ptr: *u8, c: u8, n: i32): i32 {
  if (ptr == 0) { return 0 - 1; }
  if (n <= 0) { return 0 - 1; }
  let i: i32 = n - 1;
  while (i >= 0) {
    if (ptr[i] == c) { return i; }
    i = i - 1;
  }
  return 0 - 1;
}

// shux_string_memchr_c: see function docblock below.
/** Exported function `shux_string_memchr_c`.
 * Implements `shux_string_memchr_c`.
 * @param ptr *u8
 * @param c u8
 * @param n i32
 * @return i32
 */
#[no_mangle]
export function shux_string_memchr_c(ptr: *u8, c: u8, n: i32): i32 {
  if (ptr == 0) { return 0 - 1; }
  if (n <= 0) { return 0 - 1; }
  let i: i32 = 0;
  while (i < n) {
    if (ptr[i] == c) { return i; }
    i = i + 1;
  }
  return 0 - 1;
}

// shux_string_portable_memmem_c: see function docblock below.
/** Exported function `shux_string_portable_memmem_c`.
 * Implements `shux_string_portable_memmem_c`.
 * @param hay *u8
 * @param hay_len i32
 * @param needle *u8
 * @param needle_len i32
 * @return i32
 */
#[no_mangle]
export function shux_string_portable_memmem_c(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32 {
  if (needle == 0) { return 0 - 1; }
  if (needle_len <= 0) { return 0; }
  if (hay == 0) { return 0 - 1; }
  if (hay_len < needle_len) { return 0 - 1; }
  if (needle_len == 1) {
    return shux_string_memchr_c(hay, needle[0], hay_len);
  }
  let i: i32 = 0;
  let lim: i32 = hay_len - needle_len;
  while (i <= lim) {
    let j: i32 = 0;
    while (j < needle_len) {
      if (hay[i + j] != needle[j]) { break; }
      j = j + 1;
    }
    if (j == needle_len) { return i; }
    i = i + 1;
  }
  return 0 - 1;
}

// shux_string_memmem_c: see function docblock below.
/** Exported function `shux_string_memmem_c`.
 * Implements `shux_string_memmem_c`.
 * @param hay *u8
 * @param hay_len i32
 * @param needle *u8
 * @param needle_len i32
 * @return i32
 */
#[no_mangle]
export function shux_string_memmem_c(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32 {
  if (needle_len <= 0) { return 0; }
  if (hay_len < needle_len) { return 0 - 1; }
  if (needle_len == 1) {
    if (needle == 0) { return 0 - 1; }
    return shux_string_memchr_c(hay, needle[0], hay_len);
  }
  return shux_string_portable_memmem_c(hay, hay_len, needle, needle_len);
}

/* See implementation. */

// shux_string_ptr_at_c: see function docblock below.
/** Exported function `shux_string_ptr_at_c`.
 * Implements `shux_string_ptr_at_c`.
 * @param ptr *u8
 * @param off i32
 * @return *u8
 */
#[no_mangle]
export function shux_string_ptr_at_c(ptr: *u8, off: i32): *u8 {
  if (ptr == 0) { return 0 as *u8; }
  return ptr + off;
}

// shux_string_memcmp_c: see function docblock below.
/** Exported function `shux_string_memcmp_c`.
 * Comparison/utility `shux_string_memcmp_c`.
 * @param a *u8
 * @param b *u8
 * @param n i32
 * @return i32
 */
#[no_mangle]
export function shux_string_memcmp_c(a: *u8, b: *u8, n: i32): i32 {
  if (n <= 0) { return 0; }
  let r: i32 = 0;
  unsafe {
    r = memcmp(a, b, n);
  }
  if (r < 0) { return 0 - 1; }
  if (r > 0) { return 1; }
  return 0;
}

// shux_string_memcmp_at_c: see function docblock below.
/** Exported function `shux_string_memcmp_at_c`.
 * Comparison/utility `shux_string_memcmp_at_c`.
 * @param a *u8
 * @param off i32
 * @param b *u8
 * @param n i32
 * @return i32
 */
#[no_mangle]
export function shux_string_memcmp_at_c(a: *u8, off: i32, b: *u8, n: i32): i32 {
  if (n <= 0) { return 0; }
  unsafe {
    return memcmp(a + off, b, n);
  }
  return 0;
}

// shux_string_copy_c: see function docblock below.
/** Exported function `shux_string_copy_c`.
 * Implements `shux_string_copy_c`.
 * @param dst *u8
 * @param src *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function shux_string_copy_c(dst: *u8, src: *u8, n: i32): void {
  if (n <= 0) { return; }
  unsafe {
    memcpy(dst, src, n);
  }
}
