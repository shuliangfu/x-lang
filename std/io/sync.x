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

// std.io.sync — F-03 v2/v3：hosted 同步 read/write/readv/writev（Linux/macOS libc FFI）
//
// 【文件职责】
// 从 io.c 迁出的 POSIX 同步路径：io_read/io_write、批量 readv/writev、poll 多 fd 等待、
// 固定 buffer 池（模块级静态，v1 非真 TLS）。timeout_ms 保留 ABI，v1 忽略（直接 read/write）。
//
// 【链接】
// hosted `-o exe` 由链接器解析 read/write/readv/writev/poll（-lc）；无 io.o。

/** readv/writev iovec 布局。 */
allow(padding) struct Iovec { base: *u8; len: usize; }

/** pollfd 布局（fd/events/revents）。 */
allow(padding) struct PollFd { fd: i32; events: i16; revents: i16; }

/** 与 std.io.driver Buffer ABI 一致（ptr+len+handle）。 */
allow(padding) struct IoBatchBuf { ptr: *u8; len: usize; handle: usize; }

/** 固定 buffer 池最大块数（与 io.c IO_FIXED_MAX 对齐）。 */
const IO_FIXED_MAX: u32 = 8;

/** 切片式批量读最大段数（与 io.c IO_READV_BUF_MAX 对齐）。 */
const IO_READV_BUF_MAX: i32 = 16;

/** 模块级固定 buffer 池（v1：单线程语义；多线程并发注册不隔离）。 */
let io_fixed_ptr: [8]*u8 = [
  0 as *u8, 0 as *u8, 0 as *u8, 0 as *u8,
  0 as *u8, 0 as *u8, 0 as *u8, 0 as *u8,
];
let io_fixed_len: [8]usize = [
  0, 0, 0, 0,
  0, 0, 0, 0,
];
let io_fixed_nr: u32 = 0;

extern "C" function read(fd: i32, buf: *u8, count: usize): isize;
extern "C" function write(fd: i32, buf: *u8, count: usize): isize;
extern "C" function readv(fd: i32, iov: *Iovec, iovcnt: i32): isize;
extern "C" function writev(fd: i32, iov: *Iovec, iovcnt: i32): isize;
extern "C" function poll(fds: *PollFd, nfds: u64, timeout: i32): i32;

/** libc FFI 须 unsafe；集中薄包装，避免各 io_* 重复写 unsafe 块。 */
function io_libc_read(fd: i32, buf: *u8, count: usize): isize {
  unsafe { return read(fd, buf, count); }
}
function io_libc_write(fd: i32, buf: *u8, count: usize): isize {
  unsafe { return write(fd, buf, count); }
}
function io_libc_readv(fd: i32, iov: *Iovec, iovcnt: i32): isize {
  unsafe { return readv(fd, iov, iovcnt); }
}
function io_libc_writev(fd: i32, iov: *Iovec, iovcnt: i32): isize {
  unsafe { return writev(fd, iov, iovcnt); }
}
function io_libc_poll(fds: *PollFd, nfds: i32, timeout: i32): i32 {
  unsafe { return poll(fds, nfds, timeout); }
}

/**
 * 同步读：fd 为 handle（0=stdin，≥2 为任意 fd）。
 * timeout_ms 保留 ABI；v1 忽略，直接 libc read。
 * 返回读入字节数，0=EOF，-1=错误。
 */
function io_read(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  if (timeout_ms > 0) {
    /* v1：超时未实现，仍走阻塞 read。 */
  }
  return io_libc_read(fd, buf, count);
}

/**
 * 同步写：fd 为 handle（1=stdout，≥2 为任意 fd）。
 * timeout_ms 保留 ABI；v1 忽略，直接 libc write。
 */
function io_write(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  if (timeout_ms > 0) {
    /* v1：超时未实现。 */
  }
  return io_libc_write(fd, buf, count);
}

/**
 * 批量读：最多 4 段；timeout_ms=0 且 n≥2 时走 readv，否则逐段 io_read。
 * 裸名 io_read_batch（net.o 弱桩覆盖）由 runtime_asm_io_stubs.o 强符号提供；
 * 本定义走模块前缀 std_io_sync_io_read_batch，匹配 backend.x 的 io_platform.io_read_batch 限定调用。
 */
