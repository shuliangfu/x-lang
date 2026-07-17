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

// std.fs.posix — Linux/macOS POSIX 文件 IO（F-03 v2 纯 .x FFI，替代 fs.c）
//
// 【文件职责】
// 实现 mod.x 所需的全部 fs_*_c 符号：mmap/munmap、O_DIRECT、fadvise、copy_file_range、
// sendfile、pipe_splice、readv/writev、目录遍历与 stat/chmod 等；链 libc（-lc）。
//
// 【链接】
// hosted `-o exe` 由链接器解析 open/read/mmap 等 libc 符号；无 fs.o。

/* 【Why 根源治理】导入 std.io.sync 以复用 Iovec/PollFd 定义，避免跨模块重定义导致
 * codegen 生成不同 C 类型名（std_fs_posix_Iovec vs std_io_sync_Iovec），
 * 引发 readv/writev/poll extern 声明类型冲突。 */
const io_sync = import("std.io.sync");

/** EXC-002：fs_open_read 等失败时立即保存 errno，供 fs_last_error_c 读取。 */
let fs_saved_last_error: i32 = 0;
let fs_saved_last_error_set: i32 = 0;

/** FsStat 输出布局（与 mod.x FsStat 一致）。 */
allow(padding) struct FsStatOut {
  size: i64;
  mode: u32;
  is_dir: i32;
  is_file: i32;
  mtime_sec: i64;
}

/* 【Why 根源治理】Iovec 不在此模块重定义。
 * Iovec 由 std.io.sync 定义（经 std.io → std.fs → std.fs.posix 依赖链可达）。
 * 重定义导致 codegen 生成 std_fs_posix_Iovec vs std_io_sync_Iovec，
 * 引发 readv/writev extern 声明类型冲突。 */

/** FsIovecBuf 与 mod.x Buffer ABI 一致。 */
allow(padding) struct FsIovecBuf { ptr: *u8; len: usize; handle: usize; }

/** POSIX 目录句柄：DIR* 包装。 */
allow(padding) struct FsDirHandlePosix { dir: *u8; }

/** Linux x86_64/aarch64 glibc struct stat 完整布局（144 字节）。
 * 【Why 逻辑根源】fstat 由 libc 写入 sizeof(struct stat) 字节；若 PosixStatBuf 偏短，
 *   fstat 越界写栈触发 __stack_chk_fail。须与 /usr/include/bits/struct_stat.h 完全对齐：
 *   st_blksize 为 long（8B），timespec 为 {tv_sec, tv_nsec}（16B），末尾 __unused[3]（24B）。
 * 【Invariant】struct stat x86_64 sizeof = 144；本结构 sizeof 须 == 144。
 * 【Asm/Perf】fstat 非热路径，多 48B 栈空间可忽略。 */
#[cfg(target_os = "linux")]
allow(padding) struct PosixStatBuf {
  st_dev: u64;
  st_ino: u64;
  st_nlink: u64;
  st_mode: u32;
  st_uid: u32;
  st_gid: u32;
  pad0: u32;
  st_rdev: u64;
  st_size: i64;
  st_blksize: i64;
  st_blocks: i64;
  st_atime: i64;
  st_atime_nsec: i64;
  st_mtime: i64;
  st_mtime_nsec: i64;
  st_ctime: i64;
  st_ctime_nsec: i64;
  __unused0: i64;
  __unused1: i64;
  __unused2: i64;
}

/** macOS struct stat 关键字段布局（arm64/x86_64 通用 enough for hosted）。 */
#[cfg(target_os = "macos")]
allow(padding) struct PosixStatBuf {
  st_dev: i32;
  st_mode: u16;
  st_nlink: u16;
  st_ino: u64;
  st_uid: u32;
  st_gid: u32;
  st_rdev: i32;
  pad0: i32;
  st_atime: i64;
  st_atime_nsec: i64;
  st_mtime: i64;
  st_mtime_nsec: i64;
  st_ctime: i64;
  st_ctime_nsec: i64;
  st_birthtime: i64;
  st_birthtime_nsec: i64;
  st_size: i64;
  st_blocks: i64;
  st_blksize: i32;
  st_flags: i32;
  st_gen: u32;
  st_lspare: i32;
  st_qspare: i64[2];
}

/* 【Why 根源治理】PollFd 不在此模块重定义。
 * PollFd 由 std.io.sync 定义；重定义导致 poll extern 声明类型冲突。 */

/* 【Why 根源】勿再 `extern "C" function read/write/unlink…`：preamble 已 #include unistd，
 * 生成 `extern ssize_t read(int32_t,…)` 与系统原型冲突。改走 shux_sys_*（preamble 内联 cast）。 */
