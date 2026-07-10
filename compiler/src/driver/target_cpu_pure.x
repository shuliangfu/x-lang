// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-2：target_cpu 纯状态真迁 .x（driver pending features）。
// detect/resolve/print/SIMD 拼写仍在 target_cpu.inc（OS/#if + 大表；shux-c -E 对多 u8[] 局部表易卡死）。

let g_driver_pending_target_cpu_features: u32 = 0;

#[no_mangle]
function driver_set_pending_target_cpu_features(features: u32): void {
  g_driver_pending_target_cpu_features = features;
}

#[no_mangle]
function driver_get_pending_target_cpu_features(): u32 {
  return g_driver_pending_target_cpu_features;
}
