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
// See implementation.
//
// See implementation.
// - Linux x86_64: arch/x86/entry/syscalls/syscall_64.tbl
// - Linux arm64:  include/uapi/asm-generic/unistd.h

/* See implementation. */
extern function xlang_sys_open(path: *u8, flags: i32, mode: i32): i32;

/* See implementation. */
extern function xlang_sys_read(fd: i32, buf: *u8, count: usize): isize;

/* See implementation. */
extern function xlang_sys_close(fd: i32): i32;

/* See implementation. */
extern function xlang_sys_exit(code: i32): void;

/* See implementation. */
extern function xlang_sys_write(fd: i32, buf: *u8, count: usize): isize;

/* See implementation. */
extern function xlang_sys_openat(dirfd: i32, path: *u8, flags: i32, mode: i32): i32;

/* See implementation. */
extern function xlang_sys_mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8;

/* See implementation. */
extern function xlang_sys_munmap(addr: *u8, len: usize): i32;

/* See implementation. */
extern function xlang_sys_socket(domain: i32, sock_type: i32, protocol: i32): i32;

/* See implementation. */
extern function xlang_sys_connect(sockfd: i32, addr: *u8, addrlen: i32): i32;

/* See implementation. */
extern function xlang_sys_accept(sockfd: i32, addr: *u8, addrlen: *i32): i32;

/* See implementation. */
extern function xlang_sys_bind(sockfd: i32, addr: *u8, addrlen: i32): i32;

/* See implementation. */
extern function xlang_sys_listen(sockfd: i32, backlog: i32): i32;

// --- x86_64（System V AMD64 ABI：rax=nr, rdi/rsi/rdx/...=args）---

/*
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
/** Exported function `linux_syscall_nr_read_amd64`.
 * Read path helper `linux_syscall_nr_read_amd64`.
 * @return i64
 */
export function linux_syscall_nr_read_amd64(): i64 {
  return 0;
}

/** Exported function `linux_syscall_nr_write_amd64`.
 * Write path helper `linux_syscall_nr_write_amd64`.
 * @return i64
 */
export function linux_syscall_nr_write_amd64(): i64 {
  return 1;
}

/** Exported function `linux_syscall_nr_open_amd64`.
 * Implements `linux_syscall_nr_open_amd64`.
 * @return i64
 */
export function linux_syscall_nr_open_amd64(): i64 {
  return 2;
}

/** Exported function `linux_syscall_nr_close_amd64`.
 * Implements `linux_syscall_nr_close_amd64`.
 * @return i64
 */
export function linux_syscall_nr_close_amd64(): i64 {
  return 3;
}

/** Exported function `linux_syscall_nr_exit_amd64`.
 * Implements `linux_syscall_nr_exit_amd64`.
 * @return i64
 */
export function linux_syscall_nr_exit_amd64(): i64 {
  return 60;
}

/** Exported function `linux_syscall_nr_mmap_amd64`.
 * Implements `linux_syscall_nr_mmap_amd64`.
 * @return i64
 */
export function linux_syscall_nr_mmap_amd64(): i64 {
  return 9;
}

// --- aarch64（AAPCS64：x8=nr, x0-x5=args）---

/** Exported function `linux_syscall_nr_read_arm64`.
 * Read path helper `linux_syscall_nr_read_arm64`.
 * @return i64
 */
export function linux_syscall_nr_read_arm64(): i64 {
  return 63;
}

/** Exported function `linux_syscall_nr_write_arm64`.
 * Write path helper `linux_syscall_nr_write_arm64`.
 * @return i64
 */
export function linux_syscall_nr_write_arm64(): i64 {
  return 64;
}

/** Exported function `linux_syscall_nr_openat_arm64`.
 * Implements `linux_syscall_nr_openat_arm64`.
 * @return i64
 */
export function linux_syscall_nr_openat_arm64(): i64 {
  return 56;
}

/** Exported function `linux_syscall_nr_close_arm64`.
 * Implements `linux_syscall_nr_close_arm64`.
 * @return i64
 */
export function linux_syscall_nr_close_arm64(): i64 {
  return 57;
}

/** Exported function `linux_syscall_nr_exit_arm64`.
 * Implements `linux_syscall_nr_exit_arm64`.
 * @return i64
 */
export function linux_syscall_nr_exit_arm64(): i64 {
  return 93;
}

/** Exported function `linux_syscall_nr_mmap_arm64`.
 * Implements `linux_syscall_nr_mmap_arm64`.
 * @return i64
 */
export function linux_syscall_nr_mmap_arm64(): i64 {
  return 222;
}

/**
 * See implementation.
 * See implementation.
 */
