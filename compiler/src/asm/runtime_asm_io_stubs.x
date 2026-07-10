// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-20：runtime_asm_io_stubs 产品源迁 seeds/runtime_asm_io_stubs.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_asm_io_stubs.from_x.c → runtime_asm_io_stubs.o
// G-02f-100：+ seed_io_syscall write/read + write_fd1 薄门闩。

extern "C" function seed_io_syscall_write_impl(fd: i32, buf: *u8, count: usize): isize;
extern "C" function seed_io_syscall_read_impl(fd: i32, buf: *u8, count: usize): isize;
extern "C" function seed_io_write_fd1_impl(ptr: *u8, len: usize, timeout_ms: u32): i32;

function runtime_asm_io_stubs_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-100：seed io 门闩 ---- */

#[no_mangle]
function seed_io_syscall_write(fd: i32, buf: *u8, count: usize): isize {
  unsafe {
    return seed_io_syscall_write_impl(fd, buf, count);
  }
  return 0 - 1;
}

#[no_mangle]
function seed_io_syscall_read(fd: i32, buf: *u8, count: usize): isize {
  unsafe {
    return seed_io_syscall_read_impl(fd, buf, count);
  }
  return 0 - 1;
}

#[no_mangle]
function seed_io_write_fd1(ptr: *u8, len: usize, timeout_ms: u32): i32 {
  unsafe {
    return seed_io_write_fd1_impl(ptr, len, timeout_ms);
  }
  return 0 - 1;
}
