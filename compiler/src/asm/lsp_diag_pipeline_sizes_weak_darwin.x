// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// lsp_diag_pipeline_sizes_weak_darwin.x — Darwin arm64 body of
// src/lsp/lsp_diag_pipeline_sizes.o.
//
// The three sizes match this host's C seed: arena 16, module 40,
// dep context 1560. The allocator stub returns 0. Path fill does
// not write. Linux and Windows keep the C seed, which uses sizeof.
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Anchor for this Darwin pipeline-size stub.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lsp_diag_sizes_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Byte size of the slim AST arena used by the diagnostic stub.
 * @return u64 — 16
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lsp_diag_pipeline_sizeof_arena(): u64 {
  return 16;
}

/**
 * Byte size of the slim module used by the diagnostic stub.
 * @return u64 — 40
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lsp_diag_pipeline_sizeof_module(): u64 {
  return 40;
}

/**
 * Byte size of the pipeline dependency context on Darwin arm64.
 * @return u64 — 1560
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lsp_diag_pipeline_sizeof_dep_ctx(): u64 {
  return 1560;
}

/**
 * Placeholder allocation size. A linked context object supplies the strong body.
 * @return u64 — 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lsp_diag_x_alloc_dep_ctx_size(): u64 {
  return 0;
}

/**
 * Placeholder path fill. Arguments are kept for the C ABI and are not written.
 * @param ctx context pointer, unused
 * @param entry_dir entry directory, unused
 * @param lib_roots root vector, unused
 * @param n_lib_roots root count, unused
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lsp_diag_pipeline_ctx_fill_paths(ctx: *u8, entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): void {
  let keep_ctx: *u8 = ctx;
  let keep_dir: *u8 = entry_dir;
  let keep_roots: *u8 = lib_roots;
  let keep_n: i32 = n_lib_roots;
  if (keep_ctx == keep_ctx) {
    if (keep_dir == keep_dir) {
      if (keep_roots == keep_roots) {
        if (keep_n == keep_n) {
          return;
        }
      }
    }
  }
}
