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

// std.fs — open/read/write/close、mmap
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// ≥2MB）；fs_munmap。
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//   -
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
const io = import("std.io");
const driver = import("std.io.driver");

/* See implementation. */
#[cfg(target_os = "linux")]
const fs_platform = import("std.fs.posix");
#[cfg(target_os = "macos")]
const fs_platform = import("std.fs.posix");
/* See implementation. */
#[cfg(target_os = "windows")]
const fs_platform = import("std.fs.win32");

/* See implementation. */
#[cfg(target_os = "linux")]
const fs_freestanding = import("std.fs.freestanding_linux");

// See implementation.
// See implementation.
// See implementation.
// See implementation.

/** Exported function `fs_open_read_c`.
 * Read path helper `fs_open_read_c`.
 * @param path *u8): i32 { return fs_platform.fs_open_read_c(path
 * @return void
 */
export function fs_open_read_c(path: *u8): i32 { return fs_platform.fs_open_read_c(path); }
/** Exported function `fs_posix_read_c`.
 * Read path helper `fs_posix_read_c`.
 * @param fd i32
 * @param buf *u8
 * @param count usize): i64 { return fs_platform.fs_posix_read_c(fd
 * @param buf
 * @param count
 * @return void
 */
export function fs_posix_read_c(fd: i32, buf: *u8, count: usize): i64 { return fs_platform.fs_posix_read_c(fd, buf, count); }
/** Exported function `fs_posix_write_c`.
 * Write path helper `fs_posix_write_c`.
 * @param fd i32
 * @param buf *u8
 * @param count usize): i64 { return fs_platform.fs_posix_write_c(fd
 * @param buf
 * @param count
 * @return void
 */
export function fs_posix_write_c(fd: i32, buf: *u8, count: usize): i64 { return fs_platform.fs_posix_write_c(fd, buf, count); }
/** Exported function `fs_mmap_ro_c`.
 * Implements `fs_mmap_ro_c`.
 * @param path *u8
 * @param out_size *usize): *u8 { return fs_platform.fs_mmap_ro_c(path
 * @param out_size
 * @return void
 */
export function fs_mmap_ro_c(path: *u8, out_size: *usize): *u8 { return fs_platform.fs_mmap_ro_c(path, out_size); }
/** Exported function `fs_mmap_rw_c`.
 * Implements `fs_mmap_rw_c`.
 * @param path *u8
 * @param out_size *usize): *u8 { return fs_platform.fs_mmap_rw_c(path
 * @param out_size
 * @return void
 */
export function fs_mmap_rw_c(path: *u8, out_size: *usize): *u8 { return fs_platform.fs_mmap_rw_c(path, out_size); }
/** Exported function `fs_munmap_c`.
 * Implements `fs_munmap_c`.
 * @param ptr *u8
 * @param size usize): i32 { return fs_platform.fs_munmap_c(ptr
 * @param size
 * @return void
 */
export function fs_munmap_c(ptr: *u8, size: usize): i32 { return fs_platform.fs_munmap_c(ptr, size); }
/** Exported function `fs_open_read_direct_c`.
 * Read path helper `fs_open_read_direct_c`.
 * @param path *u8): i32 { return fs_platform.fs_open_read_direct_c(path
 * @return void
 */
export function fs_open_read_direct_c(path: *u8): i32 { return fs_platform.fs_open_read_direct_c(path); }
/** Exported function `fs_direct_align_c`.
 * Implements `fs_direct_align_c`.
 * @param ) u64 { return fs_platform.fs_direct_align_c(
 * @return void
 */
export function fs_direct_align_c(): u64 { return fs_platform.fs_direct_align_c(); }
/** Exported function `fs_fadvise_sequential_c`.
 * Implements `fs_fadvise_sequential_c`.
 * @param fd i32): i32 { return fs_platform.fs_fadvise_sequential_c(fd
 * @return void
 */
export function fs_fadvise_sequential_c(fd: i32): i32 { return fs_platform.fs_fadvise_sequential_c(fd); }
/** Exported function `fs_fadvise_willneed_c`.
 * Implements `fs_fadvise_willneed_c`.
 * @param fd i32
 * @param offset i64
 * @param len usize): i32 { return fs_platform.fs_fadvise_willneed_c(fd
 * @param offset
 * @param len
 * @return void
 */
