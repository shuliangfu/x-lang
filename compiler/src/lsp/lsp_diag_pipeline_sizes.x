// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

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
