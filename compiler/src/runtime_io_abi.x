// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-29/44/57/58/59：真迁 .x — std.fs / posix + 路径读写 + file_view + open_write 槽。
// 产品：./shux-c -E → seeds/runtime_io_abi.from_x.c（+ C 尾段）。
// C 尾：open_write flags/mode 平台常量、file_view mmap bulk、os_read_file_into 循环。
// G-02f-59：+ shux_fs_open_write_flags / mode 薄门闩（常量本体 C）。
// G-02f-96：+ shux_read_fd_into_buf / file_view_read_malloc 门闩。

export extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
export extern "C" function close(fd: i32): i32;
export extern "C" function read(fd: i32, buf: *u8, count: usize): isize;
export extern "C" function write(fd: i32, buf: *u8, count: usize): isize;
// libc
export extern "C" function malloc(size: usize): *u8;
export extern "C" function free(ptr: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

// 保留 seed 的 _impl（依赖平台 #ifdef / mmap / fstat / O_* flags）
export extern "C" function shux_fs_open_write_flags_impl(): i32;
export extern "C" function shux_write_path_bytes_impl(path: *u8, data: *u8, len: i64): i32;
export extern "C" function runtime_release_file_view_impl(view: *u8): void;
export extern "C" function runtime_read_file_view_impl(path: *u8, out: *u8): i32;

/** 文件视图（与 C ShuxRuntimeFileView ABI 兼容，24B 无 padding）。
 *  data 8B + length 8B + needs_free 4B + needs_munmap 4B = 24B 对齐 8B。 */
export struct ShuxRuntimeFileView {
  data: *u8;
  length: usize;
  needs_free: i32;
  needs_munmap: i32;
}

#[no_mangle]
export function std_fs_fs_open_read(path: *u8): i32 {
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
export function shux_fs_open_write_flags(): i32 {
  unsafe {
    return shux_fs_open_write_flags_impl();
  }
  return 0;
}

// G-02f-120 / G-02f-334：mode 须在 open_write 之前（-E 产物 C 无前向声明）
#[no_mangle]
export function shux_fs_open_write_mode(): i32 {
  // 0644
  return 420;
}

#[no_mangle]
export function std_fs_fs_open_write(path: *u8): i32 {
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
export function std_fs_fs_close(fd: i32): i32 {
  unsafe {
    let r: i32 = close(fd);
    return r;
  }
  return 0 - 1;
}

#[no_mangle]
export function std_fs_fs_invalid_handle(): i32 {
  return 0 - 1;
}

#[no_mangle]
export function std_fs_fs_read(fd: i32, buf: *u8, count: usize): isize {
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
export function std_fs_fs_write(fd: i32, buf: *u8, count: usize): isize {
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
export function fs_posix_close_c(fd: i32): i32 {
  return std_fs_fs_close(fd);
}

#[no_mangle]
export function fs_posix_read_c(fd: i32, buf: *u8, count: usize): isize {
  return std_fs_fs_read(fd, buf, count);
}

#[no_mangle]
export function fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize {
  return std_fs_fs_write(fd, buf, count);
}

/* ---- G-02f-57：路径读/写与 file_view 释放 ---- */

#[no_mangle]
export function shux_read_file_into_path(path: *u8, buf: *u8, cap: i64): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (buf == 0 as *u8) {
    return -1;
  }
  if (cap == 0) {
    return -1;
  }
  unsafe {
    return shux_read_file_into_path_impl(path, buf, cap);
  }
  return -1;
}

#[no_mangle]
export function shux_write_path_bytes(path: *u8, data: *u8, len: i64): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (data == 0 as *u8) {
    return -1;
  }
  unsafe {
    return shux_write_path_bytes_impl(path, data, len);
  }
  return -1;
}

#[no_mangle]
export function runtime_release_file_view(view: *u8): void {
  if (view == 0 as *u8) {
    return;
  }
  unsafe {
    runtime_release_file_view_impl(view);
  }
}

/* ---- G-02f-58：file_view 读入 / malloc 整文件 / os_read_file_into ---- */

#[no_mangle]
export function runtime_read_file_view(path: *u8, out: *u8): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (out == 0 as *u8) {
    return -1;
  }
  unsafe {
    return runtime_read_file_view_impl(path, out);
  }
  return -1;
}

#[no_mangle]
export function runtime_read_file_malloc(path: *u8, out_len: *u8): *u8 {
  if (path == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return runtime_read_file_malloc_impl(path, out_len);
  }
  return 0 as *u8;
}

#[no_mangle]
export function std_sys_os_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (buf == 0 as *u8) {
    return -1;
  }
  if (cap <= 0) {
    return -1;
  }
  unsafe {
    return std_sys_os_read_file_into_impl(path, buf, cap);
  }
  return -1;
}

/* ---- G-02f-96：fd 读缓冲 / file_view malloc 门闩 ---- */

#[no_mangle]
export function shux_read_fd_into_buf(fd: i32, buf: *u8, cap: i64): i32 {
  unsafe {
    return shux_read_fd_into_buf_impl(fd, buf, cap);
  }
  return 0 - 1;
}

#[no_mangle]
export function shux_runtime_file_view_read_malloc(fd: i32, size: i64, out: *u8): i32 {
  unsafe {
    return shux_runtime_file_view_read_malloc_impl(fd, size, out);
  }
  return 0 - 1;
}

/* open_write_mode 已上移到 open_write 之前（G-02f-334） */

/* ---- G-02f-rest：rest→.x 迁移：5 个 _impl 函数真迁 .x（POSIX read/malloc/memcpy） ----
 * 4 个 _impl 保留 seed（依赖平台 #ifdef / mmap / fstat / O_* flags）：
 *   runtime_read_file_view_impl / runtime_release_file_view_impl /
 *   shux_write_path_bytes_impl / shux_fs_open_write_flags_impl */

/** POSIX read 循环读 fd 到 buf[0..cap-1]；成功返回读入字节数，失败 -1。 */
#[no_mangle]
export function shux_read_fd_into_buf_impl(fd: i32, buf: *u8, cap: i64): i32 {
  if (fd < 0) {
    return -1;
  }
  if (buf == 0 as *u8) {
    return -1;
  }
  if (cap == 0) {
    return -1;
  }
  if (cap > 2147483647) {
    return -1;
  }
  let off: usize = 0 as usize;
  let cap_u: usize = cap as usize;
  while (off < cap_u) {
    unsafe {
      let n: isize = read(fd, buf + off, cap_u - off);
      if (n < 0) {
        return -1;
      }
      if (n == 0) {
        break;
      }
      off = off + (n as usize);
    }
  }
  return off as i32;
}

/** malloc + read 循环读 fd 到堆缓冲；成功 0，失败 -1。
 *  调用方：runtime_read_file_view_impl（mmap 失败时回退此函数）。 */
#[no_mangle]
export function shux_runtime_file_view_read_malloc_impl(fd: i32, size: i64, out: *u8): i32 {
  let size_u: usize = size as usize;
  let buf: *u8 = 0 as *u8;
  unsafe {
    buf = malloc(size_u + 1);
  }
  if (buf == 0 as *u8) {
    unsafe {
      close(fd);
    }
    return -1;
  }
  let off: usize = 0 as usize;
  while (off < size_u) {
    unsafe {
      let n: isize = read(fd, buf + off, size_u - off);
      if (n < 0) {
        free(buf);
        close(fd);
        return -1;
      }
      if (n == 0) {
        break;
      }
      off = off + (n as usize);
    }
  }
  unsafe {
    close(fd);
  }
  if (off != size_u) {
    unsafe {
      free(buf);
    }
    return -1;
  }
  // buf[size] = '\0'
  let zero_ptr: *u8 = buf + size_u;
  zero_ptr[0] = 0;
  // 赋值 out 字段（type-erased *u8 强转为 *ShuxRuntimeFileView）
  let out_view: *ShuxRuntimeFileView = out as *ShuxRuntimeFileView;
  out_view.data = buf;
  out_view.length = size_u;
  out_view.needs_free = 1;
  out_view.needs_munmap = 0;
  return 0;
}

/** 读整文件到堆缓冲（经 runtime_read_file_view thin wrapper）；成功返回 NUL 结尾缓冲，失败 NULL。 */
#[no_mangle]
export function runtime_read_file_malloc_impl(path: *u8, out_len: *u8): *u8 {
  let view: ShuxRuntimeFileView = ShuxRuntimeFileView {
    data: 0 as *u8,
    length: 0,
    needs_free: 0,
    needs_munmap: 0,
  };
  let view_rc: i32 = runtime_read_file_view(path, &view as *u8);
  if (view_rc != 0) {
    return 0 as *u8;
  }
  let buf: *u8 = 0 as *u8;
  unsafe {
    buf = malloc(view.length + 1);
  }
  if (buf == 0 as *u8) {
    runtime_release_file_view(&view as *u8);
    return 0 as *u8;
  }
  if (view.length > 0) {
    unsafe {
      memcpy(buf, view.data, view.length);
    }
  }
  // buf[view.length] = '\0'
  let zero_ptr: *u8 = buf + view.length;
  zero_ptr[0] = 0;
  if (out_len != 0 as *u8) {
    let out_len_ptr: *usize = out_len as *usize;
    out_len_ptr[0] = view.length;
  }
  runtime_release_file_view(&view as *u8);
  return buf;
}

/** open(O_RDONLY) + read 循环读文件前缀到 buf；成功返回读入字节数，失败 -1。 */
#[no_mangle]
export function shux_read_file_into_path_impl(path: *u8, buf: *u8, cap: i64): i32 {
  if (cap > 2147483647) {
    return -1;
  }
  let fd: i32 = 0;
  unsafe {
    // POSIX: O_RDONLY|SHUX_O_BINARY == 0
    fd = open(path, 0, 0);
  }
  if (fd < 0) {
    return -1;
  }
  let n: i32 = shux_read_fd_into_buf_impl(fd, buf, cap);
  unsafe {
    close(fd);
  }
  return n;
}

/** std.sys.os_read_file_into 的 C 链接符号；成功返回读入字节数，失败 -1。 */
#[no_mangle]
export function std_sys_os_read_file_into_impl(path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (buf == 0 as *u8) {
    return -1;
  }
  if (cap <= 0) {
    return -1;
  }
  let fd: i32 = 0;
  unsafe {
    // POSIX: O_RDONLY|SHUX_O_BINARY == 0
    fd = open(path, 0, 0);
  }
  if (fd < 0) {
    return -1;
  }
  let total: i32 = 0;
  while (total < cap) {
    let chunk: i32 = cap - total;
    unsafe {
      let r: isize = read(fd, buf + (total as usize), chunk as usize);
      if (r < 0) {
        close(fd);
        return -1;
      }
      if (r == 0) {
        break;
      }
      total = total + (r as i32);
    }
  }
  unsafe {
    close(fd);
  }
  return total;
}
