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

// std.fs — open/read/write/close、mmap
// 只读/可写、pread/pwrite、readv/writev、O_DIRECT、fadvise、copy_file_range、sendfile、sync
// _range、fallocate（性能压榨到极致）
//
// 功能：与 libc 一致的 extern + 薄封装；路径由 std.path
// 拼接/规范化后传入（*u8 以 NUL 结尾）。
// 高性能极致压榨：
//   - 大模型等超大文件：fs_mmap_ro + madvise 顺序 + 大映射 MADV_HUGEPAGE（Linux
// ≥2MB）；fs_munmap。
//   - 可写零拷贝：fs_mmap_rw；改完 fs_munmap 即落盘。
//   - 大块顺序读：fs_read ≥ fs_read_chunk()；fs_fadvise_sequential 压榨预读。
//   - 同一 fd 多线程并发：fs_pread / fs_pwrite 带 offset。
//   - 分散读/集中写：fs_readv2 / fs_writev2 一次 syscall 两段，压榨 syscall 数。
//   - 极致吞吐：fs_open_read_direct（O_DIRECT）；buf 对齐 fs_direct_align()。
//   -
// 零拷贝：fs_copy_file_range（文件→文件）；fs_sendfile（文件→socket，Linux）；
//   fs_pipe_splice（ZC-5：pipe+splice 代理，Linux 无 userspace copy）。
//   - 大文件写：fs_fallocate 预分配；fs_sync_range
// 范围刷盘不阻塞，重叠写+刷盘。
//   - 与 std.io 联合：本模块已 import("std.io")，用户仅 import("std.fs") 即可用
// read_fd/write_fd/read_batch_fd/write_batch_fd 走 io_uring/readv 极致压榨。
const io = import("std.io");
const driver = import("std.io.driver");

/** F-03 v2：Linux/macOS POSIX 实现（libc FFI，链 -lc）。 */
#[cfg(target_os = "linux")]
const fs_platform = import("std.fs.posix");
#[cfg(target_os = "macos")]
const fs_platform = import("std.fs.posix");
/** F-03 v2：Windows kernel32/mswsock 实现。 */
#[cfg(target_os = "windows")]
const fs_platform = import("std.fs.win32");

/** F-no-libc NL-04：Linux freestanding 文件 IO（import 区须顶格，勿放 function 段）。 */
#[cfg(target_os = "linux")]
const fs_freestanding = import("std.fs.freestanding_linux");

// 与 POSIX open/read/write/close 一致；链接时需 -lc。fs_*_c 由 posix/win32 提供。
// fs_readv_buf/fs_writev_buf 的 bufs 与 Buffer ABI
// 一致（ptr+len+handle），可传 Buffer 数组首地址。
// close/pread/pwrite 经 fs_platform.fs_posix_*_c，避免与公开 API 同名 extern 重载冲突。

