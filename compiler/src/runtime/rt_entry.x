// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-301 / P2 runtime R10-lite：入口侧 pure 薄门闩（explain/smoke/fmt 报告）。
// 产品实现：seeds/rt_entry.from_x.c；hybrid 宏 SHUX_RT_ENTRY_FROM_X。
//
// 符号：runtime_try_handle_explain_cli / shux_smoke_diag_enabled /
//       driver_emit_legacy_smoke_summary_stdout / driver_fmt_report_no_files。
// main_entry 主体（!SHUX_USE_X_DRIVER）与 full compile 编排仍 mega。

extern "C" function strcmp(a: *u8, b: *u8): i32;

/** smoke 结构化诊断是否启用（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function shux_smoke_diag_enabled(): i32 {
  return 0;
}
