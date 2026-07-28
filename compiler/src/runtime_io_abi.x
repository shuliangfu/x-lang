// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
export extern "C" function close(fd: i32): i32;
export extern "C" function read(fd: i32, buf: *u8, count: usize): isize;
export extern "C" function write(fd: i32, buf: *u8, count: usize): isize;
// libc
export extern "C" function malloc(size: usize): *u8;
export extern "C" function free(ptr: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
/** POSIX lseek — used by pure file-view path (size without fstat struct layout).
 * PLATFORM: POSIX — SEEK_SET=0 SEEK_END=2 on Linux/macOS product hosts. */
export extern "C" function lseek(fd: i32, offset: i64, whence: i32): i64;
/** munmap for release when needs_munmap (legacy mmap views / cold seed path).
 * PLATFORM: POSIX — product pure read_file_view_impl no longer sets needs_munmap. */
export extern "C" function munmap(addr: *u8, len: usize): i32;

// Open-write flag constants (same numeric sources as rt_fs_open.x / std/fs/posix.x).
// PLATFORM: LINUX | MACOS — O_CREAT/O_TRUNC differ; XLANG_O_BINARY=0 on POSIX.
export const RIO_O_RDONLY: i32 = 0;
export const RIO_O_WRONLY: i32 = 1;
export const RIO_SEEK_SET: i32 = 0;
export const RIO_SEEK_END: i32 = 2;

#[cfg(target_os = "linux")]
export const RIO_O_CREAT: i32 = 64;
#[cfg(target_os = "linux")]
export const RIO_O_TRUNC: i32 = 512;

#[cfg(target_os = "macos")]
export const RIO_O_CREAT: i32 = 512;
#[cfg(target_os = "macos")]
export const RIO_O_TRUNC: i32 = 1024;

/** See implementation for details. */
export struct XlangRuntimeFileView {
  data: *u8;
  length: usize;
  needs_free: i32;
  needs_munmap: i32;
}

/**
 * Platform open flags for write (O_WRONLY|O_CREAT|O_TRUNC|XLANG_O_BINARY).
 * Returns: combined flags for libc open.
 * Cap residual pure: was seed C using fcntl.h macros; now cfg(target_os) constants.
 * Track-L: #[no_mangle] short surface name for thin gate + rest consumers.
 * PLATFORM: SHARED contract / LINUX|MACOS flag values (see RIO_O_*).
 */
#[no_mangle]
export function xlang_fs_open_write_flags_impl(): i32 {
  return RIO_O_WRONLY | RIO_O_CREAT | RIO_O_TRUNC;
}

/**
 * Write entire buffer to path (create/trunc 0644).
 * Params: path NUL-C string; data bytes; len length (i64, must be >= 0).
 * Returns: 0 on full write, -1 on error.
 * Cap residual pure: open/write/close loop (no seed C).
 * PLATFORM: SHARED — flags via xlang_fs_open_write_flags_impl; mode 0644=420.
 */
#[no_mangle]
export function xlang_write_path_bytes_impl(path: *u8, data: *u8, len: i64): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (data == 0 as *u8) {
    return -1;
  }
  if (len < 0) {
    return -1;
  }
  let flags: i32 = xlang_fs_open_write_flags_impl();
  let fd: i32 = 0;
  unsafe {
    fd = open(path, flags, 420);
  }
  if (fd < 0) {
    return -1;
  }
  let off: usize = 0 as usize;
  let len_u: usize = len as usize;
  while (off < len_u) {
    unsafe {
      let n: isize = write(fd, data + off, len_u - off);
      if (n < 0) {
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
  if (off == len_u) {
    return 0;
  }
  return -1;
}

/**
 * Release a XlangRuntimeFileView (munmap and/or free).
 * Params: view — pointer to XlangRuntimeFileView (as *u8 ABI).
 * Cap residual pure: free + optional munmap; clears fields.
 * PLATFORM: POSIX munmap when needs_munmap; product pure fill path uses free only.
 */
#[no_mangle]
export function runtime_release_file_view_impl(view: *u8): void {
  if (view == 0 as *u8) {
    return;
  }
  let v: *XlangRuntimeFileView = view as *XlangRuntimeFileView;
  if (v.needs_munmap != 0) {
    if (v.data != 0 as *u8) {
      if (v.length > 0) {
        unsafe {
          munmap(v.data, v.length);
        }
      }
    }
  }
  if (v.needs_free != 0) {
    if (v.data != 0 as *u8) {
      unsafe {
        free(v.data);
      }
    }
  }
  v.data = 0 as *u8;
  v.length = 0 as usize;
  v.needs_free = 0;
  v.needs_munmap = 0;
}

/**
 * Map or load a whole file into XlangRuntimeFileView.
 * Params: path NUL-C string; out — XlangRuntimeFileView* as *u8.
 * Returns: 0 on success, -1 on failure.
 * Cap residual pure: open + lseek size + malloc read (no fstat/mmap struct layout in .x).
 * Empty files: length=0, data=null, no free/munmap.
 * PLATFORM: POSIX lseek; product path prefers malloc (needs_free=1), not mmap.
 */
#[no_mangle]
export function runtime_read_file_view_impl(path: *u8, out: *u8): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (out == 0 as *u8) {
    return -1;
  }
  let v: *XlangRuntimeFileView = out as *XlangRuntimeFileView;
  v.data = 0 as *u8;
  v.length = 0 as usize;
  v.needs_free = 0;
  v.needs_munmap = 0;
  let fd: i32 = 0;
  unsafe {
    fd = open(path, RIO_O_RDONLY, 0);
  }
  if (fd < 0) {
    return -1;
  }
  let size_i: i64 = 0;
  unsafe {
    size_i = lseek(fd, 0 as i64, RIO_SEEK_END);
  }
  if (size_i < 0) {
    unsafe {
      close(fd);
    }
    return -1;
  }
  if (size_i == 0) {
    unsafe {
      close(fd);
    }
    // Empty regular file: zero-length view, no backing store.
    return 0;
  }
  unsafe {
    let back: i64 = lseek(fd, 0 as i64, RIO_SEEK_SET);
    if (back < 0) {
      close(fd);
      return -1;
    }
  }
  // Reuse pure malloc fill (closes fd).
  return xlang_runtime_file_view_read_malloc_impl(fd, size_i, out);
}

/** Exported function `std_fs_fs_open_read`.
 * Read path helper `std_fs_fs_open_read`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function std_fs_fs_open_read(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    // O_RDONLY|XLANG_O_BINARY == 0 on POSIX hosts used by product gates.
    let r: i32 = open(path, 0, 0);
    return r;
  }
  return 0 - 1;
}

/** Exported function `xlang_fs_open_write_flags`.
 * Write path helper `xlang_fs_open_write_flags`.
 * @return i32
 */
#[no_mangle]
export function xlang_fs_open_write_flags(): i32 {
  unsafe {
    return xlang_fs_open_write_flags_impl();
  }
  return 0;
}

// xlang_fs_open_write_mode: see function docblock below.
/** Exported function `xlang_fs_open_write_mode`.
 * Write path helper `xlang_fs_open_write_mode`.
 * @return i32
 */
#[no_mangle]
export function xlang_fs_open_write_mode(): i32 {
  // 0644
  return 420;
}

/** Exported function `std_fs_fs_open_write`.
 * Write path helper `std_fs_fs_open_write`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function std_fs_fs_open_write(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    let fl: i32 = xlang_fs_open_write_flags();
    let md: i32 = xlang_fs_open_write_mode();
    let r: i32 = open(path, fl, md);
    return r;
  }
  return 0 - 1;
}

/** Exported function `std_fs_fs_close`.
 * Implements `std_fs_fs_close`.
 * @param fd i32
 * @return i32
 */
#[no_mangle]
export function std_fs_fs_close(fd: i32): i32 {
  unsafe {
    let r: i32 = close(fd);
    return r;
  }
  return 0 - 1;
}

/** Exported function `std_fs_fs_invalid_handle`.
 * Implements `std_fs_fs_invalid_handle`.
 * @return i32
 */
#[no_mangle]
export function std_fs_fs_invalid_handle(): i32 {
  return 0 - 1;
}

/** Exported function `std_fs_fs_read`.
 * Read path helper `std_fs_fs_read`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @return isize
 */
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

/** Exported function `std_fs_fs_write`.
 * Write path helper `std_fs_fs_write`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @return isize
 */
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

/** Surface short name `fs_posix_close_c` (driver/pipeline import).
 * Params: fd — file descriptor.
 * Returns: close result.
 * Track-L: #[no_mangle] without `export extern "C"` — `extern "C"` definitions currently
 * mangle as module_fs_posix_* and break final link (need bare fs_posix_close_c).
 * Body: std_fs_fs_close → libc close. PLATFORM: SHARED link-name contract.
 */
#[no_mangle]
export function fs_posix_close_c(fd: i32): i32 {
  return std_fs_fs_close(fd);
}

/** Surface short name `fs_posix_read_c` (driver/pipeline import).
 * Params: fd, buf, count — POSIX read arguments.
 * Returns: bytes read or -1.
 * Track-L: #[no_mangle] bare name (see fs_posix_close_c). PLATFORM: SHARED.
 */
#[no_mangle]
export function fs_posix_read_c(fd: i32, buf: *u8, count: usize): isize {
  return std_fs_fs_read(fd, buf, count);
}

/** Surface short name `fs_posix_write_c` (driver/pipeline import).
 * Params: fd, buf, count — POSIX write arguments.
 * Returns: bytes written or -1.
 * Track-L: #[no_mangle] bare name (see fs_posix_close_c). PLATFORM: SHARED.
 */
#[no_mangle]
export function fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize {
  return std_fs_fs_write(fd, buf, count);
}

/* See implementation. */

#[no_mangle]
export function xlang_read_file_into_path(path: *u8, buf: *u8, cap: i64): i32 {
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
    return xlang_read_file_into_path_impl(path, buf, cap);
  }
  return -1;
}

/** Exported function `xlang_write_path_bytes`.
 * Write path helper `xlang_write_path_bytes`.
 * @param path *u8
 * @param data *u8
 * @param len i64
 * @return i32
 */
#[no_mangle]
export function xlang_write_path_bytes(path: *u8, data: *u8, len: i64): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (data == 0 as *u8) {
    return -1;
  }
  unsafe {
    return xlang_write_path_bytes_impl(path, data, len);
  }
  return -1;
}

