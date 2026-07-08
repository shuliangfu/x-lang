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

// std.sys.linux — Linux 系统调用号表 + freestanding invoke（BOOT-029 v1 / B-14 v1）
//
// 【文件职责】
// 为自举 freestanding 路径提供 Linux x86_64 / aarch64 常用 syscall 常量，
// 与 compiler/src/asm/freestanding_io_x86_64.s 中 write(2)=1 保持一致。
// B-14 v1：x86_64 经 extern 链 freestanding_io_x86_64.s（read/close/exit/write）。
//
// 【参考】
// - Linux x86_64: arch/x86/entry/syscalls/syscall_64.tbl
// - Linux arm64:  include/uapi/asm-generic/unistd.h

/** freestanding open(2) 桩（x86_64 legacy open，flags/mode 见 rdi/rsi/rdx）。 */
extern function shux_sys_open(path: *u8, flags: i32, mode: i32): i32;

/** freestanding read(2) 桩（x86_64 freestanding_io_x86_64.s）。 */
extern function shux_sys_read(fd: i32, buf: *u8, len: i32): i32;

/** freestanding close(2) 桩。 */
extern function shux_sys_close(fd: i32): i32;

/** freestanding exit(2) 桩（noreturn）。 */
extern function shux_sys_exit(code: i32): void;

/** freestanding write(2) 桩。 */
extern function shux_sys_write(fd: i32, buf: *u8, len: i32): i32;

/** freestanding openat(2) 桩（x86_64 syscall 257）。 */
extern function shux_sys_openat(dirfd: i32, path: *u8, flags: i32, mode: i32): i32;

/** freestanding mmap(2) 桩（6 参；offset 低 32 位在 r9）。 */
extern function shux_sys_mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8;

/** freestanding munmap(2) 桩；成功 0，失败负 errno。 */
extern function shux_sys_munmap(addr: *u8, len: usize): i32;

/** freestanding socket(2) 桩（x86_64 syscall 41）。 */
extern function shux_sys_socket(domain: i32, sock_type: i32, protocol: i32): i32;

/** freestanding connect(2) 桩（syscall 42）。 */
extern function shux_sys_connect(sockfd: i32, addr: *u8, addrlen: i32): i32;

/** freestanding accept(2) 桩（syscall 43）。 */
extern function shux_sys_accept(sockfd: i32, addr: *u8, addrlen: *i32): i32;

/** freestanding bind(2) 桩（syscall 49）。 */
extern function shux_sys_bind(sockfd: i32, addr: *u8, addrlen: i32): i32;

/** freestanding listen(2) 桩（syscall 50）。 */
extern function shux_sys_listen(sockfd: i32, backlog: i32): i32;

// --- x86_64（System V AMD64 ABI：rax=nr, rdi/rsi/rdx/...=args）---

/** Linux x86_64 read(2) 系统调用号。 */
function syscall_nr_read_amd64(): i64 {
  return 0;
}

/** Linux x86_64 write(2) 系统调用号（freestanding_io_x86_64.s 使用）。 */
function syscall_nr_write_amd64(): i64 {
  return 1;
}

/** Linux x86_64 open(2) 系统调用号。 */
function syscall_nr_open_amd64(): i64 {
  return 2;
}

/** Linux x86_64 close(2) 系统调用号。 */
function syscall_nr_close_amd64(): i64 {
  return 3;
}

/** Linux x86_64 exit(2) 系统调用号。 */
function syscall_nr_exit_amd64(): i64 {
  return 60;
}

/** Linux x86_64 mmap(2) 系统调用号。 */
function syscall_nr_mmap_amd64(): i64 {
  return 9;
}

// --- aarch64（AAPCS64：x8=nr, x0-x5=args）---

/** Linux aarch64 read(2) 系统调用号。 */
function syscall_nr_read_arm64(): i64 {
  return 63;
}

/** Linux aarch64 write(2) 系统调用号。 */
function syscall_nr_write_arm64(): i64 {
  return 64;
}

/** Linux aarch64 openat(2) 系统调用号（arm64 无 legacy open）。 */
function syscall_nr_openat_arm64(): i64 {
  return 56;
}

/** Linux aarch64 close(2) 系统调用号。 */
function syscall_nr_close_arm64(): i64 {
  return 57;
}

/** Linux aarch64 exit(2) 系统调用号。 */
function syscall_nr_exit_arm64(): i64 {
  return 93;
}

/** Linux aarch64 mmap(2) 系统调用号。 */
function syscall_nr_mmap_arm64(): i64 {
  return 222;
}

