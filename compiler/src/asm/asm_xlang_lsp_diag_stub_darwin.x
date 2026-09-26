// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// asm_xlang_lsp_diag_stub_darwin.x — Darwin arm64 body of
// asm_xlang_lsp_diag_stub.o.
//
// Diagnostics and semantic tokens both write the two bytes '[' ']'.
// A null buffer or a capacity under 2 returns -1. Cache invalidation
// forwards to lsp_diag_invalidate_cache. Linux and Windows keep the C seed.
// PLATFORM: MACOS|DARWIN arm64.

extern function lsp_diag_invalidate_cache(): void;

/**
 * Anchor for this Darwin LSP diagnostic stub.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lsp_diag_stub_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Write '[' then ']' into out. Does not touch later bytes.
 * @param out destination buffer
 * @param cap destination capacity
 * @return i32 — 2, or -1 when the buffer cannot hold both bytes
 * PLATFORM: MACOS|DARWIN
 */
function lsp_stub_empty(out: *u8, cap: i32): i32 {
  if (out == 0) {
    return 0 - 1;
  }
  if (cap < 2) {
    return 0 - 1;
  }
  let p: *u8 = out;
  p[0] = 91;
  let q: *u8 = out + 1;
  q[0] = 93;
  return 2;
}

/**
 * Empty diagnostics JSON fragment. id and source are kept for the C ABI.
 * @param id_val request id, unused
 * @param source document bytes, unused
 * @param source_len document length, unused
 * @param out_buf destination
 * @param out_cap destination capacity
 * @return i32 — 2, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lsp_build_diagnostics_response(id_val: i32, source: *u8, source_len: i32, out_buf: *u8, out_cap: i32): i32 {
  let keep_id: i32 = id_val;
  let keep_src: *u8 = source;
  let keep_len: i32 = source_len;
  if (keep_id == keep_id) {
    if (keep_src == keep_src) {
      if (keep_len == keep_len) {
        return lsp_stub_empty(out_buf, out_cap);
      }
    }
  }
  return 0 - 1;
}

/**
 * Empty semantic-token fragment. Same buffer contract as diagnostics.
 * @param id_val request id, unused
 * @param doc_buf document bytes, unused
 * @param doc_len document length, unused
 * @param out_buf destination
 * @param out_cap destination capacity
 * @return i32 — 2, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lsp_build_semantic_tokens_response(id_val: i32, doc_buf: *u8, doc_len: i32, out_buf: *u8, out_cap: i32): i32 {
  let keep_id: i32 = id_val;
  let keep_doc: *u8 = doc_buf;
  let keep_len: i32 = doc_len;
  if (keep_id == keep_id) {
    if (keep_doc == keep_doc) {
      if (keep_len == keep_len) {
        return lsp_stub_empty(out_buf, out_cap);
      }
    }
  }
  return 0 - 1;
}

/**
 * Forward cache invalidation to the linked diagnostic object.
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lsp_io_lsp_diag_invalidate_cache(): void {
  unsafe {
    lsp_diag_invalidate_cache();
  }
}
