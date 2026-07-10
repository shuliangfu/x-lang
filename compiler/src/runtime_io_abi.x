// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-29/44：真迁 .x — std.fs / posix 薄 shim（open_read/write）。
// 产品：./shux-c -E → seeds/runtime_io_abi.from_x.c（+ C 尾段）。
// C 尾：open_write flags/mode 槽（O_CREAT/TRUNC 平台相关）、file_view、os_read_file_into。
// G-02f-44：+ std_fs_fs_open_write（经 shux_fs_open_write_flags/mode 槽）。

extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
extern "C" function close(fd: i32): i32;
extern "C" function read(fd: i32, buf: *u8, count: usize): isize;
extern "C" function write(fd: i32, buf: *u8, count: usize): isize;
extern "C" function shux_fs_open_write_flags(): i32;
extern "C" function shux_fs_open_write_mode(): i32;

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