/** Exported function `runtime_release_file_view`.
 * Implements `runtime_release_file_view`.
 * @param view *u8
 * @return void
 */
#[no_mangle]
export function runtime_release_file_view(view: *u8): void {
  if (view == 0 as *u8) {
    return;
  }
  unsafe {
    runtime_release_file_view_impl(view);
  }
}

/* See implementation. */

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

/** Exported function `runtime_read_file_malloc`.
 * Read path helper `runtime_read_file_malloc`.
 * @param path *u8
 * @param out_len *u8
 * @return *u8
 */
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

/** Exported function `std_sys_os_read_file_into`.
 * Read path helper `std_sys_os_read_file_into`.
 * @param path *u8
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
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

/* See implementation. */

#[no_mangle]
export function xlang_read_fd_into_buf(fd: i32, buf: *u8, cap: i64): i32 {
  unsafe {
    return xlang_read_fd_into_buf_impl(fd, buf, cap);
  }
  return 0 - 1;
}

/** Exported function `xlang_runtime_file_view_read_malloc`.
 * Read path helper `xlang_runtime_file_view_read_malloc`.
 * @param fd i32
 * @param size i64
 * @param out *u8
 * @return i32
 */
#[no_mangle]
export function xlang_runtime_file_view_read_malloc(fd: i32, size: i64, out: *u8): i32 {
  unsafe {
    return xlang_runtime_file_view_read_malloc_impl(fd, size, out);
  }
  return 0 - 1;
}

