// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-262 / P2 R0：util 切片（unlink 失败产物 + argv0 basename）。
// 产品默认仍在 seeds/runtime.from_x.c；hybrid 用 seeds/rt_util.from_x.c。
// 🔒 unlink / strrchr / strcmp 经 libc extern。

export extern "C" function unlink(path: *u8): i32;

#[no_mangle]
export function driver_unlink_failed_output(out_path: *u8): void {
  if (out_path == 0 as *u8) {
    return;
  }
  if (out_path[0 as usize] == 0 as u8) {
    return;
  }
  unsafe {
    unlink(out_path);
  }
}

// G-02f-435：driver_argv0_basename_is 暂留 seed C（.x 不支持 "" 字符串字面量）。
