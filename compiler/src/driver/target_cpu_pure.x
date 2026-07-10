// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-2/3：target_cpu 纯逻辑真迁 .x。
// - pending features（G-02f-2）
// - SIMD 拼写 is_vector / lanes_esz（G-02f-3；逐字节比较，无大 u8[] 表）
//
// 冷启动：seeds/target_cpu_pure.from_x.c
//   优先：./shux-c src/driver/target_cpu_pure.x -E > seeds/target_cpu_pure.from_x.c
//   若 -E 卡死：seed 中 SIMD 段可与本文件语义手工对齐后提交。
// detect/resolve/print 仍在 target_cpu.inc。

let g_driver_pending_target_cpu_features: u32 = 0;

#[no_mangle]
function driver_set_pending_target_cpu_features(features: u32): void {
  g_driver_pending_target_cpu_features = features;
}

#[no_mangle]
function driver_get_pending_target_cpu_features(): u32 {
  return g_driver_pending_target_cpu_features;
}

/** ASCII 小写；用于 Vec4f 等大小写不敏感比较。 */
function tcp_tolower(c: u8): u8 {
  if (c >= 65 && c <= 90) {
    return (c + 32) as u8;
  }
  return c;
}

/** 长度 5 的忽略大小写相等。 */
function tcp_eq5(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8): i32 {
  if (tcp_tolower(name[0]) != a0) { return 0; }
  if (tcp_tolower(name[1]) != a1) { return 0; }
  if (tcp_tolower(name[2]) != a2) { return 0; }
  if (tcp_tolower(name[3]) != a3) { return 0; }
  if (tcp_tolower(name[4]) != a4) { return 0; }
  return 1;
}

/** 长度 6 的忽略大小写相等。 */
function tcp_eq6(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8, a5: u8): i32 {
  if (tcp_tolower(name[0]) != a0) { return 0; }
  if (tcp_tolower(name[1]) != a1) { return 0; }
  if (tcp_tolower(name[2]) != a2) { return 0; }
  if (tcp_tolower(name[3]) != a3) { return 0; }
  if (tcp_tolower(name[4]) != a4) { return 0; }
  if (tcp_tolower(name[5]) != a5) { return 0; }
  return 1;
}

#[no_mangle]
function shu_simd_is_vector_type_spelling(name: *u8, name_len: usize): i32 {
  if (name == 0 as *u8 || name_len == 0) {
    return 0;
  }
  if (name_len == 5) {
    if (tcp_eq5(name, 105, 51, 50, 120, 52) != 0) { return 1; }
    if (tcp_eq5(name, 105, 51, 50, 120, 56) != 0) { return 1; }
    if (tcp_eq5(name, 117, 51, 50, 120, 52) != 0) { return 1; }
    if (tcp_eq5(name, 117, 51, 50, 120, 56) != 0) { return 1; }
    if (tcp_eq5(name, 102, 51, 50, 120, 52) != 0) { return 1; }
    if (tcp_eq5(name, 118, 101, 99, 52, 102) != 0) { return 1; }
    if (tcp_eq5(name, 118, 101, 99, 56, 105) != 0) { return 1; }
  }
  if (name_len == 6) {
    if (tcp_eq6(name, 105, 51, 50, 120, 49, 54) != 0) { return 1; }
    if (tcp_eq6(name, 117, 51, 50, 120, 49, 54) != 0) { return 1; }
  }
  return 0;
}

#[no_mangle]
function shu_simd_vector_lanes_esz_from_spelling(name: *u8, name_len: usize, out_lanes: *i32, out_esz: *i32): i32 {
  let lanes: i32 = 4;
  let esz: i32 = 4;
  if (out_lanes == 0 as *i32 || out_esz == 0 as *i32) {
    return -1;
  }
  if (shu_simd_is_vector_type_spelling(name, name_len) == 0) {
    return -1;
  }
  if (name_len == 5 && name[4] == 56) {
    lanes = 8;
  }
  if (name_len == 6 && name[4] == 49 && name[5] == 54) {
    lanes = 16;
  }
  if (name_len == 5 && tcp_eq5(name, 118, 101, 99, 56, 105) != 0) {
    lanes = 8;
  }
  out_lanes[0] = lanes;
  out_esz[0] = esz;
  return 0;
}
