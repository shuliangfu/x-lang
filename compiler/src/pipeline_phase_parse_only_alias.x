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

// pipeline_phase_parse_only_alias — Darwin arm64 product body for the
// two symbols host cc of seeds/pipeline_phase_parse_only_alias.from_x.c
// emits. phase_parse_only resets, parses, sets the main index, then
// records three diagnostics. The return is -2 times the parse ok flag.
// phase_parse_load runs that sequence and then load_deps.
// This object is not pipeline_phase_parse_only_partial.o.
// Linux and Windows keep host cc of the C seed.
// PLATFORM: MACOS|DARWIN for this object path. SHARED symbol names.

struct ParseIntoResult {
  ok: i32;
  main_idx: i32;
}

extern "C" function pipeline_strict_parse_into_init(arena: *u8, module: *u8): void;
extern "C" function parser_parse_into_buf(arena: *u8, module: *u8, data: *u8, len: i32): ParseIntoResult;
extern "C" function parser_parse_into_set_main_index(module: *u8, main_idx: i32): void;
extern "C" function pipeline_module_num_funcs(module: *u8): i32;
extern "C" function driver_diagnostic_after_entry_parse(n: i32): void;
extern "C" function driver_diagnostic_after_entry_parse_module(module: *u8): void;
extern "C" function driver_diagnostic_entry_module(module: *u8, arena: *u8): void;
extern "C" function pipeline_impl_phase_load_deps(module: *u8, arena: *u8, ctx: *u8): i32;

/**
 * Parse one module and record the three entry diagnostics.
 * ctx is part of the ABI and is not read. source_len is narrowed to i32
 * before parser_parse_into_buf. The 8-byte result's main_idx is passed
 * to set_main_index. The return value is -2 times result.ok.
 * @param module *u8 — module pointer, forwarded to the callees
 * @param arena *u8 — arena pointer, forwarded to the callees
 * @param source_data *u8 — source bytes, forwarded to the parser
 * @param source_len u64 — source length, narrowed to i32 for the parser
 * @param ctx *u8 — dependency context, kept for the ABI, not read here
 * @return i32 — -2 times the parser ok flag
 * PLATFORM: MACOS|DARWIN arm64. Linux and Windows stay on the C seed.
 */
function pipeline_impl_phase_parse_only(module: *u8, arena: *u8, source_data: *u8, source_len: u64, ctx: *u8): i32 {
  unsafe {
    let len_i32: i32 = source_len as i32;
    pipeline_strict_parse_into_init(arena, module);
    let r: ParseIntoResult = parser_parse_into_buf(arena, module, source_data, len_i32);
    let idx: i32 = r.main_idx;
    parser_parse_into_set_main_index(module, idx);
    let n: i32 = pipeline_module_num_funcs(module);
    driver_diagnostic_after_entry_parse(n);
    driver_diagnostic_after_entry_parse_module(module);
    driver_diagnostic_entry_module(module, arena);
    let ok: i32 = r.ok;
    return (0 - 2) * ok;
  }
  return 0;
}

/**
 * Parse, then return the load_deps result.
 * The parse return is kept in a local so the call is not dropped.
 * ctx is forwarded only to pipeline_impl_phase_load_deps.
 * @param module *u8 — module pointer, forwarded unchanged
 * @param arena *u8 — arena pointer, forwarded unchanged
 * @param source_data *u8 — source bytes, forwarded to the parse step
 * @param source_len u64 — source length, forwarded to the parse step
 * @param ctx *u8 — dependency context, forwarded to load_deps
 * @return i32 — the value pipeline_impl_phase_load_deps returns
 * PLATFORM: MACOS|DARWIN arm64.
 */
function pipeline_impl_phase_parse_load(module: *u8, arena: *u8, source_data: *u8, source_len: u64, ctx: *u8): i32 {
  unsafe {
    let ignored: i32 = pipeline_impl_phase_parse_only(module, arena, source_data, source_len, ctx);
    let r: i32 = pipeline_impl_phase_load_deps(module, arena, ctx);
    return r;
  }
  return 0;
}
