// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f：bootstrap_nostdlib_stubs 产品源迁 seeds/bootstrap_nostdlib_stubs.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-103：+ align16 / heap_grow / syscall3/4 薄门闩。
// G-02f-104：+ format_double / vfprintf_fd 薄门闩。

extern "C" function bootstrap_align16_impl(n: usize): usize;
extern "C" function bootstrap_heap_grow_impl(need: usize): i32;
extern "C" function bootstrap_syscall3_impl(nr: i64, a0: i64, a1: i64, a2: i64): i64;
extern "C" function bootstrap_syscall4_impl(nr: i64, a0: i64, a1: i64, a2: i64, a3: i64): i64;
extern "C" function bootstrap_format_double_impl(x: f64, out: *u8, cap: usize): i32;
extern "C" function bootstrap_vfprintf_fd_impl(fd: i32, fmt: *u8, ap: *u8): i32;

function bootstrap_nostdlib_stubs_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-103：nostdlib helpers 门闩 ---- */

#[no_mangle]
function bootstrap_align16(n: usize): usize {
  unsafe {
    return bootstrap_align16_impl(n);
  }
  return 0;
}

#[no_mangle]
function bootstrap_heap_grow(need: usize): i32 {
  unsafe {
    return bootstrap_heap_grow_impl(need);
  }
  return 0 - 1;
}

#[no_mangle]
function bootstrap_syscall3(nr: i64, a0: i64, a1: i64, a2: i64): i64 {
  unsafe {
    return bootstrap_syscall3_impl(nr, a0, a1, a2);
  }
  return 0 - 1;
}

#[no_mangle]
function bootstrap_syscall4(nr: i64, a0: i64, a1: i64, a2: i64, a3: i64): i64 {
  unsafe {
    return bootstrap_syscall4_impl(nr, a0, a1, a2, a3);
  }
  return 0 - 1;
}

/* ---- G-02f-104：format / vfprintf 门闩 ---- */

#[no_mangle]
function bootstrap_format_double(x: f64, out: *u8, cap: usize): i32 {
  unsafe {
    return bootstrap_format_double_impl(x, out, cap);
  }
  return 0;
}

#[no_mangle]
function bootstrap_vfprintf_fd(fd: i32, fmt: *u8, ap: *u8): i32 {
  unsafe {
    return bootstrap_vfprintf_fd_impl(fd, fmt, ap);
  }
  return 0;
}