/** 只读打开（F-03 v2 纯 .x）；asm 跳过 std.fs emit 时由 std_fs.o 提供。 */
function fs_open_read_c(path: *u8): i32 { return fs_platform.fs_open_read_c(path); }
function fs_posix_read_c(fd: i32, buf: *u8, count: usize): i64 { return fs_platform.fs_posix_read_c(fd, buf, count); }
function fs_posix_write_c(fd: i32, buf: *u8, count: usize): i64 { return fs_platform.fs_posix_write_c(fd, buf, count); }
function fs_mmap_ro_c(path: *u8, out_size: *usize): *u8 { return fs_platform.fs_mmap_ro_c(path, out_size); }
function fs_mmap_rw_c(path: *u8, out_size: *usize): *u8 { return fs_platform.fs_mmap_rw_c(path, out_size); }
function fs_munmap_c(ptr: *u8, size: usize): i32 { return fs_platform.fs_munmap_c(ptr, size); }
function fs_open_read_direct_c(path: *u8): i32 { return fs_platform.fs_open_read_direct_c(path); }
function fs_direct_align_c(): u64 { return fs_platform.fs_direct_align_c(); }
function fs_fadvise_sequential_c(fd: i32): i32 { return fs_platform.fs_fadvise_sequential_c(fd); }
function fs_fadvise_willneed_c(fd: i32, offset: i64, len: usize): i32 { return fs_platform.fs_fadvise_willneed_c(fd, offset, len); }
function fs_copy_file_range_c(fd_in: i32, fd_out: i32, len: usize): i64 { return fs_platform.fs_copy_file_range_c(fd_in, fd_out, len); }
function fs_readv2_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 { return fs_platform.fs_readv2_c(fd, p0, l0, p1, l1); }
function fs_writev2_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 { return fs_platform.fs_writev2_c(fd, p0, l0, p1, l1); }
function fs_sendfile_c(out_fd: i32, in_fd: i32, count: usize): i64 { return fs_platform.fs_sendfile_c(out_fd, in_fd, count); }
/** ZC-5：经 pipe splice 中转（Linux 内核零拷贝；非 Linux read/write 回退）。 */
function fs_pipe_splice_c(fd_in: i32, fd_out: i32, len: usize): i64 { return fs_platform.fs_pipe_splice_c(fd_in, fd_out, len); }
function fs_sync_range_c(fd: i32, offset: i64, len: usize): i32 { return fs_platform.fs_sync_range_c(fd, offset, len); }
function fs_sync_c(fd: i32): i32 { return fs_platform.fs_sync_c(fd); }
function fs_fallocate_c(fd: i32, offset: i64, len: i64): i32 { return fs_platform.fs_fallocate_c(fd, offset, len); }
function fs_open_write_c(path: *u8): i32 { return fs_platform.fs_open_write_c(path); }
function fs_open_append_c(path: *u8): i32 { return fs_platform.fs_open_append_c(path); }
function fs_open_create_c(path: *u8): i32 { return fs_platform.fs_open_create_c(path); }
function fs_last_error_c(): i32 { return fs_platform.fs_last_error_c(); }
function fs_readv4_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize): i64 {
  return fs_platform.fs_readv4_c(fd, p0, l0, p1, l1, p2, l2, p3, l3);
}
function fs_writev4_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize): i64 {
  return fs_platform.fs_writev4_c(fd, p0, l0, p1, l1, p2, l2, p3, l3);
}
allow(padding) struct FsIovecBuf { ptr: *u8; len: usize; handle: usize }
function fs_readv_buf_c(fd: i32, bufs: *FsIovecBuf, n: i32): i64 { return fs_platform.fs_readv_buf_c(fd, bufs, n); }
function fs_writev_buf_c(fd: i32, bufs: *FsIovecBuf, n: i32): i64 { return fs_platform.fs_writev_buf_c(fd, bufs, n); }
function invalid(): i32 { return -1; }
/** 推荐大块读单次字节数（1MiB），极致压榨时用此大小循环 fs_read。 */
function chunk_size(): usize { return 1048576; }
/** 只读打开 path（NUL 结尾）；失败返回 -1。 */
function open(path: *u8): i32 { return fs_open_read_c(path); }
/** 写打开 path，不存在则创建、存在则截断；失败返回 -1。走 C 实现以
* umask(0) 保证 0644，避免 mmap_ro 等后续读打开 EACCES。 */
function create(path: *u8): i32 { return fs_open_write_c(path); }
function close(fd: i32): i32 { return fs_platform.fs_posix_close_c(fd); }
/** 大块读：从 fd 读入最多 count 字节到 buf。推荐 count ≥
* fs_read_chunk()。返回读入字节数，0=EOF，-1=错误。 */
function read(fd: i32, buf: *u8, count: usize): isize { return fs_posix_read_c(fd, buf, count); }
/** 大块写：将 buf[0..count-1] 写入 fd。返回写入字节数，-1=错误。 */
function write(fd: i32, buf: *u8, count: usize): isize { return fs_posix_write_c(fd, buf,
  count); }