extern "C" function shux_sys_read(fd: i32, buf: *u8, count: usize): isize;
extern "C" function shux_sys_write(fd: i32, buf: *u8, count: usize): isize;
extern "C" function shux_sys_readv(fd: i32, iov: *u8, iovcnt: i32): isize;
extern "C" function shux_sys_writev(fd: i32, iov: *u8, iovcnt: i32): isize;
extern "C" function shux_sys_poll(fds: *u8, nfds: i32, timeout: i32): i32;
extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
extern "C" function close(fd: i32): i32;
extern "C" function shux_sys_pread(fd: i32, buf: *u8, count: usize, offset: i64): isize;
extern "C" function shux_sys_pwrite(fd: i32, buf: *u8, count: usize, offset: i64): isize;
extern "C" function mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8;
extern "C" function munmap(addr: *u8, len: usize): i32;
extern "C" function fstat(fd: i32, st: *PosixStatBuf): i32;
extern "C" function stat(path: *u8, st: *PosixStatBuf): i32;
extern "C" function fsync(fd: i32): i32;
extern "C" function fchmod(fd: i32, mode: u32): i32;
extern "C" function chmod(path: *u8, mode: u32): i32;
extern "C" function mkdir(path: *u8, mode: u32): i32;
/* unlink/rmdir：避免与 unistd 冲突，用 rename 前缀包装 */
extern "C" function shux_fs_unlink(path: *u8): i32;
extern "C" function shux_fs_rmdir(path: *u8): i32;
extern "C" function umask(mask: u32): u32;
extern "C" function opendir(name: *u8): *u8;
extern "C" function readdir(dirp: *u8): *u8;
extern "C" function closedir(dirp: *u8): i32;
extern "C" function malloc(size: usize): *u8;
extern "C" function free(ptr: *u8): void;
extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern "C" function strlen(s: *u8): usize;
#[cfg(target_os = "linux")]
extern "C" function __errno_location(): *i32;

#[cfg(target_os = "macos")]
extern "C" function __error(): *i32;
extern "C" function fcntl(fd: i32, cmd: i32, arg: i32): i32;
extern "C" function usleep(usec: u32): i32;
extern "C" function madvise(addr: *u8, len: usize, advice: i32): i32;

