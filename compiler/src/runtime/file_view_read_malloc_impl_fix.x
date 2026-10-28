// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// 10.46: Win PE root-fix for file_view / read_file_malloc SEGV. Tip pure-asm
// hoisted `zero_ptr = buf + size` before `buf = malloc(...)`, so the NUL
// write stored through the size value (e.g. 0x2a) and crashed. Route the NUL
// through write_u8_at so the post-malloc buf is passed as an arg.
// Overlay is first-wins on PE allow-multiple ahead of src/runtime_io_abi.o.
// Also provides runtime_read_file_malloc (public entry): same-object
// wrapper→impl calls ignore first-wins, so the public symbol must be
// overlaid (and the bad T weakened on a link copy of runtime_io_abi.o).
// PLATFORM: WINDOWS · also safe on LINUX/MACOS.

export extern "C" function close(fd: i32): i32;
export extern "C" function xlang_sys_read(fd: i32, buf: *u8, count: usize): isize;
export extern "C" function malloc(size: usize): *u8;
export extern "C" function free(ptr: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

export extern "C" function runtime_read_file_view(path: *u8, out: *u8): i32;
export extern "C" function runtime_release_file_view(view: *u8): void;

export struct XlangRuntimeFileView {
  data: *u8;
  length: usize;
  needs_free: i32;
  needs_munmap: i32;
}

/** Store one byte at buf[idx]. Keeps the pointer as a call arg so codegen
 * cannot reuse a pre-malloc CSE of `buf + idx`. */
export function write_u8_at(buf: *u8, idx: usize, v: u8): void {
  buf[idx] = v;
}

/**
 * Read `size` bytes from fd into a fresh malloc buffer; NUL-terminate;
 * fill out as XlangRuntimeFileView. Closes fd on all paths.
 */
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
      let n: isize = xlang_sys_read(fd, buf + off, size_u - off);
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
  write_u8_at(buf, size_u, 0);
  let out_view: *XlangRuntimeFileView = out as *XlangRuntimeFileView;
  out_view.data = buf;
  out_view.length = size_u;
  out_view.needs_free = 1;
  out_view.needs_munmap = 0;
  return 0;
}

/**
 * Public read-file entry used by rt_run_* / Cap. Overlaid so PE callers do
 * not enter the bad same-object wrapper→impl in tip runtime_io_abi.o.
 */
#[no_mangle]
export function runtime_read_file_malloc_impl(path: *u8, out_len: *u8): *u8 {
  let view: XlangRuntimeFileView = {
    data: 0 as *u8,
    length: 0,
    needs_free: 0,
    needs_munmap: 0,
  };
  let view_rc: i32 = 0;
  unsafe {
    view_rc = runtime_read_file_view(path, &view as *u8);
  }
  if (view_rc != 0) {
    return 0 as *u8;
  }
  let buf: *u8 = 0 as *u8;
  unsafe {
    buf = malloc(view.length + 1);
  }
  if (buf == 0 as *u8) {
    unsafe {
      runtime_release_file_view(&view as *u8);
    }
    return 0 as *u8;
  }
  if (view.length > 0) {
    unsafe {
      memcpy(buf, view.data, view.length);
    }
  }
  write_u8_at(buf, view.length, 0);
  if (out_len != 0 as *u8) {
    let out_len_ptr: *usize = out_len as *usize;
    out_len_ptr[0] = view.length;
  }
  unsafe {
    runtime_release_file_view(&view as *u8);
  }
  return buf;
}

#[no_mangle]
export function runtime_read_file_malloc(path: *u8, out_len: *u8): *u8 {
  return runtime_read_file_malloc_impl(path, out_len);
}
