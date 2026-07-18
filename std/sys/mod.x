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

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.

#[cfg(target_os = "linux")]
const linux = import("std.sys.linux");

#[cfg(target_os = "macos")]
const macos = import("std.sys.macos");

#[cfg(target_os = "freebsd")]
const freebsd = import("std.sys.freebsd");

#[cfg(target_os = "windows")]
const win32 = import("std.sys.win32");

const mmap_m = import("std.sys.mmap");

/* See implementation. */
export const STDOUT_FD: i32 = 1;
/* See implementation. */
export const STDERR_FD: i32 = 2;

/* See implementation. */
#[cfg(target_os = "linux")]
extern function shux_sys_write(fd: i32, buf: *u8, count: usize): isize;

/**
 * See implementation.
 */
#[cfg(target_os = "linux")]
export function freestanding_write_available(): i32 {
  return 1;
}

#[cfg(target_os = "macos")]
/** Exported function `freestanding_write_available`.
 * Write path helper `freestanding_write_available`.
 * @return i32
 */
export function freestanding_write_available(): i32 {
  return 0;
}

#[cfg(target_os = "freebsd")]
/** Exported function `freestanding_write_available`.
 * Write path helper `freestanding_write_available`.
 * @return i32
 */
export function freestanding_write_available(): i32 {
  return 0;
}

/**
 * See implementation.
 */
#[cfg(target_os = "linux")]
export function write(fd: i32, buf: *u8, len: i32): i32 {
  if (len <= 0) {
    return 0;
  }
  if (buf == 0) {
    return -1;
  }
  unsafe {
    return shux_sys_write(fd, buf, len as usize) as i32;
  }
}

#[cfg(target_os = "macos")]
/** Exported function `write`.
 * Write path helper `write`.
 * @param fd i32
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function write(fd: i32, buf: *u8, len: i32): i32 {
  return macos.macos_write(fd, buf, len);
}

#[cfg(target_os = "freebsd")]
/** Exported function `write`.
 * Write path helper `write`.
 * @param fd i32
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function write(fd: i32, buf: *u8, len: i32): i32 {
  return freebsd.freebsd_write(fd, buf, len);
}

/** Exported function `write`.
 * Write path helper `write`.
 * @param fd i32
 * @param buf *u8
 * @param len i32
 * @return i32
 */
#[cfg(target_os = "windows")]
export function write(fd: i32, buf: *u8, len: i32): i32 {
  return win32.win32_write(fd, buf, len);
}

/** Exported function `write_stdout`.
 * Write path helper `write_stdout`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
#[cfg(target_os = "linux")]
export function write_stdout(buf: *u8, len: i32): i32 {
  return write(STDOUT_FD, buf, len);
}

#[cfg(target_os = "macos")]
/** Exported function `write_stdout`.
 * Write path helper `write_stdout`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function write_stdout(buf: *u8, len: i32): i32 {
  return write(STDOUT_FD, buf, len);
}

#[cfg(target_os = "freebsd")]
/** Exported function `write_stdout`.
 * Write path helper `write_stdout`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function write_stdout(buf: *u8, len: i32): i32 {
  return write(STDOUT_FD, buf, len);
}

#[cfg(target_os = "windows")]
/** Exported function `write_stdout`.
 * Write path helper `write_stdout`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function write_stdout(buf: *u8, len: i32): i32 {
  return write(STDOUT_FD, buf, len);
}

/** Exported function `write_stderr`.
 * Write path helper `write_stderr`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
#[cfg(target_os = "linux")]
export function write_stderr(buf: *u8, len: i32): i32 {
  return write(STDERR_FD, buf, len);
}

#[cfg(target_os = "macos")]
/** Exported function `write_stderr`.
 * Write path helper `write_stderr`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function write_stderr(buf: *u8, len: i32): i32 {
  return write(STDERR_FD, buf, len);
}

#[cfg(target_os = "freebsd")]
/** Exported function `write_stderr`.
 * Write path helper `write_stderr`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function write_stderr(buf: *u8, len: i32): i32 {
  return write(STDERR_FD, buf, len);
}

#[cfg(target_os = "windows")]
/** Exported function `write_stderr`.
 * Write path helper `write_stderr`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function write_stderr(buf: *u8, len: i32): i32 {
  return write(STDERR_FD, buf, len);
}

/**
 * See implementation.
 */
