// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// pipeline_run_impl_alias — Darwin arm64 product body for the three
// symbols the host cc of seeds/pipeline_run_impl_alias.from_x.c emits.
// pipeline_run_x_pipeline_impl forwards six pointers and the length.
// parse_into_buf returns the 8-byte parse result in one register.
// parse_into_init swaps the two pointers before the callee.
// This object is not pipeline_run_x_link_alias.o.
// Linux and Windows keep host cc of the C seed.
// PLATFORM: MACOS|DARWIN for this object path. SHARED symbol names.

struct ParseIntoResult {
  ok: i32;
  main_idx: i32;
}

extern "C" function parser_parse_into_buf(arena: *u8, module: *u8, data: *u8, len: i32): ParseIntoResult;
extern "C" function parser_parse_into_init(arena: *u8, module: *u8): void;
extern "C" function run_x_pipeline_impl(module: *u8, arena: *u8, source: *u8, source_len: u64, out_buf: *u8, ctx: *u8): i32;

/**
 * Forward the asm-only pipeline entry to run_x_pipeline_impl.
 * @param module *u8 — module pointer, forwarded unchanged
 * @param arena *u8 — arena pointer, forwarded unchanged
 * @param source *u8 — source bytes, forwarded unchanged
 * @param source_len u64 — source length, forwarded unchanged
 * @param out_buf *u8 — codegen output buffer, forwarded unchanged
 * @param ctx *u8 — dependency context, forwarded unchanged
 * @return i32 — the value run_x_pipeline_impl returns
 * Null pointers are forwarded. This function does not write them.
 * PLATFORM: MACOS|DARWIN arm64. Linux and Windows stay on the C seed.
 */
function pipeline_run_x_pipeline_impl(module: *u8, arena: *u8, source: *u8, source_len: u64, out_buf: *u8, ctx: *u8): i32 {
  unsafe {
    let r: i32 = run_x_pipeline_impl(module, arena, source, source_len, out_buf, ctx);
    return r;
  }
  return 0;
}

/**
 * Forward parse_into_buf and return the 8-byte result.
 * ok is the first i32. main_idx is the second i32. Both travel in x0.
 * @param arena *u8 — arena pointer, forwarded unchanged
 * @param module *u8 — module pointer, forwarded unchanged
 * @param data *u8 — source bytes, forwarded unchanged
 * @param len i32 — source length, forwarded unchanged
 * @return ParseIntoResult — the value parser_parse_into_buf returns
 * PLATFORM: MACOS|DARWIN arm64.
 */
function parse_into_buf(arena: *u8, module: *u8, data: *u8, len: i32): ParseIntoResult {
  unsafe {
    let r: ParseIntoResult = parser_parse_into_buf(arena, module, data, len);
    return r;
  }
}

/**
 * Swap the two pointers, then call parser_parse_into_init.
 * The public order is module then arena. The callee takes arena then module.
 * @param module *u8 — becomes the callee's second argument
 * @param arena *u8 — becomes the callee's first argument
 * PLATFORM: MACOS|DARWIN arm64.
 */
function parse_into_init(module: *u8, arena: *u8): void {
  unsafe { parser_parse_into_init(arena, module); }
}