export function fs_fadvise_willneed_c(fd: i32, offset: i64, len: usize): i32 { return fs_platform.fs_fadvise_willneed_c(fd, offset, len); }
/** Exported function `fs_copy_file_range_c`.
 * Implements `fs_copy_file_range_c`.
 * @param fd_in i32
 * @param fd_out i32
 * @param len usize): i64 { return fs_platform.fs_copy_file_range_c(fd_in
 * @param fd_out
 * @param len
 * @return void
 */
export function fs_copy_file_range_c(fd_in: i32, fd_out: i32, len: usize): i64 { return fs_platform.fs_copy_file_range_c(fd_in, fd_out, len); }
/** Exported function `fs_readv2_c`.
 * Read path helper `fs_readv2_c`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize): i64 { return fs_platform.fs_readv2_c(fd
 * @param p0
 * @param l0
 * @param p1
 * @param l1
 * @return void
 */
export function fs_readv2_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 { return fs_platform.fs_readv2_c(fd, p0, l0, p1, l1); }
/** Exported function `fs_writev2_c`.
 * Write path helper `fs_writev2_c`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize): i64 { return fs_platform.fs_writev2_c(fd
 * @param p0
 * @param l0
 * @param p1
 * @param l1
 * @return void
 */
export function fs_writev2_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 { return fs_platform.fs_writev2_c(fd, p0, l0, p1, l1); }
/** Exported function `fs_sendfile_c`.
 * Implements `fs_sendfile_c`.
 * @param out_fd i32
 * @param in_fd i32
 * @param count usize): i64 { return fs_platform.fs_sendfile_c(out_fd
 * @param in_fd
 * @param count
 * @return void
 */
export function fs_sendfile_c(out_fd: i32, in_fd: i32, count: usize): i64 { return fs_platform.fs_sendfile_c(out_fd, in_fd, count); }
/** Exported function `fs_pipe_splice_c`.
 * Implements `fs_pipe_splice_c`.
 * @param fd_in i32
 * @param fd_out i32
 * @param len usize): i64 { return fs_platform.fs_pipe_splice_c(fd_in
 * @param fd_out
 * @param len
 * @return void
 */
export function fs_pipe_splice_c(fd_in: i32, fd_out: i32, len: usize): i64 { return fs_platform.fs_pipe_splice_c(fd_in, fd_out, len); }
/** Exported function `fs_sync_range_c`.
 * Implements `fs_sync_range_c`.
 * @param fd i32
 * @param offset i64
 * @param len usize): i32 { return fs_platform.fs_sync_range_c(fd
 * @param offset
 * @param len
 * @return void
 */
export function fs_sync_range_c(fd: i32, offset: i64, len: usize): i32 { return fs_platform.fs_sync_range_c(fd, offset, len); }
/** Exported function `fs_sync_c`.
 * Implements `fs_sync_c`.
 * @param fd i32): i32 { return fs_platform.fs_sync_c(fd
 * @return void
 */
export function fs_sync_c(fd: i32): i32 { return fs_platform.fs_sync_c(fd); }
/** Exported function `fs_fallocate_c`.
 * Memory management helper `fs_fallocate_c`.
 * @param fd i32
 * @param offset i64
 * @param len i64): i32 { return fs_platform.fs_fallocate_c(fd
 * @param offset
 * @param len
 * @return void
 */
export function fs_fallocate_c(fd: i32, offset: i64, len: i64): i32 { return fs_platform.fs_fallocate_c(fd, offset, len); }
/** Exported function `fs_open_write_c`.
 * Write path helper `fs_open_write_c`.
 * @param path *u8): i32 { return fs_platform.fs_open_write_c(path
 * @return void
 */
export function fs_open_write_c(path: *u8): i32 { return fs_platform.fs_open_write_c(path); }
/** Exported function `fs_open_append_c`.
 * Implements `fs_open_append_c`.
 * @param path *u8): i32 { return fs_platform.fs_open_append_c(path
 * @return void
 */
export function fs_open_append_c(path: *u8): i32 { return fs_platform.fs_open_append_c(path); }
/** Exported function `fs_open_create_c`.
 * Implements `fs_open_create_c`.
 * @param path *u8): i32 { return fs_platform.fs_open_create_c(path
 * @return void
 */
export function fs_open_create_c(path: *u8): i32 { return fs_platform.fs_open_create_c(path); }
/** Exported function `fs_last_error_c`.
 * Implements `fs_last_error_c`.
 * @param ) i32 { return fs_platform.fs_last_error_c(
 * @return void
 */
