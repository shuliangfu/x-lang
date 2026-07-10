// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-301/310 / P2 runtime R10：入口侧 thin gates。
// 产品实现：seeds/rt_entry.from_x.c；hybrid 宏 SHUX_RT_ENTRY_FROM_X。
//
// 符号：explain/smoke/fmt_report_no_files + run_compiler_c + driver_build_build_x。
// main_entry 主体（!SHUX_USE_X_DRIVER）与 full compile 编排仍 mega。

extern "C" function strcmp(a: *u8, b: *u8): i32;

/** smoke 结构化诊断是否启用（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function shux_smoke_diag_enabled(): i32 {
  return 0;
}

/** 转调 main_run_compiler_c（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function run_compiler_c(argc: i32, argv: *u8): i32 {
  if (argc < 0) {
    return 1;
  }
  return 0;
}

/** make build-tool + build_tool（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function driver_build_build_x(): i32 {
  return 0;
}
