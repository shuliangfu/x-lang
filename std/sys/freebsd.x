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

// std.sys.freebsd — FreeBSD POSIX I/O + mmap FFI（BOOT-029 / B-21 v0）
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.

/* See implementation. */
extern "C" function write(fd: i32, buf: *u8, count: usize): isize;

/** POSIX open/read/close @ libc。 */
extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
extern "C" function read(fd: i32, buf: *u8, count: usize): isize;
extern "C" function close(fd: i32): i32;

/** FreeBSD open(2) O_RDONLY。 */
export const FREEBSD_O_RDONLY: i32 = 0;

/** FreeBSD open(2) O_RDWR。 */
export const FREEBSD_O_RDWR: i32 = 2;

/** FreeBSD open(2) O_CREAT。 */
export const FREEBSD_O_CREAT: i32 = 512;

/** mmap(2) MAP_PRIVATE @ libc。 */
export const FREEBSD_MAP_PRIVATE: i32 = 2;

/** mmap(2) MAP_ANON @ FreeBSD。 */
export const FREEBSD_MAP_ANON: i32 = 4096;

/** mmap(2) MAP_SHARED @ libc。 */
export const FREEBSD_MAP_SHARED: i32 = 1;

/** mmap(2) PROT_READ。 */
export const FREEBSD_PROT_READ: i32 = 1;

/** mmap(2) PROT_WRITE。 */
export const FREEBSD_PROT_WRITE: i32 = 2;

/** POSIX mmap/munmap/msync/ftruncate/lseek @ libc。 */
extern "C" function mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8;
extern "C" function munmap(addr: *u8, len: usize): i32;
extern "C" function msync(addr: *u8, len: usize, flags: i32): i32;
extern "C" function ftruncate(fd: i32, len: i64): i32;
extern "C" function lseek(fd: i32, offset: i64, whence: i32): i64;

/** lseek(2) SEEK_END。 */
export const FREEBSD_SEEK_END: i32 = 2;

/** POSIX _exit(2) @ libc（noreturn）。 */
extern "C" function _exit(code: i32): void;

/**
 * See implementation.
 */
export function freebsd_exit(code: i32): void {
  unsafe {
    _exit(code);
  }
}

/* See implementation. */
export const FREEBSD_OPEN_MODE_0644: i32 = 420;

/**
 * See implementation.
 */
export function freebsd_write_available(): i32 {
  return 1;
}

/**
 * See implementation.
 */
export function syscall_nr_write_amd64(): i64 {
  return 4;
}

/**
 * See implementation.
 */
export function freebsd_write(fd: i32, buf: *u8, len: i32): i32 {
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

/** Exported function `freebsd_write_stdout`.
 * Write path helper `freebsd_write_stdout`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function freebsd_write_stdout(buf: *u8, len: i32): i32 {
  return freebsd_write(1, buf, len);
}

/** Exported function `freebsd_write_stderr`.
 * Write path helper `freebsd_write_stderr`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function freebsd_write_stderr(buf: *u8, len: i32): i32 {
  return freebsd_write(2, buf, len);
}

/**
 * See implementation.
 */
export function freebsd_read(fd: i32, buf: *u8, len: i32): i32 {
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

/** Exported function `freebsd_close`.
 * Memory management helper `freebsd_close`.
 * @param fd i32
 * @return i32
 */
export function freebsd_close(fd: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = close(fd); }
  return _rc;
}

/**
 * See implementation.
 */
export function freebsd_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 || buf == 0 || cap <= 0) {
    return -1;
  }
  let fd: i32 = 0;
  unsafe {
    fd = open(path, FREEBSD_O_RDONLY, 0);
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
      freebsd_close(fd);
      return -1;
    }
    if (r == 0) {
      break;
    }
    total = total + (r as i32);
  }
  freebsd_close(fd);
  return total;
}

/**
 * See implementation.
 */
export function freebsd_anonymous_mmap(len: usize, prot: i32): *u8 {
  if (len == 0) {
    return 0 as *u8;
  }
  unsafe {
    return mmap(0 as *u8, len, prot, FREEBSD_MAP_PRIVATE | FREEBSD_MAP_ANON, -1, 0 as i64);
  }
}

/** Exported function `freebsd_munmap`.
 * Memory management helper `freebsd_munmap`.
 * @param addr *u8
 * @param len usize
 * @return i32
 */
export function freebsd_munmap(addr: *u8, len: usize): i32 {
  if (addr == 0 || len == 0) {
    return -1;
  }
  unsafe {
    return munmap(addr, len);
  }
}

/** Exported function `freebsd_mmap_available`.
 * Memory management helper `freebsd_mmap_available`.
 * @return i32
 */
export function freebsd_mmap_available(): i32 {
  return 1;
}

/**
 * See implementation.
 */
export function freebsd_mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0 || min_size == 0) {
    return 0 as *u8;
  }
  unsafe {
    let flags: i32 = FREEBSD_O_RDWR | FREEBSD_O_CREAT;
    let fd: i32 = open(path, flags, FREEBSD_OPEN_MODE_0644);
    if (fd < 0) {
      return 0 as *u8;
    }
    let cur: i64 = lseek(fd, 0 as i64, FREEBSD_SEEK_END);
    if (cur < 0) {
      close(fd);
      return 0 as *u8;
    }
    let len: usize = cur as usize;
    if (len < min_size) {
      if (ftruncate(fd, min_size as i64) != 0) {
        close(fd);
        return 0 as *u8;
      }
      len = min_size;
    }
    let prot: i32 = FREEBSD_PROT_READ | FREEBSD_PROT_WRITE;
    let p: *u8 = mmap(0 as *u8, len, prot, FREEBSD_MAP_SHARED, fd, 0 as i64);
    close(fd);
    let p_i: i64 = p as i64;
    if (p_i <= 0) {
      return 0 as *u8;
    }
    out_size[0] = len;
    return p;
  }
}

/** msync(2) MS_SYNC。 */
export const FREEBSD_MS_SYNC: i32 = 16;

/** Exported function `freebsd_msync_sync`.
 * Memory management helper `freebsd_msync_sync`.
 * @param addr *u8
 * @param len usize
 * @return i32
 */
export function freebsd_msync_sync(addr: *u8, len: usize): i32 {
  if (addr == 0 || len == 0) {
    return -1;
  }
  unsafe {
    return msync(addr, len, FREEBSD_MS_SYNC);
  }
}