function io_read_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  if (n <= 0 || n > 4) {
    return -1;
  }
  if (n == 1) {
    return io_read(fd, p0, l0, timeout_ms);
  }
  if (timeout_ms == 0) {
    let iov: [4]Iovec;
    iov[0].base = p0;
    iov[0].len = l0;
    iov[1].base = p1;
    iov[1].len = l1;
    if (n >= 3) {
      iov[2].base = p2;
      iov[2].len = l2;
    }
    if (n >= 4) {
      iov[3].base = p3;
      iov[3].len = l3;
    }
    return io_libc_readv(fd, &iov[0], n);
  }
  let total: isize = 0;
  let r0: isize = io_read(fd, p0, l0, timeout_ms);
  if (r0 < 0) { return -1; }
  total = total + r0;
  if (n == 1) { return total; }
  let r1: isize = io_read(fd, p1, l1, timeout_ms);
  if (r1 < 0) { return -1; }
  total = total + r1;
  if (n == 2) { return total; }
  let r2: isize = io_read(fd, p2, l2, timeout_ms);
  if (r2 < 0) { return -1; }
  total = total + r2;
  if (n == 3) { return total; }
  let r3: isize = io_read(fd, p3, l3, timeout_ms);
  if (r3 < 0) { return -1; }
  return total + r3;
}

/**
 * 批量写：最多 4 段；timeout_ms=0 且 n≥2 时走 writev，否则逐段 io_write。
 * 裸名 io_write_batch（net.o 弱桩覆盖）由 runtime_asm_io_stubs.o 强符号提供；
 * 本定义走模块前缀 std_io_sync_io_write_batch，匹配 backend.x 的 io_platform.io_write_batch 限定调用。
 */
function io_write_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  if (n <= 0 || n > 4) {
    return -1;
  }
  if (n == 1) {
    return io_write(fd, p0, l0, timeout_ms);
  }
  if (timeout_ms == 0) {
    let iov: [4]Iovec;
    iov[0].base = p0;
    iov[0].len = l0;
    iov[1].base = p1;
    iov[1].len = l1;
    if (n >= 3) {
      iov[2].base = p2;
      iov[2].len = l2;
    }
    if (n >= 4) {
      iov[3].base = p3;
      iov[3].len = l3;
    }
    return io_libc_writev(fd, &iov[0], n);
  }
  let total: isize = 0;
  let r0: isize = io_write(fd, p0, l0, timeout_ms);
  if (r0 < 0) { return -1; }
  total = total + r0;
  if (n == 1) { return total; }
  let r1: isize = io_write(fd, p1, l1, timeout_ms);
  if (r1 < 0) { return -1; }
  total = total + r1;
  if (n == 2) { return total; }
  let r2: isize = io_write(fd, p2, l2, timeout_ms);
  if (r2 < 0) { return -1; }
  total = total + r2;
  if (n == 3) { return total; }
  let r3: isize = io_write(fd, p3, l3, timeout_ms);
  if (r3 < 0) { return -1; }
  return total + r3;
}

/**
 * 切片式批量读：bufs 指向 n 个 IoBatchBuf（1..16）；timeout_ms=0 时 readv。
 */
function io_read_batch_buf(fd: i32, bufs: *IoBatchBuf, n: i32, timeout_ms: u32): isize {
  if (n <= 0 || n > IO_READV_BUF_MAX || bufs == 0) {
    return -1;
  }
  if (n == 1) {
    return io_read(fd, bufs[0].ptr, bufs[0].len, timeout_ms);
  }
  if (timeout_ms == 0) {
    let iov: [16]Iovec;
    let i: i32 = 0;
    while (i < n) {
      iov[i].base = bufs[i].ptr;
      iov[i].len = bufs[i].len;
      i = i + 1;
    }
    return io_libc_readv(fd, &iov[0], n);
  }
  let total: isize = 0;
  let i2: i32 = 0;
  while (i2 < n) {
    let r: isize = io_read(fd, bufs[i2].ptr, bufs[i2].len, timeout_ms);
    if (r < 0) { return -1; }
    total = total + r;
    i2 = i2 + 1;
  }
  return total;
}

/** 切片式批量写：语义同 io_read_batch_buf。 */
function io_write_batch_buf(fd: i32, bufs: *IoBatchBuf, n: i32, timeout_ms: u32): isize {
  if (n <= 0 || n > IO_READV_BUF_MAX || bufs == 0) {
    return -1;
  }
  if (n == 1) {
    return io_write(fd, bufs[0].ptr, bufs[0].len, timeout_ms);
  }
  if (timeout_ms == 0) {
    let iov: [16]Iovec;
    let i: i32 = 0;
    while (i < n) {
      iov[i].base = bufs[i].ptr;
      iov[i].len = bufs[i].len;
      i = i + 1;
    }
    return io_libc_writev(fd, &iov[0], n);
  }
  let total: isize = 0;
  let i2: i32 = 0;
  while (i2 < n) {
    let r: isize = io_write(fd, bufs[i2].ptr, bufs[i2].len, timeout_ms);
    if (r < 0) { return -1; }
    total = total + r;
    i2 = i2 + 1;
  }
  return total;
}

