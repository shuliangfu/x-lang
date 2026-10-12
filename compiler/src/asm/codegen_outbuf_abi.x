// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.

/* See implementation. */
/* See implementation. */
export struct CodegenOutBuf {
  data: u8[9437184];
  length: i32;
}

/**
 * Anchor so this type-only TU has a function.
 * Callers import CodegenOutBuf; they do not call this.
 * @return i32 — always 0
 * PLATFORM: SHARED
 */
export function codegen_outbuf_abi_x_doc_anchor(): i32 {
  return 0;
}
