// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-257 / L2-3：target_cpu pure flags 子集（pending + tolower + eq5/eq6）。
// 产品默认仍链 seeds/target_cpu_pure.from_x.c 整文件。
// SHUX_G05_PREFER_X_O=1 时：本 TU .x→-E→.o + seed 残体（-DSHUX_L2_TARGET_CPU_FLAGS_FROM_X）ld -r → target_cpu.o。
// 故意不含 tcp_parse_named / resolve / detect / print（OS/#if/stdio 或会拖垮 -E）。

let g_driver_pending_target_cpu_features: u32 = 0;

#[no_mangle]
export function driver_set_pending_target_cpu_features(features: u32): void {
  g_driver_pending_target_cpu_features = features;
}

#[no_mangle]
export function driver_get_pending_target_cpu_features(): u32 {
  return g_driver_pending_target_cpu_features;
}

#[no_mangle]
export function tcp_tolower(c: u8): u8 {
  if (c >= 65 && c <= 90) {
    return (c + 32) as u8;
  }
  return c;
}

#[no_mangle]
export function tcp_eq5(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8): i32 {
  if (tcp_tolower(name[0]) != a0) {
    return 0;
  }
  if (tcp_tolower(name[1]) != a1) {
    return 0;
  }
  if (tcp_tolower(name[2]) != a2) {
    return 0;
  }
  if (tcp_tolower(name[3]) != a3) {
    return 0;
  }
  if (tcp_tolower(name[4]) != a4) {
    return 0;
  }
  return 1;
}

#[no_mangle]
export function tcp_eq6(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8, a5: u8): i32 {
  if (tcp_eq5(name, a0, a1, a2, a3, a4) == 0) {
    return 0;
  }
  if (tcp_tolower(name[5]) != a5) {
    return 0;
  }
  return 1;
}
