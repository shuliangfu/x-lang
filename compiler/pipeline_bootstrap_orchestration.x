// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-23：真迁 .x — 实验链占位 TU（产品 strict 用 -DPIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER）。
// 产品：./shux-c -E → seeds/pipeline_bootstrap_orchestration.from_x.c → pipeline_bootstrap_orchestration.o
// weak pipeline_run_x_pipeline_impl 仍仅在需要时由手写 seed 条件编译补齐（语言尚无 weak 导出）。

#[no_mangle]
function pipeline_bootstrap_orchestration_placeholder(): i32 {
  return 0;
}