/** 并发读：从 fd 的 offset 处读最多 count 字节到 buf，不改变 fd
* 位置；多线程可同时对同一 fd 调 fs_pread 读不同
* offset，极致并发。返回读入字节数，0=EOF，-1=错误。 */
function pread(fd: i32, buf: *u8, count: usize, offset: i64): isize {
  return fs_platform.fs_posix_pread_c(fd, buf, count, offset) as isize;
}
/** 并发写：向 fd 的 offset 处写 count 字节，不改变 fd
* 位置；多线程可同时对同一 fd 调 fs_pwrite 写不同
* offset。返回写入字节数，-1=错误。 */
function pwrite(fd: i32, buf: *u8, count: usize, offset: i64): isize {
  return fs_platform.fs_posix_pwrite_c(fd, buf, count, offset) as isize;
}
/** 只读 + O_DIRECT
* 打开（Linux）；绕过页缓存，适合大文件顺序读极致吞吐。buf 与 offset
* 须对齐 fs_direct_align()；不可用或失败返回 -1。 */
function open_read_direct(path: *u8): i32 { return fs_open_read_direct_c(path); }
/** O_DIRECT 对齐要求（字节）；buf 与 offset 须为该值的整数倍。用于
* fs_open_read_direct 后的读。 */
function direct_align(): u64 { return fs_direct_align_c(); }
/** 提示内核将 fd 视为顺序访问，可激进预读与释放，压榨顺序读吞吐；0
* 成功，-1 失败。 */
function fadvise_sequential(fd: i32): i32 { return fs_fadvise_sequential_c(fd); }
/** 提示内核即将访问 [offset, offset+len)，可预取页；0 成功，-1 失败。 */
function fadvise_willneed(fd: i32, offset: i64, len: usize): i32 { return
  fs_fadvise_willneed_c(fd, offset, len); }
/** 零拷贝：从 fd_in 当前偏移复制 len 字节到 fd_out 当前偏移（Linux
* copy_file_range）；返回复制字节数，-1 失败。两 fd 偏移会前进。 */
function copy_file_range(fd_in: i32, fd_out: i32, len: usize): i64 { return
  fs_copy_file_range_c(fd_in, fd_out, len); }