export function fs_last_error_c(): i32 { return fs_platform.fs_last_error_c(); }
/** Exported function `fs_readv4_c`.
 * Read path helper `fs_readv4_c`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @return i64
 */
export function fs_readv4_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize): i64 {
  return fs_platform.fs_readv4_c(fd, p0, l0, p1, l1, p2, l2, p3, l3);
}
/** Exported function `fs_writev4_c`.
 * Write path helper `fs_writev4_c`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @return i64
 */
export function fs_writev4_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize): i64 {
  return fs_platform.fs_writev4_c(fd, p0, l0, p1, l1, p2, l2, p3, l3);
}
allow(padding) struct FsIovecBuf { ptr: *u8; len: usize; handle: usize }
/** Exported function `fs_readv_buf_c`.
 * Read path helper `fs_readv_buf_c`.
 * @param fd i32
 * @param bufs *FsIovecBuf
 * @param n i32): i64 { return fs_platform.fs_readv_buf_c(fd
 * @param bufs as *u8
 * @param n
 * @return void
 */
export function fs_readv_buf_c(fd: i32, bufs: *FsIovecBuf, n: i32): i64 { return fs_platform.fs_readv_buf_c(fd, bufs as *u8, n); }
/** Exported function `fs_writev_buf_c`.
 * Write path helper `fs_writev_buf_c`.
 * @param fd i32
 * @param bufs *FsIovecBuf
 * @param n i32): i64 { return fs_platform.fs_writev_buf_c(fd
 * @param bufs as *u8
 * @param n
 * @return void
 */
export function fs_writev_buf_c(fd: i32, bufs: *FsIovecBuf, n: i32): i64 { return fs_platform.fs_writev_buf_c(fd, bufs as *u8, n); }
/** Exported function `invalid`.
 * Implements `invalid`.
 * @return i32
 */
export function invalid(): i32 { return -1; }
/** Exported function `chunk_size`.
 * Implements `chunk_size`.
 * @return usize
 */
export function chunk_size(): usize { return 1048576; }
/** Exported function `open`.
 * Implements `open`.
 * @param path *u8): i32 { return fs_open_read_c(path
 * @return void
 */
export function open(path: *u8): i32 { return fs_open_read_c(path); }
/** Exported function `create`.
 * Implements `create`.
 * @param path *u8): i32 { return fs_open_write_c(path
 * @return void
 */
export function create(path: *u8): i32 { return fs_open_write_c(path); }
/** Exported function `close`.
 * Implements `close`.
 * @param fd i32): i32 { return fs_platform.fs_posix_close_c(fd
 * @return void
 */
export function close(fd: i32): i32 { return fs_platform.fs_posix_close_c(fd); }
/** Exported function `read`.
 * Read path helper `read`.
 * @param fd i32
 * @param buf *u8
 * @param count usize): isize { return fs_posix_read_c(fd
 * @param buf
 * @param count
 * @return void
 */
export function read(fd: i32, buf: *u8, count: usize): isize { return fs_posix_read_c(fd, buf, count) as isize; }
/** Exported function `write`.
 * Write path helper `write`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @return isize
 */
export function write(fd: i32, buf: *u8, count: usize): isize { return fs_posix_write_c(fd, buf,
  count) as isize; }
/** Exported function `pread`.
 * Read path helper `pread`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @param offset i64
 * @return isize
 */
export function pread(fd: i32, buf: *u8, count: usize, offset: i64): isize {
  return fs_platform.fs_posix_pread_c(fd, buf, count, offset) as isize;
}
/** Exported function `pwrite`.
 * Write path helper `pwrite`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @param offset i64
 * @return isize
 */
export function pwrite(fd: i32, buf: *u8, count: usize, offset: i64): isize {
  return fs_platform.fs_posix_pwrite_c(fd, buf, count, offset) as isize;
}
/** Exported function `open_read_direct`.
 * Read path helper `open_read_direct`.
 * @param path *u8): i32 { return fs_open_read_direct_c(path
 * @return void
 */
export function open_read_direct(path: *u8): i32 { return fs_open_read_direct_c(path); }
/** Exported function `direct_align`.
 * Implements `direct_align`.
 * @param ) u64 { return fs_direct_align_c(
 * @return void
 */
