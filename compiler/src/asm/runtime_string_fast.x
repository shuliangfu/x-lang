// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_string_fast 产品源迁 seeds/runtime_string_fast.from_x.c。
// G-02f-99：+ portable memmem。
// G-02f-151：shux_string_portable_memmem_c / memrchr 真迁 .x

function runtime_string_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-151：string fast pure helpers ---- */

// 从后向前找字节；成功返回下标，失败 -1
#[no_mangle]
function shux_string_memrchr_c(ptr: *u8, c: u8, n: i32): i32 {
  if (ptr == 0) { return 0 - 1; }
  if (n <= 0) { return 0 - 1; }
  let i: i32 = n - 1;
  while (i >= 0) {
    if (ptr[i] == c) { return i; }
    i = i - 1;
  }
  return 0 - 1;
}

// memchr：前向找；成功下标，失败 -1
#[no_mangle]
function shux_string_memchr_c(ptr: *u8, c: u8, n: i32): i32 {
  if (ptr == 0) { return 0 - 1; }
  if (n <= 0) { return 0 - 1; }
  let i: i32 = 0;
  while (i < n) {
    if (ptr[i] == c) { return i; }
    i = i + 1;
  }
  return 0 - 1;
}

// G-02f-151：portable memmem（无 libc memmem）
#[no_mangle]
function shux_string_portable_memmem_c(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32 {
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

// 与 seed 一致：needle_len==1 走 memchr，否则 portable
#[no_mangle]
function shux_string_memmem_c(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32 {
  if (needle_len <= 0) { return 0; }
  if (hay_len < needle_len) { return 0 - 1; }
  if (needle_len == 1) {
    if (needle == 0) { return 0 - 1; }
    return shux_string_memchr_c(hay, needle[0], hay_len);
  }
  return shux_string_portable_memmem_c(hay, hay_len, needle, needle_len);
}