/** 分散读：一次 syscall 读入两段 [p0,l0] 与 [p1,l1]；返回总字节数，0=EOF，-1
* 错误。压榨 syscall 数。 */
function readv(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 { return fs_readv2_c(fd,
  p0, l0, p1, l1); }
/** 集中写：一次 syscall 写出两段 [p0,l0] 与 [p1,l1]；返回总字节数，-1
* 错误。压榨 syscall 数。 */
function writev(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 { return fs_writev2_c(fd,
  p0, l0, p1, l1); }
/** 零拷贝：从 in_fd 当前偏移发送 count 字节到 out_fd（Linux
* sendfile，常用于文件→socket）；返回发送字节数，-1 失败。in_fd
* 偏移会前进。 */
function sendfile(out_fd: i32, in_fd: i32, count: usize): i64 { return fs_sendfile_c(out_fd,
  in_fd, count); }
/**
 * ZC-5：fd_in → 内核 pipe → fd_out（Linux splice，无 userspace 拷贝）。
 * 常用于 file→socket 代理路径；非 Linux 回退 read/write。返回传输字节数，-1 失败。
 */
function pipe_splice(fd_in: i32, fd_out: i32, len: usize): i64 {
  return fs_pipe_splice_c(fd_in, fd_out, len);
}
/** 范围刷盘（Linux）：将 [offset, offset+len) 写回磁盘，不阻塞全文件
* sync；大文件顺序写时可重叠写+刷盘压榨吞吐。0 成功，-1 失败。 */
function sync_range(fd: i32, offset: i64, len: usize): i32 { return fs_sync_range_c(fd, offset,
  len); }
/** 整文件刷盘（POSIX fsync / Windows FlushFileBuffers）；写完后 close
* 前调用，保证后续 open/mmap 可见。0 成功，-1 失败。 */
function sync(fd: i32): i32 { return fs_sync_c(fd); }
/** 预分配文件空间 [offset, offset+len)（Linux
* fallocate）；减少大文件写时的碎片与元数据更新。0 成功，-1 失败。 */
function fallocate(fd: i32, offset: i64, len: i64): i32 { return fs_fallocate_c(fd, offset,
  len); }
/** 追加写打开 path（不存在则创建）；失败返回 -1。 */
function open_append(path: *u8): i32 { return fs_open_append_c(path); }
/** 写打开 path，不存在则创建、存在则不截断；失败返回 -1。 */
function open_create(path: *u8): i32 { return fs_open_create_c(path); }
/** 返回上次 fs_* 失败时的平台错误码（Linux/macOS errno，Windows
* GetLastError）。调用方在任意 fs_* 返回 -1
* 或失败后可调用本函数获取细粒度错误码。 */
function last_error(): i32 { return fs_last_error_c(); }
/** 分散读：一次 syscall 读入四段 [p0,l0]..[p3,l3]；返回总字节数，0=EOF，-1
* 错误。 */
function readv(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8,
l3: usize): i64 {
  return fs_readv4_c(fd, p0, l0, p1, l1, p2, l2, p3, l3);
}
/** 集中写：一次 syscall 写出四段 [p0,l0]..[p3,l3]；返回总字节数，-1 错误。 */
function writev(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8,
l3: usize): i64 {
  return fs_writev4_c(fd, p0, l0, p1, l1, p2, l2, p3, l3);
}
/** 与 Zig/Rust 对齐：按「指针+段数」分散读；bufs 指向至少 n 个
* FsIovecBuf（ptr/len 有效，与 Buffer ABI 一致），n 为
* 1..16。返回总字节数，0=EOF，-1=错误。 */
function readv_buf(fd: i32, bufs: *FsIovecBuf, n: i32): i64 {
  return fs_readv_buf_c(fd, bufs, n);
}
/** 与 Zig/Rust 对齐：按「指针+段数」集中写；bufs 同上，n 为
* 1..16。返回总字节数，-1=错误。 */
function writev_buf(fd: i32, bufs: *FsIovecBuf, n: i32): i64 {
  return fs_writev_buf_c(fd, bufs, n);
}
/** 只读 mmap 整个文件（极速读大模型等大文件）；path 为 NUL 结尾；内核
* madvise 顺序+大页（≥2MB 时 Linux）。返回映射首地址，*out_size
* 为文件字节数；失败返回 0。用毕必须 fs_munmap(ptr, *out_size)。 */
function mmap_ro(path: *u8, out_size: *usize): *u8 { return fs_mmap_ro_c(path, out_size); }
/** 可写 mmap 整个文件（写回磁盘）；path
* 须已存在且可写。返回映射首地址，*out_size 为文件字节数；失败返回
* 0。用毕必须 fs_munmap(ptr, *out_size)。 */
function mmap_rw(path: *u8, out_size: *usize): *u8 { return fs_mmap_rw_c(path, out_size); }
/** 解除 mmap；ptr 与 size 须为 fs_mmap_ro/fs_mmap_rw 的返回值与 *out_size。返回 0
* 成功，-1 失败。 */
function munmap(ptr: *u8, size: usize): i32 { return fs_munmap_c(ptr, size); }
// ——— 与 std.io 联合：用户仅 import("std.fs") 即可用下列 fd 接口，走
// io_uring/readv 极致压榨（无需再 import("std.io")） ———
/** 将 fd 转为 io handle；与 read_fd/write_fd/read_batch_fd/write_batch_fd 配套。 */
/** 与 std.io 一致，第二参 unused，调用处传 0。 */
function from_fd(fd: i32, _unused: i32): usize { return (fd as usize); }
/** 从 fd 单次大块读（走 std.io，Linux 下 io_uring）；推荐 len ≥
* fs_read_chunk()。返回读入字节数，0=EOF，-1=错误。 */
function read_fd(fd: i32, ptr: *u8, len: usize): i32 {
  return io.read(io.from_fd(fd, 0), ptr, len, 0 as u32);
}
/** 向 fd 单次大块写（走 std.io，Linux 下
* io_uring）。返回写入字节数，-1=错误。 */
function write_fd(fd: i32, ptr: *u8, len: usize): i32 {
  return io.write(io.from_fd(fd, 0), ptr, len, 0 as u32);
}
/** 从 fd 批量读：一次 submit 最多 4 段，n 为段数 1..4；走
* io_uring/readv。返回总字节数，-1=错误。 */
function read_batch_fd(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3:
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
/** 向 fd 批量写：一次 submit 最多 4 段，n 为段数 1..4；走
* io_uring/writev。返回总字节数，-1=错误。 */
function write_batch_fd(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3:
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
/** 探测 path（NUL 结尾）是否可读打开；pipeline import 解析与 -L
* 路径探测用。可读返回 1，否则 0。 */
function path_readable(path: *u8): i32 {
  let fd: i32 = open(path);
  if (fd < 0) {
    return 0;
  }
  close(fd);
  return 1;
}

/* --- STD-123：目录/元数据 stat/chmod/mkdir/readdir --- */

/** 路径元数据（与 posix FsStatOut 布局一致）。 */
allow(padding) struct FsStatOut {
  size: i64;
  mode: u32;
  is_dir: i32;
  is_file: i32;
  mtime_sec: i64;
}

function fs_stat_c(path: *u8, out: *FsStatOut): i32 { return fs_platform.fs_stat_c(path, out); }
function fs_chmod_c(path: *u8, mode: u32): i32 { return fs_platform.fs_chmod_c(path, mode); }
function fs_mkdir_c(path: *u8, mode: u32): i32 { return fs_platform.fs_mkdir_c(path, mode); }
function fs_unlink_c(path: *u8): i32 { return fs_platform.fs_unlink_c(path); }
function fs_rmdir_c(path: *u8): i32 { return fs_platform.fs_rmdir_c(path); }
function fs_dir_open_c(path: *u8): i64 { return fs_platform.fs_dir_open_c(path); }
function fs_dir_read_c(handle: i64, name_out: *u8, name_cap: i32, is_dir_out: *i32): i32 {
  return fs_platform.fs_dir_read_c(handle, name_out, name_cap, is_dir_out);
}
function fs_dir_close_c(handle: i64): i32 { return fs_platform.fs_dir_close_c(handle); }

/** 默认文件权限 0644。 */
function mode_file_default(): u32 { return 420; }
/** 默认目录权限 0755。 */
function mode_dir_default(): u32 { return 493; }

/** 路径 stat；成功 0。 */
function stat(path: *u8, out: *FsStatOut): i32 {
  return fs_stat_c(path, out);
}

/** 修改权限；成功 0。 */
function chmod(path: *u8, mode: u32): i32 {
  return fs_chmod_c(path, mode);
}

/** 创建目录；成功 0。 */
function mkdir(path: *u8, mode: u32): i32 {
  return fs_mkdir_c(path, mode);
}

/** 删除文件；成功 0（不存在时仍尝试）。 */
function remove_file(path: *u8): i32 {
  return fs_unlink_c(path);
}

/** 删除空目录；成功 0。 */
function remove_dir(path: *u8): i32 {
  return fs_rmdir_c(path);
}

/** 打开目录遍历；失败 -1。 */
function dir_open(path: *u8): i64 {
  return fs_dir_open_c(path);
}

/** 读下一目录项：1=有项，0=EOF，-1=错误。 */
function dir_read(handle: i64, name_out: *u8, name_cap: i32, is_dir_out: *i32): i32 {
  return fs_dir_read_c(handle, name_out, name_cap, is_dir_out);
}

/** 关闭目录句柄；成功 0。 */
function dir_close(handle: i64): i32 {
  return fs_dir_close_c(handle);
}

/** Linux freestanding：syscall 读文件路径是否可用（1/0）。 */
#[cfg(target_os = "linux")]
function freestanding_fs_available(): i32 {
  return fs_freestanding.freestanding_fs_available();
}

/** Linux freestanding：读文件到 buf；成功字节数，失败 -1。 */
#[cfg(target_os = "linux")]
function read_file(path: *u8, buf: *u8, cap: i32): i32 {
  return fs_freestanding.freestanding_read_file_into(path, buf, cap);
}

/** 模块尾占位：transitive import 解析时末位 function 会丢失，须保留非 API 锚点。 */
function fs_module_anchor(): i32 { return 0; }