/**
 * 注册单块固定 buffer（等同 nr=1 的 io_register_buffers_4）。
 * 返回 1 成功，0 失败。
 */
function io_register_buffer(ptr: *u8, len: usize): i32 {
  return io_register_buffers_4(ptr, len, 0, 0, 0, 0, 0, 0, 1);
}

/**
 * 注册固定 buffer 池（最多 4 块）；Linux io_uring fixed 已 stub，仅存 ptr/len 供 read_fixed。
 */
function io_register_buffers_4(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, nr: u32): i32 {
  let i: u32 = 0;
  if (nr == 0 || nr > 4) {
    return 0;
  }
  io_fixed_nr = 0;
  if (nr >= 1) {
    if (p0 == 0) { return 0; }
    io_fixed_ptr[0] = p0;
    io_fixed_len[0] = l0;
    i = 1;
  }
  if (nr >= 2) {
    if (p1 == 0) { return 0; }
    io_fixed_ptr[1] = p1;
    io_fixed_len[1] = l1;
    i = 2;
  }
  if (nr >= 3) {
    if (p2 == 0) { return 0; }
    io_fixed_ptr[2] = p2;
    io_fixed_len[2] = l2;
    i = 3;
  }
  if (nr >= 4) {
    if (p3 == 0) { return 0; }
    io_fixed_ptr[3] = p3;
    io_fixed_len[3] = l3;
    i = 4;
  }
  io_fixed_nr = i;
  return 1;
}

/** 按指针+块数注册固定 buffer 池（1..8）；codegen 可能传 intptr。 */
function io_register_buffers_buf(bufs: *IoBatchBuf, nr: i32): i32 {
  if (nr <= 0 || nr > (IO_FIXED_MAX as i32) || bufs == 0) {
    return 0;
  }
  io_fixed_nr = 0;
  let i: i32 = 0;
  while (i < nr) {
    if (bufs[i].ptr == 0) {
      return 0;
    }
    io_fixed_ptr[i] = bufs[i].ptr;
    io_fixed_len[i] = bufs[i].len;
    i = i + 1;
  }
  io_fixed_nr = nr as u32;
  return 1;
}

/** 注销固定 buffer 池。 */
function io_unregister_buffers(): void {
  io_fixed_nr = 0;
}

/**
 * 使用已注册固定 buffer 读：buf_index 为池下标；offset+len 须 ≤ 注册长度。
 */
function io_read_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  if (buf_index >= io_fixed_nr) {
    return -1;
  }
  let base: *u8 = io_fixed_ptr[buf_index];
  let cap: usize = io_fixed_len[buf_index];
  if (base == 0 || offset > cap || len > cap - offset) {
    return -1;
  }
  let addr: *u8 = base + offset;
  return io_read(fd, addr, len, timeout_ms);
}

/** 使用已注册固定 buffer 写。 */
function io_write_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  if (buf_index >= io_fixed_nr) {
    return -1;
  }
  let base: *u8 = io_fixed_ptr[buf_index];
  let cap: usize = io_fixed_len[buf_index];
  if (base == 0 || offset > cap || len > cap - offset) {
    return -1;
  }
  let addr: *u8 = base + offset;
  return io_write(fd, addr, len, timeout_ms);
}

/**
 * 多 fd 就绪等待：fds 指向 n 个 i32（fd 数组），poll 等待任意可读。
 * 返回第一个就绪下标 0..n-1，超时/错误 -1。n 建议 ≤8。
 */
function io_wait_readable(fds: *i32, n: i32, timeout_ms: u32): i32 {
  if (fds == 0 || n <= 0 || n > 8) {
    return -1;
  }
  let pfd: [8]PollFd;
  let i: i32 = 0;
  while (i < n) {
    pfd[i].fd = fds[i];
    pfd[i].events = 1; /* POLLIN */
    pfd[i].revents = 0;
    i = i + 1;
  }
  let to: i32 = -1;
  if (timeout_ms > 0) {
    to = timeout_ms as i32;
  }
  let r: i32 = io_libc_poll(&pfd[0], n, to);
  if (r <= 0) {
    return -1;
  }
  i = 0;
  while (i < n) {
    if ((pfd[i].revents & 1) != 0 || (pfd[i].revents & 16) != 0) {
      return i;
    }
    i = i + 1;
  }
  return -1;
}
