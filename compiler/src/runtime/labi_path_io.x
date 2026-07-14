// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-270 / P2 link_abi L3：路径探活 thin shell → R2 full。
// 产品：PREFER_X_O → g05_try_x_to_o；冷启动 seeds/labi_path_io.from_x.c。
// hybrid 宏 SHUX_LABI_PATH_IO_FROM_X（FROM_X rest 业务 H=0，仅 marker）。
//
// R2 full：.x 吃满 3 公共门闩 + count：
//   - shux_path_is_nonempty_regular_file → _impl（stat 🔒 Cap residual mega rest）
//   - asm_link_obj_skip_missing：组合 nonempty
//   - shux_runtime_o_realpath_if_exists → _impl（realpath+skip 🔒 Cap residual）
// 不做 struct stat 布局；不做 libc realpath 原型（避免 *u8 与 char* 冲突）。

export extern "C" function shux_path_is_nonempty_regular_file_impl(path: *u8): i32;
export extern "C" function shux_runtime_o_realpath_if_exists_impl(path: *u8, resolved: *u8): *u8;

#[no_mangle]
export function shux_path_is_nonempty_regular_file(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (path[0] == 0) {
    return 0;
  }
  unsafe {
    return shux_path_is_nonempty_regular_file_impl(path);
  }
  return 0;
}

#[no_mangle]
export function asm_link_obj_skip_missing(path: *u8): *u8 {
  if (path == 0 as *u8) {
    return 0 as *u8;
  }
  if (path[0] == 0) {
    return 0 as *u8;
  }
  if (shux_path_is_nonempty_regular_file(path) == 0) {
    return 0 as *u8;
  }
  return path;
}

#[no_mangle]
export function shux_runtime_o_realpath_if_exists(path: *u8, resolved: *u8): *u8 {
  if (path == 0 as *u8) {
    return 0 as *u8;
  }
  if (path[0] == 0) {
    return 0 as *u8;
  }
  if (resolved == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return shux_runtime_o_realpath_if_exists_impl(path, resolved);
  }
  return 0 as *u8;
}

/* Pure audit: number of L3 thin path-IO gates in this slice. */
#[no_mangle]
export function labi_path_io_count(): i32 {
  return 3;
}
