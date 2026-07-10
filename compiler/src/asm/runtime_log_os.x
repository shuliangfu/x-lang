// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-19：runtime_log_os 产品源迁 seeds/runtime_log_os.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_log_os.from_x.c → runtime_log_os.o
// G-02f-105：+ apply_env / rotate / write_sync / emit 薄门闩。

extern "C" function log_apply_env_once_impl(): void;
extern "C" function log_do_rotate_impl(): i32;
extern "C" function log_write_file_sync_impl(buf: *u8, len: usize): i32;
extern "C" function log_write_sync_impl(buf: *u8, len: usize): i32;
extern "C" function log_async_enqueue_impl(buf: *u8, len: usize): i32;
extern "C" function log_emit_bytes_impl(buf: *u8, len: usize): i32;

function runtime_log_os_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-105：log helpers 门闩 ---- */

#[no_mangle]
function log_apply_env_once(): void {
  unsafe {
    log_apply_env_once_impl();
  }
}

#[no_mangle]
function log_do_rotate(): i32 {
  unsafe {
    return log_do_rotate_impl();
  }
  return 0 - 1;
}

#[no_mangle]
function log_write_file_sync(buf: *u8, len: usize): i32 {
  unsafe {
    return log_write_file_sync_impl(buf, len);
  }
  return 0 - 1;
}

#[no_mangle]
function log_write_sync(buf: *u8, len: usize): i32 {
  unsafe {
    return log_write_sync_impl(buf, len);
  }
  return 0 - 1;
}

#[no_mangle]
function log_async_enqueue(buf: *u8, len: usize): i32 {
  unsafe {
    return log_async_enqueue_impl(buf, len);
  }
  return 0 - 1;
}

#[no_mangle]
function log_emit_bytes(buf: *u8, len: usize): i32 {
  unsafe {
    return log_emit_bytes_impl(buf, len);
  }
  return 0 - 1;
}
