// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// std.sys.macos — Darwin/macOS POSIX I/O + mmap FFI（BOOT-029 v2 / B-16 v0）
//
// 【文件职责】
// 为常规 `-o exe` 宿主程序提供 libSystem write/open/read/mmap 封装；
// 与 Linux freestanding 路径（shux_sys_*）互补，不含条件编译。
//
// 【链接】
// shux 在 macOS 上链接可执行文件时由 clang 隐式链 libSystem；符号 write(2) 直接解析。

/** POSIX write(2) @ libSystem；count 为字节数。 */
extern "C" function write(fd: i32, buf: *u8, count: usize): isize;

/** POSIX open/read/close @ libSystem（B-20 v0 读文件）。 */
extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
extern "C" function read(fd: i32, buf: *u8, count: usize): isize;
extern "C" function close(fd: i32): i32;

/** macOS open(2) O_RDONLY。 */
const MACOS_O_RDONLY: i32 = 0;

/** macOS open(2) O_RDWR。 */
const MACOS_O_RDWR: i32 = 2;

/** macOS open(2) O_CREAT。 */
const MACOS_O_CREAT: i32 = 512;

/** mmap(2) MAP_PRIVATE @ libSystem。 */
const MACOS_MAP_PRIVATE: i32 = 2;

/** mmap(2) MAP_ANON @ libSystem。 */
const MACOS_MAP_ANON: i32 = 4096;

/** mmap(2) MAP_SHARED @ libSystem。 */
const MACOS_MAP_SHARED: i32 = 1;

/** mmap(2) PROT_READ。 */
const MACOS_PROT_READ: i32 = 1;

/** mmap(2) PROT_WRITE。 */
const MACOS_PROT_WRITE: i32 = 2;

/** POSIX mmap/munmap/msync/ftruncate/lseek @ libSystem（B-16 v0/v1）。 */
extern "C" function mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8;
extern "C" function munmap(addr: *u8, len: usize): i32;
extern "C" function msync(addr: *u8, len: usize, flags: i32): i32;
extern "C" function ftruncate(fd: i32, length: i64): i32;
extern "C" function lseek(fd: i32, offset: i64, whence: i32): i64;

/** lseek(2) SEEK_END：取当前文件长度。 */
const MACOS_SEEK_END: i32 = 2;

/** POSIX _exit(2) @ libSystem（noreturn）。 */
extern "C" function _exit(code: i32): void;

/**
 * B-16 v2：进程退出；noreturn。
 */
function macos_exit(code: i32): void {
  unsafe {
    _exit(code);
  }
}

/** open(2) O_CREAT 默认 mode 0644。 */
const MACOS_OPEN_MODE_0644: i32 = 420;

/**
 * v2 探测：macOS POSIX write 门面是否导出（恒 1）。
 * 实际符号由系统 libc/libSystem 在链接期解析。
 */
function macos_write_available(): i32 {
  return 1;
}

/**
 * 向 fd 写入 buf[0..len)；Darwin 走 write(2)。
 * 成功返回写入字节数；失败或 count 溢出返回 -1。
 */
function macos_write(fd: i32, buf: *u8, len: i32): i32 {
  if (len <= 0) {
    return 0;
  }
  if (buf == 0) {
    return -1;
  }
  let count: usize = len as usize;
  let r: isize = 0 as isize;
  unsafe {
    r = write(fd, buf, count);
  }
  if (r < 0) {
    return -1;
  }
  return r as i32;
}

/** 写 stdout；等价 macos_write(1, buf, len)。 */
function macos_write_stdout(buf: *u8, len: i32): i32 {
  return macos_write(1, buf, len);
}

/** 写 stderr；等价 macos_write(2, buf, len)。 */
function macos_write_stderr(buf: *u8, len: i32): i32 {
  return macos_write(2, buf, len);
}

/**
 * B-16 v2：单次 POSIX read(2)；成功返回读入字节数，失败 -1。
 */
