// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-314 / P2 runtime rest：-x -E emit 主体。
// 产品实现：seeds/rt_run_x_emit.from_x.c；hybrid 宏 SHUX_RT_RUN_X_EMIT_FROM_X。

/** 执行 -x -E（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function driver_run_x_emit_c(): i32 {
  return 1;
}
