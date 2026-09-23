// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// w848: these three functions are the only bodies. w848 deleted
// seeds/lsp_diag_pipeline_sizes.from_x.c. The product object
// src/lsp/lsp_diag_pipeline_sizes_nostub.o is pure-asm of this file.
// There is no gcc -E path and no cold-seed fallback.
// XLANG_G05_PREFER_X_O is ignored. Windows takes the same path.
// Constants: arena=16, module=40, dep_ctx=1368.
// PLATFORM: SHARED.

/** Exported function `lsp_diag_pipeline_sizeof_arena`.
 * Implements `lsp_diag_pipeline_sizeof_arena`.
 * @return usize
 */
#[no_mangle]
export function lsp_diag_pipeline_sizeof_arena(): usize {
  return 16;
}

/** Exported function `lsp_diag_pipeline_sizeof_module`.
 * Implements `lsp_diag_pipeline_sizeof_module`.
 * @return usize
 */
#[no_mangle]
export function lsp_diag_pipeline_sizeof_module(): usize {
  return 40;
}

/** Exported function `lsp_diag_pipeline_sizeof_dep_ctx`.
 * Implements `lsp_diag_pipeline_sizeof_dep_ctx`.
 * @return usize
 */
#[no_mangle]
export function lsp_diag_pipeline_sizeof_dep_ctx(): usize {
  return 1368;
}
