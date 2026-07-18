// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_string_fast 产品源迁 seeds/runtime_string_fast.from_x.c。
// G-02f-99：+ portable memmem。
// G-02f-151：shux_string_portable_memmem_c / memrchr 真迁 .x
// G-02f-rest：rest→.x 迁移：ptr_at_c / memcmp_c / memcmp_at_c / copy_c 真迁 .x
//   Why：消除 seed 中 rest 函数，使 runtime_string_fast 进入 DIRECT 模式（无 ld -r）
//   Invariant：与 seed 同语义（memcmp 返回值归一化为 -1/0/1；memcmp_at 返回原始 r）
//   Perf：仅 libc memcmp/memcpy 调用，无热路径分支冗余

export extern "C" function memcmp(a: *u8, b: *u8, n: i32): i32;
export extern "C" function memcpy(dst: *u8, src: *u8, n: i32): *u8;

export function runtime_string_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-151：string fast pure helpers ---- */

// 从后向前找字节；成功返回下标，失败 -1
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

// memchr：前向找；成功下标，失败 -1
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

// G-02f-151：portable memmem（无 libc memmem）
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

// 与 seed 一致：needle_len==1 走 memchr，否则 portable
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

/* ---- G-02f-rest：rest→.x 迁移（原 seed 中 4 个 rest 函数） ---- */

// 指针加偏移；ptr 为空返回空
#[no_mangle]
export function shux_string_ptr_at_c(ptr: *u8, off: i32): *u8 {
  if (ptr == 0) { return 0 as *u8; }
  return ptr + off;
}

// memcmp 归一化到 -1/0/1；n<=0 视作相等
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

// memcmp_at：从 a+off 起比较；返回 memcmp 原始值（与 seed 同语义，非归一化）
#[no_mangle]
export function shux_string_memcmp_at_c(a: *u8, off: i32, b: *u8, n: i32): i32 {
  if (n <= 0) { return 0; }
  unsafe {
    return memcmp(a + off, b, n);
  }
  return 0;
}

// memcpy 封装；n<=0 跳过
#[no_mangle]
export function shux_string_copy_c(dst: *u8, src: *u8, n: i32): void {
  if (n <= 0) { return; }
  unsafe {
    memcpy(dst, src, n);
  }
}
