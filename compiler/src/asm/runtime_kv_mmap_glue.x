// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Shared anchor only. Darwin arm64 does not compile this file.
// The product body is runtime_kv_mmap_glue_darwin.x.
// Linux and Windows host-cc seeds/runtime_kv_mmap_glue.from_x.c.
// PLATFORM: SHARED anchor; MACOS|DARWIN arm64 product is the other file.

/** Exported function `runtime_kv_mmap_glue_x_doc_anchor`.
 * Implements `runtime_kv_mmap_glue_x_doc_anchor`.
 * @return i32
 */
export function runtime_kv_mmap_glue_x_doc_anchor(): i32 {
  return 0;
}
