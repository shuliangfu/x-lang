// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-305 / P2 R2 真迁：lib root 指针可用性 + 默认根 + from_key。
// 产品 PREFER_X_O：.x 吃满三业务符号；FROM_X rest 仅前向 + marker。
// 🔒 getenv 经 libc extern；bufs 扁平成 *u8 行步进 512；out_arr 为 **u8。

export extern "C" function getenv(name: *u8): *u8;
export extern "C" function driver_emit_lib_root_count(state: *u8): i32;
export extern "C" function driver_emit_lib_root_len(state: *u8, i: i32): i32;
export extern "C" function driver_emit_lib_root_copy(state: *u8, i: i32, dst: *u8, cap: i32): void;

/** 指针是否可安全当 lib root 用（非 null 且非空串）。 */
#[no_mangle]
export function driver_lib_root_ptr_usable(p: *u8): i32 {
  if (p == 0 as *u8) {
    return 0;
  }
  if (p[0] == 0) {
    return 0;
  }
  return 1;
}

/**
 * 写入默认 lib root：优先 SHUX_LIB（拷贝到 root_buf[0..511]），否则 "."。
 * root_buf 容量约定 512（与 seed/C 调用方一致）。
 */
#[no_mangle]
export function driver_lib_root_default(root_buf: *u8): void {
  root_buf[0] = 46;
  root_buf[1] = 0;
  let def: *u8 = 0 as *u8;
  unsafe {
    def = getenv("SHUX_LIB");
  }
  if (driver_lib_root_ptr_usable(def) == 0) {
    return;
  }
  let i: i32 = 0;
  while (i < 511) {
    let c: u8 = def[i];
    root_buf[i] = c;
    if (c == 0) {
      return;
    }
    i = i + 1;
  }
  root_buf[511] = 0;
}

/**
 * 从 emit sidecar 键填充 lib_roots：out_arr[i] 指向 bufs 第 i 行（行宽 512）。
 * n<=0 时写默认根并返回 1；n 封顶 16（X_FULL_MAX_LIB_ROOTS）。
 */
#[no_mangle]
export function driver_lib_roots_from_key(lib_key: *u8, out_arr: **u8, bufs: *u8): i32 {
  let n: i32 = 0;
  unsafe {
    n = driver_emit_lib_root_count(lib_key);
  }
  if (n <= 0) {
    driver_lib_root_default(bufs);
    out_arr[0] = bufs;
    return 1;
  }
  if (n > 16) {
    n = 16;
  }
  let i: i32 = 0;
  while (i < n) {
    let base: i32 = i * 512;
    let row: *u8 = &bufs[base];
    let llen: i32 = 0;
    unsafe {
      llen = driver_emit_lib_root_len(lib_key, i);
    }
    if (llen <= 0 || llen >= 512) {
      row[0] = 46;
      row[1] = 0;
    } else {
      unsafe {
        driver_emit_lib_root_copy(lib_key, i, row, 512);
      }
      row[llen] = 0;
    }
    out_arr[i] = row;
    i = i + 1;
  }
  return n;
}