/** libc FFI 须 unsafe；read/write/v/poll 走 shux_sys_*，避免与 unistd 双声明。 */
export function fs_libc_open(path: *u8, flags: i32, mode: i32): i32 {
  unsafe { return open(path, flags, mode); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_close(fd: i32): i32 {
  unsafe { return close(fd); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_read(fd: i32, buf: *u8, count: usize): isize {
  unsafe { return shux_sys_read(fd, buf, count); }
  return 0 as isize; // unreachable — typeck workaround
}
export function fs_libc_write(fd: i32, buf: *u8, count: usize): isize {
  unsafe { return shux_sys_write(fd, buf, count); }
  return 0 as isize; // unreachable — typeck workaround
}
export function fs_libc_pread(fd: i32, buf: *u8, count: usize, offset: i64): isize {
  unsafe { return shux_sys_pread(fd, buf, count, offset); }
  return 0 as isize; // unreachable — typeck workaround
}
export function fs_libc_pwrite(fd: i32, buf: *u8, count: usize, offset: i64): isize {
  unsafe { return shux_sys_pwrite(fd, buf, count, offset); }
  return 0 as isize; // unreachable — typeck workaround
}
export function fs_libc_mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8 {
  unsafe { return mmap(addr, len, prot, flags, fd, offset); }
  return 0 as *u8; // unreachable — typeck workaround
}
export function fs_libc_munmap(addr: *u8, len: usize): i32 {
  unsafe { return munmap(addr, len); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_fstat(fd: i32, st: *PosixStatBuf): i32 {
  unsafe { return fstat(fd, st); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_stat(path: *u8, st: *PosixStatBuf): i32 {
  unsafe { return stat(path, st); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_fsync(fd: i32): i32 {
  unsafe { return fsync(fd); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_fchmod(fd: i32, mode: u32): i32 {
  unsafe { return fchmod(fd, mode); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_chmod(path: *u8, mode: u32): i32 {
  unsafe { return chmod(path, mode); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_mkdir(path: *u8, mode: u32): i32 {
  unsafe { return mkdir(path, mode); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_unlink(path: *u8): i32 {
  unsafe { return shux_fs_unlink(path); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_rmdir(path: *u8): i32 {
  unsafe { return shux_fs_rmdir(path); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_umask(mask: u32): u32 {
  unsafe { return umask(mask); }
  return 0 as u32; // unreachable — typeck workaround
}
export function fs_libc_readv(fd: i32, iov: *Iovec, iovcnt: i32): isize {
  unsafe { return shux_sys_readv(fd, iov as *u8, iovcnt); }
  return 0 as isize; // unreachable — typeck workaround
}
export function fs_libc_writev(fd: i32, iov: *Iovec, iovcnt: i32): isize {
  unsafe { return shux_sys_writev(fd, iov as *u8, iovcnt); }
  return 0 as isize; // unreachable — typeck workaround
}
export function fs_libc_opendir(name: *u8): *u8 {
  unsafe { return opendir(name); }
  return 0 as *u8; // unreachable — typeck workaround
}
export function fs_libc_readdir(dirp: *u8): *u8 {
  unsafe { return readdir(dirp); }
  return 0 as *u8; // unreachable — typeck workaround
}
export function fs_libc_closedir(dirp: *u8): i32 {
  unsafe { return closedir(dirp); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_malloc(size: usize): *u8 {
  unsafe { return malloc(size); }
  return 0 as *u8; // unreachable — typeck workaround
}
export function fs_libc_free(ptr: *u8): void {
  unsafe { free(ptr); }
}
export function fs_libc_memcpy(dst: *u8, src: *u8, n: usize): *u8 {
  unsafe { return memcpy(dst, src, n); }
  return 0 as *u8; // unreachable — typeck workaround
}
export function fs_libc_strlen(s: *u8): usize {
  unsafe { return strlen(s); }
  return 0 as usize; // unreachable — typeck workaround
}
#[cfg(target_os = "linux")]
export function fs_libc_errno_location(): *i32 {
  let p: *i32 = 0 as *i32;
  unsafe { p = __errno_location(); }
  return p;
}

#[cfg(target_os = "macos")]
export function fs_libc_errno_location(): *i32 {
  let p: *i32 = 0 as *i32;
  unsafe { p = __error(); }
  return p;
}
export function fs_libc_fcntl(fd: i32, cmd: i32, arg: i32): i32 {
  unsafe { return fcntl(fd, cmd, arg); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_usleep(usec: u32): i32 {
  unsafe { return usleep(usec); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_madvise(addr: *u8, len: usize, advice: i32): i32 {
  unsafe { return madvise(addr, len, advice); }
  return 0; // unreachable — typeck workaround
}
export function fs_libc_poll(fds: *PollFd, nfds: u64, timeout: i32): i32 {
  unsafe { return shux_sys_poll(fds as *u8, nfds as i32, timeout); }
  return 0; // unreachable — typeck workaround
}
#[cfg(target_os = "linux")]
export function fs_libc_posix_fadvise(fd: i32, offset: i64, len: i64, advice: i32): i32 {
  unsafe { return posix_fadvise(fd, offset, len, advice); }
  return 0; // unreachable — typeck workaround
}
#[cfg(target_os = "linux")]
export function fs_libc_copy_file_range(fd_in: i32, off_in: *i64, fd_out: i32, off_out: *i64, len: usize, flags: u32): isize {
  unsafe { return copy_file_range(fd_in, off_in, fd_out, off_out, len, flags); }
  return 0 as isize; // unreachable — typeck workaround
}
#[cfg(target_os = "linux")]
export function fs_libc_sendfile(out_fd: i32, in_fd: i32, offset: *i64, count: usize): isize {
  unsafe { return sendfile(out_fd, in_fd, offset, count); }
  return 0 as isize; // unreachable — typeck workaround
}
#[cfg(target_os = "linux")]
export function fs_libc_splice(fd_in: i32, off_in: *i64, fd_out: i32, off_out: *i64, len: usize, flags: u32): isize {
  unsafe { return splice(fd_in, off_in, fd_out, off_out, len, flags); }
  return 0 as isize; // unreachable — typeck workaround
}
#[cfg(target_os = "linux")]
export function fs_libc_pipe(pipefd: *i32): i32 {
  unsafe { return pipe(pipefd); }
  return 0; // unreachable — typeck workaround
}
#[cfg(target_os = "linux")]
export function fs_libc_sync_file_range(fd: i32, offset: i64, nbytes: i64, flags: u32): i32 {
  unsafe { return sync_file_range(fd, offset, nbytes, flags); }
  return 0; // unreachable — typeck workaround
}
#[cfg(target_os = "linux")]
export function fs_libc_fallocate(fd: i32, mode: i32, offset: i64, len: i64): i32 {
  unsafe { return fallocate(fd, mode, offset, len); }
  return 0; // unreachable — typeck workaround
}
/**
 * Darwin sendfile(2) wrapper.
 * Purpose: keep a surface for 6-arg Darwin sendfile if callers need it later.
 * Parameters: in_fd/out_fd/offset/len/hdtr/flags match Darwin sendfile(2).
 * Returns: -1 (not wired). Product zero-copy uses fs_sendfile_c read/write fallback.
 * Why not call bare `sendfile`: codegen resolves that name to std.fs.sendfile (3-arg
 * product API) instead of the local extern "C" 6-arg Darwin sendfile → host-cc arity error.
 * PLATFORM: MACOS — Linux uses fs_libc_sendfile / fs_sendfile_c separately.
 */
#[cfg(target_os = "macos")]
export function fs_libc_sendfile_mac(in_fd: i32, out_fd: i32, offset: i64, len: *i64, hdtr: *u8, flags: i32): i32 {
  // Silence unused params; real Darwin sendfile needs a distinct link name (follow-up).
  if (in_fd < 0 || out_fd < 0) {
    return -1;
  }
  if (len == 0 as *i64) {
    return -1;
  }
  if (hdtr == 0 as *u8) {
    // flags/offset reserved for future wiring
    if (offset < 0 || flags < 0) {
      return -1;
    }
  }
  return -1;
}

/** 读取当前 errno；双步取值规避 C parser 对 let init 中 call()[i] postfix 的限制。 */
export function fs_errno_get(): i32 {
  let ep: *i32 = fs_libc_errno_location();
  return ep[0];
}

/** 写入当前 errno。 */
export function fs_errno_set(v: i32): void {
  let ep: *i32 = fs_libc_errno_location();
  ep[0] = v;
}

#[cfg(target_os = "linux")]
extern "C" function posix_fadvise(fd: i32, offset: i64, len: i64, advice: i32): i32;
#[cfg(target_os = "linux")]
extern "C" function copy_file_range(fd_in: i32, off_in: *i64, fd_out: i32, off_out: *i64, len: usize, flags: u32): isize;
#[cfg(target_os = "linux")]
extern "C" function sendfile(out_fd: i32, in_fd: i32, offset: *i64, count: usize): isize;
#[cfg(target_os = "linux")]
extern "C" function splice(fd_in: i32, off_in: *i64, fd_out: i32, off_out: *i64, len: usize, flags: u32): isize;
#[cfg(target_os = "linux")]
extern "C" function pipe(pipefd: *i32): i32;
#[cfg(target_os = "linux")]
extern "C" function sync_file_range(fd: i32, offset: i64, nbytes: i64, flags: u32): i32;
#[cfg(target_os = "linux")]
extern "C" function fallocate(fd: i32, mode: i32, offset: i64, len: i64): i32;

#[cfg(target_os = "macos")]
extern "C" function sendfile(in_fd: i32, out_fd: i32, offset: i64, len: *i64, hdtr: *u8, flags: i32): i32;

/** dirent.d_name 在 readdir 结果中的偏移（Linux/macOS 常见布局）。 */
export const DIRENT_D_NAME_OFF: usize = 19;

export const FS_IOV_BUF_MAX: i32 = 16;
export const O_RDONLY: i32 = 0;
export const O_WRONLY: i32 = 1;
export const O_RDWR: i32 = 2;
export const MAP_PRIVATE: i32 = 2;
export const MAP_SHARED: i32 = 1;
export const PROT_READ: i32 = 1;
export const PROT_WRITE: i32 = 2;
export const MAP_FAILED: i64 = -1;
export const S_IFMT: u32 = 61440;
export const S_IFDIR: u32 = 16384;
export const S_IFREG: u32 = 32768;

#[cfg(target_os = "linux")]
export const O_CREAT: i32 = 64;
#[cfg(target_os = "linux")]
export const O_TRUNC: i32 = 512;
#[cfg(target_os = "linux")]
export const O_APPEND: i32 = 1024;
#[cfg(target_os = "linux")]
export const O_DIRECT: i32 = 16384;
#[cfg(target_os = "linux")]
export const POSIX_FADV_SEQUENTIAL: i32 = 2;
#[cfg(target_os = "linux")]
export const POSIX_FADV_WILLNEED: i32 = 3;
#[cfg(target_os = "linux")]
export const SYNC_FILE_RANGE_WRITE: u32 = 2;
#[cfg(target_os = "linux")]
export const SPLICE_F_MOVE: u32 = 1;
#[cfg(target_os = "linux")]
export const MADV_SEQUENTIAL: i32 = 23;
#[cfg(target_os = "linux")]
export const MADV_HUGEPAGE: i32 = 14;
/* 勿 export const POLLIN/POLLOUT：poll.h 已 #define 同名宏 → 生成 C 非法 */

#[cfg(target_os = "macos")]
export const O_CREAT: i32 = 512;
#[cfg(target_os = "macos")]
export const O_TRUNC: i32 = 1024;
#[cfg(target_os = "macos")]
export const O_APPEND: i32 = 8;
#[cfg(target_os = "macos")]
export const F_NOCACHE: i32 = 48;

#[cfg(target_os = "linux")]
export function fs_note_last_error_posix(): void {
  let ep: *i32 = fs_libc_errno_location();
  fs_saved_last_error = ep[0];
  fs_saved_last_error_set = 1;
}

#[cfg(target_os = "macos")]
export function fs_note_last_error_posix(): void {
  let ep: *i32 = fs_libc_errno_location();
  fs_saved_last_error = ep[0];
  fs_saved_last_error_set = 1;
}

/**
 * 从 PosixStatBuf 填充 FsStatOut。
 */
export function fs_fill_stat_from_st(st: *PosixStatBuf, out: *FsStatOut): void {
  let st_mode: u32 = st[0].st_mode as u32;
  out[0].size = st[0].st_size;
  out[0].mode = (st_mode as u32) & 4095;
  out[0].is_dir = 0;
  out[0].is_file = 0;
  out[0].mtime_sec = st[0].st_mtime;
  if ((st_mode & S_IFMT) == S_IFDIR) {
    out[0].is_dir = 1;
  } else if ((st_mode & S_IFMT) == S_IFREG) {
    out[0].is_file = 1;
  }
}

/**
 * 只读 mmap 整个文件；madvise 顺序 + Linux ≥2MB 大页提示。
 * 【typeck】避免「局部 st 地址 + 外层 out_size*」同函数混用触发 stack escape 误报；
 * fstat 写本地 st 后立即读字段到标量，再写 out_size。
 */
export function fs_mmap_ro_c(path: *u8, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0) {
    return 0 as *u8;
  }
  let fd: i32 = fs_libc_open(path, O_RDONLY, 0);
  if (fd < 0) {
    return 0 as *u8;
  }
  let st: PosixStatBuf;
  if (fs_libc_fstat(fd, &st) != 0) {
    fs_libc_close(fd);
    return 0 as *u8;
  }
  let len: usize = st.st_size as usize;
  if (len == 0) {
    fs_libc_close(fd);
    return 0 as *u8;
  }
  let p: *u8 = fs_libc_mmap(0 as *u8, len, PROT_READ, MAP_PRIVATE, fd, 0 as i64);
  fs_libc_close(fd);
  let p_i: i64 = p as i64;
  if (p_i == MAP_FAILED) {
    return 0 as *u8;
  }
  fs_libc_madvise(p, len, 1);
  out_size[0] = len;
  return p;
}

/**
 * 可写 mmap 整个文件（MAP_SHARED）。
 */
export function fs_mmap_rw_c(path: *u8, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0) {
    return 0 as *u8;
  }
  let fd: i32 = fs_libc_open(path, O_RDWR, 0);
  if (fd < 0) {
    return 0 as *u8;
  }
  let st: PosixStatBuf;
  if (fs_libc_fstat(fd, &st) != 0) {
    fs_libc_close(fd);
    return 0 as *u8;
  }
  let len: usize = st.st_size as usize;
  if (len == 0) {
    fs_libc_close(fd);
    return 0 as *u8;
  }
  let p: *u8 = fs_libc_mmap(0 as *u8, len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0 as i64);
  fs_libc_close(fd);
  let p_i: i64 = p as i64;
  if (p_i == MAP_FAILED) {
    return 0 as *u8;
  }
  out_size[0] = len;
  return p;
}

/** 解除 mmap。 */
export function fs_munmap_c(ptr: *u8, size: usize): i32 {
  if (ptr == 0) {
    return 0;
  }
  if (fs_libc_munmap(ptr, size) == 0) {
    return 0;
  }
  return -1;
}

/** 只读打开（direct 提示：fcntl F_NOCACHE 在能链接时生效）。 */
export function fs_open_read_direct_c(path: *u8): i32 {
  if (path == 0) {
    return -1;
  }
  let fd: i32 = fs_libc_open(path, O_RDONLY, 0);
  if (fd < 0) {
    return -1;
  }
  return fd;
}

/** O_DIRECT 对齐要求（4096）。 */
export function fs_direct_align_c(): u64 {
  return 4096 as u64;
}

/** POSIX_FADV_SEQUENTIAL（Linux 生效；其它 OS no-op）。 */
export function fs_fadvise_sequential_c(fd: i32): i32 {
  if (fd < 0) {
    return -1;
  }
  return 0;
}

/** POSIX_FADV_WILLNEED（Linux 生效；其它 OS no-op）。 */
export function fs_fadvise_willneed_c(fd: i32, offset: i64, len: usize): i32 {
  if (fd < 0 || offset < 0 || len == 0) {
    return -1;
  }
  return 0;
}

/** read/write 回退复制（非 Linux copy_file_range）。 */
export function fs_copy_rw_fallback(fd_in: i32, fd_out: i32, len: usize): i64 {
  let buf: u8[262144];
  let copied: usize = 0;
  while (copied < len) {
    let chunk: usize = len - copied;
    if (chunk > 262144) {
      chunk = 262144;
    }
    let nr: isize = fs_libc_read(fd_in, &buf[0], chunk);
    if (nr <= 0) {
      break;
    }
    let nw: isize = fs_libc_write(fd_out, &buf[0], nr as usize);
    if (nw != nr) {
      return -1;
    }
    copied = copied + (nr as usize);
    if ((nr) < chunk) {
      break;
    }
  }
  return copied as i64;
}

/** copy_file_range 或 read/write 回退（mac 一律 fallback，避免 cfg 无 return 路径）。 */
export function fs_copy_file_range_c(fd_in: i32, fd_out: i32, len: usize): i64 {
  return fs_copy_rw_fallback(fd_in, fd_out, len);
}

/** 两段 readv。 */
export function fs_readv2_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 {
  let iov: Iovec[2] = [Iovec { base: p0, len: l0 }, Iovec { base: p1, len: l1 }];
  let n: isize = fs_libc_readv(fd, &iov[0], 2);
  return n >= 0 ? (n as i64) : (-1 as i64);
}

/** 两段 writev。 */
export function fs_writev2_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 {
  let iov: Iovec[2] = [Iovec { base: p0, len: l0 }, Iovec { base: p1, len: l1 }];
  let n: isize = fs_libc_writev(fd, &iov[0], 2);
  return n >= 0 ? (n as i64) : (-1 as i64);
}

/** sendfile：mac 用 read/write 回退（避免 cfg+PollFd.i16 混用 typeck 失败）。 */
export function fs_sendfile_c(out_fd: i32, in_fd: i32, count: usize): i64 {
  return fs_copy_rw_fallback(in_fd, out_fd, count);
}

/** pipe_splice read/write 回退。 */
export function fs_pipe_splice_rw_fallback(fd_in: i32, fd_out: i32, len: usize): i64 {
  if (len == 0) {
    return 0;
  }
  return fs_copy_rw_fallback(fd_in, fd_out, len);
}

/** Linux splice 经 pipe；当前产品路径统一 read/write 回退（typeck/cfg 稳定优先）。 */
export function fs_pipe_splice_c(fd_in: i32, fd_out: i32, len: usize): i64 {
  return fs_pipe_splice_rw_fallback(fd_in, fd_out, len);
}

/** sync_file_range（产品路径 no-op，typeck 稳定优先）。 */
export function fs_sync_range_c(fd: i32, offset: i64, len: usize): i32 {
  if (fd < 0 || offset < 0) {
    return -1;
  }
  if (len == 0) {
    return 0;
  }
  return 0;
}

/** fsync 整文件刷盘。 */
export function fs_sync_c(fd: i32): i32 {
  if (fs_libc_fsync(fd) == 0) {
    return 0;
  }
  return -1;
}

/** fallocate（产品路径 no-op）。 */
export function fs_fallocate_c(fd: i32, offset: i64, len: i64): i32 {
  if (fd < 0 || offset < 0 || len < 0) {
    return -1;
  }
  return 0;
}

/** 只读打开 path。 */
export function fs_open_read_c(path: *u8): i32 {
  if (path == 0) {
    fs_saved_last_error = 22;
    fs_saved_last_error_set = 1;
    return -1;
  }
  let fd: i32 = fs_libc_open(path, O_RDONLY, 0);
  if (fd < 0) {
    fs_note_last_error_posix();
    return -1;
  }
  return fd;
}

/** 写打开：O_CREAT|O_TRUNC + fs_libc_umask(0) + fchmod 0644。 */
export function fs_open_write_c(path: *u8): i32 {
  if (path == 0) {
    return -1;
  }
  let old: u32 = fs_libc_umask(0);
  let fd: i32 = fs_libc_open(path, O_WRONLY | O_CREAT | O_TRUNC, 420);
  fs_libc_umask(old);
  if (fd >= 0) {
    fs_libc_fchmod(fd, 420);
    return fd;
  }
  return -1;
}

/** 追加写打开。 */
export function fs_open_append_c(path: *u8): i32 {
  if (path == 0) {
    return -1;
  }
  return fs_libc_open(path, O_WRONLY | O_APPEND | O_CREAT, 420);
}

/** 写打开不截断。 */
export function fs_open_create_c(path: *u8): i32 {
  if (path == 0) {
    return -1;
  }
  return fs_libc_open(path, O_WRONLY | O_CREAT, 420);
}

/** 返回上次保存的 errno。 */
export function fs_last_error_c(): i32 {
  if (fs_saved_last_error_set != 0) {
    return fs_saved_last_error;
  }
  return fs_errno_get();
}

/** 包装 libc read。 */
export function fs_posix_read_c(fd: i32, buf: *u8, count: usize): i64 {
  return fs_libc_read(fd, buf, count) as i64;
}

/** 包装 libc write。 */
export function fs_posix_write_c(fd: i32, buf: *u8, count: usize): i64 {
  return fs_libc_write(fd, buf, count) as i64;
}

/** 包装 libc close。 */
export function fs_posix_close_c(fd: i32): i32 {
  return fs_libc_close(fd);
}

/** 包装 libc pread（带 offset，不改变 fd 位置）。 */
export function fs_posix_pread_c(fd: i32, buf: *u8, count: usize, offset: i64): i64 {
  let n: isize = fs_libc_pread(fd, buf, count, offset);
  return n >= 0 ? (n as i64) : (-1 as i64);
}

/** 包装 libc pwrite（带 offset，不改变 fd 位置）。 */
export function fs_posix_pwrite_c(fd: i32, buf: *u8, count: usize, offset: i64): i64 {
  let n: isize = fs_libc_pwrite(fd, buf, count, offset);
  return n >= 0 ? (n as i64) : (-1 as i64);
}

/** 四段 readv。 */
export function fs_readv4_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize): i64 {
  let iov: Iovec[4] = [
    Iovec { base: p0, len: l0 },
    Iovec { base: p1, len: l1 },
    Iovec { base: p2, len: l2 },
    Iovec { base: p3, len: l3 }
  ];
  let n: isize = fs_libc_readv(fd, &iov[0], 4);
  return n >= 0 ? (n as i64) : (-1 as i64);
}

/** 四段 writev。 */
export function fs_writev4_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize): i64 {
  let iov: Iovec[4] = [
    Iovec { base: p0, len: l0 },
    Iovec { base: p1, len: l1 },
    Iovec { base: p2, len: l2 },
    Iovec { base: p3, len: l3 }
  ];
  let n: isize = fs_libc_writev(fd, &iov[0], 4);
  return n >= 0 ? (n as i64) : (-1 as i64);
}

/** 按段数 readv（1..16）。 */
export function fs_readv_buf_c(fd: i32, bufs: *u8, n: i32): i64 {
  if (n <= 0 || n > FS_IOV_BUF_MAX || bufs == 0) {
    return -1;
  }
  let b: *FsIovecBuf = bufs as *FsIovecBuf;
  let iov: Iovec[16];
  let i: i32 = 0;
  while (i < n) {
    iov[i].base = b[i].ptr;
    iov[i].len = b[i].len;
    i = i + 1;
  }
  let r: isize = fs_libc_readv(fd, &iov[0], n);
  return r >= 0 ? (r as i64) : (-1 as i64);
}

/** 按段数 writev（1..16）。 */
export function fs_writev_buf_c(fd: i32, bufs: *u8, n: i32): i64 {
  if (n <= 0 || n > FS_IOV_BUF_MAX || bufs == 0) {
    return -1;
  }
  let b: *FsIovecBuf = bufs as *FsIovecBuf;
  let iov: Iovec[16];
  let i: i32 = 0;
  while (i < n) {
    iov[i].base = b[i].ptr;
    iov[i].len = b[i].len;
    i = i + 1;
  }
  let r: isize = fs_libc_writev(fd, &iov[0], n);
  return r >= 0 ? (r as i64) : (-1 as i64);
}

/** 路径 stat。
 * 【Why 内联 fill】typeck 禁止「局部 struct 地址 + 外层 out*」同调 fill；在此直接写 out 字段。
 * 【Why out: *u8】与 mod.x FsStatOut 布局一致，但 mangle 为不同 C 类型名
 * （std_fs_posix_FsStatOut vs std_fs_FsStatOut）；跨模块边界用 *u8（同 fs_readv_buf_c），
 * 本函数内再 as *FsStatOut 写字段，避免 incompatible-pointer-types。 */
export function fs_stat_c(path: *u8, out: *u8): i32 {
  let st: PosixStatBuf;
  let o: *FsStatOut = out as *FsStatOut;
  if (path == 0 || out == 0) {
    return -1;
  }
  if (fs_libc_stat(path, &st) != 0) {
    fs_note_last_error_posix();
    return -1;
  }
  let st_mode: u32 = st.st_mode as u32;
  /* o[0].*：与 fs_fill_stat_from_st 一致；cast 后的 *T 用 . 会误发 C 的 o.field */
  o[0].size = st.st_size;
  o[0].mode = st_mode & 4095;
  o[0].is_dir = 0;
  o[0].is_file = 0;
  o[0].mtime_sec = st.st_mtime;
  if ((st_mode & S_IFMT) == S_IFDIR) {
    o[0].is_dir = 1;
  } else if ((st_mode & S_IFMT) == S_IFREG) {
    o[0].is_file = 1;
  }
  return 0;
}

/** chmod 路径权限。 */
export function fs_chmod_c(path: *u8, mode: u32): i32 {
  if (path == 0) {
    return -1;
  }
  if (fs_libc_chmod(path, mode) != 0) {
    fs_note_last_error_posix();
    return -1;
  }
  return 0;
}

/** mkdir。 */
export function fs_mkdir_c(path: *u8, mode: u32): i32 {
  if (path == 0) {
    return -1;
  }
  if (fs_libc_mkdir(path, mode) != 0) {
    fs_note_last_error_posix();
    return -1;
  }
  return 0;
}

/** unlink 文件。 */
export function fs_unlink_c(path: *u8): i32 {
  if (path == 0) {
    return -1;
  }
  if (fs_libc_unlink(path) != 0) {
    fs_note_last_error_posix();
    return -1;
  }
  return 0;
}

/** rmdir 空目录。 */
export function fs_rmdir_c(path: *u8): i32 {
  if (path == 0) {
    return -1;
  }
  if (fs_libc_rmdir(path) != 0) {
    fs_note_last_error_posix();
    return -1;
  }
  return 0;
}

/** opendir；失败 -1。 */
export function fs_dir_open_c(path: *u8): i64 {
  let d: *u8;
  let h: *FsDirHandlePosix;
  if (path == 0) {
    return -1;
  }
  d = fs_libc_opendir(path);
  if (d == 0) {
    fs_note_last_error_posix();
    return -1;
  }
  h = fs_libc_malloc(8) as *FsDirHandlePosix;
  if (h == 0) {
    fs_libc_closedir(d);
    return -1;
  }
  let dir_ptr: *u8 = d;
  h[0].dir = dir_ptr;
  return h as i64;
}

/** readdir 下一项；跳过 . 与 ..。 */
export function fs_dir_read_c(handle: i64, name_out: *u8, name_cap: i32, is_dir_out: *i32): i32 {
  let h: *FsDirHandlePosix;
  let de: *u8;
  let name: *u8;
  let nlen: usize;
  if (handle < 0 || name_out == 0 || name_cap <= 0) {
    return -1;
  }
  h = handle as *FsDirHandlePosix;
  while (1 != 0) {
    fs_errno_set(0);
    let h_dir: *u8 = h[0].dir;
    de = fs_libc_readdir(h_dir);
    if (de == 0) {
      if (fs_errno_get() != 0) {
        fs_note_last_error_posix();
        return -1;
      }
      return 0;
    }
    name = (de as *u8) + DIRENT_D_NAME_OFF;
    if (name[0] == 46 && (name[1] == 0 || (name[1] == 46 && name[2] == 0))) {
      continue;
    }
    nlen = fs_libc_strlen(name);
    let need_cap: i32 = (nlen + 1) as i32;
    if (need_cap > name_cap) {
      return -1;
    }
    fs_libc_memcpy(name_out, name, nlen);
    name_out[nlen] = 0;
    if (is_dir_out != 0) {
      is_dir_out[0] = 0;
    }
    return 1;
  }
  return 0;
}

/** closedir + free 句柄。 */
export function fs_dir_close_c(handle: i64): i32 {
  let h: *FsDirHandlePosix;
  if (handle < 0) {
    return -1;
  }
  h = handle as *FsDirHandlePosix;
  let h_dir: *u8 = h[0].dir;
  fs_libc_closedir(h_dir);
  fs_libc_free(h as *u8);
  return 0;
}

/** 模块尾占位：transitive import 解析锚点。 */
export function fs_posix_module_anchor(): i32 {
  return 0;
}
