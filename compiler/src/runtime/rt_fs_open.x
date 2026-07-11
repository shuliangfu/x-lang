// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-308/452 / P2 runtime rest：path 字节 → open 薄原语。
// 产品实现：seeds/rt_fs_open.from_x.c；hybrid 宏 SHUX_RT_FS_OPEN_FROM_X。
// 🔒 open 经 libc。
// G-02f-452：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。

extern "C" function driver_fs_open_read_path_impl(path: *u8, path_len: i32): i32;
extern "C" function driver_fs_open_write_impl(path: *u8, path_len: i32): i32;

/** 只读 open（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
function driver_fs_open_read_path(path: *u8, path_len: i32): i32 {
  unsafe {
    return driver_fs_open_read_path_impl(path, path_len);
  }
  return -1;
}

/** 写 open CREAT|TRUNC（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
function driver_fs_open_write(path: *u8, path_len: i32): i32 {
  unsafe {
    return driver_fs_open_write_impl(path, path_len);
  }
  return -1;
}