export function linux_syscall_table_available(): i32 {
  return 1;
}

/**
 * See implementation.
 */
export function linux_syscall_invoke_available(): i32 {
  return 1;
}

/**
 * See implementation.
 */
export function linux_syscall_read(fd: i32, buf: *u8, len: i32): i32 {
  if (len <= 0) {
    return 0;
  }
  if (buf == 0) {
    return -1;
  }
  unsafe {
    return xlang_sys_read(fd, buf, len as usize) as i32;
  }
}

/**
 * See implementation.
 */
export function linux_syscall_close(fd: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_sys_close(fd); }
  return _rc;
}

/**
 * See implementation.
 */
export function linux_syscall_write(fd: i32, buf: *u8, len: i32): i32 {
  if (len <= 0) {
    return 0;
  }
  if (buf == 0) {
    return -1;
  }
  unsafe {
    return xlang_sys_write(fd, buf, len as usize) as i32;
  }
}

/**
 * See implementation.
 */
export function linux_syscall_exit(code: i32): void {
  unsafe {
    xlang_sys_exit(code);
  }
}

/* See implementation. */
export const LINUX_O_RDONLY: i32 = 0;

/* See implementation. */
export const LINUX_AT_FDCWD: i32 = -100;

/** mmap(2) MAP_PRIVATE。 */
export const LINUX_MAP_PRIVATE: i32 = 2;

/* See implementation. */
export const LINUX_MAP_ANONYMOUS: i32 = 0x20;

/** mmap(2) PROT_READ。 */
export const LINUX_PROT_READ: i32 = 1;

/** mmap(2) PROT_WRITE。 */
export const LINUX_PROT_WRITE: i32 = 2;

/**
 * See implementation.
 */
export function linux_syscall_openat(dirfd: i32, path: *u8, flags: i32, mode: i32): i32 {
  if (path == 0) {
    return -1;
  }
  unsafe {
    return xlang_sys_openat(dirfd, path, flags, mode);
  }
}

/**
 * See implementation.
 */
export function linux_anonymous_mmap(len: usize, prot: i32, flags: i32): *u8 {
  if (len == 0) {
    return 0 as *u8;
  }
  unsafe {
    return xlang_sys_mmap(0 as *u8, len, prot, flags, -1, 0 as i64);
  }
}

/**
 * See implementation.
 */
export function linux_syscall_munmap(addr: *u8, len: usize): i32 {
  if (addr == 0 || len == 0) {
    return -1;
  }
  unsafe {
    return xlang_sys_munmap(addr, len);
  }
}

/**
 * See implementation.
 */
export function linux_read_file_openat(dirfd: i32, path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 || buf == 0 || cap <= 0) {
    return -1;
  }
  let fd: i32 = 0;
  unsafe {
    fd = xlang_sys_openat(dirfd, path, LINUX_O_RDONLY, 0);
  }
  if (fd < 0) {
    return -1;
  }
  let total: i32 = 0;
  while (total < cap) {
    let chunk: i32 = cap - total;
    let dst: *u8 = (buf as *u8) + total;
    let r: i32 = 0;
    unsafe {
      r = xlang_sys_read(fd, dst, chunk as usize) as i32;
    }
    if (r < 0) {
      linux_syscall_close(fd);
      return -1;
    }
    if (r == 0) {
      break;
    }
    total = total + r;
  }
  linux_syscall_close(fd);
  return total;
}

/**
 * See implementation.
 */
export function linux_syscall_open(path: *u8, flags: i32, mode: i32): i32 {
  if (path == 0) {
    return -1;
  }
  unsafe {
    return xlang_sys_open(path, flags, mode);
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function linux_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 || buf == 0 || cap <= 0) {
    return -1;
  }
  let fd: i32 = 0;
  unsafe {
    fd = xlang_sys_open(path, LINUX_O_RDONLY, 0);
  }
  if (fd < 0) {
    return -1;
  }
  let total: i32 = 0;
  while (total < cap) {
    let chunk: i32 = cap - total;
    let dst: *u8 = (buf as *u8) + total;
    let r: i32 = 0;
    unsafe {
      r = xlang_sys_read(fd, dst, chunk as usize) as i32;
    }
    if (r < 0) {
      linux_syscall_close(fd);
      return -1;
    }
    if (r == 0) {
      break;
    }
    total = total + r;
  }
  linux_syscall_close(fd);
  return total;
}

/** AF_INET（IPv4）。 */
export const LINUX_AF_INET: i32 = 2;

/** SOCK_STREAM（TCP）。 */
export const LINUX_SOCK_STREAM: i32 = 1;

