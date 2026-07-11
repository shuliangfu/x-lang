// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-303/304/455 / P2 runtime rest：-x -E emit 状态槽 + setters + argv 扫描。
// 产品实现：seeds/rt_emit_state.from_x.c；hybrid 宏 SHUX_RT_EMIT_STATE_FROM_X。
// G-02f-455：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。
//   driver_argv_parse_x_emit_c 保留在 rest（char **argv 签名不匹配 .x 的 *u8）。

extern "C" function driver_run_x_emit_c_set_path_impl(path: *u8, path_len: i32): i32;

/** path 灌入 emit 槽（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
function driver_run_x_emit_c_set_path(path: *u8, path_len: i32): i32 {
  unsafe {
    return driver_run_x_emit_c_set_path_impl(path, path_len);
  }
  return 0;
}