/**
 * v1 探测：mod 是否导出 Linux syscall 号表（恒 1）。
 * 与 freestanding_write_available 对称，供 gate / 文档引用。
 */
function linux_syscall_table_available(): i32 {
  return 1;
}

/**
 * B-14 v1：freestanding syscall invoke 是否在 x86_64 可用（恒 1；arm64 桩待补）。
 */
function linux_syscall_invoke_available(): i32 {
  return 1;
}

/**
 * Linux read(2) freestanding 薄封装；len<=0 返回 0，buf 空返回 -1。
 */
function linux_syscall_read(fd: i32, buf: *u8, len: i32): i32 {
  if (len <= 0) {
    return 0;
  }
  if (buf == 0) {
    return -1;
  }
  unsafe {
    return shux_sys_read(fd, buf, len);
  }
}

/**
 * Linux close(2) freestanding 薄封装。
 */
function linux_syscall_close(fd: i32): i32 {
  unsafe {
    return shux_sys_close(fd);
  }
}

/**
 * Linux write(2) freestanding 薄封装（与 mod.shux_sys_write 等价，供 linux 子模块直调）。
 */
function linux_syscall_write(fd: i32, buf: *u8, len: i32): i32 {
  if (len <= 0) {
    return 0;
  }
  if (buf == 0) {
    return -1;
  }
  unsafe {
    return shux_sys_write(fd, buf, len);
  }
}

/**
 * Linux exit(2) freestanding；进程结束，不返回。
 */
function linux_syscall_exit(code: i32): void {
  unsafe {
    shux_sys_exit(code);
  }
}

/** Linux open(2) O_RDONLY 标志。 */
const LINUX_O_RDONLY: i32 = 0;

/** openat(2) AT_FDCWD：相对当前工作目录。 */
const LINUX_AT_FDCWD: i32 = -100;

/** mmap(2) MAP_PRIVATE。 */
const LINUX_MAP_PRIVATE: i32 = 2;

/** mmap(2) MAP_ANONYMOUS（无文件 backing）。 */
const LINUX_MAP_ANONYMOUS: i32 = 0x20;

/** mmap(2) PROT_READ。 */
const LINUX_PROT_READ: i32 = 1;

/** mmap(2) PROT_WRITE。 */
const LINUX_PROT_WRITE: i32 = 2;

/**
 * Linux openat(2) freestanding 薄封装。
 */
function linux_syscall_openat(dirfd: i32, path: *u8, flags: i32, mode: i32): i32 {
  if (path == 0) {
    return -1;
  }
  unsafe {
    return shux_sys_openat(dirfd, path, flags, mode);
  }
}

/**
 * B-14 v3：匿名 mmap（MAP_PRIVATE|MAP_ANONYMOUS）；失败返回 null。
 */
function linux_anonymous_mmap(len: usize, prot: i32, flags: i32): *u8 {
  if (len == 0) {
    return 0;
  }
  unsafe {
    return shux_sys_mmap(0 as *u8, len, prot, flags, -1, 0 as i64);
  }
}

/**
 * Linux munmap(2) freestanding 薄封装。
 */
function linux_syscall_munmap(addr: *u8, len: usize): i32 {
  if (addr == 0 || len == 0) {
    return -1;
  }
  unsafe {
    return shux_sys_munmap(addr, len);
  }
}

/**
 * B-14 v3：openat + 循环 read 读文件到 buf[0..cap)（与 linux_read_file_into 等价语义）。
 */
