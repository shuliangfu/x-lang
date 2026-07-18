// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-262 / P2 R0 util → R2 真迁：unlink 失败产物 + argv0 basename 全量 .x。
// 产品 PREFER_X_O：thin.x（本文件）+ rest seed 在 FROM_X 下为空体（仅前向声明）。
// 🔒 unlink 经 libc extern；basename 用纯索引（/ 与 \\），无 strrchr/空串依赖。

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

/** argv0 末段是否等于 base（支持 / 与 Windows \\）；argv0=null 视作空名。 */
#[no_mangle]
export function driver_argv0_basename_is(argv0: *u8, base: *u8): i32 {
  if (base == 0 as *u8) {
    return 0;
  }
  if (argv0 != 0 as *u8) {
    let i: i32 = 0;
    let last: i32 = 0 - 1;
    while (i < 4096) {
      let c: u8 = argv0[i];
      if (c == 0) {
        break;
      }
      if (c == 47) {
        last = i;
      }
      if (c == 92) {
        last = i;
      }
      i = i + 1;
    }
    if (last >= 0) {
      let j: i32 = 0;
      while (j < 256) {
        let a: u8 = argv0[last + 1 + j];
        let b: u8 = base[j];
        if (a != b) {
          return 0;
        }
        if (a == 0) {
          return 1;
        }
        j = j + 1;
      }
      return 0;
    }
  }
  if (argv0 == 0 as *u8) {
    if (base[0] == 0) {
      return 1;
    }
    return 0;
  }
  let j2: i32 = 0;
  while (j2 < 256) {
    let a2: u8 = argv0[j2];
    let b2: u8 = base[j2];
    if (a2 != b2) {
      return 0;
    }
    if (a2 == 0) {
      return 1;
    }
    j2 = j2 + 1;
  }
  return 0;
}