/* Cap residual pure (wave): flags_impl / write_path_bytes_impl /
 * release_file_view_impl / read_file_view_impl are defined near the top of this file. */

/** Exported function `xlang_read_fd_into_buf_impl`.
 * Read path helper `xlang_read_fd_into_buf_impl`.
 * @param fd i32
 * @param buf *u8
 * @param cap i64
 * @return i32
 */
#[no_mangle]
export function xlang_read_fd_into_buf_impl(fd: i32, buf: *u8, cap: i64): i32 {
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

/** See implementation for details. */
#[no_mangle]
export function xlang_runtime_file_view_read_malloc_impl(fd: i32, size: i64, out: *u8): i32 {
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
  // See implementation.
  let out_view: *XlangRuntimeFileView = out as *XlangRuntimeFileView;
  out_view.data = buf;
  out_view.length = size_u;
  out_view.needs_free = 1;
  out_view.needs_munmap = 0;
  return 0;
}

/** Exported function `runtime_read_file_malloc_impl`.
 * Read path helper `runtime_read_file_malloc_impl`.
 * @param path *u8
 * @param out_len *u8
 * @return *u8
 */
#[no_mangle]
export function runtime_read_file_malloc_impl(path: *u8, out_len: *u8): *u8 {
  let view: XlangRuntimeFileView = XlangRuntimeFileView {
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

/** Exported function `xlang_read_file_into_path_impl`.
 * Read path helper `xlang_read_file_into_path_impl`.
 * @param path *u8
 * @param buf *u8
 * @param cap i64
 * @return i32
 */
#[no_mangle]
export function xlang_read_file_into_path_impl(path: *u8, buf: *u8, cap: i64): i32 {
  if (cap > 2147483647) {
    return -1;
  }
  let fd: i32 = 0;
  unsafe {
    // POSIX: O_RDONLY|XLANG_O_BINARY == 0
    fd = open(path, 0, 0);
  }
  if (fd < 0) {
    return -1;
  }
  let n: i32 = xlang_read_fd_into_buf_impl(fd, buf, cap);
  unsafe {
    close(fd);
  }
  return n;
}

/** Exported function `std_sys_os_read_file_into_impl`.
 * Read path helper `std_sys_os_read_file_into_impl`.
 * @param path *u8
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
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
    // POSIX: O_RDONLY|XLANG_O_BINARY == 0
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