function linux_read_file_openat(dirfd: i32, path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 || buf == 0 || cap <= 0) {
    return -1;
  }
  let fd: i32 = 0;
  unsafe {
    fd = shux_sys_openat(dirfd, path, LINUX_O_RDONLY, 0);
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
      r = shux_sys_read(fd, dst, chunk);
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
 * Linux open(2) freestanding 薄封装。
 */
function linux_syscall_open(path: *u8, flags: i32, mode: i32): i32 {
  if (path == 0) {
    return -1;
  }
  unsafe {
    return shux_sys_open(path, flags, mode);
  }
}

/**
 * B-20 v1：读整文件到 buf[0..cap)（循环 read 直到 EOF 或 cap）。
 * 成功返回读入字节数；失败返回 -1。
 */
function linux_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 || buf == 0 || cap <= 0) {
    return -1;
  }
  let fd: i32 = 0;
  unsafe {
    fd = shux_sys_open(path, LINUX_O_RDONLY, 0);
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
      r = shux_sys_read(fd, dst, chunk);
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
const LINUX_AF_INET: i32 = 2;

/** SOCK_STREAM（TCP）。 */
const LINUX_SOCK_STREAM: i32 = 1;

/** SOCK_DGRAM（UDP）。 */
const LINUX_SOCK_DGRAM: i32 = 2;

/**
 * Linux socket(2) freestanding 薄封装。
 */
function linux_syscall_socket(domain: i32, sock_type: i32, protocol: i32): i32 {
  unsafe {
    return shux_sys_socket(domain, sock_type, protocol);
  }
}

/**
 * Linux connect(2) freestanding 薄封装。
 */
function linux_syscall_connect(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  if (addr == 0 || addrlen <= 0) {
    return -1;
  }
  unsafe {
    return shux_sys_connect(sockfd, addr, addrlen);
  }
}

/**
 * Linux bind(2) freestanding 薄封装。
 */
function linux_syscall_bind(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  if (addr == 0 || addrlen <= 0) {
    return -1;
  }
  unsafe {
    return shux_sys_bind(sockfd, addr, addrlen);
  }
}

/**
 * Linux listen(2) freestanding 薄封装。
 */
function linux_syscall_listen(sockfd: i32, backlog: i32): i32 {
  unsafe {
    return shux_sys_listen(sockfd, backlog);
  }
}

/**
 * Linux accept(2) freestanding 薄封装。
 */
function linux_syscall_accept(sockfd: i32, addr: *u8, addrlen: *i32): i32 {
  unsafe {
    return shux_sys_accept(sockfd, addr, addrlen);
  }
}

/** Linux open(2) O_RDWR。 */
const LINUX_O_RDWR: i32 = 2;

/** Linux open(2) O_CREAT。 */
const LINUX_O_CREAT: i32 = 64;

/** mmap(2) MAP_SHARED。 */
const LINUX_MAP_SHARED: i32 = 1;

/** lseek(2) SEEK_END。 */
const LINUX_SEEK_END: i32 = 2;

/** msync(2) MS_SYNC。 */
const LINUX_MS_SYNC: i32 = 4;

/** open(2) O_CREAT 默认 mode 0644。 */
const LINUX_OPEN_MODE_0644: i32 = 420;

/** Hosted Linux：libc open/ftruncate/lseek/mmap（常规 -o exe 链 libc；F-02 v1 替代 mmap.inc.c）。 */
extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
extern "C" function close(fd: i32): i32;
extern "C" function lseek(fd: i32, offset: i64, whence: i32): i64;
extern "C" function ftruncate(fd: i32, length: i64): i32;
extern "C" function mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8;
extern "C" function munmap(addr: *u8, len: usize): i32;
extern "C" function msync(addr: *u8, len: usize, flags: i32): i32;

/**
 * F-02 v1：文件 MAP_SHARED 可写 mmap（open + ftruncate + mmap；无 mmap.inc.c）。
 * path NUL 结尾；不足 min_size 时扩展文件；*out_size 写回映射字节数。
 */
function linux_mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0 || min_size == 0) {
    return 0;
  }
  unsafe {
    let flags: i32 = LINUX_O_RDWR | LINUX_O_CREAT;
    let fd: i32 = open(path, flags, LINUX_OPEN_MODE_0644);
    if (fd < 0) {
      return 0;
    }
    let cur: i64 = lseek(fd, 0 as i64, LINUX_SEEK_END);
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
    let prot: i32 = LINUX_PROT_READ | LINUX_PROT_WRITE;
    let p: *u8 = mmap(0 as *u8, len, prot, LINUX_MAP_SHARED, fd, 0 as i64);
    close(fd);
    let p_i: i64 = p as i64;
    if (p_i <= 0) {
      return 0;
    }
    out_size[0] = len;
    return p;
  }
}

/** 解除 libc mmap；0 成功，-1 失败（F-02 v1 文件映射路径）。 */
function linux_munmap(addr: *u8, len: usize): i32 {
  if (addr == 0 || len == 0) {
    return -1;
  }
  unsafe {
    return munmap(addr, len);
  }
}

/** msync 刷盘（MS_SYNC）；0 成功，-1 失败。 */
function linux_msync_sync(addr: *u8, len: usize): i32 {
  if (addr == 0 || len == 0) {
    return -1;
  }
  unsafe {
    return msync(addr, len, LINUX_MS_SYNC);
  }
}

/** F-02 v1 探测：Linux 文件 mmap 是否在子模块导出（恒 1）。 */
function linux_mmap_file_available(): i32 {
  return 1;
}

/** 模块尾占位：transitive import 解析锚点。 */
function linux_sys_module_anchor(): i32 {
  return 0;
}
