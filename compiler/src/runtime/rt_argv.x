// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-263 / P2 R1：argv 令牌比较（drv_eq_* / path_ends / target_has_arm）。
// 产品默认 seeds/runtime.from_x.c；hybrid 用 seeds/rt_argv.from_x.c。
// 实现以 seed C 为准（memcmp）；本文件为逻辑锚点与逐步 -E 真迁目标。

#[no_mangle]
function drv_eq_minus_o(buf: *u8, len: i32): i32 {
  if (len != 2) {
    return 0;
  }
  if (buf[0] != 45 || buf[1] != 111) {
    return 0;
  }
  return 1;
}

#[no_mangle]
function drv_eq_minus_L(buf: *u8, len: i32): i32 {
  if (len != 2) {
    return 0;
  }
  if (buf[0] != 45 || buf[1] != 76) {
    return 0;
  }
  return 1;
}

#[no_mangle]
function drv_eq_minus_O(buf: *u8, len: i32): i32 {
  if (len != 2) {
    return 0;
  }
  if (buf[0] != 45 || buf[1] != 79) {
    return 0;
  }
  return 1;
}

#[no_mangle]
function drv_eq_flto(buf: *u8, len: i32): i32 {
  if (len != 5) {
    return 0;
  }
  if (buf[0] != 45 || buf[1] != 102 || buf[2] != 108 || buf[3] != 116 || buf[4] != 111) {
    return 0;
  }
  return 1;
}

#[no_mangle]
function drv_eq_asm_word(buf: *u8, len: i32): i32 {
  if (len != 3) {
    return 0;
  }
  if (buf[0] != 97 || buf[1] != 115 || buf[2] != 109) {
    return 0;
  }
  return 1;
}

#[no_mangle]
function drv_eq_c_word(buf: *u8, len: i32): i32 {
  if (len != 1) {
    return 0;
  }
  if (buf[0] != 99) {
    return 0;
  }
  return 1;
}

#[no_mangle]
function drv_path_ends_x(buf: *u8, len: i32): i32 {
  if (len >= 2 && buf[(len - 2) as usize] == 46 && buf[(len - 1) as usize] == 120) {
    return 1;
  }
  if (len >= 3 && buf[(len - 3) as usize] == 46 && buf[(len - 2) as usize] == 115 &&
      buf[(len - 1) as usize] == 117) {
    return 1;
  }
  return 0;
}

#[no_mangle]
function drv_target_has_arm(buf: *u8, len: i32): i32 {
  let start: i32 = 0;
  while (start + 5 <= len) {
    if (buf[start as usize] == 97 && buf[(start + 1) as usize] == 114 &&
        buf[(start + 2) as usize] == 109 && buf[(start + 3) as usize] == 54 &&
        buf[(start + 4) as usize] == 52) {
      return 1;
    }
    start = start + 1;
  }
  return 0;
}