#[cfg(target_os = "linux")]
export function linux_syscall_table_available(): i32 {
  return linux.linux_syscall_table_available();
}

/** Exported function `linux_syscall_nr_write_amd64`.
 * Write path helper `linux_syscall_nr_write_amd64`.
 * @return i64
 */
#[cfg(target_os = "linux")]
export function linux_syscall_nr_write_amd64(): i64 {
  return linux.linux_syscall_nr_write_amd64();
}

/** Exported function `linux_syscall_nr_write_arm64`.
 * Write path helper `linux_syscall_nr_write_arm64`.
 * @return i64
 */
#[cfg(target_os = "linux")]
export function linux_syscall_nr_write_arm64(): i64 {
  return linux.linux_syscall_nr_write_arm64();
}

/**
 * See implementation.
 */
#[cfg(target_os = "macos")]
export function macos_write_available(): i32 {
  return macos.macos_write_available();
}

/** Exported function `macos_write`.
 * Write path helper `macos_write`.
 * @param fd i32
 * @param buf *u8
 * @param len i32
 * @return i32
 */
#[cfg(target_os = "macos")]
export function macos_write(fd: i32, buf: *u8, len: i32): i32 {
  return macos.macos_write(fd, buf, len);
}

/** Exported function `macos_write_stdout`.
 * Write path helper `macos_write_stdout`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
#[cfg(target_os = "macos")]
export function macos_write_stdout(buf: *u8, len: i32): i32 {
  return macos.macos_write_stdout(buf, len);
}

/** Exported function `macos_write_stderr`.
 * Write path helper `macos_write_stderr`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
#[cfg(target_os = "macos")]
export function macos_write_stderr(buf: *u8, len: i32): i32 {
  return macos.macos_write_stderr(buf, len);
}

/** Exported function `freebsd_write_available`.
 * Write path helper `freebsd_write_available`.
 * @return i32
 */
#[cfg(target_os = "freebsd")]
export function freebsd_write_available(): i32 {
  return freebsd.freebsd_write_available();
}

#[cfg(target_os = "freebsd")]
/** Exported function `freebsd_write`.
 * Write path helper `freebsd_write`.
 * @param fd i32
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function freebsd_write(fd: i32, buf: *u8, len: i32): i32 {
  return freebsd.freebsd_write(fd, buf, len);
}

#[cfg(target_os = "freebsd")]
/** Exported function `freebsd_write_stdout`.
 * Write path helper `freebsd_write_stdout`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function freebsd_write_stdout(buf: *u8, len: i32): i32 {
  return freebsd.freebsd_write_stdout(buf, len);
}

#[cfg(target_os = "freebsd")]
/** Exported function `freebsd_write_stderr`.
 * Write path helper `freebsd_write_stderr`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function freebsd_write_stderr(buf: *u8, len: i32): i32 {
  return freebsd.freebsd_write_stderr(buf, len);
}

/** Exported function `freebsd_mmap_available`.
 * Memory management helper `freebsd_mmap_available`.
 * @return i32
 */
#[cfg(target_os = "freebsd")]
export function freebsd_mmap_available(): i32 {
  return freebsd.freebsd_mmap_available();
}

/** Exported function `macos_mmap_available`.
 * Implements `macos_mmap_available`.
 * @return i32
 */
#[cfg(target_os = "macos")]
export function macos_mmap_available(): i32 {
  return macos.macos_mmap_available();
}

/**
 * See implementation.
 * See implementation.
 */
export function mmap_available(): i32 {
  return mmap_m.mmap_available();
}

/** Exported function `mmap_rw`.
 * Implements `mmap_rw`.
 * @param path *u8
 * @param min_size usize
 * @param out_size *usize
 * @return *u8
 */
#[cfg(not(freestanding))]
export function mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  return mmap_m.mmap_rw(path, min_size, out_size);
}

/** Exported function `munmap`.
 * Implements `munmap`.
 * @param ptr *u8
 * @param size usize
 * @return i32
 */
#[cfg(not(freestanding))]
export function munmap(ptr: *u8, size: usize): i32 {
  return mmap_m.munmap(ptr, size);
}

/** Exported function `msync`.
 * Implements `msync`.
 * @param ptr *u8
 * @param size usize
 * @return i32
 */
