// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f：backend_seed_mega_fallback 产品源迁 seeds/backend_seed_mega_fallback.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-104：+ ctx_reset / target_arch_local 薄门闩。

extern "C" function pipeline_seed_mega_ctx_reset_impl(ctx: *u8, mod: *u8): void;
extern "C" function pipeline_dep_ctx_target_arch_local_impl(ctx: *u8): i32;

function backend_seed_mega_fallback_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-104：seed mega helpers 门闩 ---- */

#[no_mangle]
function pipeline_seed_mega_ctx_reset(ctx: *u8, mod: *u8): void {
  unsafe {
    pipeline_seed_mega_ctx_reset_impl(ctx, mod);
  }
}

#[no_mangle]
function pipeline_dep_ctx_target_arch_local(ctx: *u8): i32 {
  unsafe {
    return pipeline_dep_ctx_target_arch_local_impl(ctx);
  }
  return 0;
}
