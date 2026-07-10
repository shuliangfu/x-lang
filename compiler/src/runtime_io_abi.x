// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-29/44/57/58：真迁 .x — std.fs / posix + 路径读写 + file_view 门闩。
// 产品：./shux-c -E → seeds/runtime_io_abi.from_x.c（+ C 尾段）。
// C 尾：open_write flags/mode、file_view mmap bulk、os_read_file_into 循环。
// G-02f-58：+ runtime_read_file_view / read_file_malloc / std_sys_os_read_file_into。

extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
extern "C" function close(fd: i32): i32;
extern "C" function read(fd: i32, buf: *u8, count: usize): isize;
extern "C" function write(fd: i32, buf: *u8, count: usize): isize;
extern "C" function shux_fs_open_write_flags(): i32;
extern "C" function shux_fs_open_write_mode(): i32;
extern "C" function shux_read_file_into_path_impl(path: *u8, buf: *u8, cap: i64): i32;
extern "C" function shux_write_path_bytes_impl(path: *u8, data: *u8, len: i64): i32;
extern "C" function runtime_release_file_view_impl(view: *u8): void;
extern "C" function runtime_read_file_view_impl(path: *u8, out: *u8): i32;
extern "C" function runtime_read_file_malloc_impl(path: *u8, out_len: *u8): *u8;
extern "C" function std_sys_os_read_file_into_impl(path: *u8, buf: *u8, cap: i32): i32;

#[no_mangle]
function std_fs_fs_open_read(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    // O_RDONLY|SHUX_O_BINARY == 0 on POSIX hosts used by product gates.
    let r: i32 = open(path, 0, 0);
    return r;
  }
  return 0 - 1;
}

#[no_mangle]
function std_fs_fs_open_write(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    let fl: i32 = shux_fs_open_write_flags();
    let md: i32 = shux_fs_open_write_mode();
    let r: i32 = open(path, fl, md);
    return r;
  }
  return 0 - 1;
}

#[no_mangle]
function std_fs_fs_close(fd: i32): i32 {
  unsafe {
    let r: i32 = close(fd);
    return r;
  }
  return 0 - 1;
}

#[no_mangle]
function std_fs_fs_invalid_handle(): i32 {
  return 0 - 1;
}

#[no_mangle]
function std_fs_fs_read(fd: i32, buf: *u8, count: usize): isize {
  if (buf == 0 as *u8) {
    let neg: isize = (0 - 1) as isize;
    return neg;
  }
  unsafe {
    let n: isize = read(fd, buf, count);
    return n;
  }
  let neg2: isize = (0 - 1) as isize;
  return neg2;
}

#[no_mangle]
function std_fs_fs_write(fd: i32, buf: *u8, count: usize): isize {
  if (buf == 0 as *u8) {
    let neg: isize = (0 - 1) as isize;
    return neg;
  }
  unsafe {
    let n: isize = write(fd, buf, count);
    return n;
  }
  let neg2: isize = (0 - 1) as isize;
  return neg2;
}

#[no_mangle]
function fs_posix_close_c(fd: i32): i32 {
  return std_fs_fs_close(fd);
}

#[no_mangle]
function fs_posix_read_c(fd: i32, buf: *u8, count: usize): isize {
  return std_fs_fs_read(fd, buf, count);
}

#[no_mangle]
function fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize {
  return std_fs_fs_write(fd, buf, count);
}

/* ---- G-02f-57：路径读/写与 file_view 释放 ---- */

#[no_mangle]
function shux_read_file_into_path(path: *u8, buf: *u8, cap: i64): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (buf == 0 as *u8) {
    return -1;
  }
  if (cap == 0) {
    return -1;
  }
  unsafe {
    return shux_read_file_into_path_impl(path, buf, cap);
  }
  return -1;
}

#[no_mangle]
function shux_write_path_bytes(path: *u8, data: *u8, len: i64): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (data == 0 as *u8) {
    return -1;
  }
  unsafe {
    return shux_write_path_bytes_impl(path, data, len);
  }
  return -1;
}

#[no_mangle]
function runtime_release_file_view(view: *u8): void {
  if (view == 0 as *u8) {
    return;
  }
  unsafe {
    runtime_release_file_view_impl(view);
  }
}

/* ---- G-02f-58：file_view 读入 / malloc 整文件 / os_read_file_into ---- */

#[no_mangle]
function runtime_read_file_view(path: *u8, out: *u8): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (out == 0 as *u8) {
    return -1;
  }
  unsafe {
    return runtime_read_file_view_impl(path, out);
  }
  return -1;
}

#[no_mangle]
function runtime_read_file_malloc(path: *u8, out_len: *u8): *u8 {
  if (path == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return runtime_read_file_malloc_impl(path, out_len);
  }
  return 0 as *u8;
}

#[no_mangle]
function std_sys_os_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (buf == 0 as *u8) {
    return -1;
  }
  if (cap <= 0) {
    return -1;
  }
  unsafe {
    return std_sys_os_read_file_into_impl(path, buf, cap);
  }
  return -1;
}
