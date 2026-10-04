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

/**
 * Byte size of the diagnostic pipeline arena.
 * @return i64 — 16. The low 64 bits match size_t. Link name unchanged.
 * PLATFORM: SHARED — the installed product cannot asm-emit this usize return.
 */
#[no_mangle]
export function lsp_diag_pipeline_sizeof_arena(): i64 {
  return 16;
}

/**
 * Byte size of the diagnostic pipeline module.
 * @return i64 — 40. The low 64 bits match size_t. Link name unchanged.
 * PLATFORM: SHARED — the installed product cannot asm-emit this usize return.
 */
#[no_mangle]
export function lsp_diag_pipeline_sizeof_module(): i64 {
  return 40;
}

/**
 * Byte size of the diagnostic pipeline dependency context.
 * @return i64 — 1368. The low 64 bits match size_t. Link name unchanged.
 * PLATFORM: SHARED — the installed product cannot asm-emit this usize return.
 */
#[no_mangle]
export function lsp_diag_pipeline_sizeof_dep_ctx(): i64 {
  return 1368;
}
