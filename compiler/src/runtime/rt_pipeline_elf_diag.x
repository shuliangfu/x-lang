// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-304/445 / P2 runtime rest：ELF ctx 诊断 note（pure 读表）。
// 产品实现：seeds/rt_pipeline_elf_diag.from_x.c；hybrid 宏 SHUX_RT_PIPELINE_ELF_DIAG_FROM_X。
// G-02f-445：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。

export extern "C" function runtime_pipeline_elf_ctx_diag_note_impl(ctx_bytes: *u8): void;

/** elf ctx 诊断 note（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
export function runtime_pipeline_elf_ctx_diag_note(ctx_bytes: *u8): void {
  unsafe {
    runtime_pipeline_elf_ctx_diag_note_impl(ctx_bytes);
    return;
  }
}