function macos_read(fd: i32, buf: *u8, len: i32): i32 {
  if (len <= 0) {
    return 0;
  }
  if (buf == 0) {
    return -1;
  }
  let r: isize = 0 as isize;
  unsafe {
    r = read(fd, buf, len);
  }
  if (r < 0) {
    return -1;
  }
  return r as i32;
}

/** B-16 v2：close(2) 薄封装。 */
function macos_close(fd: i32): i32 {
  unsafe {
    return close(fd);
  }
}

/**
 * B-20 v1：读整文件到 buf[0..cap)（循环 read 直到 EOF 或 cap）。
 * 成功返回读入字节数；失败返回 -1。
 */
function macos_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 || buf == 0 || cap <= 0) {
    return -1;
  }
  let fd: i32 = 0;
  unsafe {
    fd = open(path, MACOS_O_RDONLY, 0);
  }
  if (fd < 0) {
    return -1;
  }
  let total: i32 = 0;
  while (total < cap) {
    let chunk: i32 = cap - total;
    let count: usize = chunk as usize;
    let dst: *u8 = (buf as *u8) + total;
    let r: isize = 0 as isize;
    unsafe {
      r = read(fd, dst, count);
    }
    if (r < 0) {
      macos_close(fd);
      return -1;
    }
    if (r == 0) {
      break;
    }
    total = total + (r as i32);
  }
  macos_close(fd);
  return total;
}

/**
 * B-16 v0：匿名 mmap（MAP_PRIVATE|MAP_ANON）；失败返回 null。
 */
function macos_anonymous_mmap(len: usize, prot: i32): *u8 {
  if (len == 0) {
    return 0;
  }
  unsafe {
    return mmap(0 as *u8, len, prot, MACOS_MAP_PRIVATE | MACOS_MAP_ANON, -1, 0 as i64);
  }
}

/** 解除 mmap 映射；0 成功，-1 失败。 */
function macos_munmap(addr: *u8, len: usize): i32 {
  if (addr == 0 || len == 0) {
    return -1;
  }
  unsafe {
    return munmap(addr, len);
  }
}

/**
 * B-16 v0 探测：macOS mmap 是否在子模块导出（恒 1）。
 */
function macos_mmap_available(): i32 {
  return 1;
}

/**
 * B-16 v1：文件 MAP_SHARED 可写 mmap（open + ftruncate + mmap）。
 * path NUL 结尾；不足 min_size 时扩展文件；*out_size 经 p[0] 写回映射字节数。
 * 失败返回 null；调用方须 macos_munmap(ptr, *out_size) 释放。
 */
function macos_mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0 || min_size == 0) {
    return 0;
  }
  unsafe {
    let flags: i32 = MACOS_O_RDWR | MACOS_O_CREAT;
    let fd: i32 = open(path, flags, MACOS_OPEN_MODE_0644);
    if (fd < 0) {
      return 0;
    }
    let cur: i64 = lseek(fd, 0 as i64, MACOS_SEEK_END);
    if (cur < 0) {
      close(fd);
      return 0;
    }
    let len: usize = cur as usize;
    if (len < min_size) {
      if (ftruncate(fd, min_size as i64) != 0) {
        close(fd);
        return 0;
      }
      len = min_size;
    }
    let prot: i32 = MACOS_PROT_READ | MACOS_PROT_WRITE;
    let p: *u8 = mmap(0 as *u8, len, prot, MACOS_MAP_SHARED, fd, 0 as i64);
    close(fd);
    let p_i: i64 = p as i64;
    if (p_i <= 0) {
      return 0;
    }
    out_size[0] = len;
    return p;
  }
}

/** msync(2) MS_SYNC @ libSystem。 */
const MACOS_MS_SYNC: i32 = 16;

/** msync 刷盘（MS_SYNC）；0 成功，-1 失败。 */
function macos_msync_sync(addr: *u8, len: usize): i32 {
  if (addr == 0 || len == 0) {
    return -1;
  }
  unsafe {
    return msync(addr, len, MACOS_MS_SYNC);
  }
}
