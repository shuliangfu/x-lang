// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-262 / P2 R0：util 切片（unlink 失败产物 + argv0 basename）。
// 产品默认仍在 seeds/runtime.from_x.c；hybrid 用 seeds/rt_util.from_x.c。
// 🔒 unlink / strrchr / strcmp 经 libc extern。

extern "C" function unlink(path: *u8): i32;
extern "C" function strrchr(s: *u8, c: i32): *u8;
extern "C" function strcmp(a: *u8, b: *u8): i32;

#[no_mangle]
function driver_unlink_failed_output(out_path: *u8): void {
  if (out_path == 0 as *u8) {
    return;
  }
  if (out_path[0] == 0) {
    return;
  }
  unsafe {
    unlink(out_path);
  }
}

#[no_mangle]
function driver_argv0_basename_is(argv0: *u8, base: *u8): i32 {
  let slash: *u8 = 0 as *u8;
  let name: *u8 = 0 as *u8;
  let empty: *u8 = 0 as *u8;
  if (base == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (argv0 == 0 as *u8) {
      empty = "" as *u8;
      slash = strrchr(empty, 47);
    } else {
      slash = strrchr(argv0, 47);
    }
  }
  if (slash != 0 as *u8) {
    name = (slash as usize + 1) as *u8;
  } else {
    if (argv0 == 0 as *u8) {
      name = "" as *u8;
    } else {
      name = argv0;
    }
  }
  unsafe {
    if (strcmp(name, base) == 0) {
      return 1;
    }
  }
  return 0;
}
