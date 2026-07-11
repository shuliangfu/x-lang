// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-263/431 / P2 R1：argv 令牌比较（drv_eq_* / path_ends / target_has_arm）。
// 产品默认 seeds/runtime.from_x.c；hybrid 用 seeds/rt_argv.from_x.c。
// G-02f-431：15 函数全部 .x 真迁（memcmp → flat early-return byte 比较），-E 通过。

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

// G-02f-431：drv_eq_minus_freestanding 真迁（"-freestanding" 13 字节，flat early-return）。
#[no_mangle]
function drv_eq_minus_freestanding(buf: *u8, len: i32): i32 {
  if (len != 13) { return 0; }
  if (buf[0] != 45) { return 0; }
  if (buf[1] != 102) { return 0; }
  if (buf[2] != 114) { return 0; }
  if (buf[3] != 101) { return 0; }
  if (buf[4] != 101) { return 0; }
  if (buf[5] != 115) { return 0; }
  if (buf[6] != 116) { return 0; }
  if (buf[7] != 97) { return 0; }
  if (buf[8] != 110) { return 0; }
  if (buf[9] != 100) { return 0; }
  if (buf[10] != 105) { return 0; }
  if (buf[11] != 110) { return 0; }
  if (buf[12] != 103) { return 0; }
  return 1;
}

// G-02f-431：drv_eq_legacy_f32_abi 真迁（"-legacy-f32-abi" 15 字节）。
#[no_mangle]
function drv_eq_legacy_f32_abi(buf: *u8, len: i32): i32 {
  if (len != 15) { return 0; }
  if (buf[0] != 45) { return 0; }
  if (buf[1] != 108) { return 0; }
  if (buf[2] != 101) { return 0; }
  if (buf[3] != 103) { return 0; }
  if (buf[4] != 97) { return 0; }
  if (buf[5] != 99) { return 0; }
  if (buf[6] != 121) { return 0; }
  if (buf[7] != 45) { return 0; }
  if (buf[8] != 102) { return 0; }
  if (buf[9] != 51) { return 0; }
  if (buf[10] != 50) { return 0; }
  if (buf[11] != 45) { return 0; }
  if (buf[12] != 97) { return 0; }
  if (buf[13] != 98) { return 0; }
  if (buf[14] != 105) { return 0; }
  return 1;
}

// G-02f-431：drv_eq_fsanitize_address 真迁（"-fsanitize=address" 18 字节）。
#[no_mangle]
function drv_eq_fsanitize_address(buf: *u8, len: i32): i32 {
  if (len != 18) { return 0; }
  if (buf[0] != 45) { return 0; }
  if (buf[1] != 102) { return 0; }
  if (buf[2] != 115) { return 0; }
  if (buf[3] != 97) { return 0; }
  if (buf[4] != 110) { return 0; }
  if (buf[5] != 105) { return 0; }
  if (buf[6] != 116) { return 0; }
  if (buf[7] != 105) { return 0; }
  if (buf[8] != 122) { return 0; }
  if (buf[9] != 101) { return 0; }
  if (buf[10] != 61) { return 0; }
  if (buf[11] != 97) { return 0; }
  if (buf[12] != 100) { return 0; }
  if (buf[13] != 100) { return 0; }
  if (buf[14] != 114) { return 0; }
  if (buf[15] != 101) { return 0; }
  if (buf[16] != 115) { return 0; }
  if (buf[17] != 115) { return 0; }
  return 1;
}

// G-02f-431：drv_eq_minus_backend 真迁（"-backend" 8 字节）。
#[no_mangle]
function drv_eq_minus_backend(buf: *u8, len: i32): i32 {
  if (len != 8) { return 0; }
  if (buf[0] != 45) { return 0; }
  if (buf[1] != 98) { return 0; }
  if (buf[2] != 97) { return 0; }
  if (buf[3] != 99) { return 0; }
  if (buf[4] != 107) { return 0; }
  if (buf[5] != 101) { return 0; }
  if (buf[6] != 110) { return 0; }
  if (buf[7] != 100) { return 0; }
  return 1;
}

// G-02f-431：drv_eq_minus_target 真迁（"-target" 前缀，len>=7）。
#[no_mangle]
function drv_eq_minus_target(buf: *u8, len: i32): i32 {
  if (len < 7) { return 0; }
  if (buf[0] != 45) { return 0; }
  if (buf[1] != 116) { return 0; }
  if (buf[2] != 97) { return 0; }
  if (buf[3] != 114) { return 0; }
  if (buf[4] != 103) { return 0; }
  if (buf[5] != 101) { return 0; }
  if (buf[6] != 116) { return 0; }
  return 1;
}

// G-02f-431：drv_eq_minus_target_cpu 真迁（"-target-cpu" 前缀，len>=11）。
#[no_mangle]
function drv_eq_minus_target_cpu(buf: *u8, len: i32): i32 {
  if (len < 11) { return 0; }
  if (buf[0] != 45) { return 0; }
  if (buf[1] != 116) { return 0; }
  if (buf[2] != 97) { return 0; }
  if (buf[3] != 114) { return 0; }
  if (buf[4] != 103) { return 0; }
  if (buf[5] != 101) { return 0; }
  if (buf[6] != 116) { return 0; }
  if (buf[7] != 45) { return 0; }
  if (buf[8] != 99) { return 0; }
  if (buf[9] != 112) { return 0; }
  if (buf[10] != 117) { return 0; }
  return 1;
}

// G-02f-431：drv_eq_print_target_cpu 真迁（"--print-target-cpu" 18 或 "-print-target-cpu" 17）。
#[no_mangle]
function drv_eq_print_target_cpu(buf: *u8, len: i32): i32 {
  if (len == 18) {
    if (buf[0] != 45) { return 0; }
    if (buf[1] != 45) { return 0; }
    if (buf[2] != 112) { return 0; }
    if (buf[3] != 114) { return 0; }
    if (buf[4] != 105) { return 0; }
    if (buf[5] != 110) { return 0; }
    if (buf[6] != 116) { return 0; }
    if (buf[7] != 45) { return 0; }
    if (buf[8] != 116) { return 0; }
    if (buf[9] != 97) { return 0; }
    if (buf[10] != 114) { return 0; }
    if (buf[11] != 103) { return 0; }
    if (buf[12] != 101) { return 0; }
    if (buf[13] != 116) { return 0; }
    if (buf[14] != 45) { return 0; }
    if (buf[15] != 99) { return 0; }
    if (buf[16] != 112) { return 0; }
    if (buf[17] != 117) { return 0; }
    return 1;
  }
  if (len == 17) {
    if (buf[0] != 45) { return 0; }
    if (buf[1] != 112) { return 0; }
    if (buf[2] != 114) { return 0; }
    if (buf[3] != 105) { return 0; }
    if (buf[4] != 110) { return 0; }
    if (buf[5] != 116) { return 0; }
    if (buf[6] != 45) { return 0; }
    if (buf[7] != 116) { return 0; }
    if (buf[8] != 97) { return 0; }
    if (buf[9] != 114) { return 0; }
    if (buf[10] != 103) { return 0; }
    if (buf[11] != 101) { return 0; }
    if (buf[12] != 116) { return 0; }
    if (buf[13] != 45) { return 0; }
    if (buf[14] != 99) { return 0; }
    if (buf[15] != 112) { return 0; }
    if (buf[16] != 117) { return 0; }
    return 1;
  }
  return 0;
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
