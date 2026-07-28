// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_string_fast.x — R2 full wave515
//
// Portable string/memory helper routines for the compiler codegen path.
// Provides 8 public `xlang_string_*_c` functions used by std/string/string.x
// via the bare ABI layer (no -lib-name prefix, symbols must be emitted as-is).
//
// All functions are pure computation or wrap standard C library memcmp/memcpy
// via extern "C" bridges. No OS glue required — this is a DIRECT-mode R2
// migration (no thin+rest ld -r; the .x compiles standalone).
//
// PLATFORM: SHARED
//
// Wave515 (2026-07-27): R2 full migration. Previously the shell script
// xlang_compile_std_string_o.sh always compiled the C seed directly. Now in
// R2 mode (XLANG_G05_PREFER_X_O=1) the .x file is compiled via xlang-c -E
// → bare ABI .o. The C seed remains as cold-mode fallback.

/* === Standard C library bridges (implemented in system libc) === */

export extern "C" function memcmp(a: *u8, b: *u8, n: i32): i32;
export extern "C" function memcpy(dst: *u8, src: *u8, n: i32): *u8;

/**
 * Read-path helper for codegen discovery; returns 0.
 * @return i32
 */
export function runtime_string_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-151: portable string fast pure helpers ---- */

/**
 * Reverse byte search: find last occurrence of byte `c` in `ptr[0..n-1]`.
 * Linear scan from index n-1 down to 0.
 * @param ptr buffer pointer (may be NULL if n <= 0)
 * @param c byte value to search
 * @param n number of bytes to scan (≥0)
 * @return index [0..n-1] if found; -1 (0xFFFFFFFF) if not found or invalid input
 */
#[no_mangle]
export function xlang_string_memrchr_c(ptr: *u8, c: u8, n: i32): i32 {
  if (ptr == 0) { return 0 - 1; }
  if (n <= 0) { return 0 - 1; }
  let i: i32 = n - 1;
  while (i >= 0) {
    if (ptr[i] == c) { return i; }
    i = i - 1;
  }
  return 0 - 1;
}

/**
 * Forward byte search: find first occurrence of byte `c` in `ptr[0..n-1]`.
 * Linear scan from index 0 to n-1.
 * @param ptr buffer pointer (may be NULL if n <= 0)
 * @param c byte value to search
 * @param n number of bytes to scan (≥0)
 * @return index [0..n-1] if found; -1 (0xFFFFFFFF) if not found or invalid input
 */
#[no_mangle]
export function xlang_string_memchr_c(ptr: *u8, c: u8, n: i32): i32 {
  if (ptr == 0) { return 0 - 1; }
  if (n <= 0) { return 0 - 1; }
  let i: i32 = 0;
  while (i < n) {
    if (ptr[i] == c) { return i; }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Portable substring search: naive O(n*m) needle matching in haystack.
 * Used as fallback when platform memmem is unavailable or when the
 * search must be vectorized / instrumented. Calls xlang_string_memchr_c
 * for single-byte needles.
 * @param hay haystack buffer pointer
 * @param hay_len haystack byte count (≥0)
 * @param needle needle buffer pointer (may be NULL if needle_len <= 0)
 * @param needle_len needle byte count (≥0)
 * @return starting index [0..hay_len-needle_len] if found;
 *         -1 if not found or invalid input; 0 if needle_len == 0
 */
#[no_mangle]
export function xlang_string_portable_memmem_c(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32 {
  if (needle == 0) { return 0 - 1; }
  if (needle_len <= 0) { return 0; }
  if (hay == 0) { return 0 - 1; }
  if (hay_len < needle_len) { return 0 - 1; }
  if (needle_len == 1) {
    return xlang_string_memchr_c(hay, needle[0], hay_len);
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

/**
 * Substring search: find `needle` in `haystack`.
 * Single-byte needles dispatch to xlang_string_memchr_c; multi-byte
 * needles dispatch to xlang_string_portable_memmem_c (naive O(n*m)).
 * @param hay haystack buffer pointer
 * @param hay_len haystack byte count
 * @param needle needle buffer pointer
 * @param needle_len needle byte count
 * @return starting index [0..hay_len-needle_len] if found;
 *         -1 if not found; 0 if needle_len <= 0
 */
#[no_mangle]
export function xlang_string_memmem_c(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32 {
  if (needle_len <= 0) { return 0; }
  if (hay_len < needle_len) { return 0 - 1; }
  if (needle_len == 1) {
    if (needle == 0) { return 0 - 1; }
    return xlang_string_memchr_c(hay, needle[0], hay_len);
  }
  return xlang_string_portable_memmem_c(hay, hay_len, needle, needle_len);
}

/**
 * Pointer arithmetic: return ptr + offset (no bounds checking).
 * Returns NULL if ptr is NULL.
 * @param ptr base pointer
 * @param off byte offset (signed; caller must ensure ptr+off is valid)
 * @return ptr + off, or NULL if ptr was NULL
 */
#[no_mangle]
export function xlang_string_ptr_at_c(ptr: *u8, off: i32): *u8 {
  if (ptr == 0) { return 0 as *u8; }
  return ptr + off;
}

/**
 * Memory comparison: wrap libc memcmp with normalized return.
 * Returns -1 if a < b, 0 if equal, 1 if a > b. Returns 0 if n <= 0.
 * @param a first buffer
 * @param b second buffer
 * @param n byte count to compare (≥0)
 * @return -1, 0, or 1
 */
#[no_mangle]
export function xlang_string_memcmp_c(a: *u8, b: *u8, n: i32): i32 {
  if (n <= 0) { return 0; }
  let r: i32 = 0;
  unsafe {
    r = memcmp(a, b, n);
  }
  if (r < 0) { return 0 - 1; }
  if (r > 0) { return 1; }
  return 0;
}

/**
 * Memory comparison at offset: compare a[off..off+n-1] with b[0..n-1].
 * Returns libc memcmp raw result (not normalized). Returns 0 if n <= 0.
 * @param a first buffer
 * @param off byte offset into a
 * @param b second buffer
 * @param n byte count to compare (≥0)
 * @return memcmp result (-/0/+)
 */
#[no_mangle]
export function xlang_string_memcmp_at_c(a: *u8, off: i32, b: *u8, n: i32): i32 {
  if (n <= 0) { return 0; }
  unsafe {
    return memcmp(a + off, b, n);
  }
  return 0;
}

/**
 * Memory copy: wrap libc memcpy. No-op if n <= 0.
 * @param dst destination buffer
 * @param src source buffer
 * @param n byte count to copy (≥0)
 */
#[no_mangle]
export function xlang_string_copy_c(dst: *u8, src: *u8, n: i32): void {
  if (n <= 0) { return; }
  unsafe {
    memcpy(dst, src, n);
  }
}