/** SOCK_DGRAM（UDP）。 */
export const LINUX_SOCK_DGRAM: i32 = 2;

/**
 * See implementation.
 */
export function linux_syscall_socket(domain: i32, sock_type: i32, protocol: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_sys_socket(domain, sock_type, protocol); }
  return _rc;
}

/**
 * See implementation.
 */
export function linux_syscall_connect(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  if (addr == 0 || addrlen <= 0) {
    return -1;
  }
  unsafe {
    return xlang_sys_connect(sockfd, addr, addrlen);
  }
}

/**
 * See implementation.
 */
export function linux_syscall_bind(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  if (addr == 0 || addrlen <= 0) {
    return -1;
  }
  unsafe {
    return xlang_sys_bind(sockfd, addr, addrlen);
  }
}

/**
 * See implementation.
 */
export function linux_syscall_listen(sockfd: i32, backlog: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_sys_listen(sockfd, backlog); }
  return _rc;
}

/**
 * See implementation.
 */
export function linux_syscall_accept(sockfd: i32, addr: *u8, addrlen: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_sys_accept(sockfd, addr, addrlen); }
  return _rc;
}

/** Linux open(2) O_RDWR。 */
export const LINUX_O_RDWR: i32 = 2;

/** Linux open(2) O_CREAT。 */
export const LINUX_O_CREAT: i32 = 64;

/** mmap(2) MAP_SHARED。 */
export const LINUX_MAP_SHARED: i32 = 1;

/** lseek(2) SEEK_END。 */
export const LINUX_SEEK_END: i32 = 2;

/** msync(2) MS_SYNC。 */
export const LINUX_MS_SYNC: i32 = 4;

/* See implementation. */
export const LINUX_OPEN_MODE_0644: i32 = 420;

/* See implementation. */
#[cfg(not(freestanding))]
extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
#[cfg(not(freestanding))]
extern "C" function close(fd: i32): i32;
#[cfg(not(freestanding))]
extern "C" function lseek(fd: i32, offset: i64, whence: i32): i64;
#[cfg(not(freestanding))]
extern "C" function ftruncate(fd: i32, length: i64): i32;
#[cfg(not(freestanding))]
extern "C" function mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8;
#[cfg(not(freestanding))]
extern "C" function munmap(addr: *u8, len: usize): i32;
#[cfg(not(freestanding))]
extern "C" function msync(addr: *u8, len: usize, flags: i32): i32;

/**
 * See implementation.
 * See implementation.
 *
 * See implementation.
 * See implementation.
 * See implementation.
 */
#[cfg(not(freestanding))]
export function linux_mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0 || min_size == 0) {
    return 0 as *u8;
  }
  unsafe {
    let flags: i32 = LINUX_O_RDWR | LINUX_O_CREAT;
    let fd: i32 = open(path, flags, LINUX_OPEN_MODE_0644);
    if (fd < 0) {
      return 0 as *u8;
    }
    let cur: i64 = lseek(fd, 0 as i64, LINUX_SEEK_END);
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
    let prot: i32 = LINUX_PROT_READ | LINUX_PROT_WRITE;
    let p: *u8 = mmap(0 as *u8, len, prot, LINUX_MAP_SHARED, fd, 0 as i64);
    close(fd);
    let p_i: i64 = p as i64;
    if (p_i <= 0) {
      return 0 as *u8;
    }
    out_size[0] = len;
    return p;
  }
}

/** Exported function `linux_munmap`.
 * Implements `linux_munmap`.
 * @param addr *u8
 * @param len usize
 * @return i32
 */
#[cfg(not(freestanding))]
export function linux_munmap(addr: *u8, len: usize): i32 {
  if (addr == 0 || len == 0) {
    return -1;
  }
  unsafe {
    return munmap(addr, len);
  }
}

/** Exported function `linux_msync_sync`.
 * Implements `linux_msync_sync`.
 * @param addr *u8
 * @param len usize
 * @return i32
 */
#[cfg(not(freestanding))]
export function linux_msync_sync(addr: *u8, len: usize): i32 {
  if (addr == 0 || len == 0) {
    return -1;
  }
  unsafe {
    return msync(addr, len, LINUX_MS_SYNC);
  }
}

/** Exported function `linux_mmap_file_available`.
 * Implements `linux_mmap_file_available`.
 * @return i32
 */
export function linux_mmap_file_available(): i32 {
  return 1;
}

/** Exported function `linux_sys_module_anchor`.
 * Implements `linux_sys_module_anchor`.
 * @return i32
 */
export function linux_sys_module_anchor(): i32 {
  return 0;
}