export function direct_align(): u64 { return fs_direct_align_c(); }
/** Exported function `fadvise_sequential`.
 * Implements `fadvise_sequential`.
 * @param fd i32): i32 { return fs_fadvise_sequential_c(fd
 * @return void
 */
export function fadvise_sequential(fd: i32): i32 { return fs_fadvise_sequential_c(fd); }
/** Exported function `fadvise_willneed`.
 * Implements `fadvise_willneed`.
 * @param fd i32
 * @param offset i64
 * @param len usize
 * @return i32
 */
export function fadvise_willneed(fd: i32, offset: i64, len: usize): i32 { return
  fs_fadvise_willneed_c(fd, offset, len); }
/** Exported function `copy_file_range`.
 * Implements `copy_file_range`.
 * @param fd_in i32
 * @param fd_out i32
 * @param len usize
 * @return i64
 */
export function copy_file_range(fd_in: i32, fd_out: i32, len: usize): i64 { return
  fs_copy_file_range_c(fd_in, fd_out, len); }
/** Exported function `readv`.
 * Read path helper `readv`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @return i64
 */
export function readv(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 { return fs_readv2_c(fd,
  p0, l0, p1, l1); }
/** Exported function `writev`.
 * Write path helper `writev`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @return i64
 */
export function writev(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 { return fs_writev2_c(fd,
  p0, l0, p1, l1); }
/** Exported function `sendfile`.
 * Implements `sendfile`.
 * @param out_fd i32
 * @param in_fd i32
 * @param count usize
 * @return i64
 */
export function sendfile(out_fd: i32, in_fd: i32, count: usize): i64 { return fs_sendfile_c(out_fd,
  in_fd, count); }
/**
 * See implementation.
 * See implementation.
 */
export function pipe_splice(fd_in: i32, fd_out: i32, len: usize): i64 {
  return fs_pipe_splice_c(fd_in, fd_out, len);
}
/** Exported function `sync_range`.
 * Implements `sync_range`.
 * @param fd i32
 * @param offset i64
 * @param len usize
 * @return i32
 */
export function sync_range(fd: i32, offset: i64, len: usize): i32 { return fs_sync_range_c(fd, offset,
  len); }
/** Exported function `sync`.
 * Implements `sync`.
 * @param fd i32): i32 { return fs_sync_c(fd
 * @return void
 */
export function sync(fd: i32): i32 { return fs_sync_c(fd); }
/** Exported function `fallocate`.
 * Memory management helper `fallocate`.
 * @param fd i32
 * @param offset i64
 * @param len i64
 * @return i32
 */
export function fallocate(fd: i32, offset: i64, len: i64): i32 { return fs_fallocate_c(fd, offset,
  len); }
/** Exported function `open_append`.
 * Implements `open_append`.
 * @param path *u8): i32 { return fs_open_append_c(path
 * @return void
 */
export function open_append(path: *u8): i32 { return fs_open_append_c(path); }
/** Exported function `open_create`.
 * Implements `open_create`.
 * @param path *u8): i32 { return fs_open_create_c(path
 * @return void
 */
export function open_create(path: *u8): i32 { return fs_open_create_c(path); }
/** Exported function `last_error`.
 * Implements `last_error`.
 * @param ) i32 { return fs_last_error_c(
 * @return void
 */
export function last_error(): i32 { return fs_last_error_c(); }
/** See implementation for details. */
export function readv(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8,
l3: usize): i64 {
  return fs_readv4_c(fd, p0, l0, p1, l1, p2, l2, p3, l3);
}
/* See implementation. */
export function writev(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8,
l3: usize): i64 {
  return fs_writev4_c(fd, p0, l0, p1, l1, p2, l2, p3, l3);
}
/** Exported function `readv_buf`.
 * Read path helper `readv_buf`.
 * @param fd i32
 * @param bufs *FsIovecBuf
 * @param n i32
 * @return i64
 */
export function readv_buf(fd: i32, bufs: *FsIovecBuf, n: i32): i64 {
  return fs_readv_buf_c(fd, bufs, n);
}
/** Exported function `writev_buf`.
 * Write path helper `writev_buf`.
 * @param fd i32
 * @param bufs *FsIovecBuf
 * @param n i32
 * @return i64
 */
export function writev_buf(fd: i32, bufs: *FsIovecBuf, n: i32): i64 {
  return fs_writev_buf_c(fd, bufs, n);
}
/** Exported function `mmap_ro`.
 * Implements `mmap_ro`.
 * @param path *u8
 * @param out_size *usize): *u8 { return fs_mmap_ro_c(path
 * @param out_size
 * @return void
 */
export function mmap_ro(path: *u8, out_size: *usize): *u8 { return fs_mmap_ro_c(path, out_size); }
/** Exported function `mmap_rw`.
 * Implements `mmap_rw`.
 * @param path *u8
 * @param out_size *usize): *u8 { return fs_mmap_rw_c(path
 * @param out_size
 * @return void
 */
export function mmap_rw(path: *u8, out_size: *usize): *u8 { return fs_mmap_rw_c(path, out_size); }
/** Exported function `munmap`.
 * Implements `munmap`.
 * @param ptr *u8
 * @param size usize): i32 { return fs_munmap_c(ptr
 * @param size
 * @return void
 */
export function munmap(ptr: *u8, size: usize): i32 { return fs_munmap_c(ptr, size); }
// See implementation.
// See implementation.
/* See implementation. */
/** Exported function `from_fd`.
 * Implements `from_fd`.
 * @param fd i32
 * @param _unused i32): usize { return (fd as usize
 * @return void
 */
export function from_fd(fd: i32, _unused: i32): usize { return (fd as usize); }
/** Exported function `read_fd`.
 * Read path helper `read_fd`.
 * @param fd i32
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function read_fd(fd: i32, ptr: *u8, len: usize): i32 {
  return io.read(io.from_fd(fd, 0), ptr, len, 0 as u32);
}
/** Exported function `write_fd`.
 * Write path helper `write_fd`.
 * @param fd i32
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function write_fd(fd: i32, ptr: *u8, len: usize): i32 {
  return io.write(io.from_fd(fd, 0), ptr, len, 0 as u32);
}
/** See implementation for details. */
export function read_batch_fd(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3:
*u8, l3: usize, n: i32): i32 {
  let h: usize = io.from_fd(fd, 0);
  let bufs: [4]Buffer = [
  Buffer { ptr: p0, len: l0, handle: h },
  Buffer { ptr: p1, len: l1, handle: h },
  Buffer { ptr: p2, len: l2, handle: h },
  Buffer { ptr: p3, len: l3, handle: h }
  ];
  return driver.submit_read_batch(bufs, n, 0 as u32);
}
/** See implementation for details. */
export function write_batch_fd(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3:
*u8, l3: usize, n: i32): i32 {
  let h: usize = io.from_fd(fd, 0);
  let bufs: [4]Buffer = [
  Buffer { ptr: p0, len: l0, handle: h },
  Buffer { ptr: p1, len: l1, handle: h },
  Buffer { ptr: p2, len: l2, handle: h },
  Buffer { ptr: p3, len: l3, handle: h }
  ];
  return driver.submit_write_batch(bufs, n, 0 as u32);
}
/** Exported function `path_readable`.
 * Read path helper `path_readable`.
 * @param path *u8
 * @return i32
 */
export function path_readable(path: *u8): i32 {
  let fd: i32 = open(path);
  if (fd < 0) {
    return 0;
  }
  close(fd);
  return 1;
}

/* See implementation. */

/* See implementation. */
allow(padding) struct FsStatOut {
  size: i64;
  mode: u32;
  is_dir: i32;
  is_file: i32;
  mtime_sec: i64;
}

/* See implementation. */
export function fs_stat_c(path: *u8, out: *FsStatOut): i32 { return fs_platform.fs_stat_c(path, out as *u8); }
/** Exported function `fs_chmod_c`.
 * Implements `fs_chmod_c`.
 * @param path *u8
 * @param mode u32): i32 { return fs_platform.fs_chmod_c(path
 * @param mode
 * @return void
 */
export function fs_chmod_c(path: *u8, mode: u32): i32 { return fs_platform.fs_chmod_c(path, mode); }
/** Exported function `fs_mkdir_c`.
 * Implements `fs_mkdir_c`.
 * @param path *u8
 * @param mode u32): i32 { return fs_platform.fs_mkdir_c(path
 * @param mode
 * @return void
 */
export function fs_mkdir_c(path: *u8, mode: u32): i32 { return fs_platform.fs_mkdir_c(path, mode); }
/** Exported function `fs_unlink_c`.
 * Implements `fs_unlink_c`.
 * @param path *u8): i32 { return fs_platform.fs_unlink_c(path
 * @return void
 */
export function fs_unlink_c(path: *u8): i32 { return fs_platform.fs_unlink_c(path); }
/** Exported function `fs_rmdir_c`.
 * Implements `fs_rmdir_c`.
 * @param path *u8): i32 { return fs_platform.fs_rmdir_c(path
 * @return void
 */
export function fs_rmdir_c(path: *u8): i32 { return fs_platform.fs_rmdir_c(path); }
/** Exported function `fs_dir_open_c`.
 * Implements `fs_dir_open_c`.
 * @param path *u8): i64 { return fs_platform.fs_dir_open_c(path
 * @return void
 */
export function fs_dir_open_c(path: *u8): i64 { return fs_platform.fs_dir_open_c(path); }
/** Exported function `fs_dir_read_c`.
 * Read path helper `fs_dir_read_c`.
 * @param handle i64
 * @param name_out *u8
 * @param name_cap i32
 * @param is_dir_out *i32
 * @return i32
 */
export function fs_dir_read_c(handle: i64, name_out: *u8, name_cap: i32, is_dir_out: *i32): i32 {
  return fs_platform.fs_dir_read_c(handle, name_out, name_cap, is_dir_out);
}
/** Exported function `fs_dir_close_c`.
 * Implements `fs_dir_close_c`.
 * @param handle i64): i32 { return fs_platform.fs_dir_close_c(handle
 * @return void
 */
export function fs_dir_close_c(handle: i64): i32 { return fs_platform.fs_dir_close_c(handle); }

/** Exported function `mode_file_default`.
 * Implements `mode_file_default`.
 * @return u32
 */
export function mode_file_default(): u32 { return 420; }
/** Exported function `mode_dir_default`.
 * Implements `mode_dir_default`.
 * @return u32
 */
export function mode_dir_default(): u32 { return 493; }

/** Exported function `stat`.
 * Implements `stat`.
 * @param path *u8
 * @param out *FsStatOut
 * @return i32
 */
export function stat(path: *u8, out: *FsStatOut): i32 {
  return fs_stat_c(path, out);
}

/** Exported function `chmod`.
 * Implements `chmod`.
 * @param path *u8
 * @param mode u32
 * @return i32
 */
export function chmod(path: *u8, mode: u32): i32 {
  return fs_chmod_c(path, mode);
}

/** Exported function `mkdir`.
 * Implements `mkdir`.
 * @param path *u8
 * @param mode u32
 * @return i32
 */
export function mkdir(path: *u8, mode: u32): i32 {
  return fs_mkdir_c(path, mode);
}

/** Exported function `remove_file`.
 * Implements `remove_file`.
 * @param path *u8
 * @return i32
 */
export function remove_file(path: *u8): i32 {
  return fs_unlink_c(path);
}

/** Exported function `remove_dir`.
 * Implements `remove_dir`.
 * @param path *u8
 * @return i32
 */
export function remove_dir(path: *u8): i32 {
  return fs_rmdir_c(path);
}

/** Exported function `dir_open`.
 * Implements `dir_open`.
 * @param path *u8
 * @return i64
 */
export function dir_open(path: *u8): i64 {
  return fs_dir_open_c(path);
}

/** Exported function `dir_read`.
 * Read path helper `dir_read`.
 * @param handle i64
 * @param name_out *u8
 * @param name_cap i32
 * @param is_dir_out *i32
 * @return i32
 */
export function dir_read(handle: i64, name_out: *u8, name_cap: i32, is_dir_out: *i32): i32 {
  return fs_dir_read_c(handle, name_out, name_cap, is_dir_out);
}

/** Exported function `dir_close`.
 * Implements `dir_close`.
 * @param handle i64
 * @return i32
 */
export function dir_close(handle: i64): i32 {
  return fs_dir_close_c(handle);
}

/** Exported function `freestanding_fs_available`.
 * Memory management helper `freestanding_fs_available`.
 * @return i32
 */
#[cfg(target_os = "linux")]
export function freestanding_fs_available(): i32 {
  return fs_freestanding.freestanding_fs_available();
}

/** Exported function `read_file`.
 * Read path helper `read_file`.
 * @param path *u8
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
#[cfg(target_os = "linux")]
export function read_file(path: *u8, buf: *u8, cap: i32): i32 {
  return fs_freestanding.freestanding_read_file_into(path, buf, cap);
}

/** Exported function `fs_module_anchor`.
 * Implements `fs_module_anchor`.
 * @return i32
 */
export function fs_module_anchor(): i32 { return 0; }
