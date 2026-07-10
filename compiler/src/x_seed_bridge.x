// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-27：真迁 .x — seed 链桥接：preprocess 名桥 / heap 薄封装 / io 注册桩。
// 产品：./shux-c -E → seeds/x_seed_bridge.from_x.c（+ C 尾段）。
// C 尾：match-module 静态全局、ast_expr 字段初始化、io_read/write(isize/ssize)、
//       shu_buffer_abi 字段访问、weak driver_read_ptr 桩（语言/ABI 限制）。

extern "C" function preprocess_x_buf(src: *u8, src_len: isize, out_buf: *u8, out_cap: i32): i32;
extern "C" function typeck_std_heap_alloc(size: usize): *u8;
extern "C" function calloc(n: usize, size: usize): *u8;
extern "C" function free(ptr: *u8): void;

#[no_mangle]
function typeck_preprocess_x_buf(src: *u8, src_len: isize, out_buf: *u8, out_cap: i32): i32 {
  unsafe {
    let r: i32 = preprocess_x_buf(src, src_len, out_buf, out_cap);
    return r;
  }
  return 0;
}

#[no_mangle]
function std_heap_alloc_zeroed(size: usize): *u8 {
  unsafe {
    let r: *u8 = calloc(1, size);
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
function std_heap_alloc_zero(size: usize): *u8 {
  return std_heap_alloc_zeroed(size);
}

#[no_mangle]
function std_heap_free(ptr: *u8): void {
  unsafe {
    free(ptr);
  }
}

#[no_mangle]
function std_heap_alloc(size: usize): *u8 {
  unsafe {
    let r: *u8 = typeck_std_heap_alloc(size);
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
function io_read_ptr(handle: u32, timeout_ms: u32): *u8 {
  return 0 as *u8;
}

#[no_mangle]
function io_read_ptr_len(): i32 {
  return 0;
}

#[no_mangle]
function io_register_buffer(ptr: *u8, len: usize): i32 {
  return 0;
}

#[no_mangle]
function io_unregister_buffers(): void {
}

#[no_mangle]
function io_wait_readable(fds: *i32, n: i32, timeout_ms: u32): i32 {
  return 0;
}

#[no_mangle]
function io_register_buffers_4(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize,
                               p3: *u8, l3: usize, nr: u32): i32 {
  return 0;
}

#[no_mangle]
function io_register_buffers_buf(bufs: *u8, nr: i32): i32 {
  return 0;
}

#[no_mangle]
function io_register_buffers_buf_i32(bufs: isize, nr: i32): i32 {
  return io_register_buffers_buf(0 as *u8, nr);
}

#[no_mangle]
function shux_io_register(ptr: *u8, len: usize, handle: usize): i32 {
  return io_register_buffer(ptr, len);
}