#[cfg(not(freestanding))]
export function msync(ptr: *u8, size: usize): i32 {
  return mmap_m.msync(ptr, size);
}

/**
 * See implementation.
 * See implementation.
 */
#[cfg(target_os = "linux")]
export function read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  return linux.linux_read_file_into(path, buf, cap);
}

#[cfg(target_os = "macos")]
/** Exported function `read_file_into`.
 * Read path helper `read_file_into`.
 * @param path *u8
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
export function read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  return macos.macos_read_file_into(path, buf, cap);
}

#[cfg(target_os = "freebsd")]
/** Exported function `read_file_into`.
 * Read path helper `read_file_into`.
 * @param path *u8
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
export function read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  return freebsd.freebsd_read_file_into(path, buf, cap);
}

/** Exported function `read_file_into`.
 * Read path helper `read_file_into`.
 * @param path *u8
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
#[cfg(target_os = "windows")]
export function read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  return win32.win32_read_file_into(path, buf, cap);
}

/** Exported function `read`.
 * Read path helper `read`.
 * @param fd i32
 * @param buf *u8
 * @param len i32
 * @return i32
 */
#[cfg(target_os = "linux")]
export function read(fd: i32, buf: *u8, len: i32): i32 {
  return linux.linux_syscall_read(fd, buf, len);
}

/** Exported function `read`.
 * Read path helper `read`.
 * @param fd i32
 * @param buf *u8
 * @param len i32
 * @return i32
 */
#[cfg(target_os = "macos")]
export function read(fd: i32, buf: *u8, len: i32): i32 {
  return macos.macos_read(fd, buf, len);
}

#[cfg(target_os = "freebsd")]
/** Exported function `read`.
 * Read path helper `read`.
 * @param fd i32
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function read(fd: i32, buf: *u8, len: i32): i32 {
  return freebsd.freebsd_read(fd, buf, len);
}

/** Exported function `read`.
 * Read path helper `read`.
 * @param fd i32
 * @param buf *u8
 * @param len i32
 * @return i32
 */
#[cfg(target_os = "windows")]
export function read(fd: i32, buf: *u8, len: i32): i32 {
  (void)fd;
  (void)buf;
  (void)len;
  return -1;
}

/** Exported function `close`.
 * Implements `close`.
 * @param fd i32
 * @return i32
 */
#[cfg(target_os = "linux")]
export function close(fd: i32): i32 {
  return linux.linux_syscall_close(fd);
}

/** Exported function `close`.
 * Implements `close`.
 * @param fd i32
 * @return i32
 */
#[cfg(target_os = "macos")]
export function close(fd: i32): i32 {
  return macos.macos_close(fd);
}

#[cfg(target_os = "freebsd")]
/** Exported function `close`.
 * Implements `close`.
 * @param fd i32
 * @return i32
 */
export function close(fd: i32): i32 {
  return freebsd.freebsd_close(fd);
}

/** Exported function `close`.
 * Implements `close`.
 * @param fd i32
 * @return i32
 */
#[cfg(target_os = "windows")]
export function close(fd: i32): i32 {
  (void)fd;
  return -1;
}

/** Linux exit(2) freestanding；noreturn。 */
#[cfg(target_os = "linux")]
export function exit(code: i32): void {
  linux.linux_syscall_exit(code);
}

/** Exported function `exit`.
 * Implements `exit`.
 * @param code i32
 * @return void
 */
#[cfg(target_os = "macos")]
export function exit(code: i32): void {
  macos.macos_exit(code);
}

#[cfg(target_os = "freebsd")]
/** Exported function `exit`.
 * Implements `exit`.
 * @param code i32
 * @return void
 */
export function exit(code: i32): void {
  freebsd.freebsd_exit(code);
}

/** Exported function `exit`.
 * Implements `exit`.
 * @param code i32
 * @return void
 */
#[cfg(target_os = "windows")]
export function exit(code: i32): void {
  win32.win32_exit_process(code);
}

/** Exported function `mmap`.
 * Implements `mmap`.
 * @param path *u8
 * @param min_size usize
 * @param out_size *usize
 * @return *u8
 */
#[cfg(not(freestanding))]
export function mmap(path: *u8, min_size: usize, out_size: *usize): *u8 {
  return mmap_rw(path, min_size, out_size);
}
