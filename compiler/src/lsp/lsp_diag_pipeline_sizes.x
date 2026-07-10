// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-1：原 lsp_diag_pipeline_sizes.inc 瘦 struct sizeof 真迁 .x。
// 产品 G05 链 sizes_nostub.o：仅需三枚 lsp_diag_pipeline_sizeof_*。
// 常量与历史 C 瘦布局一致（arena=16 / module=40 / dep_ctx=1368）；
// 全量 pipeline 布局见 pipeline_sizeof_*（bootstrap_seed_pipeline）。

/** 与历史 C `sizeof(struct ast_ASTArena)` 瘦布局一致。 */
#[no_mangle]
function lsp_diag_pipeline_sizeof_arena(): usize {
  return 16;
}

/** 与历史 C `sizeof(struct ast_Module)` 瘦布局一致。 */
#[no_mangle]
function lsp_diag_pipeline_sizeof_module(): usize {
  return 40;
}

/** 与历史 C `sizeof(struct ast_PipelineDepCtx)` 瘦布局一致（非 4MiB 全量 dep ctx）。 */
#[no_mangle]
function lsp_diag_pipeline_sizeof_dep_ctx(): usize {
  return 1368;
}
